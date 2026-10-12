//
//  LeaveKindsView.swift
//  Goldweek
//
//  휴가 종류와 색 — 기본 종류의 색을 바꾸고, 회사에서 쓰는 휴가(ROL·공부 휴가 등)를 새 종류로 만든다.
//  고른 색은 달력 막대와 범례에 그대로 쓰인다.
//

import SwiftUI
import SwiftData

struct LeaveKindsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomLeaveType.createdAt) private var customTypes: [CustomLeaveType]
    @Query private var records: [LeaveRecord]
    @Query private var profiles: [UserProfile]
    @State private var store = LeaveStyleStore.shared
    @State private var editing: CustomLeaveType?
    @State private var showingNew = false
    @State private var editMode: EditMode = .inactive

    private var orderedKinds: [LeaveKindRef] { store.orderedKinds(custom: customTypes) }

    private var startMonth: Int { profiles.first?.yearStartMonth ?? 1 }
    private var currentYear: Int { LeaveUsageCalculator.fiscalYear(for: Date(), startMonth: startMonth) }

    /// 올해(연차 기준월부터) 종류별 사용량 — 한도 카운터용
    private var usage: [LeaveKindRef: LeaveKindUsage] {
        LeaveKindUsage.byKind(records: records, customTypes: customTypes, year: currentYear, startMonth: startMonth)
    }

    var body: some View {
        let usage = usage
        List {
            Section {
                ForEach(orderedKinds) { ref in
                    switch ref {
                    case .builtIn(let type):
                        builtInRow(type)
                            .deleteDisabled(true)
                    case .custom(let id):
                        if let kind = customTypes.first(where: { $0.id == id }) {
                            customRow(kind, usage: usage[ref] ?? LeaveKindUsage())
                        }
                    }
                }
                .onMove(perform: move)
                .onDelete(perform: delete)

                Button {
                    showingNew = true
                } label: {
                    Label(Strings.addLeaveKind, systemImage: "plus.circle.fill")
                }
            } header: {
                Text(Strings.allLeaveKindsHeader)
            } footer: {
                Text([Strings.leaveKindsFooter, Strings.leaveKindsOrderFooter,
                      customTypes.isEmpty ? nil : Strings.deleteLeaveKindNote].compactMap { $0 }.joined(separator: "\n"))
            }
        }
        .environment(\.editMode, $editMode)
        .navigationTitle(Strings.leaveKindsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(editMode.isEditing ? Strings.doneEditing : Strings.edit) {
                    withAnimation { editMode = editMode.isEditing ? .inactive : .active }
                }
            }
        }
        .sheet(isPresented: $showingNew) {
            LeaveKindEditor(kind: nil)
        }
        .sheet(item: $editing) { kind in
            LeaveKindEditor(kind: kind)
        }
    }

    private func builtInRow(_ type: LeaveType) -> some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundStyle(store.color(for: type))
                .frame(width: 24)
                .voDecorative()
            ColorPicker(Strings.leaveTypeName(type),
                        selection: Binding(get: { store.color(for: type) },
                                           set: { store.setColor($0.leaveHex, for: type) }),
                        supportsOpacity: false)
        }
        .swipeActions {
            if store.hasCustomColor(for: type) {
                Button(Strings.resetLeaveColor) { store.setColor(nil, for: type) }
                    .tint(.gray)
            }
        }
        .contextMenu {
            if store.hasCustomColor(for: type) {
                Button(Strings.resetLeaveColor) { store.setColor(nil, for: type) }
            }
        }
    }

    private func customRow(_ kind: CustomLeaveType, usage: LeaveKindUsage) -> some View {
        Button {
            editing = kind
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(kind.color)
                    .frame(width: 16, height: 16)
                    .frame(width: 24)
                    .voDecorative()
                VStack(alignment: .leading, spacing: 2) {
                    Text(kind.name)
                        .foregroundStyle(.primary)
                    // 연간 한도가 있으면 올해 남은 양
                    if kind.hasAllowance {
                        let counter = LeaveAllowanceCounter(kind: kind, usage: usage,
                                                            carriedIn: LeaveAllowanceCounter.carryIn(kind: kind, records: records,
                                                                                                    year: currentYear, startMonth: startMonth))
                        Text(counter.isOver ? Strings.allowanceOver(counter.text(-counter.remaining))
                             : "\(Strings.remaining) \(counter.text(counter.remaining)) / \(counter.text(counter.total))")
                            .font(.body)
                            .foregroundStyle(counter.isOver ? .red : .secondary)
                    }
                }
                Spacer()
                if kind.deductsFromAnnual {
                    Text(Strings.leaveTypeName(.annual))
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundStyle(.tertiary)
                    .voDecorative()
            }
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        var kinds = orderedKinds
        kinds.move(fromOffsets: source, toOffset: destination)
        store.setOrder(kinds)
        UsageReportingService.record(event: "leave_kind_reordered")
    }

    /// 종류를 지워도 그 종류로 남긴 휴가는 지우지 않는다 — 기본 유형(연차/특별휴가)으로 보인다
    private func delete(at offsets: IndexSet) {
        let kinds = orderedKinds
        for i in offsets {
            guard case .custom(let id) = kinds[i], let kind = customTypes.first(where: { $0.id == id }) else { continue }
            modelContext.delete(kind)
        }
        do { try modelContext.save() } catch {
            logError("휴가 종류 삭제 실패: \(error.localizedDescription)", category: .data)
        }
        UsageReportingService.record(event: "leave_kind_deleted")
    }
}

