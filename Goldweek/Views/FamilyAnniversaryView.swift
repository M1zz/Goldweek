//
//  FamilyAnniversaryView.swift
//  Goldweek
//
//  가족 기념일 — 가족 안에서는 공휴일이나 다름없는 날(생신·결혼기념일·기일)을 기록하고,
//  달력에 표시하고, 미리 휴가를 챙기게 돕는다. 음력·관계·"몇 번째"는 DDayCounter(음력세기)에서 가져왔다.
//

import SwiftUI
import SwiftData
#if canImport(UserNotifications)
import UserNotifications
#endif

// MARK: - 표시

extension FamilyAnniversary {
    /// 이름이 비면 관계와 종류로 ("엄마 · 생일")
    var displayTitle: String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty { return trimmed }
        let who = relation.trimmingCharacters(in: .whitespaces)
        return who.isEmpty ? kind.label : "\(who) · \(kind.label)"
    }
}

extension AnniversaryKind {
    var label: String { Strings.anniversaryKindName(self) }
}

extension Date {
    /// 요일까지 붙인 짧은 날짜 ("10월 16일 (금)" / "Fri, Oct 16") — 앱 언어를 따른다
    var appMonthDayWeekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Strings.localeIdentifier)
        formatter.setLocalizedDateFormatFromTemplate("MMMdEEE")
        return formatter.string(from: self)
    }
}

// MARK: - 알림

/// 기념일 2주 전 오전 10시: 휴가를 미리 내 두라고 (그날 휴가가 이미 있거나 원래 쉬는 날이면 뺀다).
/// 당일 오전 9시: 오늘이 그날이라고. 다가오는 한 번씩만 예약하고, 앱을 열 때마다 다시 맞춘다.
enum AnniversaryReminders {
    struct Item {
        let id: UUID
        let title: String
        let kind: AnniversaryKind
        let date: Date
        let isLunar: Bool
        let reminds: Bool

        init(_ model: FamilyAnniversary) {
            id = model.id
            title = model.displayTitle
            kind = model.kind
            date = model.date
            isLunar = model.isLunar
            reminds = model.reminds
        }
    }

    static let identifierPrefix = "family-anniversary-"
    static let leadDays = 14

    static func refresh(_ items: [Item], leaves: [LeaveRecord]) {
        #if canImport(UserNotifications)
        let calendar = Calendar.app
        let leaveRanges = leaves.map { (calendar.startOfDay(for: $0.startDate), calendar.startOfDay(for: $0.endDate)) }
        let now = Date()
        var requests: [UNNotificationRequest] = []
        for item in items where item.reminds {
            guard let day = nextDay(of: item, from: now, calendar: calendar) else { continue }
            let ordinal = calendar.component(.year, from: day) - calendar.component(.year, from: item.date)

            let hasLeave = leaveRanges.contains { day >= $0.0 && day <= $0.1 }
            if !hasLeave, !DayOffCalendar.shared.isDayOff(day),
               let before = calendar.date(byAdding: .day, value: -leadDays, to: day),
               let fire = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: before), fire > now {
                let content = UNMutableNotificationContent()
                content.title = Strings.anniversaryLeadTitle(item.title, days: leadDays)
                content.body = Strings.anniversaryLeadBody(day.appMonthDayWeekday)
                content.sound = .default
                content.userInfo = ["type": "family_anniversary"]
                requests.append(request("\(item.id)-lead", content, fire, calendar))
            }
            if let fire = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: day), fire > now {
                let content = UNMutableNotificationContent()
                content.title = Strings.anniversaryTodayTitle(item.title)
                content.body = Strings.anniversaryTodayBody(item.kind, ordinal: ordinal > 0 ? ordinal : nil)
                content.sound = .default
                content.userInfo = ["type": "family_anniversary"]
                requests.append(request("\(item.id)-day", content, fire, calendar))
            }
        }

        Task {
            let center = UNUserNotificationCenter.current()
            let stale = await center.pendingNotificationRequests()
                .map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
            center.removePendingNotificationRequests(withIdentifiers: stale)
            // 알릴 게 없으면 권한도 묻지 않는다 — 기념일을 안 쓰는 사람에게 팝업이 뜨면 안 된다
            guard !requests.isEmpty, await NotificationService.requestAuthorization() else { return }
            for r in requests {
                do { try await center.add(r) } catch {
                    logWarning("가족 기념일 알림 예약 실패: \(error.localizedDescription)", category: .app)
                }
            }
        }
        #endif
    }

    private static func nextDay(of item: Item, from now: Date, calendar: Calendar) -> Date? {
        let today = calendar.startOfDay(for: now)
        let year = calendar.component(.year, from: today)
        for y in [year, year + 1] {
            if let d = FamilyAnniversary.occurrence(of: item.date, isLunar: item.isLunar, in: y, calendar: calendar), d >= today {
                return d
            }
        }
        return nil
    }

    #if canImport(UserNotifications)
    private static func request(_ suffix: String, _ content: UNNotificationContent, _ fire: Date,
                                _ calendar: Calendar) -> UNNotificationRequest {
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
        return UNNotificationRequest(identifier: identifierPrefix + suffix, content: content,
                                     trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: false))
    }
    #endif
}

