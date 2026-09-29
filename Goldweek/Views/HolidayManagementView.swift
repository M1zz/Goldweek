//
//  HolidayManagementView.swift
//  Goldweek
//
//  공휴일 관리 — 기본 공휴일 숨기기/복원, 사용자 정의 공휴일 추가/삭제, 방학 추가/수정/삭제

import SwiftUI
import SwiftData

struct HolidayManagementView: View {
    let country: Country

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomHoliday.date) private var customHolidays: [CustomHoliday]
    @Query(sort: \SchoolBreak.startDate) private var schoolBreaks: [SchoolBreak]
    @AppStorage("hiddenHolidayDates") private var hiddenHolidayDatesRaw: String = ""

    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showingAddSheet = false
    @State private var holidayToDelete: CustomHoliday?
    @State private var showingDeleteAlert = false
    @State private var showingAddBreak = false
    @State private var breakToEdit: SchoolBreak?
    @State private var breakToDelete: SchoolBreak?
    @State private var errorMessage = ""
    @State private var showingErrorAlert = false

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

    /// 선택한 연도에 걸친 방학 (겨울방학처럼 해를 넘기는 것도 포함)
    private var breaksThisYear: [SchoolBreak] {
        schoolBreaks.filter {
            calendar.component(.year, from: $0.startDate) <= selectedYear
                && calendar.component(.year, from: $0.endDate) >= selectedYear
        }
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

                // 방학 섹션
                breakSection

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
                do {
                    try modelContext.save()
                } catch {
                    modelContext.delete(holiday)
                    errorMessage = Strings.saveFailed
                    showingErrorAlert = true
                    HapticFeedback.error()
                }
            }
        }
        .sheet(isPresented: $showingAddBreak) {
            SchoolBreakEditSheet(defaultYear: selectedYear, existing: nil) { name, start, end, kind in
                let item = SchoolBreak(name: name, startDate: start, endDate: end, kind: kind)
                modelContext.insert(item)
                saveOrReport { modelContext.delete(item) }
            }
        }
        .sheet(item: $breakToEdit) { item in
            SchoolBreakEditSheet(defaultYear: selectedYear, existing: item) { name, start, end, kind in
                item.name = name
                item.startDate = calendar.startOfDay(for: start)
                item.endDate = calendar.startOfDay(for: end)
                item.kind = kind
                saveOrReport { modelContext.rollback() }
            }
        }
        .alert(Strings.breakDeleteAlertTitle, isPresented: Binding(
            get: { breakToDelete != nil },
            set: { if !$0 { breakToDelete = nil } }
        )) {
            Button(Strings.cancel, role: .cancel) { breakToDelete = nil }
            Button(Strings.commonDelete, role: .destructive) {
                if let item = breakToDelete {
                    modelContext.delete(item)
                    saveOrReport { }
                }
                breakToDelete = nil
            }
        } message: {
            Text(breakToDelete?.name ?? "")
        }
        .alert(Strings.holidayDeleteAlertTitle, isPresented: $showingDeleteAlert) {
            Button(Strings.cancel, role: .cancel) { }
            Button(Strings.commonDelete, role: .destructive) {
                if let h = holidayToDelete {
                    modelContext.delete(h)
                    do {
                        try modelContext.save()
                    } catch {
                        errorMessage = Strings.deleteFailed
                        showingErrorAlert = true
                        HapticFeedback.error()
                    }
                    holidayToDelete = nil
                }
            }
        } message: {
            Text(Strings.holidayDeleteAlertMessage)
        }
        .alert(Strings.alert, isPresented: $showingErrorAlert) {
            Button(Strings.confirm, role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func saveOrReport(undo: () -> Void) {
        do {
            try modelContext.save()
            HapticFeedback.success()
        } catch {
            undo()
            errorMessage = Strings.saveFailed
            showingErrorAlert = true
            HapticFeedback.error()
        }
    }

    // MARK: - Subviews

    private var breakSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(Strings.breakSectionTitle)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .voHeader()
                Spacer()
                Button {
                    showingAddBreak = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .voDecorative()
                        Text(Strings.commonAdd)
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.teal)
                }
                .voButton(Strings.breakAddTitle)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 8)

            VStack(spacing: 0) {
                if breaksThisYear.isEmpty {
                    HStack(spacing: 10) {
                        Image(systemName: "graduationcap")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .voDecorative()
                        Text(Strings.breakEmpty)
                            .foregroundStyle(.secondary)
                            .font(.body)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                } else {
                    ForEach(breaksThisYear) { item in
                        SchoolBreakRow(item: item,
                                       onEdit: { breakToEdit = item },
                                       onDelete: { breakToDelete = item })
                        if item.id != breaksThisYear.last?.id {
                            Divider().padding(.leading, 60)
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            Text(Strings.breakSectionFooter)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.top, 6)
        }
    }

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
                .font(.body.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .voButton(label)
        .voSelected(isSelected)
    }

    private var builtInSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack {
                Text(Strings.holidayDefaultSection)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .voHeader()
                Spacer()
                Text(Strings.itemCount(builtInHolidays.count))
                    .font(.body)
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
                .font(.body)
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
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .voHeader()
                Spacer()
                Button {
                    showingAddSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .voDecorative()
                        Text(Strings.commonAdd)
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.purple)
                }
                .voButton(Strings.commonAdd)
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
                            .voDecorative()
                        Text(Strings.holidayCustomEmpty)
                            .foregroundStyle(.secondary)
                            .font(.body)
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
                .font(.body)
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
            HStack(spacing: 12) {
                // 날짜 컬럼
                VStack(alignment: .center, spacing: 1) {
                    Text(holiday.date, format: .dateTime.month(.abbreviated))
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text(holiday.date, format: .dateTime.day())
                        .font(.headline)
                        .foregroundStyle(isHidden ? Color.secondary : Color.red)
                }
                .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(holiday.name)
                        .font(.body)
                        .foregroundStyle(isHidden ? Color.secondary : Color.primary)
                        .strikethrough(isHidden, color: .secondary)
                    if holiday.isSubstitute {
                        Text(Strings.holidaySubstitute)
                            .font(.body)
                            .foregroundStyle(.orange)
                    }
                }

                Spacer()
            }
            .accessibilityElement(children: .combine)

            Toggle("", isOn: Binding(
                get: { !isHidden },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .accessibilityLabel(Text(holiday.name))
            .accessibilityHint(Text(Strings.holidayVisibilityHint))
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
            HStack(spacing: 12) {
                VStack(alignment: .center, spacing: 1) {
                    Text(holiday.date, format: .dateTime.month(.abbreviated))
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text(holiday.date, format: .dateTime.day())
                        .font(.headline)
                        .foregroundStyle(.purple)
                }
                .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(holiday.name)
                        .font(.body)
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.body)
                            .voDecorative()
                        Text(Strings.holidayAddedByMe)
                            .font(.body)
                    }
                    .foregroundStyle(.purple)
                }

                Spacer()
            }
            .accessibilityElement(children: .combine)

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
                    .font(.body)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(Strings.commonDelete))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// MARK: - 방학 행
