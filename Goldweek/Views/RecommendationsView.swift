//
//  RecommendationsView.swift
//  Goldweek
//
//  휴가 추천 화면
//

import SwiftUI
import SwiftData

struct RecommendationsView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var modelContext
    @Query private var allLeaveRecords: [LeaveRecord]
    @Query private var allBonusLeaves: [BonusLeave]

    @State private var recommendations: [LeaveRecommendation] = []
    @State private var selectedYear: Int
    @State private var isLoading = true
    @State private var addedRecommendations: Set<UUID> = []
    @State private var showingAddError = false
    /// 한 해의 황금연휴 전체 보기 (지난 휴가 포함). 사용자 요청 — 회고용/계획용 양쪽 활용.
    @State private var showAllYear = false

    private let recommendationEngine = RecommendationEngine()

    init(profile: UserProfile) {
        self.profile = profile
        _selectedYear = State(initialValue: Calendar.current.component(.year, from: Date()))
    }

    /// Records 기반 사용 확정 연차 (현황·설정과 동일한 공식)
    private var committedLeave: Double {
        let active = allLeaveRecords.filter { $0.status == .used || $0.status == .planned }
        let deducting = active.filter { $0.deductsFromAnnualLeave }
        return deducting.reduce(0.0) { $0 + $1.effectiveLeaveDays }
    }

    private var activeBonusLeave: Double {
        let now = Date()
        return allBonusLeaves
            .filter { !$0.isUsed && ($0.expirationDate == nil || $0.expirationDate! > now) }
            .reduce(0) { $0 + $1.remainingDays }
    }

    /// 사용 가능 연차 = 설정·현황과 동일한 계산
    private var availableLeave: Double {
        max(0, profile.totalAnnualLeave - committedLeave) + activeBonusLeave
    }

    private var freeHolidays: [LeaveRecommendation] {
        recommendations.filter { $0.requiredLeaveDays == 0 }
    }

    private var actionableRecommendations: [LeaveRecommendation] {
        recommendations.filter { $0.requiredLeaveDays > 0 }
    }

    /// MRT 여행 큐레이션 노출 조건: 한국어 + 한국 거주 + 직장인 (마이리얼트립은 한국 시장 위주)
    private var showsMRTSuggestions: Bool {
        LanguageManager.shared.currentLanguage == .korean
            && profile.country == .korea
            && profile.userType == .employee
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 연도 선택
                    YearPicker(selectedYear: $selectedYear)
                        .onChange(of: selectedYear) { _, _ in
                            loadRecommendations()
                        }

                    // 한 해 전체 보기 토글 — 지난 황금연휴까지 회고/계획 양면 활용
                    Toggle(isOn: $showAllYear) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar.circle")
                                .foregroundStyle(.blue)
                            Text(Strings.showAllYearToggle)
                                .font(.subheadline)
                        }
                    }
                    .toggleStyle(.switch)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onChange(of: showAllYear) { _, _ in
                        loadRecommendations()
                    }

                    // 남은 연차 정보 — records 기반으로 계산
                    RemainingLeaveInfo(available: availableLeave, total: profile.totalAnnualLeave, committed: committedLeave, hasBonus: activeBonusLeave > 0)

                    // 최적 연간 휴가 플래너 (Pro 기능 — 알고리즘 기반)
                    OptimalLeavePlannerCard(
                        profile: profile,
                        year: selectedYear,
                        availableLeaveDays: Int(availableLeave),
                        existingLeaveRecords: allLeaveRecords
                    )

                    // 추천 일정 미리보기 달력
                    if !recommendations.isEmpty && !isLoading {
                        RecommendationCalendarPreview(
                            recommendations: recommendations,
                            selectedYear: selectedYear
                        )
                    }

                    if isLoading {
                        ProgressView(Strings.analyzingSchedule)
                            .padding(.top, 40)
                    } else if actionableRecommendations.isEmpty && freeHolidays.isEmpty {
                        EmptyRecommendationView()
                    } else {
                        // 연차 없이 쉬는 날 (정보성, 액션 없음)
                        if !freeHolidays.isEmpty {
                            UpcomingHolidaysSection(holidays: freeHolidays)
                        }

                        // 연차를 써야 만들 수 있는 추천 + 일정별 MRT 여행 큐레이션
                        if !actionableRecommendations.isEmpty {
                            RecommendationList(
                                recommendations: actionableRecommendations,
                                addedRecommendations: $addedRecommendations,
                                onAdd: addLeave,
                                showsTravelSuggestions: showsMRTSuggestions,
                                originCountry: profile.country,
                                allLeaveRecords: allLeaveRecords
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(Strings.navTitleRecommendations)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadRecommendations()
            }
            .alert(Strings.alert, isPresented: $showingAddError) {
                Button(Strings.confirm, role: .cancel) { }
            } message: {
                Text(Strings.saveFailed)
            }
        }
    }

    private func loadRecommendations() {
        isLoading = true
        let remaining = availableLeave

        // 추천 로직 업데이트 후 사용자 기기에 캐시가 남아있을 수 있어 강제 무효화.
        // 캐시는 1시간 TTL이지만 동일 입력이면 옛 결과를 그대로 반환할 수 있음.
        recommendationEngine.invalidateCache()

        let includePast = showAllYear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            recommendations = recommendationEngine.generateRecommendations(
                for: profile,
                remainingLeave: remaining,
                year: selectedYear,
                country: profile.country,
                includePast: includePast
            )
            isLoading = false
        }
    }

    private func addLeave(from recommendation: LeaveRecommendation) {
        let record = LeaveRecord(
            startDate: recommendation.startDate,
            endDate: recommendation.endDate,
            type: .annual,
            status: .planned,
            note: recommendation.title,
            isRecommended: true
        )

        modelContext.insert(record)
        addedRecommendations.insert(recommendation.id)

        do {
            try modelContext.save()
            AnalyticsService.logRecommendationAdded(
                days: recommendation.totalDaysOff,
                efficiency: recommendation.efficiency
            )
            HapticFeedback.success()
        } catch {
            AnalyticsService.recordError(error, context: ["op": "recommendation_add"])
            addedRecommendations.remove(recommendation.id)
            modelContext.delete(record)
            HapticFeedback.error()
            showingAddError = true
        }
    }
}

// MARK: - 연도 선택기
struct YearPicker: View {
    @Binding var selectedYear: Int
    
    @State private var showingPaywall = false
    private let proManager = ProManager.shared
    private let currentYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        HStack {
            Button(action: {
                if proManager.isPro || selectedYear > currentYear {
                    selectedYear -= 1
                } else {
                    showingPaywall = true
                }
            }) {
                Image(systemName: proManager.isPro ? "chevron.left.circle.fill" : "lock.circle.fill")
                    .font(.title2)
                    .foregroundStyle(proManager.isPro ? .blue : .gray)
            }
            .disabled(selectedYear <= currentYear && proManager.isPro)
            .accessibilityLabel(Text(Strings.previousYear))

            Spacer()

            VStack(spacing: 4) {
                Text(Strings.yearRecommendation(year: selectedYear))
                    .font(.title2.bold())

                if !proManager.isPro && selectedYear != currentYear {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                            .voDecorative()
                        Text(Strings.currentYearOnly)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .voHeader()

            Spacer()

            Button(action: {
                if proManager.isPro {
                    selectedYear += 1
                } else {
                    showingPaywall = true
                }
            }) {
                Image(systemName: proManager.isPro ? "chevron.right.circle.fill" : "lock.circle.fill")
                    .font(.title2)
                    .foregroundStyle(proManager.isPro ? .blue : .gray)
            }
            .disabled(selectedYear >= currentYear + 1 && proManager.isPro)
            .accessibilityLabel(Text(Strings.nextYear))
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}

// MARK: - 남은 연차 정보
struct RemainingLeaveInfo: View {
    let available: Double
    let total: Double
    let committed: Double
    var hasBonus: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Strings.availableLeave)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(String(format: "%.1f", available))")
                        .font(.system(.largeTitle, weight: .bold))
                        .foregroundStyle(hasBonus ? AppTheme.Colors.bonus : .green)
                    Text(Strings.dayUnitSuffix)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            CircularProgressView(
                progress: total > 0 ? committed / total : 0,
                lineWidth: 8
            )
            .frame(width: 60, height: 60)
            .voDecorative()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5)
        .voCard(VoiceOverLabel.leaveBalance(total: total, used: committed, remaining: available))
    }
}

// MARK: - 원형 프로그레스
struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(progress, 1))
                .stroke(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.caption.bold())
        }
    }
}

// MARK: - 추천 리스트
struct RecommendationList: View {
    let recommendations: [LeaveRecommendation]
    @Binding var addedRecommendations: Set<UUID>
    let onAdd: (LeaveRecommendation) -> Void
    /// MRT 여행 큐레이션 카드 노출 여부 (한국어 + 한국 거주 + 직장인일 때만)
    let showsTravelSuggestions: Bool
    let originCountry: Country
    let allLeaveRecords: [LeaveRecord]

    @State private var showingPaywall = false
    private let proManager = ProManager.shared
    private let freeAddLimit = 3

    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(Array(recommendations.enumerated()), id: \.element.id) { index, recommendation in
                let requiresPro = !proManager.isPro && index >= freeAddLimit
                VStack(spacing: 12) {
                    DetailedRecommendationCard(
                        recommendation: recommendation,
                        isAdded: addedRecommendations.contains(recommendation.id),
                        requiresPro: requiresPro,
                        onAdd: {
                            if requiresPro {
                                showingPaywall = true
                            } else {
                                onAdd(recommendation)
                            }
                        }
                    )

                    // 추천 일정마다 여행 큐레이션 카드 부착 (한국 직장인 한정).
                    // LazyVStack 안이므로 스크롤로 화면에 들어와야만 .task가 발화 → API 호출이 점진적으로 일어남.
                    if showsTravelSuggestions {
                        MyRealTripPromoCard(
                            recommendation: recommendation,
                            originCountry: originCountry,
                            allLeaveRecords: allLeaveRecords
                        )
                    }
                }
            }

