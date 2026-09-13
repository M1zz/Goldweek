//
//  UsageInsightsTests.swift
//  Goldweek
//
//  사용 통계 집계 검증 — 허브에서 읽어 온 원본을 판단용 숫자로 바꾸는 계산은
//  화면을 열어 눈으로 확인할 수가 없다(데이터가 남의 기기에서 온다). 그래서 여기서 못박는다.
//

import Foundation
import XCTest
@testable import Goldweek

final class UsageInsightsTests: XCTestCase {

    private func sample(_ name: String, install: String, daysAgo: Int = 0) -> UsageReportingService.EventSample {
        UsageReportingService.EventSample(
            name: name,
            installID: install,
            date: Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        )
    }

    // MARK: - 이벤트 이름 매칭

    func testMatchesSliceEventName() {
        // `leave_added:annual` 처럼 슬라이스가 붙어도 같은 단계로 잡혀야 한다.
        XCTAssertTrue(UsageInsights.matches("leave_added:annual", step: "leave_added"))
        XCTAssertTrue(UsageInsights.matches("leave_added", step: "leave_added"))
        // 접두사가 겹치는 다른 이벤트를 삼키면 안 된다.
        XCTAssertFalse(UsageInsights.matches("leave_added_bulk", step: "leave_added"))
        XCTAssertFalse(UsageInsights.matches("leave_deleted", step: "leave_added"))
    }

    func testInstallsCountsDistinctInstalls() {
        let events = [
            sample("leave_added:annual", install: "A"),
            sample("leave_added:half", install: "A"),
            sample("leave_added", install: "B"),
            sample("paywall_view", install: "C"),
        ]
        XCTAssertEqual(UsageInsights.installs(in: events, named: "leave_added"), ["A", "B"])
    }

    // MARK: - 퍼널

    func testPaywallFunnelCountsOnlySuccessAsCompleted() {
        let events = [
            sample("paywall_view:direct", install: "A"),
            sample("paywall_view:direct", install: "B"),
            sample("paywall_purchase:success", install: "A"),
            sample("paywall_purchase:fail", install: "B"),
        ]
        let stages = UsageInsights.paywallFunnel(events: events)

        XCTAssertEqual(stages.map(\.installs), [2, 2, 1])
        XCTAssertEqual(stages[2].rateFromTop, 0.5, accuracy: 0.001)
        XCTAssertEqual(stages[2].rateFromPrevious, 0.5, accuracy: 0.001)
    }

    func testActivationFunnelUsesSnapshotCountAsTopStage() {
        let events = [
            sample("onboarding_complete", install: "A"),
            sample("leave_added:annual", install: "A"),
            sample("recommendation_added", install: "A"),
            sample("onboarding_complete", install: "B"),
        ]
        // 스냅샷 3곳 중 온보딩 2곳, 등록 1곳, 추천 채택 1곳.
        let stages = UsageInsights.activationFunnel(snapshots: [], events: events)
        XCTAssertEqual(stages.map(\.installs), [0, 2, 1, 1])
        // 첫 단계가 0이면 비율은 0으로 떨어져야 한다(0으로 나누지 않는다).
        XCTAssertEqual(stages[1].rateFromTop, 0)
    }

    // MARK: - 추이

    func testTrendFillsEmptyBucketsAndCountsDistinctInstalls() {
        let events = [
            sample(UsageReportingService.appOpenEvent, install: "A", daysAgo: 2),
            sample(UsageReportingService.appOpenEvent, install: "B", daysAgo: 2),
            sample("leave_added", install: "A", daysAgo: 2),
            sample(UsageReportingService.appOpenEvent, install: "A", daysAgo: 0),
        ]
        let points = UsageReportingService.trend(unit: .day, events: events, snapshots: [])

        // 2일 전 ~ 오늘 = 3칸. 가운데(어제)는 데이터가 없어도 채워져야 차트가 끊기지 않는다.
        XCTAssertEqual(points.count, 3)
        XCTAssertEqual(points[0].activeInstalls, 2)
        XCTAssertEqual(points[0].events, 3)
        XCTAssertEqual(points[1].events, 0)
        XCTAssertEqual(points[2].activeInstalls, 1)
    }

    func testTrendIsEmptyWithoutData() {
        XCTAssertTrue(UsageReportingService.trend(unit: .day, events: [], snapshots: []).isEmpty)
    }

    // MARK: - 이벤트 집계

    func testEventStatsAggregatesCountAndInstalls() {
        let events = [
            sample("leave_added", install: "A", daysAgo: 3),
            sample("leave_added", install: "B", daysAgo: 1),
            sample("plan_shared", install: "A", daysAgo: 2),
        ]
        let stats = UsageReportingService.eventStats(from: events)

        XCTAssertEqual(stats.first?.name, "leave_added")   // 건수 많은 순
        XCTAssertEqual(stats.first?.count, 2)
        XCTAssertEqual(stats.first?.installs, 2)
        XCTAssertEqual(stats.count, 2)
    }

    // MARK: - 지표 라벨

    func testMetricLabelFallsBackToRawKey() {
        XCTAssertEqual(UsageInsights.metricLabel("restDays"), "확보한 쉬는 날")
        XCTAssertEqual(UsageInsights.metricLabel("country.korea"), "국가 korea")
        XCTAssertEqual(UsageInsights.metricLabel("someNewKey"), "someNewKey")
    }

    func testIsFlagCoversDistributionKeys() {
        XCTAssertTrue(UsageInsights.isFlag("flag.isPro"))
        XCTAssertTrue(UsageInsights.isFlag("country.japan"))
        XCTAssertTrue(UsageInsights.isFlag("type.employee"))
        // 평균으로 읽어야 하는 수치 지표는 플래그가 아니다.
        XCTAssertFalse(UsageInsights.isFlag("restDays"))
    }
}