private struct SchoolBreakRow: View {
    let item: SchoolBreak
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var tint: Color { item.kind == .mine ? .indigo : .teal }

    private var days: Int {
        (Calendar.current.dateComponents([.day], from: item.startDate, to: item.endDate).day ?? 0) + 1
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onEdit) {
                HStack(spacing: 12) {
                    Image(systemName: item.kind == .mine ? "graduationcap.fill" : "figure.and.child.holdinghands")
                        .font(.title3)
                        .foregroundStyle(tint)
                        .frame(width: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.body)
                            .foregroundStyle(.primary)
                        Text("\(item.startDate.appMonthDay) – \(item.endDate.appMonthDay) · \(Strings.breakDays(days))")
                            .font(.body)
                            .foregroundStyle(.secondary)
                        Text(item.kind == .mine ? Strings.myBreakLabel : Strings.childBreakTag)
                            .font(.body)
                            .foregroundStyle(tint)
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint(Text(Strings.breakEditTitle))

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
                    .font(.body)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(Strings.commonDelete))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// MARK: - 방학 추가·수정 시트
struct SchoolBreakEditSheet: View {
    let existing: SchoolBreak?
    let onSave: (String, Date, Date, SchoolBreakKind) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var kind: SchoolBreakKind
    @State private var startDate: Date
    @State private var endDate: Date

    init(defaultYear: Int, existing: SchoolBreak?, onSave: @escaping (String, Date, Date, SchoolBreakKind) -> Void) {
        self.existing = existing
        self.onSave = onSave
        let cal = Calendar.current
        let thisYear = cal.component(.year, from: Date())
        // 기본값: 올해면 오늘부터 4주, 다른 해면 그해 7월 말부터 4주(여름방학 즈음)
        let start = existing?.startDate
            ?? (defaultYear == thisYear ? cal.startOfDay(for: Date())
                : cal.date(from: DateComponents(year: defaultYear, month: 7, day: 20)) ?? Date())
        _startDate = State(initialValue: start)
        _endDate = State(initialValue: existing?.endDate ?? cal.date(byAdding: .day, value: 27, to: start) ?? start)
        _name = State(initialValue: existing?.name ?? "")
        _kind = State(initialValue: existing?.kind ?? .child)
    }

    private var isValid: Bool { endDate >= startDate }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(Strings.breakKindSection, selection: $kind) {
                        Text(Strings.childBreakTag).tag(SchoolBreakKind.child)
                        Text(Strings.myBreakLabel).tag(SchoolBreakKind.mine)
                    }
                    .pickerStyle(.segmented)
                    Text(kind == .child ? Strings.breakKindChildDesc : Strings.breakKindMineDesc)
                        .font(.body)
                        .foregroundStyle(.secondary)
                } header: {
                    Text(Strings.breakKindSection)
                }

                Section(Strings.breakPeriodSection) {
                    DatePicker(Strings.startDate, selection: $startDate, displayedComponents: .date)
                    DatePicker(Strings.endDate, selection: $endDate, in: startDate..., displayedComponents: .date)
                    if !isValid {
                        Text(Strings.breakInvalidRange)
                            .font(.body)
                            .foregroundStyle(.red)
                    }
                }

                Section(Strings.breakNameSection) {
                    TextField(Strings.breakNamePlaceholder, text: $name)
                        .submitLabel(.done)
                }
            }
            .navigationTitle(existing == nil ? Strings.breakAddTitle : Strings.breakEditTitle)
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: startDate) { _, newStart in
                if endDate < newStart { endDate = newStart }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(existing == nil ? Strings.commonAdd : Strings.save) {
                        let trimmed = name.trimmingCharacters(in: .whitespaces)
                        let finalName = trimmed.isEmpty
                            ? (kind == .mine ? Strings.myBreakLabel : Strings.childBreakTag)
                            : trimmed
                        onSave(finalName, startDate, endDate, kind)
                        dismiss()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large])
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
    .modelContainer(for: [CustomHoliday.self, SchoolBreak.self], inMemory: true)
}
