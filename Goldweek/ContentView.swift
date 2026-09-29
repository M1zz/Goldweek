//
//  ContentView.swift
//  Goldweek
//
//  메인 탭 뷰
//

import SwiftUI
import SwiftData
import WidgetKit
import LeeoKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var profiles: [UserProfile]
    @Query private var leaveRecords: [LeaveRecord]
    @Query private var bonusLeaves: [BonusLeave]
    @Query private var customHolidays: [CustomHoliday]
    @Query private var schoolBreaks: [SchoolBreak]
    @AppStorage("hiddenHolidayDates") private var hiddenHolidayDatesRaw: String = ""

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    /// 사용법 시트를 이미 봤는지 — 온보딩 직후 딱 한 번 자동으로 띄운다.
    /// (그 뒤로는 설정 > 도움말에서 사용자가 원할 때만 연다)
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @State private var showingTutorial = false

    var currentProfile: UserProfile? {
        profiles.first
    }

    var body: some View {
        let _ = LanguageManager.shared.currentLanguage
        Group {
            if let profile = currentProfile {
                MainTabView(profile: profile)
                    // 온보딩을 막 마쳤다면 "어디를 눌러야 하는지"를 한 번 보여준다.
                    // 온보딩에 더 끼워 넣지 않는 이유: 설득과 사용법은 읽는 마음가짐이 다르다.
                    .sheet(isPresented: $showingTutorial) {
                        TutorialView()
                    }
                    .task {
                        guard !hasSeenTutorial else { return }
                        hasSeenTutorial = true
                        // 화면이 자리 잡은 뒤에 — 첫 프레임과 겹치면 놀란다
                        try? await Task.sleep(nanoseconds: 700_000_000)
                        showingTutorial = true
                    }
                    // 만족도 프롬프트 — 조건이 맞으면 "즐겁게 쓰고 계신가요?"를 묻고,
                    // 좋다면 App Store 리뷰로, 아쉽다면 피드백 화면으로 보낸다.
                    // 불만인 사람을 별점 대신 피드백으로 흡수하는 게 이 프롬프트의 목적이다.
                    .leeoSatisfactionCheck(GoldweekSpec.self)
                    .onAppear {
                        syncDayOffCalendar(profile: profile)
                        LeaveMigrations.splitRecommendedLeavesIfNeeded(records: leaveRecords, context: modelContext)
                        LeaveManager.updatePastLeaves(records: leaveRecords, modelContext: modelContext)
                        updateWidget()
                        ReviewManager.shared.recordLaunch()
                        // 사람이 앱을 실제로 연 순간 — 실행 횟수·활동일·설치 스냅샷이 여기서 나간다.
                        UsageReportingService.reportForegroundOpen(context: modelContext)
                        if !hasCompletedOnboarding {
                            hasCompletedOnboarding = true
                        }
                        refreshRestRadar(profile: profile)
                        syncSharedSchedules(profile: profile)
                    }
                    .onChange(of: scenePhase) { _, newPhase in
                        if newPhase == .active {
                            LeaveManager.updatePastLeaves(records: leaveRecords, modelContext: modelContext)
                            updateWidget()
                            UsageReportingService.reportForegroundOpen(context: modelContext)
                            refreshRestRadar(profile: profile)
                            syncSharedSchedules(profile: profile)
                        } else if newPhase == .background {
                            // 앱을 떠나는 순간의 상태를 타임머신에 보존 (내용 같으면 스킵됨)
                            TimeMachineService.shared.captureNow(from: modelContext, reason: .background)
                        }
                    }
                    // 쉬는 날(국가·내 공휴일·숨김·방학)이 바뀌면 연차 차감 계산 기준도 바꾼다
                    .onChange(of: dayOffInputs(profile: profile)) { _, _ in
                        syncDayOffCalendar(profile: profile)
                        updateWidget()
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

        // 기기 언어를 그대로 따른다 — 지원하지 않는 언어면 영어
        AppLanguage.current = AppLanguage.fromDeviceLocale()

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
        for item in schoolBreaks {
            hasher.combine(item.id)
            hasher.combine(item.name)
            hasher.combine(item.startDate)
            hasher.combine(item.endDate)
            hasher.combine(item.kindRaw)
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

    /// 쉬는 날 판정 입력값 요약 — 바뀌면 DayOffCalendar 를 다시 채운다
    private func dayOffInputs(profile: UserProfile) -> String {
        let breaks = schoolBreaks.map { "\($0.kindRaw):\($0.startDate.timeIntervalSince1970):\($0.endDate.timeIntervalSince1970)" }.sorted()
        let customs = customHolidays.map { "\($0.date.timeIntervalSince1970)" }.sorted()
        return "\(profile.countryRaw)|\(hiddenHolidayDatesRaw)|\(customs.joined(separator: ","))|\(breaks.joined(separator: ","))"
    }

    private func syncDayOffCalendar(profile: UserProfile) {
        let hidden = Set(hiddenHolidayDatesRaw.split(separator: ",").map(String.init).filter { !$0.isEmpty })
        DayOffCalendar.shared.update(country: profile.country, customHolidays: customHolidays,
                                     hiddenDates: hidden, breaks: schoolBreaks)
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
    @State private var selectedTab = ScreenshotMode.initialTab
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // 공유받은 일정이 있으면 가족 탭 표시 (@Observable — body에서 읽으면 자동 갱신)
    private var hasSharedSchedules: Bool {
        !ShareSyncService.shared.sharedSchedules.isEmpty
    }

    var body: some View {
        // iPad·Mac 처럼 넓으면 탭 대신 "캘린더 + 현황 대시보드" 두 칸 화면
        if horizontalSizeClass == .regular {
            WideMainView(profile: profile, hasSharedSchedules: hasSharedSchedules)
        } else {
            compactTabs
        }
    }

    private var compactTabs: some View {
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

// MARK: - 넓은 화면 (iPad·Mac)

/// 캘린더를 왼쪽에 크게, 오른쪽에 현황 대시보드.
/// 아이폰 화면을 가로로 늘리면 카드가 화면 끝까지 퍼져 허전하다 — 넓은 화면에선 한눈에 달력과 현황을 같이 본다.
struct WideMainView: View {
    @Bindable var profile: UserProfile
    let hasSharedSchedules: Bool

    @State private var showingSettings = false
    @State private var showingFamily = false

    /// 오른쪽 대시보드 폭 — 현황 카드가 아이폰 폭과 비슷할 때 가장 읽기 좋다
    private let dashboardWidth: CGFloat = 400

    var body: some View {
        HStack(spacing: 0) {
            CalendarView(profile: profile)
                .frame(minWidth: 460, maxWidth: .infinity)

            Divider()
                .ignoresSafeArea()

            HomeView(
                profile: profile,
                onOpenSettings: { showingSettings = true },
                onOpenFamily: hasSharedSchedules ? { showingFamily = true } : nil
            )
            .frame(width: dashboardWidth)
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(profile: profile, showsCloseButton: true)
                .frame(minWidth: 540, minHeight: 640)
        }
        .sheet(isPresented: $showingFamily) {
            FamilyView(profile: profile, showsCloseButton: true)
                .frame(minWidth: 540, minHeight: 640)
        }
        .onAppear(perform: applyMacWindowMinimumSize)
    }

    /// Mac 창을 너무 줄이면 두 칸이 찌그러진다 — 최소 크기를 건다
    private func applyMacWindowMinimumSize() {
        #if targetEnvironment(macCatalyst)
        for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
            scene.sizeRestrictions?.minimumSize = CGSize(width: 960, height: 680)
        }
        #endif
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, LeaveRecord.self, BonusLeave.self, CustomHoliday.self, SchoolBreak.self], inMemory: true)
}
