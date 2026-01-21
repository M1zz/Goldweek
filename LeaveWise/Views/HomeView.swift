//
//  HomeView.swift
//  LeaveWise
//
//  홈 대시보드 화면
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Bindable var profile: UserProfile
    @Query(sort: \LeaveRecord.startDate) private var leaveRecords: [LeaveRecord]
    @Environment(\.modelContext) private var modelContext

    @State private var recommendations: [LeaveRecommendation] = []
    @State private var showingHistory = false

    private let recommendationEngine = RecommendationEngine()
    private let holidayService = HolidayService()

    var upcomingLeaves: [LeaveRecord] {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let today = calendar.startOfDay(for: Date())

        return leaveRecords.filter { record in
            let recordYear = calendar.component(.year, from: record.startDate)
            return recordYear == currentYear &&
                   record.startDate >= today &&
                   record.status == .planned
        }
        .sorted { $0.startDate < $1.startDate }
    }

    var usedLeavesCount: Int {
        leaveRecords.filter { $0.status == .used }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 연차 현황 카드
                    LeaveStatusCard(profile: profile)

                    // 휴가 사용 내역 버튼
                    LeaveHistoryButton(
                        usedCount: usedLeavesCount,
                        action: { showingHistory = true }
                    )

                    // 다가오는 휴가
                    if !upcomingLeaves.isEmpty {
                        UpcomingLeavesSection(leaves: upcomingLeaves)
                    }

                    // 추천 휴가 일정
                    RecommendationSection(
                        recommendations: recommendations,
                        profile: profile
                    )
                }
                .padding()
            }
            .navigationTitle("휴가플래너")
            .onAppear {
                loadRecommendations()
            }
            .sheet(isPresented: $showingHistory) {
                LeaveHistoryView()
            }
        }
    }
    
    private func loadRecommendations() {
        let year = Calendar.current.component(.year, from: Date())
        recommendations = recommendationEngine.generateRecommendations(
            for: profile,
            remainingLeave: profile.remainingLeave,
            year: year
        )
    }
}

// MARK: - 연차 현황 카드
struct LeaveStatusCard: View {
    @Bindable var profile: UserProfile

    var remainingPercentage: Double {
        guard profile.totalAnnualLeave > 0 else { return 0 }
        return profile.remainingLeave / profile.totalAnnualLeave
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(verbatim: "\(Calendar.current.component(.year, from: Date()))년 연차 현황")
                    .font(.headline)
                Spacer()
            }

            // 프로그레스 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [.green, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * remainingPercentage, height: 20)
                }
            }
            .frame(height: 20)
            
            // 연차 텍스트
            HStack {
                VStack(alignment: .leading) {
                    Text("사용")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(String(format: "%.1f", profile.usedLeave))일")
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
                }
                
                Spacer()
                
                VStack {
                    Text("총")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(String(format: "%.1f", profile.totalAnnualLeave))일")
                        .font(.title2.bold())
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("남음")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(String(format: "%.1f", profile.remainingLeave))일")
                        .font(.title2.bold())
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - 다가오는 휴가 섹션
struct UpcomingLeavesSection: View {
    let leaves: [LeaveRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📅 다가오는 휴가")
                    .font(.headline)
                Spacer()
                Text("\(leaves.count)건")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(leaves) { leave in
                UpcomingLeaveRow(leave: leave)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct UpcomingLeaveRow: View {
    let leave: LeaveRecord
    
    var daysUntil: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: leave.startDate).day ?? 0
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(leave.note.isEmpty ? "휴가" : leave.note)
                    .font(.subheadline.bold())
                
                Text("\(leave.startDate.formatted(date: .abbreviated, time: .omitted)) - \(leave.endDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("D-\(daysUntil)")
                    .font(.headline)
                    .foregroundStyle(.blue)
                
                Text("\(leave.type.rawValue) \(leave.daysCount)일")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 추천 섹션
struct RecommendationSection: View {
    let recommendations: [LeaveRecommendation]
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("💡 추천 휴가 일정")
                    .font(.headline)
                Spacer()
                if !recommendations.isEmpty {
                    Text("\(recommendations.count)건")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if recommendations.isEmpty {
                Text("추천을 생성 중입니다...")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach(recommendations) { recommendation in
                    RecommendationCard(
                        recommendation: recommendation,
                        onAdd: {
                            addLeave(from: recommendation)
                        }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

        do {
            try modelContext.save()
            HapticFeedback.success()
        } catch {
            // 롤백
            profile.usedLeave -= recommendation.requiredLeaveDays
            modelContext.delete(record)
            HapticFeedback.error()
        }
    }
}

struct RecommendationCard: View {
    let recommendation: LeaveRecommendation
    let onAdd: () -> Void
    @State private var isAdded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🎯 \(recommendation.title)")
                    .font(.subheadline.bold())
                Spacer()
                Text("효율: \(recommendation.efficiencyStars)")
                    .font(.caption)
            }
            
            Text(recommendation.description)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // 태그들
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(recommendation.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                }
            }

            // 버튼
            Button(action: {
                onAdd()
                isAdded = true
            }) {
                Text(isAdded ? "추가됨 ✓" : "일정 추가하기")
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isAdded ? Color.green : Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .disabled(isAdded)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 휴가 사용 내역 버튼
struct LeaveHistoryButton: View {
    let usedCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "list.bullet.clipboard")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text("휴가 사용 내역")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text("지난 휴가 기록을 확인하세요")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if usedCount > 0 {
                    Text("\(usedCount)건")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, LeaveRecord.self, configurations: config)

    let profile = UserProfile(name: "홍길동", yearStartMonth: 1, totalAnnualLeave: 15, usedLeave: 5)
    container.mainContext.insert(profile)

    return HomeView(profile: profile)
        .modelContainer(container)
}
