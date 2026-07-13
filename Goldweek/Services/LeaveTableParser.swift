//
//  LeaveTableParser.swift
//  Goldweek
//
//  휴가 신청 내역 화면(사내 ERP 등)을 찍은 사진의 OCR 텍스트에서 휴가 기록을 추출한다.
//  Vision 의존 없이 순수 텍스트 파싱만 담당 — 단위 테스트/CLI 검증 가능.
//
//  특정 시스템(POVIS 등)에 종속되지 않도록 일반화된 규칙:
//  - 날짜: 2026.07.03 / 2026-07-03 / 2026/07/03 / 2026년 7월 3일 모두 인식
//  - 행에 날짜 1개면 하루짜리, 2개면 유효한 범위(종료≥시작, 60일 이내)일 때만 기간으로 해석
//    (신청일·결재일이 뒤에 붙는 표에서 오인하지 않기 위한 안전장치)
//  - 차감 일수("0.50일", "1일" 같은 독립 토큰)를 최우선 근거로 유형 결정
//  - 표 문맥 활용: 표 안에 차감 수치가 하나라도 있으면(=공제 열이 있는 표)
//    공제가 빈 행은 "연차 차감 없음"으로, 공제 열이 없는 표면 키워드·시간으로 판단
//  - 알려진 키워드가 없어도 차감 수치가 있는 행은 휴가로 인정 (미지의 유형명 대응)
//

import Foundation
import CoreGraphics

enum LeaveTableParser {

    // MARK: - 파싱 결과

    struct ParsedLeave: Equatable {
        let startDate: Date
        let endDate: Date
        /// 표의 휴무유형명 원문 (예: "대체휴가(1일)", "자녀돌봄(1/2)")
        let rawTypeName: String
        /// 오전/오후 또는 "16:00~18:00" 같은 시간 정보
        let timeInfo: String
        /// 실공제수 (없으면 nil)
        let deductionDays: Double?
        /// LeaveType.rawValue 로 매핑된 추천 유형
        let suggestedTypeRaw: String

        /// 기록의 note 로 쓸 원문 요약
        var noteText: String {
            timeInfo.isEmpty ? rawTypeName : "\(rawTypeName) \(timeInfo)"
        }
    }

    // MARK: - OCR 조각 → 행 재구성

    struct TextFragment {
        let text: String
        /// Vision 정규화 좌표 (원점 좌하단, 0~1)
        let box: CGRect
    }

    /// OCR 텍스트 조각들을 y좌표 기준으로 같은 행끼리 묶고, 행 안에서는 x좌표 순으로 정렬해 문자열로 합친다
    static func reconstructRows(from fragments: [TextFragment]) -> [String] {
        guard !fragments.isEmpty else { return [] }

        let heights = fragments.map { $0.box.height }.sorted()
        let medianHeight = heights[heights.count / 2]
        let tolerance = max(medianHeight * 0.6, 0.004)

        // y 중심 내림차순 = 화면 위에서 아래로
        let sorted = fragments.sorted { $0.box.midY > $1.box.midY }

        var rows: [[TextFragment]] = []
        var currentRow: [TextFragment] = []
        var currentMidY: CGFloat = 0

        for fragment in sorted {
            if currentRow.isEmpty {
                currentRow = [fragment]
                currentMidY = fragment.box.midY
            } else if abs(fragment.box.midY - currentMidY) <= tolerance {
                currentRow.append(fragment)
                // 행 대표 y를 누적 평균으로 갱신 (기울어진 사진 보정)
                currentMidY = currentRow.map { $0.box.midY }.reduce(0, +) / CGFloat(currentRow.count)
            } else {
                rows.append(currentRow)
                currentRow = [fragment]
                currentMidY = fragment.box.midY
            }
        }
        if !currentRow.isEmpty { rows.append(currentRow) }

        return rows.map { row in
            row.sorted { $0.box.minX < $1.box.minX }
                .map { $0.text }
                .joined(separator: " ")
        }
    }

    // MARK: - 유형 분류

    private enum TypeCategory {
        case annual, half, quarter, compensatory, sick, official, businessTrip, special, generic
    }

    /// 유형 키워드 → 분류. 긴/구체적인 것 먼저 매칭한다 ("반반차"가 "반차"보다, "대체휴가"가 "휴가"보다 먼저)
    private static let keywordTable: [(keyword: String, category: TypeCategory)] = [
        ("반반차", .quarter), ("quarter", .quarter),
        ("반차", .half), ("반일", .half), ("half", .half),
        ("연차", .annual), ("월차", .annual), ("annual", .annual), ("pto", .annual),
        ("대체휴가", .compensatory), ("대체휴무", .compensatory), ("대휴", .compensatory),
        ("보상휴가", .compensatory), ("보상휴무", .compensatory), ("compensatory", .compensatory),
        ("병가", .sick), ("병휴", .sick), ("sick", .sick),
        ("공가", .official),
        ("출장", .businessTrip),
        ("특별휴가", .special), ("경조", .special), ("조의", .special), ("결혼", .special),
        ("출산", .special), ("육아", .special), ("돌봄", .special), ("포상", .special),
        ("리프레시", .special), ("안식", .special), ("보건", .special),
        ("여름휴가", .generic), ("하계휴가", .generic), ("겨울휴가", .generic), ("동계휴가", .generic),
        ("휴가", .generic), ("휴무", .generic), ("vacation", .generic), ("leave", .generic),
    ]

