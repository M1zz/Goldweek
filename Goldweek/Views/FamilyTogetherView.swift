//
//  FamilyTogetherView.swift
//  Goldweek
//
//  프로 칸: 함께 쉬기 (2.4.2 전에는 패밀리였다).
//  공유받은 가족 일정(주말·각자 나라의 공휴일·휴가)과 내 일정을 겹쳐
//  다 같이 쉬는 날, 한 사람만 연차를 내면 다 같이 쉬는 날, 가족 기념일에 누가 쉬는지를 찾는다.
//  무엇을 왜 프로에 두는지는 docs/MONETIZATION.md.
//

import SwiftUI
import SwiftData

// MARK: - 계산

/// 가족 한 사람의 쉬는 날 판정
struct TogetherMember {
    let name: String
    let isMe: Bool
    let isOff: (Date) -> Bool
}

enum FamilyTogether {
    /// 다 같이 쉬는 연휴 (3일 이상 이어지는 날)
    struct Break: Identifiable, Equatable {
        let start: Date
        let end: Date
        let days: Int
        var id: Date { start }
    }

    /// 한 사람만 연차를 내면 다 같이 쉬는 연휴
    struct OneAway: Identifiable, Equatable {
        let member: String
        let isMe: Bool
        let start: Date
        let end: Date
        let days: Int
        /// 그 사람이 내야 하는 날
        let leaveDates: [Date]
        var id: String { "\(member)|\(start.timeIntervalSince1970)" }
    }

    /// 기념일 하루에 누가 쉬고 누가 일하는지
    struct AnniversaryDay: Identifiable {
        let title: String
        let date: Date
        let sharedBy: String?
        let working: [String]
        let meWorking: Bool
        var id: String { "\(title)|\(date.timeIntervalSince1970)" }
    }

    static func days(from start: Date, count: Int, calendar: Calendar = .app) -> [Date] {
        let first = calendar.startOfDay(for: start)
        return (0..<count).compactMap { calendar.date(byAdding: .day, value: $0, to: first) }
    }

    /// 모두 쉬는 날이 3일 이상 이어지는 구간
    static func togetherBreaks(members: [TogetherMember], days: [Date], minDays: Int = 3) -> [Break] {
        let allOff = days.map { d in members.allSatisfy { $0.isOff(d) } }
        return runs(of: allOff).compactMap { range in
            range.count >= minDays ? Break(start: days[range.lowerBound], end: days[range.upperBound - 1], days: range.count) : nil
        }
    }

    /// 다른 가족이 모두 쉬는 구간 안에서 그 사람만 일하는 날이 1~2일이면, 그날 연차를 내면 다 같이 쉰다.
    static func oneLeaveAway(members: [TogetherMember], days: [Date], maxLeave: Int = 2, minDays: Int = 3) -> [OneAway] {
        guard members.count >= 2 else { return [] }
        var result: [OneAway] = []
        for (index, member) in members.enumerated() {
            let others = members.enumerated().filter { $0.offset != index }.map(\.element)
            let othersOff = days.map { d in others.allSatisfy { $0.isOff(d) } }
            for range in runs(of: othersOff) where range.count >= minDays {
                let window = Array(days[range])
                let leave = window.filter { !member.isOff($0) }
                guard (1...maxLeave).contains(leave.count), window.count >= leave.count + 2 else { continue }
                result.append(OneAway(member: member.name, isMe: member.isMe, start: window[0], end: window[window.count - 1],
                                      days: window.count, leaveDates: leave))
            }
        }
        // 연차 하루에 오래 쉬는 것부터, 같으면 가까운 날부터
        return result.sorted {
            let a = Double($0.days) / Double($0.leaveDates.count), b = Double($1.days) / Double($1.leaveDates.count)
            return a != b ? a > b : $0.start < $1.start
        }
    }

    private static func runs(of flags: [Bool]) -> [Range<Int>] {
        var result: [Range<Int>] = []
        var start: Int?
        for (i, flag) in flags.enumerated() {
            if flag, start == nil { start = i }
            if !flag, let s = start { result.append(s..<i); start = nil }
        }
        if let s = start { result.append(s..<flags.count) }
        return result
    }

    // MARK: 쉬는 날 판정 만들기

