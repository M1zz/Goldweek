//
//  LeaveTableParserTests.swift
//  Goldweek
//
//  사진 가져오기(OCR) 파서의 형식 일반화 검증 — 다양한 회사 시스템의 표 형식 대응
//

import Foundation
import XCTest
@testable import Goldweek
import GoldweekCore

final class LeaveTableParserTests: XCTestCase {

    private let calendar = Calendar.current

    private func days(_ leave: LeaveTableParser.ParsedLeave) -> Int {
        (calendar.dateComponents([.day], from: leave.startDate, to: leave.endDate).day ?? 0) + 1
    }

    // MARK: - POVIS 형식 (공제 열이 있는 표)

    func testPOVISStyleRow() {
        let result = LeaveTableParser.parseRows([
            "2026.07.16 2026.07.16 반차 오전 0.50일 2026.07.02 2026.07.06 승인",
        ])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].suggestedTypeRaw, "반차")
        XCTAssertEqual(result[0].deductionDays, 0.5)
        XCTAssertEqual(result[0].timeInfo, "오전")
        XCTAssertEqual(days(result[0]), 1)
    }

    func testDeductionColumnTable_EmptyDeductionMeansNoDeduct() {
        // 공제 수치가 있는 표에서 공제가 빈 행(자녀돌봄 등)은 연차 차감 없는 유형
        let result = LeaveTableParser.parseRows([
            "2026.08.01 2026.08.01 연차 1.00일 승인",
            "2026.08.02 2026.08.02 자녀돌봄(1/2) 승인",
        ])
        XCTAssertEqual(result.map(\.suggestedTypeRaw), ["연차", "특별휴가"])
    }

    func testFractionInTypeName_ParsedAsHalfLength() {
        // "자녀돌봄(1/2)" → 카테고리는 특별휴가, 길이는 반차(0.5)로 인식돼야 한다
        let result = LeaveTableParser.parseRows([
            "2026.08.02 2026.08.02 자녀돌봄(1/2) 승인",
        ])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].suggestedTypeRaw, "특별휴가")
        XCTAssertEqual(result[0].suggestedLength, .half)
    }

    func testQuarterFractionInTypeName() {
        // "(1/4)" → 반반차(0.25)
        let result = LeaveTableParser.parseRows([
            "2026.08.03 2026.08.03 특별휴가(1/4) 승인",
        ])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].suggestedLength, .quarter)
    }

    // MARK: - 기존 기록 길이 보정 (마이그레이션)

    func testBackfillLength_singleDaySpecialWithFractionNote() {
        // 파서 개선 전 1일로 저장된 "자녀돌봄(1/2)" → 반차(0.5)로 보정
        // 오늘 날짜를 쓰면 주말에 돌릴 때 차감 0일이 되어 깨진다 — 어느 나라든 평일인 날로 고정
        let day = calendar.date(from: DateComponents(year: 2026, month: 3, day: 11))!
        let record = LeaveRecord(startDate: day, endDate: day, type: .special, note: "자녀돌봄(1/2)")
        XCTAssertEqual(record.effectiveLeaveDays, 1.0, accuracy: 0.001)

        let changed = LeaveRecordMaintenance.backfillLengths(records: [record])
        XCTAssertTrue(changed)
        XCTAssertEqual(record.length, .half)
        XCTAssertEqual(record.effectiveLeaveDays, 0.5, accuracy: 0.001)
    }

    func testBackfillLength_ignoresMultiDay() {
        // 다일 기간은 분수 표기가 있어도 건드리지 않는다
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 2, to: start)!
        let record = LeaveRecord(startDate: start, endDate: end, type: .special, note: "특별휴가(1/2)")
        let changed = LeaveRecordMaintenance.backfillLengths(records: [record])
        XCTAssertFalse(changed)
        XCTAssertEqual(record.length, .full)
    }

    func testBackfillLength_ignoresPlainNote() {
        // 분수 표기 없는 기록은 그대로
        let day = calendar.startOfDay(for: Date())
        let record = LeaveRecord(startDate: day, endDate: day, type: .special, note: "자녀돌봄")
        let changed = LeaveRecordMaintenance.backfillLengths(records: [record])
        XCTAssertFalse(changed)
        XCTAssertEqual(record.length, .full)
    }

    func testDateSlashNotMisreadAsFraction() {
        // 날짜의 슬래시(2026/08/02)를 분수로 오인하지 않아야 한다 (괄호 없는 슬래시)
        let result = LeaveTableParser.parseRows([
            "2026/08/02 2026/08/02 연차 1.00일 승인",
        ])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].suggestedLength, .full)
    }

    func testCompensatoryNeverDeducts() {
        // 대체휴가는 다른 날 근무의 보상 — 항상 연차 차감 없음
        let result = LeaveTableParser.parseRows([
            "2026.06.09 2026.06.09 대체휴가(1일) 2026.05.15 2026.05.17 승인",
            "2026.06.10 2026.06.10 연차 1.00일 승인",
        ])
        XCTAssertEqual(result[0].suggestedTypeRaw, "대체휴무")
        XCTAssertNil(result[0].deductionDays)
    }

    func testParenthesizedDayCountIsNotDeduction() {
        // "대체휴가(1일)"의 "1일"은 차감 수치가 아니다
        let result = LeaveTableParser.parseRows([
            "2026.06.09 2026.06.09 대체휴가(1일) 승인",
        ])
        XCTAssertEqual(result.count, 1)
        XCTAssertNil(result[0].deductionDays)
    }

    // MARK: - 날짜 형식 일반화

    func testKoreanDateFormat() {
        let result = LeaveTableParser.parseRows([
            "홍길동 반차 2026년 8월 3일 오후 승인",
        ])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].suggestedTypeRaw, "반차")
        XCTAssertNil(result[0].deductionDays, "날짜의 '3일'이 차감으로 오인되면 안 됨")
    }

    func testDashAndSlashDateFormats() {
        let result = LeaveTableParser.parseRows([
            "2026-08-03 여름휴가 승인",
            "2026/08/04 연차 승인",
        ])
        XCTAssertEqual(result.count, 2)
    }

    func testSingleDateRow() {
        let result = LeaveTableParser.parseRows(["2026-08-03 여름휴가 승인"])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(days(result[0]), 1)
    }

    func testDateRange() {
        let result = LeaveTableParser.parseRows([
            "2026.08.03 ~ 2026.08.05 연차 신청일 2026.07.20",
        ])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(days(result[0]), 3)
        XCTAssertEqual(result[0].suggestedTypeRaw, "연차")
    }

    func testSecondDateInPastIsNotRangeEnd() {
        // 두 번째 날짜가 시작일보다 과거(신청일)면 하루짜리로 해석
        let result = LeaveTableParser.parseRows(["2026.08.20 2026.08.01 여름휴가"])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(days(result[0]), 1)
    }

    // MARK: - 유형 추론 일반화

    func testUnknownTypeNameWithDeduction() {
        // 알려진 키워드가 없어도 차감 수치가 있으면 휴가로 인정
        let result = LeaveTableParser.parseRows(["2026.08.11 웰니스데이 1일 승인"])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].suggestedTypeRaw, "연차")
        XCTAssertEqual(result[0].rawTypeName, "웰니스데이")
    }

    func testTimeRangeInfersQuarterDay() {
        // 공제 열이 없는 표: 2시간 범위 → 반반차
        let result = LeaveTableParser.parseRows(["2026.08.12 휴가 16:00~18:00 승인"])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].suggestedTypeRaw, "반반차")
    }

    func testEnglishVacationRange() {
        let result = LeaveTableParser.parseRows(["Vacation 2026-12-24 - 2026-12-26 approved"])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].suggestedTypeRaw, "연차")
        XCTAssertEqual(days(result[0]), 3)
    }

    // MARK: - 노이즈 행 처리

    func testRejectedRowsAreSkipped() {
        let result = LeaveTableParser.parseRows([
            "2026.08.13 2026.08.13 연차 1.00일 반려",
            "2026.08.14 2026.08.14 연차 1.00일 취소",
            "2026.08.15 2026.08.15 연차 1.00일 승인",
        ])
        XCTAssertEqual(result.count, 1)
    }

    func testHeaderAndSummaryRowsAreIgnored() {
        let result = LeaveTableParser.parseRows([
            "시작일 종료일 휴무유형명 실공제수 상태",
            "합계 3.50일",
            "2026.08.17 반반차 0.25일 승인",
        ])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].suggestedTypeRaw, "반반차")
    }

    func testDuplicateRowsAreDeduped() {
        let result = LeaveTableParser.parseRows([
            "2026.08.18 2026.08.18 연차 1.00일 승인",
            "2026.08.18 2026.08.18 연차 1.00일 승인",
        ])
        XCTAssertEqual(result.count, 1)
    }
}