// MARK: - 목록

struct FamilyAnniversariesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FamilyAnniversary.createdAt) private var anniversaries: [FamilyAnniversary]

    @State private var showingAdd = false
    @State private var editing: FamilyAnniversary?
    @State private var deleting: FamilyAnniversary?
    @State private var showingErrorAlert = false

    private let calendar = Calendar.app

    /// 다가오는 순서로
    private var sorted: [(item: FamilyAnniversary, next: Date?)] {
        anniversaries.map { ($0, $0.nextOccurrence(calendar: calendar)) }
            .sorted { ($0.next ?? .distantFuture) < ($1.next ?? .distantFuture) }
    }

    var body: some View {
        List {
            Section {
                if anniversaries.isEmpty {
                    HStack(spacing: 10) {
                        Image(systemName: "heart.text.square")
                            .font(.title3)
                            .foregroundStyle(.pink)
                            .voDecorative()
                        Text(Strings.anniversaryEmpty)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ForEach(sorted, id: \.item.id) { entry in
                        Button { editing = entry.item } label: {
                            AnniversaryRow(item: entry.item, next: entry.next)
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button(role: .destructive) { deleting = entry.item } label: {
                                Label(Strings.commonDelete, systemImage: "trash")
                            }
                        }
                    }
                }
                Button {
                    showingAdd = true
                } label: {
                    Label(Strings.anniversaryAddTitle, systemImage: "plus.circle.fill")
                        .fontWeight(.semibold)
                        .foregroundStyle(.pink)
                }
            } footer: {
                Text(Strings.familyAnniversariesFooter)
            }
        }
        .navigationTitle(Strings.familyAnniversariesTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAdd) {
            AnniversaryEditSheet(existing: nil) { values in
                let item = FamilyAnniversary(name: values.name, relation: values.relation, kind: values.kind,
                                             date: values.date, isLunar: values.isLunar, reminds: values.reminds)
                modelContext.insert(item)
                save { modelContext.delete(item) }
            }
        }
        .sheet(item: $editing) { item in
            AnniversaryEditSheet(existing: item) { values in
                item.name = values.name
                item.relation = values.relation
                item.kind = values.kind
                item.date = calendar.startOfDay(for: values.date)
                item.isLunar = values.isLunar
                item.reminds = values.reminds
                save { modelContext.rollback() }
            } onDelete: {
                deleting = item
            }
        }
        .alert(Strings.anniversaryDeleteTitle, isPresented: Binding(
            get: { deleting != nil },
            set: { if !$0 { deleting = nil } }
        )) {
            Button(Strings.cancel, role: .cancel) { deleting = nil }
            Button(Strings.commonDelete, role: .destructive) {
                if let item = deleting {
                    modelContext.delete(item)
                    save { modelContext.rollback() }
                }
                deleting = nil
            }
        } message: {
            Text(deleting?.displayTitle ?? "")
        }
        .alert(Strings.alert, isPresented: $showingErrorAlert) {
            Button(Strings.confirm, role: .cancel) { }
        } message: {
            Text(Strings.saveFailed)
        }
    }

    private func save(undo: () -> Void) {
        do {
            try modelContext.save()
            HapticFeedback.success()
        } catch {
            undo()
            showingErrorAlert = true
            HapticFeedback.error()
        }
    }
}