    /// 반차·반반차·시간 단위는 쉬는 날로 치지 않는다
    static func fullDayLeaveKeys(_ leaves: [(start: Date, end: Date, typeRaw: String, lengthRaw: String?, statusRaw: String)],
                                 calendar: Calendar = .app) -> Set<String> {
        var keys = Set<String>()
        for leave in leaves {
            guard LeaveStatus(rawValue: leave.statusRaw) != .cancelled else { continue }
            if let type = LeaveType(rawValue: leave.typeRaw), type == .half || type == .quarter { continue }
            if let raw = leave.lengthRaw, let length = LeaveLength(rawValue: raw), length != .full { continue }
            var d = calendar.startOfDay(for: leave.start)
            let end = calendar.startOfDay(for: leave.end)
            while d <= end {
                keys.insert(key(d, calendar))
                guard let next = calendar.date(byAdding: .day, value: 1, to: d) else { break }
                d = next
            }
        }
        return keys
    }

    static func key(_ date: Date, _ calendar: Calendar = .app) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    /// 공유받은 가족 — 그 사람 나라의 기본 주말·공휴일과 공유된 휴가
    static func member(for schedule: SharedSchedule, years: ClosedRange<Int>, calendar: Calendar = .app) -> TogetherMember {
        let country = schedule.countryRaw.flatMap(Country.init(rawValue:)) ?? DayOffCalendar.shared.country
        let weekend = country.standardWeekendDays
        let service = HolidayService()
        var holidayKeys = Set<String>()
        for year in years {
            for h in service.getHolidays(for: year, country: country) { holidayKeys.insert(key(h.date, calendar)) }
        }
        let leaveKeys = fullDayLeaveKeys(schedule.leaves.map { ($0.startDate, $0.endDate, $0.typeRaw, nil, $0.statusRaw) }, calendar: calendar)
        return TogetherMember(name: schedule.ownerName, isMe: false) { d in
            weekend.contains(calendar.component(.weekday, from: d))
                || holidayKeys.contains(key(d, calendar)) || leaveKeys.contains(key(d, calendar))
        }
    }

    /// 나 — 내 달력(공휴일·내 공휴일·방학·교대)과 내 휴가
    static func me(leaves: [LeaveRecord], calendar: Calendar = .app) -> TogetherMember {
        let leaveKeys = fullDayLeaveKeys(leaves.map { ($0.startDate, $0.endDate, $0.typeRaw, $0.lengthRaw, $0.statusRaw) }, calendar: calendar)
        let dayOff = DayOffCalendar.shared
        return TogetherMember(name: Strings.togetherMe, isMe: true) { d in
            dayOff.isDayOff(d) || leaveKeys.contains(key(d, calendar))
        }
    }
}

// MARK: - 화면

struct FamilyTogetherView: View {
    @Bindable var profile: UserProfile
    @Query(sort: \LeaveRecord.startDate) private var leaveRecords: [LeaveRecord]
    @Query private var anniversaries: [FamilyAnniversary]

    @State private var breaks: [FamilyTogether.Break] = []
    @State private var oneAway: [FamilyTogether.OneAway] = []
    @State private var anniversaryDays: [FamilyTogether.AnniversaryDay] = []
    @State private var leaveTarget: TogetherLeaveDate?

    private var service: ShareSyncService { .shared }
    private let horizonDays = 365

    var body: some View {
        List {
            Section {
                if breaks.isEmpty {
                    Text(Strings.togetherNothingFound)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(breaks.prefix(8)) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(rangeText(item.start, item.end))
                                    .font(.body.weight(.semibold))
                                Text(Strings.togetherEveryoneOff)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(Strings.togetherDaysInRow(item.days))
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.green)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            } header: {
                Text(Strings.togetherAllOffSection)
            }

            Section {
                if oneAway.isEmpty {
                    Text(Strings.togetherNothingFound)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(oneAway.prefix(10)) { item in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(rangeText(item.start, item.end))
                                    .font(.body.weight(.semibold))
                                Text(Strings.togetherLeaveNeeded(item.member, item.leaveDates.count, item.days))
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                            if item.isMe, let first = item.leaveDates.first {
                                Button(Strings.anniversaryTakeLeave) { leaveTarget = TogetherLeaveDate(date: first) }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                            }
                        }
                    }
                }
            } header: {
                Text(Strings.togetherOneLeaveSection)
            }

            Section {
                if anniversaryDays.isEmpty {
                    Text(Strings.anniversaryEmpty)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(anniversaryDays) { day in
                        HStack(spacing: 12) {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.pink)
                                .voDecorative()
                            VStack(alignment: .leading, spacing: 2) {
                                Text(day.title)
                                    .font(.body.weight(.semibold))
                                Text(day.date.appMonthDayWeekday)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                if let by = day.sharedBy {
                                    Text(Strings.togetherSharedBy(by))
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                Text(day.working.isEmpty ? Strings.togetherEveryoneOff : Strings.togetherWorking(day.working.joined(separator: ", ")))
                                    .font(.body)
                                    .foregroundStyle(day.working.isEmpty ? .green : .orange)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                            if day.meWorking {
                                Button(Strings.anniversaryTakeLeave) { leaveTarget = TogetherLeaveDate(date: day.date) }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                            }
                        }
                        .accessibilityElement(children: .contain)
                    }
                }
            } header: {
                Text(Strings.familyAnniversariesTitle)
            } footer: {
                Text(Strings.togetherFooter)
            }
        }
        .navigationTitle(Strings.togetherTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: inputKey) { compute() }
        .refreshable {
            await service.refreshSharedSchedules()
            compute()
        }
        .sheet(item: $leaveTarget) { target in
            AddLeaveView(profile: profile, initialDate: target.date)
        }
    }

