//
//  AddLeaveView.swift
//  LeaveWise
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

    var totalBonusLeave: Double {
        bonusLeaves.filter { !$0.isUsed }.reduce(0) { $0 + $1.days }
    }

    var totalAvailableLeave: Double {
        profile.remainingLeave + totalBonusLeave
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 연차 현황 요약
                LeaveStatusHeader(
                    remainingLeave: profile.remainingLeave,
                    bonusLeave: totalBonusLeave,
                    totalAvailable: totalAvailableLeave
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("연차 현황: 기본 연차 \(String(format: "%.1f", profile.remainingLeave))일, 보너스 \(String(format: "%.1f", totalBonusLeave))일, 총 사용 가능 \(String(format: "%.1f", totalAvailableLeave))일")

                // 탭 선택
                Picker("관리 유형", selection: $selectedTab) {
                    Text("휴가 등록").tag(0)
                    Text("연차 추가").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedTab) { _, _ in
                    HapticFeedback.selection()
                }

                if selectedTab == 0 {
                    LeaveRegistrationView(
                        profile: profile,
                        totalAvailableLeave: totalAvailableLeave,
                        leaveRecords: Array(leaveRecords.prefix(5))
                    )
                } else {
                    BonusLeaveView(bonusLeaves: bonusLeaves)
                }
            }
            .navigationTitle("연차 관리")
        }
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
                Text("기본 연차")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Text("\(String(format: "%.1f", remainingLeave))일")
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.Colors.brand)
            }

            if bonusLeave > 0 {
                Text("+")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("보너스")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Text("\(String(format: "%.1f", bonusLeave))일")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.Colors.compensatory)
                }

                Text("=")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("총 사용 가능")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Text("\(String(format: "%.1f", totalAvailable))일")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.Colors.success)
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

    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var leaveType: LeaveType = .annual
    @State private var note = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var isSaving = false
    @FocusState private var isNoteFocused: Bool

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

    var requiredAnnualLeave: Double {
        leaveType.deductsFromAnnual ? leaveDays : 0
    }

    var canAddLeave: Bool {
        if leaveType.deductsFromAnnual {
            return totalAvailableLeave >= leaveDays && startDate <= endDate
        }
        return startDate <= endDate
    }

    var body: some View {
        Form {
            // 휴가 유형
            Section("휴가 유형") {
                LeaveTypePicker(selectedType: $leaveType)
            }

            // 연차 차감 안내
            if !leaveType.deductsFromAnnual {
                Section {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                        Text("\(leaveType.rawValue)은(는) 연차에서 차감되지 않습니다.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // 날짜 선택
            Section("날짜 선택") {
                DatePicker("시작일", selection: $startDate, displayedComponents: .date)

                if leaveType != .half && leaveType != .quarter {
                    DatePicker("종료일", selection: $endDate, in: startDate..., displayedComponents: .date)
                }

                HStack {
                    Text("사용일수")
                    Spacer()
                    Text("\(String(format: "%.1f", leaveDays))일")
                        .foregroundStyle(.blue)
                        .fontWeight(.semibold)
                }
            }

            // 메모
            Section("메모 (선택)") {
                TextField("휴가 목적을 입력하세요", text: $note)
                    .focused($isNoteFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        isNoteFocused = false
                    }
                    .accessibilityLabel("휴가 메모")
                    .accessibilityHint("휴가 목적이나 설명을 입력하세요")
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
                            Text("휴가 등록하기")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(!canAddLeave || isSaving)
                .foregroundStyle(canAddLeave ? .white : .gray)
                .listRowBackground(canAddLeave ? AppTheme.Colors.brand : Color.gray.opacity(0.3))
                .accessibilityLabel("휴가 등록하기")
                .accessibilityHint(canAddLeave ? "\(leaveType.rawValue) \(String(format: "%.1f", leaveDays))일을 등록합니다" : "연차가 부족하거나 날짜가 올바르지 않습니다")
            }

            // 최근 등록 내역
            if !leaveRecords.isEmpty {
                Section("최근 등록 내역") {
                    ForEach(leaveRecords) { record in
                        LeaveRecordRow(record: record)
                    }
                }
            }
        }
        .onChange(of: leaveType) { _, newValue in
            if newValue == .half || newValue == .quarter {
                endDate = startDate
            }
        }
        .alert("알림", isPresented: $showingAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func addLeave() {
        guard canAddLeave else {
            alertMessage = "연차가 부족합니다."
            isSuccess = false
            showingAlert = true
            HapticFeedback.error()
            return
        }

        isSaving = true
        isNoteFocused = false

        let actualEndDate = (leaveType == .half || leaveType == .quarter) ? startDate : endDate

        let record = LeaveRecord(
            startDate: startDate,
            endDate: actualEndDate,
            type: leaveType,
            status: .planned,
            note: note
        )

        modelContext.insert(record)

        // 연차 차감 (연차/반차만)
        if leaveType.deductsFromAnnual {
            profile.usedLeave += leaveDays
        }

        do {
            try modelContext.save()
            // 초기화
            note = ""
            startDate = Date()
            endDate = Date()

            alertMessage = "\(leaveType.rawValue)이(가) 등록되었습니다!"
            isSuccess = true
            HapticFeedback.success()
        } catch {
            alertMessage = "저장에 실패했습니다. 다시 시도해주세요.\n\(error.localizedDescription)"
            isSuccess = false
            HapticFeedback.error()
            // 롤백
            if leaveType.deductsFromAnnual {
                profile.usedLeave -= leaveDays
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
                Text(type.rawValue)
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
        .accessibilityLabel("\(type.rawValue) 휴가")
        .accessibilityHint(type.deductsFromAnnual ? "연차에서 차감됩니다" : "연차에서 차감되지 않습니다")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - 보너스 연차 관리 뷰
struct BonusLeaveView: View {
    let bonusLeaves: [BonusLeave]

    @Environment(\.modelContext) private var modelContext

    @State private var showingAddSheet = false
    @State private var bonusDays: Double = 1.0
    @State private var bonusType: BonusLeaveType = .compensatory
    @State private var bonusReason = ""
    @State private var hasExpiration = false
    @State private var expirationDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())!

    var activeBonusLeaves: [BonusLeave] {
        bonusLeaves.filter { !$0.isUsed }
    }

    var usedBonusLeaves: [BonusLeave] {
        bonusLeaves.filter { $0.isUsed }
    }

    var body: some View {
        Form {
            // 보너스 연차 추가
            Section {
                Button {
                    showingAddSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.green)
                        Text("보너스 연차 추가")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            } footer: {
                Text("대체휴무, 포상휴가, 리프레시휴가 등 추가로 받은 연차를 기록합니다.")
            }

            // 사용 가능한 보너스 연차
            if !activeBonusLeaves.isEmpty {
                Section("사용 가능") {
                    ForEach(activeBonusLeaves) { bonus in
                        BonusLeaveRow(bonus: bonus)
                    }
                    .onDelete(perform: deleteActiveBonus)
                }
            }

            // 사용 완료된 보너스 연차
            if !usedBonusLeaves.isEmpty {
                Section("사용 완료") {
                    ForEach(usedBonusLeaves) { bonus in
                        BonusLeaveRow(bonus: bonus)
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
                        Text("등록된 보너스 연차가 없습니다")
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
            // 초기화
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
                Section("연차 일수") {
                    HStack {
                        Text("추가할 일수")
                        Spacer()
                        TextField("일수", value: $bonusDays, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("일")
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

                Section("유형") {
                    Picker("유형", selection: $bonusType) {
                        ForEach(BonusLeaveType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("사유") {
                    TextField("예: 휴일근무 대체, 프로젝트 포상 등", text: $bonusReason)
                }

                Section {
                    Toggle("만료일 설정", isOn: $hasExpiration)

                    if hasExpiration {
                        DatePicker("만료일", selection: $expirationDate, in: Date()..., displayedComponents: .date)
                    }
                } footer: {
                    Text("만료일을 설정하지 않으면 연말까지 사용 가능합니다.")
                }
            }
            .navigationTitle("보너스 연차 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { onSave() }
                        .disabled(bonusDays <= 0)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - 보너스 연차 행
struct BonusLeaveRow: View {
    let bonus: BonusLeave

    var body: some View {
        HStack {
            Image(systemName: bonus.type.icon)
                .foregroundStyle(.orange)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(bonus.type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("\(String(format: "%.1f", bonus.days))일")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
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
                Text("사용완료")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
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
                        Text(record.type.rawValue)
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(record.type.themeColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())

                    Text(record.status.rawValue)
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
        .accessibilityLabel("\(record.type.rawValue), \(dateRangeText), \(record.status.rawValue)")
    }
}

#Preview {
    @Previewable @State var profile = UserProfile(name: "홍길동", yearStartMonth: 1, totalAnnualLeave: 15, usedLeave: 5)

    AddLeaveView(profile: profile)
}
