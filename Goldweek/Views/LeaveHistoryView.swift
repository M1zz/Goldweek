//
//  LeaveHistoryView.swift
//  Goldweek
//
//  과거 휴가 사용 내역 리스트
//

import SwiftUI
import SwiftData

struct LeaveHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \LeaveRecord.startDate, order: .reverse) private var allRecords: [LeaveRecord]
    @Query private var profiles: [UserProfile]
    @Query private var allBonusLeaves: [BonusLeave]

    @State private var selectedYear: Int
    @State private var selectedStatus: LeaveStatus?
    @State private var selectedType: LeaveType?
    @State private var showingDeleteAlert = false
    @State private var recordToDelete: LeaveRecord?
    @State private var recordToEdit: LeaveRecord?
    @State private var showingDeleteError = false

    private let calendar = Calendar.current
    private let initYearStartMonth: Int

    private var profile: UserProfile? { profiles.first }

    private var yearStartMonth: Int { profile?.yearStartMonth ?? initYearStartMonth }

    init(yearStartMonth: Int = 1) {
        self.initYearStartMonth = yearStartMonth
        let cal = Calendar.current
        let now = Date()
        let month = cal.component(.month, from: now)
        let year = cal.component(.year, from: now)
        let fiscalYear = month >= yearStartMonth ? year : year - 1
        _selectedYear = State(initialValue: fiscalYear)
    }

    // 회계연도 시작일 (yearStartMonth 기준)
    private func fiscalYearStart(for year: Int) -> Date {
        let sm = yearStartMonth
        return calendar.date(from: DateComponents(year: year, month: sm, day: 1)) ?? Date()
    }

    // 회계연도 종료일
    private func fiscalYearEnd(for year: Int) -> Date {
        let start = fiscalYearStart(for: year)
        return calendar.date(byAdding: DateComponents(year: 1, second: -1), to: start) ?? start
    }

    // 날짜가 속한 회계연도
    private func fiscalYear(for date: Date) -> Int {
        let sm = yearStartMonth
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return month >= sm ? year : year - 1
    }

    // 필터링된 기록 (회계연도 기준)
    var filteredRecords: [LeaveRecord] {
        let start = fiscalYearStart(for: selectedYear)
        let end = fiscalYearEnd(for: selectedYear)
        return allRecords.filter { record in
            let inYear = record.startDate >= start && record.startDate <= end

            let statusMatch: Bool
            if let status = selectedStatus {
                statusMatch = record.status == status
            } else {
                statusMatch = true
            }

            let typeMatch: Bool
            if let type = selectedType {
                typeMatch = record.type == type
            } else {
                typeMatch = true
            }

            return inYear && statusMatch && typeMatch
        }
    }

    // 연도별 통계 (회계연도 기준)
    var yearStats: YearStats {
        let start = fiscalYearStart(for: selectedYear)
        let end = fiscalYearEnd(for: selectedYear)
        let records = allRecords.filter { $0.startDate >= start && $0.startDate <= end }
        let today = calendar.startOfDay(for: Date())

        // 내역은 모든 휴가 유형의 일수를 합산 (연차 차감 여부 무관)
        // endDate가 지난 .planned도 완료로 집계
        let totalUsed = records.filter { record in
            record.status == .used ||
            (record.status == .planned && calendar.startOfDay(for: record.endDate) < today)
        }.reduce(0.0) { $0 + $1.effectiveLeaveDays }

        let totalPlanned = records.filter { record in
            record.status == .planned && calendar.startOfDay(for: record.endDate) >= today
        }.reduce(0.0) { $0 + $1.effectiveLeaveDays }

        let usedCount = records.filter { record in
            record.status == .used ||
            (record.status == .planned && calendar.startOfDay(for: record.endDate) < today)
        }.count
        let plannedCount = records.filter { record in
            record.status == .planned && calendar.startOfDay(for: record.endDate) >= today
        }.count
        let cancelledCount = records.filter { $0.status == .cancelled }.count

        return YearStats(
            totalUsed: totalUsed,
            totalPlanned: totalPlanned,
            usedCount: usedCount,
            plannedCount: plannedCount,
            cancelledCount: cancelledCount
        )
    }

    // 월별 그룹화
    var groupedRecords: [(month: Int, records: [LeaveRecord])] {
        let grouped = Dictionary(grouping: filteredRecords) { record in
            calendar.component(.month, from: record.startDate)
        }
        return grouped.map { (month: $0.key, records: $0.value) }
            .sorted { $0.month > $1.month }
    }

    // 사용 가능한 연도 목록 (회계연도 기준)
    var availableYears: [Int] {
        let years = Set(allRecords.map { fiscalYear(for: $0.startDate) })
        let currentFiscal = fiscalYear(for: Date())
        return Array(years.union([currentFiscal, currentFiscal - 1])).sorted(by: >)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 연도 및 필터 선택
                filterSection

                // 연간 통계 요약
                statsSection

                // 기록 리스트
                if filteredRecords.isEmpty {
                    emptyView
                } else {
                    recordsList
                }
            }
            .navigationTitle(Strings.navTitleLeaveHistory)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // 진입 시 현재 회계연도에 기록이 없고 다른 연도엔 있으면 자동 전환
                if filteredRecords.isEmpty && !allRecords.isEmpty {
                    if let mostRecentYearWithData = allRecords
                        .map({ fiscalYear(for: $0.startDate) })
                        .max(), mostRecentYearWithData != selectedYear {
                        selectedYear = mostRecentYearWithData
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Strings.close) {
                        dismiss()
                    }
                }
            }
            .alert(Strings.deleteLeave, isPresented: $showingDeleteAlert) {
                Button(Strings.cancel, role: .cancel) { }
                Button(Strings.delete, role: .destructive) {
                    if let record = recordToDelete {
                        deleteRecord(record)
                    }
                }
            } message: {
                Text(Strings.deleteLeaveConfirm)
            }
            .alert(Strings.alert, isPresented: $showingDeleteError) {
                Button(Strings.confirm, role: .cancel) { }
            } message: {
                Text(Strings.deleteFailed)
            }
            .onAppear {
                repairBonusLeaveUsage()
            }
        }
    }

    // MARK: - 필터 섹션
    private var filterSection: some View {
        VStack(spacing: 12) {
            // 연도 선택
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(availableYears, id: \.self) { year in
                        Button {
                            withAnimation { selectedYear = year }
                        } label: {
                            Text(verbatim: Strings.yearLabel(year))
                                .font(.subheadline.weight(selectedYear == year ? .semibold : .regular))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedYear == year ? Color.blue : Color(.systemGray6))
                                .foregroundStyle(selectedYear == year ? .white : .primary)
                                .clipShape(Capsule())
                        }
                        .voButton(Strings.yearLabel(year))
                        .voSelected(selectedYear == year)
                    }
                }
                .padding(.horizontal)
            }

            // 상태 필터
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: Strings.all,
                        isSelected: selectedStatus == nil,
                        color: .gray
                    ) {
                        withAnimation { selectedStatus = nil }
                    }

                    ForEach(LeaveStatus.allCases) { status in
                        FilterChip(
                            title: Strings.leaveStatusName(status),
                            isSelected: selectedStatus == status,
                            color: statusColor(status)
                        ) {
                            withAnimation {
                                selectedStatus = selectedStatus == status ? nil : status
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            // 유형 필터
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: Strings.allTypes,
                        isSelected: selectedType == nil,
                        color: .gray
                    ) {
                        withAnimation { selectedType = nil }
                    }

                    ForEach(LeaveType.allCases) { type in
                        FilterChip(
                            title: Strings.leaveTypeName(type),
                            isSelected: selectedType == type,
                            color: typeColor(type)
                        ) {
                            withAnimation {
                                selectedType = selectedType == type ? nil : type
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    // MARK: - 통계 섹션
    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: Strings.statUsed,
                value: String(format: "%.1f\(Strings.dayUnitSuffix)", yearStats.totalUsed),
                count: yearStats.usedCount,
                color: .green
            )

            StatCard(
                title: Strings.statPlanned,
                value: String(format: "%.1f\(Strings.dayUnitSuffix)", yearStats.totalPlanned),
                count: yearStats.plannedCount,
                color: .blue
            )

            StatCard(
                title: Strings.statCancelled,
                value: "-",
                count: yearStats.cancelledCount,
                color: .gray
            )
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }

    // MARK: - 기록 리스트
    private var recordsList: some View {
        List {
            ForEach(groupedRecords, id: \.month) { group in
                Section {
                    ForEach(group.records) { record in
                        HistoryRecordRow(record: record)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                recordToEdit = record
                                HapticFeedback.selection()
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    recordToDelete = record
                                    showingDeleteAlert = true
                                } label: {
                                    Label(Strings.delete, systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    recordToEdit = record
                                } label: {
                                    Label(Strings.edit, systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                } header: {
                    Text(Strings.monthLabel(group.month))
                        .font(.headline)
                }
            }
        }
        .listStyle(.insetGrouped)
        .sheet(item: $recordToEdit) { record in
            EditLeaveSheet(record: record, profile: profile, onSave: {
                recordToEdit = nil
            })
        }
    }

    // MARK: - 빈 상태 뷰
    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(.largeTitle))
                .foregroundStyle(.secondary)
                .voDecorative()

            Text(Strings.noLeaveRecords)
                .font(.headline)

            Text(Strings.noLeaveForYear(selectedYear))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }

    // MARK: - Actions
    private func deleteRecord(_ record: LeaveRecord) {
        logInfo("Leave record deleted - \(record.startDate) ~ \(record.endDate)", category: .data)

        // 보너스 연차 레코드 삭제 시 usedDays 복원
        if let bonusId = record.bonusLeaveId,
           let bonus = allBonusLeaves.first(where: { $0.id == bonusId }) {
            let days = record.effectiveLeaveDays
            bonus.usedDays = max(0, bonus.usedDays - days)
            if bonus.isUsed && bonus.remainingDays > 0 {
                bonus.isUsed = false
            }
        }

        let typeRaw = record.type.rawValue
        modelContext.delete(record)
        do {
            try modelContext.save()
            AnalyticsService.logLeaveDeleted(type: typeRaw)
            HapticFeedback.success()
        } catch {
            AnalyticsService.recordError(error, context: ["op": "leave_delete"])
            logError("Failed to delete leave record: \(error.localizedDescription)", category: .data)
            HapticFeedback.error()
            showingDeleteError = true
        }
    }

    /// 휴가 사용 내역을 기준으로 보너스 연차 사용량을 재산정 (미연결 특별휴가 자동 연결 포함)
    private func repairBonusLeaveUsage() {
        if BonusLeaveReconciler.reconcile(records: allRecords, bonuses: allBonusLeaves) {
            try? modelContext.save()
        }
    }

    // MARK: - Helpers
    private func statusColor(_ status: LeaveStatus) -> Color {
        switch status {
        case .planned: return .blue
        case .used: return .green
        case .cancelled: return .gray
        }
    }

    private func typeColor(_ type: LeaveType) -> Color {
        switch type {
        case .annual: return .blue
        case .half: return .cyan
        case .quarter: return .teal
        case .compensatory: return .orange
        case .official: return .purple
        case .sick: return .red
        case .special: return .yellow
        case .businessTrip: return .brown
        }
    }
}

// MARK: - 연간 통계 구조체
struct YearStats {
    let totalUsed: Double
    let totalPlanned: Double
    let usedCount: Int
    let plannedCount: Int
    let cancelledCount: Int
}

// MARK: - 필터 칩
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color.opacity(0.2) : Color(.systemGray6))
                .foregroundStyle(isSelected ? color : .secondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? color : Color.clear, lineWidth: 1)
                )
        }
        .voButton(title)
        .voSelected(isSelected)
    }
}

