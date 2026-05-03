//
//  SettingsView.swift
//  LeaveWise
//
//  설정 화면
//

import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var modelContext
    @Environment(\.requestReview) private var requestReview
    @Query private var leaveRecords: [LeaveRecord]
    @Query(sort: \BonusLeave.grantedDate, order: .reverse) private var bonusLeaves: [BonusLeave]

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

    // 국가 & 언어
    @State private var selectedCountry: Country
    @State private var selectedLanguage: AppLanguage

    private let recommendationEngine = RecommendationEngine()

    init(profile: UserProfile) {
        self.profile = profile
        _selectedCountry = State(initialValue: profile.country)
        _selectedLanguage = State(initialValue: AppLanguage.current)
    }

    var usedLeaveCount: Int {
        leaveRecords.filter { $0.status == .used }.count
    }

    var plannedLeaveCount: Int {
        leaveRecords.filter { $0.status == .planned }.count
    }

    var committedLeave: Double {
        let active = leaveRecords.filter { $0.status == .used || $0.status == .planned }
        let deducting = active.filter { $0.deductsFromAnnualLeave }
        return deducting.reduce(0.0) { $0 + $1.effectiveLeaveDays }
    }

    var activeBonusLeave: Double {
        let now = Date()
        return bonusLeaves
            .filter { !$0.isUsed && ($0.expirationDate == nil || $0.expirationDate! > now) }
            .reduce(0) { $0 + $1.remainingDays }
    }

    var totalAvailableLeave: Double {
        max(0, profile.totalAnnualLeave - committedLeave) + activeBonusLeave
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

                            Text(String(profile.name.prefix(1)))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            if editingName {
                                TextField(Strings.name, text: $tempName)
                                    .textFieldStyle(.roundedBorder)
                                    .onSubmit {
                                        profile.name = tempName
                                        editingName = false
                                    }
                            } else {
                                Text(profile.name)
                                    .font(.title2.bold())
                            }

                            Text(Strings.joinDate(profile.createdAt.formatted(date: .abbreviated, time: .omitted)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button(action: {
                            if editingName {
                                profile.name = tempName
                            } else {
                                tempName = profile.name
                            }
                            editingName.toggle()
                        }) {
                            Image(systemName: editingName ? "checkmark.circle.fill" : "pencil.circle.fill")
                                .font(.title2)
                                .foregroundStyle(editingName ? .green : .blue)
                        }
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
                            VStack(alignment: .leading, spacing: 2) {
                                Text("공휴일 관리")
                                Text("공휴일 추가·숨기기")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // 사용자 유형
                Section("사용자 유형") {
                    Picker("모드", selection: $profile.userType) {
                        ForEach(UserType.allCases) { type in
                            Label(type.displayName, systemImage: type.icon).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)

                    if profile.userType == .leisure {
                        Text("연차 제한 없이 자유롭게 휴가를 계획하고 싶은 분을 위한 모드입니다.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // 연차/휴가 설정
                let isLeisure = profile.userType == .leisure
                Section(isLeisure ? "휴가 설정" : Strings.annualLeaveSettings) {
                    // 총 사용 가능 연차 표시 — 직장인 모드만
                    if !isLeisure {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(Strings.availableLeaveLabel)
                                    .font(.subheadline)
                                if activeBonusLeave > 0 {
                                    Text(Strings.baseAndBonus(
                                        base: formatLeave(max(0, profile.totalAnnualLeave - committedLeave)),
                                        bonus: formatLeave(activeBonusLeave)
                                    ))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Text("\(formatLeave(totalAvailableLeave))\(Strings.dayUnitSuffix)")
                                .font(.title2.bold())
                                .foregroundStyle(.green)
                        }
                        .padding(.vertical, 4)
                    }

                    HStack {
                        Text(isLeisure ? "연간 목표 일수" : Strings.totalLeave)
                        Spacer()
                        if isLeisure {
                            Stepper(
                                profile.totalAnnualLeave == 0
                                    ? "무제한"
                                    : "\(Int(profile.totalAnnualLeave))\(Strings.dayUnitSuffix)",
                                value: $profile.totalAnnualLeave,
                                in: 0...365,
                                step: 1
                            )
                        } else {
                            Stepper(
                                "\(Int(profile.totalAnnualLeave))\(Strings.dayUnitSuffix)",
                                value: $profile.totalAnnualLeave,
                                in: max(committedLeave, 1)...365,
                                step: 1
                            )
                        }
                    }

                    HStack {
                        Text(isLeisure ? "계획된 휴가" : Strings.usedLeave)
                        Spacer()
                        Text("\(formatLeave(committedLeave))\(Strings.dayUnitSuffix)")
                            .foregroundStyle(.secondary)
                    }

                    Picker(isLeisure ? "기준 연도 시작월" : Strings.yearStartMonth, selection: $profile.yearStartMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(Strings.monthShort(month)).tag(month)
                        }
                    }
                }

                // 보너스 연차 관리 (Pro 전용, 직장인 모드만)
                if !isLeisure { Section {
                    Button {
                        if ProManager.shared.isPro {
                            showingBonusLeaveSheet = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: ProManager.shared.isPro ? "plus.circle.fill" : "crown.fill")
                                .foregroundStyle(ProManager.shared.isPro ? .orange : .yellow)
                            Text(Strings.addBonusLeave)
                                .foregroundStyle(ProManager.shared.isPro ? .primary : .secondary)
                            Spacer()
                            if ProManager.shared.isPro {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            } else {
                                Text("Pro")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.yellow)
                                    .foregroundColor(.black)
                                    .cornerRadius(4)
                            }
                        }
                    }

                    // 활성 보너스 연차 목록
                    ForEach(bonusLeaves.filter { !$0.isUsed }) { bonus in
                        HStack {
                            Image(systemName: bonus.type.icon)
                                .foregroundStyle(.orange)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(Strings.bonusLeaveTypeName(bonus.type))
                                        .font(.subheadline)
                                    Text("\(String(format: "%.1f", bonus.remainingDays))/\(String(format: "%.1f", bonus.days))\(Strings.dayUnitSuffix)")
                                        .font(.subheadline)
                                        .foregroundStyle(.orange)
                                }
                                if !bonus.reason.isEmpty {
                                    Text(bonus.reason)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            if let expiration = bonus.expirationDate {
                                Text(expiration, format: .dateTime.month().day())
                                    .font(.caption)
                                    .foregroundStyle(expiration < Date() ? .red : .secondary)
                            }

                            Image(systemName: "pencil.circle")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { editingBonus = bonus }
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
                            Text(Strings.preferencesSettings)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
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
                                value: profile.preferredSeasons.map { $0.icon }.joined(separator: " ")
                            )
                        }

                        if !profile.priorityActivities.isEmpty {
                            PreferenceSummaryRow(
                                icon: "star",
                                title: Strings.preferredActivity,
                                value: profile.priorityActivities.map { $0.icon }.joined(separator: " ")
                            )
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                // 통계
                Section(Strings.usageStats) {
                    StatRow(icon: "checkmark.circle.fill", iconColor: .green, title: Strings.completed, value: Strings.itemCount(usedLeaveCount))
                    StatRow(icon: "calendar.badge.clock", iconColor: .blue, title: Strings.plannedLeave, value: Strings.itemCount(plannedLeaveCount))
                    StatRow(icon: "chart.pie.fill", iconColor: .orange, title: Strings.leaveUsageRate, value: profile.totalAnnualLeave > 0 ? "\(Int((committedLeave / profile.totalAnnualLeave) * 100))%" : "0%")
                }

                // 데이터 관리
                Section {
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
                        Text(Strings.lastBackup(lastBackup.formatted(date: .abbreviated, time: .shortened)))
                    }
                }

                // 앱 정보
                Section(Strings.appInfo) {
                        // 구매 복원
                    if !ProManager.shared.isPro {
                        Button {
                            Task {
                                await ProManager.shared.restorePurchases()
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

                    // 앱 평가하기 (App Store 직접 열기)
                    Button {
                        ReviewManager.shared.openAppStoreForReview()
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text(Strings.rateApp)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    // 앱 공유하기
                    ShareLink(
                        item: URL(string: "https://apps.apple.com/app/id6739899592")!,
                        subject: Text("LeaveWise - 연차 관리 앱"),
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
                                .font(.caption)
                        }
                    }

                    HStack {
                        Text(Strings.version)
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text(Strings.developer)
                        Spacer()
                        Text("LeaveWise Team")
                            .foregroundStyle(.secondary)
                    }
                }
            }
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
            backupAlertMessage = "iCloud에 백업되었습니다."
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
            backupAlertMessage = "복원이 완료되었습니다."
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
            backupAlertMessage = "저장에 실패했습니다: \(error.localizedDescription)"
            showingBackupAlert = true
        }
    }

    private func deleteBonusLeave(at offsets: IndexSet) {
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
            backupAlertMessage = "초기화에 실패했습니다: \(error.localizedDescription)"
            showingBackupAlert = true
        }
    }
}

// MARK: - 설정 요약 행
struct PreferenceSummaryRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
            Text(title)
            Spacer()
            Text(value)
        }
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
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    @Previewable @State var profile = UserProfile(name: "홍길동", yearStartMonth: 1, totalAnnualLeave: 15, usedLeave: 5)

    SettingsView(profile: profile)
}