// MARK: - 퍼즈: 사진 · PDF 에서 읽은 글을 죽이려고 넣기

/// OCR 글은 엉망으로 온다. 날짜 조각 · 숫자 · 기호 · 다른 언어가 뒤섞인 줄을 무작위로 만들어
/// 연차 표 파서와 학사 일정 파서에 넣는다. 어떤 줄에서도 죽지 않아야 한다.
final class ImportParserFuzzTests: XCTestCase {

    private struct SeededRandom: RandomNumberGenerator {
        var state: UInt64
        mutating func next() -> UInt64 {
            state &+= 0x9E37_79B9_7F4A_7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }
    }

    private let pieces = ["2026.07.16", "2026-02-29", "2027.13.45", "0000.00.00", "9999.12.31", "1.1", "31/12", "12/31",
                          "2/30", "Nov 24-28", "Nov 30 - 3 Dec", "Dec 31 – Jan 2", "24 - 28", "&", "and", "through",
                          "Sept", "Feb", "1st", "22nd", "~", "–", "—", "-", ",", " ", "  ", "\t", "반차", "오전", "연차",
                          "0.50일", "-1일", "999999일", "1e309일", "NaN일", "승인", "반려", "월", "화", "(", ")", "[", "]",
                          "2026년", "7월", "16일", "학기", "방학", "개교기념일", "e\u{301}", "👍🏽", "١٢", "２０２６", "",
                          "-2147483648", "99999999999999999999", ":", "/", ".", "..", "...", "2026.", ".07", "7.", "2026.07."]

    private func line(_ random: inout SeededRandom) -> String {
        (0..<Int.random(in: 0...14, using: &random))
            .map { _ in pieces.randomElement(using: &random)! }
            .joined(separator: Bool.random(using: &random) ? " " : "")
    }

    func testLeaveTableParserSurvivesAnyRows() {
        var random = SeededRandom(state: 11)
        for _ in 0..<2_000 {
            let rows = (0..<Int.random(in: 0...6, using: &random)).map { _ in line(&random) }
            _ = LeaveTableParser.parseRows(rows)
        }
    }

    func testSchoolCalendarParserSurvivesAnyText() {
        var random = SeededRandom(state: 23)
        for _ in 0..<1_500 {
            let text = (0..<Int.random(in: 0...8, using: &random)).map { _ in line(&random) }.joined(separator: "\n")
            _ = SchoolCalendarParser.schoolYearStart(in: text)
            _ = SchoolCalendarParser.parse(text: text, dayFirst: Bool.random(using: &random))
            for single in text.split(separator: "\n") {
                let mentions = SchoolCalendarParser.dateMentions(in: String(single), dayFirst: Bool.random(using: &random))
                _ = SchoolCalendarParser.spans(from: mentions, in: String(single))
            }
        }
    }
}
