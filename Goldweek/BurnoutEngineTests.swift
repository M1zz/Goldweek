//
//  BurnoutEngineTests.swift
//  Goldweek
//
//  번아웃 엔진 검증 — 회복 잔량/개인 주기/예측은 손으로 못 푸는 계산이므로
//  결정적(asOf 주입) 테스트로 동작을 고정한다.
//

import Foundation
import XCTest
@testable import Goldweek

final class BurnoutEngineTests: XCTestCase {

    private let cal = Calendar.current
    private var engine = BurnoutEngine()

    private func day(_ ymd: (Int, Int, Int)) -> Date {
        cal.date(from: DateComponents(year: ymd.0, month: ymd.1, day: ymd.2))!
    }
    private func block(_ start: (Int, Int, Int), _ end: (Int, Int, Int)) -> RestBlock {
        RestBlock(start: day(start), end: day(end))
    }

    // MARK: - 회복 잔량 (fade-out)

    func testReserve_FullRightAfterRest() {
        // 3일 휴식이 오늘 끝남 → decay(0)=1, reserve=3, fullTank=3 → 1.0
        let breaks = [block((2026, 6, 1), (2026, 6, 3))]
        let r = engine.recoveryReserveRatio(past: breaks, asOf: day((2026, 6, 3)))
        XCTAssertEqual(r, 1.0, accuracy: 0.001, "휴식 직후 잔량은 가득 차야 함")
    }

    func testReserve_DepletedAfter30Days() {
        // 30일 경과 → decay=0 → 잔량 0
        let breaks = [block((2026, 5, 1), (2026, 5, 3))]
        let r = engine.recoveryReserveRatio(past: breaks, asOf: day((2026, 6, 2))) // 종료 5/3 기준 30일
        XCTAssertEqual(r, 0.0, accuracy: 0.001, "30일 지나면 회복 잔량이 소멸해야 함")
    }

    func testReserve_HalfAt15Days() {
        let breaks = [block((2026, 6, 1), (2026, 6, 3))] // 3일
        let r = engine.recoveryReserveRatio(past: breaks, asOf: day((2026, 6, 18))) // 종료 후 15일
        // decay(15)=0.5 → reserve=1.5 → /3 = 0.5
        XCTAssertEqual(r, 0.5, accuracy: 0.001, "15일 후 잔량은 절반이어야 함")
    }

    // MARK: - 개인 주기 (이력 통계 — 손으로 못 푸는 핵심)

    func testPersonalCycle_DefaultWhenSparse() {
        let (cycle, personalized) = engine.personalCycle(past: [block((2026, 1, 1), (2026, 1, 2))])
        XCTAssertEqual(cycle, 60, "표본 부족 시 기본 60일")
        XCTAssertFalse(personalized, "개인화 아님 플래그")
    }

    func testPersonalCycle_MedianOfGaps() {
        // 시작 간격: 1/1→2/1(31), 2/1→4/1(59), 4/1→5/1(30) → 정렬 [30,31,59] 중앙값 31
        let breaks = [
            block((2026, 1, 1), (2026, 1, 1)),
            block((2026, 2, 1), (2026, 2, 1)),
            block((2026, 4, 1), (2026, 4, 1)),
            block((2026, 5, 1), (2026, 5, 1)),
        ]
        let (cycle, personalized) = engine.personalCycle(past: breaks)
        XCTAssertEqual(cycle, 31, "간격 중앙값이어야 함")
        XCTAssertTrue(personalized, "표본 충분 → 개인화")
    }

    // MARK: - 종합 평가 / 레벨

    func testAssess_WellRestedIsOk() {
        let breaks = [block((2026, 6, 1), (2026, 6, 5))]
        let a = engine.assess(breaks: breaks, asOf: day((2026, 6, 6)))
        XCTAssertEqual(a.level, .ok, "막 쉬었으면 OK")
        XCTAssertEqual(a.primaryReason, .wellRested)
    }

    func testAssess_LongGapEscalates() {
        // 90일 이상 휴식 없음 → critical 기대
        let breaks = [block((2026, 3, 1), (2026, 3, 1))]
        let a = engine.assess(breaks: breaks, asOf: day((2026, 6, 15)))
        XCTAssertGreaterThanOrEqual(a.level, .overdue, "오래 못 쉬면 최소 overdue")
        XCTAssertEqual(a.recoveryReserveRatio, 0, accuracy: 0.001, "오래 비면 회복 잔량 0")
    }

    func testAssess_PlannedSoonReassures() {
        // 오래 비었어도 곧(10일 뒤) 휴식 예정이면 완화
        let asOf = day((2026, 6, 15))
        let breaks = [
            block((2026, 3, 1), (2026, 3, 1)),       // 과거 — 오래됨
            block((2026, 6, 25), (2026, 6, 27)),     // 미래 — 곧 쉼
        ]
        let a = engine.assess(breaks: breaks, asOf: asOf)
        XCTAssertEqual(a.primaryReason, .planAhead, "곧 예정된 휴식이 있으면 안심 사유")
        XCTAssertLessThan(a.level, .critical, "예정 휴식이 위험을 완화해야 함")
    }

    func testAssess_SubjectiveFatiguePushesUp() {
        let breaks = [block((2026, 6, 1), (2026, 6, 3))]
        let calm = engine.assess(breaks: breaks, asOf: day((2026, 6, 14)))
        let tired = engine.assess(breaks: breaks, asOf: day((2026, 6, 14)), subjectiveFatigue: 10)
        XCTAssertGreaterThan(tired.riskScore, calm.riskScore, "주관적 피로 보고가 위험을 높여야 함")
    }

    // MARK: - 번아웃 예측일 (미래 외삽 — 손으로 못 푸는 핵심)

    func testPredict_ReturnsFutureDateWhenHealthyNow() {
        let breaks = [block((2026, 6, 1), (2026, 6, 3))]
        let a = engine.assess(breaks: breaks, asOf: day((2026, 6, 4)))
        XCTAssertNotNil(a.predictedRiskDate, "지금 건강하면 미래 위험일을 예측해야 함")
        if let p = a.predictedRiskDate {
            XCTAssertGreaterThan(p, day((2026, 6, 4)), "예측일은 미래여야 함")
        }
    }

    func testPredict_NilWhenAlreadyCritical() {
        let breaks = [block((2026, 1, 1), (2026, 1, 1))]
        let a = engine.assess(breaks: breaks, asOf: day((2026, 6, 15)))
        if a.level == .critical {
            XCTAssertNil(a.predictedRiskDate, "이미 위험이면 예측일은 nil(=지금)")
        }
    }
}
