//
//  CalendarView.swift
//  Goldweek
//
//  캘린더 뷰
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LeaveRecord.startDate) private var leaveRecords: [LeaveRecord]

    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var recordToEdit: LeaveRecord?
    @State private var showingDeleteAlert = false
    @State private var recordToDelete: LeaveRecord?

    @Query private var customHolidays: [CustomHoliday]
    @Query private var allBonusLeaves: [BonusLeave]
    @AppStorage("hiddenHolidayDates") private var hiddenHolidayDatesRaw: String = ""

    /// 추천 탭과 동일한 추천 일정(공휴일 포함, 연차 필요) — 캘린더 노란색 표시 + 상세정보용
    @State private var recommendations: [LeaveRecommendation] = []

    private let holidayService = HolidayService()
    private let recommendationEngine = RecommendationEngine()
    private let calendar = Calendar.current

    private var hiddenDates: Set<String> {
        Set(hiddenHolidayDatesRaw.split(separator: ",").map(String.init).filter { !$0.isEmpty })
    }

    var holidays: [Holiday] {
        let year = calendar.component(.year, from: currentMonth)
        return holidayService.getHolidays(for: year, country: profile.country,
                                           customHolidays: customHolidays,
                                           hiddenDates: hiddenDates)
    }

    var upcomingLeaves: [LeaveRecord] {
        let today = calendar.startOfDay(for: Date())
        return leaveRecords
            .filter { $0.status != .cancelled && $0.endDate >= today }
            .sorted { $0.startDate < $1.startDate }
    }

    // MARK: 추천 일정 계산 입력값
    private var committedLeave: Double {
        leaveRecords
            .filter { ($0.status == .used || $0.status == .planned) && $0.deductsFromAnnualLeave }
            .reduce(0.0) { $0 + $1.effectiveLeaveDays }
    }
    private var activeBonusLeave: Double {
        let now = Date()
        return allBonusLeaves
            .filter { !$0.isUsed && ($0.expirationDate == nil || $0.expirationDate! > now) }
            .reduce(0) { $0 + $1.remainingDays }
    }
    private var availableLeave: Double {
        max(0, profile.totalAnnualLeave - committedLeave) + activeBonusLeave
    }

    /// MRT 여행 큐레이션 노출 조건: 한국어 + 한국 거주 + 직장인 (마이리얼트립은 한국 시장 위주)
    private var showsMRTSuggestions: Bool {
        LanguageManager.shared.currentLanguage == .korean
            && profile.country == .korea
            && profile.userType == .employee
    }

    /// 추천 일정 중 노란색으로 표시할 "연차일" — 범위 내 평일(주말·공휴일 제외)
    private var recommendedDates: Set<Date> {
        let holidaySet = Set(holidays.map { calendar.startOfDay(for: $0.date) })
        var set: Set<Date> = []
        for rec in recommendations {
            var d = calendar.startOfDay(for: rec.startDate)
            let end = calendar.startOfDay(for: rec.endDate)
            while d <= end {
                let wd = calendar.component(.weekday, from: d)
                if wd != 1 && wd != 7 && !holidaySet.contains(d) {
                    set.insert(d)
                }
                guard let next = calendar.date(byAdding: .day, value: 1, to: d) else { break }
                d = next
            }
        }
        return set
    }

    /// 이미 잡힌 휴가/휴식 날짜 (번아웃 텀 계산용)
    private var existingLeaveDates: [Date] {
        var dates: [Date] = []
        for record in leaveRecords where record.status != .cancelled {
            var d = calendar.startOfDay(for: record.startDate)
            let end = calendar.startOfDay(for: record.endDate)
            while d <= end {
                dates.append(d)
                guard let next = calendar.date(byAdding: .day, value: 1, to: d) else { break }
                d = next
            }
        }
        return dates
    }

    // MARK: 번아웃 주의 구간 (홈에서 이동) — 손으로 못 푸는 예측을 캘린더에 시각화
    private var burnoutAssessment: BurnoutAssessment {
        BurnoutEngine().assess(
            breaks: BurnoutEngine.restBlocks(from: leaveRecords),
            asOf: Date(),
            subjectiveFatigue: FatigueCheckIn.recentValue
        )
    }

    /// 캘린더에 주황 링으로 표시할 "번아웃 주의 구간" (예측일부터 1주). 없으면 빈 셋.
    private var burnoutWarningDates: Set<Date> {
        let a = burnoutAssessment
        let anchor: Date?
        if a.level == .critical {
            anchor = calendar.startOfDay(for: Date())   // 이미 위험 → 지금부터
        } else {
            anchor = a.predictedRiskDate                  // 예측 진입일부터
        }
        guard let start = anchor else { return [] }
        var set: Set<Date> = []
        for offset in 0..<7 {
            if let d = calendar.date(byAdding: .day, value: offset, to: start) {
                set.insert(calendar.startOfDay(for: d))
            }
        }
        return set
    }

    /// 주의 구간 안내 문구. 안정적이면 nil (카드 숨김).
    private var burnoutForecastText: String? {
        let a = burnoutAssessment
        if a.level == .critical { return Strings.burnoutForecastNow }
        guard let date = a.predictedRiskDate else { return nil }
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: Strings.localeIdentifier)
        fmt.setLocalizedDateFormatFromTemplate("yMMM")
        return Strings.burnoutForecast(fmt.string(from: date))
    }

    /// 추천 탭과 동일한 엔진으로 추천을 만들고, 공휴일이 포함되고 연차가 필요한 일정만 남긴다.
    private func computeRecommendations(year: Int) {
        let recs = recommendationEngine.generateRecommendations(
            for: profile,
            remainingLeave: availableLeave,
            year: year,
            country: profile.country,
            includePast: false,
            existingLeaveDates: existingLeaveDates
        )
        let holidaySet = Set(holidays.map { calendar.startOfDay(for: $0.date) })
        recommendations = recs.filter { rec in
            guard rec.requiredLeaveDays > 0 else { return false }
            // 범위 안에 공휴일이 하나라도 포함된 추천만
            var d = calendar.startOfDay(for: rec.startDate)
            let end = calendar.startOfDay(for: rec.endDate)
            while d <= end {
                if holidaySet.contains(d) { return true }
                guard let next = calendar.date(byAdding: .day, value: 1, to: d) else { break }
                d = next
            }
            return false
        }

        // 노출 측정 — 캘린더에 실제로 표시되는 (공휴일+연차) 추천만 카운트
        let avgEff = recommendations.isEmpty ? 0 :
            recommendations.map { $0.efficiency }.reduce(0, +) / Double(recommendations.count)
        AnalyticsService.logRecommendationShown(
            count: recommendations.count,
            avgEfficiency: avgEff,
            source: "calendar"
        )
    }

    var pastLeaves: [LeaveRecord] {
        let today = calendar.startOfDay(for: Date())
        return leaveRecords
            .filter { $0.status != .cancelled && $0.endDate < today }
            .sorted { $0.startDate > $1.startDate }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 월 네비게이션
                    MonthNavigator(currentMonth: $currentMonth)

                    // 번아웃 주의 구간 안내 (예측 있을 때만)
                    if let forecast = burnoutForecastText {
                        BurnoutForecastCard(text: forecast)
                    }

                    // 캘린더 그리드
                    CalendarGrid(
                        currentMonth: currentMonth,
                        selectedDate: $selectedDate,
                        holidays: holidays,
                        leaveRecords: leaveRecords,
                        recommendedDates: recommendedDates,
                        warningDates: burnoutWarningDates
                    )

                    // 범례
                    LegendView(showsRecommendation: !recommendedDates.isEmpty,
                               showsWarning: !burnoutWarningDates.isEmpty)

                    // 선택된 날짜 정보
                    SelectedDateInfo(
                        date: selectedDate,
                        holidays: holidays,
                        leaveRecords: leaveRecords,
                        recommendations: recommendations,
                        showsTravelSuggestions: showsMRTSuggestions,
                        originCountry: profile.country
                    )

                    // 나의 연차 일정
                    MyLeaveListView(
                        upcomingLeaves: upcomingLeaves,
                        pastLeaves: pastLeaves,
                        onEdit: { record in
                            recordToEdit = record
                        },
                        onDelete: { record in
                            recordToDelete = record
                            showingDeleteAlert = true
                        }
                    )
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .task(id: "\(calendar.component(.year, from: currentMonth))-\(Int(availableLeave))-\(leaveRecords.count)-\(profile.preferredDurationRaw)-\(profile.preferLongWeekend)-\(profile.preferConsecutive)-\(profile.avoidPeakSeason)") {
                computeRecommendations(year: calendar.component(.year, from: currentMonth))
            }
            .sheet(item: $recordToEdit) { record in
                EditLeaveSheet(record: record, profile: profile) {
                    recordToEdit = nil
                }
            }
            .alert(Strings.deleteLeave, isPresented: $showingDeleteAlert) {
                Button(Strings.cancel, role: .cancel) { }
                Button(Strings.delete, role: .destructive) {
                    if let record = recordToDelete {
                        deleteRecord(record)
                    }
                }
            } message: {
                Text(Strings.deleteLeaveConfirm)
            }
        }
    }

    private func deleteRecord(_ record: LeaveRecord) {
        if record.type.deductsFromAnnual {
            let days = record.type == .half ? 0.5 : (record.type == .quarter ? 0.25 : Double(record.daysCount))
            profile.usedLeave -= days
        }

        modelContext.delete(record)
        do {
            try modelContext.save()
            HapticFeedback.success()
        } catch {
            if record.type.deductsFromAnnual {
                let days = record.type == .half ? 0.5 : (record.type == .quarter ? 0.25 : Double(record.daysCount))
                profile.usedLeave += days
            }
            HapticFeedback.error()
        }
    }

}

