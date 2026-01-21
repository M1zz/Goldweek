//
//  LeaveHistoryView.swift
//  LeaveWise
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

    @State private var selectedYear: Int
    @State private var selectedStatus: LeaveStatus?
    @State private var selectedType: LeaveType?
    @State private var showingDeleteAlert = false
    @State private var recordToDelete: LeaveRecord?
    @State private var recordToEdit: LeaveRecord?

    private let calendar = Calendar.current

    private var profile: UserProfile? {
        profiles.first
    }

    init() {
        _selectedYear = State(initialValue: Calendar.current.component(.year, from: Date()))
    }

    // 필터링된 기록
    var filteredRecords: [LeaveRecord] {
        allRecords.filter { record in
            let recordYear = calendar.component(.year, from: record.startDate)
            let yearMatch = recordYear == selectedYear

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

            return yearMatch && statusMatch && typeMatch
        }
    }

    // 연도별 통계
    var yearStats: YearStats {
        let records = allRecords.filter {
            calendar.component(.year, from: $0.startDate) == selectedYear
        }

        let totalUsed = records.filter { $0.status == .used }
            .reduce(0.0) { $0 + $1.type.leaveValue * Double($1.daysCount) }

        let totalPlanned = records.filter { $0.status == .planned }
            .reduce(0.0) { $0 + $1.type.leaveValue * Double($1.daysCount) }

        let usedCount = records.filter { $0.status == .used }.count
        let plannedCount = records.filter { $0.status == .planned }.count
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

    // 사용 가능한 연도 목록
    var availableYears: [Int] {
        let years = Set(allRecords.map { calendar.component(.year, from: $0.startDate) })
        let currentYear = calendar.component(.year, from: Date())
        return Array(Set(years).union([currentYear, currentYear - 1])).sorted(by: >)
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
            .navigationTitle("휴가 사용 내역")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .alert("휴가 삭제", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    if let record = recordToDelete {
                        deleteRecord(record)
                    }
                }
            } message: {
                Text("이 휴가 기록을 삭제하시겠습니까?")
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
                            Text(verbatim: "\(year)년")
                                .font(.subheadline.weight(selectedYear == year ? .semibold : .regular))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedYear == year ? Color.blue : Color(.systemGray6))
                                .foregroundStyle(selectedYear == year ? .white : .primary)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal)
            }

            // 상태 필터
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "전체",
                        isSelected: selectedStatus == nil,
                        color: .gray
                    ) {
                        withAnimation { selectedStatus = nil }
                    }

                    ForEach(LeaveStatus.allCases) { status in
                        FilterChip(
                            title: status.rawValue,
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
                        title: "전체 유형",
                        isSelected: selectedType == nil,
                        color: .gray
                    ) {
                        withAnimation { selectedType = nil }
                    }

                    ForEach(LeaveType.allCases) { type in
                        FilterChip(
                            title: type.rawValue,
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
                title: "사용 완료",
                value: String(format: "%.1f일", yearStats.totalUsed),
                count: yearStats.usedCount,
                color: .green
            )

            StatCard(
                title: "예정",
                value: String(format: "%.1f일", yearStats.totalPlanned),
                count: yearStats.plannedCount,
                color: .blue
            )

            StatCard(
                title: "취소",
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
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    recordToEdit = record
                                } label: {
                                    Label("수정", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                } header: {
                    Text("\(group.month)월")
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
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("휴가 기록이 없습니다")
                .font(.headline)

            Text(verbatim: "\(selectedYear)년에 등록된 휴가가 없습니다.\n새로운 휴가를 등록해보세요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }

    // MARK: - Actions
    private func deleteRecord(_ record: LeaveRecord) {
        logInfo("휴가 기록 삭제 - \(record.startDate) ~ \(record.endDate)", category: .data)

        // 연차 복원
        if let profile = profile, record.type.deductsFromAnnual && record.status != .cancelled {
            let days = record.type == .half ? 0.5 : (record.type == .quarter ? 0.25 : Double(record.daysCount))
            profile.usedLeave -= days
            logInfo("연차 복원: \(days)일", category: .data)
        }

        modelContext.delete(record)
        do {
            try modelContext.save()
            HapticFeedback.success()
        } catch {
            // 롤백
            if let profile = profile, record.type.deductsFromAnnual && record.status != .cancelled {
                let days = record.type == .half ? 0.5 : (record.type == .quarter ? 0.25 : Double(record.daysCount))
                profile.usedLeave += days
            }
            logError("휴가 기록 삭제 실패: \(error.localizedDescription)", category: .data)
            HapticFeedback.error()
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

            Text("\(count)건")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 휴가 기록 행
struct HistoryRecordRow: View {
    let record: LeaveRecord

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E)"
        formatter.locale = Locale(identifier: "ko_KR")
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
                    .font(.system(size: 18))
                    .foregroundStyle(statusColor)
            }

            // 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(record.type.rawValue)
                        .font(.subheadline.weight(.semibold))

                    Spacer()

                    StatusBadge(status: record.status)
                }

                HStack {
                    Text(dateString)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if record.daysCount > 1 {
                        Text("(\(record.daysCount)일)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
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
            }
        }
        .padding(.vertical, 4)
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
        Text(status.rawValue)
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
        if !leaveType.deductsFromAnnual && !record.type.deductsFromAnnual {
            return 0
        }
        let originalDeduction = record.type.deductsFromAnnual ? originalLeaveDays : 0
        let newDeduction = leaveType.deductsFromAnnual ? newLeaveDays : 0
        return newDeduction - originalDeduction
    }

    var body: some View {
        NavigationStack {
            Form {
                // 휴가 유형
                Section("휴가 유형") {
                    Picker("유형", selection: $leaveType) {
                        ForEach(LeaveType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                }

                // 상태
                Section("상태") {
                    Picker("상태", selection: $leaveStatus) {
                        ForEach(LeaveStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 날짜 선택
                Section("날짜") {
                    DatePicker("시작일", selection: $startDate, displayedComponents: .date)

                    if leaveType != .half && leaveType != .quarter {
                        DatePicker("종료일", selection: $endDate, in: startDate..., displayedComponents: .date)
                    }

                    HStack {
                        Text("사용일수")
                        Spacer()
                        Text("\(String(format: "%.1f", newLeaveDays))일")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                    }

                    if leaveDaysDifference != 0 {
                        HStack {
                            Image(systemName: leaveDaysDifference > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .foregroundStyle(leaveDaysDifference > 0 ? .red : .green)
                            Text(leaveDaysDifference > 0 ? "연차 \(String(format: "%.1f", leaveDaysDifference))일 추가 사용" : "연차 \(String(format: "%.1f", abs(leaveDaysDifference)))일 복원")
                                .font(.caption)
                                .foregroundStyle(leaveDaysDifference > 0 ? .red : .green)
                        }
                    }
                }

                // 메모
                Section("메모") {
                    TextField("휴가 목적", text: $note)
                }

                // 일정 미리보기
                Section("일정 미리보기") {
                    RecommendationDatePreview(
                        startDate: startDate,
                        endDate: leaveType == .half || leaveType == .quarter ? startDate : endDate
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("휴가 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { saveChanges() }
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
    }

    private func saveChanges() {
        // 연차 차감량 조정
        if let profile = profile {
            let difference = leaveDaysDifference
            if profile.remainingLeave - difference < 0 && difference > 0 {
                alertMessage = "연차가 부족합니다."
                showingAlert = true
                HapticFeedback.error()
                return
            }
            profile.usedLeave += difference
        }

        // 기록 업데이트
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
            // 롤백
            if let profile = profile {
                profile.usedLeave -= leaveDaysDifference
            }
            alertMessage = "저장에 실패했습니다."
            showingAlert = true
            HapticFeedback.error()
        }
    }
}

#Preview {
    LeaveHistoryView()
        .modelContainer(for: [LeaveRecord.self, UserProfile.self], inMemory: true)
}
