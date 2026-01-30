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

    @State private var recommendations: [LeaveRecommendation] = []
    @State private var selectedYear: Int
    @State private var isLoading = true
    @State private var addedRecommendations: Set<UUID> = []

    private let recommendationEngine = RecommendationEngine()

    init(profile: UserProfile) {
        self.profile = profile
        _selectedYear = State(initialValue: Calendar.current.component(.year, from: Date()))
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

                    // 남은 연차 정보
                    RemainingLeaveInfo(profile: profile)

                    // 추천 일정 미리보기 달력
                    if !recommendations.isEmpty && !isLoading {
                        RecommendationCalendarPreview(
                            recommendations: recommendations,
                            selectedYear: selectedYear
                        )
                    }

                    // 추천 리스트
                    if isLoading {
                        ProgressView(Strings.analyzingSchedule)
                            .padding(.top, 40)
                    } else if recommendations.isEmpty {
                        EmptyRecommendationView()
                    } else {
                        RecommendationList(
                            recommendations: recommendations,
                            addedRecommendations: $addedRecommendations,
                            onAdd: addLeave
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("💡 \(Strings.navTitleRecommendations)")
            .onAppear {
                loadRecommendations()
            }
        }
    }

    private func loadRecommendations() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            recommendations = recommendationEngine.generateRecommendations(
                for: profile,
                remainingLeave: profile.remainingLeave,
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
        profile.usedLeave += recommendation.requiredLeaveDays
        addedRecommendations.insert(recommendation.id)

        do {
            try modelContext.save()
            HapticFeedback.success()
        } catch {
            profile.usedLeave -= recommendation.requiredLeaveDays
            addedRecommendations.remove(recommendation.id)
            modelContext.delete(record)
            HapticFeedback.error()
        }
    }
}

// MARK: - 연도 선택기
struct YearPicker: View {
    @Binding var selectedYear: Int

    private let currentYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        HStack {
            Button(action: { selectedYear -= 1 }) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .disabled(selectedYear <= currentYear)

            Spacer()

            Text(Strings.yearRecommendation(year: selectedYear))
                .font(.title2.bold())

            Spacer()

            Button(action: { selectedYear += 1 }) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .disabled(selectedYear >= currentYear + 1)
        }
        .padding(.horizontal)
    }
}

// MARK: - 남은 연차 정보
struct RemainingLeaveInfo: View {
    @Bindable var profile: UserProfile

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Strings.availableLeave)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(String(format: "%.1f", profile.remainingLeave))")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.green)
                    Text(Strings.dayUnitSuffix)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            CircularProgressView(
                progress: profile.usedLeave / profile.totalAnnualLeave,
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

    var body: some View {
        VStack(spacing: 16) {
            ForEach(recommendations) { recommendation in
                DetailedRecommendationCard(
                    recommendation: recommendation,
                    isAdded: addedRecommendations.contains(recommendation.id),
                    onAdd: { onAdd(recommendation) }
                )
            }
        }
    }
}

// MARK: - 상세 추천 카드
struct DetailedRecommendationCard: View {
    let recommendation: LeaveRecommendation
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🎯 \(recommendation.title)")
                    .font(.headline)

                Spacer()

                VStack(alignment: .trailing) {
                    Text(Strings.efficiency)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(recommendation.efficiencyStars)
                        .font(.caption)
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
                    Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                    Text(isAdded ? Strings.addedToScheduleAction : Strings.addToScheduleAction)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(isAdded ? Color.green : Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(isAdded)
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