// MARK: - 월 네비게이터
struct MonthNavigator: View {
    @Binding var currentMonth: Date

    private let calendar = Calendar.current

    var monthYearString: String {
        let year = calendar.component(.year, from: currentMonth)
        let month = calendar.component(.month, from: currentMonth)
        return Strings.monthYearFormat(year: year, month: month)
    }

    var body: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .accessibilityLabel(Text(Strings.previousMonth))

            Spacer()

            Text(monthYearString)
                .font(.title2.bold())
                .voHeader()

            Spacer()

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .accessibilityLabel(Text(Strings.nextMonth))
        }
        .padding(.horizontal)
        .accessibilityAction(named: Text(Strings.previousMonth), previousMonth)
        .accessibilityAction(named: Text(Strings.nextMonth), nextMonth)
    }

    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

// MARK: - 캘린더 그리드
struct CalendarGrid: View {
    let currentMonth: Date
    @Binding var selectedDate: Date
    let holidays: [Holiday]
    let leaveRecords: [LeaveRecord]
    var recommendedDates: Set<Date> = []
    var warningDates: Set<Date> = []

    private let calendar = Calendar.current

    var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    var body: some View {
        VStack(spacing: 8) {
            // 요일 헤더
            HStack {
                ForEach(Array(Strings.weekdays.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.caption.bold())
                        .foregroundStyle(index == 0 ? .red : (index == 6 ? .blue : .primary))
                        .frame(maxWidth: .infinity)
                }
            }

            // 날짜 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        Button {
                            selectedDate = date
                        } label: {
                            DayCell(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                isHoliday: isHoliday(date),
                                isLeave: isLeave(date),
                                barVisible: showsRestBar(date),
                                barColor: restBarColor(date),
                                leaveConnectsLeft: restConnectsLeft(date),
                                leaveConnectsRight: restConnectsRight(date),
                                isRecommended: recommendedDates.contains(calendar.startOfDay(for: date)),
                                isBurnoutWarning: warningDates.contains(calendar.startOfDay(for: date)),
                                isToday: calendar.isDateInToday(date)
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear
                            .frame(height: 40)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private func isHoliday(_ date: Date) -> Bool {
        holidays.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func isLeave(_ date: Date) -> Bool {
        let dayStart = calendar.startOfDay(for: date)
        return leaveRecords.contains { record in
            let recordStart = calendar.startOfDay(for: record.startDate)
            let recordEnd = calendar.startOfDay(for: record.endDate)
            return dayStart >= recordStart && dayStart <= recordEnd && record.status != .cancelled
        }
    }

    private func isWeekendDate(_ date: Date) -> Bool {
        let wd = calendar.component(.weekday, from: date)
        return wd == 1 || wd == 7
    }

    /// 평일 쉬는 날(휴가·공휴일) — 주말 브릿지의 앵커
    private func isRestAnchor(_ date: Date) -> Bool {
        isLeave(date) || isHoliday(date)
    }

    /// 주말 블록의 앞(금) 또는 뒤(월) 평일이 쉬는 날이면 그 주말도 선으로 이어준다.
    /// 한쪽만 휴가/공휴일이어도 적용 → 금(휴/공)요일이면 토·일, 월(휴/공)요일이면 토·일이 이어짐.
    private func isBridgedWeekend(_ date: Date) -> Bool {
        guard isWeekendDate(date) else { return false }
        var start = date
        while let p = calendar.date(byAdding: .day, value: -1, to: start), isWeekendDate(p) {
            start = p
        }
        var end = date
        while let n = calendar.date(byAdding: .day, value: 1, to: end), isWeekendDate(n) {
            end = n
        }
        let before = calendar.date(byAdding: .day, value: -1, to: start)
        let after = calendar.date(byAdding: .day, value: 1, to: end)
        return (before.map(isRestAnchor) ?? false) || (after.map(isRestAnchor) ?? false)
    }

    /// 선(막대) 후보 — 휴가·공휴일·브릿지 주말
    private func baseCovered(_ date: Date) -> Bool {
        isLeave(date) || isHoliday(date) || isBridgedWeekend(date)
    }

    /// 실제로 막대를 그릴지 — 휴가는 단독도 표시, 공휴일·주말은 인접한 쉬는 날과 이어질 때만.
    /// (외톨이 공휴일은 기존처럼 점으로 표시)
    private func showsRestBar(_ date: Date) -> Bool {
        if isLeave(date) { return true }
        guard baseCovered(date) else { return false }
        let prev = calendar.date(byAdding: .day, value: -1, to: date)
        let next = calendar.date(byAdding: .day, value: 1, to: date)
        return (prev.map(baseCovered) ?? false) || (next.map(baseCovered) ?? false)
    }

    /// 막대 색 — 휴가색/공휴일색, 브릿지 주말은 인접 앵커 기준(휴가 우선)
    private func restBarColor(_ date: Date) -> Color {
        if isLeave(date) { return AppTheme.Colors.leave }
        if isHoliday(date) { return AppTheme.Colors.holiday }
        var start = date
        while let p = calendar.date(byAdding: .day, value: -1, to: start), isWeekendDate(p) { start = p }
        var end = date
        while let n = calendar.date(byAdding: .day, value: 1, to: end), isWeekendDate(n) { end = n }
        let before = calendar.date(byAdding: .day, value: -1, to: start)
        let after = calendar.date(byAdding: .day, value: 1, to: end)
        let nearLeave = (before.map(isLeave) ?? false) || (after.map(isLeave) ?? false)
        return nearLeave ? AppTheme.Colors.leave : AppTheme.Colors.holiday
    }

    /// 전날도 막대이고 같은 주 안에서 이어지는 경우 (일요일=첫 열은 좌측 연결 없음)
    private func restConnectsLeft(_ date: Date) -> Bool {
        guard showsRestBar(date) else { return false }
        if calendar.component(.weekday, from: date) == 1 { return false }
        guard let prev = calendar.date(byAdding: .day, value: -1, to: date) else { return false }
        return showsRestBar(prev)
    }

    /// 다음날도 막대이고 같은 주 안에서 이어지는 경우 (토요일=마지막 열은 우측 연결 없음)
    private func restConnectsRight(_ date: Date) -> Bool {
        guard showsRestBar(date) else { return false }
        if calendar.component(.weekday, from: date) == 7 { return false }
        guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { return false }
        return showsRestBar(next)
    }
}

// MARK: - 날짜 셀
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isHoliday: Bool
    let isLeave: Bool
    var barVisible: Bool = false
    var barColor: Color = AppTheme.Colors.leave
    var leaveConnectsLeft: Bool = false
    var leaveConnectsRight: Bool = false
    var isRecommended: Bool = false
    var isBurnoutWarning: Bool = false
    let isToday: Bool

    private let calendar = Calendar.current

    var dayNumber: Int {
        calendar.component(.day, from: date)
    }

    var isWeekend: Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }

    var textColor: Color {
        if isSelected {
            return .white
        } else if isHoliday || calendar.component(.weekday, from: date) == 1 {
            return AppTheme.Colors.holiday
        } else if calendar.component(.weekday, from: date) == 7 {
            return AppTheme.Colors.weekend
        }
        return .primary
    }

    var body: some View {
        ZStack {
            // 휴가·공휴일: 연속된 쉬는 날(+인접 주말)은 칸 사이를 메워 하나의 선으로 표현.
            // 선택 원보다 먼저(뒤에) 깔아 원이 막대에 잘리지 않게 한다 — 막대는 원 양옆으로만 보인다.
            if barVisible {
                leaveBar
            }

            if isSelected {
                Circle()
                    .fill(AppTheme.Colors.brand)
                    .frame(width: 34, height: 34)
            } else if isToday {
                Circle()
                    .stroke(AppTheme.Colors.brand, lineWidth: 2)
                    .frame(width: 34, height: 34)
            }

            // 추천: 최적 플랜이 제안하는 연차일 — 노란 배경으로 강조
            if isRecommended && !isSelected {
                Circle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 34, height: 34)
            }

            // 번아웃 주의 구간 — 주황 점선 링으로 "구간" 강조 (배경 칠 X, 다른 표식과 겹쳐도 구분)
            if isBurnoutWarning && !isSelected {
                Circle()
                    .stroke(AppTheme.Colors.compensatory.opacity(0.7),
                            style: StrokeStyle(lineWidth: 1.5, dash: [3, 2]))
                    .frame(width: 30, height: 30)
            }

            // 외톨이 공휴일은 점으로 표시
            if isHoliday && !isSelected && !barVisible {
                Circle()
                    .fill(AppTheme.Colors.holiday)
                    .frame(width: 6, height: 6)
                    .offset(y: 14)
            }

            Text("\(dayNumber)")
                .font(.system(.subheadline, weight: (isToday || isRecommended) ? .bold : .regular))
                .foregroundStyle(textColor)
        }
        .frame(height: 40)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Strings.accessibilityDayLabel(day: dayNumber, isToday: isToday, isHoliday: isHoliday, isLeave: isLeave, isSelected: isSelected))
        .accessibilityHint(isRecommended ? Text(Strings.recommendedSchedule) : Text(""))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// 휴가·공휴일 막대 — 양 끝(고립/시작/끝)은 둥글게, 이어지는 쪽은 칸 사이 간격(8pt)을
    /// 음수 패딩으로 메워 옆 칸 막대와 하나의 선처럼 연결된다.
    private var leaveBar: some View {
        let r: CGFloat = 3
        // 막대는 선택 원 뒤에 깔리므로 항상 본래 색을 써서 양옆 칸과 하나의 선으로 이어진다.
        let fill = barColor
        return fill
            .frame(maxWidth: .infinity, minHeight: 6, maxHeight: 6)
            .clipShape(
                .rect(
                    topLeadingRadius: leaveConnectsLeft ? 0 : r,
                    bottomLeadingRadius: leaveConnectsLeft ? 0 : r,
                    bottomTrailingRadius: leaveConnectsRight ? 0 : r,
                    topTrailingRadius: leaveConnectsRight ? 0 : r
                )
            )
            .padding(.leading, leaveConnectsLeft ? -5 : 0)
            .padding(.trailing, leaveConnectsRight ? -5 : 0)
            .offset(y: 14)
    }
}

// MARK: - 범례
struct LegendView: View {
    var showsRecommendation: Bool = false
    var showsWarning: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            LegendItem(color: AppTheme.Colors.holiday, text: Strings.holiday)
            LegendItem(color: AppTheme.Colors.leave, text: Strings.annualLeave)
            LegendItem(color: AppTheme.Colors.weekend, text: Strings.weekend)
            if showsRecommendation {
                LegendItem(color: .yellow, text: Strings.tabRecommendations)
            }
            if showsWarning {
                LegendItem(color: AppTheme.Colors.compensatory, text: Strings.burnoutWarningLegend)
            }
        }
        .font(.caption)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Strings.legendAccessibility)
    }
}

