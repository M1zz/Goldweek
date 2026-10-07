//
//  CalendarOverview.swift
//  Goldweek
//
//  여러 달 보기 — 2개월·분기·반기·1년을 작은 달력으로 한눈에 (이탈리아 사용자 피드백).
//  달은 1월부터 끊는다 (분기 = 1~3월·4~6월…). 달을 누르면 그 달의 한 달 보기로 들어간다.
//

import SwiftUI

/// 달력 보기 범위 (개월 수)
enum CalendarSpan: Int, CaseIterable, Identifiable {
    case one = 1, two = 2, three = 3, six = 6, twelve = 12
    var id: Int { rawValue }

    /// 그 날이 속한 구간의 첫 달 (1월 기준으로 끊는다)
    func periodStart(containing date: Date, calendar: Calendar = .current) -> Date {
        let c = calendar.dateComponents([.year, .month], from: date)
        let month = ((c.month ?? 1) - 1) / rawValue * rawValue + 1
        return calendar.date(from: DateComponents(year: c.year, month: month, day: 1)) ?? date
    }
}

/// 구간 이동 + 제목 ("2026년 1월 – 6월")
struct PeriodNavigator: View {
    @Binding var currentMonth: Date
    let span: CalendarSpan
    private let calendar = Calendar.current

    private var start: Date { span.periodStart(containing: currentMonth) }
    private var end: Date { calendar.date(byAdding: .month, value: span.rawValue - 1, to: start) ?? start }

    private var title: String {
        let s = calendar.dateComponents([.year, .month], from: start)
        let e = calendar.dateComponents([.year, .month], from: end)
        if span == .twelve, s.month == 1 { return "\(s.year ?? 0)" }
        return "\(Strings.monthYearFormat(year: s.year ?? 0, month: s.month ?? 1)) – \(Strings.monthYearFormat(year: e.year ?? 0, month: e.month ?? 1))"
    }

    var body: some View {
        HStack {
            Button { move(-1) } label: {
                Image(systemName: "chevron.left").font(.title2).foregroundStyle(.blue)
            }
            .accessibilityLabel(Text(Strings.previousMonth))
            Spacer()
            Text(title)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .voHeader()
            Spacer()
            Button { move(1) } label: {
                Image(systemName: "chevron.right").font(.title2).foregroundStyle(.blue)
            }
            .accessibilityLabel(Text(Strings.nextMonth))
        }
        .padding(.horizontal)
        .accessibilityAction(named: Text(Strings.previousMonth)) { move(-1) }
        .accessibilityAction(named: Text(Strings.nextMonth)) { move(1) }
    }

    private func move(_ step: Int) {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: step * span.rawValue, to: start) ?? currentMonth
        }
    }
}

/// 여러 달을 작은 달력으로 늘어놓는다
struct CalendarOverviewGrid: View {
    let currentMonth: Date
    let span: CalendarSpan
    let country: Country
    let leaveRecords: [LeaveRecord]
    /// 달을 눌렀을 때 — 그 달 한 달 보기로
    let onSelectMonth: (Date) -> Void

    @Environment(\.horizontalSizeClass) private var sizeClass
    private let calendar = Calendar.current

    private var months: [Date] {
        let start = span.periodStart(containing: currentMonth)
        return (0..<span.rawValue).compactMap { calendar.date(byAdding: .month, value: $0, to: start) }
    }

    private var columnCount: Int {
        if sizeClass == .regular { return span.rawValue >= 6 ? 4 : min(span.rawValue, 3) }
        return span == .two ? 1 : 2
    }

