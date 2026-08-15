//
//  SettingsView.swift
//  Goldweek
//
//  설정 화면
//

import SwiftUI
import SwiftData
import StoreKit
import TipKit
import LeeoKit

struct SettingsView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var modelContext
    @Environment(\.requestReview) private var requestReview
    @Query private var leaveRecords: [LeaveRecord]
    @Query(sort: \BonusLeave.grantedDate, order: .reverse) private var bonusLeaves: [BonusLeave]

    /// 개발자 모드 — 지원 섹션의 버전 행을 7번 탭하면 켜진다(키는 LeeoKit과 공유).
    /// 켜지면 접수된 피드백(인박스)·사용 통계·안정성 화면이 보인다.
    @AppStorage("dev.masterMode") private var masterModeEnabled = false

    /// "2.1.2 (1)" — 지원 섹션의 버전 행 표시용
    private var appVersionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "\(version) (\(build))"
    }

    @State private var showingPreferences = false
    @State private var showingResetAlert = false
    @State private var showingBonusLeaveSheet = false
    @State private var editingName = false
    @State private var tempName = ""

    // 보너스 연차 추가용 상태
    @State private var bonusDays: Double = 1.0
    @State private var bonusType: BonusLeaveType = .compensatory
    @State private var bonusReason = ""
    @State private var hasExpiration = false
    @State private var expirationDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())!

    // 백업 관련 상태
    @State private var isBackingUp = false
    @State private var isRestoring = false
    @State private var lastBackupDate: Date?
    @State private var showingBackupAlert = false
    @State private var backupAlertMessage = ""
    @State private var showingRestoreConfirm = false
    @State private var showingPaywall = false
    @State private var editingBonus: BonusLeave?
    @State private var pendingBonusDeleteOffsets: IndexSet?
    @State private var showingBonusDeleteConfirm = false
    @State private var restoreResultMessage = ""
    @State private var showingRestoreResult = false
    @State private var showingCalendarImport = false
    @State private var showingPhotoImport = false
    @AppStorage("autoDetectLeavesEnabled") private var autoDetectEnabled = true
    /// 홈 "다가오는 휴가" 카드에 공휴일도 함께 보여줄지 (HomeView와 같은 키를 공유)
    @AppStorage("showHolidaysInUpcoming") private var showHolidaysInUpcoming = true

    // 홈 "연차 현황"에 보너스 연차를 합산할지 여부 (홈 화면에서 이 설정을 따른다)
    @AppStorage("includeBonusInStatus") private var includeBonusInStatus: Bool = true
    @AppStorage("rest_radar_enabled") private var restRadarEnabled: Bool = true

    // 국가 & 언어
    @State private var selectedCountry: Country
    @State private var selectedLanguage: AppLanguage

    private let recommendationEngine = RecommendationEngine()

    init(profile: UserProfile) {
        self.profile = profile
        _selectedCountry = State(initialValue: profile.country)
        _selectedLanguage = State(initialValue: AppLanguage.current)
    }

    /// 프로필 편집을 즉시 저장한다. 실패해도 화면을 막지 않고 로그만 남긴다
    /// (다음 자동 저장이나 타임머신 스냅샷이 받아 준다).
    private func persistProfile() {
        do {
            try modelContext.save()
        } catch {
            logError("프로필 저장 실패: \(error.localizedDescription)", category: .data)
        }
    }

    var usedLeaveCount: Int {
        leaveRecords.filter { $0.status == .used }.count
    }

    var plannedLeaveCount: Int {
        leaveRecords.filter { $0.status == .planned }.count
    }

    /// 현재 회계연도 시작일 (yearStartMonth 기준) — LeaveStatusCard와 동일 계산
    var annualYearStart: Date {
        let cal = Calendar.current
        let now = Date()
        let year = cal.component(.year, from: now)
        let month = cal.component(.month, from: now)
        let sm = profile.yearStartMonth
        let startYear = month >= sm ? year : year - 1
        return cal.date(from: DateComponents(year: startYear, month: sm, day: 1)) ?? now
    }

    var annualYearEnd: Date {
        Calendar.current.date(byAdding: DateComponents(year: 1, second: -1), to: annualYearStart) ?? annualYearStart
    }

    /// 계산은 `LeaveUsageCalculator` 한 곳에서 — 화면마다 세면 숫자가 어긋난다.
    var committedLeave: Double {
        LeaveUsageCalculator.currentSummary(records: Array(leaveRecords),
                                            bonuses: Array(bonusLeaves),
                                            startMonth: profile.yearStartMonth).annualCommitted
    }

    var activeBonusLeave: Double {
        let now = Date()
        return bonusLeaves
            .filter { !$0.isUsed && ($0.expirationDate == nil || $0.expirationDate! > now) }
            .reduce(0) { $0 + $1.remainingDays }
    }

    /// 보너스 합산 여부는 홈 카드와 동일하게 includeBonusInStatus 토글을 따른다
    var totalAvailableLeave: Double {
        let base = max(0, profile.totalAnnualLeave - committedLeave)
        return includeBonusInStatus ? base + activeBonusLeave : base
    }

    /// 부여된 보너스 전체 (사용률 분모용 — LeaveStatusCard와 동일 계산)
    var grantedBonusLeave: Double {
        bonusLeaves.reduce(0) { $0 + $1.days }
    }

    /// 사용된 보너스 (사용률 분자용)
    var usedBonusLeave: Double {
        bonusLeaves.reduce(0) { $0 + $1.usedDays }
    }

    /// 사용률 — 토글 ON이면 보너스를 분모(부여량)와 분자(사용량)에 모두 반영
    var usageRateText: String {
        let total = includeBonusInStatus
            ? profile.totalAnnualLeave + grantedBonusLeave
            : profile.totalAnnualLeave
        guard total > 0 else { return "0%" }
        let used = includeBonusInStatus
            ? committedLeave + usedBonusLeave
            : committedLeave
        return "\(Int((used / total) * 100))%"
    }

    var body: some View {
        NavigationStack {
            Form {
                // 프로필 섹션
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 70, height: 70)

                            Text(String(profile.displayName.prefix(1)))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 4) {
                            if editingName {
                                TextField(Strings.name, text: $tempName)
                                    .textFieldStyle(.roundedBorder)
                                    .onSubmit {
                                        profile.name = tempName
                                        editingName = false
                                    }
                            } else {
                                Text(profile.displayName)
                                    .font(.title2.bold())
                            }

                            Text(Strings.joinDate(profile.createdAt.appFormatted()))
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button(action: {
                            if editingName {
                                profile.name = tempName
                            } else {
                                tempName = profile.displayName
                            }
                            editingName.toggle()
                        }) {
                            Image(systemName: editingName ? "checkmark.circle.fill" : "pencil.circle.fill")
                                .font(.title2)
                                .foregroundStyle(editingName ? .green : .blue)
                        }
                        .accessibilityLabel(Text(editingName ? Strings.save : Strings.editName))
                    }
                    .padding(.vertical, 8)
                }

                // 국가 및 언어
                Section(Strings.countryAndLanguage) {
                    Picker(Strings.country, selection: $selectedCountry) {
                        ForEach(Country.allCases) { country in
                            Text("\(country.flag) \(country.displayName)").tag(country)
                        }
                    }
                    .onChange(of: selectedCountry) { _, newValue in
                        profile.country = newValue
                        recommendationEngine.invalidateCache()
                    }

                    Picker(Strings.language, selection: $selectedLanguage) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text("\(lang.flag) \(lang.displayName)").tag(lang)
                        }
                    }
                    .onChange(of: selectedLanguage) { _, newValue in
                        AppLanguage.current = newValue
                        recommendationEngine.invalidateCache()
                    }
                }

                // 공휴일 관리
                Section {
                    NavigationLink(destination: HolidayManagementView(country: profile.country)) {
                        HStack(spacing: 12) {
                            Image(systemName: "calendar.badge.plus")
                                .foregroundStyle(.orange)
                                .frame(width: 28)
                                .voDecorative()
                            VStack(alignment: .leading, spacing: 2) {
                                Text(Strings.holidayMgmtTitle)
                                Text(Strings.holidayMgmtSubtitle)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }

                    // 홈의 "다가오는 휴가" 카드에 공휴일을 섞을지 — 내 휴가만 보고 싶은 사람을 위한 스위치
                    Toggle(isOn: $showHolidaysInUpcoming) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(Strings.showHolidaysInUpcomingTitle)
                            Text(Strings.showHolidaysInUpcomingDescription)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.orange)
                }

                // 일정 공유 (가족·친구와 실시간 공유)
                Section {
                    NavigationLink(destination: ShareScheduleView(profile: profile)
                        .onAppear { AppTips.familyShare.invalidate(reason: .actionPerformed) }
                    ) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.2.fill")
                                .foregroundStyle(.blue)
                                .frame(width: 28)
                                .voDecorative()
                            VStack(alignment: .leading, spacing: 2) {
                                Text(Strings.shareScheduleTitle)
                                Text(Strings.shareScheduleSubtitle)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }
                }

                // 사용자 유형
                Section(Strings.userTypeSection) {
                    Picker(Strings.userTypeMode, selection: $profile.userType) {
                        ForEach(UserType.allCases) { type in
                            Label(type.displayName, systemImage: type.icon).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)

                    if profile.userType == .leisure {
                        Text(Strings.userTypeLeisureDesc)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                // 연차/휴가 설정
                let isLeisure = profile.userType == .leisure
                Section(isLeisure ? Strings.leisureVacationSettings : Strings.annualLeaveSettings) {
                    // 총 사용 가능 연차 표시 — 직장인 모드만
                    if !isLeisure {
                        HStack(alignment: .center) {
                            Text(Strings.availableLeaveLabel)
                                .font(.body)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(Strings.dayCount(totalAvailableLeave))")
                                    .font(.system(.largeTitle, weight: .bold))
                                    .foregroundStyle(includeBonusInStatus && activeBonusLeave > 0 ? AppTheme.Colors.bonus : .green)
                                if includeBonusInStatus && activeBonusLeave > 0 {
                                    Text(Strings.baseAndBonus(
                                        base: formatLeave(max(0, profile.totalAnnualLeave - committedLeave)),
                                        bonus: formatLeave(activeBonusLeave)
                                    ))
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .voCard("\(Strings.availableLeaveLabel) \(Strings.dayCount(totalAvailableLeave))")
                    }

                    HStack {
                        Text(isLeisure ? Strings.leisureAnnualGoal : Strings.totalLeave)
                        Spacer()
                        if isLeisure {
                            Stepper(
                                profile.totalAnnualLeave == 0
                                    ? Strings.leisureUnlimited
                                    : "\(Strings.dayCount(Double(profile.totalAnnualLeave)))",
                                value: $profile.totalAnnualLeave,
                                in: 0...365,
                                step: 1
                            )
                        } else {
                            Stepper(
                                "\(Strings.dayCount(Double(profile.totalAnnualLeave)))",
                                value: $profile.totalAnnualLeave,
                                in: max(committedLeave, 1)...365,
                                step: 1
                            )
                        }
                    }

                    HStack {
                        Text(isLeisure ? Strings.leisurePlannedLeave : Strings.usedLeave)
                        Spacer()
                        Text("\(Strings.dayCount(committedLeave))")
                            .foregroundStyle(.secondary)
                    }

                    Picker(isLeisure ? Strings.leisureYearStartMonth : Strings.yearStartMonth, selection: $profile.yearStartMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(Strings.monthShort(month)).tag(month)
                        }
                    }
                }

                // 보너스 연차 관리 (Pro 전용, 직장인 모드만)
                if !isLeisure { Section {
                    // 홈 "연차 현황"에 보너스 합산 여부 (예전엔 홈 화면 토글이었음)
                    Toggle(isOn: $includeBonusInStatus) {
                        Text(Strings.includeBonus)
                    }
                    .tint(AppTheme.Colors.bonus)
                    .accessibilityHint(Text(Strings.includeBonusHint))

                    Button {
                        if ProManager.shared.isPro {
                            showingBonusLeaveSheet = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: ProManager.shared.isPro ? "plus.circle.fill" : "crown.fill")
                                .foregroundStyle(ProManager.shared.isPro ? AppTheme.Colors.bonus : .yellow)
                                .voDecorative()
                            Text(Strings.addBonusLeave)
                                .foregroundStyle(ProManager.shared.isPro ? .primary : .secondary)
                            Spacer()
                            if ProManager.shared.isPro {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                                    .font(.body)
                                    .voDecorative()
                            } else {
                                Text("Pro")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.yellow)
                                    .foregroundColor(.black)
                                    .cornerRadius(4)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }

                    // 활성 보너스 연차 목록
                    ForEach(bonusLeaves.filter { !$0.isUsed }) { bonus in
                        HStack {
                            Image(systemName: bonus.type.icon)
                                .foregroundStyle(AppTheme.Colors.bonus)
                                .frame(width: 24)
                                .voDecorative()

                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(Strings.bonusLeaveTypeName(bonus.type))
                                        .font(.body)
                                    // 홈 카드와 같은 뜻의 분수(사용/부여) — 화면마다 분모·분자가 다르면 헷갈린다.
                                    // 문장형 "3일 중 1.5일 사용"은 아래 VoiceOver 라벨이 대신 읽어 준다.
                                    Text(Strings.bonusUsedFraction(
                                        used: formatLeave(bonus.usedDays),
                                        granted: formatLeave(bonus.days)
                                    ))
                                    .font(.body)
                                    .foregroundStyle(AppTheme.Colors.bonus)
                                }
                                if !bonus.reason.isEmpty {
                                    Text(bonus.reason)
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            if let expiration = bonus.expirationDate {
                                Text(expiration, format: .dateTime.month().day())
                                    .font(.body)
                                    .foregroundStyle(expiration < Date() ? .red : .secondary)
                            }

                            Image(systemName: "pencil.circle")
                                .foregroundStyle(.secondary)
                                .font(.body)
                                .voDecorative()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { editingBonus = bonus }
                        .voButton(bonusRowAccessibilityLabel(bonus), hint: Strings.editLeaveHint)
                    }
                    .onDelete(perform: deleteBonusLeave)
                } header: {
                    Text(Strings.bonusLeave)
                } footer: {
                    Text(Strings.bonusLeaveFooter)
                }
                } // end if !isLeisure

                // 휴가 스타일
                Section(Strings.vacationStyle) {
                    Button(action: { showingPreferences = true }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(.blue)
                                .voDecorative()
                            Text(Strings.preferencesSettings)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .voDecorative()
                        }
                    }
                    .foregroundStyle(.primary)

                    // 현재 설정 요약
                    VStack(alignment: .leading, spacing: 8) {
                        PreferenceSummaryRow(
                            icon: "clock",
                            title: Strings.preferredDuration,
                            value: Strings.durationName(profile.preferredDuration)
                        )

                        if !profile.preferredSeasons.isEmpty {
                            PreferenceSummaryRow(
                                icon: "leaf",
                                title: Strings.preferredSeason,
                                value: profile.preferredSeasons.map { $0.icon }.joined(separator: " "),
                                accessibilityValue: profile.preferredSeasons.map { Strings.seasonName($0) }.joined(separator: ", ")
                            )
                        }

                        if !profile.priorityActivities.isEmpty {
                            PreferenceSummaryRow(
                                icon: "star",
                                title: Strings.preferredActivity,
                                value: profile.priorityActivities.map { $0.icon }.joined(separator: " "),
                                accessibilityValue: profile.priorityActivities.map { Strings.activityName($0) }.joined(separator: ", ")
                            )
                        }
                    }
                    .font(.body)
                    .foregroundStyle(.secondary)
                }

                // 휴식 알림 (Rest Radar)
                if !isLeisure {
                    Section {
                        Toggle(isOn: $restRadarEnabled) {
                            Label(Strings.restRadarToggle, systemImage: "bell.badge")
                        }
                        .tint(AppTheme.Colors.brand)
                        .onChange(of: restRadarEnabled) { _, enabled in
                            if !enabled { NotificationService.cancelPending() }
                        }
                    } header: {
                        Text(Strings.restRadarSection)
                    } footer: {
                        Text(Strings.restRadarFooter)
                    }
                }

                // 통계
                Section(Strings.usageStats) {
                    StatRow(icon: "checkmark.circle.fill", iconColor: .green, title: Strings.completed, value: Strings.itemCount(usedLeaveCount))
                    StatRow(icon: "calendar.badge.clock", iconColor: .blue, title: Strings.plannedLeave, value: Strings.itemCount(plannedLeaveCount))
                    StatRow(icon: "chart.pie.fill", iconColor: .orange, title: Strings.leaveUsageRate, value: usageRateText)
                }

                // 데이터 관리
                Section {
                    // 사진에서 휴가 가져오기 (OCR)
                    Button {
                        showingPhotoImport = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.viewfinder")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(Strings.importFromPhoto)
                                    .foregroundStyle(.primary)
                                Text(Strings.importFromPhotoDescription)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.body)
                        }
                        .accessibilityElement(children: .combine)
                    }

                    // 캘린더에서 휴가 가져오기 (제안 후 확인)
                    Button {
                        showingCalendarImport = true
                    } label: {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .foregroundStyle(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(Strings.importFromCalendar)
                                    .foregroundStyle(.primary)
                                Text(Strings.importFromCalendarDescription)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.body)
                        }
                        .accessibilityElement(children: .combine)
                    }

                    // 캘린더 자동 감지 (Pro)
                    if ProManager.shared.isPro {
                        Toggle(isOn: $autoDetectEnabled) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(Strings.autoDetectSettingTitle)
                                Text(Strings.autoDetectSettingDescription)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.green)
                    } else {
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(Strings.autoDetectSettingTitle)
                                        .foregroundStyle(.primary)
                                    Text(Strings.autoDetectSettingDescription)
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("Pro")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.yellow)
                                    .foregroundColor(.black)
                                    .cornerRadius(4)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }

                    // 타임머신 (시점별 스냅샷 복원)
                    NavigationLink {
                        TimeMachineView()
                    } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(.purple)
                            Text(Strings.timeMachine)
                                .foregroundStyle(.primary)
                        }
                    }
                    .popoverTip(AppTips.timeMachine)

                    // iCloud 백업
                    Button {
                        Task { await backupToICloud() }
                    } label: {
                        HStack {
                            Image(systemName: "icloud.and.arrow.up")
                                .foregroundStyle(.blue)
                            Text(Strings.backupToICloud)
                                .foregroundStyle(.primary)
                            Spacer()
                            if isBackingUp {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isBackingUp)

                    // iCloud 복원
                    Button {
                        Task { await restoreFromICloud() }
                    } label: {
                        HStack {
                            Image(systemName: "icloud.and.arrow.down")
                                .foregroundStyle(.blue)
                            Text(Strings.restoreFromICloud)
                                .foregroundStyle(.primary)
                            Spacer()
                            if isRestoring {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isRestoring)

                    // 초기화
                    Button(role: .destructive, action: { showingResetAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text(Strings.resetData)
                        }
                    }
                } header: {
                    Text(Strings.dataManagement)
                } footer: {
                    if let lastBackup = lastBackupDate {
                        Text(Strings.lastBackup(lastBackup.appFormatted(time: .short)))
                    }
                }

                // 앱 정보
                Section(Strings.appInfo) {
                        // 구매 복원
                    if !ProManager.shared.isPro {
                        Button {
                            Task {
                                let result = await ProManager.shared.restorePurchases()
                                switch result {
                                case .restored:
                                    restoreResultMessage = Strings.restorePurchasesSuccess
                                    HapticFeedback.success()
                                case .nothingToRestore:
                                    restoreResultMessage = Strings.restorePurchasesNone
                                case .failed(let reason):
                                    restoreResultMessage = Strings.restorePurchasesFailed(reason)
                                    HapticFeedback.error()
                                }
                                showingRestoreResult = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .foregroundStyle(.blue)
                                Text(Strings.restorePurchase)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if ProManager.shared.isLoading {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(ProManager.shared.isLoading)
                    }

                    // 앱 공유하기
                    ShareLink(
                        item: URL(string: "https://apps.apple.com/app/id6739899592")!,
                        subject: Text(Strings.shareSubject),
                        message: Text(Strings.shareMessage)
                    ) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(.blue)
                            Text(Strings.shareApp)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.body)
                        }
                    }

                    HStack {
                        Text(Strings.developer)
                        Spacer()
                        Text("Goldweek Team")
                            .foregroundStyle(.secondary)
                    }
                }

                // 지원 — 피드백 보내기·리뷰 남기기·법적 링크·버전.
                // 버전 행을 7번 탭하면 개발자 모드가 켜지고, 접수된 피드백·사용 통계·안정성이 보인다.
                //
                // ⚠️ LeeoKit의 `LeeoSupportSection`을 쓰지 않고 행을 직접 그린다 —
                //    그쪽 문구는 **기기 언어**를 따라서, 기기가 한국어인 사용자가 앱만 영어로 바꾸면
                //    이 섹션만 한국어로 남는다. 화면 안쪽(피드백 폼)은 LeeoKit 것을 그대로 쓰고,
                //    번들 언어는 `AppLanguage.current` 설정이 함께 맞춰 준다(다음 실행부터).
                Section {
                    NavigationLink(destination: LeeoFeedbackView<GoldweekSpec>()) {
                        Label(Strings.sendFeedback, systemImage: "envelope.badge")
                    }

                    Button {
                        if let id = GoldweekSpec.appStoreID {
                            LeeoReviewRequest.openWriteReview(appStoreID: id)
                        } else {
                            LeeoReviewRequest.markRequested()
                            requestReview()
                        }
                    } label: {
                        Label(Strings.rateApp, systemImage: "star.bubble")
                    }

                    Link(destination: GoldweekSpec.legal.privacyURL) {
                        Label(Strings.privacyPolicy, systemImage: "arrow.up.forward.square")
                    }
                    Link(destination: GoldweekSpec.legal.supportURL) {
                        Label(Strings.supportPage, systemImage: "arrow.up.forward.square")
                    }
                    if let termsURL = GoldweekSpec.legal.termsURL {
                        Link(destination: termsURL) {
                            Label(Strings.termsOfService, systemImage: "arrow.up.forward.square")
                        }
                    }

                    if masterModeEnabled {
                        NavigationLink(destination: LeeoFeedbackInboxView<GoldweekSpec>()) {
                            Label(Strings.devFeedbackInbox, systemImage: "tray.full")
                        }
                        NavigationLink(destination: UsageStatsView()) {
                            Label(Strings.devUsageStats, systemImage: "chart.bar.xaxis")
                        }
                        NavigationLink(destination: CrashReportsView()) {
                            Label(Strings.devCrashReports, systemImage: "ladybug")
                        }
                    }

                    // 버전 — 7번 탭하면 개발자 모드 토글 (LeeoKit과 같은 키를 쓴다)
                    HStack {
                        Label(Strings.version, systemImage: "info.circle")
                        Spacer()
                        Text(appVersionText)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture(count: 7) {
                        masterModeEnabled.toggle()
                        HapticFeedback.success()
                    }
                } header: {
                    Text(Strings.supportSection)
                }

                // 개발자 문의
                DeveloperContactSection()
            }
            // 프로필 값은 @Bindable 바인딩이라 SwiftData 자동 저장에 맡겨져 있었다.
            // 자동 저장은 "곧" 저장할 뿐 그 시점을 보장하지 않는다 — 총 연차처럼 잔여 계산의
            // 근거가 되는 값은 바뀐 즉시 디스크에 있어야 한다(강제 종료·크래시 대비).
            .onChange(of: profile.totalAnnualLeave) { _, _ in persistProfile() }
            .onChange(of: profile.yearStartMonth) { _, _ in persistProfile() }
            .onChange(of: profile.name) { _, _ in persistProfile() }
            .onChange(of: profile.userTypeRaw) { _, _ in persistProfile() }
            .onChange(of: profile.countryRaw) { _, _ in persistProfile() }
            .navigationTitle(Strings.navTitleSettings)
            .sheet(isPresented: $showingPreferences) {
                PreferencesView(profile: profile)
            }
            .sheet(isPresented: $showingBonusLeaveSheet) {
                AddBonusLeaveSheet(
                    bonusDays: $bonusDays,
                    bonusType: $bonusType,
                    bonusReason: $bonusReason,
                    hasExpiration: $hasExpiration,
                    expirationDate: $expirationDate,
                    onSave: saveBonusLeave
                )
            }
            .sheet(item: $editingBonus) { bonus in
                EditBonusLeaveSheet(bonus: bonus)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingCalendarImport) {
                CalendarImportSheet(existingRecords: Array(leaveRecords))
            }
            .sheet(isPresented: $showingPhotoImport) {
                PhotoImportSheet()
            }
            .alert(Strings.resetDataTitle, isPresented: $showingResetAlert) {
                Button(Strings.cancel, role: .cancel) { }
                Button(Strings.reset, role: .destructive) {
                    resetData()
                }
            } message: {
                Text(Strings.resetDataMessage)
            }
            .alert(Strings.backup, isPresented: $showingBackupAlert) {
                Button(Strings.confirm, role: .cancel) { }
            } message: {
                Text(backupAlertMessage)
            }
            .alert(Strings.restoreConfirmTitle, isPresented: $showingRestoreConfirm) {
                Button(Strings.cancel, role: .cancel) { }
                Button(Strings.restore, role: .destructive) {
                    Task { await performRestore() }
                }
            } message: {
                Text(Strings.restoreConfirmMessage)
            }
            .alert(Strings.deleteBonusLeaveTitle, isPresented: $showingBonusDeleteConfirm) {
                Button(Strings.cancel, role: .cancel) { pendingBonusDeleteOffsets = nil }
                Button(Strings.delete, role: .destructive) { performDeleteBonusLeave() }
            } message: {
                Text(Strings.deleteBonusLeaveConfirm)
            }
            .alert(Strings.alert, isPresented: $showingRestoreResult) {
                Button(Strings.confirm, role: .cancel) { }
            } message: {
                Text(restoreResultMessage)
            }
            .task {
                await checkLastBackup()
            }
        }
    }

    // MARK: - 백업 함수
    private func backupToICloud() async {
        logInfo("사용자 iCloud 백업 요청", category: .ui)
        isBackingUp = true
        defer { isBackingUp = false }

        do {
            try await BackupService.shared.backupToICloud(
                profile: profile,
                leaveRecords: Array(leaveRecords),
                bonusLeaves: Array(bonusLeaves)
            )
            lastBackupDate = Date()
            backupAlertMessage = Strings.backupSuccessMessage
            logInfo("iCloud 백업 성공", category: .backup)
            await MainActor.run { HapticFeedback.success() }
            showingBackupAlert = true
        } catch {
            backupAlertMessage = error.localizedDescription
            logError("iCloud 백업 실패: \(error.localizedDescription)", category: .backup)
            await MainActor.run { HapticFeedback.error() }
            showingBackupAlert = true
        }
    }

    private func restoreFromICloud() async {
        logInfo("사용자 iCloud 복원 요청", category: .ui)
        showingRestoreConfirm = true
    }

    private func performRestore() async {
        logInfo("iCloud 복원 시작", category: .backup)
        isRestoring = true
        defer { isRestoring = false }

        do {
            let backup = try await BackupService.shared.restoreFromICloud()
            logDebug("백업 데이터 로드 완료 - 연차기록: \(backup.leaveRecords.count)건", category: .backup)
            try BackupService.shared.applyBackup(backup, to: modelContext, existingProfile: profile)
            backupAlertMessage = Strings.restoreSuccessMessage
            logInfo("iCloud 복원 성공", category: .backup)
            await MainActor.run { HapticFeedback.success() }
            showingBackupAlert = true
        } catch {
            backupAlertMessage = error.localizedDescription
            logError("iCloud 복원 실패: \(error.localizedDescription)", category: .backup)
            await MainActor.run { HapticFeedback.error() }
            showingBackupAlert = true
        }
    }

    private func checkLastBackup() async {
        logDebug("마지막 백업 정보 확인", category: .backup)
        let info = await BackupService.shared.getICloudBackupInfo()
        lastBackupDate = info.date
        if let date = info.date {
            logDebug("마지막 백업: \(date)", category: .backup)
        } else {
            logDebug("백업 없음", category: .backup)
        }
    }

    private func saveBonusLeave() {
        guard bonusDays > 0 else {
            logWarning("보너스 연차 저장 실패: 일수가 0 이하", category: .data)
            HapticFeedback.error()
            return
        }

        logDebug("보너스 연차 추가 시도 - \(bonusType.rawValue) \(bonusDays)일", category: .data)

        let bonus = BonusLeave(
            days: bonusDays,
            type: bonusType,
            reason: bonusReason,
            expirationDate: hasExpiration ? expirationDate : nil
        )
        modelContext.insert(bonus)

        do {
            try modelContext.save()
            logInfo("보너스 연차 추가 완료 - \(bonusType.rawValue) \(bonusDays)일", category: .data)
            HapticFeedback.success()
            bonusDays = 1.0
            bonusType = .compensatory
            bonusReason = ""
            hasExpiration = false
            showingBonusLeaveSheet = false
        } catch {
            modelContext.delete(bonus)
            logError("보너스 연차 저장 실패: \(error.localizedDescription)", category: .data)
            HapticFeedback.error()
            backupAlertMessage = Strings.saveFailedWithReason(error.localizedDescription)
            showingBackupAlert = true
        }
    }

    /// 보너스 연차 행을 한 문장으로 읽어주는 VoiceOver 라벨
    private func bonusRowAccessibilityLabel(_ bonus: BonusLeave) -> String {
        var parts = [
            Strings.bonusLeaveTypeName(bonus.type),
            // 화면의 분수("1.5/3일")를 귀로는 문장으로 읽어 준다 — 분수는 낭독하면 뜻이 흐리다.
            Strings.bonusUsedOfGranted(
                used: formatLeave(bonus.usedDays),
                granted: formatLeave(bonus.days)
            )
        ]
        if !bonus.reason.isEmpty { parts.append(bonus.reason) }
        if let expiration = bonus.expirationDate {
            parts.append(expiration.appMonthDay)
        }
        return parts.joined(separator: ", ")
    }

    private func deleteBonusLeave(at offsets: IndexSet) {
        pendingBonusDeleteOffsets = offsets
        showingBonusDeleteConfirm = true
    }

    private func performDeleteBonusLeave() {
        guard let offsets = pendingBonusDeleteOffsets else { return }
        pendingBonusDeleteOffsets = nil
        let activeLeaves = bonusLeaves.filter { !$0.isUsed }
        for index in offsets {
            let bonus = activeLeaves[index]
            logDebug("보너스 연차 삭제 - \(bonus.type.rawValue) \(bonus.days)일", category: .data)
            modelContext.delete(bonus)
        }
        do {
            try modelContext.save()
            logInfo("보너스 연차 삭제 완료", category: .data)
            HapticFeedback.success()
        } catch {
            logError("보너스 연차 삭제 실패: \(error.localizedDescription)", category: .data)
            HapticFeedback.error()
            backupAlertMessage = Strings.deleteFailed
            showingBackupAlert = true
        }
    }

    private func resetData() {
        logWarning("사용자 데이터 초기화 요청", category: .data)

        for record in leaveRecords {
            modelContext.delete(record)
        }
        logDebug("연차 기록 \(leaveRecords.count)건 삭제", category: .data)

        for bonus in bonusLeaves {
            modelContext.delete(bonus)
        }
        logDebug("보너스 연차 \(bonusLeaves.count)건 삭제", category: .data)

        profile.usedLeave = 0

        do {
            try modelContext.save()
            logInfo("데이터 초기화 완료", category: .data)
            HapticFeedback.success()
        } catch {
            logError("데이터 초기화 실패: \(error.localizedDescription)", category: .data)
            HapticFeedback.error()
            backupAlertMessage = Strings.resetFailedWithReason(error.localizedDescription)
            showingBackupAlert = true
        }
    }
}