            // Pro 힌트: 무료 사용자이고 추천이 freeAddLimit 초과일 때만
            if !proManager.isPro && recommendations.count > freeAddLimit {
                Text(Strings.proUnlockHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}

// MARK: - 연차 없이 쉬는 날 섹션
struct UpcomingHolidaysSection: View {
    let holidays: [LeaveRecommendation]

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M/d"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "gift.fill")
                            .foregroundStyle(.orange)
                        Text(Strings.upcomingHolidaysSection)
                            .font(.headline)
                    }
                    Text(Strings.upcomingHolidaysSectionSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(holidays) { holiday in
                        HolidayInfoCard(holiday: holiday, formatter: dateFormatter)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.bottom, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct HolidayInfoCard: View {
    let holiday: LeaveRecommendation
    let formatter: DateFormatter

    private let calendar = Calendar.current
    private let holidayService = HolidayService()

    /// 카드의 시작일~종료일 사이의 모든 날짜
    var datesInRange: [Date] {
        var dates: [Date] = []
        var current = holiday.startDate
        while current <= holiday.endDate {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return dates
    }

    /// 해당 연도의 공휴일 (요일 동그라미 색상 판정용)
    var publicHolidays: [Holiday] {
        let year = calendar.component(.year, from: holiday.startDate)
        return holidayService.getHolidays(for: year)
    }

    /// 추천 카드와 동일한 색상 규칙: 주말(토/일) 우선 파랑 → 평일 공휴일은 빨강 → 평일
    func dayType(for date: Date) -> DayType {
        let weekday = calendar.component(.weekday, from: date)
        if weekday == 1 { return .sunday }
        if weekday == 7 { return .saturday }
        let isHoliday = publicHolidays.contains { calendar.isDate($0.date, inSameDayAs: date) }
        if isHoliday { return .holiday }
        return .workday
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(holiday.title)
                .font(.subheadline.bold())
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(formatter.string(from: holiday.startDate)) – \(formatter.string(from: holiday.endDate))")
                .font(.caption)
                .foregroundStyle(.secondary)

            // 요일 동그라미 미리보기 — 추천 카드와 동일한 시각 언어
            HStack(spacing: 3) {
                ForEach(Array(datesInRange.prefix(6).enumerated()), id: \.offset) { _, date in
                    DatePreviewCell(date: date, dayType: dayType(for: date))
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "sun.max.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                Text(Strings.daysOff(holiday.totalDaysOff))
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
            }

            Text(Strings.noLeaveRequired)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.orange.opacity(0.12))
                .foregroundStyle(.orange)
                .clipShape(Capsule())
        }
        .padding(12)
        .frame(width: 200)
        .background(Color.orange.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - 상세 추천 카드
struct DetailedRecommendationCard: View {
    let recommendation: LeaveRecommendation
    let isAdded: Bool
    var requiresPro: Bool = false
    let onAdd: () -> Void

    private var dateRangeText: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: Strings.localeIdentifier)
        f.dateStyle = .medium
        return "\(f.string(from: recommendation.startDate)) - \(f.string(from: recommendation.endDate))"
    }

    private var summaryLabel: String {
        VoiceOverLabel.recommendation(
            dateRange: dateRangeText,
            totalDays: recommendation.totalDaysOff,
            leavesNeeded: Int(recommendation.requiredLeaveDays),
            score: nil
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🎯 \(recommendation.title)")
                    .font(.headline)
                    .accessibilityLabel(Text(recommendation.title))
                    .voHeader()

                Spacer()

                if requiresPro {
                    HStack(spacing: 3) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                            .voDecorative()
                        Text("Pro")
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.12))
                    .clipShape(Capsule())
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(Text("Pro"))
                } else {
                    VStack(alignment: .trailing) {
                        Text(Strings.efficiency)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(recommendation.efficiencyStars)
                            .font(.caption)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(Text("\(Strings.efficiency) \(recommendation.efficiencyStars)"))
                }
            }

            Divider()

            // 일정 미리보기 (시각화)
            RecommendationDatePreview(
                startDate: recommendation.startDate,
                endDate: recommendation.endDate
            )

            // 요약 정보
            HStack(spacing: 0) {
                Spacer()
                Label(Strings.leaveRequired(Int(recommendation.requiredLeaveDays)), systemImage: "briefcase.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
                Spacer()
                Text("→")
                    .foregroundStyle(.secondary)
                Spacer()
                Label(Strings.daysOff(recommendation.totalDaysOff), systemImage: "sun.max.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(recommendation.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            if !recommendation.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recommendation.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Button(action: onAdd) {
                HStack {
                    Spacer()
                    if requiresPro {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                            .voDecorative()
                        Text(Strings.addWithPro)
                            .fontWeight(.semibold)
                    } else {
                        Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                            .voDecorative()
                        Text(isAdded ? Strings.addedToScheduleAction : Strings.addToScheduleAction)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(requiresPro ? Color.purple.opacity(0.85) : (isAdded ? Color.green : Color.blue))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(isAdded && !requiresPro)
            .accessibilityLabel(Text(requiresPro ? Strings.addWithPro : (isAdded ? Strings.addedToScheduleAction : Strings.addToScheduleAction)))
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("\(recommendation.title), \(summaryLabel)"))
    }
}

// MARK: - 추천 날짜 미리보기 (요일별 시각화)
struct RecommendationDatePreview: View {
    let startDate: Date
    let endDate: Date

    private let calendar = Calendar.current
    private let holidayService = HolidayService()

    var extendedDateRange: [Date] {
        var dates: [Date] = []

        if let dayBefore = calendar.date(byAdding: .day, value: -1, to: startDate) {
            dates.append(dayBefore)
        }

        var current = startDate
        while current <= endDate {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        if let dayAfter = calendar.date(byAdding: .day, value: 1, to: endDate) {
            dates.append(dayAfter)
        }

        return dates
    }

    var holidays: [Holiday] {
        let year = calendar.component(.year, from: startDate)
        return holidayService.getHolidays(for: year)
    }

    var body: some View {
        VStack(spacing: 8) {
            let startMonth = calendar.component(.month, from: startDate)
            let endMonth = calendar.component(.month, from: endDate)
            HStack {
                if startMonth == endMonth {
                    Text(Strings.monthShort(startMonth))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(Strings.monthShort(startMonth)) → \(Strings.monthShort(endMonth))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(extendedDateRange.enumerated()), id: \.offset) { _, date in
                        DatePreviewCell(
                            date: date,
                            dayType: getDayType(for: date)
                        )
                    }
                }
            }

            HStack(spacing: 12) {
                MiniLegend(color: .gray.opacity(0.5), text: Strings.workday)
                MiniLegend(color: .green, text: Strings.annualLeave)
                MiniLegend(color: .red.opacity(0.7), text: Strings.holiday)
                MiniLegend(color: .blue.opacity(0.7), text: Strings.weekend)
            }
            .font(.caption2)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func getDayType(for date: Date) -> DayType {
        let weekday = calendar.component(.weekday, from: date)
        let isHoliday = holidays.contains { calendar.isDate($0.date, inSameDayAs: date) }
        let isInLeaveRange = date >= startDate && date <= endDate

        // 사용자 요청: 토/일은 공휴일과 겹쳐도 항상 파랑 (주말 우선).
        // 공휴일은 평일에 떨어진 경우에만 빨강으로 표시.
        if weekday == 1 {
            return .sunday
        } else if weekday == 7 {
            return .saturday
        } else if isHoliday {
            return .holiday
        } else if isInLeaveRange {
            return .leave
        } else {
            return .workday
        }
    }
}

// MARK: - 날짜 타입
enum DayType {
    case leave
    case saturday
    case sunday
    case holiday
    case workday

    var color: Color {
        switch self {
        case .leave: return .green
        case .saturday, .sunday: return .blue.opacity(0.7)  // 범례와 일치: 주말 = 파랑
        case .holiday: return .red.opacity(0.7)
        case .workday: return .gray.opacity(0.5)
        }
    }

    var label: String {
        Strings.dayTypeLabel(self)
    }
}

// MARK: - 날짜 미리보기 셀
struct DatePreviewCell: View {
    let date: Date
    let dayType: DayType

    private let calendar = Calendar.current

    var dayNumber: Int {
        calendar.component(.day, from: date)
    }

    var weekdayName: String {
        let weekday = calendar.component(.weekday, from: date)
        return Strings.weekdays[weekday - 1]
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(weekdayName)
                .font(.system(.caption2, weight: .medium))
                .foregroundStyle(dayType == .holiday ? .red : (dayType == .saturday || dayType == .sunday ? .blue : .secondary))

            Text("\(dayNumber)")
                .font(.system(.footnote, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(dayType.color)
                .clipShape(Circle())
        }
    }
}

// MARK: - 미니 범례
struct MiniLegend: View {
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 3) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(text)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 빈 추천 뷰
struct EmptyRecommendationView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(.largeTitle))
                .foregroundStyle(.secondary)
                .voDecorative()

            Text(Strings.noRecommendations)
                .font(.headline)

            Text(Strings.noRecommendationsHint)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}

// MARK: - 추천 일정 달력 미리보기
struct RecommendationCalendarPreview: View {
    let recommendations: [LeaveRecommendation]
    let selectedYear: Int

    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(.blue)
                Text(Strings.previewCalendar)
                    .font(.headline)
                Spacer()
                Text(Strings.itemCountUnit(recommendations.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 6), spacing: 8) {
                ForEach(0..<12, id: \.self) { monthIndex in
                    MonthPreviewCell(
                        month: monthIndex + 1,
                        monthName: Strings.monthShort(monthIndex + 1),
                        recommendations: recommendationsForMonth(monthIndex + 1),
                        year: selectedYear
                    )
                }
            }

            HStack(spacing: 16) {
                LegendDot(color: .orange, text: Strings.goldenWeekLegend)
                LegendDot(color: .green, text: Strings.bridgeDayLegend)
                LegendDot(color: .blue, text: Strings.consecutiveLeaveLegend)
            }
            .font(.caption2)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private func recommendationsForMonth(_ month: Int) -> [LeaveRecommendation] {
        recommendations.filter {
            calendar.component(.month, from: $0.startDate) == month
        }
    }
}

// MARK: - 월별 미리보기 셀
struct MonthPreviewCell: View {
    let month: Int
    let monthName: String
    let recommendations: [LeaveRecommendation]
    let year: Int

    private let calendar = Calendar.current

    var isPastMonth: Bool {
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        if year < currentYear { return true }
        if year == currentYear && month < currentMonth { return true }
        return false
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(monthName)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(isPastMonth ? .secondary : .primary)

            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isPastMonth ? Color(.systemGray5) : Color(.systemGray6))
                    .frame(height: 32)

                if !recommendations.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(Array(recommendations.prefix(3).enumerated()), id: \.offset) { _, rec in
                            Circle()
                                .fill(colorForRecommendation(rec))
                                .frame(width: 6, height: 6)
                        }
                        if recommendations.count > 3 {
                            Text("+")
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if !recommendations.isEmpty && !isPastMonth {
                Text(Strings.itemCountUnit(recommendations.count))
                    .font(.system(size: 9))
                    .foregroundStyle(.blue)
            } else {
                Text(" ")
                    .font(.system(size: 9))
            }
        }
        .opacity(isPastMonth ? 0.5 : 1)
    }

    private func colorForRecommendation(_ rec: LeaveRecommendation) -> Color {
        if rec.tags.contains(Strings.goldenWeek) || rec.title.contains(Strings.goldenWeek) || rec.title.contains("Golden") || rec.title.contains("황금") {
            return .orange
        } else if rec.tags.contains(Strings.bridgeDay) || rec.title.contains(Strings.bridgeDay) || rec.title.contains("Bridge") || rec.title.contains("징검다리") {
            return .green
        } else {
            return .blue
        }
    }
}

// MARK: - 범례 점
struct LegendDot: View {
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

// MARK: - 여행 큐레이션 데이터 모델

struct TravelSuggestion: Identifiable {
    let id = UUID()
    let cityKey: String           // 다국어 키 (예: "osaka")
    let countryFlag: String       // 🇯🇵
    let themeKey: String          // 다국어 키 (예: "family")
    let priceTierKey: String      // "budget" | "mid" | "premium"
    let minDays: Int              // 추천 최소 연휴 일수
    let maxDays: Int              // 추천 최대 연휴 일수
    let seasons: Set<TravelSeason> // 비어있으면 사계절
    let originCountries: Set<Country>  // 어느 출발 국가에서 인기인지
    let accentColor: (light: Color, dark: Color)  // 카드 그라디언트
    let reasonKeys: [String]      // 후보 reason 키들 (컨텍스트에 따라 1개 선택)
    let offSeasonMonths: Set<Int> // 비수기 월 (할인 시즌 강조)
}

enum TravelSeason: Hashable {
    case spring, summer, fall, winter
    static func from(month: Int) -> TravelSeason {
        switch month {
        case 3...5: return .spring
        case 6...8: return .summer
        case 9...11: return .fall
        default: return .winter
        }
    }
}

// MARK: - 여행 큐레이션 엔진

enum TravelSuggestionEngine {
    static let catalog: [TravelSuggestion] = [
        TravelSuggestion(cityKey: "osaka", countryFlag: "🇯🇵", themeKey: "family", priceTierKey: "mid",
                         minDays: 3, maxDays: 7, seasons: [.spring, .fall],
                         originCountries: [.korea, .china],
                         accentColor: (Color(red: 0.95, green: 0.45, blue: 0.45), Color(red: 0.85, green: 0.30, blue: 0.30)),
                         reasonKeys: ["familyTime", "foodieParadise", "bestSeason"],
                         offSeasonMonths: [6, 7]),
        TravelSuggestion(cityKey: "fukuoka", countryFlag: "🇯🇵", themeKey: "foodie", priceTierKey: "budget",
                         minDays: 2, maxDays: 5, seasons: [],
                         originCountries: [.korea, .china],
                         accentColor: (Color(red: 0.95, green: 0.60, blue: 0.30), Color(red: 0.80, green: 0.45, blue: 0.20)),
                         reasonKeys: ["shortNearby", "weekendEscape", "foodieParadise"],
                         offSeasonMonths: [1, 2, 6]),
        TravelSuggestion(cityKey: "tokyo", countryFlag: "🇯🇵", themeKey: "shopping", priceTierKey: "premium",
                         minDays: 4, maxDays: 8, seasons: [.spring, .fall, .winter],
                         originCountries: [.korea, .china, .usa],
                         accentColor: (Color(red: 0.40, green: 0.55, blue: 0.85), Color(red: 0.25, green: 0.40, blue: 0.70)),
                         reasonKeys: ["bestSeason", "cultureExplore"],
                         offSeasonMonths: [6, 7]),
        TravelSuggestion(cityKey: "sapporo", countryFlag: "🇯🇵", themeKey: "nature", priceTierKey: "mid",
                         minDays: 3, maxDays: 6, seasons: [.winter],
                         originCountries: [.korea, .china],
                         accentColor: (Color(red: 0.50, green: 0.70, blue: 0.85), Color(red: 0.35, green: 0.55, blue: 0.75)),
                         reasonKeys: ["bestSeason", "burnoutRecovery"],
                         offSeasonMonths: [5, 6, 9, 10]),
        TravelSuggestion(cityKey: "okinawa", countryFlag: "🇯🇵", themeKey: "rest", priceTierKey: "mid",
                         minDays: 4, maxDays: 7, seasons: [.spring, .summer, .fall],
                         originCountries: [.korea, .japan, .china],
                         accentColor: (Color(red: 0.30, green: 0.75, blue: 0.75), Color(red: 0.20, green: 0.60, blue: 0.65)),
                         reasonKeys: ["longResort", "familyTime", "burnoutRecovery"],
                         offSeasonMonths: [11, 12, 1, 2]),
        TravelSuggestion(cityKey: "kyoto", countryFlag: "🇯🇵", themeKey: "culture", priceTierKey: "mid",
                         minDays: 3, maxDays: 6, seasons: [.spring, .fall],
                         originCountries: [.korea, .china, .usa],
                         accentColor: (Color(red: 0.85, green: 0.50, blue: 0.65), Color(red: 0.70, green: 0.35, blue: 0.50)),
                         reasonKeys: ["cultureExplore", "bestSeason", "couplesTrip"],
                         offSeasonMonths: [6, 7, 8]),
        TravelSuggestion(cityKey: "danang", countryFlag: "🇻🇳", themeKey: "rest", priceTierKey: "budget",
                         minDays: 4, maxDays: 7, seasons: [.spring, .fall, .winter],
                         originCountries: [.korea, .japan],
                         accentColor: (Color(red: 0.20, green: 0.70, blue: 0.55), Color(red: 0.10, green: 0.55, blue: 0.45)),
                         reasonKeys: ["burnoutRecovery", "longResort", "offSeasonDeal", "couplesTrip"],
                         offSeasonMonths: [5, 6, 7, 8, 9]),
        TravelSuggestion(cityKey: "bangkok", countryFlag: "🇹🇭", themeKey: "foodie", priceTierKey: "budget",
                         minDays: 4, maxDays: 8, seasons: [.fall, .winter],
                         originCountries: [.korea, .japan, .china],
                         accentColor: (Color(red: 0.95, green: 0.55, blue: 0.20), Color(red: 0.80, green: 0.40, blue: 0.10)),
                         reasonKeys: ["foodieParadise", "offSeasonDeal", "longResort"],
                         offSeasonMonths: [4, 5, 6, 7, 8, 9]),
        TravelSuggestion(cityKey: "taipei", countryFlag: "🇹🇼", themeKey: "foodie", priceTierKey: "budget",
                         minDays: 3, maxDays: 5, seasons: [.spring, .fall],
                         originCountries: [.korea, .japan],
                         accentColor: (Color(red: 0.55, green: 0.75, blue: 0.45), Color(red: 0.40, green: 0.60, blue: 0.30)),
                         reasonKeys: ["shortNearby", "foodieParadise", "weekendEscape"],
                         offSeasonMonths: [6, 7, 8]),
        TravelSuggestion(cityKey: "bali", countryFlag: "🇮🇩", themeKey: "rest", priceTierKey: "mid",
                         minDays: 5, maxDays: 9, seasons: [.spring, .summer],
                         originCountries: [.korea, .japan, .china, .usa],
                         accentColor: (Color(red: 0.25, green: 0.60, blue: 0.75), Color(red: 0.15, green: 0.45, blue: 0.60)),
                         reasonKeys: ["longResort", "couplesTrip", "burnoutRecovery"],
                         offSeasonMonths: [11, 12, 1, 2]),
        TravelSuggestion(cityKey: "jeju", countryFlag: "🇰🇷", themeKey: "nature", priceTierKey: "mid",
                         minDays: 2, maxDays: 5, seasons: [],
                         originCountries: [.korea, .japan, .china],
                         accentColor: (Color(red: 0.40, green: 0.75, blue: 0.55), Color(red: 0.25, green: 0.60, blue: 0.40)),
                         reasonKeys: ["shortNearby", "familyTime", "weekendEscape"],
                         offSeasonMonths: [12, 1, 2]),
        TravelSuggestion(cityKey: "busan", countryFlag: "🇰🇷", themeKey: "foodie", priceTierKey: "budget",
                         minDays: 1, maxDays: 3, seasons: [],
                         originCountries: [.korea, .japan, .china],
                         accentColor: (Color(red: 0.30, green: 0.60, blue: 0.85), Color(red: 0.20, green: 0.45, blue: 0.70)),
                         reasonKeys: ["weekendEscape", "shortNearby", "foodieParadise"],
                         offSeasonMonths: [12, 1, 2]),
        TravelSuggestion(cityKey: "guam", countryFlag: "🇬🇺", themeKey: "rest", priceTierKey: "premium",
                         minDays: 4, maxDays: 7, seasons: [.spring, .summer, .winter],
                         originCountries: [.korea, .japan],
                         accentColor: (Color(red: 0.30, green: 0.65, blue: 0.85), Color(red: 0.15, green: 0.50, blue: 0.70)),
                         reasonKeys: ["longResort", "familyTime", "couplesTrip"],
                         offSeasonMonths: [9, 10, 11]),
        TravelSuggestion(cityKey: "phuket", countryFlag: "🇹🇭", themeKey: "rest", priceTierKey: "mid",
                         minDays: 5, maxDays: 8, seasons: [.fall, .winter],
                         originCountries: [.korea, .japan, .china],
                         accentColor: (Color(red: 0.95, green: 0.65, blue: 0.40), Color(red: 0.80, green: 0.50, blue: 0.25)),
                         reasonKeys: ["longResort", "couplesTrip", "offSeasonDeal"],
                         offSeasonMonths: [5, 6, 7, 8, 9, 10]),
    ]

    /// (suggestion, 컨텍스트별 선택된 reason 키) 튜플로 반환
    static func suggest(
        for recommendation: LeaveRecommendation,
        originCountry: Country,
        daysSinceLastLeave: Int? = nil,  // 마지막 휴가 후 경과 일수 (번아웃 컨텍스트)
        limit: Int = 6
    ) -> [(TravelSuggestion, String)] {
        let month = Calendar.current.component(.month, from: recommendation.startDate)
        let season = TravelSeason.from(month: month)
        let days = recommendation.totalDaysOff
        let isOffSeason: (TravelSuggestion) -> Bool = { $0.offSeasonMonths.contains(month) }
        let isBurnout = (daysSinceLastLeave ?? 0) >= 60

        let scored = catalog.map { suggestion -> (TravelSuggestion, Int) in
            var score = 0
            if suggestion.originCountries.contains(originCountry) { score += 5 }
            if suggestion.seasons.isEmpty { score += 1 }
            else if suggestion.seasons.contains(season) { score += 4 }
            if days >= suggestion.minDays && days <= suggestion.maxDays { score += 4 }
            else if abs(days - suggestion.minDays) <= 1 || abs(days - suggestion.maxDays) <= 1 { score += 1 }
            if suggestion.originCountries.contains(originCountry) && days >= 5 { score += 1 }
            // 비수기 보너스 (저렴 강조 가치 ↑)
            if isOffSeason(suggestion) { score += 2 }
            // 번아웃 컨텍스트: 휴양 도시 가산
            if isBurnout && suggestion.themeKey == "rest" { score += 3 }
            return (suggestion, score)
        }

        let filtered = scored.filter { $0.1 > 0 }.sorted { $0.1 > $1.1 }
        return Array(filtered.prefix(limit).map { entry -> (TravelSuggestion, String) in
            let reason = pickReason(
                for: entry.0,
                season: season,
                seasonMatched: entry.0.seasons.contains(season),
                days: days,
                isOffSeason: isOffSeason(entry.0),
                isBurnout: isBurnout,
                isNearby: entry.0.originCountries.contains(originCountry)
            )
            return (entry.0, reason)
        })
    }

    /// 컨텍스트 기반 reason 자동 선택 (우선순위: 번아웃 > 비수기 > 시즌 > 길이 > 카탈로그 첫 번째)
    private static func pickReason(
        for suggestion: TravelSuggestion,
        season: TravelSeason,
        seasonMatched: Bool,
        days: Int,
        isOffSeason: Bool,
        isBurnout: Bool,
        isNearby: Bool
    ) -> String {
        // 1. 번아웃 + 휴양 → 회복
        if isBurnout && suggestion.reasonKeys.contains("burnoutRecovery") {
            return "burnoutRecovery"
        }
        // 2. 비수기 → 저렴 강조
        if isOffSeason && suggestion.reasonKeys.contains("offSeasonDeal") {
            return "offSeasonDeal"
        }
        // 3. 시즌 매칭 → 베스트 시즌
        if seasonMatched && suggestion.reasonKeys.contains("bestSeason") {
            return "bestSeason"
        }
        // 4. 짧은 연휴(1-3일) → 가깝고 부담 없이 / 주말+1
        if days <= 3 {
            if isNearby && suggestion.reasonKeys.contains("weekendEscape") { return "weekendEscape" }
            if suggestion.reasonKeys.contains("shortNearby") { return "shortNearby" }
        }
        // 5. 긴 연휴(7일+) → 긴 휴가
        if days >= 7 && suggestion.reasonKeys.contains("longResort") {
            return "longResort"
        }
        // 6. 카탈로그 첫 번째 (테마 기반)
        return suggestion.reasonKeys.first ?? ""
    }
}

// MARK: - 마이리얼트립 결과 캐시
//
// LazyVStack 안에 MRT 카드가 N개 있을 때, 사용자가 스크롤 아웃 → 다시 스크롤 인 하면
// 카드가 새로 생성되어 @State가 리셋되고 .task가 다시 발화 → API 재호출 (이전 호출은 "취소됨")
// 이게 무한히 반복되며 메인 스레드 부담 + 네트워크 낭비 + 스크롤 버벅임 유발.
//
// 결과를 (추천ID + 도시키)로 캐싱해두고, 스크롤 백 시엔 즉시 캐시에서 복원.
@MainActor
final class MRTResultCache {
    static let shared = MRTResultCache()
    private init() {}

    struct Entry {
        let tnas: [MRTTnaItem]
        let flights: [MRTFlightItem]
        let accommodations: [MRTAccommodationItem]
        let timestamp: Date
    }

    private var store: [String: Entry] = [:]
    private let ttl: TimeInterval = 3600  // 1시간

    func get(key: String) -> Entry? {
        guard let entry = store[key], Date().timeIntervalSince(entry.timestamp) < ttl else { return nil }
        return entry
    }

    func set(key: String, tnas: [MRTTnaItem], flights: [MRTFlightItem], accommodations: [MRTAccommodationItem]) {
        store[key] = Entry(tnas: tnas, flights: flights, accommodations: accommodations, timestamp: Date())
    }
}

// MARK: - 마이리얼트립 연계 프로모션 섹션 (가로 스크롤 큐레이션)

struct MyRealTripPromoCard: View {
    let recommendation: LeaveRecommendation
    let originCountry: Country
    let allLeaveRecords: [LeaveRecord]

    @State private var liveProducts: [MRTTnaItem]?         // 투어/티켓
    @State private var liveFlights: [MRTFlightItem]?       // 항공권
    @State private var liveAccommodations: [MRTAccommodationItem]?  // 숙박
    @State private var isLoading = false

    /// 펼침 상태 — 사용자가 "보기" 누르면 true (per-card). 본질은 연차 추천이라 매번 접힌 상태로 시작.
    @State private var didOptIn = false
    @State private var dismissed = false   // 이번 세션 숨김 (현재 코드에선 트리거 없음)

    private var daysSinceLastLeave: Int? {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let lastDate: Date? = allLeaveRecords
            .filter { $0.deductsFromAnnualLeave }
            .compactMap { record -> Date? in
                let endDay = cal.startOfDay(for: record.endDate)
                guard endDay <= today else { return nil }
                guard record.status == .used || record.status == .planned else { return nil }
                return record.endDate
            }
            .max()
        guard let last = lastDate else { return nil }
        return cal.dateComponents([.day], from: cal.startOfDay(for: last), to: today).day
    }

    private var suggestions: [(TravelSuggestion, String)] {
        TravelSuggestionEngine.suggest(
            for: recommendation,
            originCountry: originCountry,
            daysSinceLastLeave: daysSinceLastLeave
        )
    }

    /// 첫 번째 큐레이션 도시 (TNA 검색 키워드로 사용)
    private var primarySuggestion: (TravelSuggestion, String)? {
        suggestions.first
    }

    /// 마이리얼트립 API용 도시명 (항상 한국어 — 명세 요구사항)
    static func koreanCityName(for cityKey: String) -> String {
        switch cityKey {
        case "osaka": return "오사카"
        case "fukuoka": return "후쿠오카"
        case "tokyo": return "도쿄"
        case "sapporo": return "삿포로"
        case "kyoto": return "교토"
        case "okinawa": return "오키나와"
        case "danang": return "다낭"
        case "bangkok": return "방콕"
        case "taipei": return "타이베이"
        case "bali": return "발리"
        case "jeju": return "제주"
        case "busan": return "부산"
        case "guam": return "괌"
        case "saipan": return "사이판"
        case "hanoi": return "하노이"
        case "phuket": return "푸켓"
        default: return cityKey
        }
    }

    /// 도시별 IATA 코드 (항공권 검색용)
    static func iataCode(for cityKey: String) -> String? {
        switch cityKey {
        case "osaka": return "OSA"        // 간사이 (KIX/ITM 통합)
        case "fukuoka": return "FUK"
        case "tokyo": return "TYO"        // NRT/HND 통합
        case "sapporo": return "SPK"      // CTS
        case "kyoto": return "OSA"        // 교토는 보통 간사이 공항
        case "okinawa": return "OKA"
        case "danang": return "DAD"
        case "bangkok": return "BKK"
        case "taipei": return "TPE"
        case "bali": return "DPS"
        case "jeju": return "CJU"
        case "busan": return "PUS"
        case "guam": return "GUM"
        case "saipan": return "SPN"
        case "hanoi": return "HAN"
        case "phuket": return "HKT"
        default: return nil
        }
    }

    /// 출발 국가별 대표 IATA 코드
    static func departureIata(for country: Country) -> String {
        switch country {
        case .korea: return "ICN"   // 인천
        case .japan: return "NRT"   // 나리타
        case .china: return "PEK"   // 베이징
        case .usa: return "LAX"     // LA
        case .germany: return "FRA" // 프랑크푸르트
        case .france: return "CDG"  // 파리 샤를드골
        }
    }

    private var dateRangeText: String {
        let f = DateFormatter()
        f.dateFormat = "M/d"
        return "\(f.string(from: recommendation.startDate)) - \(f.string(from: recommendation.endDate))"
    }

    var body: some View {
        if suggestions.isEmpty || dismissed {
            EmptyView()
        } else if !didOptIn {
            // 기본 상태: 접힌 카드 + "보기" 버튼. 본질(연차 추천)을 가리지 않도록.
            collapsedCard
        } else {
            VStack(alignment: .leading, spacing: 12) {
                // 헤더 — 펼친 상태에선 "접기" 버튼 제공
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Strings.travelSuggestionsHeader)
                            .font(.headline)
                        Text("\(dateRangeText) · \(recommendation.totalDaysOff)\(Strings.dayUnitSuffix)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        didOptIn = false  // 다시 접음
                    } label: {
                        Image(systemName: "chevron.up.circle.fill")
                            .foregroundStyle(.tertiary)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }

                // 추천 이유 카드 — 도시 + 컨텍스트 이유 강조
                if let primary = primarySuggestion {
                    reasonCard(suggestion: primary.0, reasonKey: primary.1)
                }

                // 본문 — 항공/숙박/투어 3개 섹션 또는 정적 큐레이션 fallback
                Group {
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding(.vertical, 24)
                            Spacer()
                        }
                    } else {
                        let hasAnyLive = (liveFlights?.isEmpty == false)
                            || (liveAccommodations?.isEmpty == false)
                            || (liveProducts?.isEmpty == false)

                        if hasAnyLive {
                            VStack(alignment: .leading, spacing: 14) {
                                if let flights = liveFlights, !flights.isEmpty {
                                    sectionHeader(icon: "airplane", title: Strings.sectionFlight, color: AppTheme.Colors.brand)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            // 첫 번째 = 가장 저렴 (이미 가격순 정렬됨)
                                            ForEach(Array(flights.enumerated()), id: \.element.id) { idx, f in
                                                MRTFlightCard(flight: f, showCheapestBadge: idx == 0)
                                            }
                                        }
                                    }
                                    .scrollClipDisabled()
                                }
                                if let accoms = liveAccommodations, !accoms.isEmpty {
                                    sectionHeader(icon: "bed.double.fill", title: Strings.sectionAccommodation, color: AppTheme.Colors.success)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            // 첫 번째 = 베스트 평점 (review_desc 정렬)
                                            ForEach(Array(accoms.enumerated()), id: \.element.id) { idx, a in
                                                MRTAccommodationCard(item: a, showTopRatedBadge: idx == 0)
                                            }
                                        }
                                    }
                                    .scrollClipDisabled()
                                }
                                if let products = liveProducts, !products.isEmpty {
                                    sectionHeader(icon: "ticket.fill", title: Strings.sectionTour, color: AppTheme.Colors.bonus)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            // 첫 번째 = 베스트셀러 (review_score_desc 정렬)
                                            ForEach(Array(products.enumerated()), id: \.element.id) { idx, p in
                                                MRTLiveTnaCard(product: p, showBestsellerBadge: idx == 0)
                                            }
                                        }
                                    }
                                    .scrollClipDisabled()
                                }
                            }
                        } else {
                            // Fallback: 정적 큐레이션 카드
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(suggestions, id: \.0.id) { entry in
                                        TravelSuggestionCard(
                                            suggestion: entry.0,
                                            reasonKey: entry.1,
                                            recommendation: recommendation
                                        )
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .scrollClipDisabled()
                        }
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(AppTheme.Colors.bonus.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: AppTheme.Colors.bonus.opacity(0.10), radius: 8, y: 4)
            .task(id: optInTaskKey) {
                // 펼친 상태에서만 API 호출
                guard didOptIn else { return }
                await loadLiveProducts()
            }
        }
    }

    /// task 트리거 키 — 펼친 상태에서만 API 호출
    private var optInTaskKey: String {
        "\(primarySuggestion?.0.cityKey ?? "")-\(didOptIn ? "on" : "off")"
    }

    // MARK: - 접힌 카드 (기본 상태) — 본질은 연차 추천. MRT는 사용자가 원할 때만 펼침.
    private var collapsedCard: some View {
        Button {
            AnalyticsService.logMRTOptInShow()
            didOptIn = true
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Strings.travelSuggestionsHeader)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("\(dateRangeText) · \(recommendation.totalDaysOff)\(Strings.dayUnitSuffix)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(Strings.mrtOptInShow)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(AppTheme.Colors.bonus)
                    .clipShape(Capsule())
            }
            .padding(12)
            .background(AppTheme.Colors.bonus.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.Colors.bonus.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 추천 이유 카드 (도시 + 컨텍스트)
    @ViewBuilder
    private func reasonCard(suggestion: TravelSuggestion, reasonKey: String) -> some View {
        let cityDisplay = Strings.cityName(suggestion.cityKey)
        let reasonText = reasonKey.isEmpty ? Strings.travelThemeName(suggestion.themeKey)
                                            : Strings.travelReasonLabel(reasonKey)
        HStack(spacing: 12) {
            Text(suggestion.countryFlag)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(cityDisplay)
                    .font(.subheadline.weight(.bold))
                Text(Strings.mrtCityReason(
                    city: cityDisplay,
                    season: reasonText,
                    days: recommendation.totalDaysOff
                ))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(AppTheme.Colors.bonus.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 첫 도시 기준으로 마이리얼트립 TNA + 항공권 + 숙박 병렬 호출
    private func loadLiveProducts() async {
        // 한국어 사용자만 호출 (비즈니스 결정: 마이리얼트립은 한국 시장 위주)
        guard LanguageManager.shared.currentLanguage == .korean else {
            liveProducts = []; liveFlights = []; liveAccommodations = []
            return
        }
        guard MRTConfig.apiKey != nil else {
            print("[MRT] ❌ API 키 미설정")
            liveProducts = []; liveFlights = []; liveAccommodations = []
            return
        }
        guard let primary = primarySuggestion else {
            liveProducts = []; liveFlights = []; liveAccommodations = []
            return
        }

        // 캐시 우선 — 스크롤 백/앞 반복 시 API 재호출 방지
        let cacheKey = "\(recommendation.id.uuidString)-\(primary.0.cityKey)"
        if let cached = MRTResultCache.shared.get(key: cacheKey) {
            liveProducts = cached.tnas
            liveFlights = cached.flights
            liveAccommodations = cached.accommodations
            return
        }

        let cityName = Self.koreanCityName(for: primary.0.cityKey)
        let cityIata = Self.iataCode(for: primary.0.cityKey)
        let depIata = Self.departureIata(for: originCountry)
        let nights = max(1, recommendation.totalDaysOff - 1)

        print("[MRT] 🔍 \(cityName) — TNA + 항공(\(depIata)→\(cityIata ?? "?")) + 숙박(\(nights)박) 동시 호출")
        isLoading = true
        defer { isLoading = false }

        // 3개 병렬 호출
        async let tnaTask = fetchTnas(cityName: cityName)
        async let flightTask = fetchFlights(depIata: depIata, arrIata: cityIata, period: nights)
        async let accomTask = fetchAccommodations(cityName: cityName)

        let (tnas, flights, accoms) = await (tnaTask, flightTask, accomTask)

        // Task가 도중에 cancel되면(스크롤 아웃 등) 부분 결과를 캐시하지 않음 — 완료된 경우만 저장
        guard !Task.isCancelled else { return }

        liveProducts = tnas
        liveFlights = flights
        liveAccommodations = accoms
        MRTResultCache.shared.set(key: cacheKey, tnas: tnas, flights: flights, accommodations: accoms)
    }

    private func fetchTnas(cityName: String) async -> [MRTTnaItem] {
        do {
            let r = try await MyRealTripAPIClient.shared.searchTnas(
                keyword: cityName, city: cityName,
                sort: "review_score_desc", page: 1, perPage: 8
            )
            print("[MRT] ✅ TNA \(r.items.count)개")
            return r.items
        } catch {
            print("[MRT] ❌ TNA: \(error.localizedDescription)")
            return []
        }
    }

    private func fetchFlights(depIata: String, arrIata: String?, period: Int) async -> [MRTFlightItem] {
        guard let arrIata = arrIata else { return [] }
        // 추천일과 정확히 일치하는 항공권만 조회. startDate=endDate=추천 출발일.
        // period(박 수)는 MRT API 제한상 1~7로 클램핑 — 8박 이상 추천(예: 9일 추석)도 7박 항공권으로 검색.
        let exactDate = recommendation.startDate
        let safePeriod = min(7, max(1, period))
        do {
            let items = try await MyRealTripAPIClient.shared.searchFlightCalendar(
                depCityCd: depIata, arrCityCd: arrIata, period: safePeriod,
                startDate: exactDate, endDate: exactDate
            )
            print("[MRT] ✅ 항공권 \(items.count)개")
            return Array(items.sorted { $0.totalPrice < $1.totalPrice }.prefix(6))
        } catch {
            print("[MRT] ❌ 항공권: \(error.localizedDescription)")
            return []
        }
    }

    private func fetchAccommodations(cityName: String) async -> [MRTAccommodationItem] {
        do {
            let r = try await MyRealTripAPIClient.shared.searchAccommodations(
                keyword: cityName,
                checkIn: recommendation.startDate,
                checkOut: recommendation.endDate,
                adultCount: 2, childCount: 0,
                order: "review_desc", page: 0, size: 6
            )
            print("[MRT] ✅ 숙박 \(r.items.count)개")
            return r.items
        } catch {
            print("[MRT] ❌ 숙박: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - 섹션 헤더 헬퍼

extension MyRealTripPromoCard {
    func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(.top, 4)
    }
}

// MARK: - 항공권 카드

struct MRTFlightCard: View {
    let flight: MRTFlightItem
    var showCheapestBadge: Bool = false   // "가장 저렴" 라벨 (리스트 첫 카드에 부여)

    private var dateText: String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        let out = DateFormatter()
        out.dateFormat = "M/d (E)"
        out.locale = Locale(identifier: Strings.localeIdentifier)
        guard let dep = f.date(from: flight.departureDate) else { return flight.departureDate }
        if let retStr = flight.returnDate, let ret = f.date(from: retStr) {
            return "\(out.string(from: dep)) → \(out.string(from: ret))"
        }
        return out.string(from: dep)
    }

    private var priceText: String {
        Strings.currency(flight.totalPrice)
    }

    private var url: URL {
        URL(string: "https://www.myrealtrip.com/?utm_source=goldweek&utm_medium=app&utm_campaign=flight&utm_content=\(flight.fromCity)-\(flight.toCity)")!
    }

    var body: some View {
        Link(destination: url) {
            VStack(alignment: .leading, spacing: 8) {
                // 상단: 출발/도착
                HStack(spacing: 6) {
                    Text(flight.fromCity)
                        .font(.headline.weight(.bold))
                    Image(systemName: "airplane")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .voDecorative()
                    Text(flight.toCity)
                        .font(.headline.weight(.bold))
                    Spacer(minLength: 0)
                }

                // 날짜
                Text(dateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                // 항공사 + 직항 여부 + 가장 저렴 (이유 라벨)
                HStack(spacing: 6) {
                    if let airline = flight.airline {
                        Text(airline)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.Colors.brand.opacity(0.15))
                            .foregroundStyle(AppTheme.Colors.brand)
                            .clipShape(Capsule())
                    }
                    if let stops = flight.transfer, stops == 0 {
                        Text(Strings.mrtFlightReasonDirect)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.Colors.success.opacity(0.15))
                            .foregroundStyle(AppTheme.Colors.success)
                            .clipShape(Capsule())
                    }
                    if showCheapestBadge {
                        Text(Strings.mrtFlightReasonCheapest)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.Colors.bonus.opacity(0.15))
                            .foregroundStyle(AppTheme.Colors.bonus)
                            .clipShape(Capsule())
                    }
                    Spacer(minLength: 0)
                }

                Spacer(minLength: 4)

                // 가격
                Text(priceText)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.brand)
            }
            .padding(12)
            .frame(width: 180, height: 140, alignment: .topLeading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.brand.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            AnalyticsService.logMRTCardTap(category: "flight", city: flight.toCity)
        })
        .onAppear {
            AnalyticsService.logMRTCardImpression(category: "flight", city: flight.toCity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(
            VoiceOverLabel.flight(
                origin: flight.fromCity,
                destination: flight.toCity,
                dateRange: dateText,
                airline: flight.airline,
                direct: flight.transfer == 0,
                priceText: priceText
            ) + (showCheapestBadge ? ", \(Strings.mrtFlightReasonCheapest)" : "")
        ))
        .accessibilityAddTraits(.isLink)
    }
}

// MARK: - 숙박 카드

struct MRTAccommodationCard: View {
    let item: MRTAccommodationItem
    var showTopRatedBadge: Bool = false   // "베스트 평점" 라벨

    private var priceText: String {
        Strings.currency(item.salePrice)
    }

    private var url: URL {
        // 마이리얼트립 숙박 응답에 productUrl 미제공 — 호텔 ID 기반 추정 URL
        URL(string: "https://www.myrealtrip.com/accommodations/\(item.itemId)?utm_source=goldweek&utm_medium=app&utm_campaign=accommodation")
            ?? URL(string: "https://www.myrealtrip.com/")!
    }

    var body: some View {
        Link(destination: url) {
            VStack(alignment: .leading, spacing: 0) {
                // 이미지
                ZStack(alignment: .topTrailing) {
                    if let urlStr = item.imageUrl, let imageURL = URL(string: urlStr) {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .success(let img): img.resizable().scaledToFill()
                            case .failure: Rectangle().fill(Color(.systemGray5))
                            case .empty: Rectangle().fill(Color(.systemGray6)).overlay(ProgressView())
                            @unknown default: Rectangle().fill(Color(.systemGray6))
                            }
                        }
                        .frame(width: 200, height: 110)
                        .clipped()
                    } else {
                        Rectangle().fill(Color(.systemGray5))
                            .frame(width: 200, height: 110)
                            .overlay(Image(systemName: "bed.double").foregroundStyle(.secondary))
                    }

                    if showTopRatedBadge {
                        Text(Strings.mrtAccomReasonTopRated)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(8)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.itemName)
                        .font(.caption.weight(.semibold))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 4) {
                        if let star = item.starRating, star > 0 {
                            HStack(spacing: 1) {
                                ForEach(0..<min(star, 5), id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 7))
                                        .foregroundStyle(.yellow)
                                }
                            }
                        }
                        if let score = item.reviewScore, let count = item.reviewCount, count > 0 {
                            Text("\(score) (\(count))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer(minLength: 4)

                    Text(priceText)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.Colors.success)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(width: 200, alignment: .leading)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            AnalyticsService.logMRTCardTap(category: "stay", city: item.itemName)
        })
        .onAppear {
            AnalyticsService.logMRTCardImpression(category: "stay", city: item.itemName)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(
            VoiceOverLabel.accommodation(
                name: item.itemName,
                rating: item.reviewScore.flatMap { Double($0) },
                priceText: priceText
            ) + (showTopRatedBadge ? ", \(Strings.mrtAccomReasonTopRated)" : "")
        ))
        .accessibilityAddTraits(.isLink)
    }
}

// MARK: - 실제 마이리얼트립 TNA 상품 카드

struct MRTLiveTnaCard: View {
    let product: MRTTnaItem
    var showBestsellerBadge: Bool = false  // "베스트셀러" 라벨

    private var url: URL? {
        URL(string: product.productUrl)
    }

    private var displayPrice: String {
        product.priceDisplay ?? Strings.currency(product.salePrice)
    }

    var body: some View {
        Link(destination: url ?? URL(string: "https://www.myrealtrip.com/")!) {
            VStack(alignment: .leading, spacing: 0) {
                // 이미지
                ZStack(alignment: .topTrailing) {
                    if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure:
                                Rectangle().fill(Color(.systemGray5))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundStyle(.secondary)
                                    )
                            case .empty:
                                Rectangle().fill(Color(.systemGray6))
                                    .overlay(ProgressView())
                            @unknown default:
                                Rectangle().fill(Color(.systemGray6))
                            }
                        }
                        .frame(width: 200, height: 120)
                        .clipped()
                    } else {
                        Rectangle().fill(Color(.systemGray5))
                            .frame(width: 200, height: 120)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundStyle(.secondary)
                            )
                    }

                    // "베스트셀러" or "즉시 확정" 태그 (이유 라벨)
                    let displayTag: String? = {
                        if showBestsellerBadge { return Strings.mrtTourReasonBestseller }
                        return product.tags?.first
                    }()
                    if let tag = displayTag {
                        Text(tag)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(8)
                    }
                }
                .clipShape(.rect(topLeadingRadius: 14, topTrailingRadius: 14))

                // 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.itemName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    // 평점
                    if let score = product.reviewScore, let count = product.reviewCount, count > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.2f", score))
                                .font(.caption2.weight(.semibold))
                            Text("(\(count))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer(minLength: 4)

                    Text(displayPrice)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.Colors.bonus)
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 200)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            AnalyticsService.logMRTCardTap(category: "tour", city: product.itemName)
        })
        .onAppear {
            AnalyticsService.logMRTCardImpression(category: "tour", city: product.itemName)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(
            VoiceOverLabel.accommodation(
                name: product.itemName,
                rating: product.reviewScore,
                priceText: displayPrice
            ) + (showBestsellerBadge ? ", \(Strings.mrtTourReasonBestseller)" : "")
        ))
        .accessibilityAddTraits(.isLink)
    }
}

// MARK: - 개별 큐레이션 카드

struct TravelSuggestionCard: View {
    let suggestion: TravelSuggestion
    let reasonKey: String
    let recommendation: LeaveRecommendation

