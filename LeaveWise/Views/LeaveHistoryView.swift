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

    @State private var selectedYear: Int
    @State private var selectedStatus: LeaveStatus?
    @State private var selectedType: LeaveType?
    @State private var showingDeleteAlert = false
    @State private var recordToDelete: LeaveRecord?

    private let calendar = Calendar.current

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
                            Text("\(year)년")
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
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    recordToDelete = record
                                    showingDeleteAlert = true
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }

                                if record.status == .planned {
                                    Button {
                                        cancelRecord(record)
                                    } label: {
                                        Label("취소", systemImage: "xmark.circle")
                                    }
                                    .tint(.orange)
                                }
                            }
                    }
                } header: {
                    Text("\(group.month)월")
                        .font(.headline)
                }
            }
        }
        .listStyle(.insetGrouped)
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

            Text("\(selectedYear)년에 등록된 휴가가 없습니다.\n새로운 휴가를 등록해보세요.")
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
        modelContext.delete(record)
        do {
            try modelContext.save()
            HapticFeedback.success()
        } catch {
            logError("휴가 기록 삭제 실패: \(error.localizedDescription)", category: .data)
            HapticFeedback.error()
        }
    }

    private func cancelRecord(_ record: LeaveRecord) {
        logInfo("휴가 취소 처리 - \(record.startDate) ~ \(record.endDate)", category: .data)
        record.status = .cancelled
        do {
            try modelContext.save()
            HapticFeedback.success()
        } catch {
            logError("휴가 취소 실패: \(error.localizedDescription)", category: .data)
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

#Preview {
    LeaveHistoryView()
        .modelContainer(for: [LeaveRecord.self], inMemory: true)
}
