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
                        updateWidget()
                        ReviewManager.shared.recordLaunch()
                        if !hasCompletedOnboarding {
                            hasCompletedOnboarding = true
                        }
                        refreshRestRadar(profile: profile)
                    }
                    .onChange(of: scenePhase) { _, newPhase in
                        if newPhase == .active {
                            updateWidget()
                            refreshRestRadar(profile: profile)
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
        try? modelContext.save()
    }

    private func updateWidget() {
        guard let profile = currentProfile else { return }
        WidgetService.shared.updateWidgetData(
            profile: profile,
            bonusLeaves: bonusLeaves,
            leaveRecords: leaveRecords
        )
    }

    // MARK: - Rest Radar (번아웃 평가 + 선제 알림)

    /// 휴식 이력으로 번아웃을 평가하고, overdue 이상이면 가까운 저비용 휴식 창과 함께 알림 예약.
    private func refreshRestRadar(profile: UserProfile) {
        let blocks = BurnoutEngine.restBlocks(from: leaveRecords)
        let assessment = BurnoutEngine().assess(
            breaks: blocks, asOf: Date(),
            subjectiveFatigue: FatigueCheckIn.recentValue
        )
        let window = (assessment.level >= .overdue)
            ? bestRestWindow(profile: profile) : nil
        Task {
            await NotificationService.refreshRestRadar(assessment: assessment, window: window)
        }
    }

    /// 오늘 이후 가장 가까운 "연차 1~N일로 만드는 연휴" 창. LeavePlanner 재사용.
    private func bestRestWindow(profile: UserProfile) -> RestWindowHint? {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let year = cal.component(.year, from: today)

        // 가용 연차
        let committed = leaveRecords
            .filter { ($0.status == .used || $0.status == .planned) && $0.deductsFromAnnualLeave }
            .reduce(0.0) { $0 + $1.effectiveLeaveDays }
        let bonus = bonusLeaves
            .filter { !$0.isUsed && ($0.expirationDate == nil || $0.expirationDate! > Date()) }
            .reduce(0.0) { $0 + $1.remainingDays }
        let available = Int((max(0, profile.totalAnnualLeave - committed) + bonus).rounded(.down))
        guard available >= 1 else { return nil }

        let holidays = HolidayService().getHolidays(for: year, country: profile.country).map { $0.date }

        // 이미 잡힌 휴가는 제외
        var excluded: Set<Date> = []
        for r in leaveRecords where r.status != .cancelled {
            var d = cal.startOfDay(for: r.startDate)
            let end = cal.startOfDay(for: r.endDate)
            while d <= end {
                excluded.insert(d)
                guard let n = cal.date(byAdding: .day, value: 1, to: d) else { break }
                d = n
            }
        }

        let plan = LeavePlanner.optimalPlan(
            year: year,
            availableLeaveDays: available,
            holidays: holidays,
            excludedDates: excluded,
            earliestDate: today
        )

        // 오늘 이후 시작하는 가장 가까운 연휴
        guard let next = plan.breaks
            .filter({ $0.startDate >= today && $0.leaveCount >= 1 })
            .min(by: { $0.startDate < $1.startDate }) else { return nil }

        // 연휴 범위 내 대표 공휴일 이름 (있으면)
        let holidaySvc = HolidayService().getHolidays(for: year, country: profile.country)
        let name = holidaySvc.first(where: { $0.date >= next.startDate && $0.date <= next.endDate && !$0.isSubstitute })?.name ?? ""

        return RestWindowHint(
            startDate: next.startDate,
            leaveDaysNeeded: next.leaveCount,
            totalDaysOff: next.totalDays,
            holidayName: name
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