// MARK: - 번아웃 주의 구간 카드
struct BurnoutForecastCard: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AppTheme.Colors.compensatory)
                .voDecorative()
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(AppTheme.Colors.compensatory.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}

struct LegendItem: View {
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 선택된 날짜 정보
struct SelectedDateInfo: View {
    let date: Date
    let holidays: [Holiday]
    let leaveRecords: [LeaveRecord]
    var recommendations: [LeaveRecommendation] = []
    /// MRT 여행 큐레이션 카드 노출 여부 (한국어 + 한국 거주 + 직장인일 때만)
    var showsTravelSuggestions: Bool = false
    var originCountry: Country = .korea

    private let calendar = Calendar.current

    var holidayOnDate: Holiday? {
        holidays.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    var leaveOnDate: LeaveRecord? {
        let dayStart = calendar.startOfDay(for: date)
        return leaveRecords.first { record in
            let recordStart = calendar.startOfDay(for: record.startDate)
            let recordEnd = calendar.startOfDay(for: record.endDate)
            return dayStart >= recordStart && dayStart <= recordEnd && record.status != .cancelled
        }
    }

    /// 선택일이 포함된 추천 일정 (있으면 상세 표시)
    var recommendationOnDate: LeaveRecommendation? {
        let dayStart = calendar.startOfDay(for: date)
        return recommendations.first { rec in
            let s = calendar.startOfDay(for: rec.startDate)
            let e = calendar.startOfDay(for: rec.endDate)
            return dayStart >= s && dayStart <= e
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(date.formatted(date: .complete, time: .omitted))
                .font(.headline)
                .voHeader()

            if let holiday = holidayOnDate {
                HStack {
                    Image(systemName: "flag.fill")
                        .foregroundStyle(.red)
                        .voDecorative()
                    Text(holiday.name)
                    if holiday.isSubstitute {
                        Text("(\(Strings.substituteHoliday))")
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
            }

            if let leave = leaveOnDate {
                HStack {
                    Image(systemName: "calendar.badge.checkmark")
                        .foregroundStyle(.green)
                        .voDecorative()
                    Text(Strings.leaveTypeName(leave.type))
                    if !leave.note.isEmpty {
                        Text("- \(leave.note)")
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
            }

            // 추천 일정 상세 (실제 등록 휴가가 없을 때) — "일정 없음" 대신 표시
            if leaveOnDate == nil, let rec = recommendationOnDate {
                recommendationDetail(rec)
            }

            if holidayOnDate == nil && leaveOnDate == nil && recommendationOnDate == nil {
                Text(Strings.noSchedule)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func recRangeText(_ rec: LeaveRecommendation) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: Strings.localeIdentifier)
        f.dateFormat = "M/d (E)"
        return "\(f.string(from: rec.startDate)) ~ \(f.string(from: rec.endDate))"
    }

    @ViewBuilder
    private func recommendationDetail(_ rec: LeaveRecommendation) -> some View {
        let dateRange = recRangeText(rec)

        VStack(alignment: .leading, spacing: 6) {
            if !rec.title.isEmpty {
                Text(rec.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.brand)
            }

            Text(dateRange)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(Strings.breakLabel(rec.totalDaysOff, leaveUsed: Int(rec.requiredLeaveDays)))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.yellow.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(Strings.recommendedSchedule), \(rec.title), \(Strings.breakLabel(rec.totalDaysOff, leaveUsed: Int(rec.requiredLeaveDays)))"))

        // 추천 일정에 맞춘 마이리얼트립 여행 큐레이션 (한국 직장인 한정)
        if showsTravelSuggestions {
            MyRealTripPromoCard(
                recommendation: rec,
                originCountry: originCountry,
                allLeaveRecords: leaveRecords
            )
        }
    }
}

// MARK: - 나의 연차 일정 리스트
struct MyLeaveListView: View {
    let upcomingLeaves: [LeaveRecord]
    let pastLeaves: [LeaveRecord]
    var onEdit: ((LeaveRecord) -> Void)?
    var onDelete: ((LeaveRecord) -> Void)?

    @State private var showPastLeaves = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(Strings.myLeaveSchedule)
                    .font(.title3.bold())
                Spacer()
                Text(Strings.itemCount(upcomingLeaves.count + pastLeaves.count))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if upcomingLeaves.isEmpty && pastLeaves.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(Strings.noLeaveRegistered)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                if onEdit != nil {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.tap")
                            .font(.caption2)
                        Text(Strings.tapToEditSwipeToDelete)
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }

                if !upcomingLeaves.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Strings.upcomingSchedule)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.Colors.brand)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.Colors.brand.opacity(0.1))
                            .clipShape(Capsule())

                        ForEach(upcomingLeaves) { leave in
                            LeaveListRowInteractive(
                                leave: leave,
                                isUpcoming: true,
                                onEdit: onEdit,
                                onDelete: onDelete
                            )
                        }
                    }
                }

                if !pastLeaves.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            withAnimation {
                                showPastLeaves.toggle()
                            }
                            HapticFeedback.selection()
                        } label: {
                            HStack {
                                Text(Strings.pastSchedule)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                Image(systemName: showPastLeaves ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .voDecorative()
                                Spacer()
                                Text(Strings.itemCount(pastLeaves.count))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("\(Strings.pastSchedule), \(Strings.itemCount(pastLeaves.count))"))
                        .accessibilityValue(Text(showPastLeaves ? Strings.a11yExpanded : Strings.a11yCollapsed))

                        if showPastLeaves {
                            ForEach(pastLeaves.prefix(10)) { leave in
                                LeaveListRowInteractive(
                                    leave: leave,
                                    isUpcoming: false,
                                    onEdit: onEdit,
                                    onDelete: onDelete
                                )
                            }

                            if pastLeaves.count > 10 {
                                Text(Strings.moreItems(pastLeaves.count - 10))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 4)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - 연차 리스트 행 (인터랙티브)
struct LeaveListRowInteractive: View {
    let leave: LeaveRecord
    let isUpcoming: Bool
    var onEdit: ((LeaveRecord) -> Void)?
    var onDelete: ((LeaveRecord) -> Void)?

    @State private var offset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .trailing) {
            // 삭제 버튼: 스와이프 시 우측에서 노출
            if onDelete != nil {
                Button {
                    if let onDelete { onDelete(leave) }
                    withAnimation { offset = 0 }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                        Text(Strings.delete)
                            .font(.caption2)
                    }
                    .foregroundStyle(.white)
                    .frame(width: 70)
                    .frame(maxHeight: .infinity)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .opacity(offset < 0 ? 1 : 0)
                .accessibilityLabel(Text(Strings.delete))
            }

            LeaveListRow(leave: leave, isUpcoming: isUpcoming)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offset = max(value.translation.width, -70.0)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3)) {
                                if value.translation.width < -30 {
                                    offset = -70.0
                                } else {
                                    offset = 0
                                }
                            }
                        }
                )
                .onTapGesture {
                    if offset != 0 {
                        withAnimation { offset = 0 }
                    } else {
                        onEdit?(leave)
                        HapticFeedback.selection()
                    }
                }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 연차 리스트 행
struct LeaveListRow: View {
    let leave: LeaveRecord
    let isUpcoming: Bool

    private let calendar = Calendar.current

    var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Strings.localeIdentifier)
        formatter.dateFormat = Strings.dateFormat(style: "monthDay")

        if calendar.isDate(leave.startDate, inSameDayAs: leave.endDate) {
            return formatter.string(from: leave.startDate)
        } else {
            let endFormatter = DateFormatter()
            endFormatter.locale = Locale(identifier: Strings.localeIdentifier)
            endFormatter.dateFormat = Strings.dateFormat(style: "monthDayOnly")
            return "\(formatter.string(from: leave.startDate)) ~ \(endFormatter.string(from: leave.endDate))"
        }
    }