    /// 다시 계산할 때 — 공유 일정·내 휴가·기념일·내 달력이 바뀌면
    private var inputKey: String {
        let shared = service.sharedSchedules.map { "\($0.id):\($0.leaves.count):\($0.anniversaries.count):\($0.countryRaw ?? "")" }.joined(separator: ",")
        let mine = leaveRecords.map { "\($0.startDate.timeIntervalSince1970)\($0.statusRaw)" }.joined(separator: ",")
        let anniv = anniversaries.map { "\($0.id)\($0.date.timeIntervalSince1970)" }.joined(separator: ",")
        return [shared, mine, anniv, DayOffCalendar.shared.fingerprint].joined(separator: "#")
    }

    private func compute() {
        let calendar = Calendar.app
        let today = calendar.startOfDay(for: Date())
        let days = FamilyTogether.days(from: today, count: horizonDays)
        let year = calendar.component(.year, from: today)
        let me = FamilyTogether.me(leaves: leaveRecords)
        let family = service.sharedSchedules.map { FamilyTogether.member(for: $0, years: year...year + 1) }
        let members = [me] + family

        breaks = FamilyTogether.togetherBreaks(members: members, days: days)
            // 그냥 주말 이틀은 빼고, 다 같이 사흘 이상
            .filter { $0.days >= 3 }
        oneAway = FamilyTogether.oneLeaveAway(members: members, days: days)

        // 기념일 — 내 것과 가족이 공유한 것, 앞으로 120일
        var items: [(title: String, date: Date, isLunar: Bool, by: String?)] =
            anniversaries.map { ($0.displayTitle, $0.date, $0.isLunar, nil) }
        for schedule in service.sharedSchedules {
            items += schedule.anniversaries.map { ($0.title, $0.date, $0.isLunar, schedule.ownerName) }
        }
        guard let limit = calendar.date(byAdding: .day, value: 120, to: today) else { return }
        var seen = Set<String>()
        anniversaryDays = items.compactMap { item -> FamilyTogether.AnniversaryDay? in
            let next = (year...year + 1)
                .compactMap { FamilyAnniversary.occurrence(of: item.date, isLunar: item.isLunar, in: $0) }
                .first { $0 >= today }
            guard let date = next, date <= limit,
                  seen.insert("\(item.title)|\(FamilyTogether.key(date))").inserted else { return nil }
            return FamilyTogether.AnniversaryDay(
                title: item.title, date: date, sharedBy: item.by,
                working: members.filter { !$0.isOff(date) }.map(\.name),
                meWorking: !me.isOff(date))
        }
        .sorted { $0.date < $1.date }
    }

    private func rangeText(_ start: Date, _ end: Date) -> String {
        start == end ? start.appMonthDayWeekday : "\(start.appMonthDayWeekday) – \(end.appMonthDayWeekday)"
    }
}

private struct TogetherLeaveDate: Identifiable {
    let date: Date
    var id: Date { date }
}

// MARK: - 가족 탭 입구

/// 가족 탭 맨 위. 프로면 함께 쉬기로, 아니면 프로 페이월로
struct FamilyTogetherEntry: View {
    @Bindable var profile: UserProfile
    @State private var showingPaywall = false

    private var unlocked: Bool { ProManager.shared.hasProTier }

    var body: some View {
        Section {
            if unlocked {
                NavigationLink {
                    FamilyTogetherView(profile: profile)
                } label: {
                    label
                }
            } else {
                Button { showingPaywall = true } label: { label }
                    .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(initialProductID: ProManager.yearlyProductID)
        }
    }

    private var label: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.2.fill")
                .foregroundStyle(.pink)
                .frame(width: 28)
                .voDecorative()
            VStack(alignment: .leading, spacing: 2) {
                Text(Strings.togetherTitle)
                    .fontWeight(.semibold)
                Text(unlocked ? Strings.togetherSubtitle : Strings.togetherLocked)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            if !unlocked {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.yellow)
                    .voDecorative()
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