    @Environment(\.colorScheme) private var colorScheme

    private var reasonIcon: String {
        switch reasonKey {
        case "burnoutRecovery": return "heart.fill"
        case "offSeasonDeal": return "tag.fill"
        case "bestSeason": return "sparkles"
        case "shortNearby", "weekendEscape": return "bolt.fill"
        case "longResort": return "sun.max.fill"
        case "familyTime": return "person.2.fill"
        case "couplesTrip": return "heart.circle.fill"
        case "foodieParadise": return "fork.knife"
        case "cultureExplore": return "building.columns.fill"
        default: return "star.fill"
        }
    }

    private var accentColor: Color {
        colorScheme == .dark ? suggestion.accentColor.dark : suggestion.accentColor.light
    }

    private var url: URL {
        // 마이리얼트립 검색 URL이 client-side SPA여서 ?keyword= 파라미터로 검색 트리거 안 됨
        // ("검색 결과가 없습니다" 페이지로 빠짐). 메인 페이지로 보내고 UTM으로 출처 추적.
        // service-api 통합 후에는 응답의 deepLinkURL로 직접 상품 페이지 이동.
        let urlString = "https://www.myrealtrip.com/?utm_source=goldweek&utm_medium=app&utm_campaign=travel_suggestions&utm_content=\(suggestion.cityKey)"
        return URL(string: urlString) ?? URL(string: "https://www.myrealtrip.com/")!
    }

