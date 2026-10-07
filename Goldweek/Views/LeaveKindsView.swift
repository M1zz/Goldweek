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
    @State private var store = LeaveStyleStore.shared
    @State private var editing: CustomLeaveType?
    @State private var showingNew = false

    var body: some View {
        List {
            Section {
                ForEach(LeaveType.categories, id: \.self) { type in
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
            } header: {
                Text(Strings.builtInLeaveKinds)
            }

            Section {
                ForEach(customTypes) { kind in
                    Button {
                        editing = kind
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(kind.color)
                                .frame(width: 16, height: 16)
                                .frame(width: 24)
                                .voDecorative()
                            Text(kind.name)
                                .foregroundStyle(.primary)
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
                .onDelete(perform: delete)

                Button {
                    showingNew = true
                } label: {
                    Label(Strings.addLeaveKind, systemImage: "plus.circle.fill")
                }
            } header: {
                Text(Strings.myLeaveKinds)
            } footer: {
                Text(customTypes.isEmpty ? Strings.leaveKindsFooter
                     : "\(Strings.leaveKindsFooter)\n\(Strings.deleteLeaveKindNote)")
            }
        }
        .navigationTitle(Strings.leaveKindsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingNew) {
            LeaveKindEditor(kind: nil)
        }
        .sheet(item: $editing) { kind in
            LeaveKindEditor(kind: kind)
        }
    }

    /// 종류를 지워도 그 종류로 남긴 휴가는 지우지 않는다 — 기본 유형(연차/특별휴가)으로 보인다
    private func delete(at offsets: IndexSet) {
        for i in offsets { modelContext.delete(customTypes[i]) }
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

    @State private var name = ""
    @State private var color = Color(hex: "4FACFE") ?? .blue
    @State private var deducts = true
    @State private var didLoad = false

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
                if let kind {
                    name = kind.name
                    color = kind.color
                    deducts = kind.deductsFromAnnual
                }
            }
        }
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
