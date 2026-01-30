//
//  ContentView.swift
//  LeaveWise
//
//  메인 탭 뷰
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var profiles: [UserProfile]
    @Query private var leaveRecords: [LeaveRecord]
    @Query private var bonusLeaves: [BonusLeave]

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var currentProfile: UserProfile? {
        profiles.first
    }

    var body: some View {
        let _ = LanguageManager.shared.currentLanguage
        Group {
            if let profile = currentProfile {
                MainTabView(profile: profile)
                    .onAppear {
                        updateWidget()
                        if !hasCompletedOnboarding {
                            hasCompletedOnboarding = true
                        }
                    }
                    .onChange(of: scenePhase) { _, newPhase in
                        if newPhase == .active {
                            updateWidget()
                        }
                    }
                    .onChange(of: profile.usedLeave) { _, _ in
                        updateWidget()
                    }
                    .onChange(of: profile.totalAnnualLeave) { _, _ in
                        updateWidget()
                    }
                    .onChange(of: leaveRecords.count) { _, _ in
                        updateWidget()
                    }
                    .onChange(of: bonusLeaves.count) { _, _ in
                        updateWidget()
                    }
            } else {
                OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
            }
        }
    }

    private func updateWidget() {
        guard let profile = currentProfile else { return }
        WidgetService.shared.updateWidgetData(
            profile: profile,
            bonusLeaves: bonusLeaves,
            leaveRecords: leaveRecords
        )
    }
}

struct MainTabView: View {
    @Bindable var profile: UserProfile
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(profile: profile)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(Strings.tabHome)
                }
                .tag(0)

            CalendarView(profile: profile)
                .tabItem {
                    Image(systemName: "calendar")
                    Text(Strings.tabCalendar)
                }
                .tag(1)

            AddLeaveView(profile: profile)
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text(Strings.tabRegister)
                }
                .tag(2)

            RecommendationsView(profile: profile)
                .tabItem {
                    Image(systemName: "lightbulb.fill")
                    Text(Strings.tabRecommendations)
                }
                .tag(3)

            SettingsView(profile: profile)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(Strings.tabSettings)
                }
                .tag(4)
        }
        .tint(Color(red: 0.0, green: 0.4, blue: 0.9))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, LeaveRecord.self, BonusLeave.self], inMemory: true)
}