// MARK: - 통계 카드
struct StatCard: View {
    let title: String
    let value: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)

            Text(Strings.casesCount(count))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .voCard("\(title), \(value), \(Strings.casesCount(count))")
    }
}

// MARK: - 휴가 기록 행
struct HistoryRecordRow: View {
    let record: LeaveRecord

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = Strings.dateRangeFormat
        formatter.locale = Locale(identifier: Strings.localeIdentifier)
        return formatter
    }

    var body: some View {
        HStack(spacing: 12) {
            // 상태 아이콘
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: record.type.icon)
                    .font(.system(.body))
                    .foregroundStyle(statusColor)
                    .voDecorative()
            }

            // 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(Strings.leaveTypeName(record.type))
                        .font(.subheadline.weight(.semibold))

                    Spacer()

                    StatusBadge(status: record.status)
                }

                HStack {
                    Text(dateString)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(formatLeave(record.effectiveLeaveDays))\(Strings.dayUnitSuffix)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !record.note.isEmpty {
                    Text(record.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            // 추천 배지
            if record.isRecommended {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .voDecorative()
            }
        }
        .padding(.vertical, 4)
        .voCard(accessibilityText, hint: Strings.editLeaveHint)
    }

    private var accessibilityText: String {
        var parts = [
            Strings.leaveTypeName(record.type),
            Strings.leaveStatusName(record.status),
            dateString,
            "\(formatLeave(record.effectiveLeaveDays))\(Strings.dayUnitSuffix)"
        ]
        if record.isRecommended { parts.append(Strings.recommendedMark) }
        if !record.note.isEmpty { parts.append(record.note) }
        return parts.joined(separator: ", ")
    }

    private var dateString: String {
        if record.daysCount == 1 {
            return dateFormatter.string(from: record.startDate)
        } else {
            return "\(dateFormatter.string(from: record.startDate)) ~ \(dateFormatter.string(from: record.endDate))"
        }
    }

    private var statusColor: Color {
        switch record.status {
        case .planned: return .blue
        case .used: return .green
        case .cancelled: return .gray
        }
    }
}

