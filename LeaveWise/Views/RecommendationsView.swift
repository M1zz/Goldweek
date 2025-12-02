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
            
            Text("\(selectedYear)년 추천")
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
            
            // 날짜 정보
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("기간")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(recommendation.startDate.formatted(date: .abbreviated, time: .omitted)) - \(recommendation.endDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("연차 사용")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(String(format: "%.1f", recommendation.requiredLeaveDays))일")
                        .font(.subheadline.bold())
                        .foregroundStyle(.blue)
                }
                
                VStack(alignment: .center, spacing: 4) {
                    Text("총 휴일")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(recommendation.totalDaysOff)일")
                        .font(.subheadline.bold())
                        .foregroundStyle(.green)
                }
            }
            
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, LeaveRecord.self, configurations: config)
    
    let profile = UserProfile(name: "홍길동", yearStartMonth: 1, totalAnnualLeave: 15, usedLeave: 3)
    container.mainContext.insert(profile)
    
    return RecommendationsView(profile: profile)
        .modelContainer(container)
}
