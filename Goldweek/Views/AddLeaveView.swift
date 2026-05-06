//
//  AddLeaveView.swift
//  Goldweek
//
//  연차 등록 및 보너스 연차 관리 화면
//

import SwiftUI
import SwiftData

struct AddLeaveView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LeaveRecord.startDate, order: .reverse) private var leaveRecords: [LeaveRecord]
    @Query(sort: \BonusLeave.grantedDate, order: .reverse) private var bonusLeaves: [BonusLeave]

    @State private var selectedTab = 0

    var committedLeave: Double {
        let active = leaveRecords.filter { $0.status == .used || $0.status == .planned }
        let deducting = active.filter { $0.deductsFromAnnualLeave }
        return deducting.reduce(0.0) { $0 + $1.effectiveLeaveDays }
    }

    var totalBonusLeave: Double {
        let now = Date()
        let available = bonusLeaves.filter { !$0.isUsed }
        let notExpired = available.filter { $0.expirationDate == nil || $0.expirationDate! > now }
        return notExpired.reduce(0.0) { $0 + $1.remainingDays }
    }

    var totalAvailableLeave: Double {
        max(0, profile.totalAnnualLeave - committedLeave) + totalBonusLeave
    }

    private var isLeisure: Bool { profile.userType == .leisure }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 현황 요약 헤더
                if isLeisure {
                    LeisureStatusHeader(
                        usedDays: committedLeave,
                        goalDays: profile.totalAnnualLeave
                    )
                    .accessibilityElement(children: .combine)
                } else {
                    LeaveStatusHeader(
                        remainingLeave: max(0, profile.totalAnnualLeave - committedLeave),
                        bonusLeave: totalBonusLeave,
                        totalAvailable: totalAvailableLeave
                    )
                    .accessibilityElement(children: .combine)
                }

                // 탭 선택 — 직장인 모드만 보너스 탭 노출
                if !isLeisure {
                    Picker(Strings.managementType, selection: $selectedTab) {
                        Text(Strings.registerLeave).tag(0)
                        Text(Strings.addLeave).tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .onChange(of: selectedTab) { _, _ in
                        HapticFeedback.selection()
                    }
                }

                if selectedTab == 0 || isLeisure {
                    LeaveRegistrationView(
                        profile: profile,
                        totalAvailableLeave: totalAvailableLeave,
                        leaveRecords: Array(leaveRecords.prefix(5))
                    )
                } else {
                    BonusLeaveView(bonusLeaves: bonusLeaves)
                }
            }
            .navigationTitle(isLeisure ? Strings.registerLeave : Strings.navTitleLeaveManagement)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 자유 계획 현황 헤더
struct LeisureStatusHeader: View {
    let usedDays: Double
    let goalDays: Double

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(Strings.statUsed)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Text("\(formatLeave(usedDays))\(Strings.dayUnitSuffix)")
                    .font(.title3.bold())
                    .foregroundStyle(.blue)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(goalDays > 0 ? Strings.leisureGoalRemaining : Strings.leisureTotalPlan)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Text(goalDays > 0 ? "\(formatLeave(max(0, goalDays - usedDays)))\(Strings.dayUnitSuffix)" : "\(formatLeave(usedDays))\(Strings.dayUnitSuffix)")
                    .font(.title2.bold())
                    .foregroundStyle(.purple)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - 연차 현황 헤더
struct LeaveStatusHeader: View {
    let remainingLeave: Double
    let bonusLeave: Double
    let totalAvailable: Double

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(Strings.basicLeave)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                Text("\(formatLeave(remainingLeave))\(Strings.dayUnitSuffix)")
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.Colors.brand)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }

            if bonusLeave > 0 {
                Text("+")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.bonus)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    Text("\(formatLeave(bonusLeave))\(Strings.dayUnitSuffix)")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.Colors.compensatory)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }

                Text("=")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(Strings.totalAvailable)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                Text("\(formatLeave(totalAvailable))\(Strings.dayUnitSuffix)")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.Colors.success)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - 휴가 등록 뷰