// MARK: - 개발자 문의
struct DeveloperContactSection: View {
    var body: some View {
        Section {
            Link(destination: URL(string: "mailto:leeo@kakao.com")!) {
                HStack {
                    Image(systemName: "envelope")
                        .foregroundStyle(.blue)
                        .frame(width: 24)
                        .voDecorative()
                    Text(Strings.contactByEmail)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                        .font(.body)
                        .voDecorative()
                }
            }
            Link(destination: URL(string: "https://instagram.com/lee25_ios")!) {
                HStack {
                    Image(systemName: "paperplane")
                        .foregroundStyle(.purple)
                        .frame(width: 24)
                        .voDecorative()
                    Text(Strings.contactByInstagram)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                        .font(.body)
                        .voDecorative()
                }
            }
        } header: {
            Text(Strings.contactDeveloperSection)
        } footer: {
            Text(Strings.contactDeveloperFooter)
        }
    }
}

// MARK: - 설정 요약 행
struct PreferenceSummaryRow: View {
    let icon: String
    let title: String
    let value: String
    /// 화면에 이모지를 쓰는 경우 VoiceOver용 자연어 값(이름)을 별도 지정
    var accessibilityValue: String? = nil

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
                .voDecorative()
            Text(title)
            Spacer()
            Text(value)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text(accessibilityValue ?? value))
    }
}

