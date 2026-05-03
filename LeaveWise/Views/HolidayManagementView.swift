//
//  HolidayManagementView.swift
//  LeaveWise
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
                        Label("기본 공휴일 모두 복원", systemImage: "arrow.counterclockwise")
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
        .navigationTitle("공휴일 관리")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddSheet) {
            AddCustomHolidaySheet(defaultYear: selectedYear) { date, name in
                let holiday = CustomHoliday(date: date, name: name)
                modelContext.insert(holiday)
                try? modelContext.save()
            }
        }
        .alert("공휴일 삭제", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                if let h = holidayToDelete {
                    modelContext.delete(h)
                    try? modelContext.save()
                    holidayToDelete = nil
                }
            }
        } message: {
            Text("이 공휴일을 삭제할까요?")
        }
    }

    // MARK: - Subviews

    private var yearPickerBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(availableYears, id: \.self) { year in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedYear = year }
                    } label: {
                        Text(verbatim: "\(year)년")
                            .font(.subheadline.weight(selectedYear == year ? .semibold : .regular))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(selectedYear == year ? Color.blue : Color(.systemGray5))
                            .foregroundStyle(selectedYear == year ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }

    private var builtInSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack {
                Text("기본 공휴일")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(builtInHolidays.count)개")
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

            Text("토글을 끄면 캘린더와 추천에서 해당 공휴일이 숨겨집니다.")
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
                Text("내 공휴일")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    showingAddSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("추가")
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
                        Text("직접 추가한 공휴일이 없습니다")
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

            Text("직접 추가한 공휴일은 캘린더와 추천에 반영됩니다.")
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
                    Text("대체공휴일")
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
                    Text("내가 추가")
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
                Section("날짜") {
                    DatePicker("날짜 선택", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
                Section("이름") {
                    TextField("공휴일 이름 (예: 창립기념일)", text: $name)
                        .submitLabel(.done)
                }
            }
            .navigationTitle("공휴일 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
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
