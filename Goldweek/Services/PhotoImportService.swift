//
//  PhotoImportService.swift
//  Goldweek
//
//  사진(휴가 신청 내역 화면 캡처/촬영)에서 Vision OCR로 휴가 기록을 추출한다.
//  텍스트 파싱 로직은 LeaveTableParser에 분리되어 있다.
//

import Foundation
import Vision
import UIKit

final class PhotoImportService {
    static let shared = PhotoImportService()

    private init() {}

    struct ScanResult {
        let candidates: [DetectedLeaveCandidate]
        /// 이미 등록된 기록과 중복이라 제외된 개수
        let duplicateCount: Int
    }

    /// 사진에서 휴가 표를 인식해 후보 목록을 만든다. 기존 기록과 중복(같은 날짜+유형)은 제외.
    func scanLeaveTable(in image: UIImage, existingRecords: [LeaveRecord]) async throws -> ScanResult {
        let fragments = try await recognizeText(in: image)
        let rows = LeaveTableParser.reconstructRows(from: fragments)
        let parsed = LeaveTableParser.parseRows(rows)
        logInfo("사진 OCR: 조각 \(fragments.count)개 → 행 \(rows.count)개 → 휴가 \(parsed.count)건", category: .data)

        let calendar = Calendar.current
        let activeRecords = existingRecords.filter { $0.status != .cancelled }

        var candidates: [DetectedLeaveCandidate] = []
        var duplicateCount = 0
        for leave in parsed {
            guard let type = LeaveType(rawValue: leave.suggestedTypeRaw) else { continue }
            let isDuplicate = activeRecords.contains { record in
                calendar.isDate(record.startDate, inSameDayAs: leave.startDate)
                    && calendar.isDate(record.endDate, inSameDayAs: leave.endDate)
                    && record.type == type
            }
            if isDuplicate {
                duplicateCount += 1
                continue
            }
            candidates.append(DetectedLeaveCandidate(
                title: leave.noteText,
                startDate: leave.startDate,
                endDate: leave.endDate,
                suggestedType: type
            ))
        }
        return ScanResult(candidates: candidates, duplicateCount: duplicateCount)
    }

    private func recognizeText(in image: UIImage) async throws -> [LeaveTableParser.TextFragment] {
        guard let cgImage = image.cgImage else {
            throw PhotoImportError.invalidImage
        }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let request = VNRecognizeTextRequest()
                request.recognitionLevel = .accurate
                request.recognitionLanguages = ["ko-KR", "en-US"]
                // 날짜/숫자 표라서 언어 보정이 오히려 오인식을 유발한다
                request.usesLanguageCorrection = false

                let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
                do {
                    try handler.perform([request])
                    let fragments = (request.results ?? []).compactMap { observation -> LeaveTableParser.TextFragment? in
                        guard let top = observation.topCandidates(1).first else { return nil }
                        return LeaveTableParser.TextFragment(text: top.string, box: observation.boundingBox)
                    }
                    continuation.resume(returning: fragments)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

enum PhotoImportError: LocalizedError {
    case invalidImage

    var errorDescription: String? {
        switch self {
        case .invalidImage: return Strings.photoImportInvalidImage
        }
    }
}

private extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
