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
        /// 모든 날이 이미 등록돼 있어 통째로 제외된 개수 (일부만 빠진 건 빠진 날만 후보로 남는다)
        let duplicateCount: Int
    }

    /// 사진에서 휴가 표를 인식해 후보 목록을 만든다. 이미 등록된 날은 빼고 **빠진 날만** 후보로 남긴다.
    func scanLeaveTable(in image: UIImage, existingRecords: [LeaveRecord]) async throws -> ScanResult {
        let fragments = try await recognizeText(in: image)
        let rows = LeaveTableParser.reconstructRows(from: fragments)
        let parsed = LeaveTableParser.parseRows(rows)
        logInfo("사진 OCR: 조각 \(fragments.count)개 → 행 \(rows.count)개 → 휴가 \(parsed.count)건", category: .data)

        let inputs: [ImportedLeave] = parsed.compactMap { leave in
            guard let type = LeaveType(rawValue: leave.suggestedTypeRaw) else { return nil }
            return ImportedLeave(title: leave.noteText, startDate: leave.startDate, endDate: leave.endDate,
                                 type: type, length: leave.suggestedLength)
        }
        return Self.missingLeaves(inputs, existingRecords: existingRecords,
                                  isDayOff: { DayOffCalendar.shared.isDayOff($0) })
    }

    /// 사진에서 읽은 휴가 한 건 (중복 비교 전)
    struct ImportedLeave {
        let title: String
        let startDate: Date
        let endDate: Date
        let type: LeaveType
        let length: LeaveLength
    }

    /// 사진 내역과 이미 등록된 기록을 **날짜 단위**로 맞춰 보고, 등록되지 않은 날만 후보로 돌려준다.
    ///
    /// 예전에는 시작일·종료일·유형이 모두 같아야 중복으로 봤다. 그래서
    ///  · 앱에 10/1~10/3 하나로 넣었는데 사진엔 하루씩 세 줄이면 → 세 줄이 다 새로 들어가 두 번 차감
    ///  · 앱에 "연차"로 넣은 날이 사진엔 "대체휴가"면 → 같은 날 휴가가 둘
    ///  · 사진의 10/1~10/5 중 10/1만 등록돼 있으면 → 5일이 통째로 다시 들어감
    /// 이제는 날마다 이미 얼마나 등록됐는지(종일 1, 반차 0.5, 반반차 0.25 — 유형은 따지지 않음)를 보고,
    /// 다 채워진 날은 빼고 비어 있는 날만 이어지는 구간으로 다시 묶어 넣는다.
    /// 같은 날 오전 반차가 있고 사진에 반차가 하나 더 있으면, 하루 1을 넘지 않는 한 새로 넣는다.
    static func missingLeaves(_ leaves: [ImportedLeave],
                              existingRecords: [LeaveRecord],
                              isDayOff: (Date) -> Bool,
                              calendar: Calendar = .current) -> ScanResult {
        // 날짜별로 이미 등록된 양 — 취소된 기록은 없는 것으로 본다
        var covered: [Date: Double] = [:]
        for record in existingRecords where record.status != .cancelled {
            let fraction = record.length.fraction
            forEachDay(from: record.startDate, to: record.endDate, calendar: calendar) {
                covered[$0, default: 0] += fraction
            }
        }

        let epsilon = 0.001
        var candidates: [DetectedLeaveCandidate] = []
        var duplicateCount = 0
        for leave in leaves {
            let fraction = leave.length.fraction
            var days: [Date] = []
            forEachDay(from: leave.startDate, to: leave.endDate, calendar: calendar) { days.append($0) }
            // 쉬는 날은 연차가 아니니 비교하지 않는다 (전부 쉬는 날이면 달력 그대로 비교)
            let workdays = days.filter { !isDayOff($0) }
            let checked = workdays.isEmpty ? days : workdays

            // 이 날에 이 휴가가 더 들어갈 자리가 있나 — 하루 1을 넘으면 이미 등록된 것
            let missing = Set(checked.filter { (covered[$0] ?? 0) + fraction <= 1 + epsilon })
            if missing.isEmpty {
                duplicateCount += 1
                continue
            }
            for day in missing { covered[day, default: 0] += fraction }

            // 빠진 날을 이어지는 구간으로 — 사이에 낀 쉬는 날은 구간을 끊지 않는다
            var segments: [(start: Date, end: Date)] = []
            var current: (start: Date, end: Date)?
            for day in days {
                if missing.contains(day) {
                    current = (current?.start ?? day, day)
                } else if checked.contains(day) {
                    if let c = current { segments.append(c) }
                    current = nil
                }
            }
            if let c = current { segments.append(c) }

            for seg in segments {
                candidates.append(DetectedLeaveCandidate(
                    title: leave.title,
                    startDate: seg.start,
                    endDate: seg.end,
                    suggestedType: leave.type,
                    suggestedLength: leave.length
                ))
            }
        }
        return ScanResult(candidates: candidates, duplicateCount: duplicateCount)
    }

    private static func forEachDay(from start: Date, to end: Date, calendar: Calendar, _ body: (Date) -> Void) {
        var d = calendar.startOfDay(for: start)
        let last = calendar.startOfDay(for: end)
        while d <= last {
            body(d)
            guard let next = calendar.date(byAdding: .day, value: 1, to: d) else { break }
            d = next
        }
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