struct LeaveRegistrationView: View {
    @Bindable var profile: UserProfile
    let totalAvailableLeave: Double
    let leaveRecords: [LeaveRecord]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.requestReview) private var requestReview

    @Query private var allLeaveRecords: [LeaveRecord]

    // 사용 가능한 보너스 연차 (미사용 + 미만료)
    @Query(filter: #Predicate<BonusLeave> { $0.isUsed == false })
    private var unusedBonusLeaves: [BonusLeave]

    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var leaveType: LeaveType = .annual
    @State private var note = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var isSaving = false
    @State private var shouldPromptReview = false
    @State private var selectedBonusLeave: BonusLeave?
    @FocusState private var isNoteFocused: Bool

    var committedLeave: Double {
        let active = allLeaveRecords.filter { $0.status == .used || $0.status == .planned }
        let deducting = active.filter { $0.deductsFromAnnualLeave }
        return deducting.reduce(0.0) { $0 + $1.effectiveLeaveDays }
    }

    /// 만료되지 않은 보너스 연차
    var availableBonusLeaves: [BonusLeave] {
        let now = Date()
        return unusedBonusLeaves.filter {
            $0.expirationDate == nil || $0.expirationDate! > now
        }
    }

    var leaveDays: Double {
        switch leaveType {
        case .half:
            return 0.5
        case .quarter:
            return 0.25
        default:
            let components = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
            let days = (components.day ?? 0) + 1
            return Double(max(days, 1))
        }
    }

    var canAddLeave: Bool {
        guard startDate <= endDate else { return false }
        // 보너스 연차 사용 시: 잔여 보너스 초과 불가
        if let bonus = selectedBonusLeave {
            return leaveDays <= bonus.remainingDays
        }
        // 자유 계획 모드: 한도 없음
        if profile.userType == .leisure { return true }
        // 직장인: 연차 차감 유형이면 잔여 연차 초과 불가
        if leaveType.deductsFromAnnual {
            return max(0, profile.totalAnnualLeave - committedLeave) >= leaveDays
        }
        return true
    }

    var body: some View {
        Form {
            // 보너스 연차 선택 (사용 가능한 경우 최상단 표시)
            if !availableBonusLeaves.isEmpty {
                Section {
                    ForEach(availableBonusLeaves) { bonus in
                        Button {
                            if selectedBonusLeave?.id == bonus.id {
                                selectedBonusLeave = nil
                            } else {
                                selectedBonusLeave = bonus
                                // 보너스 선택 시 단위가 기타 유형이면 연차로 초기화
                                if !leaveType.deductsFromAnnual {
                                    leaveType = .annual
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: bonus.type.icon)
                                    .font(.title3)
                                    .foregroundStyle(selectedBonusLeave?.id == bonus.id ? .white : AppTheme.Colors.bonus)
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(Strings.bonusLeaveTypeName(bonus.type))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(selectedBonusLeave?.id == bonus.id ? .white : .primary)
                                    HStack(spacing: 4) {
                                        Text(Strings.availableDays(formatLeave(bonus.remainingDays)))
                                            .font(.caption)
                                            .foregroundStyle(selectedBonusLeave?.id == bonus.id ? .white.opacity(0.85) : .secondary)
                                        if !bonus.reason.isEmpty {
                                            Text("· \(bonus.reason)")
                                                .font(.caption)
                                                .foregroundStyle(selectedBonusLeave?.id == bonus.id ? .white.opacity(0.85) : .secondary)
                                                .lineLimit(1)
                                        }
                                    }
                                    if let exp = bonus.expirationDate {
                                        Text(Strings.expiresBy(exp.formatted(.dateTime.month().day())))
                                            .font(.caption2)
                                            .foregroundStyle(selectedBonusLeave?.id == bonus.id ? .white.opacity(0.7) : AppTheme.Colors.bonus)
                                    }
                                }

                                Spacer()

                                Image(systemName: selectedBonusLeave?.id == bonus.id ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedBonusLeave?.id == bonus.id ? .white : Color(.systemGray3))
                                    .font(.title3)
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(
                            selectedBonusLeave?.id == bonus.id
                                ? AppTheme.Colors.bonus.opacity(0.85)
                                : Color(.systemBackground)
                        )
                    }
                } header: {
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill").foregroundStyle(AppTheme.Colors.bonus)
                        Text(Strings.bonusUseSectionHeader)
                    }
                } footer: {
                    if selectedBonusLeave != nil {
                        Text(Strings.bonusUseFooterSelected)
                    } else {
                        Text(Strings.bonusUseFooterUnselected)
                    }
                }
            }

            // 사용 단위 선택 — 보너스/일반 연차 모두 항상 표시
            let isLeisureMode = profile.userType == .leisure
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedBonusLeave != nil ? Strings.unitSectionTitleBonus
                         : isLeisureMode ? Strings.unitSectionTitleLeisure
                         : Strings.unitSectionTitleEmployee)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        ForEach([LeaveType.quarter, .half, .annual], id: \.self) { type in
                            Button {
                                HapticFeedback.selection()
                                leaveType = type
                            } label: {
                                VStack(spacing: 3) {
                                    Text(type == .quarter ? "¼" : type == .half ? "½" : "1")
                                        .font(.system(size: 22, weight: .black, design: .rounded))
                                    Text(Strings.unitLabel(type, isLeisure: isLeisureMode))
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Text(type == .quarter ? "0.25\(Strings.dayUnitSuffix)" : type == .half ? "0.5\(Strings.dayUnitSuffix)" : "1\(Strings.dayUnitSuffix)~")
                                        .font(.caption2)
                                        .opacity(0.8)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(leaveType == type ? type.themeColor : Color(.systemGray5))
                                .foregroundStyle(leaveType == type ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(leaveType == type ? .isSelected : [])
                        }
                    }
                }
                .padding(.vertical, 4)

                // 기타 유형 — 직장인 + 보너스 미선택 시만 표시
                if selectedBonusLeave == nil && !isLeisureMode {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(Strings.otherTypesSectionHeader)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 6) {
                            ForEach([LeaveType.compensatory, .official, .sick, .special, .businessTrip], id: \.self) { type in
                                Button {
                                    HapticFeedback.selection()
                                    leaveType = type
                                } label: {
                                    VStack(spacing: 3) {
                                        Image(systemName: type.icon)
                                            .font(.subheadline)
                                        Text(Strings.leaveTypeName(type))
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(leaveType == type ? type.themeColor : Color(.systemGray5))
                                    .foregroundStyle(leaveType == type ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                                .accessibilityAddTraits(leaveType == type ? .isSelected : [])
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text(Strings.leaveTypeSection)
            } footer: {
                if selectedBonusLeave == nil && !leaveType.deductsFromAnnual {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                        Text(Strings.noDeductionInfo(Strings.leaveTypeName(leaveType)))
                    }
                }
            }

            // 날짜 선택
            Section(Strings.dateSelection) {
                DatePicker(Strings.startDate, selection: $startDate, displayedComponents: .date)

                if leaveType != .half && leaveType != .quarter {
                    DatePicker(Strings.endDate, selection: $endDate, in: startDate..., displayedComponents: .date)
                }

                HStack {
                    Text(Strings.daysUsed)
                    Spacer()
                    HStack(spacing: 4) {
                        Text(Strings.unitLabel(leaveType, isLeisure: false))
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(leaveType.themeColor.opacity(0.15))
                            .foregroundStyle(leaveType.themeColor)
                            .clipShape(Capsule())
                        Text("\(String(format: leaveDays == Double(Int(leaveDays)) ? "%.0f" : "%.2g", leaveDays))\(Strings.dayUnitSuffix)")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                    }
                }

                if startDate < Calendar.current.startOfDay(for: Date()) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                        Text(Strings.pastLeaveAutoUsed)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // 메모
            Section(Strings.memoOptional) {
                TextField(Strings.memoPlaceholder, text: $note)
                    .focused($isNoteFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        isNoteFocused = false
                    }
            }

            // 등록 버튼
            Section {
                Button(action: addLeave) {
                    HStack {
                        Spacer()
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "plus.circle.fill")
                            Text(Strings.registerLeaveButton)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(!canAddLeave || isSaving)
                .foregroundStyle(canAddLeave ? .white : .gray)
                .listRowBackground(canAddLeave ? AppTheme.Colors.brand : Color.gray.opacity(0.3))
            }

            // 최근 등록 내역
            if !leaveRecords.isEmpty {
                Section(Strings.recentRecords) {
                    ForEach(leaveRecords) { record in
                        LeaveRecordRow(record: record)
                    }
                }
            }
        }
        .onChange(of: startDate) { oldStart, newStart in
            let calendar = Calendar.current
            if leaveType == .half || leaveType == .quarter {
                endDate = newStart
            } else {
                let duration = calendar.dateComponents([.day], from: oldStart, to: endDate).day ?? 0
                endDate = calendar.date(byAdding: .day, value: max(duration, 0), to: newStart) ?? newStart
            }
        }
        .onChange(of: leaveType) { _, newValue in
            if newValue == .half || newValue == .quarter {
                endDate = startDate
            }
        }
        .alert(Strings.alert, isPresented: $showingAlert) {
            Button(Strings.confirm, role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: shouldPromptReview) { _, newValue in
            if newValue {
                shouldPromptReview = false
                // 약간의 딜레이 후 리뷰 요청 (UX 개선)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    ReviewManager.shared.requestReviewAfterPositiveAction(using: requestReview)
                }
            }
        }
    }

    private func addLeave() {
        guard canAddLeave else {
            alertMessage = Strings.insufficientLeave
            isSuccess = false
            showingAlert = true
            HapticFeedback.error()
            return
        }

        isSaving = true
        isNoteFocused = false

        let actualEndDate = (leaveType == .half || leaveType == .quarter) ? startDate : endDate
        let today = Calendar.current.startOfDay(for: Date())
        let isPastLeave = startDate < today
        let status: LeaveStatus = isPastLeave ? .used : .planned

        // 보너스 링크는 bonusLeaveId로 추적하므로 원래 leaveType 유지
        let recordType: LeaveType = leaveType

        let record = LeaveRecord(
            startDate: Calendar.current.startOfDay(for: startDate),
            endDate: Calendar.current.startOfDay(for: actualEndDate),
            type: recordType,
            status: status,
            note: note,
            bonusLeaveId: selectedBonusLeave?.id  // 보너스 연결 — 삭제 시 usedDays 복원에 사용
        )
        modelContext.insert(record)

        // 보너스 연차 차감 (일반 연차는 레코드에서 자동 계산)
        if let bonus = selectedBonusLeave {
            bonus.usedDays += leaveDays
            if bonus.remainingDays <= 0 {
                bonus.isUsed = true
            }
        }

        do {
            try modelContext.save()
            let typeName = selectedBonusLeave != nil
                ? Strings.bonusLeaveTypeName(selectedBonusLeave!.type)
                : Strings.leaveTypeName(leaveType)
            alertMessage = Strings.leaveRegistered(typeName)
            isSuccess = true
            // 초기화
            note = ""
            startDate = Date()
            endDate = Date()
            selectedBonusLeave = nil
            HapticFeedback.success()
            ReviewManager.shared.recordLeaveRegistration()
            shouldPromptReview = true
        } catch {
            alertMessage = Strings.saveFailed
            isSuccess = false
            HapticFeedback.error()
            // 롤백
            if let bonus = selectedBonusLeave {
                bonus.usedDays -= leaveDays
                if bonus.isUsed { bonus.isUsed = false }
            }
            modelContext.delete(record)
        }

        isSaving = false
        showingAlert = true
    }
}

// MARK: - 휴가 유형 선택기
struct LeaveTypePicker: View {
    @Binding var selectedType: LeaveType

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(LeaveType.allCases) { type in
                LeaveTypeButton(
                    type: type,
                    isSelected: selectedType == type
                ) {
                    selectedType = type
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct LeaveTypeButton: View {
    let type: LeaveType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticFeedback.selection()
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(Strings.leaveTypeName(type))
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? type.themeColor : Color(.systemGray5))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? type.themeColor : Color(.systemGray4), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - 보너스 연차 관리 뷰
struct BonusLeaveView: View {
    let bonusLeaves: [BonusLeave]

    @Environment(\.modelContext) private var modelContext

    @State private var showingAddSheet = false
    @State private var showingPaywall = false
    @State private var editingBonus: BonusLeave?
    @State private var bonusDays: Double = 1.0
    @State private var bonusType: BonusLeaveType = .compensatory
    @State private var bonusReason = ""
    @State private var hasExpiration = false
    @State private var expirationDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())!

    private var isPro: Bool { ProManager.shared.isPro }

    var activeBonusLeaves: [BonusLeave] {
        bonusLeaves.filter { !$0.isUsed }
    }

    var usedBonusLeaves: [BonusLeave] {
        bonusLeaves.filter { $0.isUsed }
    }

    var body: some View {
        Form {
            // 보너스 연차 추가 (Pro 전용)
            Section {
                Button {
                    if isPro {
                        showingAddSheet = true
                    } else {
                        showingPaywall = true
                    }
                } label: {
                    HStack {
                        Image(systemName: isPro ? "plus.circle.fill" : "lock.fill")
                            .foregroundStyle(isPro ? .green : .secondary)
                        Text(Strings.addBonusLeave)
                            .foregroundStyle(.primary)
                        Spacer()
                        if !isPro {
                            Text("Pro")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.yellow.opacity(0.85))
                                .clipShape(Capsule())
                        } else {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                }
            } footer: {
                Text(isPro ? Strings.bonusLeaveFooter : Strings.bonusLeaveFooterFree)
            }

            // 사용 가능한 보너스 연차
            if !activeBonusLeaves.isEmpty {
                Section(Strings.available) {
                    ForEach(activeBonusLeaves) { bonus in
                        BonusLeaveRow(bonus: bonus, editable: true)
                            .contentShape(Rectangle())
                            .onTapGesture { editingBonus = bonus }
                    }
                    .onDelete(perform: deleteActiveBonus)
                }
            }

            // 사용 완료된 보너스 연차
            if !usedBonusLeaves.isEmpty {
                Section(Strings.usedComplete) {
                    ForEach(usedBonusLeaves) { bonus in
                        BonusLeaveRow(bonus: bonus, editable: false)
                    }
                }
            }

            // 비어있을 때
            if bonusLeaves.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "gift")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text(Strings.noBonusLeave)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
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
    }

    private func deleteActiveBonus(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(activeBonusLeaves[index])
        }
        do {
            try modelContext.save()
            HapticFeedback.success()
        } catch {
            HapticFeedback.error()
        }
    }

    private func saveBonusLeave() {
        guard bonusDays > 0 else {
            HapticFeedback.error()
            return
        }

        let bonus = BonusLeave(
            days: bonusDays,
            type: bonusType,
            reason: bonusReason,
            expirationDate: hasExpiration ? expirationDate : nil
        )
        modelContext.insert(bonus)

        do {
            try modelContext.save()
            HapticFeedback.success()
            bonusDays = 1.0
            bonusType = .compensatory
            bonusReason = ""
            hasExpiration = false
            showingAddSheet = false
        } catch {
            modelContext.delete(bonus)
            HapticFeedback.error()
        }
    }
}

// MARK: - 보너스 연차 추가 시트
struct AddBonusLeaveSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var bonusDays: Double
    @Binding var bonusType: BonusLeaveType
    @Binding var bonusReason: String
    @Binding var hasExpiration: Bool
    @Binding var expirationDate: Date

    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(Strings.leaveDaysSection) {
                    HStack {
                        Text(Strings.daysToAdd)
                        Spacer()
                        TextField(Strings.dayUnitSuffix, value: $bonusDays, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text(Strings.dayUnitSuffix)
                    }

                    // 빠른 선택
                    HStack(spacing: 8) {
                        ForEach([0.25, 0.5, 1.0, 2.0, 3.0], id: \.self) { days in
                            Button {
                                bonusDays = days
                            } label: {
                                Text(days < 1 ? String(format: "%.2g", days) : "\(Int(days))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(bonusDays == days ? Color.blue : Color(.systemGray5))
                                    .foregroundStyle(bonusDays == days ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section(Strings.typeSection) {
                    Picker(Strings.typeSection, selection: $bonusType) {
                        ForEach(BonusLeaveType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(Strings.bonusLeaveTypeName(type))
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(Strings.reasonSection) {
                    TextField(Strings.reasonPlaceholder, text: $bonusReason)
                }

                Section {
                    Toggle(Strings.setExpiration, isOn: $hasExpiration)

                    if hasExpiration {
                        DatePicker(Strings.expirationDate, selection: $expirationDate, in: Date()..., displayedComponents: .date)
                    }
                } footer: {
                    Text(Strings.expirationFooter)
                }
            }
            .navigationTitle(Strings.addBonusLeave)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.save) { onSave() }
                        .disabled(bonusDays <= 0)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - 보너스 연차 수정 시트
struct EditBonusLeaveSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var bonus: BonusLeave

    @State private var editedDays: Double
    @State private var editedType: BonusLeaveType
    @State private var editedReason: String
    @State private var editedHasExpiration: Bool
    @State private var editedExpirationDate: Date

    init(bonus: BonusLeave) {
        self.bonus = bonus
        _editedDays = State(initialValue: bonus.days)
        _editedType = State(initialValue: bonus.type)
        _editedReason = State(initialValue: bonus.reason)
        _editedHasExpiration = State(initialValue: bonus.expirationDate != nil)
        _editedExpirationDate = State(initialValue: bonus.expirationDate ?? Calendar.current.date(byAdding: .month, value: 3, to: Date())!)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(Strings.leaveDaysSection) {
                    HStack {
                        Text(Strings.daysToAdd)
                        Spacer()
                        Text("\(String(format: editedDays == Double(Int(editedDays)) ? "%.0f" : "%.2g", editedDays))\(Strings.dayUnitSuffix)")
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                        Stepper("", value: $editedDays, in: max(bonus.usedDays, 0.25)...365, step: 0.25)
                            .labelsHidden()
                    }
                    HStack(spacing: 8) {
                        ForEach([0.25, 0.5, 1.0, 2.0, 3.0], id: \.self) { d in
                            Button {
                                editedDays = d
                            } label: {
                                Text(d < 1 ? String(format: "%.2g", d) : "\(Int(d))")
                                    .font(.subheadline).fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(editedDays == d ? Color.blue : Color(.systemGray5))
                                    .foregroundStyle(editedDays == d ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                            .disabled(d < bonus.usedDays)
                        }
                    }

                    if bonus.usedDays > 0 {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                                .font(.caption)
                            Text(Strings.bonusEditUsedRemaining(
                                used: String(format: "%.2g", bonus.usedDays),
                                remaining: String(format: "%.2g", max(0, editedDays - bonus.usedDays))
                            ))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section(Strings.typeSection) {
                    Picker(Strings.typeSection, selection: $editedType) {
                        ForEach(BonusLeaveType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(Strings.bonusLeaveTypeName(type))
                            }.tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(Strings.reasonSection) {
                    TextField(Strings.reasonPlaceholder, text: $editedReason)
                }

                Section {
                    Toggle(Strings.setExpiration, isOn: $editedHasExpiration)
                    if editedHasExpiration {
                        DatePicker(Strings.expirationDate, selection: $editedExpirationDate, in: Date()..., displayedComponents: .date)
                    }
                } footer: {
                    Text(Strings.expirationFooter)
                }
            }
            .navigationTitle(Strings.bonusEditTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.save) { saveEdit() }
                        .disabled(editedDays <= 0 || editedDays < bonus.usedDays)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func saveEdit() {
        bonus.days = editedDays
        bonus.type = editedType
        bonus.reason = editedReason
        bonus.expirationDate = editedHasExpiration ? editedExpirationDate : nil
        if bonus.remainingDays > 0 { bonus.isUsed = false }
        try? modelContext.save()
        HapticFeedback.success()
        dismiss()
    }
}

// MARK: - 보너스 연차 행
struct BonusLeaveRow: View {
    let bonus: BonusLeave
    var editable: Bool = false

    var body: some View {
        HStack {
            Image(systemName: bonus.type.icon)
                .foregroundStyle(AppTheme.Colors.bonus)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(Strings.bonusLeaveTypeName(bonus.type))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("\(String(format: "%.1f", bonus.remainingDays))/\(String(format: "%.1f", bonus.days))\(Strings.dayUnitSuffix)")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.Colors.bonus)
                }

                if !bonus.reason.isEmpty {
                    Text(bonus.reason)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text(bonus.grantedDate, format: .dateTime.month().day())
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if let expiration = bonus.expirationDate {
                        Text("~")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(expiration, format: .dateTime.month().day())
                            .font(.caption2)
                            .foregroundStyle(expiration < Date() ? .red : .secondary)
                    }
                }
            }

            Spacer()

            if bonus.isUsed {
                Text(Strings.usedComplete)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            } else if editable {
                Image(systemName: "pencil.circle")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 연차 기록 행
struct LeaveRecordRow: View {
    let record: LeaveRecord

    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"

        if record.type == .half || record.type == .quarter || Calendar.current.isDate(record.startDate, inSameDayAs: record.endDate) {
            return formatter.string(from: record.startDate)
        }
        return "\(formatter.string(from: record.startDate)) - \(formatter.string(from: record.endDate))"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: record.type.icon)
                            .font(.caption)
                        Text(Strings.leaveTypeName(record.type))
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(record.type.themeColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())

                    Text(Strings.leaveStatusName(record.status))
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(record.status.themeColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }

                Text(dateRangeText)
                    .font(.subheadline.bold())

                if !record.note.isEmpty {
                    Text(record.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if record.isRecommended {
                Image(systemName: "sparkles")
                    .foregroundStyle(AppTheme.Colors.compensatory)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(Strings.leaveTypeName(record.type)), \(dateRangeText), \(Strings.leaveStatusName(record.status))")
    }
}

#Preview {
    @Previewable @State var profile = UserProfile(name: "Test", yearStartMonth: 1, totalAnnualLeave: 15, usedLeave: 5)

    AddLeaveView(profile: profile)
}
