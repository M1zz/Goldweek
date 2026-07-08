//
//  ShareScheduleView.swift
//  Goldweek
//
//  일정 공유 관리 화면
//  - 내 일정 공유 시작/중지, 초대 링크 보내기, 참여자 확인
//  - 공유받은 일정 목록 표시 및 나가기
//

import SwiftUI
import SwiftData
import CloudKit

// MARK: - CKShare 공유 시트용 Transferable
struct ScheduleSharePayload: Transferable {
    let share: CKShare
    let container: CKContainer

    static var transferRepresentation: some TransferRepresentation {
        CKShareTransferRepresentation { payload in
            .existing(payload.share, container: payload.container)
        }
    }
}

struct ShareScheduleView: View {
    @Bindable var profile: UserProfile
    @Query(sort: \LeaveRecord.startDate) private var leaveRecords: [LeaveRecord]

    @State private var service = ShareSyncService.shared
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingStopConfirm = false
    @State private var leavingSchedule: SharedSchedule?

    var body: some View {
        Form {
            if !service.accountAvailable {
                Section {
                    Label(Strings.shareICloudRequired, systemImage: "exclamationmark.icloud")
                        .foregroundStyle(.orange)
                        .font(.subheadline)
                }
            }

            // MARK: 내 일정 공유
            Section {
                if service.isSharingActive {
                    HStack {
                        Image(systemName: "checkmark.icloud.fill")
                            .foregroundStyle(.green)
                        Text(Strings.shareStatusActive)
                        Spacer()
                        Text(Strings.shareParticipants(service.participantNames.count))
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }

                    if service.participantNames.isEmpty {
                        Text(Strings.shareNoParticipants)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(service.participantNames, id: \.self) { name in
                            Label(name, systemImage: "person.fill")
                                .font(.subheadline)
                        }
                    }

                    if let share = service.myShare {
                        ShareLink(
                            item: ScheduleSharePayload(
                                share: share,
                                container: CKContainer(identifier: ShareSyncService.containerIdentifier)
                            ),
                            preview: SharePreview(Strings.shareCKTitle(profile.name))
                        ) {
                            Label(Strings.shareInviteLink, systemImage: "envelope")
                        }
                    }

                    Button {
                        Task {
                            await service.mirrorMySchedule(
                                profile: ProfileSnapshot(profile: profile),
                                leaves: leaveRecords.map(LeaveSnapshot.init)
                            )
                            await service.refreshMyShareState()
                        }
                    } label: {
                        HStack {
                            Label(Strings.shareSyncNow, systemImage: "arrow.triangle.2.circlepath")
                            Spacer()
                            if service.isWorking {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(service.isWorking)

                    Button(role: .destructive) {
                        showingStopConfirm = true
                    } label: {
                        Label(Strings.shareStop, systemImage: "xmark.icloud")
                    }
                    .disabled(service.isWorking)
                } else {
                    Button {
                        startSharing()
                    } label: {
                        HStack {
                            Label(Strings.shareStartButton, systemImage: "person.2.badge.plus")
                            Spacer()
                            if service.isWorking {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(service.isWorking || !service.accountAvailable)
                }
            } header: {
                Text(Strings.shareMySection)
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.shareFooterPrivacy)
                    if let last = service.lastSyncDate {
                        Text(Strings.shareLastSync(last.formatted(date: .abbreviated, time: .shortened)))
                    }
                }
            }

            // MARK: 공유받은 일정
            Section(Strings.shareReceivedSection) {
                if service.sharedSchedules.isEmpty {
                    Text(Strings.shareReceivedEmpty)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                } else {
                    ForEach(service.sharedSchedules) { schedule in
                        SharedScheduleRow(schedule: schedule)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    leavingSchedule = schedule
                                } label: {
                                    Label(Strings.shareLeaveButton, systemImage: "rectangle.portrait.and.arrow.right")
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle(Strings.shareScheduleTitle)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await service.updateAccountStatus()
            await service.refreshMyShareState()
            await service.refreshSharedSchedules()
        }
        .task {
            await service.onAppActive(
                profile: ProfileSnapshot(profile: profile),
                leaves: leaveRecords.map(LeaveSnapshot.init)
            )
        }
        .alert(Strings.shareStopConfirmTitle, isPresented: $showingStopConfirm) {
            Button(Strings.cancel, role: .cancel) { }
            Button(Strings.shareStop, role: .destructive) {
                Task {
                    do {
                        try await service.stopSharing()
                    } catch {
                        presentError(error)
                    }
                }
            }
        } message: {
            Text(Strings.shareStopConfirmMessage)
        }
        .alert(
            Strings.shareLeaveButton,
            isPresented: Binding(
                get: { leavingSchedule != nil },
                set: { if !$0 { leavingSchedule = nil } }
            )
        ) {
            Button(Strings.cancel, role: .cancel) { leavingSchedule = nil }
            Button(Strings.shareLeaveButton, role: .destructive) {
                if let schedule = leavingSchedule {
                    Task { await service.leaveSharedSchedule(schedule) }
                }
                leavingSchedule = nil
            }
        } message: {
            Text(Strings.shareLeaveConfirmMessage(leavingSchedule?.ownerName ?? ""))
        }
        .alert(Strings.shareErrorTitle, isPresented: $showingError) {
            Button(Strings.confirm, role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func startSharing() {
        Task {
            do {
                _ = try await service.startSharing(
                    profile: ProfileSnapshot(profile: profile),
                    leaves: leaveRecords.map(LeaveSnapshot.init)
                )
            } catch {
                presentError(error)
            }
        }
    }

    private func presentError(_ error: Error) {
        errorMessage = Strings.shareErrorGeneric(error.localizedDescription)
        showingError = true
    }
}

// MARK: - 공유받은 일정 행 (펼치면 다가오는 휴가 표시)
struct SharedScheduleRow: View {
    let schedule: SharedSchedule

    var body: some View {
        DisclosureGroup {
            let upcoming = schedule.upcomingLeaves
            if upcoming.isEmpty {
                Text(Strings.shareNoUpcoming)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(upcoming.prefix(10)) { leave in
                    HStack {
                        Image(systemName: leave.type.icon)
                            .foregroundStyle(.blue)
                            .frame(width: 24)
                            .voDecorative()
                        VStack(alignment: .leading, spacing: 2) {
                            Text(dateRangeText(leave))
                                .font(.subheadline)
                            Text(leave.type.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(leave.status.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(leave.status == .used ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .voDecorative()
                VStack(alignment: .leading, spacing: 2) {
                    Text(schedule.ownerName)
                        .font(.body.weight(.medium))
                    Text(Strings.shareUpcomingCount(schedule.upcomingLeaves.count))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func dateRangeText(_ leave: SharedLeaveItem) -> String {
        let start = leave.startDate.formatted(date: .abbreviated, time: .omitted)
        if Calendar.current.isDate(leave.startDate, inSameDayAs: leave.endDate) {
            return start
        }
        let end = leave.endDate.formatted(date: .abbreviated, time: .omitted)
        return "\(start) ~ \(end)"
    }
}
