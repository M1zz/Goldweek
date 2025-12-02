//
//  SettingsView.swift
//  LeaveWise
//
//  설정 화면
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var modelContext
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

    var usedLeaveCount: Int {
        leaveRecords.filter { $0.status == .used }.count
    }

    var plannedLeaveCount: Int {
        leaveRecords.filter { $0.status == .planned }.count
    }

    var activeBonusLeave: Double {
        bonusLeaves.filter { !$0.isUsed }.reduce(0) { $0 + $1.days }
    }

    var totalAvailableLeave: Double {
        profile.remainingLeave + activeBonusLeave
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
                                TextField("이름", text: $tempName)
                                    .textFieldStyle(.roundedBorder)
                                    .onSubmit {
                                        profile.name = tempName
                                        editingName = false
                                    }
                            } else {
                                Text(profile.name)
                                    .font(.title2.bold())
                            }
                            
                            Text("가입일: \(profile.createdAt.formatted(date: .abbreviated, time: .omitted))")
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
                
                // 연차 설정
                Section("연차 설정") {
                    // 총 사용 가능 연차 표시
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("사용 가능 연차")
                                .font(.subheadline)
                            if activeBonusLeave > 0 {
                                Text("기본 \(String(format: "%.1f", profile.remainingLeave))일 + 보너스 \(String(format: "%.1f", activeBonusLeave))일")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Text("\(String(format: "%.1f", totalAvailableLeave))일")
                            .font(.title2.bold())
                            .foregroundStyle(.green)
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Text("총 연차")
                        Spacer()
                        Stepper(
                            "\(Int(profile.totalAnnualLeave))일",
                            value: $profile.totalAnnualLeave,
                            in: max(profile.usedLeave, 1)...30,
                            step: 1
                        )
                    }

                    HStack {
                        Text("사용한 연차")
                        Spacer()
                        Text("\(String(format: "%.1f", profile.usedLeave))일")
                            .foregroundStyle(.secondary)
                    }

                    Picker("연차 기준월", selection: $profile.yearStartMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text("\(month)월").tag(month)
                        }
                    }
                }

                // 보너스 연차 관리
                Section {
                    Button {
                        showingBonusLeaveSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.orange)
                            Text("보너스 연차 추가")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.caption)
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
                                    Text(bonus.type.rawValue)
                                        .font(.subheadline)
                                    Text("\(String(format: "%.1f", bonus.days))일")
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
                        }
                    }
                    .onDelete(perform: deleteBonusLeave)
                } header: {
                    Text("보너스 연차")
                } footer: {
                    Text("대체휴무, 포상휴가 등 추가로 받은 연차를 관리합니다.")
                }
                
                // 휴가 스타일
                Section("휴가 스타일") {
                    Button(action: { showingPreferences = true }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(.blue)
                            Text("선호도 설정")
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
                            title: "선호 기간",
                            value: profile.preferredDuration.rawValue
                        )
                        
                        if !profile.preferredSeasons.isEmpty {
                            PreferenceSummaryRow(
                                icon: "leaf",
                                title: "선호 계절",
                                value: profile.preferredSeasons.map { $0.icon }.joined(separator: " ")
                            )
                        }
                        
                        if !profile.priorityActivities.isEmpty {
                            PreferenceSummaryRow(
                                icon: "star",
                                title: "선호 활동",
                                value: profile.priorityActivities.map { $0.icon }.joined(separator: " ")
                            )
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                // 통계
                Section("사용 통계") {
                    StatRow(icon: "checkmark.circle.fill", iconColor: .green, title: "사용 완료", value: "\(usedLeaveCount)건")
                    StatRow(icon: "calendar.badge.clock", iconColor: .blue, title: "예정된 휴가", value: "\(plannedLeaveCount)건")
                    StatRow(icon: "chart.pie.fill", iconColor: .orange, title: "연차 소진율", value: "\(Int((profile.usedLeave / profile.totalAnnualLeave) * 100))%")
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
                            Text("iCloud에 백업")
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
                            Text("iCloud에서 복원")
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
                            Text("연차 데이터 초기화")
                        }
                    }
                } header: {
                    Text("데이터 관리")
                } footer: {
                    if let lastBackup = lastBackupDate {
                        Text("마지막 백업: \(lastBackup.formatted(date: .abbreviated, time: .shortened))")
                    }
                }
                
                // 앱 정보
                Section("앱 정보") {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("개발")
                        Spacer()
                        Text("LeaveWise Team")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("설정")
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
            .alert("연차 데이터 초기화", isPresented: $showingResetAlert) {
                Button("취소", role: .cancel) { }
                Button("초기화", role: .destructive) {
                    resetData()
                }
            } message: {
                Text("모든 연차 기록이 삭제되고 사용한 연차가 0으로 초기화됩니다. 이 작업은 되돌릴 수 없습니다.")
            }
            .alert("백업", isPresented: $showingBackupAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(backupAlertMessage)
            }
            .alert("복원 확인", isPresented: $showingRestoreConfirm) {
                Button("취소", role: .cancel) { }
                Button("복원", role: .destructive) {
                    Task { await performRestore() }
                }
            } message: {
                Text("iCloud 백업에서 데이터를 복원합니다. 현재 데이터는 모두 삭제됩니다.")
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
            // 초기화
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

        // 모든 연차 기록 삭제
        for record in leaveRecords {
            modelContext.delete(record)
        }
        logDebug("연차 기록 \(leaveRecords.count)건 삭제", category: .data)

        // 모든 보너스 연차 삭제
        for bonus in bonusLeaves {
            modelContext.delete(bonus)
        }
        logDebug("보너스 연차 \(bonusLeaves.count)건 삭제", category: .data)

        // 사용한 연차 초기화
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