    private var dateRangeText: String {
        let f = DateFormatter()
        f.dateFormat = "M/d"
        return "\(f.string(from: recommendation.startDate))~\(f.string(from: recommendation.endDate))"
    }

    var body: some View {
        Link(destination: url) {
            VStack(alignment: .leading, spacing: 10) {
                // 상단 그라디언트 영역
                ZStack(alignment: .topTrailing) {
                    LinearGradient(
                        colors: [accentColor, accentColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 88)

                    // 우측 상단: 가격대 배지
                    Text(Strings.priceTierLabel(suggestion.priceTierKey))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(10)

                    // 좌측 상단: 큰 국기
                    Text(suggestion.countryFlag)
                        .font(.system(.largeTitle))
                        .padding(.leading, 12)
                        .padding(.top, 10)
                        .voDecorative()
                }
                .clipShape(.rect(topLeadingRadius: 14, topTrailingRadius: 14))

                // 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.cityName(suggestion.cityKey))
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(Strings.travelThemeName(suggestion.themeKey))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // 추천 이유 배지 (컨텍스트 기반)
                    if !reasonKey.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: reasonIcon)
                                .font(.system(size: 9, weight: .bold))
                            Text(Strings.travelReasonLabel(reasonKey))
                                .font(.caption2.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(accentColor.opacity(0.12))
                        .clipShape(Capsule())
                        .padding(.top, 4)
                    }

                    Text(dateRangeText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)

                    HStack(spacing: 3) {
                        Text(Strings.mrtPromoCTA)
                            .font(.caption2.weight(.semibold))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(accentColor)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .frame(width: 168)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 사용자 휴가 기반 액티비티 추천
// EditLeaveSheet에서 사용. 등록된 LeaveRecord의 날짜·기간·사용자 국가를 기반으로
// TravelSuggestionEngine으로 도시 후보를 뽑고, MRT 라이브 항공/숙박을 추가로 보여준다.
// MRT 노출은 무료 — 어필리에이트 수익 채널이라 Pro 게이트 두지 않음.

struct LeaveActivityRecommendations: View {
    let leave: LeaveRecord
    let originCountry: Country

    @State private var liveFlights: [MRTFlightItem]?
    @State private var liveAccommodations: [MRTAccommodationItem]?
    @State private var isLoading = false

    private var totalDaysOff: Int {
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: leave.startDate, to: leave.endDate).day ?? 0
        return max(1, days + 1)
    }

    /// TravelSuggestionEngine이 LeaveRecommendation을 요구하므로 LeaveRecord에서 합성
    private var syntheticRecommendation: LeaveRecommendation {
        LeaveRecommendation(
            title: leave.note.isEmpty ? Strings.leaveActivityTitle : leave.note,
            description: "",
            startDate: leave.startDate,
            endDate: leave.endDate,
            requiredLeaveDays: leave.effectiveLeaveDays,
            totalDaysOff: totalDaysOff
        )
    }

    private var suggestions: [(TravelSuggestion, String)] {
        TravelSuggestionEngine.suggest(
            for: syntheticRecommendation,
            originCountry: originCountry,
            daysSinceLastLeave: nil,
            limit: 6
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(AppTheme.Colors.bonus)
                    .voDecorative()
                VStack(alignment: .leading, spacing: 2) {
                    Text(Strings.leaveActivityTitle)
                        .font(.subheadline.weight(.semibold))
                    Text(Strings.leaveActivitySubtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            if suggestions.isEmpty {
                Text(Strings.noRecommendations)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(suggestions.enumerated()), id: \.element.0.id) { _, entry in
                            TravelSuggestionCard(
                                suggestion: entry.0,
                                reasonKey: entry.1,
                                recommendation: syntheticRecommendation
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            liveSection
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .task {
            await loadLive()
        }
    }

    @ViewBuilder
    private var liveSection: some View {
        if isLoading {
            HStack(spacing: 6) {
                ProgressView().scaleEffect(0.7)
                Text(Strings.leaveActivityLoading)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        } else if (liveFlights?.isEmpty == false) || (liveAccommodations?.isEmpty == false) {
            Divider().padding(.vertical, 4)
            Text(Strings.leaveActivityLiveTitle)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    if let flights = liveFlights, !flights.isEmpty {
                        ForEach(Array(flights.prefix(3))) { f in
                            MRTFlightCard(flight: f, showCheapestBadge: f.id == flights.first?.id)
                        }
                    }
                    if let stays = liveAccommodations, !stays.isEmpty {
                        ForEach(Array(stays.prefix(3))) { s in
                            MRTAccommodationCard(item: s, showTopRatedBadge: s.itemId == stays.first?.itemId)
                        }
                    }
                }
            }
        }
    }

    private func loadLive() async {
        // 비-한국어 사용자 또는 API 키 미설정 시 라이브 결과 노출 안 함 (MRT 한국 시장 한정)
        guard LanguageManager.shared.currentLanguage == .korean,
              MRTConfig.apiKey != nil,
              let primary = suggestions.first?.0 else {
            return
        }
        isLoading = true
        defer { isLoading = false }

        let cityName = MyRealTripPromoCard.koreanCityName(for: primary.cityKey)
        let cityIata = MyRealTripPromoCard.iataCode(for: primary.cityKey)
        let depIata = MyRealTripPromoCard.departureIata(for: originCountry)
        let nights = max(1, totalDaysOff - 1)

        async let flightTask = fetchFlights(depIata: depIata, arrIata: cityIata, period: nights)
        async let accomTask = fetchAccommodations(cityName: cityName)
        let (flights, accoms) = await (flightTask, accomTask)

        guard !Task.isCancelled else { return }
        liveFlights = flights
        liveAccommodations = accoms
    }

    private func fetchFlights(depIata: String, arrIata: String?, period: Int) async -> [MRTFlightItem] {
        guard let arrIata = arrIata else { return [] }
        let safePeriod = min(7, max(1, period))
        do {
            let items = try await MyRealTripAPIClient.shared.searchFlightCalendar(
                depCityCd: depIata, arrCityCd: arrIata, period: safePeriod,
                startDate: leave.startDate, endDate: leave.startDate
            )
            return Array(items.sorted { $0.totalPrice < $1.totalPrice }.prefix(4))
        } catch {
            return []
        }
    }

    private func fetchAccommodations(cityName: String) async -> [MRTAccommodationItem] {
        do {
            let r = try await MyRealTripAPIClient.shared.searchAccommodations(
                keyword: cityName,
                checkIn: leave.startDate,
                checkOut: leave.endDate,
                size: 4
            )
            return r.items
        } catch {
            return []
        }
    }
}

// MARK: - 최적 연간 휴가 플래너 (Pro 기능)
// LeavePlanner 알고리즘으로 1년치 최적 연차 배치를 계산해 보여준다.
// Free: 락된 미리보기 + Pro CTA. Pro: 전체 결과 + 일괄 등록.

struct OptimalLeavePlannerCard: View {
    @Bindable var profile: UserProfile
    let year: Int
    let availableLeaveDays: Int
    let existingLeaveRecords: [LeaveRecord]

    @Environment(\.modelContext) private var modelContext
    @State private var plan: OptimalLeavePlan?
    @State private var isComputing = false
    @State private var showingPaywall = false
    @State private var didBatchAdd = false
    /// 기본은 접힘. Pro 결과가 길어서 추천 탭을 잠식하지 않도록.
    @State private var isExpanded = false

    private var proManager: ProManager { ProManager.shared }

    private let holidayService = HolidayService()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerSection

            if !proManager.isPro {
                proLockedView
            } else if availableLeaveDays <= 0 {
                Text(Strings.optimalPlannerEmpty)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if isComputing {
                HStack(spacing: 6) {
                    ProgressView().scaleEffect(0.7)
                    Text(Strings.leaveActivityLoading)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else if let plan = plan {
                planResultView(plan: plan)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.Colors.bonus.opacity(0.25), lineWidth: 1)
        )
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .task(id: "\(year)-\(availableLeaveDays)") {
            await computeIfPro()
        }
    }

    /// 헤더 — 비-Pro는 부제 노출, Pro+결과 있으면 펼침 토글 버튼 역할
    @ViewBuilder
    private var headerSection: some View {
        let canToggle = proManager.isPro && (plan?.breaks.isEmpty == false)
        let header = HStack(spacing: 8) {
            Image(systemName: "wand.and.stars")
                .foregroundStyle(AppTheme.Colors.bonus)
                .voDecorative()
            VStack(alignment: .leading, spacing: 2) {
                Text(Strings.optimalPlannerTitle)
                    .font(.subheadline.weight(.semibold))
                if !proManager.isPro || plan == nil {
                    Text(Strings.optimalPlannerSubtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if canToggle {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .voDecorative()
            }
        }

        if canToggle {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
                HapticFeedback.selection()
            } label: {
                header
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(Strings.optimalPlannerTitle))
            .accessibilityHint(Text(isExpanded ? Strings.optimalPlannerCollapseHint : Strings.optimalPlannerExpandHint))
        } else {
            header
        }
    }

    @ViewBuilder
    private var proLockedView: some View {
        Button {
            AnalyticsService.logPaywallView(source: "optimal_planner")
            showingPaywall = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                        .voDecorative()
                    Text(Strings.optimalPlannerProLockedTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                Text(Strings.optimalPlannerProLockedDesc)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 4) {
                    Text(Strings.optimalPlannerCTA)
                        .font(.caption.weight(.semibold))
                    Image(systemName: "arrow.right")
                        .font(.caption2.weight(.bold))
                        .voDecorative()
                }
                .foregroundStyle(AppTheme.Colors.brand)
                .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(AppTheme.Colors.bonus.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func planResultView(plan: OptimalLeavePlan) -> some View {
        if plan.breaks.isEmpty {
            Text(Strings.optimalPlannerEmpty)
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            // 항상 보이는 요약 (접힘 상태에서도 노출)
            summaryPill(plan: plan)

            // 펼침 상태에서만 연휴 카드 + 일괄 등록
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(plan.breaks) { brk in
                        breakCard(brk: brk)
                    }
                }
                .padding(.top, 4)

                Button {
                    batchAdd(plan: plan)
                } label: {
                    HStack(spacing: 6) {
                        Spacer()
                        Image(systemName: didBatchAdd ? "checkmark.circle.fill" : "plus.circle.fill")
                            .voDecorative()
                        Text(Strings.optimalPlannerApplyAll)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .font(.subheadline)
                    .padding(.vertical, 9)
                    .background(didBatchAdd ? Color.green : AppTheme.Colors.bonus)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(didBatchAdd)
                .buttonStyle(.plain)
            }
        }
    }

    /// 접힘 상태에서도 노출되는 한 줄 요약 — 핵심 숫자를 한눈에
    private func summaryPill(plan: OptimalLeavePlan) -> some View {
        HStack(spacing: 8) {
            // 큰 숫자: 총 휴식일
            Text("\(plan.totalDaysOff)")
                .font(.title2.weight(.bold))
                .foregroundStyle(AppTheme.Colors.brand)
            Text(Strings.optimalPlannerSummaryUnit)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.brand)
                .padding(.leading, -4)
            Spacer(minLength: 0)
            // 보조: 연차 N · M회 연휴
            Text(Strings.optimalPlannerSummaryAside(leaveUsed: plan.leaveDaysUsed, breaks: plan.breaks.count))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppTheme.Colors.brand.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(Strings.optimalPlannerSummary(
            totalDays: plan.totalDaysOff,
            breaks: plan.breaks.count,
            leaveUsed: plan.leaveDaysUsed
        )))
    }

    /// 연휴 1건을 시각화한 카드 — 날짜 · 총 휴식일 · 구성(주말/공휴일/연차) 막대 · 포함 공휴일
    private func breakCard(brk: LeaveBreak) -> some View {
        let cal = Calendar.current
        let start = cal.startOfDay(for: brk.startDate)
        let leaveSet = Set(brk.leaveDates.map { cal.startOfDay(for: $0) })
        let days = (0..<max(brk.totalDays, 1)).compactMap {
            cal.date(byAdding: .day, value: $0, to: start)
        }
        var leaveN = 0, weekendN = 0, holidayN = 0
        for d in days {
            let wd = cal.component(.weekday, from: d)
            if leaveSet.contains(cal.startOfDay(for: d)) { leaveN += 1 }
            else if wd == 1 || wd == 7 { weekendN += 1 }
            else { holidayN += 1 }  // 주말도 연차도 아닌 휴일 = 공휴일
        }

        let f = DateFormatter()
        f.locale = Locale(identifier: Strings.localeIdentifier)
        f.dateFormat = "M/d (E)"
        let dateRange = "\(f.string(from: brk.startDate)) ~ \(f.string(from: brk.endDate))"

        return VStack(alignment: .leading, spacing: 10) {
            // 날짜 + 효율 배지
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(dateRange)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                if brk.efficiency >= 1.5 {
                    HStack(spacing: 2) {
                        Text("✨").font(.caption2).voDecorative()
                        Text(String(format: "%.1f×", brk.efficiency))
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(AppTheme.Colors.bonus)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(AppTheme.Colors.bonus.opacity(0.12))
                    .clipShape(Capsule())
                }
            }

            // 큰 숫자: 총 휴식일
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(brk.totalDays)")
                    .font(.title.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.brand)
                Text(Strings.optimalPlannerSummaryUnit)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.brand)
            }

            // 구성 막대 — 주말 / 공휴일 / 연차
            GeometryReader { geo in
                let total = CGFloat(max(brk.totalDays, 1))
                let w = geo.size.width
                HStack(spacing: 1.5) {
                    if weekendN > 0 {
                        Color(.systemGray3).frame(width: w * CGFloat(weekendN) / total)
                    }
                    if holidayN > 0 {
                        AppTheme.Colors.holiday.frame(width: w * CGFloat(holidayN) / total)
                    }
                    if leaveN > 0 {
                        AppTheme.Colors.leave.frame(width: w * CGFloat(leaveN) / total)
                    }
                }
                .clipShape(Capsule())
            }
            .frame(height: 10)

            // 구성 범례
            HStack(spacing: 12) {
                if leaveN > 0 { compChip(color: AppTheme.Colors.leave, text: "\(Strings.annualLeave) \(leaveN)\(Strings.dayUnitSuffix)") }
                if holidayN > 0 { compChip(color: AppTheme.Colors.holiday, text: "\(Strings.holiday) \(holidayN)\(Strings.dayUnitSuffix)") }
                if weekendN > 0 { compChip(color: Color(.systemGray3), text: "\(Strings.weekend) \(weekendN)\(Strings.dayUnitSuffix)") }
                Spacer(minLength: 0)
            }

            // 포함 공휴일
            if !brk.holidaysIncluded.isEmpty {
                Text(brk.holidaysIncluded.joined(separator: " · "))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(dateRange), \(Strings.breakLabel(brk.totalDays, leaveUsed: brk.leaveCount))"))
    }

    private func compChip(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(text)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    @MainActor
    private func computeIfPro() async {
        guard proManager.isPro, availableLeaveDays > 0 else { return }
        isComputing = true
        defer { isComputing = false }

        let holidays = holidayService.getHolidays(for: year, country: profile.country)
        let holidayDates = holidays.map { $0.date }

        // 이미 등록된 휴가 날짜는 제외 (중복 방지)
        let cal = Calendar.current
        var excluded: Set<Date> = []
        for record in existingLeaveRecords where record.status != .cancelled {
            var d = cal.startOfDay(for: record.startDate)
            let end = cal.startOfDay(for: record.endDate)
            while d <= end {
                excluded.insert(d)
                guard let next = cal.date(byAdding: .day, value: 1, to: d) else { break }
                d = next
            }
        }

        // 백그라운드 계산 (DP는 가볍지만 main 스레드 차단 방지)
        let computed = await Task.detached(priority: .userInitiated) { () -> OptimalLeavePlan in
            LeavePlanner.optimalPlan(
                year: year,
                availableLeaveDays: availableLeaveDays,
                holidays: holidayDates,
                excludedDates: excluded,
                minBreakLength: 3,
                earliestDate: Date(),
                calendar: cal
            )
        }.value

        plan = computed
    }

    private func batchAdd(plan: OptimalLeavePlan) {
        let cal = Calendar.current
        var addedAny = false
        for brk in plan.breaks {
            // 각 연휴마다 1개 LeaveRecord (연속된 leaveDates를 합쳐서)
            // 단순화: leaveDates를 sorted 후 연속 구간으로 분할
            let sortedDates = brk.leaveDates.sorted()
            var segments: [[Date]] = []
            var current: [Date] = []
            for d in sortedDates {
                if let last = current.last,
                   let next = cal.date(byAdding: .day, value: 1, to: last),
                   cal.isDate(next, inSameDayAs: d) {
                    current.append(d)
                } else {
                    if !current.isEmpty { segments.append(current) }
                    current = [d]
                }
            }
            if !current.isEmpty { segments.append(current) }

            for seg in segments {
                guard let first = seg.first, let last = seg.last else { continue }
                let record = LeaveRecord(
                    startDate: first,
                    endDate: last,
                    type: .annual,
                    status: .planned,
                    note: "",
                    isRecommended: true
                )
                modelContext.insert(record)
                addedAny = true
            }
        }
        if addedAny {
            try? modelContext.save()
            HapticFeedback.success()
            didBatchAdd = true
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
    let container = try! ModelContainer(for: UserProfile.self, LeaveRecord.self, configurations: config)

    let profile = UserProfile(name: "홍길동", yearStartMonth: 1, totalAnnualLeave: 15, usedLeave: 3)
    container.mainContext.insert(profile)

    return RecommendationsView(profile: profile)
        .modelContainer(container)
}

// MARK: - 마이리얼트립 API 클라이언트 (골격)
//
// 사용자가 마이리얼트립 service-api 명세(인증/엔드포인트/응답 스키마)를 확인하면
// 다음 위치만 채우면 즉시 동작:
//   1. MRTConfig.baseURL
//   2. MRTConfig.authHeader (Bearer / X-API-Key 등)
//   3. MRT*Response 모델의 CodingKeys
//   4. MyRealTripAPIClient의 각 fetch* 메서드 path/query
//
// API 키 설정 (3가지 방식 중 택1):
//   A. Xcode Run Scheme → Arguments → Environment Variables → MRT_API_KEY 추가 (개발/디버그)
//   B. Goldweek/GoldweekSecrets.swift 생성 후 enum GoldweekSecrets { static let mrtAPIKey = "..." }
//      (.gitignore 처리됨, 배포 빌드용)
//   C. xcconfig + INFOPLIST_KEY_MRTAPIKey (가장 정석, 별도 셋업 필요)

enum MRTConfig {
    /// 마이리얼트립 service-api 베이스 URL
    static let baseURL: String = "https://partner-ext-api.myrealtrip.com"

    /// API 키 — 환경변수 우선, 없으면 GoldweekSecrets fallback (공백·줄바꿈 자동 제거)
    static var apiKey: String? {
        let raw: String
        if let env = ProcessInfo.processInfo.environment["MRT_API_KEY"], !env.isEmpty {
            raw = env
        } else {
            raw = GoldweekSecrets.mrtAPIKey
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty || trimmed == "YOUR_MRT_API_KEY_HERE" ? nil : trimmed
    }
}

// MARK: - 응답 모델 (마이리얼트립 service-api 명세 기반)

/// 공통 응답 wrapper
struct MRTAPIResponse<T: Codable>: Codable {
    let data: T?
    let meta: MRTMeta?
    let result: MRTResult?
}

struct MRTMeta: Codable {
    let totalCount: Int?
}

struct MRTResult: Codable {
    let status: Int?
    let message: String?
    let code: String?
}

/// 항공권 캘린더 항목 (flight/calendar*)
struct MRTFlightItem: Codable, Identifiable, Hashable {
    var id: String { "\(fromCity)-\(toCity)-\(departureDate)" }
    let fromCity: String
    let toCity: String
    let period: Int?
    let departureDate: String
    let returnDate: String?
    let totalPrice: Int64
    let airline: String?
    let transfer: Int?
    let averagePrice: Int64?
}

/// 숙소 검색 결과 wrapper
struct MRTAccommodationSearchData: Codable {
    let items: [MRTAccommodationItem]
    let totalCount: Int
    let page: Int
    let size: Int
}

struct MRTAccommodationItem: Codable, Identifiable, Hashable {
    var id: Int64 { itemId }
    let itemId: Int64
    let itemName: String
    let originalPrice: Int64
    let salePrice: Int64
    let imageUrl: String?
    let reviewCount: Int?
    let reviewScore: String?
    let starRating: Int?
}

/// 투어/티켓 검색 결과 wrapper
struct MRTTnaSearchData: Codable {
    let items: [MRTTnaItem]
    let totalCount: Int
    let page: Int
    let perPage: Int
    let hasNextPage: Bool
}

struct MRTTnaItem: Codable, Identifiable, Hashable {
    var id: String { gid }
    let gid: String
    let itemName: String
    let description: String?
    let salePrice: Int64
    let priceDisplay: String?
    let category: String?
    let reviewScore: Double?
    let reviewCount: Int?
    let imageUrl: String?
    let productUrl: String         // 웹 딥링크
    let deepLink: String?          // 앱 딥링크 (mrt://...)
    let tags: [String]?
}

/// TNA 카테고리
struct MRTTnaCategoriesData: Codable {
    let categories: [MRTTnaCategory]
    let totalCount: Int
}

struct MRTTnaCategory: Codable, Identifiable, Hashable {
    var id: String { value }
    let name: String
    let value: String
}

// MARK: - API 클라이언트

actor MyRealTripAPIClient {
    static let shared = MyRealTripAPIClient()

    enum APIError: LocalizedError {
        case notConfigured              // baseURL 또는 apiKey 미설정
        case invalidURL
        case badRequest(String?)        // 400 — 파라미터 오류
        case unauthorized(String?)      // 401 — 인증 실패 (재시도 X)
        case forbidden(String?)         // 403 — 권한 없음 (재시도 X)
        case notFound(String?)          // 404 — 엔드포인트/리소스 없음 (재시도 X)
        case rateLimited(String?)       // 429 — Rate Limit
        case serverError(Int, String?)  // 500/503 — 서버 오류
        case decodingError(Error)
        case networkError(Error)
        case maxRetriesExceeded

        var errorDescription: String? {
            switch self {
            case .notConfigured: return Strings.mrtErrorNotConfigured
            case .invalidURL: return Strings.mrtErrorInvalidURL
            case .badRequest(let m): return m ?? Strings.mrtErrorBadRequest
            case .unauthorized(let m): return m ?? Strings.mrtErrorUnauthorized
            case .forbidden(let m): return m ?? Strings.mrtErrorForbidden
            case .notFound(let m): return m ?? Strings.mrtErrorNotFound
            case .rateLimited(let m): return m ?? Strings.mrtErrorRateLimited
            case .serverError(let code, let m): return m ?? Strings.mrtErrorServerError(code)
            case .decodingError: return Strings.mrtErrorDecoding
            case .networkError(let err): return err.localizedDescription
            case .maxRetriesExceeded: return Strings.mrtErrorMaxRetries
            }
        }
    }

    /// 에러 응답 본문에서 result.message 추출
    private struct MRTErrorBody: Decodable {
        struct Result: Decodable {
            let message: String?
            let code: String?
        }
        let result: Result?
    }

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(memoryCapacity: 10 * 1024 * 1024,
                                    diskCapacity: 50 * 1024 * 1024)
        self.session = URLSession(configuration: config)

        let decoder = JSONDecoder()
        // 마이리얼트립 응답은 camelCase이므로 변환 불필요
        self.decoder = decoder
    }

    /// 공통 POST + JSON body 헬퍼 (Exponential Backoff: 429/500/503 시 1s/2s/4s 재시도)
    private func postJSON<T: Decodable>(
        path: String,
        body: [String: Any],
        maxRetries: Int = 3
    ) async throws -> T {
        guard let key = MRTConfig.apiKey else {
            throw APIError.notConfigured
        }
        guard let url = URL(string: MRTConfig.baseURL + path) else {
            throw APIError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        var lastError: APIError = .maxRetriesExceeded

        for attempt in 0..<maxRetries {
            do {
                print("[MRT] → POST \(path) (attempt \(attempt + 1)/\(maxRetries))")
                let (data, response) = try await session.data(for: req)
                guard let http = response as? HTTPURLResponse else {
                    throw APIError.networkError(URLError(.badServerResponse))
                }
                print("[MRT] ← \(http.statusCode) \(path)")

                // Rate limit 모니터링 (잔여 요청 적으면 로그)
                if let remaining = http.value(forHTTPHeaderField: "X-RateLimit-Remaining"),
                   let n = Int(remaining), n < 5 {
                    print("[MRT] Rate limit warning — remaining: \(n)")
                }

                // 4xx/5xx일 때 응답 본문 일부 출력 (디버깅용)
                if !(200..<300).contains(http.statusCode) {
                    let preview = String(data: data, encoding: .utf8)?.prefix(500) ?? ""
                    print("[MRT] body: \(preview)")
                }

                switch http.statusCode {
                case 200..<300:
                    do { return try decoder.decode(T.self, from: data) }
                    catch { throw APIError.decodingError(error) }

                // 재시도 불가 — 즉시 throw
                case 400: throw APIError.badRequest(extractMessage(from: data))
                case 401: throw APIError.unauthorized(extractMessage(from: data))
                case 403: throw APIError.forbidden(extractMessage(from: data))
                case 404: throw APIError.notFound(extractMessage(from: data))

                // 재시도 가능 — backoff 후 재시도
                case 429:
                    lastError = .rateLimited(extractMessage(from: data))
                case 500, 503:
                    lastError = .serverError(http.statusCode, extractMessage(from: data))
                case 500..<600:
                    lastError = .serverError(http.statusCode, extractMessage(from: data))
                default:
                    lastError = .serverError(http.statusCode, extractMessage(from: data))
                }
            } catch let error as APIError {
                // 재시도 불가 에러는 즉시 전파
                switch error {
                case .badRequest, .unauthorized, .forbidden, .notFound,
                     .notConfigured, .invalidURL, .decodingError:
                    throw error
                default:
                    lastError = error
                }
            } catch {
                lastError = .networkError(error)
            }

            // Exponential Backoff: 1s, 2s, 4s
            if attempt < maxRetries - 1 {
                let delay = UInt64(pow(2.0, Double(attempt)) * 1_000_000_000)
                try? await Task.sleep(nanoseconds: delay)
            }
        }

        throw lastError
    }

    /// 에러 응답 본문에서 result.message 추출
    private func extractMessage(from data: Data) -> String? {
        guard let body = try? decoder.decode(MRTErrorBody.self, from: data) else { return nil }
        return body.result?.message
    }

    // MARK: - 투어/티켓 (TNA) — 추천 탭의 메인 호출

    /// 투어티켓 상품 검색
    /// docs: POST /v1/products/tna/search
    func searchTnas(
        keyword: String,
        city: String? = nil,
        category: String? = nil,
        minPrice: Int? = nil,
        maxPrice: Int? = nil,
        sort: String? = "review_score_desc",
        page: Int = 1,
        perPage: Int = 10
    ) async throws -> MRTTnaSearchData {
        var body: [String: Any] = [
            "keyword": keyword,
            "page": page,
            "perPage": perPage
        ]
        if let city = city { body["city"] = city }
        if let category = category { body["category"] = category }
        if let minPrice = minPrice { body["minPrice"] = minPrice }
        if let maxPrice = maxPrice { body["maxPrice"] = maxPrice }
        if let sort = sort { body["sort"] = sort }

        let response: MRTAPIResponse<MRTTnaSearchData> = try await postJSON(
            path: "/v1/products/tna/search",
            body: body
        )
        guard let data = response.data else { throw APIError.decodingError(URLError(.cannotParseResponse)) }
        return data
    }

    /// 도시별 카테고리 목록
    /// docs: POST /v1/products/tna/categories
    func getTnaCategories(city: String) async throws -> MRTTnaCategoriesData {
        let response: MRTAPIResponse<MRTTnaCategoriesData> = try await postJSON(
            path: "/v1/products/tna/categories",
            body: ["city": city]
        )
        guard let data = response.data else { throw APIError.decodingError(URLError(.cannotParseResponse)) }
        return data
    }

    // MARK: - 숙소

    /// 숙소 검색
    /// docs: POST /v1/products/accommodation/search
    func searchAccommodations(
        keyword: String,
        checkIn: Date,
        checkOut: Date,
        adultCount: Int = 2,
        childCount: Int = 0,
        isDomestic: Bool? = nil,
        starRating: String? = nil,
        order: String? = "review_desc",
        minPrice: Int? = nil,
        maxPrice: Int? = nil,
        page: Int = 0,
        size: Int = 10
    ) async throws -> MRTAccommodationSearchData {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        var body: [String: Any] = [
            "keyword": keyword,
            "checkIn": f.string(from: checkIn),
            "checkOut": f.string(from: checkOut),
            "adultCount": adultCount,
            "childCount": childCount,
            "page": page,
            "size": size
        ]
        if let isDomestic = isDomestic { body["isDomestic"] = isDomestic }
        if let starRating = starRating { body["starRating"] = starRating }
        if let order = order { body["order"] = order }
        if let minPrice = minPrice { body["minPrice"] = minPrice }
        if let maxPrice = maxPrice { body["maxPrice"] = maxPrice }

        let response: MRTAPIResponse<MRTAccommodationSearchData> = try await postJSON(
            path: "/v1/products/accommodation/search",
            body: body
        )
        guard let data = response.data else { throw APIError.decodingError(URLError(.cannotParseResponse)) }
        return data
    }

    // MARK: - 항공권

    /// 캘린더 최저가 조회 (지정 기간)
    /// docs: POST /v1/products/flight/calendar
    func searchFlightCalendar(
        depCityCd: String,
        arrCityCd: String,
        period: Int,
        startDate: Date,
        endDate: Date
    ) async throws -> [MRTFlightItem] {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        let body: [String: Any] = [
            "depCityCd": depCityCd,
            "arrCityCd": arrCityCd,
            "period": period,
            "startDate": f.string(from: startDate),
            "endDate": f.string(from: endDate)
        ]
        let response: MRTAPIResponse<[MRTFlightItem]> = try await postJSON(
            path: "/v1/products/flight/calendar",
            body: body
        )
        return response.data ?? []
    }

    /// 다중 목적지 최저가
    /// docs: POST /v1/products/flight/calendar/lowest
    func searchFlightLowestForDestinations(
        depCityCd: String,
        arrCityCds: [String],
        period: Int
    ) async throws -> [MRTFlightItem] {
        let body: [String: Any] = [
            "depCityCd": depCityCd,
            "arrCityCds": arrCityCds,
            "period": period
        ]
        let response: MRTAPIResponse<[MRTFlightItem]> = try await postJSON(
            path: "/v1/products/flight/calendar/lowest",
            body: body
        )
        return response.data ?? []
    }
}