    var body: some View {
        // 연도가 걸치는 구간(예: 12월~1월)도 있으니 해마다 쉬는 날을 한 번씩만 구한다
        let years = Set(months.map { calendar.component(.year, from: $0) })
        let holidayKeys: Set<String> = Set(years.flatMap { y in
            DayOffCalendar.shared.holidays(for: y, country: country).filter { !$0.isBreak }.map { Self.key($0.date) }
        })
        VStack(spacing: 8) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: columnCount),
                      spacing: 12) {
                ForEach(months, id: \.self) { month in
                    Button { onSelectMonth(month) } label: {
                        MiniMonthView(month: month, country: country, holidayKeys: holidayKeys,
                                      leaveRecords: leaveRecords, large: span == .two)
                    }
                    .buttonStyle(.plain)
                }
            }
            Text(Strings.calendarOverviewHint)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private static let keyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func key(_ date: Date) -> String { keyFormatter.string(from: date) }
}

/// 작은 한 달 — 휴가는 종류 색 동그라미, 공휴일은 빨간 글자, 주말은 흐린 글자
struct MiniMonthView: View {
    let month: Date
    let country: Country
    let holidayKeys: Set<String>
    let leaveRecords: [LeaveRecord]
    /// 2개월 보기처럼 칸이 넓을 때 글자를 키운다
    var large = false

    @AppStorage("firstWeekday") private var firstWeekdayRaw = 0
    private let calendar = Calendar.current

    private var firstWeekday: Int { HolidayService.firstWeekday(for: country, override: firstWeekdayRaw) }

    private var cells: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let first = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else { return [] }
        let blanks = (calendar.component(.weekday, from: first) - firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: blanks)
        for d in range { days.append(calendar.date(byAdding: .day, value: d - 1, to: first)) }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    private func leave(on date: Date) -> LeaveRecord? {
        let d = calendar.startOfDay(for: date)
        return leaveRecords.first {
            $0.status != .cancelled && d >= calendar.startOfDay(for: $0.startDate) && d <= calendar.startOfDay(for: $0.endDate)
        }
    }

    private var monthName: String {
        let c = calendar.dateComponents([.year, .month], from: month)
        return Strings.monthYearFormat(year: c.year ?? 0, month: c.month ?? 1)
    }

    /// VoiceOver — "2026년 8월, 휴가 5일, 공휴일 1일"
    private var accessibilityText: String {
        let days = cells.compactMap { $0 }
        let leaveCount = days.filter { leave(on: $0) != nil }.count
        let holidayCount = days.filter { holidayKeys.contains(CalendarOverviewGrid.key($0)) }.count
        var parts = [monthName]
        if leaveCount > 0 { parts.append("\(Strings.annualLeave) \(Strings.dayUnit(leaveCount))") }
        if holidayCount > 0 { parts.append("\(Strings.holiday) \(Strings.dayUnit(holidayCount))") }
        return parts.joined(separator: ", ")
    }

    var body: some View {
        let font: Font = large ? .body : .caption2
        let cellHeight: CGFloat = large ? 30 : 18
        VStack(alignment: .leading, spacing: 4) {
            Text(monthName)
                .font(large ? .headline : .subheadline.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 7), spacing: 2) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, date in
                    if let date {
                        let record = leave(on: date)
                        let isHoliday = holidayKeys.contains(CalendarOverviewGrid.key(date))
                        let isWeekend = HolidayService.isRestWeekend(date, country: country, calendar: calendar)
                        Text("\(calendar.component(.day, from: date))")
                            .font(font.monospacedDigit())
                            .fontWeight(record != nil || isHoliday ? .bold : .regular)
                            .foregroundStyle(record != nil ? .white : isHoliday ? AppTheme.Colors.holiday : isWeekend ? .secondary : .primary)
                            .frame(maxWidth: .infinity, minHeight: cellHeight)
                            .background {
                                if let record {
                                    Circle().fill(record.displayColor)
                                } else if calendar.isDateInToday(date) {
                                    Circle().strokeBorder(AppTheme.Colors.brand, lineWidth: 1.5)
                                }
                            }
                    } else {
                        Color.clear.frame(height: cellHeight)
                    }
                }
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityText))
        .accessibilityAddTraits(.isButton)
    }
}
