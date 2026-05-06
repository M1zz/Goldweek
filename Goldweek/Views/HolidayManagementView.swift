//
//  HolidayManagementView.swift
//  Goldweek
//
//  공휴일 관리 — 기본 공휴일 숨기기/복원, 사용자 정의 공휴일 추가/삭제

import SwiftUI
import SwiftData

struct HolidayManagementView: View {
    let country: Country

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomHoliday.date) private var customHolidays: [CustomHoliday]
    @AppStorage("hiddenHolidayDates") private var hiddenHolidayDatesRaw: String = ""

    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showingAddSheet = false
    @State private var holidayToDelete: CustomHoliday?
    @State private var showingDeleteAlert = false

    private let holidayService = HolidayService()
    private let calendar = Calendar.current

    // MARK: - Hidden dates helpers

    private var hiddenDates: Set<String> {
        Set(hiddenHolidayDatesRaw.split(separator: ",").map(String.init).filter { !$0.isEmpty })
    }

    private func isHidden(_ date: Date) -> Bool {
        hiddenDates.contains(holidayService.dateKey(date))
    }

    private func toggleHidden(_ date: Date) {
        var dates = hiddenDates
        let key = holidayService.dateKey(date)
        if dates.contains(key) { dates.remove(key) } else { dates.insert(key) }
        hiddenHolidayDatesRaw = dates.joined(separator: ",")
    }

    // MARK: - Data

    private var availableYears: [Int] {
        let y = calendar.component(.year, from: Date())
        return Array((y - 1)...(y + 2))
    }

    private var builtInHolidays: [Holiday] {
        holidayService.getHolidays(for: selectedYear, country: country)
    }

    private var customHolidaysThisYear: [CustomHoliday] {
        customHolidays.filter { calendar.component(.year, from: $0.date) == selectedYear }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 연도 선택 바
                yearPickerBar
                    .background(Color(.systemBackground))

                Divider()

                // 기본 공휴일 섹션
                builtInSection

                // 내 공휴일 섹션
                customSection

                // 복원 버튼
                if !hiddenDates.isEmpty {
                    Button(role: .destructive) {
                        hiddenHolidayDatesRaw = ""
                    } label: {
                        Label(Strings.holidayMgmtRestoreAll, systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(Strings.holidayMgmtTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddSheet) {
            AddCustomHolidaySheet(defaultYear: selectedYear) { date, name in
                let holiday = CustomHoliday(date: date, name: name)
                modelContext.insert(holiday)
                try? modelContext.save()
            }
        }
        .alert(Strings.holidayDeleteAlertTitle, isPresented: $showingDeleteAlert) {
            Button(Strings.cancel, role: .cancel) { }
            Button(Strings.commonDelete, role: .destructive) {
                if let h = holidayToDelete {
                    modelContext.delete(h)
                    try? modelContext.save()
                    holidayToDelete = nil
                }
            }
        } message: {
            Text(Strings.holidayDeleteAlertMessage)
        }
    }

    // MARK: - Subviews

    private var yearPickerBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(availableYears, id: \.self) { year in
                    yearButton(for: year)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }

    private func yearButton(for year: Int) -> some View {
        let label: String = Strings.yearLabel(year)
        let isSelected = selectedYear == year
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedYear = year }
        } label: {
            Text(label)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }

    private var builtInSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack {
                Text(Strings.holidayDefaultSection)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(Strings.itemCount(builtInHolidays.count))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 8)

            // 항목 목록
            VStack(spacing: 0) {
                ForEach(builtInHolidays, id: \.date) { holiday in
                    BuiltInHolidayRow(
                        holiday: holiday,
                        isHidden: isHidden(holiday.date),
                        onToggle: { toggleHidden(holiday.date) }
                    )
                    Divider().padding(.leading, 60)
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            Text(Strings.holidayDefaultFooter)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.top, 6)
        }
    }

    private var customSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack {
                Text(Strings.holidayCustomSection)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    showingAddSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text(Strings.commonAdd)
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.purple)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 8)

            VStack(spacing: 0) {
                if customHolidaysThisYear.isEmpty {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.dashed")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text(Strings.holidayCustomEmpty)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                } else {
                    ForEach(customHolidaysThisYear) { holiday in
                        CustomHolidayRow(
                            holiday: holiday,
                            onDelete: {
                                holidayToDelete = holiday
                                showingDeleteAlert = true
                            }
                        )
                        if holiday.id != customHolidaysThisYear.last?.id {
                            Divider().padding(.leading, 60)
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            Text(Strings.holidayCustomFooter)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.top, 6)
        }
    }
}

// MARK: - 기본 공휴일 행
private struct BuiltInHolidayRow: View {
    let holiday: Holiday
    let isHidden: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // 날짜 컬럼
            VStack(alignment: .center, spacing: 1) {
                Text(holiday.date, format: .dateTime.month(.abbreviated))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(holiday.date, format: .dateTime.day())
                    .font(.headline)
                    .foregroundStyle(isHidden ? Color.secondary : Color.red)
            }
            .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(holiday.name)
                    .font(.subheadline)
                    .foregroundStyle(isHidden ? Color.secondary : Color.primary)
                    .strikethrough(isHidden, color: .secondary)
                if holiday.isSubstitute {
                    Text(Strings.holidaySubstitute)
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { !isHidden },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// MARK: - 커스텀 공휴일 행
private struct CustomHolidayRow: View {
    let holiday: CustomHoliday
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .center, spacing: 1) {
                Text(holiday.date, format: .dateTime.month(.abbreviated))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(holiday.date, format: .dateTime.day())
                    .font(.headline)
                    .foregroundStyle(.purple)
            }
            .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(holiday.name)
                    .font(.subheadline)
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                    Text(Strings.holidayAddedByMe)
                        .font(.caption2)
                }
                .foregroundStyle(.purple)
            }

            Spacer()

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
                    .font(.subheadline)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// MARK: - 커스텀 공휴일 추가 시트
struct AddCustomHolidaySheet: View {
    let defaultYear: Int
    let onSave: (Date, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var date: Date
    @State private var name = ""

    init(defaultYear: Int, onSave: @escaping (Date, String) -> Void) {
        self.defaultYear = defaultYear
        self.onSave = onSave
        var comps = DateComponents()
        comps.year = defaultYear; comps.month = 1; comps.day = 1
        _date = State(initialValue: Calendar.current.date(from: comps) ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(Strings.holidayDateSection) {
                    DatePicker(Strings.holidayDatePickerLabel, selection: $date, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
                Section(Strings.holidayNameSection) {
                    TextField(Strings.holidayNamePlaceholder, text: $name)
                        .submitLabel(.done)
                }
            }
            .navigationTitle(Strings.holidayAddTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.commonAdd) {
                        let trimmed = name.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        onSave(date, trimmed)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large])
    }
}

#Preview {
    NavigationStack {
        HolidayManagementView(country: .korea)
    }
    .modelContainer(for: [CustomHoliday.self], inMemory: true)
}
