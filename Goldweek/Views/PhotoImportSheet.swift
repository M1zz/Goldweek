//
//  PhotoImportSheet.swift
//  Goldweek
//
//  휴가 신청 내역 화면을 찍은 사진에서 휴가 기록을 인식해 일괄 등록한다.
//  실공제수가 없는 대체휴가 등은 연차 차감 없는 유형으로 등록된다.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PhotoImportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var existingRecords: [LeaveRecord]

    // 사용 가능한 보너스 연차 (미사용 + 미만료) — 특별휴가류 후보를 보너스에서 차감할 때 사용
    @Query(filter: #Predicate<BonusLeave> { $0.isUsed == false })
    private var unusedBonusLeaves: [BonusLeave]

    @State private var pickedItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var isScanning = false
    @State private var hasScanned = false
    @State private var candidates: [DetectedLeaveCandidate] = []
    @State private var duplicateCount = 0
    @State private var selectedIDs: Set<UUID> = []
    /// 후보 id → 차감할 보너스 연차 id (자동 매칭 후 사용자가 행별로 변경 가능)
    @State private var bonusAssignments: [UUID: UUID] = [:]
    @State private var scanErrorMessage: String?
    @State private var isSaving = false
    @State private var resultMessage = ""
    @State private var showingResultAlert = false
    @State private var importSucceeded = false

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            Group {
                if isScanning {
                    scanningView
                } else if !hasScanned {
                    photoPickerView
                } else if candidates.isEmpty {
                    emptyResultView
                } else {
                    resultListView
                }
            }
            .navigationTitle(Strings.importFromPhoto)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
                if !candidates.isEmpty && !isScanning {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            importSelected()
                        } label: {
                            if isSaving {
                                ProgressView().scaleEffect(0.8)
                            } else {
                                Text(Strings.importSelectedLeaves(selectedIDs.count))
                                    .fontWeight(.semibold)
                            }
                        }
                        .disabled(selectedIDs.isEmpty || isSaving)
                    }
                }
            }
            .onChange(of: pickedItem) { _, newItem in
                guard let newItem else { return }
                Task { await loadAndScan(item: newItem) }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraPicker { image in
                    Task { await scan(image: image) }
                }
                .ignoresSafeArea()
            }
            .alert(Strings.alert, isPresented: $showingResultAlert) {
                Button(Strings.confirm, role: .cancel) {
                    if importSucceeded { dismiss() }
                }
            } message: {
                Text(resultMessage)
            }
        }
    }

    // MARK: - 사진 선택 화면

    private var photoPickerView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 56))
                .foregroundStyle(.blue)
                .voDecorative()

            Text(Strings.photoImportGuide)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let errorMessage = scanErrorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 12) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button {
                        showingCamera = true
                    } label: {
                        Label(Strings.takePhoto, systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

                PhotosPicker(selection: $pickedItem, matching: .images) {
                    Label(Strings.choosePhoto, systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var scanningView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(Strings.scanningPhoto)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyResultView: some View {
        VStack(spacing: 12) {
            Image(systemName: duplicateCount > 0 ? "checkmark.circle" : "text.magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
                .voDecorative()
            Text(duplicateCount > 0
                 ? Strings.photoImportAllDuplicates(duplicateCount)
                 : Strings.noLeaveFoundInPhoto)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button(Strings.chooseAnotherPhoto) {
                resetToPickerState()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 인식 결과 목록

    private var resultListView: some View {
        List {
            Section {
                ForEach(candidates) { candidate in
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            toggleSelection(candidate.id)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: selectedIDs.contains(candidate.id)
                                      ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(selectedIDs.contains(candidate.id)
                                                     ? AppTheme.Colors.brand : Color(.systemGray3))
                                    .voDecorative()

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(candidate.title)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    HStack(spacing: 6) {
                                        Text(Strings.leaveTypeName(candidate.suggestedType))
                                            .font(.caption2.weight(.semibold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(candidate.suggestedType.themeColor.opacity(0.15))
                                            .foregroundStyle(candidate.suggestedType.themeColor)
                                            .clipShape(Capsule())
                                        Text(deductionText(candidate))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(dateRangeText(candidate))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text("\(candidate.title), \(Strings.leaveTypeName(candidate.suggestedType)), \(dateRangeText(candidate)), \(deductionText(candidate))"))
                        .accessibilityAddTraits(selectedIDs.contains(candidate.id) ? .isSelected : [])

                        if !availableBonusLeaves.isEmpty {
                            bonusMenu(for: candidate)
                                .padding(.leading, 34)  // 체크 아이콘 폭만큼 들여쓰기
                        }
                    }
                }
            } header: {
                Text(Strings.detectedLeaveCandidates)
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.photoImportFooter)
                    if duplicateCount > 0 {
                        Text(Strings.duplicatesExcluded(duplicateCount))
                    }
                }
            }

            Section {
                Button(Strings.chooseAnotherPhoto) {
                    resetToPickerState()
                }
            }
        }
    }

    // MARK: - 보너스 연차 연결

    /// 만료되지 않은 보너스 연차
    private var availableBonusLeaves: [BonusLeave] {
        let now = Date()
        return unusedBonusLeaves.filter {
            $0.expirationDate == nil || $0.expirationDate! > now
        }
    }

    private func assignedBonus(for candidate: DetectedLeaveCandidate) -> BonusLeave? {
        guard let bonusID = bonusAssignments[candidate.id] else { return nil }
        return availableBonusLeaves.first { $0.id == bonusID }
    }

    /// 연차 차감 없는 후보(자녀돌봄, 포상 등)를 유형이 맞는 보너스 연차에 자동 연결.
    /// 잔여 일수를 누적 추적해 같은 보너스에 과할당하지 않는다.
    private func autoAssignBonuses() {
        var remaining: [UUID: Double] = [:]
        for bonus in availableBonusLeaves {
            remaining[bonus.id] = bonus.remainingDays
        }

        var assignments: [UUID: UUID] = [:]
        for candidate in candidates {
            guard !candidate.suggestedType.deductsFromAnnual,
                  let bonusType = BonusLeaveType.matching(candidate.title) else { continue }
            guard let bonus = availableBonusLeaves.first(where: {
                $0.type == bonusType && (remaining[$0.id] ?? 0) >= candidate.effectiveDays
            }) else { continue }
            assignments[candidate.id] = bonus.id
            remaining[bonus.id]! -= candidate.effectiveDays
        }
        bonusAssignments = assignments
    }

    /// 후보별 차감 보너스 선택 메뉴
    private func bonusMenu(for candidate: DetectedLeaveCandidate) -> some View {
        Menu {
            Button {
                bonusAssignments[candidate.id] = nil
            } label: {
                if bonusAssignments[candidate.id] == nil {
                    Label(Strings.bonusDeductNone, systemImage: "checkmark")
                } else {
                    Text(Strings.bonusDeductNone)
                }
            }
            ForEach(availableBonusLeaves) { bonus in
                Button {
                    bonusAssignments[candidate.id] = bonus.id
                } label: {
                    let title = "\(Strings.bonusLeaveTypeName(bonus.type)) · \(Strings.availableDays(formatLeave(bonus.remainingDays)))"
                    if bonusAssignments[candidate.id] == bonus.id {
                        Label(title, systemImage: "checkmark")
                    } else {
                        Text(title)
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "gift.fill")
                    .font(.caption2)
                if let bonus = assignedBonus(for: candidate) {
                    Text(Strings.bonusDeductionSummary(
                        name: Strings.bonusLeaveTypeName(bonus.type),
                        daysText: formatLeave(candidate.effectiveDays)
                    ))
                } else {
                    Text(Strings.bonusDeductNone)
                }
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
            }
            .font(.caption)
            .foregroundStyle(assignedBonus(for: candidate) != nil ? AppTheme.Colors.bonus : .secondary)
        }
        .buttonStyle(.borderless)
    }

    // MARK: - 동작

    private func toggleSelection(_ id: UUID) {
        HapticFeedback.selection()
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    private func deductionText(_ candidate: DetectedLeaveCandidate) -> String {
        if assignedBonus(for: candidate) != nil {
            return "\(formatLeave(candidate.effectiveDays))\(Strings.dayUnitSuffix)"
        }
        return candidate.suggestedType.deductsFromAnnual
            ? "\(formatLeave(candidate.effectiveDays))\(Strings.dayUnitSuffix)"
            : Strings.noDeduction
    }

    private func dateRangeText(_ candidate: DetectedLeaveCandidate) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Strings.localeIdentifier)
        formatter.dateFormat = Strings.dateRangeFormat
        if calendar.isDate(candidate.startDate, inSameDayAs: candidate.endDate) {
            return formatter.string(from: candidate.startDate)
        }
        return "\(formatter.string(from: candidate.startDate)) ~ \(formatter.string(from: candidate.endDate))"
    }

    private func resetToPickerState() {
        hasScanned = false
        candidates = []
        selectedIDs = []
        bonusAssignments = [:]
        duplicateCount = 0
        pickedItem = nil
        scanErrorMessage = nil
    }

    private func loadAndScan(item: PhotosPickerItem) async {
        isScanning = true
        defer { isScanning = false }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else {
            scanErrorMessage = Strings.photoImportInvalidImage
            pickedItem = nil
            return
        }
        await scan(image: image)
    }

    private func scan(image: UIImage) async {
        isScanning = true
        scanErrorMessage = nil
        do {
            let result = try await PhotoImportService.shared.scanLeaveTable(
                in: image,
                existingRecords: existingRecords
            )
            candidates = result.candidates
            duplicateCount = result.duplicateCount
            selectedIDs = Set(result.candidates.map(\.id))  // 기본 전체 선택
            autoAssignBonuses()
            hasScanned = true
        } catch {
            scanErrorMessage = error.localizedDescription
            hasScanned = false
        }
        pickedItem = nil
        isScanning = false
    }

    private func importSelected() {
        let selected = candidates.filter { selectedIDs.contains($0.id) }
        guard !selected.isEmpty else { return }

        // 보너스별 차감 예정 일수 합산 후 잔여 검증 (여러 후보가 같은 보너스를 쓸 수 있음)
        var pendingDeductions: [UUID: Double] = [:]
        for candidate in selected {
            if let bonus = assignedBonus(for: candidate) {
                pendingDeductions[bonus.id, default: 0] += candidate.effectiveDays
            }
        }
        for (bonusID, days) in pendingDeductions {
            guard let bonus = availableBonusLeaves.first(where: { $0.id == bonusID }) else { continue }
            if days > bonus.remainingDays {
                HapticFeedback.error()
                importSucceeded = false
                resultMessage = Strings.insufficientBonus(Strings.bonusLeaveTypeName(bonus.type))
                showingResultAlert = true
                return
            }
        }

        isSaving = true

        let today = calendar.startOfDay(for: Date())
        var inserted: [LeaveRecord] = []
        for candidate in selected {
            let record = LeaveRecord(
                startDate: candidate.startDate,
                endDate: candidate.endDate,
                type: candidate.suggestedType,
                status: candidate.endDate < today ? .used : .planned,
                note: candidate.title,
                length: candidate.suggestedLength,  // 종일/반차/반반차 — "(1/2)" 등 반영
                bonusLeaveId: assignedBonus(for: candidate)?.id  // 보너스 연결 — 삭제 시 usedDays 복원에 사용
            )
            modelContext.insert(record)
            inserted.append(record)
        }

        // 보너스 연차 차감
        var deducted: [(bonus: BonusLeave, days: Double, wasUsed: Bool)] = []
        for (bonusID, days) in pendingDeductions {
            guard let bonus = availableBonusLeaves.first(where: { $0.id == bonusID }) else { continue }
            deducted.append((bonus, days, bonus.isUsed))
            bonus.usedDays += days
            if bonus.remainingDays <= 0 {
                bonus.isUsed = true
            }
        }

        do {
            try modelContext.save()
            HapticFeedback.success()
            importSucceeded = true
            resultMessage = Strings.leavesImported(inserted.count)
            AnalyticsService.logLeaveAdded(type: "photo_import", days: Double(inserted.count), isRecommended: false)
        } catch {
            // 롤백
            for entry in deducted {
                entry.bonus.usedDays -= entry.days
                entry.bonus.isUsed = entry.wasUsed
            }
            inserted.forEach { modelContext.delete($0) }
            HapticFeedback.error()
            importSucceeded = false
            resultMessage = Strings.saveFailed
        }
        isSaving = false
        showingResultAlert = true
    }
}

// MARK: - 카메라 촬영

struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let onCapture: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onCapture(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
    let container = try! ModelContainer(
        for: UserProfile.self, LeaveRecord.self, BonusLeave.self, CustomHoliday.self,
        configurations: config
    )
    return PhotoImportSheet()
        .modelContainer(container)
}