/// 휴가 종류 만들기·고치기
struct LeaveKindEditor: View {
    let kind: CustomLeaveType?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var records: [LeaveRecord]
    @Query private var profiles: [UserProfile]

    @State private var name = ""
    @State private var color = Color(hex: "4FACFE") ?? .blue
    @State private var deducts = true
    @State private var hasAllowance = false
    @State private var allowanceIsHours = true
    /// 시간 한도는 분, 일 한도는 일
    @State private var allowanceMinutes = 0
    @State private var allowanceDays = 0.0
    /// 남은 한도 넘겨 쓰기 · 시작할 때 이미 쌓여 있던 양 (시간이면 분, 일이면 일)
    @State private var carriesOver = false
    @State private var startBalanceMinutes = 0
    @State private var startBalanceDays = 0.0
    @State private var didLoad = false

    private var startMonth: Int { profiles.first?.yearStartMonth ?? 1 }
    private var currentYear: Int { LeaveUsageCalculator.fiscalYear(for: Date(), startMonth: startMonth) }
    /// 넘겨 쓰기를 셈하기 시작하는 해 — 이미 켜져 있던 종류는 그 해, 새로 켜면 올해
    private var carryStartYear: Int {
        if let kind, kind.allowanceCarriesOver, kind.allowanceStartYear > 0 { return kind.allowanceStartYear }
        if let kind, kind.allowanceCarriesOver {
            return LeaveUsageCalculator.fiscalYear(for: kind.createdAt, startMonth: startMonth)
        }
        return currentYear
    }

