//
//  GoldweekIntents.swift
//  Goldweek
//
//  Siri · 단축어로 묻는다.
//   - "골드위크 연차 몇 개 남았어?": 홈 화면과 같은 계산으로 올해 남은 연차를 알려 준다.
//   - "골드위크 다음 공휴일": 내 나라의 다음 공휴일과 며칠 남았는지 알려 준다.
//   - Spotlight: 휴가 기록마다 종류 · 날짜 · 메모를 싣는다. 누르면 그 휴가의 수정 화면이 열린다.
//

import AppIntents
import CoreSpotlight
import Foundation
import SwiftData
import SwiftUI
import GoldweekCore

// MARK: - 앱 화면으로 넘기는 요청

@MainActor @Observable
final class GoldweekRouter {
    static let shared = GoldweekRouter()
    /// 열어 달라는 휴가. `OpenLeaveSheet` 가 수정 시트로 열고 비운다.
    var leaveID: UUID?
}

// MARK: - 휴가 기록

struct LeaveEntity: AppEntity, IndexedEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("휴가", comment: "Siri/Spotlight: one leave record (a day off the user planned or took)")
    )
    static let defaultQuery = LeaveQuery()

    let id: String
    let kind: String
    let dates: String
    let note: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(kind)", subtitle: "\(dates)")
    }

    var attributeSet: CSSearchableItemAttributeSet {
        let set = defaultAttributeSet
        set.contentDescription = note.isEmpty ? nil : note
        return set
    }

    @MainActor
    init(_ record: LeaveRecord) {
        let formatter = DateFormatter()
        formatter.dateFormat = Strings.dateRangeFormat
        formatter.locale = Locale(identifier: Strings.localeIdentifier)
        let start = formatter.string(from: record.startDate)
        let range = record.daysCount == 1 ? start : "\(start) ~ \(formatter.string(from: record.endDate))"
        id = record.id.uuidString
        kind = record.displayTypeName
        dates = "\(range) · \(Strings.dayCount(record.effectiveLeaveDays))"
        note = record.note
    }
}

struct LeaveQuery: EntityStringQuery {
    @Dependency private var container: ModelContainer

    @MainActor
    func entities(for identifiers: [String]) async throws -> [LeaveEntity] {
        let wanted = Set(identifiers)
        return GoldweekLeaves.records(in: container).filter { wanted.contains($0.id.uuidString) }.map(LeaveEntity.init)
    }

    /// 종류 이름 · 메모에서 찾는다.
    @MainActor
    func entities(matching string: String) async throws -> [LeaveEntity] {
        GoldweekLeaves.records(in: container).map(LeaveEntity.init).filter {
            $0.kind.localizedCaseInsensitiveContains(string) || $0.note.localizedCaseInsensitiveContains(string)
        }
    }

    @MainActor
    func suggestedEntities() async throws -> [LeaveEntity] {
        GoldweekLeaves.records(in: container).prefix(20).map(LeaveEntity.init)
    }
}

/// 휴가를 연다. Spotlight · Siri 결과를 누르면 여기로 온다.
struct OpenLeaveIntent: OpenIntent {
    static let title = LocalizedStringResource("휴가 열기", comment: "Siri/Spotlight: open a leave record")
    static let description = IntentDescription(
        LocalizedStringResource("휴가 기록을 앱에서 열어 고칩니다.", comment: "Siri: open leave record description")
    )

    @Parameter(title: LocalizedStringResource("휴가", comment: "Siri: leave record parameter"),
               description: LocalizedStringResource("열어 볼 휴가 기록", comment: "Siri: leave record parameter description"))
    var target: LeaveEntity

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult {
        GoldweekRouter.shared.leaveID = UUID(uuidString: target.id)
        return .result()
    }
}

enum GoldweekLeaves {
    /// 최근 휴가부터. 취소한 휴가는 뺀다.
    @MainActor
    static func records(in container: ModelContainer) -> [LeaveRecord] {
        let descriptor = FetchDescriptor<LeaveRecord>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        return ((try? container.mainContext.fetch(descriptor)) ?? []).filter { $0.status != .cancelled }
    }

    /// Spotlight 에 싣는 휴가를 지금 것에 맞춘다. 앱을 열 때와 뒤로 보낼 때 부른다.
    @MainActor
    static func reindex(_ container: ModelContainer) async {
        let entities = records(in: container).map(LeaveEntity.init)
        let index = CSSearchableIndex.default()
        try? await index.deleteAppEntities(ofType: LeaveEntity.self)
        try? await index.indexAppEntities(entities)
    }
}

