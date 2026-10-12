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
import PDFKit

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

// MARK: - 학교 달력 글 읽기

extension PhotoImportService {
    /// 사진 속 글을 줄 단위로 — 같은 높이의 글 조각은 한 줄로 합친다 (왼쪽 날짜 · 오른쪽 이름)
    func recognizeLines(in image: UIImage) async throws -> String {
        let fragments = try await recognizeText(in: image)
        return LeaveTableParser.reconstructRows(from: fragments).joined(separator: "\n")
    }

    /// PDF 글 — 글이 들어 있는 PDF는 그대로, 스캔한 PDF는 쪽마다 그림으로 바꿔 읽는다 (앞 6쪽까지)
    func text(fromPDF url: URL) async throws -> String {
        guard let doc = PDFDocument(url: url) else { throw PhotoImportError.invalidImage }
        var parts: [String] = []
        for i in 0..<min(doc.pageCount, 6) {
            guard let page = doc.page(at: i) else { continue }
            if let s = page.string, s.trimmingCharacters(in: .whitespacesAndNewlines).count > 20 {
                parts.append(s)
            } else {
                let bounds = page.bounds(for: .mediaBox)
                let scale = min(3, 2400 / max(bounds.width, bounds.height, 1))
                let image = page.thumbnail(of: CGSize(width: bounds.width * scale, height: bounds.height * scale), for: .mediaBox)
                parts.append(try await recognizeLines(in: image))
            }
        }
        return parts.joined(separator: "\n")
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

// MARK: - 학교 달력 가져오기 (미국 교사 피드백: 학교 달력이 사진·PDF로만 온다)

/// 학교 달력 글(사진 OCR·PDF·붙여 넣은 글)에서 날짜와 이름을 찾아 쉬는 날·휴가 불가 기간 후보를 만든다.
/// 칸으로 된 달력보다 "Nov 24-28 Thanksgiving Break" 같은 주요 일정 목록을 잘 읽는다.
enum SchoolCalendarParser {
    enum Suggestion: Equatable {
        /// 학교가 쉬는 날 → 내 방학 (연차 차감 없음)
        case dayOff
        /// 시험 주간 등 → 휴가 불가 기간
        case blackout
        /// 개학·교사 근무일 등 — 기본으로 넣지 않는다
        case skip
    }

    struct Item: Identifiable, Equatable {
        let id = UUID()
        var name: String
        var start: Date
        var end: Date
        var suggestion: Suggestion

        static func == (a: Item, b: Item) -> Bool {
            a.name == b.name && a.start == b.start && a.end == b.end && a.suggestion == b.suggestion
        }
    }

    // MARK: 학년도

    /// 글에 "2026-2027", "2026–27" 이 있으면 그 시작 해, 없으면 오늘 기준 (6월부터 새 학년도)
    static func schoolYearStart(in text: String, now: Date = Date(), calendar: Calendar = .current) -> Int {
        if let m = firstMatch(#"(20\d\d)\s*[-–—/]\s*(20\d\d|\d\d)\b"#, in: text),
           let a = Int(m[1]) {
            let bRaw = m[2]
            let b = bRaw.count == 2 ? (a / 100) * 100 + (Int(bRaw) ?? 0) : (Int(bRaw) ?? 0)
            if b == a + 1 { return a }
        }
        let y = calendar.component(.year, from: now)
        return calendar.component(.month, from: now) >= 6 ? y : y - 1
    }

    // MARK: 읽기

    static func parse(text: String, schoolYearStart: Int? = nil, dayFirst: Bool = Self.localeIsDayFirst,
                      calendar: Calendar = .current) -> [Item] {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let baseYear = schoolYearStart ?? Self.schoolYearStart(in: text, calendar: calendar)
        var items: [Item] = []
        var previousTextOnly: String?
        for line in lines {
            let mentions = dateMentions(in: line, dayFirst: dayFirst)
            guard !mentions.isEmpty else {
                // 날짜 없는 짧은 줄은 다음 줄 날짜의 이름일 수 있다 ("Thanksgiving Break" ↵ "Nov 24-28")
                let cleaned = cleanName(line)
                previousTextOnly = cleaned.count >= 3 && cleaned.count <= 60 ? cleaned : nil
                continue
            }
            var name = cleanName(removing: mentions.map(\.range), from: line)
            if name.isEmpty, let prev = previousTextOnly { name = prev }
            previousTextOnly = nil
            for span in spans(from: mentions, in: line) {
                guard let (start, end) = resolve(span, baseYear: baseYear, calendar: calendar) else { continue }
                // 넉 달이 넘는 기간은 학기 표기 같은 것 — 빼고 본다
                guard let days = calendar.dateComponents([.day], from: start, to: end).day, days <= 120 else { continue }
                let item = Item(name: name, start: start, end: end, suggestion: suggestion(for: name))
                if !items.contains(item) { items.append(item) }
            }
        }
        return items.sorted { $0.start < $1.start }
    }

    /// 이름의 낱말로 넣을 곳을 고른다 — 교사가 일하는 날을 먼저 걸러 낸다
    static func suggestion(for name: String) -> Suggestion {
        let n = name.lowercased()
        let work = ["first day", "last day", "early release", "early dismissal", "half day", "teacher work", "teacher day",
                    "professional", "pd day", "in-service", "inservice", "staff development", "workday", "work day",
                    "conference", "open house", "report card", "grading", "graduation", "begins", "starts", "ends",
                    "개학", "종업", "졸업", "연수", "교사 근무"]
        let tests = ["test", "testing", "exam", "assessment", "staar", "eoc", "final", "midterm", "시험", "평가"]
        let off = ["break", "holiday", "vacation", "recess", "no school", "closed", "day off", "no classes",
                   "thanksgiving", "christmas", "labor day", "memorial", "mlk", "luther king", "president", "veteran",
                   "juneteenth", "independence", "new year", "columbus", "indigenous", "good friday", "easter",
                   "방학", "휴업", "휴일", "재량", "공휴일"]
        // "Student holiday / Teacher workday" 처럼 둘 다 있으면 교사는 일한다
        if work.contains(where: n.contains) { return .skip }
        if tests.contains(where: n.contains) { return .blackout }
        if off.contains(where: n.contains) { return .dayOff }
        return .skip
    }

    // MARK: 날짜 찾기

    struct Mention {
        let month: Int
        let day: Int
        let year: Int?
        let range: Range<String.Index>
    }

    /// 나라 날짜 표기가 일/월 순서인지 (영국·유럽 "24/11")
    static var localeIsDayFirst: Bool {
        let format = DateFormatter.dateFormat(fromTemplate: "Md", options: 0, locale: .current) ?? "M/d"
        guard let d = format.firstIndex(of: "d"), let m = format.firstIndex(of: "M") else { return false }
        return d < m
    }

    private static let monthNames: [(String, Int)] = [
        ("jan", 1), ("feb", 2), ("mar", 3), ("apr", 4), ("may", 5), ("jun", 6),
        ("jul", 7), ("aug", 8), ("sep", 9), ("oct", 10), ("nov", 11), ("dec", 12),
    ]
    private static let monthPattern = #"(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|june?|july?|aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\.?"#

    private static func monthNumber(_ s: String) -> Int? {
        let l = s.lowercased()
        return monthNames.first { l.hasPrefix($0.0) }?.1
    }

    /// 한 줄에서 날짜 표기를 모두 찾는다. "Nov 24-28" 의 "-28" 처럼 달 없이 이어지는 날도 날짜로 만든다.
    static func dateMentions(in line: String, dayFirst: Bool) -> [Mention] {
        var found: [Mention] = []
        let ns = line as NSString
        func add(_ pattern: String, _ make: ([String], NSRange) -> Mention?) {
            guard let re = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return }
            for m in re.matches(in: line, range: NSRange(location: 0, length: ns.length)) {
                let groups = (0..<m.numberOfRanges).map { i -> String in
                    let r = m.range(at: i)
                    return r.location == NSNotFound ? "" : ns.substring(with: r)
                }
                // 이미 찾은 표기와 겹치면 건너뛴다
                guard let r = Range(m.range, in: line), !found.contains(where: { $0.range.overlaps(r) }),
                      let mention = make(groups, m.range) else { continue }
                found.append(mention)
            }
        }
        func year(_ s: String) -> Int? {
            guard let y = Int(s) else { return nil }
            return s.count == 2 ? 2000 + y : y
        }
        // 2026-11-24
        add(#"\b(20\d\d)[-./](\d{1,2})[-./](\d{1,2})\b"#) { g, r in
            guard let m = Int(g[2]), let d = Int(g[3]), let range = Range(r, in: line) else { return nil }
            return Mention(month: m, day: d, year: Int(g[1]), range: range)
        }
        // November 24, 2026 / Nov. 24th
        add(#"\b"# + monthPattern + #"\s*(\d{1,2})(?:st|nd|rd|th)?\b(?:,?\s*(20\d\d))?"#) { g, r in
            guard let m = monthNumber(g[1]), let d = Int(g[2]), let range = Range(r, in: line) else { return nil }
            return Mention(month: m, day: d, year: year(g[3]), range: range)
        }
        // 24 November 2026
        add(#"\b(\d{1,2})(?:st|nd|rd|th)?\s+"# + monthPattern + #"(?:,?\s*(20\d\d))?"#) { g, r in
            guard let d = Int(g[1]), let m = monthNumber(g[2]), let range = Range(r, in: line) else { return nil }
            return Mention(month: m, day: d, year: year(g[3]), range: range)
        }
        // 11월 24일 · 11月24日
        add(#"(\d{1,2})\s*[월月]\s*(\d{1,2})\s*[일日]?"#) { g, r in
            guard let m = Int(g[1]), let d = Int(g[2]), let range = Range(r, in: line) else { return nil }
            return Mention(month: m, day: d, year: nil, range: range)
        }
        // 11/24, 11/24/26, 24.11.2026
        add(#"\b(\d{1,2})[/.](\d{1,2})(?:[/.](\d{2}|20\d\d))?\b"#) { g, r in
            guard let a = Int(g[1]), let b = Int(g[2]), let range = Range(r, in: line) else { return nil }
            let (m, d) = dayFirst ? (b, a) : (a, b)
            return Mention(month: m, day: d, year: year(g[3]), range: range)
        }
        found = found.filter { (1...12).contains($0.month) && (1...31).contains($0.day) }
        found.sort { $0.range.lowerBound < $1.range.lowerBound }

        // "Nov 24-28", "Nov 24 – 28", "Nov 26 & 27" — 달 없이 이어지는 날
        var result: [Mention] = []
        for mention in found {
            result.append(mention)
            var cursor = mention.range.upperBound
            while true {
                let rest = String(line[cursor...])
                guard let m = firstMatch(#"^\s*(?:-|–|—|~|to|through|thru|&|and|,)\s*(\d{1,2})(?:st|nd|rd|th)?\b(?!\s*[/.:]\d)"#, in: rest),
                      let d = Int(m[1]), (1...31).contains(d),
                      let r = rest.range(of: m[0]) else { break }
                // 뒤에 달 이름이 오면 ("Nov 30 - 3 Dec") 그건 다음 날짜 표기다
                let after = String(rest[r.upperBound...]).trimmingCharacters(in: .whitespaces).lowercased()
                if monthNumber(String(after.prefix(3))) != nil && after.count >= 3 { break }
                let lower = line.index(cursor, offsetBy: rest.distance(from: rest.startIndex, to: r.lowerBound))
                let upper = line.index(cursor, offsetBy: rest.distance(from: rest.startIndex, to: r.upperBound))
                if found.contains(where: { $0.range.overlaps(lower..<upper) }) { break }
                result.append(Mention(month: mention.month, day: d, year: mention.year, range: lower..<upper))
                cursor = upper
            }
        }
        return result
    }

    /// 이어진 날짜 표기를 기간으로 묶는다 — 사이가 "-", "to" 면 기간, "&", "," 면 따로
    struct Span { let start: Mention; let end: Mention }

    static func spans(from mentions: [Mention], in line: String) -> [Span] {
        var result: [Span] = []
        var i = 0
        while i < mentions.count {
            let current = mentions[i]
            if i + 1 < mentions.count, isRangeConnector(between: current, and: mentions[i + 1], in: line) {
                result.append(Span(start: current, end: mentions[i + 1]))
                i += 2
            } else {
                result.append(Span(start: current, end: current))
                i += 1
            }
        }
        return result
    }

    /// 두 표기 사이가 기간을 뜻하는지 — 달 없이 이어진 날("-28")은 구분 기호가 뒤 표기 안에 들어 있다
    private static func isRangeConnector(between a: Mention, and b: Mention, in line: String) -> Bool {
        guard a.range.upperBound <= b.range.lowerBound else { return false }
        let gap = String(line[a.range.upperBound..<b.range.lowerBound]) + String(line[b.range].prefix(8))
        let g = gap.lowercased().trimmingCharacters(in: .whitespaces)
        if g.hasPrefix("&") || g.hasPrefix("and") || g.hasPrefix(",") { return false }
        return g.hasPrefix("-") || g.hasPrefix("–") || g.hasPrefix("—") || g.hasPrefix("~")
            || g.hasPrefix("to") || g.hasPrefix("through") || g.hasPrefix("thru")
    }

    /// 연도가 없으면 학년도에 맞춘다 (7월부터는 시작 해, 그 전은 다음 해). 끝이 시작보다 앞이면 해를 넘긴 것.
    private static func resolve(_ span: Span, baseYear: Int, calendar: Calendar) -> (Date, Date)? {
        func date(_ m: Mention, minimum: Date? = nil) -> Date? {
            let y = m.year ?? (m.month >= 7 ? baseYear : baseYear + 1)
            guard let d = calendar.date(from: DateComponents(year: y, month: m.month, day: m.day)),
                  calendar.component(.day, from: d) == m.day else { return nil }
            if let minimum, d < minimum, m.year == nil {
                return calendar.date(byAdding: .year, value: 1, to: d)
            }
            return d
        }
        guard let start = date(span.start), let end = date(span.end, minimum: start), end >= start else { return nil }
        return (calendar.startOfDay(for: start), calendar.startOfDay(for: end))
    }

    // MARK: 이름

    private static let weekdayPattern = #"\b(mon|tue|tues|wed|thu|thur|thurs|fri|sat|sun)(day|nesday|rsday|urday)?\.?\b|\([월화수목금토일]\)"#

    static func cleanName(_ s: String) -> String {
        var t = s
        if let re = try? NSRegularExpression(pattern: weekdayPattern, options: [.caseInsensitive]) {
            t = re.stringByReplacingMatches(in: t, range: NSRange(location: 0, length: (t as NSString).length), withTemplate: " ")
        }
        // 날짜 사이에 남은 기호·연도
        if let re = try? NSRegularExpression(pattern: #"\b20\d\d\b|\s(?:to|through|thru|and)\s"#, options: [.caseInsensitive]) {
            t = re.stringByReplacingMatches(in: t, range: NSRange(location: 0, length: (t as NSString).length), withTemplate: " ")
        }
        let junk = CharacterSet(charactersIn: "-–—~:|,.;/&()[]*•·").union(.whitespaces)
        t = t.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.joined(separator: " ")
        return t.trimmingCharacters(in: junk)
    }

    private static func cleanName(removing ranges: [Range<String.Index>], from line: String) -> String {
        var t = line
        for r in ranges.sorted(by: { $0.lowerBound > $1.lowerBound }) {
            t.replaceSubrange(r, with: " ")
        }
        return cleanName(t)
    }

    private static func firstMatch(_ pattern: String, in s: String) -> [String]? {
        guard let re = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
              let m = re.firstMatch(in: s, range: NSRange(location: 0, length: (s as NSString).length)) else { return nil }
        let ns = s as NSString
        return (0..<m.numberOfRanges).map { i in
            let r = m.range(at: i)
            return r.location == NSNotFound ? "" : ns.substring(with: r)
        }
    }
}
