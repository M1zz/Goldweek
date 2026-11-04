//
//  GoldweekIntents.swift
//  Goldweek
//
//  Siri · 단축어로 묻는다.
//   - "골드위크 연차 몇 개 남았어?": 홈 화면과 같은 계산으로 올해 남은 연차를 알려 준다.
//   - "골드위크 다음 공휴일": 내 나라의 다음 공휴일과 며칠 남았는지 알려 준다.
//

import AppIntents
import Foundation
import SwiftData

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