/// Spotlight 에서 고른 휴가를 수정 시트로 연다. 앱을 열 때 · 뒤로 보낼 때 색인도 맞춘다.
struct OpenLeaveSheet: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var profiles: [UserProfile]
    @State private var record: LeaveRecord?

    func body(content: Content) -> some View {
        content
            .onChange(of: GoldweekRouter.shared.leaveID, initial: true) { _, id in
                guard let id else { return }
                GoldweekRouter.shared.leaveID = nil
                record = try? modelContext.fetch(FetchDescriptor<LeaveRecord>(predicate: #Predicate { $0.id == id })).first
            }
            .onChange(of: scenePhase, initial: true) { _, phase in
                guard phase != .inactive else { return }
                let container = modelContext.container
                Task { await GoldweekLeaves.reindex(container) }
            }
            .sheet(item: $record) { record in
                EditLeaveSheet(record: record, profile: profiles.first, onSave: { self.record = nil })
            }
    }
}

struct RemainingLeaveIntent: AppIntent {
    static let title = LocalizedStringResource("남은 연차", comment: "Siri: how many annual leave days are left")
    static let description = IntentDescription(
        LocalizedStringResource("올해 남은 연차를 알려 줍니다.", comment: "Siri: remaining leave description")
    )

    @Dependency private var container: ModelContainer

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = ModelContext(container)
        guard let profile = try? context.fetch(FetchDescriptor<UserProfile>()).first else {
            return .result(dialog: IntentDialog(LocalizedStringResource("먼저 앱에서 연차를 설정해 주세요.", comment: "Siri: no profile yet")))
        }
        let records = (try? context.fetch(FetchDescriptor<LeaveRecord>())) ?? []
        // 홈 화면과 같은 계산 (HomeView)
        let remaining = LeaveUsageCalculator
            .currentSummary(records: records, startMonth: profile.yearStart, annualGrant: profile.totalAnnualLeave)
            .remaining(annualGrant: profile.totalAnnualLeave, includingBonus: false)
        let days = remaining.formatted(.number.precision(.fractionLength(0...1)))
        return .result(dialog: IntentDialog(LocalizedStringResource("올해 연차가 \(days)일 남았어요.", comment: "Siri: remaining leave. Argument is the number of days")))
    }
}

struct NextHolidayIntent: AppIntent {
    static let title = LocalizedStringResource("다음 공휴일", comment: "Siri: the next public holiday")
    static let description = IntentDescription(
        LocalizedStringResource("다음 공휴일과 며칠 남았는지 알려 줍니다.", comment: "Siri: next holiday description")
    )

    @Dependency private var container: ModelContainer

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = ModelContext(container)
        let country = (try? context.fetch(FetchDescriptor<UserProfile>()).first)?.country ?? .korea
        let calendar = Calendar.app
        let today = calendar.startOfDay(for: .now)
        let year = calendar.component(.year, from: today)
        let service = HolidayService()
        let upcoming = (service.getHolidays(for: year, country: country) + service.getHolidays(for: year + 1, country: country))
            .filter { $0.date >= today }
            .sorted { $0.date < $1.date }
        guard let next = upcoming.first else {
            return .result(dialog: IntentDialog(LocalizedStringResource("다가오는 공휴일을 찾지 못했어요.", comment: "Siri: no upcoming holiday")))
        }
        let days = calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: next.date)).day ?? 0
        let date = next.date.formatted(.dateTime.month().day().weekday())
        if days == 0 {
            return .result(dialog: IntentDialog(LocalizedStringResource("오늘이 \(next.name)이에요.", comment: "Siri: today is the holiday. Argument is the holiday name")))
        }
        return .result(dialog: IntentDialog(LocalizedStringResource("다음 공휴일은 \(date) \(next.name), \(days)일 남았어요.", comment: "Siri: next holiday. Arguments: date, name, days left")))
    }
}

struct GoldweekShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RemainingLeaveIntent(),
            phrases: [
                "How much leave do I have left in \(.applicationName)",
                "\(.applicationName) remaining leave"
            ],
            shortTitle: "Remaining Leave",
            systemImageName: "calendar.badge.clock"
        )
        AppShortcut(
            intent: NextHolidayIntent(),
            phrases: [
                "Next holiday in \(.applicationName)",
                "When is the next holiday with \(.applicationName)"
            ],
            shortTitle: "Next Holiday",
            systemImageName: "sun.max"
        )
    }
}