    /// 이 단어가 있으면 무효 처리된 신청이므로 건너뛴다
    private static let rejectedKeywords = [
        "반려", "취소", "회수", "상신", "임시저장",
        "rejected", "cancelled", "canceled", "withdrawn", "draft",
    ]

    /// 유형명 후보에서 제외할 상태/부속 단어
    private static let stopwords: Set<String> = [
        "승인", "완료", "결재", "대기", "신청", "오전", "오후", "종일",
        "approved", "done", "am", "pm",
    ]

    // MARK: - 정규식

    /// 2026.07.03 / 2026-07-03 / 2026/07/03 / 2026년 7월 3일
    private static let dateRegex = try! NSRegularExpression(
        pattern: #"(20\d{2})\s*[.\-/년]\s*(\d{1,2})\s*[.\-/월]\s*(\d{1,2})(?:\s*일)?"#
    )
    /// 독립 토큰 형태의 차감 일수: "0.50일", "0.5일", "1일" — "대체휴가(1일)"처럼 괄호에 든 것은 제외
    private static let deductionTokenRegex = try! NSRegularExpression(
        pattern: #"^\d+(?:\.\d{1,2})?일$"#
    )
    private static let timeRangeRegex = try! NSRegularExpression(
        pattern: #"(\d{1,2}):(\d{2})\s*[~\-–]\s*(\d{1,2}):(\d{2})"#
    )

    /// 시작~종료가 이 일수를 넘으면 두 번째 날짜를 종료일이 아닌 다른 열(신청일 등)로 간주
    private static let maxRangeDays = 60

    // MARK: - 행 파싱

    /// 파싱 중간 결과 — 유형 확정은 표 전체 문맥(공제 열 유무)을 본 뒤에 한다
    private struct RawRow {
        let startDate: Date
        let endDate: Date
        let category: TypeCategory?    // nil = 미지의 유형명
        let rawTypeName: String
        let timeInfo: String
        let timeRangeHours: Double?
        let deduction: Double?

        var isMultiDay: Bool {
            !Calendar.current.isDate(startDate, inSameDayAs: endDate)
        }
    }

    static func parseRows(_ rows: [String]) -> [ParsedLeave] {
        let raws = rows.compactMap(parseRawRow)

        // 표 문맥: 차감 수치가 하나라도 있으면 "공제 열이 있는 표"
        let tableHasDeduction = raws.contains { $0.deduction != nil }

        var results: [ParsedLeave] = []
        var seenKeys = Set<String>()
        for raw in raws {
            let leave = ParsedLeave(
                startDate: raw.startDate,
                endDate: raw.endDate,
                rawTypeName: raw.rawTypeName,
                timeInfo: raw.timeInfo,
                deductionDays: raw.deduction,
                suggestedTypeRaw: suggestType(raw, tableHasDeduction: tableHasDeduction)
            )
            let key = "\(leave.startDate.timeIntervalSince1970)|\(leave.endDate.timeIntervalSince1970)|\(leave.rawTypeName)|\(leave.timeInfo)"
            guard seenKeys.insert(key).inserted else { continue }
            results.append(leave)
        }
        return results.sorted { $0.startDate < $1.startDate }
    }

