//
//  RecommendationsView.swift
//  LeaveWise
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 연도 선택
                    YearPicker(selectedYear: $selectedYear)
                        .onChange(of: selectedYear) { _, _ in
                            loadRecommendations()
                        }

                    // 남은 연차 정보 — records 기반으로 계산
                    RemainingLeaveInfo(available: availableLeave, total: profile.totalAnnualLeave, committed: committedLeave, hasBonus: activeBonusLeave > 0)

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

                        // 연차를 써야 만들 수 있는 추천
                        if !actionableRecommendations.isEmpty {
                            RecommendationList(
                                recommendations: actionableRecommendations,
                                addedRecommendations: $addedRecommendations,
                                onAdd: addLeave
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
        }
    }

    private func loadRecommendations() {
        isLoading = true
        let remaining = availableLeave

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            recommendations = recommendationEngine.generateRecommendations(
                for: profile,
                remainingLeave: remaining,
                year: selectedYear,
                country: profile.country
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
            HapticFeedback.success()
        } catch {
            addedRecommendations.remove(recommendation.id)
            modelContext.delete(record)
            HapticFeedback.error()
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

            Spacer()

            VStack(spacing: 4) {
                Text(Strings.yearRecommendation(year: selectedYear))
                    .font(.title2.bold())
                
                if !proManager.isPro && selectedYear != currentYear {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(Strings.currentYearOnly)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

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
                        .font(.system(size: 36, weight: .bold))
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
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5)
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

    @State private var showingPaywall = false
    private let proManager = ProManager.shared
    private let freeAddLimit = 3

    var body: some View {
        VStack(spacing: 16) {
            ForEach(Array(recommendations.enumerated()), id: \.element.id) { index, recommendation in
                let requiresPro = !proManager.isPro && index >= freeAddLimit
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

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(holiday.title)
                .font(.subheadline.bold())
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(formatter.string(from: holiday.startDate)) – \(formatter.string(from: holiday.endDate))")
                .font(.caption)
                .foregroundStyle(.secondary)

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
        .frame(width: 148)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🎯 \(recommendation.title)")
                    .font(.headline)

                Spacer()

                if requiresPro {
                    HStack(spacing: 3) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text("Pro")
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.12))
                    .clipShape(Capsule())
                } else {
                    VStack(alignment: .trailing) {
                        Text(Strings.efficiency)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(recommendation.efficiencyStars)
                            .font(.caption)
                    }
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
                        Text(Strings.addWithPro)
                            .fontWeight(.semibold)
                    } else {
                        Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
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
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
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
            .font(.system(size: 10))
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func getDayType(for date: Date) -> DayType {
        let weekday = calendar.component(.weekday, from: date)
        let isHoliday = holidays.contains { calendar.isDate($0.date, inSameDayAs: date) }
        let isInLeaveRange = date >= startDate && date <= endDate

        if isHoliday {
            return .holiday
        } else if weekday == 1 {
            return .sunday
        } else if weekday == 7 {
            return .saturday
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
        case .saturday: return .blue.opacity(0.7)
        case .sunday: return .red.opacity(0.7)
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
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(dayType == .sunday || dayType == .holiday ? .red : (dayType == .saturday ? .blue : .secondary))

            Text("\(dayNumber)")
                .font(.system(size: 13, weight: .semibold))
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
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, LeaveRecord.self, configurations: config)

    let profile = UserProfile(name: "홍길동", yearStartMonth: 1, totalAnnualLeave: 15, usedLeave: 3)
    container.mainContext.insert(profile)

    return RecommendationsView(profile: profile)
        .modelContainer(container)
}
