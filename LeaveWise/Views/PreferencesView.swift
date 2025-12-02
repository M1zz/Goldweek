//
//  PreferencesView.swift
//  LeaveWise
//
//  휴가 선호도 설정 화면
//

import SwiftUI
import SwiftData

struct PreferencesView: View {
    @Bindable var profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDuration: PreferredDuration
    @State private var selectedSeasons: Set<Season>
    @State private var preferLongWeekend: Bool
    @State private var preferConsecutive: Bool
    @State private var avoidPeakSeason: Bool
    @State private var selectedActivities: Set<ActivityType>
    
    init(profile: UserProfile) {
        self.profile = profile
        _selectedDuration = State(initialValue: profile.preferredDuration)
        _selectedSeasons = State(initialValue: Set(profile.preferredSeasons))
        _preferLongWeekend = State(initialValue: profile.preferLongWeekend)
        _preferConsecutive = State(initialValue: profile.preferConsecutive)
        _avoidPeakSeason = State(initialValue: profile.avoidPeakSeason)
        _selectedActivities = State(initialValue: Set(profile.priorityActivities))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 선호 휴가 길이
                Section("선호하는 휴가 길이") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(PreferredDuration.allCases) { duration in
                            DurationButton(
                                duration: duration,
                                isSelected: selectedDuration == duration
                            ) {
                                selectedDuration = duration
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 8)
                }
                
                // 선호 계절
                Section("선호하는 계절 (복수 선택)") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(Season.allCases) { season in
                            SeasonButton(
                                season: season,
                                isSelected: selectedSeasons.contains(season)
                            ) {
                                toggleSeason(season)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 8)
                }
                
                // 휴가 스타일
                Section("휴가 스타일") {
                    Toggle("징검다리 휴일 활용", isOn: $preferLongWeekend)
                    Toggle("연속 휴가 선호", isOn: $preferConsecutive)
                    Toggle("성수기 회피", isOn: $avoidPeakSeason)
                }
                
                // 선호 활동
                Section("주로 하고 싶은 활동") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(ActivityType.allCases) { activity in
                            ActivityButton(
                                activity: activity,
                                isSelected: selectedActivities.contains(activity)
                            ) {
                                toggleActivity(activity)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("나의 휴가 스타일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        savePreferences()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleSeason(_ season: Season) {
        if selectedSeasons.contains(season) {
            selectedSeasons.remove(season)
        } else {
            selectedSeasons.insert(season)
        }
    }
    
    private func toggleActivity(_ activity: ActivityType) {
        if selectedActivities.contains(activity) {
            selectedActivities.remove(activity)
        } else {
            selectedActivities.insert(activity)
        }
    }
    
    private func savePreferences() {
        profile.preferredDuration = selectedDuration
        profile.preferredSeasons = Array(selectedSeasons)
        profile.preferLongWeekend = preferLongWeekend
        profile.preferConsecutive = preferConsecutive
        profile.avoidPeakSeason = avoidPeakSeason
        profile.priorityActivities = Array(selectedActivities)
    }
}

// MARK: - 버튼 컴포넌트들
struct DurationButton: View {
    let duration: PreferredDuration
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(duration.icon)
                    .font(.title)
                Text(duration.rawValue)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct SeasonButton: View {
    let season: Season
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(season.icon)
                    .font(.title2)
                Text(season.rawValue)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

struct ActivityButton: View {
    let activity: ActivityType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(activity.icon)
                    .font(.title3)
                Text(activity.rawValue)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    
    let profile = UserProfile(name: "홍길동", yearStartMonth: 1, totalAnnualLeave: 15)
    container.mainContext.insert(profile)
    
    return PreferencesView(profile: profile)
        .modelContainer(container)
}