    private static func parseRawRow(_ row: String) -> RawRow? {
        let lowered = row.lowercased()
        if rejectedKeywords.contains(where: { lowered.contains($0) }) { return nil }

        let range = NSRange(row.startIndex..., in: row)

        // 날짜: 최소 1개 필요. 2개 이상이면 앞의 두 개가 유효한 기간일 때만 범위로 해석
        let dateMatches = dateRegex.matches(in: row, range: range)
        let dates = dateMatches.compactMap { date(from: $0, in: row) }
        guard let start = dates.first else { return nil }

        // 날짜로 매칭된 영역을 마스킹 — "2026년 8월 3일"의 "3일"이 차감 토큰으로 오인되는 것 방지
        var masked = row
        for match in dateMatches.reversed() {
            if let r = Range(match.range, in: masked) {
                masked.replaceSubrange(r, with: String(repeating: " ", count: masked[r].count))
            }
        }
        var end = start
        if dates.count >= 2, dates[1] >= start,
           let gap = Calendar.current.dateComponents([.day], from: start, to: dates[1]).day,
           gap <= maxRangeDays {
            end = dates[1]
        }

        // 시간 정보
        var timeInfo = ""
        var timeRangeHours: Double?
        if let match = timeRangeRegex.firstMatch(in: row, range: range), let r = Range(match.range, in: row) {
            timeInfo = String(row[r]).replacingOccurrences(of: " ", with: "")
            if let h1 = int(match, 1, row), let m1 = int(match, 2, row),
               let h2 = int(match, 3, row), let m2 = int(match, 4, row) {
                let minutes = (h2 * 60 + m2) - (h1 * 60 + m1)
                if minutes > 0 { timeRangeHours = Double(minutes) / 60.0 }
            }
        } else if row.contains("오전") || lowered.contains(" am") {
            timeInfo = "오전"
        } else if row.contains("오후") || lowered.contains(" pm") {
            timeInfo = "오후"
        }

        // 차감 일수: 독립 토큰만 인정 ("대체휴가(1일)"의 "1일"은 토큰에 괄호가 있어 제외)
        let tokens = masked.split(separator: " ").map(String.init)
        var deduction: Double?
        for token in tokens where deductionTokenRegex.firstMatch(in: token, range: NSRange(token.startIndex..., in: token)) != nil {
            deduction = Double(token.dropLast())  // "일" 제거
            break
        }

        // 유형 키워드 (영문 키워드는 소문자로, 한글 키워드는 원문으로 비교)
        let matched = keywordTable.first { entry in
            entry.keyword.allSatisfy(\.isASCII)
                ? lowered.contains(entry.keyword)
                : row.contains(entry.keyword)
        }

        // 유형명 원문: 키워드를 포함한 토큰, 없으면(미지의 유형) 상태/날짜/시간이 아닌 가장 긴 토큰
        let rawTypeName: String
        if let matched {
            rawTypeName = tokens.first {
                $0.contains(matched.keyword) || $0.lowercased().contains(matched.keyword)
            } ?? matched.keyword
        } else {
            // 알려진 키워드가 없으면 차감 수치가 있는 행만 휴가로 인정 (오인식 방지)
            guard deduction != nil else { return nil }
            let candidates = tokens.filter { token in
                token.rangeOfCharacter(from: .letters) != nil
                    && token.rangeOfCharacter(from: .decimalDigits) == nil
                    && !stopwords.contains(token.lowercased())
            }
            guard let name = candidates.max(by: { $0.count < $1.count }) else { return nil }
            rawTypeName = name
        }

        return RawRow(
            startDate: start,
            endDate: end,
            category: matched?.category,
            rawTypeName: rawTypeName,
            timeInfo: timeInfo,
            timeRangeHours: timeRangeHours,
            deduction: deduction
        )
    }

    // MARK: - 유형 결정

    private static func suggestType(_ row: RawRow, tableHasDeduction: Bool) -> String {
        // 1. 명시적 비차감 유형은 키워드가 최우선 (대체휴무는 다른 날 근무의 보상이라 연차 차감 없음)
        switch row.category {
        case .compensatory: return "대체휴무"
        case .sick: return "병가"
        case .official: return "공가"
        case .businessTrip: return "출장"
        default: break
        }

        // 2. 차감 수치가 있으면 그것이 실제 차감의 근거
        if let deduction = row.deduction, deduction > 0 {
            if row.isMultiDay || deduction >= 0.75 { return "연차" }
            return deduction >= 0.375 ? "반차" : "반반차"
        }

        // 3. 공제 열이 있는 표에서 공제가 빈 행 → 연차를 차감하지 않는 휴가
        //    (단, 연차/반차류 명시 키워드는 OCR이 수치를 놓쳤을 수 있으므로 키워드를 믿는다)
        if tableHasDeduction {
            switch row.category {
            case .annual: return "연차"
            case .half: return "반차"
            case .quarter: return "반반차"
            default: return "특별휴가"
            }
        }

        // 4. 공제 열이 없는 표 → 키워드와 시간 정보로 추론
        switch row.category {
        case .annual: return "연차"
        case .half: return "반차"
        case .quarter: return "반반차"
        case .special: return "특별휴가"
        default:
            // generic(휴가/vacation) 또는 미지의 유형
            if let hours = row.timeRangeHours {
                if hours <= 2.5 { return "반반차" }
                if hours <= 5 { return "반차" }
                return "연차"
            }
            if row.timeInfo == "오전" || row.timeInfo == "오후" { return "반차" }
            return "연차"
        }
    }

    // MARK: - 헬퍼

    private static func date(from match: NSTextCheckingResult, in row: String) -> Date? {
        guard let year = int(match, 1, row),
              let month = int(match, 2, row),
              let day = int(match, 3, row),
              (1...12).contains(month), (1...31).contains(day) else { return nil }

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        guard let date = Calendar.current.date(from: components) else { return nil }
        return Calendar.current.startOfDay(for: date)
    }

    private static func int(_ match: NSTextCheckingResult, _ index: Int, _ row: String) -> Int? {
        guard let range = Range(match.range(at: index), in: row) else { return nil }
        return Int(row[range])
    }
}
