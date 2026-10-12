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

// MARK: - 근무 형태 고르기 (온보딩·설정)

/// 근무 형태 세 가지를 카드로 — 고른 형태에 맞는 기능만 앱에 보인다
struct WorkPatternChooser: View {
    @AppStorage(HolidayService.workPatternKey) private var raw = ""
    var onChange: () -> Void = {}

    private var selected: WorkPattern { WorkPattern(rawValue: raw) ?? HolidayService.workPattern }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(WorkPattern.allCases) { pattern in
                let isOn = selected == pattern
                Button {
                    HapticFeedback.selection()
                    raw = pattern.rawValue
                    UsageReportingService.record(event: "work_pattern:\(pattern.rawValue)")
                    onChange()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: pattern.icon)
                            .font(.title3)
                            .frame(width: 28)
                            .foregroundStyle(isOn ? .white : AppTheme.Colors.brand)
                            .voDecorative()
                        VStack(alignment: .leading, spacing: 2) {
                            Text(Strings.workPatternName(pattern))
                                .font(.body.weight(.semibold))
                            Text(Strings.workPatternDesc(pattern))
                                .font(.body)
                                .foregroundStyle(isOn ? .white.opacity(0.9) : .secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                        if isOn {
                            Image(systemName: "checkmark.circle.fill").voDecorative()
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(isOn ? AppTheme.Colors.brand : Color(.systemGray6))
                    .foregroundStyle(isOn ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
    }
}

// MARK: - 교대 근무 (피드백: "쉬는 날이 주마다 바뀌어 주말이 고정돼 있지 않다")

/// 한 주씩 넘기며 날짜마다 근무·휴무를 누른다 — 매주 근무표를 옮겨 적기 쉽게
struct ShiftScheduleView: View {
    let country: Country
    var onChange: () -> Void = {}

    @AppStorage("shiftDaysOff") private var offRaw = ""
    @AppStorage("shiftWorkDays") private var workRaw = ""
    @AppStorage("firstWeekday") private var firstWeekdayRaw = 0
    @State private var weekOffset = 0
    private let calendar = Calendar.current

    private var weekStart: Date {
        let today = calendar.startOfDay(for: Date())
        let first = HolidayService.firstWeekday(for: country, override: firstWeekdayRaw)
        let back = (calendar.component(.weekday, from: today) - first + 7) % 7
        let thisWeek = calendar.date(byAdding: .day, value: -back, to: today) ?? today
        return calendar.date(byAdding: .day, value: weekOffset * 7, to: thisWeek) ?? thisWeek
    }

    private var days: [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    var body: some View {
        let _ = (offRaw, workRaw)
        List {
            Section {
                HStack {
                    Button {
                        withAnimation { weekOffset -= 1 }
                    } label: {
                        Image(systemName: "chevron.left").font(.body.weight(.semibold))
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(Text(Strings.shiftPrevWeek))
                    Spacer()
                    VStack(spacing: 2) {
                        Text("\(weekStart.appMonthDay) – \((days.last ?? weekStart).appMonthDay)")
                            .font(.headline)
                            .monospacedDigit()
                        if weekOffset != 0 {
                            Button(Strings.shiftThisWeek) { withAnimation { weekOffset = 0 } }
                                .font(.body)
                                .buttonStyle(.borderless)
                        }
                    }
                    Spacer()
                    Button {
                        withAnimation { weekOffset += 1 }
                    } label: {
                        Image(systemName: "chevron.right").font(.body.weight(.semibold))
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(Text(Strings.shiftNextWeek))
                }

                ForEach(days, id: \.self) { day in
                    dayRow(day)
                }
            } footer: {
                Text(Strings.shiftScheduleFooter)
            }
        }
        .navigationTitle(Strings.shiftScheduleTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func dayRow(_ day: Date) -> some View {
        let isOff = DayOffCalendar.shared.isDayOff(day)
        let changed = HolidayService.shiftMark(on: day) != nil
        let holiday = DayOffCalendar.shared.holidays(for: calendar.component(.year, from: day), country: country)
            .first { calendar.isDate($0.date, inSameDayAs: day) }?.name
        return Button {
            HapticFeedback.selection()
            HolidayService.setShiftMark(!isOff, on: day, defaultIsOff: DayOffCalendar.shared.isDayOffIgnoringShift(day))
            offRaw = HolidayService.shiftDaysOffRaw
            workRaw = HolidayService.shiftWorkDaysRaw
            UsageReportingService.record(event: "shift_day_toggled")
            onChange()
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(Strings.weekdays[calendar.component(.weekday, from: day) - 1])
                            .font(.body.weight(.semibold))
                        Text(day.appMonthDay)
                            .foregroundStyle(.secondary)
                        if calendar.isDateInToday(day) {
                            Circle().fill(AppTheme.Colors.brand).frame(width: 6, height: 6).voDecorative()
                        }
                    }
                    if let holiday {
                        Text(holiday)
                            .font(.body)
                            .foregroundStyle(AppTheme.Colors.holiday)
                    }
                }
                Spacer()
                Text(isOff ? Strings.shiftOff : Strings.shiftWork)
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(isOff ? Color.indigo : Color(.systemGray5))
                    .foregroundStyle(isOff ? .white : .primary)
                    .clipShape(Capsule())
                    .overlay(alignment: .topTrailing) {
                        if changed {
                            Circle().fill(.orange).frame(width: 8, height: 8).offset(x: 2, y: -2).voDecorative()
                        }
                    }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("\(Strings.weekdays[calendar.component(.weekday, from: day) - 1]) \(day.appMonthDay), \(isOff ? Strings.shiftOff : Strings.shiftWork)"))
    }
}

/// 달력 날짜 상세 — 교대 근무면 이 날을 휴무/근무로 바꾸거나 되돌린다
struct ShiftDayRow: View {
    let date: Date
    @AppStorage(HolidayService.workPatternKey) private var patternRaw = ""
    @AppStorage("shiftDaysOff") private var offRaw = ""
    @AppStorage("shiftWorkDays") private var workRaw = ""

    var body: some View {
        let _ = (patternRaw, offRaw, workRaw)
        if HolidayService.workPattern == .shift {
            let mark = HolidayService.shiftMark(on: date)
            let isOff = DayOffCalendar.shared.isDayOff(date)
            HStack {
                if let mark {
                    Image(systemName: mark ? "moon.zzz.fill" : "briefcase.fill").foregroundStyle(.indigo).voDecorative()
                    Text(mark ? Strings.shiftMarkedOff : Strings.shiftMarkedWork)
                    Spacer()
                    Button(Strings.shiftUndo) { set(nil) }
                        .buttonStyle(.bordered)
                } else {
                    Button {
                        set(!isOff)
                    } label: {
                        Label(isOff ? Strings.shiftMarkWork : Strings.shiftMarkOff,
                              systemImage: isOff ? "briefcase" : "moon.zzz")
                            .font(.body.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .tint(.indigo)
                }
            }
        }
    }

    private func set(_ off: Bool?) {
        HapticFeedback.selection()
        HolidayService.setShiftMark(off, on: date, defaultIsOff: DayOffCalendar.shared.isDayOffIgnoringShift(date))
        offRaw = HolidayService.shiftDaysOffRaw
        workRaw = HolidayService.shiftWorkDaysRaw
        UsageReportingService.record(event: "shift_day_toggled")
    }
}