// MARK: - 상태 배지
struct StatusBadge: View {
    let status: LeaveStatus

    var body: some View {
        Text(Strings.leaveStatusName(status))
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var color: Color {
        switch status {
        case .planned: return .blue
        case .used: return .green
        case .cancelled: return .gray
        }
    }
}

// MARK: - 연차 수정 시트
struct EditLeaveSheet: View {
    @Bindable var record: LeaveRecord
    var profile: UserProfile?
    let onSave: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allLeaveRecords: [LeaveRecord]
    @Query private var allBonusLeaves: [BonusLeave]

    @State private var startDate: Date
    @State private var endDate: Date
    @State private var leaveType: LeaveType
    @State private var leaveStatus: LeaveStatus
    @State private var note: String
    @State private var showingAlert = false
    @State private var alertMessage = ""

    private let calendar = Calendar.current

    init(record: LeaveRecord, profile: UserProfile?, onSave: @escaping () -> Void) {
        self.record = record
        self.profile = profile
        self.onSave = onSave
        _startDate = State(initialValue: record.startDate)
        _endDate = State(initialValue: record.endDate)
        _leaveType = State(initialValue: record.type)
        _leaveStatus = State(initialValue: record.status)
        _note = State(initialValue: record.note)
    }

    var originalLeaveDays: Double {
        if record.type == .half { return 0.5 }
        if record.type == .quarter { return 0.25 }
        let days = calendar.dateComponents([.day], from: record.startDate, to: record.endDate).day ?? 0
        return Double(max(days + 1, 1))
    }

