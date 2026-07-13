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

    @State private var pickedItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var isScanning = false
    @State private var hasScanned = false
    @State private var candidates: [DetectedLeaveCandidate] = []
    @State private var duplicateCount = 0
    @State private var selectedIDs: Set<UUID> = []
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
        candidate.suggestedType.deductsFromAnnual
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
        isSaving = true

        let today = calendar.startOfDay(for: Date())
        var inserted: [LeaveRecord] = []
        for candidate in selected {
            let record = LeaveRecord(
                startDate: candidate.startDate,
                endDate: candidate.endDate,
                type: candidate.suggestedType,
                status: candidate.endDate < today ? .used : .planned,
                note: candidate.title
            )
            modelContext.insert(record)
            inserted.append(record)
        }

        do {
            try modelContext.save()
            HapticFeedback.success()
            importSucceeded = true
            resultMessage = Strings.leavesImported(inserted.count)
            AnalyticsService.logLeaveAdded(type: "photo_import", days: Double(inserted.count), isRecommended: false)
        } catch {
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
