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
    @Query private var customHolidays: [CustomHoliday]

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
                        } else if newPhase == .background {
                            // 앱을 떠나는 순간의 상태를 타임머신에 보존 (내용 같으면 스킵됨)
                            TimeMachineService.shared.captureNow(from: modelContext, reason: .background)
                        }
                    }
                    .onChange(of: timeMachineFingerprint) { _, _ in
                        TimeMachineService.shared.scheduleAutoSnapshot(context: modelContext)
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
        // 저장소는 비었지만 타임머신 스냅샷이 남아있다면 우선 복구한다
        // (크래시 복구/실수 초기화 등으로 저장소가 리셋된 경우의 안전망)
        if TimeMachineService.shared.restoreFromLatestSnapshot(to: modelContext) {
            logInfo("빈 저장소 감지 — 타임머신 스냅샷에서 데이터 복구", category: .data)
            return
        }

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

    /// 타임머신 자동 스냅샷용 — 모든 데이터의 변화를 포착
    private var timeMachineFingerprint: Int {
        var hasher = Hasher()
        for profile in profiles {
            hasher.combine(profile.name)
            hasher.combine(profile.totalAnnualLeave)
            hasher.combine(profile.usedLeave)
            hasher.combine(profile.yearStartMonth)
            hasher.combine(profile.countryRaw)
            hasher.combine(profile.userTypeRaw)
        }
        for record in leaveRecords {
            hasher.combine(record.id)
            hasher.combine(record.startDate)
            hasher.combine(record.endDate)
            hasher.combine(record.typeRaw)
            hasher.combine(record.statusRaw)
            hasher.combine(record.note)
            hasher.combine(record.bonusLeaveId)
        }
        for bonus in bonusLeaves {
            hasher.combine(bonus.id)
            hasher.combine(bonus.days)
            hasher.combine(bonus.usedDays)
            hasher.combine(bonus.isUsed)
        }
        for holiday in customHolidays {
            hasher.combine(holiday.id)
            hasher.combine(holiday.date)
            hasher.combine(holiday.name)
        }
        return hasher.finalize()
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

    // 공유받은 일정이 있으면 가족 탭 표시 (@Observable — body에서 읽으면 자동 갱신)
    private var hasSharedSchedules: Bool {
        !ShareSyncService.shared.sharedSchedules.isEmpty
    }

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

            if hasSharedSchedules {
                FamilyView(profile: profile)
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        Text(Strings.tabFamily)
                    }
                    .tag(2)
            }

            SettingsView(profile: profile)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(Strings.tabSettings)
                }
                .tag(3)
        }
        .tint(Color(red: 0.0, green: 0.4, blue: 0.9))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, LeaveRecord.self, BonusLeave.self, CustomHoliday.self], inMemory: true)
}