// MARK: - 통계 행
struct StatRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .frame(width: 24)
                .voDecorative()
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text(value))
    }
}

// MARK: - 캘린더 휴가 가져오기 시트 (제안 후 확인)
struct CalendarImportSheet: View {
    let existingRecords: [LeaveRecord]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var isScanning = true
    @State private var candidates: [DetectedLeaveCandidate] = []
    @State private var selectedIDs: Set<UUID> = []
    @State private var scanErrorMessage: String?
    @State private var isSaving = false
    @State private var resultMessage = ""
    @State private var showingResultAlert = false
    @State private var importSucceeded = false

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            Group {
                if isScanning {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text(Strings.scanningCalendar)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = scanErrorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                            .voDecorative()
                        Text(errorMessage)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        HStack(spacing: 12) {
                            Button(Strings.retry) {
                                Task { await scan() }
                            }
                            .buttonStyle(.bordered)

                            // 권한이 거부된 상태면 재시도로 해결되지 않으므로 설정으로 안내
                            Button(Strings.openSettings) {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if candidates.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .voDecorative()
                        Text(Strings.noLeaveCandidatesFound)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section {
                            ForEach(candidates) { candidate in
                                Button {
                                    toggleSelection(candidate.id)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: selectedIDs.contains(candidate.id)
                                              ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(selectedIDs.contains(candidate.id)
                                                             ? AppTheme.Colors.brand : Color(.systemGray3))
                                            .voDecorative()

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(candidate.title)
                                                .fontWeight(.medium)
                                                .foregroundStyle(.primary)
                                                .lineLimit(1)
                                            HStack(spacing: 6) {
                                                // 추론된 휴가 유형 배지
                                                Text(Strings.leaveTypeName(candidate.suggestedType))
                                                    .font(.body.weight(.semibold))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(candidate.suggestedType.themeColor.opacity(0.15))
                                                    .foregroundStyle(candidate.suggestedType.themeColor)
                                                    .clipShape(Capsule())
                                                Text("\(dateRangeText(candidate)) · \(Strings.dayCount(candidate.effectiveDays))")
                                                    .font(.body)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(Text("\(candidate.title), \(Strings.leaveTypeName(candidate.suggestedType)), \(dateRangeText(candidate)), \(Strings.dayCount(candidate.effectiveDays))"))
                                .accessibilityAddTraits(selectedIDs.contains(candidate.id) ? .isSelected : [])
                            }
                        } header: {
                            Text(Strings.detectedLeaveCandidates)
                        } footer: {
                            Text(Strings.importFromCalendarDescription)
                        }
                    }
                }
            }
            .navigationTitle(Strings.importFromCalendar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
                if !candidates.isEmpty && scanErrorMessage == nil && !isScanning {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            importSelected()
                        } label: {
                            if isSaving {
                                ProgressView().scaleEffect(0.8)
                            } else {
                                Text(Strings.importSelectedLeaves(selectedIDs.count))
                                    .fontWeight(.semibold)
                            }
                        }
                        .disabled(selectedIDs.isEmpty || isSaving)
                    }
                }
            }
            .task { await scan() }
            .alert(Strings.alert, isPresented: $showingResultAlert) {
                Button(Strings.confirm, role: .cancel) {
                    if importSucceeded { dismiss() }
                }
            } message: {
                Text(resultMessage)
            }
        }
    }

    private func toggleSelection(_ id: UUID) {
        HapticFeedback.selection()
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    private func dateRangeText(_ candidate: DetectedLeaveCandidate) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Strings.localeIdentifier)
        formatter.dateFormat = Strings.dateRangeFormat
        if calendar.isDate(candidate.startDate, inSameDayAs: candidate.endDate) {
            return formatter.string(from: candidate.startDate)
        }
        return "\(formatter.string(from: candidate.startDate)) ~ \(formatter.string(from: candidate.endDate))"
    }

    private func scan() async {
        isScanning = true
        scanErrorMessage = nil
        do {
            let found = try await CalendarService.shared.scanForLeaveCandidates(
                existingRecords: existingRecords
            )
            candidates = found
            selectedIDs = Set(found.map(\.id))  // 기본 전체 선택
        } catch {
            scanErrorMessage = error.localizedDescription
        }
        isScanning = false
    }

    private func importSelected() {
        let selected = candidates.filter { selectedIDs.contains($0.id) }
        guard !selected.isEmpty else { return }
        isSaving = true

        let today = calendar.startOfDay(for: Date())
        var inserted: [LeaveRecord] = []
        for candidate in selected {
            let record = LeaveRecord(
                startDate: candidate.startDate,
                endDate: candidate.endDate,
                type: candidate.suggestedType,
                status: candidate.endDate < today ? .used : .planned,
                note: candidate.title
            )
            modelContext.insert(record)
            inserted.append(record)
        }

        do {
            try modelContext.save()
            UsageReportingService.record(event: "leave_added:calendar_import")
            HapticFeedback.success()
            importSucceeded = true
            resultMessage = Strings.leavesImported(inserted.count)
        } catch {
            inserted.forEach { modelContext.delete($0) }
            HapticFeedback.error()
            importSucceeded = false
            resultMessage = Strings.saveFailed
        }
        isSaving = false
        showingResultAlert = true
    }
}

#Preview {
    @Previewable @State var profile = UserProfile(name: "홍길동", yearStartMonth: 1, totalAnnualLeave: 15, usedLeave: 5)

    SettingsView(profile: profile)
}
