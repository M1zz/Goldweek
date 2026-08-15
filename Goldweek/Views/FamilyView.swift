//
//  FamilyView.swift
//  Goldweek
//
//  가족 탭 — 공유받은 가족·친구의 휴가 일정을 한눈에 표시
//  공유받은 일정이 1개 이상일 때만 탭이 나타난다 (MainTabView에서 제어)
//

import SwiftUI

struct FamilyView: View {
    @Bindable var profile: UserProfile

    private var service: ShareSyncService { .shared }

    var body: some View {
        NavigationStack {
            List {
                ForEach(service.sharedSchedules) { schedule in
                    Section {
                        let upcoming = schedule.upcomingLeaves
                        if upcoming.isEmpty {
                            Text(Strings.shareNoUpcoming)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(upcoming) { leave in
                                FamilyLeaveRow(leave: leave)
                            }
                        }
                    } header: {
                        HStack(spacing: 8) {
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundStyle(.blue)
                                .voDecorative()
                            Text(schedule.ownerName)
                            Spacer()
                            Text(Strings.shareUpcomingCount(schedule.upcomingLeaves.count))
                                .font(.body)
                                .textCase(nil)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(Strings.familyNavTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ShareScheduleView(profile: profile)) {
                        Image(systemName: "person.2.badge.gearshape")
                    }
                    .accessibilityLabel(Text(Strings.shareScheduleTitle))
                }
            }
            .refreshable {
                await service.refreshSharedSchedules()
            }
            .task {
                await service.refreshSharedSchedules()
            }
        }
    }
}

// MARK: - 가족 휴가 행 (D-day / 휴가 중 배지 포함)
struct FamilyLeaveRow: View {
    let leave: SharedLeaveItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: leave.type.icon)
                .foregroundStyle(.blue)
                .frame(width: 28)
                .voDecorative()

            VStack(alignment: .leading, spacing: 2) {
                Text(dateRangeText)
                    .font(.body)
                // rawValue는 한국어 고정값이다 — 앱 언어를 따르는 이름으로 그린다
                Text(Strings.leaveTypeName(leave.type))
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            badge
        }
        .accessibilityElement(children: .combine)
    }

    /// 오늘 기준 진행 중이면 "휴가 중", 아니면 시작까지 남은 일수(D-n)
    @ViewBuilder
    private var badge: some View {
        let today = Calendar.current.startOfDay(for: Date())
        let start = Calendar.current.startOfDay(for: leave.startDate)

        if start <= today && leave.endDate >= today {
            Text(Strings.familyOnLeave)
                .font(.body.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.green.opacity(0.15))
                .foregroundStyle(.green)
                .clipShape(Capsule())
        } else if let days = Calendar.current.dateComponents([.day], from: today, to: start).day, days > 0 {
            Text(Strings.familyDday(days))
                .font(.body.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.blue.opacity(0.12))
                .foregroundStyle(.blue)
                .clipShape(Capsule())
        }
    }

    private var dateRangeText: String {
        let start = leave.startDate.appFormatted()
        if Calendar.current.isDate(leave.startDate, inSameDayAs: leave.endDate) {
            return start
        }
        let end = leave.endDate.appFormatted()
        return "\(start) ~ \(end)"
    }
}