private struct AnniversaryRow: View {
    let item: FamilyAnniversary
    let next: Date?

    private var daysUntil: Int? {
        guard let next else { return nil }
        let cal = Calendar.app
        return cal.dateComponents([.day], from: cal.startOfDay(for: Date()), to: next).day
    }

    private var detail: String {
        var parts: [String] = []
        if let next {
            parts.append(next.appMonthDayWeekday)
            if let n = item.ordinal(at: next) { parts.append(Strings.anniversaryOrdinal(item.kind, n)) }
        }
        if item.isLunar { parts.append(LunarDate.label(from: item.date)) }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.kind.symbol)
                .font(.title3)
                .foregroundStyle(.pink)
                .frame(width: 36)
                .voDecorative()
            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayTitle)
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let d = daysUntil {
                Text(d == 0 ? "D-DAY" : "D-\(d)")
                    .font(.headline)
                    .foregroundStyle(.pink)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

// MARK: - 추가·수정

struct AnniversaryValues {
    var name: String
    var relation: String
    var kind: AnniversaryKind
    var date: Date
    var isLunar: Bool
    var reminds: Bool
}

struct AnniversaryEditSheet: View {
    let existing: FamilyAnniversary?
    let onSave: (AnniversaryValues) -> Void
    var onDelete: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var values: AnniversaryValues

    init(existing: FamilyAnniversary?, onSave: @escaping (AnniversaryValues) -> Void, onDelete: (() -> Void)? = nil) {
        self.existing = existing
        self.onSave = onSave
        self.onDelete = onDelete
        _values = State(initialValue: AnniversaryValues(
            name: existing?.name ?? "",
            relation: existing?.relation ?? "",
            kind: existing?.kind ?? .birthday,
            date: existing?.date ?? Calendar.app.startOfDay(for: Date()),
            isLunar: existing?.isLunar ?? false,
            reminds: existing?.reminds ?? true
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(Strings.anniversaryKindSection) {
                    Picker(Strings.anniversaryKindSection, selection: $values.kind) {
                        ForEach(AnniversaryKind.allCases) { kind in
                            Label(kind.label, systemImage: kind.symbol).tag(kind)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    TextField(Strings.anniversaryRelationPlaceholder, text: $values.relation)
                        .submitLabel(.done)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Strings.anniversaryRelationPresets, id: \.self) { preset in
                                Button(preset) { values.relation = preset }
                                    .buttonStyle(.bordered)
                                    .tint(values.relation == preset ? .pink : .secondary)
                            }
                        }
                    }
                } header: {
                    Text(Strings.anniversaryRelationSection)
                }

                Section {
                    DatePicker(Strings.holidayDateSection, selection: $values.date, displayedComponents: .date)
                    Toggle(Strings.anniversaryLunarToggle, isOn: $values.isLunar)
                        .tint(.pink)
                    if values.isLunar {
                        Text(LunarDate.label(from: values.date))
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    Text(values.isLunar ? Strings.anniversaryLunarFooter : Strings.anniversaryDateFooter)
                }

                Section {
                    TextField(Strings.anniversaryNamePlaceholder, text: $values.name)
                        .submitLabel(.done)
                } header: {
                    Text(Strings.holidayNameSection)
                }

                Section {
                    Toggle(Strings.anniversaryRemindToggle, isOn: $values.reminds)
                        .tint(.pink)
                } footer: {
                    Text(Strings.anniversaryRemindFooter)
                }

                if let onDelete {
                    Section {
                        Button(Strings.commonDelete, role: .destructive) {
                            dismiss()
                            onDelete()
                        }
                    }
                }
            }
            .navigationTitle(existing == nil ? Strings.anniversaryAddTitle : Strings.anniversaryEditTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(existing == nil ? Strings.commonAdd : Strings.save) {
                        var v = values
                        v.name = v.name.trimmingCharacters(in: .whitespaces)
                        v.relation = v.relation.trimmingCharacters(in: .whitespaces)
                        onSave(v)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large])
    }
}

// MARK: - 홈 카드

/// 45일 안에 오는 가족 기념일 — 평일이면 그날 바로 휴가를 낼 수 있게
struct UpcomingAnniversariesCard: View {
    @Bindable var profile: UserProfile
    @Query private var anniversaries: [FamilyAnniversary]
    @Query(sort: \LeaveRecord.startDate) private var leaveRecords: [LeaveRecord]
    @State private var leaveDate: Date?

    static let horizonDays = 45
    private let calendar = Calendar.app

    private var upcoming: [(item: FamilyAnniversary, day: Date, daysUntil: Int)] {
        let today = calendar.startOfDay(for: Date())
        return anniversaries.compactMap { item in
            guard let day = item.nextOccurrence(calendar: calendar),
                  let d = calendar.dateComponents([.day], from: today, to: day).day,
                  d <= Self.horizonDays else { return nil }
            return (item, day, d)
        }
        .sorted { $0.daysUntil < $1.daysUntil }
        .prefix(3)
        .map { $0 }
    }

    private func hasLeave(on day: Date) -> Bool {
        leaveRecords.contains {
            $0.status != .cancelled && calendar.startOfDay(for: $0.startDate) <= day && calendar.startOfDay(for: $0.endDate) >= day
        }
    }

    var body: some View {
        if !upcoming.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(Strings.upcomingAnniversariesTitle)
                        .font(.headline)
                        .voHeader()
                    Spacer()
                    NavigationLink {
                        FamilyAnniversariesView()
                    } label: {
                        Text(Strings.showAllDates)
                            .font(.body)
                    }
                }

                ForEach(upcoming, id: \.item.id) { entry in
                    row(entry.item, day: entry.day, daysUntil: entry.daysUntil)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            .sheet(item: Binding(
                get: { leaveDate.map(IdentifiedDate.init) },
                set: { leaveDate = $0?.date }
            )) { target in
                AddLeaveView(profile: profile, initialDate: target.date)
            }
        }
    }

    private func row(_ item: FamilyAnniversary, day: Date, daysUntil: Int) -> some View {
        let ordinal = item.ordinal(at: day).map { Strings.anniversaryOrdinal(item.kind, $0) }
        let dateText = [day.appMonthDayWeekday, ordinal].compactMap { $0 }.joined(separator: " · ")
        return HStack(spacing: 12) {
            Image(systemName: item.kind.symbol)
                .foregroundStyle(.pink)
                .frame(width: 28)
                .voDecorative()
            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayTitle)
                    .font(.body.bold())
                Text(dateText)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(daysUntil == 0 ? "D-DAY" : "D-\(daysUntil)")
                    .font(.headline)
                    .foregroundStyle(.pink)
                if hasLeave(on: day) {
                    Label(Strings.anniversaryLeaveReady, systemImage: "checkmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(.green)
                } else if DayOffCalendar.shared.isDayOff(day) {
                    Text(Strings.anniversaryAlreadyOff)
                        .font(.body)
                        .foregroundStyle(.secondary)
                } else {
                    Button(Strings.anniversaryTakeLeave) { leaveDate = day }
                        .font(.body.weight(.semibold))
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                        .controlSize(.small)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct IdentifiedDate: Identifiable {
    let date: Date
    var id: Date { date }
}
