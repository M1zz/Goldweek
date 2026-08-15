//
//  TimeMachineView.swift
//  Goldweek
//
//  타임머신: 저장된 시점 목록을 보고 원하는 시점으로 데이터를 되돌린다
//

import SwiftUI
import SwiftData
import TipKit

struct TimeMachineView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var snapshots: [TimeMachineService.SnapshotInfo] = []
    @State private var pendingRestore: TimeMachineService.SnapshotInfo?
    @State private var showingRestoreConfirm = false
    @State private var showingResult = false
    @State private var resultMessage = ""

    var body: some View {
        List {
            Section {
                Button {
                    createSnapshot()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.purple)
                        Text(Strings.snapshotNow)
                            .foregroundStyle(.primary)
                    }
                }
            } footer: {
                Text(Strings.timeMachineFooter)
            }

            Section {
                if snapshots.isEmpty {
                    Text(Strings.noSnapshots)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(snapshots) { info in
                        Button {
                            pendingRestore = info
                            showingRestoreConfirm = true
                        } label: {
                            snapshotRow(info)
                        }
                    }
                    .onDelete(perform: deleteSnapshots)
                }
            } header: {
                Text(Strings.snapshotList)
            }
        }
        .navigationTitle(Strings.timeMachine)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AppTips.timeMachine.invalidate(reason: .actionPerformed)
            reload()
        }
        .alert(Strings.restoreSnapshotTitle, isPresented: $showingRestoreConfirm) {
            Button(Strings.cancel, role: .cancel) { pendingRestore = nil }
            Button(Strings.restore, role: .destructive) { performRestore() }
        } message: {
            if let info = pendingRestore {
                Text(Strings.restoreSnapshotMessage(formatted(info.createdAt)))
            }
        }
        .alert(Strings.timeMachine, isPresented: $showingResult) {
            Button(Strings.confirm, role: .cancel) { }
        } message: {
            Text(resultMessage)
        }
    }

    private func snapshotRow(_ info: TimeMachineService.SnapshotInfo) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatted(info.createdAt))
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Text(Strings.snapshotSummary(leaves: info.leaveCount, bonuses: info.bonusCount))
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(info.reason.displayName)
                .font(.body)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.purple.opacity(0.12))
                .foregroundStyle(.purple)
                .cornerRadius(4)
        }
        .accessibilityElement(children: .combine)
    }

    private func formatted(_ date: Date) -> String {
        date.appFormatted(time: .short)
    }

    private func reload() {
        snapshots = TimeMachineService.shared.snapshotInfos()
    }

    private func createSnapshot() {
        logInfo("사용자 수동 스냅샷 요청", category: .ui)
        let created = TimeMachineService.shared.captureNow(from: modelContext, reason: .manual)
        resultMessage = created ? Strings.snapshotCreated : Strings.snapshotFailed
        if created {
            HapticFeedback.success()
        } else {
            HapticFeedback.error()
        }
        showingResult = true
        reload()
    }

    private func performRestore() {
        guard let info = pendingRestore else { return }
        pendingRestore = nil
        do {
            try TimeMachineService.shared.restore(from: info, to: modelContext)
            resultMessage = Strings.restoreSuccessMessage
            HapticFeedback.success()
        } catch {
            resultMessage = error.localizedDescription
            HapticFeedback.error()
        }
        showingResult = true
        reload()
    }

    private func deleteSnapshots(at offsets: IndexSet) {
        for index in offsets {
            TimeMachineService.shared.deleteSnapshot(snapshots[index])
        }
        reload()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
    let container = try! ModelContainer(
        for: UserProfile.self, LeaveRecord.self, BonusLeave.self, CustomHoliday.self,
        configurations: config
    )
    return NavigationStack {
        TimeMachineView()
    }
    .modelContainer(container)
}
