//
//  PreferencesView.swift
//  Goldweek
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
                Section(Strings.preferredDurationSection) {
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
                Section(Strings.preferredSeasonSection) {
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
                Section(Strings.vacationStyleSection) {
                    Toggle(Strings.useBridgeDays, isOn: $preferLongWeekend)
                    Toggle(Strings.preferConsecutive, isOn: $preferConsecutive)
                    Toggle(Strings.avoidPeakSeason, isOn: $avoidPeakSeason)
                }

                // 선호 활동
                Section(Strings.preferredActivitySection) {
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
            .navigationTitle(Strings.navTitlePreferences)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.save) {
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
                    .voDecorative()
                Text(Strings.durationName(duration))
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .voButton(Strings.durationName(duration))
        .voSelected(isSelected)
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
                    .voDecorative()
                Text(Strings.seasonName(season))
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .voButton(Strings.seasonName(season))
        .voSelected(isSelected)
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
                    .voDecorative()
                Text(Strings.activityName(activity))
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .voButton(Strings.activityName(activity))
        .voSelected(isSelected)
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
