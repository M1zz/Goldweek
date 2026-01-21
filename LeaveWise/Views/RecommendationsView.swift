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
                        ProgressView("추천 일정 분석 중...")
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
            .navigationTitle("💡 휴가 추천")
            .onAppear {
                loadRecommendations()
            }
        }
    }
    
    private func loadRecommendations() {
        isLoading = true
        
        // 약간의 딜레이로 로딩 효과
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            recommendations = recommendationEngine.generateRecommendations(
                for: profile,
                remainingLeave: profile.remainingLeave,
                year: selectedYear
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
            // 롤백
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
            
            Text(verbatim: "\(selectedYear)년 추천")
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
                Text("사용 가능한 연차")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(String(format: "%.1f", profile.remainingLeave))")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.green)
                    Text("일")
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
            // 헤더
            HStack {
                Text("🎯 \(recommendation.title)")
                    .font(.headline)

                Spacer()

                VStack(alignment: .trailing) {
                    Text("효율")
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
                Label("\(Int(recommendation.requiredLeaveDays))일 연차", systemImage: "briefcase.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
                Spacer()
                Text("→")
                    .foregroundStyle(.secondary)
                Spacer()
                Label("\(recommendation.totalDaysOff)일 휴식", systemImage: "sun.max.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // 설명
            Text(recommendation.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            // 태그
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

            // 추가 버튼
            Button(action: onAdd) {
                HStack {
                    Spacer()
                    Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                    Text(isAdded ? "일정에 추가됨" : "일정에 추가하기")
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
    private let weekdayNames = ["일", "월", "화", "수", "목", "금", "토"]

    // 앞뒤로 평일 하루씩 추가한 날짜 범위
    var extendedDateRange: [Date] {
        var dates: [Date] = []

        // 하루 전 추가
        if let dayBefore = calendar.date(byAdding: .day, value: -1, to: startDate) {
            dates.append(dayBefore)
        }

        // 원래 범위
        var current = startDate
        while current <= endDate {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        // 하루 후 추가
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
            // 월 표시 (시작월과 종료월이 다르면 둘 다 표시)
            let startMonth = calendar.component(.month, from: startDate)
            let endMonth = calendar.component(.month, from: endDate)
            HStack {
                if startMonth == endMonth {
                    Text("\(startMonth)월")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(startMonth)월 → \(endMonth)월")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            // 날짜 미리보기
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

            // 범례
            HStack(spacing: 12) {
                MiniLegend(color: .gray.opacity(0.5), text: "평일")
                MiniLegend(color: .green, text: "연차")
                MiniLegend(color: .red.opacity(0.7), text: "공휴일")
                MiniLegend(color: .blue.opacity(0.7), text: "주말")
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
        } else if weekday == 1 { // 일요일
            return .sunday
        } else if weekday == 7 { // 토요일
            return .saturday
        } else if isInLeaveRange {
            return .leave // 연차 범위 내 평일 = 연차 사용
        } else {
            return .workday // 연차 범위 밖 평일 = 일반 근무일
        }
    }
}

// MARK: - 날짜 타입
enum DayType {
    case leave      // 연차 사용일 (평일)
    case saturday   // 토요일
    case sunday     // 일요일
    case holiday    // 공휴일
    case workday    // 일반 근무일 (연차 범위 밖 평일)

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
        switch self {
        case .leave: return "연차"
        case .saturday: return "토"
        case .sunday: return "일"
        case .holiday: return "휴일"
        case .workday: return "평일"
        }
    }
}

// MARK: - 날짜 미리보기 셀
struct DatePreviewCell: View {
    let date: Date
    let dayType: DayType

    private let calendar = Calendar.current
    private let weekdayNames = ["일", "월", "화", "수", "목", "금", "토"]

    var dayNumber: Int {
        calendar.component(.day, from: date)
    }

    var weekdayName: String {
        let weekday = calendar.component(.weekday, from: date)
        return weekdayNames[weekday - 1]
    }

    var body: some View {
        VStack(spacing: 4) {
            // 요일
            Text(weekdayName)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(dayType == .sunday || dayType == .holiday ? .red : (dayType == .saturday ? .blue : .secondary))

            // 날짜
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

            Text("추천 일정이 없습니다")
                .font(.headline)

            Text("선호도 설정을 확인하거나\n연차를 더 확보해보세요")
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
    private let monthNames = ["1월", "2월", "3월", "4월", "5월", "6월",
                              "7월", "8월", "9월", "10월", "11월", "12월"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(.blue)
                Text("추천 일정 미리보기")
                    .font(.headline)
                Spacer()
                Text("\(recommendations.count)개")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // 연간 달력 미리보기
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 6), spacing: 8) {
                ForEach(0..<12, id: \.self) { monthIndex in
                    MonthPreviewCell(
                        month: monthIndex + 1,
                        monthName: monthNames[monthIndex],
                        recommendations: recommendationsForMonth(monthIndex + 1),
                        year: selectedYear
                    )
                }
            }

            // 범례
            HStack(spacing: 16) {
                LegendDot(color: .orange, text: "황금연휴")
                LegendDot(color: .green, text: "징검다리")
                LegendDot(color: .blue, text: "연속휴가")
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

    var recommendationColor: Color {
        guard let first = recommendations.first else { return .clear }

        if first.tags.contains("황금연휴") || first.title.contains("황금") {
            return .orange
        } else if first.tags.contains("징검다리") {
            return .green
        } else {
            return .blue
        }
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
                    // 추천 일정 표시 (점으로)
                    HStack(spacing: 2) {
                        ForEach(Array(recommendations.prefix(3).enumerated()), id: \.offset) { index, rec in
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

            // 추천 개수
            if !recommendations.isEmpty && !isPastMonth {
                Text("\(recommendations.count)개")
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
        if rec.tags.contains("황금연휴") || rec.title.contains("황금") || rec.title.contains("연계 휴가") {
            return .orange
        } else if rec.tags.contains("징검다리") {
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