    /// 빨리 고를 수 있는 색 — 달력의 공휴일(빨강)과 겹치지 않게 골랐다
    private static let palette = ["4FACFE", "34C759", "FF9500", "AF52DE", "FF2D55", "5856D6", "00C7BE", "A2845E"]

    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(Strings.leaveKindName, text: $name)
                }
                Section(Strings.leaveKindColor) {
                    HStack(spacing: 10) {
                        ForEach(Self.palette, id: \.self) { hex in
                            let c = Color(hex: hex) ?? .blue
                            Button {
                                color = c
                            } label: {
                                Circle()
                                    .fill(c)
                                    .frame(width: 28, height: 28)
                                    .overlay(Circle().strokeBorder(.primary, lineWidth: color.leaveHex == hex ? 2.5 : 0))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text("\(Strings.leaveKindColor) \(hex)"))
                            .accessibilityAddTraits(color.leaveHex == hex ? .isSelected : [])
                        }
                    }
                    ColorPicker(Strings.leaveKindColor, selection: $color, supportsOpacity: false)
                }
                Section {
                    Toggle(Strings.leaveKindDeducts, isOn: $deducts)
                }
                allowanceSection
            }
            .navigationTitle(kind?.name ?? Strings.addLeaveKind)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.save, action: save)
                        .disabled(trimmedName.isEmpty)
                }
            }
            .onAppear {
                guard !didLoad else { return }
                didLoad = true
                if kind == nil { allowanceIsHours = LeaveLength.usesHourlyLeave }
                if let kind {
                    name = kind.name
                    color = kind.color
                    deducts = kind.deductsFromAnnual
                    hasAllowance = kind.hasAllowance
                    allowanceIsHours = kind.allowanceIsHours
                    if kind.allowanceIsHours {
                        allowanceMinutes = Int((kind.allowanceAmount * 60).rounded())
                    } else {
                        allowanceDays = kind.allowanceAmount
                    }
                    carriesOver = kind.allowanceCarriesOver
                    if kind.allowanceIsHours {
                        startBalanceMinutes = Int((kind.allowanceStartBalance * 60).rounded())
                    } else {
                        startBalanceDays = kind.allowanceStartBalance
                    }
                }
            }
        }
    }

    /// 연간 한도 (이탈리아 permessi 의 monte ore) — 시간 또는 일
    @ViewBuilder
    private var allowanceSection: some View {
        Section {
            Toggle(Strings.allowanceToggle, isOn: $hasAllowance.animation())
            if hasAllowance {
                if LeaveLength.usesHourlyLeave || allowanceIsHours {
                Picker(Strings.allowanceUnitLabel, selection: $allowanceIsHours) {
                    Text(Strings.leaveHoursLabel).tag(true)
                    Text(Strings.allowanceUnitDays).tag(false)
                }
                .pickerStyle(.segmented)
                }
                if allowanceIsHours {
                    HStack {
                        Text(Strings.leaveHoursLabel)
                        Spacer()
                        TextField("0", value: Binding(get: { allowanceMinutes / 60 },
                                                      set: { allowanceMinutes = max(0, min(9999, $0)) * 60 + allowanceMinutes % 60 }),
                                  format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .monospacedDigit()
                            .frame(maxWidth: 100)
                    }
                    Stepper(value: Binding(get: { allowanceMinutes % 60 },
                                           set: { allowanceMinutes = (allowanceMinutes / 60) * 60 + $0 }),
                            in: 0...55, step: 5) {
                        HStack {
                            Text(Strings.leaveMinutesLabel)
                            Spacer()
                            Text("\(allowanceMinutes % 60)").monospacedDigit().foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Stepper(value: $allowanceDays, in: 0...365, step: 0.5) {
                        HStack {
                            Text(Strings.allowanceUnitDays)
                            Spacer()
                            Text(Strings.dayCount(allowanceDays)).monospacedDigit().foregroundStyle(.secondary)
                        }
                    }
                }
            }
        } header: {
            Text(Strings.allowanceSection)
        } footer: {
            if hasAllowance { Text(Strings.allowanceFooter) }
        }
        if hasAllowance {
            carryOverSection
        }
    }

    /// 남은 한도를 다음 해로 넘기기 (미국 교사 피드백: 병가는 쌓이고 개인 휴가는 사라진다)
    @ViewBuilder
    private var carryOverSection: some View {
        Section {
            Toggle(Strings.allowanceCarryToggle, isOn: $carriesOver.animation())
            if carriesOver {
                if allowanceIsHours {
                    HStack {
                        Text(Strings.allowanceStartBalance(Strings.yearLabel(carryStartYear)))
                        Spacer()
                        TextField("0", value: Binding(get: { startBalanceMinutes / 60 },
                                                      set: { startBalanceMinutes = max(0, min(99999, $0)) * 60 + startBalanceMinutes % 60 }),
                                  format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .monospacedDigit()
                            .frame(maxWidth: 100)
                        Text(Strings.leaveHoursLabel).foregroundStyle(.secondary)
                    }
                } else {
                    Stepper(value: $startBalanceDays, in: 0...999, step: 0.5) {
                        HStack {
                            Text(Strings.allowanceStartBalance(Strings.yearLabel(carryStartYear)))
                            Spacer()
                            Text(Strings.dayCount(startBalanceDays)).monospacedDigit().foregroundStyle(.secondary)
                        }
                    }
                }
            }
        } footer: {
            Text(carriesOver ? Strings.allowanceCarryOnFooter : Strings.allowanceCarryOffFooter)
        }
    }

    private func applyAllowance(to target: CustomLeaveType) {
        target.allowanceIsHours = allowanceIsHours
        if !hasAllowance {
            target.allowanceAmount = 0
        } else {
            target.allowanceAmount = allowanceIsHours ? Double(allowanceMinutes) / 60 : allowanceDays
        }
        let carry = hasAllowance && carriesOver
        if carry {
            // 새로 켤 때 시작 해를 올해로 — 시작할 때 쌓여 있던 양이 그해부터 들어간다
            if !target.allowanceCarriesOver || target.allowanceStartYear == 0 { target.allowanceStartYear = carryStartYear }
            target.allowanceStartBalance = allowanceIsHours ? Double(startBalanceMinutes) / 60 : startBalanceDays
        }
        target.allowanceCarriesOver = carry
    }

    private func save() {
        let target: CustomLeaveType
        if let kind {
            target = kind
            target.name = trimmedName
            target.colorHex = color.leaveHex
            if target.deductsFromAnnual != deducts {
                target.deductsFromAnnual = deducts
                // 이미 남긴 휴가도 차감 여부를 맞춘다 (길이·날짜는 그대로)
                for r in records where r.customTypeId == target.id && r.bonusLeaveId == nil {
                    r.type = target.baseType
                }
            }
        } else {
            target = CustomLeaveType(name: trimmedName, colorHex: color.leaveHex, deductsFromAnnual: deducts)
            modelContext.insert(target)
            UsageReportingService.record(event: "leave_kind_created")
        }
        applyAllowance(to: target)
        do {
            try modelContext.save()
            HapticFeedback.success()
            dismiss()
        } catch {
            logError("휴가 종류 저장 실패: \(error.localizedDescription)", category: .data)
            HapticFeedback.error()
        }
    }
}

// MARK: - 종류별 합계 (이탈리아 피드백: 휴가 종류마다 쓴 날·시간과 남은 한도)

/// 한 해 동안 휴가 종류마다 쓴 양 — 사용 · 예정 · (한도가 있으면) 남음
struct LeaveKindStatsView: View {
    let year: Int
    let startMonth: Int

    @Query(sort: \CustomLeaveType.createdAt) private var customTypes: [CustomLeaveType]
    @Query private var records: [LeaveRecord]
    @State private var store = LeaveStyleStore.shared

    /// 쓴 기록이 있거나 한도를 정한 종류만, 사용자가 정한 순서로
    private var rows: [(ref: LeaveKindRef, usage: LeaveKindUsage, kind: CustomLeaveType?, counter: LeaveAllowanceCounter?)] {
        let usage = LeaveKindUsage.byKind(records: records, customTypes: customTypes, year: year, startMonth: startMonth)
        return store.orderedKinds(custom: customTypes).compactMap { ref in
            let kind: CustomLeaveType? = {
                if case .custom(let id) = ref { return customTypes.first { $0.id == id } }
                return nil
            }()
            let u = usage[ref] ?? LeaveKindUsage()
            guard u.totalCount > 0 || kind?.hasAllowance == true else { return nil }
            let counter = kind.flatMap { k in
                k.hasAllowance ? LeaveAllowanceCounter(kind: k, usage: u,
                                                       carriedIn: LeaveAllowanceCounter.carryIn(kind: k, records: records,
                                                                                               year: year, startMonth: startMonth)) : nil
            }
            return (ref, u, kind, counter)
        }
    }

    var body: some View {
        let rows = rows
        List {
            if rows.isEmpty {
                Text(Strings.noLeaveRecords)
                    .font(.body)
                    .foregroundStyle(.secondary)
            } else {
                Section {
                    ForEach(rows, id: \.ref) { row in
                        LeaveKindStatsRow(ref: row.ref, usage: row.usage, kind: row.kind, counter: row.counter)
                    }
                } header: {
                    Text(verbatim: Strings.yearLabel(year))
                } footer: {
                    Text(Strings.statsByKindFooter)
                }
            }
        }
        .navigationTitle(Strings.statsByKindTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LeaveKindStatsRow: View {
    let ref: LeaveKindRef
    let usage: LeaveKindUsage
    let kind: CustomLeaveType?
    /// 한도가 있는 종류의 카운터 (넘어온 양 포함)
    let counter: LeaveAllowanceCounter?

    private var name: String {
        switch ref {
        case .builtIn(let type): return Strings.leaveTypeName(type)
        case .custom: return kind?.name ?? ""
        }
    }

    private var color: Color {
        switch ref {
        case .builtIn(let type): return LeaveStyleStore.shared.color(for: type)
        case .custom: return kind?.color ?? AppTheme.Colors.leave
        }
    }

    /// 한도가 있으면 그 단위, 없으면 시간 단위로 쓴 적이 있을 때만 시간으로
    private var showsHours: Bool {
        if let kind, kind.hasAllowance { return kind.allowanceIsHours }
        return usage.hasHourRecords
    }

    private func amount(days: Double, minutes: Int) -> String {
        showsHours ? Strings.durationText(minutes: minutes) : Strings.dayCount(days)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Circle().fill(color).frame(width: 14, height: 14).voDecorative()
                Text(name).font(.headline)
                Spacer()
                Text("\(usage.totalCount)×")
                    .font(.body)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 0) {
                figure(Strings.statUsed, amount(days: usage.usedDays, minutes: usage.usedMinutes), .green)
                figure(Strings.statPlanned, amount(days: usage.plannedDays, minutes: usage.plannedMinutes), .blue)
                if let counter {
                    figure(Strings.remaining, counter.text(counter.remaining), counter.isOver ? .red : .primary)
                }
            }

            if let counter {
                AllowanceBar(counter: counter, color: color)
                if counter.carriedIn > 0.0001 {
                    Text(Strings.allowanceCarriedIn(counter.text(counter.carriedIn)))
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                if counter.isOver {
                    Text(Strings.allowanceOver(counter.text(-counter.remaining)))
                        .font(.body)
                        .foregroundStyle(.red)
                }
            } else if showsHours {
                // 시간으로 보여 줄 때는 일수도 함께 (시간 단위 휴가는 하루 근무 시간 기준 일수)
                Text(Strings.dayCount(usage.usedDays + usage.plannedDays))
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private func figure(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.body).foregroundStyle(.secondary)
            Text(value).font(.body.weight(.semibold)).monospacedDigit().foregroundStyle(color)
                .lineLimit(1).minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 한도 막대 — 사용(진한 색) · 예정(옅은 색) · 남음(빈칸)
struct AllowanceBar: View {
    let counter: LeaveAllowanceCounter
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let total = max(counter.total, counter.used + counter.planned, 0.0001)
            let usedW = geo.size.width * counter.used / total
            let plannedW = geo.size.width * counter.planned / total
            ZStack(alignment: .leading) {
                Capsule().fill(Color(.systemGray5))
                HStack(spacing: 0) {
                    Rectangle().fill(color).frame(width: usedW)
                    Rectangle().fill(color.opacity(0.4)).frame(width: plannedW)
                }
                .clipShape(Capsule())
            }
        }
        .frame(height: 8)
        .voDecorative()
    }
}

// MARK: - 요일별 근무 시간 (이탈리아 피드백: 월~목 7시간 30분, 금 7시간)

struct WorkdayHoursView: View {
    let country: Country
    var onChange: () -> Void = {}

    @AppStorage("workdayMinutes") private var defaultMinutes = 480
    @State private var byWeekday: [Int: Int] = LeaveLength.workdayMinutesByWeekday

    /// 근무하는 요일만, 주 시작 요일부터
    private var weekdays: [Int] {
        let first = HolidayService.firstWeekday(for: country)
        let weekend = HolidayService.weekendDays(for: country)
        return (0..<7).map { (first - 1 + $0) % 7 + 1 }.filter { !weekend.contains($0) }
    }

    private var weekdayNames: [String] {
        var cal = Calendar.app
        cal.locale = Locale(identifier: Strings.localeIdentifier)
        return cal.standaloneWeekdaySymbols
    }

    var body: some View {
        List {
            Section {
                ForEach(weekdays, id: \.self) { day in
                    let minutes = byWeekday[day] ?? defaultMinutes
                    Stepper(value: Binding(get: { minutes }, set: { set($0, for: day) }), in: 60...720, step: 15) {
                        HStack {
                            Text(weekdayNames[day - 1].capitalized(with: Locale(identifier: Strings.localeIdentifier)))
                            Spacer()
                            VStack(alignment: .trailing, spacing: 0) {
                                Text(Strings.durationText(minutes: minutes))
                                    .monospacedDigit()
                                    .foregroundStyle(byWeekday[day] == nil ? .secondary : .primary)
                                if byWeekday[day] == nil {
                                    Text(Strings.workdayDefaultTag)
                                        .font(.body)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                    }
                }
            } footer: {
                Text(Strings.workdayByWeekdayFooter)
            }

            if !byWeekday.isEmpty {
                Section {
                    Button(Strings.resetWorkdayHours, role: .destructive) {
                        byWeekday = [:]
                        save()
                    }
                }
            }
        }
        .navigationTitle(Strings.workdayByWeekdayTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    /// 기본값과 같으면 따로 두지 않는다 — 기본값을 바꾸면 따라 바뀌게
    private func set(_ minutes: Int, for day: Int) {
        byWeekday[day] = minutes == defaultMinutes ? nil : minutes
        save()
    }

    private func save() {
        LeaveLength.workdayMinutesByWeekday = byWeekday
        onChange()
    }
}