    var newLeaveDays: Double {
        if leaveType == .half { return 0.5 }
        if leaveType == .quarter { return 0.25 }
        let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return Double(max(days + 1, 1))
    }

    var leaveDaysDifference: Double {
        let originalDeductsFromAnnual = record.deductsFromAnnualLeave
        let newDeductsFromAnnual = leaveType.deductsFromAnnual && record.bonusLeaveId == nil
        if !newDeductsFromAnnual && !originalDeductsFromAnnual {
            return 0
        }
        let originalDeduction = originalDeductsFromAnnual ? originalLeaveDays : 0
        let newDeduction = newDeductsFromAnnual ? newLeaveDays : 0
        return newDeduction - originalDeduction
    }

    // 현재 레코드를 제외한 다른 레코드들의 committed leave
    var committedExcludingSelf: Double {
        let others = allLeaveRecords.filter { $0.id != record.id }
        let active = others.filter { $0.status == .used || $0.status == .planned }
        let deducting = active.filter { $0.deductsFromAnnualLeave }
        return deducting.reduce(0.0) { $0 + $1.effectiveLeaveDays }
    }

    var availableForEdit: Double {
        guard let profile = profile else { return 0 }
        return max(0, profile.totalAnnualLeave - committedExcludingSelf)
    }

    var body: some View {
        NavigationStack {
            Form {
                // 휴가 유형
                Section(Strings.leaveTypeSection) {
                    Picker(Strings.typeSection, selection: $leaveType) {
                        ForEach(LeaveType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(Strings.leaveTypeName(type))
                            }
                            .tag(type)
                        }
                    }
                }

                // 상태
                Section(Strings.statusSection) {
                    Picker(Strings.statusSection, selection: $leaveStatus) {
                        ForEach(LeaveStatus.allCases) { status in
                            Text(Strings.leaveStatusName(status)).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 날짜 선택
                Section(Strings.dateSection) {
                    DatePicker(Strings.startDate, selection: $startDate, displayedComponents: .date)

                    if leaveType != .half && leaveType != .quarter {
                        DatePicker(Strings.endDate, selection: $endDate, in: startDate..., displayedComponents: .date)
                    }

                    HStack {
                        Text(Strings.daysUsed)
                        Spacer()
                        Text("\(String(format: "%.1f", newLeaveDays))\(Strings.dayUnitSuffix)")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                    }

                    if leaveDaysDifference != 0 {
                        HStack {
                            Image(systemName: leaveDaysDifference > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .foregroundStyle(leaveDaysDifference > 0 ? .red : .green)
                            Text(leaveDaysDifference > 0
                                 ? Strings.additionalLeaveUsed(String(format: "%.1f", leaveDaysDifference))
                                 : Strings.leaveRestored(String(format: "%.1f", abs(leaveDaysDifference))))
                                .font(.caption)
                                .foregroundStyle(leaveDaysDifference > 0 ? .red : .green)
                        }
                    }
                }

                // 메모
                Section(Strings.memo) {
                    TextField(Strings.leavePurpose, text: $note)
                }

                // 일정 미리보기
                Section(Strings.schedulePreview) {
                    RecommendationDatePreview(
                        startDate: startDate,
                        endDate: leaveType == .half || leaveType == .quarter ? startDate : endDate
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                // 휴가 일정에 맞는 액티비티/여행 추천
                // .used 상태(과거)면 의미 없으므로 숨김, 보너스/병가/공가 등 비차감 유형도 숨김
                if leaveStatus == .planned, leaveType.deductsFromAnnual, let profile = profile {
                    Section {
                        LeaveActivityRecommendations(
                            leave: record,
                            originCountry: profile.country
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationTitle(Strings.navTitleEditLeave)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.save) { saveChanges() }
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
        }
    }

    private func saveChanges() {
        // 잔여 연차 검증 (레코드 기반, leisure 모드는 검증 없음, 보너스 연차는 제외)
        let isLeisure = profile?.userType == .leisure
        let newDeductsFromAnnual = leaveType.deductsFromAnnual && record.bonusLeaveId == nil
        if !isLeisure, newDeductsFromAnnual {
            let needed = leaveType == .half ? 0.5 : leaveType == .quarter ? 0.25 : newLeaveDays
            if needed > availableForEdit {
                alertMessage = Strings.insufficientLeave
                showingAlert = true
                HapticFeedback.error()
                return
            }
        }

        // 보너스 연차 레코드를 편집하면 usedDays 차분 반영
        if let bonusId = record.bonusLeaveId,
           let bonus = allBonusLeaves.first(where: { $0.id == bonusId }) {
            let diff = newLeaveDays - originalLeaveDays
            if abs(diff) > 0.001 {
                bonus.usedDays = max(0, bonus.usedDays + diff)
                if bonus.isUsed && bonus.remainingDays > 0 { bonus.isUsed = false }
            }
        }

        // 기록 업데이트 (records가 source of truth이므로 profile.usedLeave 조정 불필요)
        record.startDate = startDate
        record.endDate = leaveType == .half || leaveType == .quarter ? startDate : endDate
        record.type = leaveType
        record.status = leaveStatus
        record.note = note

        do {
            try modelContext.save()
            HapticFeedback.success()
            onSave()
            dismiss()
        } catch {
            alertMessage = Strings.saveFailed
            showingAlert = true
            HapticFeedback.error()
        }
    }
}

#Preview {
    LeaveHistoryView()
        .modelContainer(for: [LeaveRecord.self, UserProfile.self], inMemory: true)
}
