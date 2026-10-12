//
//  PartTimeDays.swift
//  Goldweek
//
//  파트타임 쉬는 요일 — 매주 쉬는 요일을 정하고(설정), 동료와 바꾼 주에는 그 주만 다른 날로 옮긴다(달력).
//  (네덜란드 사용자 피드백: "금요일마다 쉬는데 가끔 다른 날과 바꾼다")
//
//  판정은 HolidayService 가 맡는다 — 쉬는 요일은 주말처럼(weekendDays), 옮겨서 일하는 날은
//  보충 근무일처럼(isMakeupWorkday), 옮겨 와서 쉬는 날은 쉬는 주말처럼(isRestWeekend) 다룬다.
//

import SwiftUI

/// 설정 — 매주 쉬는 요일 고르기 (여러 개 가능)
struct PartTimeDaysPicker: View {
    let country: Country
    @AppStorage("partTimeDaysOff") private var raw = ""
    @AppStorage("firstWeekday") private var firstWeekdayRaw = 0

    private var selected: Set<Int> {
        Set(raw.split(separator: ",").compactMap { Int($0) })
    }

    /// 주말은 이미 쉬는 날이라 고를 수 없게 뺀다
    private var weekdays: [Int] {
        let first = HolidayService.firstWeekday(for: country, override: firstWeekdayRaw)
        let weekend = HolidayService.parseWeekend(HolidayService.weekendOverrideRaw) ?? country.standardWeekendDays
        return (0..<7).map { (first - 1 + $0) % 7 + 1 }.filter { !weekend.contains($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.partTimeDaysSetting)
            HStack(spacing: 6) {
                ForEach(weekdays, id: \.self) { day in
                    let isOn = selected.contains(day)
                    Button {
                        toggle(day)
                    } label: {
                        Text(Strings.weekdays[day - 1])
                            .font(.body.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .background(isOn ? AppTheme.Colors.brand : Color(.systemGray5))
                            .foregroundStyle(isOn ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isOn ? .isSelected : [])
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func toggle(_ day: Int) {
        HapticFeedback.selection()
        var set = selected
        if set.contains(day) { set.remove(day) } else { set.insert(day) }
        raw = set.sorted().map(String.init).joined(separator: ",")
        UsageReportingService.record(event: "part_time_days:\(set.count)")
    }
}

/// 달력 날짜 상세 — 고정 쉬는 날이면 "이번 주만 옮기기", 옮긴 날이면 "원래대로"
struct PartTimeDayRow: View {
    let date: Date
    let country: Country
    /// 바뀌면 다시 그리도록 지켜본다 (값은 HolidayService 가 읽는다)
    @AppStorage("partTimeDaysOff") private var daysRaw = ""
    @AppStorage("partTimeSwaps") private var swapsRaw = ""
    @AppStorage("firstWeekday") private var firstWeekdayRaw = 0
    @State private var showingMove = false
    private let calendar = Calendar.current

    private var key: String { HolidayService.partTimeKey(date) }
    private var isRegularOff: Bool {
        HolidayService.partTimeDaysOff.contains(calendar.component(.weekday, from: date))
    }

    var body: some View {
        let _ = (daysRaw, swapsRaw)
        if HolidayService.partTimeSwapOffKeys.contains(key) {
            row(icon: "arrow.uturn.left.circle.fill", text: Strings.partTimeMovedOff, undo: true)
        } else if HolidayService.partTimeSwapWorkKeys.contains(key) {
            row(icon: "briefcase.fill", text: Strings.partTimeMovedWork, undo: true)
        } else if isRegularOff {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "moon.zzz.fill").foregroundStyle(.indigo).voDecorative()
                    Text(Strings.partTimeRegularDayOff)
                }
                .accessibilityElement(children: .combine)
                Button {
                    showingMove = true
                } label: {
                    Label(Strings.partTimeMoveThisWeek, systemImage: "arrow.left.arrow.right")
                        .font(.body.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .tint(.indigo)
            }
            .sheet(isPresented: $showingMove) {
                PartTimeMoveSheet(from: date, country: country, firstWeekday: HolidayService.firstWeekday(for: country, override: firstWeekdayRaw))
                    .presentationDetents([.medium])
            }
        }
    }

    private func row(icon: String, text: String, undo: Bool) -> some View {
        HStack {
            Image(systemName: icon).foregroundStyle(.indigo).voDecorative()
            Text(text)
            Spacer()
            Button(Strings.partTimeUndoMove) {
                HapticFeedback.selection()
                HolidayService.removePartTimeSwap(involving: date)
                swapsRaw = HolidayService.partTimeSwapsRaw
            }
            .buttonStyle(.bordered)
        }
    }
}

/// 같은 주의 다른 근무일 중에서 대신 쉴 날을 고른다
private struct PartTimeMoveSheet: View {
    let from: Date
    let country: Country
    let firstWeekday: Int
    @Environment(\.dismiss) private var dismiss
    @AppStorage("partTimeSwaps") private var swapsRaw = ""
    private let calendar = Calendar.current

    /// 그 주(달력 첫 요일 기준)에서 지금 일하는 날
    private var candidates: [Date] {
        let d = calendar.startOfDay(for: from)
        let back = (calendar.component(.weekday, from: d) - firstWeekday + 7) % 7
        guard let weekStart = calendar.date(byAdding: .day, value: -back, to: d) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
            .filter { !calendar.isDate($0, inSameDayAs: d) && !DayOffCalendar.shared.isDayOff($0) }
    }

    var body: some View {
        NavigationStack {
            List(candidates, id: \.self) { day in
                Button {
                    HapticFeedback.success()
                    HolidayService.addPartTimeSwap(from: from, to: day)
                    swapsRaw = HolidayService.partTimeSwapsRaw
                    UsageReportingService.record(event: "part_time_swap")
                    dismiss()
                } label: {
                    HStack {
                        Text(Strings.weekdays[calendar.component(.weekday, from: day) - 1])
                            .fontWeight(.semibold)
                            .frame(minWidth: 44, alignment: .leading)
                        Text(day.appMonthDay)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(Strings.partTimeMoveTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
            }
        }
    }
}
