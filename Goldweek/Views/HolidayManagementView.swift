//
//  HolidayManagementView.swift
//  Goldweek
//
//  공휴일 관리 — 기본 공휴일 숨기기/복원, 사용자 정의 공휴일 추가/삭제, 방학 추가/수정/삭제

import SwiftUI
import SwiftData
import PhotosUI

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
    @State private var showingSchoolImport = false
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

    /// 선택한 연도에 오는 내 공휴일과 그해 날짜 (매년 반복 포함)
    private var customHolidaysThisYear: [(holiday: CustomHoliday, date: Date)] {
        customHolidays
            .compactMap { h in h.occurrence(in: selectedYear, calendar: calendar).map { (h, $0) } }
            .sorted { $0.date < $1.date }
    }

    /// 선택한 연도에 걸친 방학 (겨울방학처럼 해를 넘기는 것도 포함) — 휴가 불가 기간은 설정에서 따로 관리
    private var breaksThisYear: [SchoolBreak] {
        schoolBreaks.filter {
            $0.kind != .blackout
                && calendar.component(.year, from: $0.startDate) <= selectedYear
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
            AddCustomHolidaySheet(defaultYear: selectedYear, defaultRepeats: country == .custom) { date, name, repeats in
                let holiday = CustomHoliday(date: date, name: name, repeatsYearly: repeats)
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
        .sheet(isPresented: $showingSchoolImport) {
            SchoolCalendarImportSheet()
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

            Button {
                showingSchoolImport = true
            } label: {
                Label(Strings.schoolImportTitle, systemImage: "doc.viewfinder")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .padding(.top, 8)

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
                if country == .custom {
                    HStack(spacing: 10) {
                        Image(systemName: "globe")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .voDecorative()
                        Text(Strings.customCountryBuiltInInfo)
                            .foregroundStyle(.secondary)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
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

            if country != .custom {
                Text(Strings.holidayDefaultFooter)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 6)
            }
            if country.hasMoonSightingHolidays {
                Text(Strings.moonSightingNote)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 6)
            }
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
                    ForEach(customHolidaysThisYear, id: \.holiday.id) { item in
                        CustomHolidayRow(
                            holiday: item.holiday,
                            date: item.date,
                            onDelete: {
                                holidayToDelete = item.holiday
                                showingDeleteAlert = true
                            }
                        )
                        if item.holiday.id != customHolidaysThisYear.last?.holiday.id {
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
    /// 보고 있는 해의 날짜 — 매년 반복이면 처음 넣은 날과 다르다
    let date: Date
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .center, spacing: 1) {
                    Text(date, format: .dateTime.month(.abbreviated))
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text(date, format: .dateTime.day())
                        .font(.headline)
                        .foregroundStyle(.purple)
                }
                .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(holiday.name)
                        .font(.body)
                    HStack(spacing: 4) {
                        Image(systemName: holiday.repeatsYearly ? "repeat" : "person.fill")
                            .font(.body)
                            .voDecorative()
                        Text(holiday.repeatsYearly ? Strings.holidayEveryYear : Strings.holidayAddedByMe)
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

    private var tint: Color {
        switch item.kind {
        case .mine: return .indigo
        case .child: return .teal
        case .blackout: return .orange
        }
    }

    private var icon: String {
        switch item.kind {
        case .mine: return "graduationcap.fill"
        case .child: return "figure.and.child.holdinghands"
        case .blackout: return "nosign"
        }
    }

    private var kindLabel: String {
        switch item.kind {
        case .mine: return Strings.myBreakLabel
        case .child: return Strings.childBreakTag
        case .blackout: return Strings.blackoutPeriodsTitle
        }
    }

    private var days: Int {
        (Calendar.current.dateComponents([.day], from: item.startDate, to: item.endDate).day ?? 0) + 1
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onEdit) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
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
                        Text(kindLabel)
                            .font(.body)
                            .foregroundStyle(tint)
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint(Text(item.kind == .blackout ? Strings.blackoutPeriodEditTitle : Strings.breakEditTitle))

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

    /// 휴가 불가 기간 편집 — 종류 선택을 숨기고 문구를 바꾼다
    private var isBlackout: Bool { kind == .blackout }

    /// - Parameter kind: 새로 만들 때의 종류 (휴가 불가 기간 화면은 `.blackout`)
    init(defaultYear: Int, existing: SchoolBreak?, kind defaultKind: SchoolBreakKind = .child,
         onSave: @escaping (String, Date, Date, SchoolBreakKind) -> Void) {
        self.existing = existing
        self.onSave = onSave
        let cal = Calendar.current
        let thisYear = cal.component(.year, from: Date())
        let initialKind = existing?.kind ?? defaultKind
        // 기본값: 올해면 오늘부터 4주, 다른 해면 그해 7월 말부터 4주(여름방학 즈음)
        let start = existing?.startDate
            ?? (defaultYear == thisYear ? cal.startOfDay(for: Date())
                : cal.date(from: DateComponents(year: defaultYear, month: 7, day: 20)) ?? Date())
        _startDate = State(initialValue: start)
        // 방학은 4주, 휴가 불가 기간은 1주가 기본
        let length = initialKind == .blackout ? 6 : 27
        _endDate = State(initialValue: existing?.endDate ?? cal.date(byAdding: .day, value: length, to: start) ?? start)
        _name = State(initialValue: existing?.name ?? "")
        _kind = State(initialValue: initialKind)
    }

    private var isValid: Bool { endDate >= startDate }

    var body: some View {
        NavigationStack {
            Form {
                if isBlackout {
                    Section {
                        Text(Strings.blackoutPeriodsFooter)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                } else { Section {
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
                } }

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
                    TextField(isBlackout ? Strings.blackoutPeriodNamePlaceholder : Strings.breakNamePlaceholder, text: $name)
                        .submitLabel(.done)
                }
            }
            .navigationTitle(isBlackout
                ? (existing == nil ? Strings.blackoutPeriodAddTitle : Strings.blackoutPeriodEditTitle)
                : (existing == nil ? Strings.breakAddTitle : Strings.breakEditTitle))
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
                        let fallback: String = switch kind {
                        case .mine: Strings.myBreakLabel
                        case .child: Strings.childBreakTag
                        case .blackout: Strings.blackoutPeriodsTitle
                        }
                        let finalName = trimmed.isEmpty ? fallback : trimmed
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

// MARK: - 휴가 불가 기간 (설정 → 휴가 제한)
/// 직장 규정상 휴가를 낼 수 없는 기간 목록. 방학과 같은 `SchoolBreak` 모델(`.blackout`)에 담는다.
struct BlackoutPeriodsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SchoolBreak.startDate) private var schoolBreaks: [SchoolBreak]

    /// 바뀌면 추천을 다시 계산하게 한다
    var onChange: () -> Void = {}

    @State private var showingAdd = false
    @State private var itemToEdit: SchoolBreak?
    @State private var itemToDelete: SchoolBreak?
    @State private var showingErrorAlert = false

    private let calendar = Calendar.current

    /// 끝나지 않은 기간을 먼저, 지난 기간은 아래로
    private var periods: [SchoolBreak] {
        let today = calendar.startOfDay(for: Date())
        let all = schoolBreaks.filter { $0.kind == .blackout }
        return all.filter { $0.endDate >= today } + all.filter { $0.endDate < today }.reversed()
    }

    var body: some View {
        List {
            Section {
                if periods.isEmpty {
                    HStack(spacing: 10) {
                        Image(systemName: "nosign")
                            .foregroundStyle(.secondary)
                            .voDecorative()
                        Text(Strings.blackoutPeriodsEmpty)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ForEach(periods) { item in
                        SchoolBreakRow(item: item,
                                       onEdit: { itemToEdit = item },
                                       onDelete: { itemToDelete = item })
                            .listRowInsets(EdgeInsets())
                    }
                }
            } footer: {
                Text(Strings.blackoutPeriodsFooter)
                    .font(.body)
            }
        }
        .navigationTitle(Strings.blackoutPeriodsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAdd = true } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(Text(Strings.blackoutPeriodAddTitle))
            }
        }
        .sheet(isPresented: $showingAdd) {
            SchoolBreakEditSheet(defaultYear: calendar.component(.year, from: Date()), existing: nil,
                                 kind: .blackout) { name, start, end, kind in
                let item = SchoolBreak(name: name, startDate: start, endDate: end, kind: kind)
                modelContext.insert(item)
                save { modelContext.delete(item) }
            }
        }
        .sheet(item: $itemToEdit) { item in
            SchoolBreakEditSheet(defaultYear: calendar.component(.year, from: item.startDate), existing: item) { name, start, end, _ in
                item.name = name
                item.startDate = calendar.startOfDay(for: start)
                item.endDate = calendar.startOfDay(for: end)
                save { modelContext.rollback() }
            }
        }
        .alert(Strings.blackoutPeriodDeleteTitle, isPresented: Binding(
            get: { itemToDelete != nil },
            set: { if !$0 { itemToDelete = nil } }
        )) {
            Button(Strings.cancel, role: .cancel) { itemToDelete = nil }
            Button(Strings.commonDelete, role: .destructive) {
                if let item = itemToDelete {
                    modelContext.delete(item)
                    save { }
                }
                itemToDelete = nil
            }
        } message: {
            Text(itemToDelete?.name ?? "")
        }
        .alert(Strings.alert, isPresented: $showingErrorAlert) {
            Button(Strings.confirm, role: .cancel) { }
        } message: {
            Text(Strings.saveFailed)
        }
    }

    private func save(undo: () -> Void) {
        do {
            try modelContext.save()
            HapticFeedback.success()
            onChange()
        } catch {
            undo()
            showingErrorAlert = true
            HapticFeedback.error()
        }
    }
}

// MARK: - 커스텀 공휴일 추가 시트
struct AddCustomHolidaySheet: View {
    let defaultYear: Int
    let onSave: (Date, String, Bool) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var date: Date
    @State private var name = ""
    @State private var repeatsYearly: Bool

    init(defaultYear: Int, defaultRepeats: Bool = false, onSave: @escaping (Date, String, Bool) -> Void) {
        self.defaultYear = defaultYear
        self.onSave = onSave
        _repeatsYearly = State(initialValue: defaultRepeats)
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
                Section {
                    Toggle(Strings.holidayRepeatYearly, isOn: $repeatsYearly)
                } footer: {
                    Text(Strings.holidayRepeatYearlyFooter)
                        .font(.body)
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
                        onSave(date, trimmed, repeatsYearly)
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

// MARK: - 학교 달력 가져오기 (미국 교사 피드백: 학교 달력은 사진·PDF로만 온다)

/// 학교 달력 사진·PDF·붙여 넣은 글에서 쉬는 날과 시험 주간을 찾아 한 번에 넣는다.
/// 쉬는 날은 내 방학(연차 차감 없음, 공휴일 앞뒤 제한의 기준), 시험 주간은 휴가 불가 기간으로.
struct SchoolCalendarImportSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var schoolBreaks: [SchoolBreak]

    private enum Phase { case pick, reading, results }

    @State private var phase: Phase = .pick
    @State private var pastedText = ""
    @State private var sourceText = ""
    @State private var schoolYear = SchoolCalendarParser.schoolYearStart(in: "")
    @State private var items: [SchoolCalendarParser.Item] = []
    @State private var selected: Set<UUID> = []
    @State private var kinds: [UUID: SchoolBreakKind] = [:]
    @State private var pickedItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var showingFileImporter = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                switch phase {
                case .pick: pickView
                case .reading:
                    VStack(spacing: 12) {
                        ProgressView()
                        Text(Strings.scanningPhoto).font(.body).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .results: resultsView
                }
            }
            .navigationTitle(Strings.schoolImportTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
                if phase == .results {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(Strings.schoolImportAdd(selected.count), action: addSelected)
                            .disabled(selected.isEmpty)
                            .fontWeight(.semibold)
                    }
                }
            }
            .onChange(of: pickedItem) { _, item in
                guard let item else { return }
                Task { await read { 
                    guard let data = try await item.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else { throw PhotoImportError.invalidImage }
                    return try await PhotoImportService.shared.recognizeLines(in: image)
                } }
            }
            .sheet(isPresented: $showingCamera) {
                CameraPicker { image in
                    Task { await read { try await PhotoImportService.shared.recognizeLines(in: image) } }
                }
                .ignoresSafeArea()
            }
            .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.pdf, .image]) { result in
                guard case .success(let url) = result else { return }
                Task { await read {
                    let scoped = url.startAccessingSecurityScopedResource()
                    defer { if scoped { url.stopAccessingSecurityScopedResource() } }
                    if url.pathExtension.lowercased() == "pdf" {
                        return try await PhotoImportService.shared.text(fromPDF: url)
                    }
                    guard let image = UIImage(contentsOfFile: url.path) else { throw PhotoImportError.invalidImage }
                    return try await PhotoImportService.shared.recognizeLines(in: image)
                } }
            }
        }
    }

    // MARK: 고르기

    private var pickView: some View {
        Form {
            Section {
                Text(Strings.schoolImportGuide)
                    .font(.body)
                    .foregroundStyle(.secondary)
                if let errorMessage {
                    Text(errorMessage).font(.body).foregroundStyle(.orange)
                }
            }
            Section {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button { showingCamera = true } label: {
                        Label(Strings.takePhoto, systemImage: "camera.fill")
                    }
                }
                PhotosPicker(selection: $pickedItem, matching: .images) {
                    Label(Strings.choosePhoto, systemImage: "photo.on.rectangle")
                }
                Button { showingFileImporter = true } label: {
                    Label(Strings.schoolImportChooseFile, systemImage: "doc.richtext")
                }
            }
            Section {
                TextEditor(text: $pastedText)
                    .frame(minHeight: 120)
                    .font(.body)
                    .overlay(alignment: .topLeading) {
                        if pastedText.isEmpty {
                            Text(verbatim: "Nov 24-28  Thanksgiving Break\nDec 21 - Jan 1  Winter Break")
                                .font(.body)
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }
                    }
                Button(Strings.schoolImportRead) {
                    let text = pastedText
                    Task { await read { text } }
                }
                .disabled(pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } header: {
                Text(Strings.schoolImportPaste)
            }
        }
    }

    // MARK: 결과

    private var resultsView: some View {
        List {
            Section {
                Picker(Strings.schoolImportSchoolYear, selection: $schoolYear) {
                    ForEach((schoolYear - 2)...(schoolYear + 2), id: \.self) { y in
                        Text(verbatim: "\(y)–\(String(y + 1).suffix(2))").tag(y)
                    }
                }
                .onChange(of: schoolYear) { _, _ in parse() }
            } footer: {
                Text(Strings.schoolImportFooter)
            }

            if items.isEmpty {
                Section {
                    Text(Strings.schoolImportNothingFound)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            } else {
                Section {
                    ForEach(items) { item in row(item) }
                }
            }

            Section {
                Button(Strings.chooseAnotherPhoto) {
                    phase = .pick
                    pickedItem = nil
                }
            }
        }
    }

    private func row(_ item: SchoolCalendarParser.Item) -> some View {
        let isOn = selected.contains(item.id)
        let alreadyOff = DayOffCalendar.shared.workdays(from: item.start, to: item.end) == 0
        let days = (Calendar.current.dateComponents([.day], from: item.start, to: item.end).day ?? 0) + 1
        return VStack(alignment: .leading, spacing: 8) {
            Button {
                if isOn { selected.remove(item.id) } else { selected.insert(item.id) }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isOn ? AppTheme.Colors.brand : Color(.systemGray3))
                        .voDecorative()
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name.isEmpty ? Strings.schoolImportUntitled : item.name)
                            .foregroundStyle(.primary)
                        Text(item.start == item.end ? item.start.appMonthDay
                             : "\(item.start.appMonthDay) – \(item.end.appMonthDay) · \(Strings.breakDays(days))")
                            .font(.body)
                            .foregroundStyle(.secondary)
                        if alreadyOff {
                            Text(Strings.schoolImportAlreadyOff)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isOn ? .isSelected : [])

            if isOn {
                Picker(Strings.breakKindSection, selection: Binding(
                    get: { kinds[item.id] ?? .mine },
                    set: { kinds[item.id] = $0 })) {
                    Text(Strings.schoolImportDayOff).tag(SchoolBreakKind.mine)
                    Text(Strings.blackoutPeriodsTitle).tag(SchoolBreakKind.blackout)
                }
                .pickerStyle(.segmented)
                .padding(.leading, 34)
            }
        }
    }

    // MARK: 동작

    private func read(_ load: @escaping () async throws -> String) async {
        errorMessage = nil
        phase = .reading
        do {
            let text = try await load()
            sourceText = text
            schoolYear = SchoolCalendarParser.schoolYearStart(in: text)
            parse()
            phase = .results
            UsageReportingService.record(event: "school_calendar_read")
        } catch {
            errorMessage = error.localizedDescription
            phase = .pick
        }
    }

    private func parse() {
        let existing = Set(schoolBreaks.map { "\($0.kindRaw)|\($0.startDate.timeIntervalSince1970)|\($0.endDate.timeIntervalSince1970)" })
        items = SchoolCalendarParser.parse(text: sourceText, schoolYearStart: schoolYear)
        selected = []
        kinds = [:]
        for item in items {
            let kind: SchoolBreakKind = item.suggestion == .blackout ? .blackout : .mine
            kinds[item.id] = kind
            let key = "\(kind.rawValue)|\(item.start.timeIntervalSince1970)|\(item.end.timeIntervalSince1970)"
            // 이미 넣었거나, 원래 쉬는 날이거나, 교사가 일하는 날은 고르지 않은 채로 둔다
            guard item.suggestion != .skip, !existing.contains(key) else { continue }
            if kind == .mine && DayOffCalendar.shared.workdays(from: item.start, to: item.end) == 0 { continue }
            selected.insert(item.id)
        }
    }

    private func addSelected() {
        var inserted: [SchoolBreak] = []
        for item in items where selected.contains(item.id) {
            let kind = kinds[item.id] ?? .mine
            let name = item.name.isEmpty ? Strings.schoolImportUntitled : item.name
            let b = SchoolBreak(name: name, startDate: item.start, endDate: item.end, kind: kind)
            modelContext.insert(b)
            inserted.append(b)
        }
        do {
            try modelContext.save()
            HapticFeedback.success()
            UsageReportingService.record(event: "school_calendar_imported")
            dismiss()
        } catch {
            inserted.forEach { modelContext.delete($0) }
            errorMessage = Strings.saveFailed
            HapticFeedback.error()
        }
    }
}
