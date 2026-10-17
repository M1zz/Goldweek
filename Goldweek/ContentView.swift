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
    @Query private var anniversaries: [FamilyAnniversary]
    /// 직접 만든 휴가 종류 — 달력 색·이름이 읽는 LeaveStyleStore 에 맞춰 둔다
    @Query(sort: \CustomLeaveType.createdAt) private var customLeaveTypes: [CustomLeaveType]
    @AppStorage("hiddenHolidayDates") private var hiddenHolidayDatesRaw: String = ""
    /// 직접 입력 국가의 주말 요일 — 바뀌면 쉬는 날 판정을 다시 채운다
    @AppStorage("customWeekendDays") private var customWeekendDaysRaw = ""
    /// 파트타임 쉬는 요일·이번 주만 옮긴 날 — 바뀌면 쉬는 날 판정을 다시 채운다
    @AppStorage("partTimeDaysOff") private var partTimeDaysOffRaw = ""
    @AppStorage("partTimeSwaps") private var partTimeSwapsRaw = ""
    /// 근무 형태·교대 휴무/근무 날 — 바뀌면 쉬는 날 판정을 다시 채운다
    @AppStorage("workPattern") private var workPatternRaw = ""
    @AppStorage("shiftDaysOff") private var shiftDaysOffRaw = ""
    @AppStorage("shiftWorkDays") private var shiftWorkDaysRaw = ""
    /// 사는 곳 공휴일에도 쉬는지 — 바뀌면 쉬는 날 판정을 다시 채운다
    @AppStorage("homeHolidaysDaysOff") private var homeHolidaysDaysOff = false
    /// 공휴일 앞뒤 휴가 제한 근무일 수
    @AppStorage("holidayBlackoutDays") private var holidayBlackoutDays = 0

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    /// 사용법 시트를 이미 봤는지 — 온보딩 직후 딱 한 번 자동으로 띄운다.
    /// (그 뒤로는 설정 > 도움말에서 사용자가 원할 때만 연다)
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @State private var showingTutorial = false
    /// 업데이트 뒤 처음 열 때 한 번 — 처음 설치한 사람에게는 뜨지 않는다(WhatsNewGate)
    @State private var showingWhatsNew = false
    /// 만족 순간에 띄우는 만족도 프롬프트 (추천 등록·플랜 등록·휴가 복귀)
    @State private var reviewMoments = ReviewMoments.shared

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
                    .sheet(isPresented: $showingWhatsNew) {
                        WhatsNewView { showingWhatsNew = false }
                    }
                    .task {
                        guard WhatsNewGate.shouldPresentNow() else { return }
                        // 첫 화면이 자리 잡은 뒤에 — 실행 직후 시트가 튀어나오면 놀란다
                        try? await Task.sleep(nanoseconds: 900_000_000)
                        showingWhatsNew = true
                    }
                    .task {
                        guard !hasSeenTutorial else { return }
                        hasSeenTutorial = true
                        // 화면이 자리 잡은 뒤에 — 첫 프레임과 겹치면 놀란다
                        try? await Task.sleep(nanoseconds: 700_000_000)
                        showingTutorial = true
                    }
                    // 만족도 프롬프트 — "즐겁게 쓰고 계신가요?"를 묻고, 좋다면 App Store 리뷰로,
                    // 아쉽다면 피드백 화면으로 보낸다(불만은 별점 대신 피드백으로 흡수).
                    // 앱을 열자마자가 아니라 만족한 순간(추천·플랜 등록, 휴가 복귀)에 띄운다 — ReviewMoments.
                    .leeoReviewGate(GoldweekSpec.self, isPresented: $reviewMoments.isPresented)
                    .onAppear {
                        syncDayOffCalendar(profile: profile)
                        LeaveMigrations.splitRecommendedLeavesIfNeeded(records: leaveRecords, context: modelContext)
                        LeaveManager.updatePastLeaves(records: leaveRecords, modelContext: modelContext)
                        // 시간 단위 휴가 켜짐 여부를 고른 적 없는 기존 사용자 — 시간 기록이 있으면 켠다 (버튼이 갑자기 사라지지 않게)
                        if UserDefaults.standard.object(forKey: LeaveLength.usesHourlyLeaveKey) == nil,
                           leaveRecords.contains(where: { $0.length == .hours }) {
                            LeaveLength.usesHourlyLeave = true
                        }
                        updateWidget()
                        ReviewManager.shared.recordLaunch()
                        // 사람이 앱을 실제로 연 순간 — 실행 횟수·활동일·설치 스냅샷이 여기서 나간다.
                        UsageReportingService.reportForegroundOpen(context: modelContext)
                        reviewMoments.checkOnOpen(leaveRecords: leaveRecords)
                        if !hasCompletedOnboarding {
                            hasCompletedOnboarding = true
                        }
                        // 첫 화면이 떴다 — 몇 초 버티면 이번 실행을 성공으로 적는다(연속 크래시 보호)
                        LaunchSafety.firstScreenAppeared()
                        if !LaunchSafety.isSafeMode {
                            refreshRestRadar(profile: profile)
                            syncSharedSchedules(profile: profile)
                        }
                    }
                    .onChange(of: scenePhase) { _, newPhase in
                        if newPhase == .active {
                            LeaveManager.updatePastLeaves(records: leaveRecords, modelContext: modelContext)
                            updateWidget()
                            UsageReportingService.reportForegroundOpen(context: modelContext)
                            reviewMoments.checkOnOpen(leaveRecords: leaveRecords)
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
                    .onChange(of: customLeaveTypes.map { "\($0.id)\($0.name)\($0.colorHex)" }, initial: true) { _, _ in
                        LeaveStyleStore.shared.update(customTypes: customLeaveTypes)
                    }
                    // 캘린더 앱으로 보내기를 켰으면 휴가가 바뀔 때마다 Goldweek 캘린더를 맞춘다
                    .onChange(of: calendarSyncFingerprint, initial: true) { _, _ in
                        CalendarService.shared.scheduleSync(records: leaveRecords)
                    }
                    // 가족 기념일 알림 — 기념일이나 휴가가 바뀌면 다시 예약 (그날 휴가가 잡혀 있으면 2주 전 알림은 뺀다)
                    .onChange(of: anniversaryReminderKey, initial: true) { _, _ in
                        ShareSyncService.shared.myAnniversaries = anniversaries.map {
                            AnniversarySnapshot(id: $0.id, title: $0.displayTitle, kindRaw: $0.kindRaw, date: $0.date, isLunar: $0.isLunar)
                        }
                        AnniversaryReminders.refresh(anniversaries.map(AnniversaryReminders.Item.init),
                                                     leaves: leaveRecords.filter { $0.status != .cancelled })
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
            hasher.combine(profile.holidayRegionRaw)
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
            hasher.combine(record.lengthRaw)
            hasher.combine(record.durationMinutes)
            hasher.combine(record.customTypeId)
        }
        for kind in customLeaveTypes {
            hasher.combine(kind.id)
            hasher.combine(kind.name)
            hasher.combine(kind.colorHex)
            hasher.combine(kind.deductsFromAnnual)
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
        for item in anniversaries {
            hasher.combine(item.id)
            hasher.combine(item.name)
            hasher.combine(item.relation)
            hasher.combine(item.kindRaw)
            hasher.combine(item.date)
            hasher.combine(item.isLunar)
            hasher.combine(item.reminds)
        }
        for holiday in customHolidays {
            hasher.combine(holiday.id)
            hasher.combine(holiday.date)
            hasher.combine(holiday.name)
            hasher.combine(holiday.repeatsYearly)
        }
        return hasher.finalize()
    }

    private var anniversaryReminderKey: String {
        guard !anniversaries.isEmpty else { return "" }
        return anniversaries.map { "\($0.id)\($0.date.timeIntervalSince1970)\($0.isLunar)\($0.reminds)\($0.displayTitle)" }.sorted().joined(separator: "|")
            + "#" + leaveRecords.map { "\($0.startDate.timeIntervalSince1970)-\($0.endDate.timeIntervalSince1970)\($0.statusRaw)" }.joined(separator: ",")
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
        // 가족 기념일도 함께 올린다 (패밀리 · 함께 쉬기)
        for anniversary in anniversaries {
            hasher.combine(anniversary.id)
            hasher.combine(anniversary.date)
            hasher.combine(anniversary.isLunar)
            hasher.combine(anniversary.displayTitle)
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

    /// 캘린더 이벤트에 보이는 값만 — 바뀌면 캘린더를 다시 맞춘다
    private var calendarSyncFingerprint: String {
        leaveRecords.map { "\($0.id)\($0.startDate.timeIntervalSince1970)\($0.endDate.timeIntervalSince1970)\($0.statusRaw)\($0.typeRaw)\($0.lengthRaw ?? "")\($0.durationMinutes ?? 0)\($0.customTypeId?.uuidString ?? "")\($0.note)" }
            .joined(separator: "|")
    }

    /// 쉬는 날 판정 입력값 요약 — 바뀌면 DayOffCalendar 를 다시 채운다
    private func dayOffInputs(profile: UserProfile) -> String {
        let breaks = schoolBreaks.map { "\($0.kindRaw):\($0.startDate.timeIntervalSince1970):\($0.endDate.timeIntervalSince1970)" }.sorted()
        let customs = customHolidays.map { "\($0.date.timeIntervalSince1970)\($0.repeatsYearly ? "y" : "")" }.sorted()
        let anniversaryKeys = anniversaries.map { "\($0.date.timeIntervalSince1970)\($0.isLunar ? "L" : "")\($0.displayTitle)" }.sorted()
        return "\(profile.countryRaw)|\(customWeekendDaysRaw)|\(partTimeDaysOffRaw)|\(partTimeSwapsRaw)|\(workPatternRaw)|\(shiftDaysOffRaw)|\(shiftWorkDaysRaw)|\(profile.holidayRegionRaw)|\(profile.homeCountryRaw)|\(profile.homeRegionRaw)|\(homeHolidaysDaysOff)|\(holidayBlackoutDays)|\(hiddenHolidayDatesRaw)|\(customs.joined(separator: ","))|\(breaks.joined(separator: ","))|\(anniversaryKeys.joined(separator: ","))"
    }

    private func syncDayOffCalendar(profile: UserProfile) {
        let hidden = Set(hiddenHolidayDatesRaw.split(separator: ",").map(String.init).filter { !$0.isEmpty })
        // 백업 복원·타임머신처럼 프로필이 통째로 바뀐 경우에도 공휴일 계산이 같은 지역을 쓰도록 맞춘다
        HolidayService.selectedRegionCode = profile.holidayRegion?.code ?? ""
        HolidayService.homeCountryCode = profile.homeCountry?.rawValue ?? ""
        HolidayService.homeRegionCode = profile.homeRegion?.code ?? ""
        DayOffCalendar.shared.update(country: profile.country, customHolidays: customHolidays,
                                     hiddenDates: hidden, breaks: schoolBreaks, anniversaries: anniversaries)
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
        let cal = Calendar.app
        let today = cal.startOfDay(for: Date())
        let year = cal.component(.year, from: today)

        // 가용 연차
        let committed = leaveRecords
            .filter { ($0.status == .used || $0.status == .planned) && $0.deductsFromAnnualLeave }
            .reduce(0.0) { $0 + $1.effectiveLeaveDays }
        let bonus = bonusLeaves
            .filter { !$0.isUsed && ($0.expirationDate == nil || $0.expirationDate! > Date()) }
            .reduce(0.0) { $0 + $1.remainingDays }
        // 지난해에서 넘어온 연차도 쓸 수 있는 양에 든다
        let carry = LeaveUsageCalculator.carryOverUsable(year: LeaveUsageCalculator.fiscalYear(for: today, startMonth: profile.yearStartMonth),
                                                         on: today, records: leaveRecords, annualGrant: profile.totalAnnualLeave,
                                                         startMonth: profile.yearStartMonth)
        let available = Int((max(0, profile.totalAnnualLeave + carry - committed) + bonus).rounded(.down))
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

        // 직장 규정상 공휴일 앞뒤로 못 쉬는 날도 제외
        excluded.formUnion(DayOffCalendar.shared.blockedDates(in: year))

        let plan = LeavePlanner.optimalPlan(
            year: year,
            availableLeaveDays: available,
            holidays: holidays,
            excludedDates: excluded,
            makeupWorkdays: HolidayService.makeupWorkdays(for: year, country: profile.country),
            weekendDays: HolidayService.weekendDays(for: profile.country),
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
    /// 스크린샷 모드에서 페이월을 열어 둔다 (앱 내 구입 심사용 화면)
    @State private var showingScreenshotPaywall = ScreenshotMode.paywallProductID != nil
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // 공유받은 일정이 있으면 가족 탭 표시 (@Observable — body에서 읽으면 자동 갱신)
    private var hasSharedSchedules: Bool {
        !ShareSyncService.shared.sharedSchedules.isEmpty
    }

    var body: some View {
        // Mac 처럼 넓으면 탭 대신 "캘린더 + 현황 대시보드" 두 칸 화면
        // (아이폰 Pro Max 가로도 regular 라서 기기 종류까지 본다)
        if LayoutMode.isLargeScreen(horizontalSizeClass) {
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

            // 아이폰 듀오를 펴면 왼쪽(세로면 아래)에 이 탭, 오른쪽(위)에 현황이 선다 (→ Views/FoldPanes.swift).
            // 접혀 있거나 보통 아이폰이면 `FoldTab` 은 이 탭만 그린다 — 지금 화면 그대로.
            FoldTab(profile: profile) { CalendarView(profile: profile) }
                .tabItem {
                    Image(systemName: "calendar")
                    Text(Strings.tabCalendar)
                }
                .tag(1)

            if hasSharedSchedules {
                FoldTab { FamilyView(profile: profile) } result: { FoldFamilyResult(profile: profile) }
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        Text(Strings.tabFamily)
                    }
                    .tag(2)
            }

            FoldTab(profile: profile) { SettingsView(profile: profile) }
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(Strings.tabSettings)
                }
                .tag(3)
        }
        .tint(Color(red: 0.0, green: 0.4, blue: 0.9))
        // 펴면 시스템 탭바 대신 고르는 쪽 판 바닥에 막대가 선다. 현황은 늘 오른쪽 판에 있다.
        .foldTabBar(items: FoldTabs.items(showsFamily: hasSharedSchedules),
                    selected: selectedTab == 0 ? 1 : selectedTab) { selectedTab = $0 }
        .foldHomeTabRedirect(selectedTab: $selectedTab)
        // 창 크기로 접힘을 재서 아래로 흘린다. 시트 · 알림창도 접힌 선을 비킨다 (LeeoKit Fold).
        .foldAware()
        .sheet(isPresented: $showingScreenshotPaywall) { PaywallView() }
    }
}

// MARK: - 넓은 화면 (Mac)

enum LayoutMode {
    /// 두 칸 화면을 쓸지 — 아이폰이 아니고(현재는 Mac) 가로 폭이 넉넉할 때
    static func isLargeScreen(_ sizeClass: UserInterfaceSizeClass?) -> Bool {
        UIDevice.current.userInterfaceIdiom != .phone && sizeClass == .regular
    }
}

/// 캘린더를 왼쪽에 크게, 오른쪽에 현황 대시보드.
/// 아이폰 화면을 가로로 늘리면 카드가 화면 끝까지 퍼져 허전하다 — 넓은 화면에선 한눈에 달력과 현황을 같이 본다.
struct WideMainView: View {
    @Bindable var profile: UserProfile
    let hasSharedSchedules: Bool

    /// 두 칸 화면엔 설정 탭이 없다 — 스크린샷 모드에서 설정(탭 3)을 찍을 땐 시트로 열어 둔다
    @State private var showingSettings = ScreenshotMode.initialTab == 3
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
            // 기본 최대 폭이 좁게 잡혀 창을 넓힐 수 없다 — 큰 모니터에서도 늘릴 수 있게 푼다
            scene.sizeRestrictions?.maximumSize = CGSize(width: 10_000, height: 10_000)
        }
        #endif
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, LeaveRecord.self, BonusLeave.self, CustomHoliday.self, SchoolBreak.self, FamilyAnniversary.self], inMemory: true)
}
