//
//  ContentView.swift
//  Goldweek
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
                        LeaveManager.updatePastLeaves(records: leaveRecords, modelContext: modelContext)
                        updateWidget()
                        ReviewManager.shared.recordLaunch()
                        if !hasCompletedOnboarding {
                            hasCompletedOnboarding = true
                        }
                        syncSharedSchedules(profile: profile)
                    }
                    .onChange(of: scenePhase) { _, newPhase in
                        if newPhase == .active {
                            LeaveManager.updatePastLeaves(records: leaveRecords, modelContext: modelContext)
                            updateWidget()
                            syncSharedSchedules(profile: profile)
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
                    .onChange(of: leaveSyncFingerprint) { _, _ in
                        // 공유 중이면 변경사항을 CloudKit에 미러링 (디바운스됨)
                        ShareSyncService.shared.scheduleMirror(
                            profile: ProfileSnapshot(profile: profile),
                            leaves: leaveRecords.map(LeaveSnapshot.init)
                        )
                    }
                    .onChange(of: bonusLeaves.count) { _, _ in
                        updateWidget()
                    }
            } else if hasCompletedOnboarding {
                // 온보딩 완료했지만 profile이 없는 경우 (빌드로 SwiftData 초기화됨)
                // 기본 profile 자동 생성
                Color.clear.onAppear {
                    createDefaultProfile()
                }
            } else {
                OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
            }
        }
    }

    private func createDefaultProfile() {
        let country = Country.fromDeviceLocale()

        // 국가에 따라 언어 설정 (DE/FR는 UI 번역 추가 전까지 영문)
        switch country {
        case .korea: AppLanguage.current = .korean
        case .japan: AppLanguage.current = .japanese
        case .china: AppLanguage.current = .chinese
        case .usa, .germany, .france: AppLanguage.current = .english
        }

        let profile = UserProfile(
            name: Strings.defaultUser,
            yearStartMonth: 1,
            totalAnnualLeave: 15,
            usedLeave: 0,
            country: country
        )
        modelContext.insert(profile)
        do {
            try modelContext.save()
        } catch {
            logError("기본 프로필 저장 실패: \(error.localizedDescription)", category: .data)
        }
    }

    /// 휴가 기록의 공유 관련 필드 변화 감지용 (개수뿐 아니라 날짜/상태 수정도 포착)
    private var leaveSyncFingerprint: Int {
        var hasher = Hasher()
        for record in leaveRecords {
            hasher.combine(record.id)
            hasher.combine(record.startDate)
            hasher.combine(record.endDate)
            hasher.combine(record.typeRaw)
            hasher.combine(record.statusRaw)
        }
        return hasher.finalize()
    }

    private func syncSharedSchedules(profile: UserProfile) {
        let snapshot = ProfileSnapshot(profile: profile)
        let leaves = leaveRecords.map(LeaveSnapshot.init)
        Task {
            await ShareSyncService.shared.onAppActive(profile: snapshot, leaves: leaves)
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
                    Image(systemName: "chart.bar.fill")
                    Text(Strings.tabHome)
                }
                .tag(0)

            CalendarView(profile: profile)
                .tabItem {
                    Image(systemName: "calendar")
                    Text(Strings.tabCalendar)
                }
                .tag(1)

            SettingsView(profile: profile)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(Strings.tabSettings)
                }
                .tag(2)
        }
        .tint(Color(red: 0.0, green: 0.4, blue: 0.9))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, LeaveRecord.self, BonusLeave.self, CustomHoliday.self], inMemory: true)
}