    var daysCount: Int {
        let days = calendar.dateComponents([.day], from: leave.startDate, to: leave.endDate).day ?? 0
        return days + 1
    }

    var dDayText: String? {
        guard isUpcoming else { return nil }
        let today = calendar.startOfDay(for: Date())
        let startDay = calendar.startOfDay(for: leave.startDate)
        let days = calendar.dateComponents([.day], from: today, to: startDay).day ?? 0

        if days == 0 {
            return Strings.today
        } else if days > 0 {
            return "D-\(days)"
        }
        return nil
    }

    var typeColor: Color {
        leave.type.themeColor
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: leave.type.icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(typeColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(Strings.leaveTypeName(leave.type))
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    if leave.type == .annual && daysCount > 1 {
                        Text(Strings.dayUnit(daysCount))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(dateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !leave.note.isEmpty {
                    Text(leave.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            if let dDay = dDayText {
                Text(dDay)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(dDay == Strings.today ? .white : AppTheme.Colors.brand)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(dDay == Strings.today ? AppTheme.Colors.brand : AppTheme.Colors.brand.opacity(0.1))
                    .clipShape(Capsule())
            } else if !isUpcoming {
                Text(Strings.leaveStatusName(leave.status))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(isUpcoming ? 1 : 0.7)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(Strings.leaveTypeName(leave.type)), \(dateText)\(dDayText != nil ? ", \(dDayText!)" : "")")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, LeaveRecord.self, configurations: config)

    let profile = UserProfile(name: "홍길동", yearStartMonth: 1, totalAnnualLeave: 15, usedLeave: 5)
    container.mainContext.insert(profile)

    return CalendarView(profile: profile)
        .modelContainer(container)
}
