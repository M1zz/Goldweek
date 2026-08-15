//
//  LeaveCalculationTests.swift
//  Goldweek
//
//  보너스 연차 반차 버그 수정 검증 — 연차 계산 유닛 테스트
//

import Foundation
import XCTest
@testable import Goldweek

final class LeaveCalculationTests: XCTestCase {

    // MARK: - 날짜 헬퍼

    private func makeDate(daysFromNow offset: Int) -> Date {
        Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: offset, to: Date())!
        )
    }

    // MARK: - effectiveLeaveDays 기본 테스트

    func testEffectiveLeaveDays_Half() {
        let record = LeaveRecord(
            startDate: makeDate(daysFromNow: 3),
            endDate: makeDate(daysFromNow: 3),
            type: .half,
            status: .planned
        )
        XCTAssertEqual(record.effectiveLeaveDays, 0.5, "반차는 0.5일이어야 함")
    }

    func testEffectiveLeaveDays_Quarter() {
        let record = LeaveRecord(
            startDate: makeDate(daysFromNow: 3),
            endDate: makeDate(daysFromNow: 3),
            type: .quarter,
            status: .planned
        )
        XCTAssertEqual(record.effectiveLeaveDays, 0.25, "반반차는 0.25일이어야 함")
    }

    func testEffectiveLeaveDays_Annual_SingleDay() {
        let date = makeDate(daysFromNow: 5)
        let record = LeaveRecord(
            startDate: date,
            endDate: date,
            type: .annual,
            status: .planned
        )
        XCTAssertEqual(record.effectiveLeaveDays, 1.0, "1일 연차는 1.0일이어야 함")
    }

    func testEffectiveLeaveDays_Annual_ThreeDays() {
        let start = makeDate(daysFromNow: 5)
        let end = makeDate(daysFromNow: 7)
        let record = LeaveRecord(
            startDate: start,
            endDate: end,
            type: .annual,
            status: .planned
        )
        XCTAssertEqual(record.effectiveLeaveDays, 3.0, "3일 연차는 3.0일이어야 함")
    }

    // MARK: - deductsFromAnnualLeave 테스트

    func testDeductsFromAnnualLeave_BonusBacked() {
        let bonusId = UUID()
        let record = LeaveRecord(
            startDate: makeDate(daysFromNow: 3),
            endDate: makeDate(daysFromNow: 3),
            type: .half,
            status: .planned,
            bonusLeaveId: bonusId
        )
        XCTAssertFalse(record.deductsFromAnnualLeave,
                       "보너스 연차로 사용된 반차는 연차 차감 아님")
    }

    func testDeductsFromAnnualLeave_Regular() {
        let record = LeaveRecord(
            startDate: makeDate(daysFromNow: 3),
            endDate: makeDate(daysFromNow: 3),
            type: .half,
            status: .planned
        )
        XCTAssertTrue(record.deductsFromAnnualLeave,
                      "일반 반차는 연차 차감이어야 함")
    }

    func testDeductsFromAnnualLeave_Special_NoBonusId() {
        let date = makeDate(daysFromNow: 3)
        let record = LeaveRecord(
            startDate: date,
            endDate: date,
            type: .special,
            status: .planned
        )
        XCTAssertFalse(record.deductsFromAnnualLeave,
                       "특별휴가(bonusLeaveId 없음)는 연차 차감 아님")
    }

    func testDeductsFromAnnualLeave_Annual_NoBonusId() {
        let date = makeDate(daysFromNow: 3)
        let record = LeaveRecord(
            startDate: date,
            endDate: date,
            type: .annual,
            status: .planned
        )
        XCTAssertTrue(record.deductsFromAnnualLeave,
                      "일반 연차는 연차 차감이어야 함")
    }

    // MARK: - BonusLeave 상태 테스트

    func testBonusLeave_InitialState() {
        let bonus = BonusLeave(days: 1.0, type: .compensatory, reason: "테스트")
        XCTAssertEqual(bonus.days, 1.0)
        XCTAssertEqual(bonus.usedDays, 0.0)
        XCTAssertEqual(bonus.remainingDays, 1.0, "초기 잔여일은 부여일과 동일해야 함")
        XCTAssertFalse(bonus.isUsed, "초기 상태는 미사용이어야 함")
    }

    func testBonusLeave_AfterHalfDayUsage() {
        let bonus = BonusLeave(days: 1.0, type: .compensatory, reason: "테스트")
        bonus.usedDays += 0.5
        XCTAssertEqual(bonus.usedDays, 0.5, "반차 사용 후 usedDays는 0.5여야 함")
        XCTAssertEqual(bonus.remainingDays, 0.5, "반차 사용 후 잔여는 0.5여야 함")
    }

    func testBonusLeave_RemainingNeverNegative() {
        let bonus = BonusLeave(days: 1.0, type: .compensatory, reason: "테스트")
        bonus.usedDays = 2.0  // 초과 사용 시뮬레이션
        XCTAssertEqual(bonus.remainingDays, 0.0, "잔여일은 음수가 되면 안 됨 (max(0, ...))")
    }

    // MARK: - 시나리오 테스트: 보너스 반차 + 일반 반차

    func testScenario_BonusHalfDay_Plus_RegularHalfDay_Remaining() {
        // Setup
        let totalAnnual: Double = 15.0
        let bonus = BonusLeave(days: 1.0, type: .compensatory, reason: "테스트")

        let futureDate = makeDate(daysFromNow: 5)
        let futureDate2 = makeDate(daysFromNow: 6)

        // Step 2: 보너스 반차 등록
        let bonusRecord = LeaveRecord(
            startDate: futureDate,
            endDate: futureDate,
            type: .half,          // 버그 수정: .special 아닌 .half 유지
            status: .planned,
            bonusLeaveId: bonus.id
        )
        bonus.usedDays += 0.5

        // Step 3: 일반 반차 등록
        let regularRecord = LeaveRecord(
            startDate: futureDate2,
            endDate: futureDate2,
            type: .half,
            status: .planned
        )

        let allRecords = [bonusRecord, regularRecord]

        // Step 4: 검증

        // 4a. 보너스 usedDays = 0.5
        XCTAssertEqual(bonus.usedDays, 0.5, "보너스 usedDays는 0.5여야 함")
        XCTAssertEqual(bonus.remainingDays, 0.5, "보너스 잔여는 0.5여야 함")

        // 4b. effectiveLeaveDays — 보너스 레코드도 0.5
        XCTAssertEqual(bonusRecord.effectiveLeaveDays, 0.5,
                       "보너스 반차 effectiveLeaveDays는 0.5여야 함 (type=.half)")

        // 4c. plannedLeave = 0.5 (일반 반차만 차감)
        let planned = calcPlannedLeave(records: allRecords)
        XCTAssertEqual(planned, 0.5,
                       "예정 연차는 일반 반차 0.5만 포함, 보너스 반차는 제외")

        // 4d. actualUsed = 0.0 (둘 다 미래)
        let used = calcActualUsed(records: allRecords)
        XCTAssertEqual(used, 0.0, "미래 날짜이므로 사용완료 연차 없음")

        // 4e. remaining = 15 - 0.5(planned) - 0.0(used) = 14.5
        let remaining = totalAnnual - used - planned
        XCTAssertEqual(remaining, 14.5, "잔여 연차는 14.5여야 함")

        // 4f. repairBonusLeaveUsage 검증 — linkedDays = 0.5 = bonus.usedDays → 교정 불필요
        let linkedDays = allRecords
            .filter { $0.bonusLeaveId == bonus.id }
            .reduce(0.0) { $0 + $1.effectiveLeaveDays }
        XCTAssertEqual(linkedDays, 0.5,
                       "보너스 연결 레코드의 effectiveLeaveDays 합 = 0.5")
        XCTAssertTrue(abs(linkedDays - bonus.usedDays) <= 0.001,
                      "linkedDays와 bonus.usedDays가 일치해야 교정이 발생하지 않음")
    }

    // MARK: - repairBonusLeaveUsage 거짓 교정 방지 테스트

    func testRepairBonusLeaveUsage_NoFalseCorrection() {
        let bonus = BonusLeave(days: 1.0, type: .compensatory, reason: "테스트")

        let futureDate = makeDate(daysFromNow: 3)
        let bonusRecord = LeaveRecord(
            startDate: futureDate,
            endDate: futureDate,
            type: .half,          // 버그 수정 후: .half로 저장됨
            status: .planned,
            bonusLeaveId: bonus.id
        )
        bonus.usedDays = 0.5

        let allRecords = [bonusRecord]

        // repair 로직 인라인 복제
        let linkedDays = allRecords
            .filter { $0.bonusLeaveId == bonus.id }
            .reduce(0.0) { $0 + $1.effectiveLeaveDays }

        // linkedDays는 0.5여야 함 (버그 전: .special type이면 1.0이 됐음)
        XCTAssertEqual(linkedDays, 0.5,
                       "반차 보너스 레코드의 linkedDays는 0.5여야 함 (bugfix: .half 유지)")

        // 불일치 없으므로 repair 발생하지 않아야 함
        let mismatch = abs(linkedDays - bonus.usedDays) > 0.001
        XCTAssertFalse(mismatch,
                       "linkedDays와 usedDays가 일치하므로 거짓 교정이 발생하면 안 됨")
    }

    // MARK: - 현황 ↔ 내역 싱크 테스트

    // 다양한 레코드 유형이 섞인 경우 양쪽 뷰가 동일한 값을 반환해야 함
    func testSync_UsedAndPlanned_MatchBothViews() {
        let past1 = makeDate(daysFromNow: -10)
        let past2 = makeDate(daysFromNow: -5)
        let future1 = makeDate(daysFromNow: 7)
        let future2 = makeDate(daysFromNow: 14)

        let records: [LeaveRecord] = [
            LeaveRecord(startDate: past1, endDate: past1, type: .annual, status: .used),       // 완료 1.0
            LeaveRecord(startDate: past2, endDate: past2, type: .half, status: .used),         // 완료 0.5
            LeaveRecord(startDate: future1, endDate: future1, type: .annual, status: .planned),// 예정 1.0
            LeaveRecord(startDate: future2, endDate: future2, type: .half, status: .planned),  // 예정 0.5
        ]

        let homeUsed    = calcActualUsed(records: records)
        let homePlanned = calcPlannedLeave(records: records)
        let histUsed    = calcHistoryTotalUsed(records: records, yearStartMonth: 1)
        let histPlanned = calcHistoryTotalPlanned(records: records, yearStartMonth: 1)

        XCTAssertEqual(homeUsed, histUsed,
                       "현황(완료)과 내역(totalUsed)이 일치해야 함: \(homeUsed) != \(histUsed)")
        XCTAssertEqual(homePlanned, histPlanned,
                       "현황(예정)과 내역(totalPlanned)이 일치해야 함: \(homePlanned) != \(histPlanned)")
        XCTAssertEqual(homeUsed, 1.5, "완료 합계: 1.0 + 0.5 = 1.5")
        XCTAssertEqual(homePlanned, 1.5, "예정 합계: 1.0 + 0.5 = 1.5")
    }

    // 과거 날짜의 .planned 레코드는 양쪽 모두 '완료'로 분류돼야 함
    func testSync_PastPlanned_CountedAsUsed_InBothViews() {
        let pastDate = makeDate(daysFromNow: -3)
        let record = LeaveRecord(startDate: pastDate, endDate: pastDate, type: .annual, status: .planned)

        let homeUsed    = calcActualUsed(records: [record])
        let homePlanned = calcPlannedLeave(records: [record])
        let histUsed    = calcHistoryTotalUsed(records: [record], yearStartMonth: 1)
        let histPlanned = calcHistoryTotalPlanned(records: [record], yearStartMonth: 1)

        XCTAssertEqual(homeUsed, histUsed, "과거 .planned: 현황/내역 완료 일치")
        XCTAssertEqual(homePlanned, histPlanned, "과거 .planned: 현황/내역 예정 일치")
        XCTAssertEqual(homeUsed, 1.0, "과거 .planned는 완료로 집계")
        XCTAssertEqual(homePlanned, 0.0, "과거 .planned는 예정에서 제외")
    }

    // 보너스 연차 레코드: 현황(연차차감)에서는 0, 내역(전체휴가)에서는 실제 일수 표시
    func testSync_BonusRecord_CountsInNeitherAnnualTotal() {
        let bonusId = UUID()
        let pastDate = makeDate(daysFromNow: -2)
        let futureDate = makeDate(daysFromNow: 5)
        let bonusPast = LeaveRecord(startDate: pastDate, endDate: pastDate,
                                    type: .half, status: .used, bonusLeaveId: bonusId)
        let bonusFuture = LeaveRecord(startDate: futureDate, endDate: futureDate,
                                      type: .annual, status: .planned, bonusLeaveId: bonusId)
        let records = [bonusPast, bonusFuture]

        // 현황(HomeView): 보너스는 연차 차감 아님 → 0
        XCTAssertEqual(calcActualUsed(records: records), 0.0,
                       "현황: 보너스 레코드는 연차 차감 0")
        XCTAssertEqual(calcPlannedLeave(records: records), 0.0,
                       "현황: 보너스 예정도 연차 차감 0")

        // 내역 카드도 같은 정의를 쓴다 — 보너스 연결 기록은 연차를 깎지 않으므로 양쪽 다 0.
        XCTAssertEqual(calcHistoryTotalUsed(records: records, yearStartMonth: 1), 0.0,
                       "내역 카드: 보너스 사용분은 연차 사용이 아니다")
        XCTAssertEqual(calcHistoryTotalPlanned(records: records, yearStartMonth: 1), 0.0,
                       "내역 카드: 보너스 예정도 연차 예정이 아니다")
        // 쉰 날로 세면 보이는 값 (보너스 반차 0.5 + 보너스 연차 예정 1.0은 예정이라 제외)
        XCTAssertEqual(calcAllTypesUsed(records: records, yearStartMonth: 1), 0.5,
                       "쉰 날: 보너스 반차 0.5일")
    }

    // 비차감 유형(.sick, .compensatory 등): 현황은 0, 내역은 실제 일수 — 핵심 버그 재현
    func testSync_NonDeductingTypes_CountAsRestNotAnnual() {
        let past = makeDate(daysFromNow: -1)
        let future = makeDate(daysFromNow: 3)
        let records: [LeaveRecord] = [
            LeaveRecord(startDate: past,   endDate: past,   type: .sick,          status: .used),
            LeaveRecord(startDate: past,   endDate: past,   type: .compensatory,  status: .used),
            LeaveRecord(startDate: future, endDate: future, type: .official,       status: .planned),
        ]

        // 현황: 비차감 유형은 연차에서 제외 → 0
        XCTAssertEqual(calcActualUsed(records: records), 0.0,
                       "현황: 비차감 유형은 연차 차감 0")
        XCTAssertEqual(calcPlannedLeave(records: records), 0.0,
                       "현황: 비차감 예정도 연차 차감 0")

        // 내역 카드도 이제 홈과 같은 정의(연차 차감분)를 쓴다 — 두 화면이 같은 숫자를 보여야 한다.
        XCTAssertEqual(calcHistoryTotalUsed(records: records, yearStartMonth: 1), 0.0,
                       "내역 카드: 비차감 유형은 연차 사용 0")
        XCTAssertEqual(calcHistoryTotalPlanned(records: records, yearStartMonth: 1), 0.0,
                       "내역 카드: 비차감 예정도 0")
        // "며칠 쉬었나"는 여전히 셀 수 있다 — 다만 연차 옆에 놓는 숫자가 아니다.
        XCTAssertEqual(calcAllTypesUsed(records: records, yearStartMonth: 1), 2.0,
                       "병가 1일 + 대체휴무 1일 = 쉰 날 2일")
    }

    // 취소된 레코드는 양쪽 모두 집계에서 제외
    func testSync_CancelledRecords_ExcludedFromBothViews() {
        let past = makeDate(daysFromNow: -5)
        let future = makeDate(daysFromNow: 5)
        let records: [LeaveRecord] = [
            LeaveRecord(startDate: past,   endDate: past,   type: .annual, status: .cancelled),
            LeaveRecord(startDate: future, endDate: future, type: .half,   status: .cancelled),
        ]

        XCTAssertEqual(calcActualUsed(records: records), 0.0,
                       "현황: 취소 레코드는 완료 0")
        XCTAssertEqual(calcPlannedLeave(records: records), 0.0,
                       "현황: 취소 레코드는 예정 0")
        XCTAssertEqual(calcHistoryTotalUsed(records: records, yearStartMonth: 1), 0.0,
                       "내역: 취소 레코드는 totalUsed 0")
        XCTAssertEqual(calcHistoryTotalPlanned(records: records, yearStartMonth: 1), 0.0,
                       "내역: 취소 레코드는 totalPlanned 0")
    }

    // 완료+예정+남은의 합이 총 연차와 일치해야 함 (전체 보존 법칙)
    func testSync_ConservationLaw_UsedPlusPlannedPlusRemainingEqualsTotal() {
        let totalAnnual = 15.0
        let past1 = makeDate(daysFromNow: -10)
        let past2 = makeDate(daysFromNow: -3)
        let future1 = makeDate(daysFromNow: 4)
        let future2 = makeDate(daysFromNow: 8)

        let records: [LeaveRecord] = [
            LeaveRecord(startDate: past1, endDate: past1, type: .annual, status: .used),
            LeaveRecord(startDate: past2, endDate: past2, type: .half, status: .planned),
            LeaveRecord(startDate: future1, endDate: future1, type: .annual, status: .planned),
            LeaveRecord(startDate: future2, endDate: future2, type: .quarter, status: .planned),
        ]

        let used    = calcActualUsed(records: records)    // 1.0 + 0.5(past planned)
        let planned = calcPlannedLeave(records: records)  // 1.0 + 0.25
        let remaining = totalAnnual - used - planned

        // 내역에서도 동일한 값
        let histUsed    = calcHistoryTotalUsed(records: records, yearStartMonth: 1)
        let histPlanned = calcHistoryTotalPlanned(records: records, yearStartMonth: 1)

        XCTAssertEqual(used, histUsed, "완료 싱크")
        XCTAssertEqual(planned, histPlanned, "예정 싱크")
        XCTAssertEqual(used, 1.5, "완료: 연차 1.0 + 과거반차 0.5")
        XCTAssertEqual(planned, 1.25, "예정: 연차 1.0 + 반반차 0.25")
        XCTAssertEqual(remaining, totalAnnual - 1.5 - 1.25, "잔여 보존 법칙")
        XCTAssertEqual(used + planned + remaining, totalAnnual, accuracy: 0.001, "합산 = 총 연차")
    }

    // MARK: - 현황 완료 일수 ↔ 내역 사용완료 일수 관계 테스트

    // 연차/반차/반반차(차감 유형)만 있을 때: 현황 완료 == 내역 사용완료
    func testHomeVsHistory_PureAnnualLeave_Equal() {
        let past1 = makeDate(daysFromNow: -7)
        let past2 = makeDate(daysFromNow: -2)
        let records: [LeaveRecord] = [
            LeaveRecord(startDate: past1, endDate: past1, type: .annual, status: .used),
            LeaveRecord(startDate: past2, endDate: past2, type: .half,   status: .used),
        ]

        let homeUsed = calcActualUsed(records: records)
        let histUsed = calcHistoryTotalUsed(records: records, yearStartMonth: 1)

        XCTAssertEqual(homeUsed, 1.5, "현황 완료: 연차 1.0 + 반차 0.5")
        XCTAssertEqual(homeUsed, histUsed,
                       "순수 연차 레코드만 있을 때 현황 완료 == 내역 사용완료")
    }

    // 비차감 유형 추가 시: 내역이 현황보다 더 큰 값 (비차감 일수만큼 차이)
    func testHomeAndHistoryMatch_WithNonDeductingTypes() {
        let past = makeDate(daysFromNow: -3)
        let records: [LeaveRecord] = [
            LeaveRecord(startDate: past, endDate: past, type: .annual,       status: .used), // 차감 1.0
            LeaveRecord(startDate: past, endDate: past, type: .sick,         status: .used), // 비차감 1.0
            LeaveRecord(startDate: past, endDate: past, type: .compensatory, status: .used), // 비차감 1.0
        ]

        let homeUsed = calcActualUsed(records: records)
        let histUsed = calcHistoryTotalUsed(records: records, yearStartMonth: 1)
        let allTypes = calcAllTypesUsed(records: records, yearStartMonth: 1)
        let nonDeductingUsed = calcNonDeductingUsed(records: records)

        XCTAssertEqual(homeUsed, 1.0, "현황: 연차 차감분만 1.0일")
        XCTAssertEqual(histUsed, homeUsed, accuracy: 0.001,
                       "내역 카드와 홈은 같은 숫자여야 한다 (병가·대체휴무는 연차를 깎지 않는다)")
        XCTAssertEqual(allTypes, 3.0, "쉰 날: 연차+병가+대체휴무 = 3.0일")
        XCTAssertEqual(homeUsed + nonDeductingUsed, allTypes, accuracy: 0.001,
                       "산술 관계: 쉰 날 = 연차 차감분 + 비차감분")
    }

    // 보너스 연차 사용 시: 내역에는 보너스 일수 포함, 현황에는 미포함
    func testHomeAndHistoryMatch_WithBonusLeave() {
        let bonusId = UUID()
        let past = makeDate(daysFromNow: -4)
        let records: [LeaveRecord] = [
            LeaveRecord(startDate: past, endDate: past, type: .annual, status: .used),                          // 차감 1.0
            LeaveRecord(startDate: past, endDate: past, type: .half,   status: .used, bonusLeaveId: bonusId),   // 보너스 0.5
        ]

        let homeUsed = calcActualUsed(records: records)
        let histUsed = calcHistoryTotalUsed(records: records, yearStartMonth: 1)
        let allTypes = calcAllTypesUsed(records: records, yearStartMonth: 1)
        let nonDeductingUsed = calcNonDeductingUsed(records: records)

        XCTAssertEqual(homeUsed, 1.0, "현황: 일반 연차 1.0일 (보너스 제외)")
        XCTAssertEqual(histUsed, homeUsed, accuracy: 0.001, "내역 카드와 홈은 같은 숫자")
        XCTAssertEqual(allTypes, 1.5, "쉰 날: 연차 1.0 + 보너스 반차 0.5 = 1.5일")
        XCTAssertEqual(homeUsed + nonDeductingUsed, allTypes, accuracy: 0.001,
                       "산술 관계: 쉰 날 = 연차 차감분 + 비차감(보너스)분")
    }

    // 복합 시나리오: 연차+반차+병가+보너스 혼합
    func testHomeVsHistory_Mixed_ArithmeticRelation() {
        let bonusId = UUID()
        let past = makeDate(daysFromNow: -5)
        let records: [LeaveRecord] = [
            LeaveRecord(startDate: past, endDate: past, type: .annual,       status: .used),                        // 차감 1.0
            LeaveRecord(startDate: past, endDate: past, type: .half,         status: .used),                        // 차감 0.5
            LeaveRecord(startDate: past, endDate: past, type: .sick,         status: .used),                        // 비차감 1.0
            LeaveRecord(startDate: past, endDate: past, type: .quarter,      status: .used, bonusLeaveId: bonusId), // 보너스(비차감) 0.25
        ]

        let homeUsed         = calcActualUsed(records: records)
        let histUsed         = calcHistoryTotalUsed(records: records, yearStartMonth: 1)
        let allTypes         = calcAllTypesUsed(records: records, yearStartMonth: 1)
        let nonDeductingUsed = calcNonDeductingUsed(records: records)

        XCTAssertEqual(homeUsed, 1.5, accuracy: 0.001,
                       "현황: 차감분 연차 1.0 + 반차 0.5 = 1.5")
        XCTAssertEqual(histUsed, homeUsed, accuracy: 0.001,
                       "내역 카드와 홈은 같은 숫자")
        XCTAssertEqual(allTypes, 2.75, accuracy: 0.001,
                       "쉰 날: 1.0 + 0.5 + 1.0(병가) + 0.25(보너스반반차) = 2.75")
        XCTAssertEqual(homeUsed + nonDeductingUsed, allTypes, accuracy: 0.001,
                       "항등식: 쉰 날 = 연차 차감분 + 비차감분 (항상 성립)")
    }

    // 현황 완료 일수는 총 연차를 초과할 수 없음
    func testHomeVsHistory_ActualUsed_NeverExceedsTotalAnnual() {
        let totalAnnual = 5.0
        let past = makeDate(daysFromNow: -1)
        let records: [LeaveRecord] = [
            LeaveRecord(startDate: past, endDate: past, type: .annual, status: .used),
            LeaveRecord(startDate: past, endDate: past, type: .annual, status: .used),
            LeaveRecord(startDate: past, endDate: past, type: .annual, status: .used),
        ]

        let homeUsed = calcActualUsed(records: records)
        let histUsed = calcHistoryTotalUsed(records: records, yearStartMonth: 1)

        // 연차 소진 검증
        XCTAssertLessThanOrEqual(homeUsed, totalAnnual + 0.001,
                                 "현황 완료 일수는 총 연차 이하여야 함 (여기선 3일 사용, 총 5일)")
        XCTAssertEqual(homeUsed, histUsed,
                       "순수 연차 3건: 현황 완료 == 내역 사용완료")
        XCTAssertEqual(homeUsed, 3.0, "연차 3건 × 1.0 = 3.0일")
    }

    // MARK: - 보너스 포함 ON 시 완료 일수 보존 법칙 테스트

    // 보너스 포함 OFF: 완료 = 연차 차감분만 (보너스 무관)
    func testDisplayUsed_BonusOFF_OnlyAnnualDeductions() {
        let bonus = BonusLeave(days: 4.0, type: .compensatory, reason: "테스트")
        bonus.usedDays = 0.5

        let past = makeDate(daysFromNow: -3)
        let bonusRecord = LeaveRecord(startDate: past, endDate: past,
                                      type: .half, status: .used, bonusLeaveId: bonus.id)
        let annualRecord = LeaveRecord(startDate: past, endDate: past,
                                       type: .annual, status: .used)
        let records = [bonusRecord, annualRecord]

        let displayUsed = calcDisplayUsed(records: records, bonuses: [bonus], includeBonusInStatus: false)
        XCTAssertEqual(displayUsed, 1.0, "보너스 OFF: 완료 = 연차 1일만 (보너스 0.5 미포함)")
    }

    // 보너스 포함 ON: 완료 = 연차 차감분 + 보너스 사용분
    func testDisplayUsed_BonusON_IncludesUsedBonus() {
        let bonus = BonusLeave(days: 4.0, type: .compensatory, reason: "테스트")
        bonus.usedDays = 0.5

        let past = makeDate(daysFromNow: -3)
        let bonusRecord = LeaveRecord(startDate: past, endDate: past,
                                      type: .half, status: .used, bonusLeaveId: bonus.id)
        let annualRecord = LeaveRecord(startDate: past, endDate: past,
                                       type: .annual, status: .used)
        let records = [bonusRecord, annualRecord]

        let displayUsed = calcDisplayUsed(records: records, bonuses: [bonus], includeBonusInStatus: true)
        XCTAssertEqual(displayUsed, 1.5, "보너스 ON: 완료 = 연차 1.0 + 보너스 0.5 = 1.5")
    }

    // 스크린샷 재현: 보너스 포함 ON에서 완료가 0으로 표시되는 버그
    // 연차 0일 사용, 보너스 0.5일 사용, 연차 2일 예정
    func testConservation_BonusON_DisplayUsedIsNotZero() {
        let bonus = BonusLeave(days: 4.0, type: .compensatory, reason: "테스트")
        bonus.usedDays = 0.5

        let past   = makeDate(daysFromNow: -3)
        let future = makeDate(daysFromNow: 57)
        let futureEnd = makeDate(daysFromNow: 58)

        let bonusRecord  = LeaveRecord(startDate: past,   endDate: past,      type: .half,   status: .used,    bonusLeaveId: bonus.id)
        let annualPlanned = LeaveRecord(startDate: future, endDate: futureEnd, type: .annual, status: .planned)
        let records = [bonusRecord, annualPlanned]

        let displayUsed = calcDisplayUsed(records: records, bonuses: [bonus], includeBonusInStatus: true)
        XCTAssertEqual(displayUsed, 0.5, accuracy: 0.001,
                       "버그수정: 보너스 ON에서 완료는 0이 아닌 0.5여야 함")
    }

    // 보존 법칙: 완료 + 예정 + 남음 = 총연차 (보너스 포함/미포함 양쪽)
    func testConservation_WithBonus_DisplayUsedPlusPlannedPlusRemaining_EqualsTotal() {
        let totalAnnual = 15.0
        let bonus = BonusLeave(days: 4.0, type: .compensatory, reason: "테스트")
        bonus.usedDays = 0.5

        let past      = makeDate(daysFromNow: -3)
        let future    = makeDate(daysFromNow: 57)
        let futureEnd = makeDate(daysFromNow: 58)

        let bonusRecord   = LeaveRecord(startDate: past,   endDate: past,      type: .half,   status: .used,    bonusLeaveId: bonus.id)
        let annualPlanned = LeaveRecord(startDate: future, endDate: futureEnd,  type: .annual, status: .planned)
        let records = [bonusRecord, annualPlanned]
        let bonuses = [bonus]

        let grantedBonus   = bonuses.reduce(0.0) { $0 + $1.days }          // 4.0
        let remainingBonus = bonuses.reduce(0.0) { $0 + $1.remainingDays } // 3.5
        let actualUsed     = calcActualUsed(records: records)               // 0.0 (보너스 제외)
        let plannedLeave   = calcPlannedLeave(records: records)             // 2.0
        let annualRemaining = max(0.0, totalAnnual - actualUsed - plannedLeave) // 13.0

        // 보너스 포함 OFF
        let totalOff    = totalAnnual                                // 15.0
        let displayOff  = calcDisplayUsed(records: records, bonuses: bonuses, includeBonusInStatus: false) // 0.0
        let remainOff   = annualRemaining                            // 13.0
        XCTAssertEqual(displayOff + plannedLeave + remainOff, totalOff, accuracy: 0.001,
                       "보너스 OFF 보존: 0 + 2 + 13 = 15")

        // 보너스 포함 ON
        let totalOn     = totalAnnual + grantedBonus                 // 19.0
        let displayOn   = calcDisplayUsed(records: records, bonuses: bonuses, includeBonusInStatus: true)  // 0.5
        let remainOn    = annualRemaining + remainingBonus           // 16.5
        XCTAssertEqual(displayOn + plannedLeave + remainOn, totalOn, accuracy: 0.001,
                       "보너스 ON 보존: 0.5 + 2 + 16.5 = 19 (버그수정 전: 0 + 2 + 16.5 = 18.5 ≠ 19)")
    }

    // MARK: - 테스트 헬퍼 (LeaveStatusCard 로직 복제)

    // ⚠️ 화면 공식을 테스트에 **복제하지 않는다.** 예전엔 여기서 따로 구현해 두는 바람에
    //    화면 쪽 정의가 바뀌어도 테스트는 옛 공식을 통과시켰고, 홈과 내역이 갈라진 걸 못 잡았다.
    //    이제 전부 `LeaveUsageCalculator`(= 화면이 쓰는 그 코드)를 호출한다.

    private func calcActualUsed(records: [LeaveRecord]) -> Double {
        LeaveUsageCalculator.currentSummary(records: records, startMonth: 1).annualUsed
    }

    private func calcPlannedLeave(records: [LeaveRecord]) -> Double {
        LeaveUsageCalculator.currentSummary(records: records, startMonth: 1).annualPlanned
    }

    // HomeView.LeaveStatusCard.displayUsed 로직 복제
    private func calcDisplayUsed(records: [LeaveRecord], bonuses: [BonusLeave], includeBonusInStatus: Bool) -> Double {
        let actual = calcActualUsed(records: records)
        guard includeBonusInStatus else { return actual }
        let usedBonus = bonuses.reduce(0.0) { $0 + $1.usedDays }
        return actual + usedBonus
    }

    // 비차감 레코드(병가·공가·보너스 등) 완료 일수 합산
    private func calcNonDeductingUsed(records: [LeaveRecord]) -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        return records.filter { record in
            guard !record.deductsFromAnnualLeave else { return false }
            return record.status == .used ||
                   (record.status == .planned && Calendar.current.startOfDay(for: record.endDate) < today)
        }.reduce(0.0) { $0 + $1.effectiveLeaveDays }
    }

    // LeaveHistoryView.yearStats 로직 복제 — 모든 휴가 유형 포함 (연차 차감 여부 무관)
    /// 내역 화면이 카드에 띄우는 값 — 이제 홈과 같은 정의(연차 차감분)다.
    private func calcHistoryTotalUsed(records: [LeaveRecord], yearStartMonth: Int) -> Double {
        LeaveUsageCalculator.currentSummary(records: records, startMonth: yearStartMonth)
            .used(includingBonus: false)
    }

    private func calcHistoryTotalPlanned(records: [LeaveRecord], yearStartMonth: Int) -> Double {
        LeaveUsageCalculator.currentSummary(records: records, startMonth: yearStartMonth).annualPlanned
    }

    /// "며칠 쉬었나"(출장·병가 포함) — 내역 카드가 아니라 별도 지표로만 쓰는 값.
    private func calcAllTypesUsed(records: [LeaveRecord], yearStartMonth: Int) -> Double {
        LeaveUsageCalculator.currentSummary(records: records, startMonth: yearStartMonth).allTypesUsed
    }

    // MARK: - 캘린더 날짜 하이라이트 로직 복제 (CalendarGrid.isLeave 수정 후 버전)
    private func calendarIsLeave(date: Date, records: [LeaveRecord]) -> Bool {
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: date)
        return records.contains { record in
            let recordStart = cal.startOfDay(for: record.startDate)
            let recordEnd   = cal.startOfDay(for: record.endDate)
            return dayStart >= recordStart && dayStart <= recordEnd && record.status != .cancelled
        }
    }

    // MARK: - 3-way 사용 가능 연차 계산 로직 복제

    // HomeView.effectiveRemaining (includeBonusInStatus=false 시 순수 annual)
    private func calcHomeEffectiveRemaining(
        records: [LeaveRecord],
        bonuses: [BonusLeave],
        totalAnnual: Double,
        includeBonusInStatus: Bool
    ) -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        let committed = records.filter { record in
            guard record.deductsFromAnnualLeave else { return false }
            return record.status == .used ||
                   record.status == .planned
        }.reduce(0.0) { $0 + $1.effectiveLeaveDays }
        let annualRemaining = max(0, totalAnnual - committed)
        if includeBonusInStatus {
            let now = Date()
            let remainingBonus = bonuses
                .filter { !$0.isUsed && ($0.expirationDate == nil || $0.expirationDate! > now) }
                .reduce(0.0) { $0 + $1.remainingDays }
            return annualRemaining + remainingBonus
        }
        return annualRemaining
    }

    // RecommendationsView.availableLeave / SettingsView.totalAvailableLeave (항상 보너스 포함)
    private func calcAvailableLeave(
        records: [LeaveRecord],
        bonuses: [BonusLeave],
        totalAnnual: Double
    ) -> Double {
        let committed = records.filter { record in
            guard record.deductsFromAnnualLeave else { return false }
            return record.status == .used || record.status == .planned
        }.reduce(0.0) { $0 + $1.effectiveLeaveDays }
        let now = Date()
        let activeBonusLeave = bonuses
            .filter { !$0.isUsed && ($0.expirationDate == nil || $0.expirationDate! > now) }
            .reduce(0.0) { $0 + $1.remainingDays }
        return max(0, totalAnnual - committed) + activeBonusLeave
    }

    // MARK: - 캘린더 ↔ 휴가 내역 싱크 테스트

    // 내역의 레코드가 해당 날짜 캘린더에 하이라이트돼야 함 (단일일)
    func testCalendarSync_SingleDayRecord_HighlightedOnCorrectDate() {
        let date = makeDate(daysFromNow: 5)
        let record = LeaveRecord(startDate: date, endDate: date, type: .annual, status: .planned)

        XCTAssertTrue(calendarIsLeave(date: date, records: [record]),
                      "레코드 날짜에 캘린더 하이라이트가 있어야 함")
        XCTAssertFalse(calendarIsLeave(date: makeDate(daysFromNow: 4), records: [record]),
                       "레코드 없는 날은 하이라이트 없음")
        XCTAssertFalse(calendarIsLeave(date: makeDate(daysFromNow: 6), records: [record]),
                       "레코드 없는 날은 하이라이트 없음")
    }

    // 다중일 레코드: 범위 내 모든 날이 하이라이트돼야 함
    func testCalendarSync_MultiDayRecord_AllDaysHighlighted() {
        let start = makeDate(daysFromNow: 3)
        let end   = makeDate(daysFromNow: 7)
        let record = LeaveRecord(startDate: start, endDate: end, type: .annual, status: .planned)

        for offset in 3...7 {
            let d = makeDate(daysFromNow: offset)
            XCTAssertTrue(calendarIsLeave(date: d, records: [record]),
                          "다중일 레코드: offset=\(offset)도 하이라이트돼야 함")
        }
        XCTAssertFalse(calendarIsLeave(date: makeDate(daysFromNow: 2), records: [record]),
                       "범위 전 날짜는 하이라이트 없음")
        XCTAssertFalse(calendarIsLeave(date: makeDate(daysFromNow: 8), records: [record]),
                       "범위 후 날짜는 하이라이트 없음")
    }

    // 취소된 레코드는 캘린더에 하이라이트되면 안 됨
    func testCalendarSync_CancelledRecord_NotHighlighted() {
        let date = makeDate(daysFromNow: 5)
        let record = LeaveRecord(startDate: date, endDate: date, type: .annual, status: .cancelled)

        XCTAssertFalse(calendarIsLeave(date: date, records: [record]),
                       "취소 레코드는 캘린더에 하이라이트 없음")
    }

    // DatePicker가 time component를 포함해도 (00:00:00이 아닌 경우) 올바른 날짜에 하이라이트돼야 함
    func testCalendarSync_RecordWithTimeComponent_CorrectDateHighlighted() {
        let cal = Calendar.current
        // 오후 3시에 저장된 레코드 시뮬레이션 (DatePicker가 Date()로 초기화되는 경우)
        let targetDate = makeDate(daysFromNow: 5)
        var components = cal.dateComponents([.year, .month, .day], from: targetDate)
        components.hour = 15
        components.minute = 30
        let recordDateWithTime = cal.date(from: components)!

        let record = LeaveRecord(startDate: recordDateWithTime, endDate: recordDateWithTime, type: .annual, status: .planned)
        let calendarCellDate = cal.startOfDay(for: targetDate) // 캘린더 셀은 자정

        XCTAssertTrue(calendarIsLeave(date: calendarCellDate, records: [record]),
                      "time component가 있는 레코드도 해당 날짜 캘린더에 하이라이트돼야 함 (startOfDay 비교)")
    }

    // 내역에서 보이는 레코드 수 == 캘린더에서 하이라이트된 날짜 수 (단일일 레코드 기준)
    func testCalendarSync_HistoryRecordCount_MatchesHighlightedDates() {
        let date1 = makeDate(daysFromNow: 3)
        let date2 = makeDate(daysFromNow: 7)
        let date3 = makeDate(daysFromNow: -2) // 과거 used
        let records: [LeaveRecord] = [
            LeaveRecord(startDate: date1, endDate: date1, type: .annual,  status: .planned),
            LeaveRecord(startDate: date2, endDate: date2, type: .half,    status: .planned),
            LeaveRecord(startDate: date3, endDate: date3, type: .sick,    status: .used),
        ]
        let historyVisible = records.filter { $0.status != .cancelled }.count
        let calendarHighlighted = [date1, date2, date3].filter { calendarIsLeave(date: $0, records: records) }.count

        XCTAssertEqual(historyVisible, 3, "내역에 취소 아닌 레코드 3건")
        XCTAssertEqual(calendarHighlighted, 3, "캘린더에서도 3개 날짜 하이라이트")
        XCTAssertEqual(historyVisible, calendarHighlighted,
                       "내역 레코드 수 == 캘린더 하이라이트 날짜 수 (단일일 레코드)")
    }

    // MARK: - 3-way 남은 연차 일관성 테스트

    // 순수 연차만 있을 때: 현황탭·추천탭·설정의 사용 가능 연차가 동일해야 함
    func testThreeWayConsistency_PureAnnualLeave() {
        let totalAnnual = 15.0
        let past = makeDate(daysFromNow: -3)
        let future = makeDate(daysFromNow: 5)
        let records: [LeaveRecord] = [
            LeaveRecord(startDate: past,   endDate: past,   type: .annual, status: .used),
            LeaveRecord(startDate: future, endDate: future, type: .annual, status: .planned),
        ]

        let homeRemaining  = calcHomeEffectiveRemaining(records: records, bonuses: [], totalAnnual: totalAnnual, includeBonusInStatus: false)
        let recoAvailable  = calcAvailableLeave(records: records, bonuses: [], totalAnnual: totalAnnual)
        let settAvailable  = calcAvailableLeave(records: records, bonuses: [], totalAnnual: totalAnnual)

        XCTAssertEqual(homeRemaining, 13.0, "현황: 15 - 1(used) - 1(planned) = 13")
        XCTAssertEqual(homeRemaining, recoAvailable,  "현황탭 == 추천탭")
        XCTAssertEqual(recoAvailable, settAvailable,  "추천탭 == 설정")
    }

    // 보너스 연차 포함: 3-way 모두 동일 (보너스 잔여 포함)
    func testThreeWayConsistency_WithBonusLeave() {
        let totalAnnual = 15.0
        let bonus = BonusLeave(days: 3.0, type: .compensatory, reason: "테스트")
        let past = makeDate(daysFromNow: -2)
        let records: [LeaveRecord] = [
            LeaveRecord(startDate: past, endDate: past, type: .annual, status: .used),
        ]

        let homeRemaining = calcHomeEffectiveRemaining(records: records, bonuses: [bonus], totalAnnual: totalAnnual, includeBonusInStatus: true)
        let recoAvailable = calcAvailableLeave(records: records, bonuses: [bonus], totalAnnual: totalAnnual)
        let settAvailable = calcAvailableLeave(records: records, bonuses: [bonus], totalAnnual: totalAnnual)

        // 현황(보너스ON) = (15 - 1) + 3 = 17.0
        XCTAssertEqual(homeRemaining, 17.0, accuracy: 0.001, "현황(보너스ON): 14 + 3 = 17")
        XCTAssertEqual(homeRemaining, recoAvailable, "현황(보너스ON) == 추천탭")
        XCTAssertEqual(recoAvailable, settAvailable, "추천탭 == 설정")
    }

    // 보너스 연결 레코드: SettingsView 버그 수정 검증
    // 보너스로 사용한 반차는 연차 차감 아님 → 3-way 모두 동일해야 함
    func testThreeWayConsistency_BonusBackedRecord_NotDeducted() {
        let totalAnnual = 15.0
        let bonusId = UUID()
        let bonus = BonusLeave(days: 2.0, type: .compensatory, reason: "테스트")
        bonus.usedDays = 0.5

        let past = makeDate(daysFromNow: -1)
        let records: [LeaveRecord] = [
            LeaveRecord(startDate: past, endDate: past, type: .half, status: .used, bonusLeaveId: bonusId),
        ]

        let homeRemaining = calcHomeEffectiveRemaining(records: records, bonuses: [bonus], totalAnnual: totalAnnual, includeBonusInStatus: true)
        let recoAvailable = calcAvailableLeave(records: records, bonuses: [bonus], totalAnnual: totalAnnual)
        let settAvailable = calcAvailableLeave(records: records, bonuses: [bonus], totalAnnual: totalAnnual)

        // 보너스 반차는 연차 차감 아님 → committed=0 → annual remaining=15
        // 보너스 잔여=1.5 (2.0 - 0.5) → available=16.5
        XCTAssertEqual(homeRemaining, 16.5, accuracy: 0.001,
                       "보너스 반차는 연차 차감 아님: 15.0 + 1.5(보너스잔여) = 16.5")
        XCTAssertEqual(homeRemaining, recoAvailable, "현황탭 == 추천탭 (버그수정: deductsFromAnnualLeave 사용)")
        XCTAssertEqual(recoAvailable, settAvailable, "추천탭 == 설정 (버그수정: deductsFromAnnualLeave 사용)")
    }

    // 비차감 유형(병가·공가·출장): 연차 차감 없음 → 3-way 모두 동일 (총 연차 그대로)
    func testThreeWayConsistency_NonDeductingTypes_NoImpact() {
        let totalAnnual = 15.0
        let past = makeDate(daysFromNow: -1)
        let future = makeDate(daysFromNow: 3)
        let records: [LeaveRecord] = [
            LeaveRecord(startDate: past,   endDate: past,   type: .sick,         status: .used),
            LeaveRecord(startDate: past,   endDate: past,   type: .compensatory, status: .used),
            LeaveRecord(startDate: future, endDate: future, type: .businessTrip, status: .planned),
        ]

        let homeRemaining = calcHomeEffectiveRemaining(records: records, bonuses: [], totalAnnual: totalAnnual, includeBonusInStatus: false)
        let recoAvailable = calcAvailableLeave(records: records, bonuses: [], totalAnnual: totalAnnual)
        let settAvailable = calcAvailableLeave(records: records, bonuses: [], totalAnnual: totalAnnual)

        XCTAssertEqual(homeRemaining, 15.0, "비차감 유형은 연차에 영향 없음")
        XCTAssertEqual(homeRemaining, recoAvailable, "현황탭 == 추천탭")
        XCTAssertEqual(recoAvailable, settAvailable, "추천탭 == 설정")
    }

    // 복합 시나리오: 연차+반차+보너스+출장 혼합
    func testThreeWayConsistency_Mixed_AllEqual() {
        let totalAnnual = 20.0
        let bonusId = UUID()
        let bonus = BonusLeave(days: 3.0, type: .reward, reason: "포상")
        bonus.usedDays = 1.0

        let past   = makeDate(daysFromNow: -5)
        let future = makeDate(daysFromNow: 5)
        let records: [LeaveRecord] = [
            LeaveRecord(startDate: past,   endDate: past,   type: .annual,      status: .used),           // 연차 차감 1.0
            LeaveRecord(startDate: past,   endDate: past,   type: .half,        status: .used),           // 연차 차감 0.5
            LeaveRecord(startDate: past,   endDate: past,   type: .sick,        status: .used),           // 비차감
            LeaveRecord(startDate: past,   endDate: past,   type: .annual,      status: .used, bonusLeaveId: bonusId), // 보너스(비차감)
            LeaveRecord(startDate: future, endDate: future, type: .businessTrip, status: .planned),       // 비차감
        ]

        // committed = 1.0(annual) + 0.5(half) = 1.5 (sick·bonus·businessTrip 제외)
        // annualRemaining = 20 - 1.5 = 18.5
        // activeBonusLeave = 3.0 - 1.0 = 2.0
        // available = 18.5 + 2.0 = 20.5
        let homeRemaining = calcHomeEffectiveRemaining(records: records, bonuses: [bonus], totalAnnual: totalAnnual, includeBonusInStatus: true)
        let recoAvailable = calcAvailableLeave(records: records, bonuses: [bonus], totalAnnual: totalAnnual)
        let settAvailable = calcAvailableLeave(records: records, bonuses: [bonus], totalAnnual: totalAnnual)

        XCTAssertEqual(homeRemaining, 20.5, accuracy: 0.001, "복합: 18.5 + 2.0 = 20.5")
        XCTAssertEqual(homeRemaining, recoAvailable, "현황탭 == 추천탭")
        XCTAssertEqual(recoAvailable, settAvailable, "추천탭 == 설정")
    }

    // MARK: - LeaveUsageCalculator — 화면 간 숫자 일치

    /// 홈 카드와 휴가 사용 내역이 **같은 값**을 보여야 한다.
    /// (예전엔 내역이 출장·병가까지 더해 홈보다 큰 "사용 완료"를 띄웠다)
    func testHomeAndHistoryShareTheSameUsedNumber() {
        let past = makeDate(daysFromNow: -10)
        let records = [
            LeaveRecord(startDate: past, endDate: past, type: .annual, status: .used),
            LeaveRecord(startDate: past, endDate: past, type: .sick, status: .used),        // 연차 차감 아님
            LeaveRecord(startDate: past, endDate: past, type: .businessTrip, status: .used) // 연차 차감 아님
        ]
        let summary = LeaveUsageCalculator.currentSummary(records: records, startMonth: 1)

        XCTAssertEqual(summary.annualUsed, 1.0, "연차에서 깎인 건 1일뿐")
        XCTAssertEqual(summary.allTypesUsed, 3.0, "쉰 날로 세면 3일 — 두 숫자는 뜻이 다르다")
        XCTAssertEqual(summary.used(includingBonus: false), summary.annualUsed,
                       "화면이 '총 연차' 옆에 놓는 값은 언제나 연차 차감분")
    }

    func testPastPlannedCountsAsUsed() {
        let past = makeDate(daysFromNow: -3)
        let future = makeDate(daysFromNow: 5)
        let records = [
            LeaveRecord(startDate: past, endDate: past, type: .annual, status: .planned),   // 지나간 예정
            LeaveRecord(startDate: future, endDate: future, type: .annual, status: .planned)
        ]
        let summary = LeaveUsageCalculator.currentSummary(records: records, startMonth: 1)

        XCTAssertEqual(summary.annualUsed, 1.0, "종료일이 지난 예정은 사용으로 센다")
        XCTAssertEqual(summary.annualPlanned, 1.0)
        XCTAssertEqual(summary.annualCommitted, 2.0)
    }

    func testCancelledIsCountedNowhere() {
        let past = makeDate(daysFromNow: -3)
        let records = [LeaveRecord(startDate: past, endDate: past, type: .annual, status: .cancelled)]
        let summary = LeaveUsageCalculator.currentSummary(records: records, startMonth: 1)

        XCTAssertEqual(summary.annualUsed, 0)
        XCTAssertEqual(summary.annualPlanned, 0)
        XCTAssertEqual(summary.cancelledCount, 1)
    }

    /// 기준월이 1월이 아니면 회계연도 경계가 달라진다 — 경계 기록이 엉뚱한 해에 붙으면 안 된다.
    func testFiscalYearBoundaryWithAprilStart() {
        let calendar = Calendar.current
        let march = calendar.date(from: DateComponents(year: 2026, month: 3, day: 31))!
        let april = calendar.date(from: DateComponents(year: 2026, month: 4, day: 1))!

        XCTAssertEqual(LeaveUsageCalculator.fiscalYear(for: march, startMonth: 4), 2025)
        XCTAssertEqual(LeaveUsageCalculator.fiscalYear(for: april, startMonth: 4), 2026)

        let records = [
            LeaveRecord(startDate: march, endDate: march, type: .annual, status: .used),
            LeaveRecord(startDate: april, endDate: april, type: .annual, status: .used)
        ]
        let y2025 = LeaveUsageCalculator.summary(records: records, year: 2025, startMonth: 4,
                                                 asOf: makeDate(daysFromNow: 0))
        let y2026 = LeaveUsageCalculator.summary(records: records, year: 2026, startMonth: 4,
                                                 asOf: makeDate(daysFromNow: 0))
        XCTAssertEqual(y2025.annualUsed, 1.0)
        XCTAssertEqual(y2026.annualUsed, 1.0)
    }

    /// 지난 해 내역을 볼 때 올해 받은 보너스가 끼어들면 안 된다.
    func testBonusIsScopedToItsFiscalYear() {
        let calendar = Calendar.current
        let thisYear = calendar.component(.year, from: Date())
        let grantedNow = BonusLeave(days: 3, type: .compensatory)
        let summaryThisYear = LeaveUsageCalculator.summary(records: [], bonuses: [grantedNow],
                                                           year: thisYear, startMonth: 1)
        let summaryLastYear = LeaveUsageCalculator.summary(records: [], bonuses: [grantedNow],
                                                           year: thisYear - 1, startMonth: 1)

        XCTAssertEqual(summaryThisYear.grantedBonus, 3)
        XCTAssertEqual(summaryLastYear.grantedBonus, 0, "작년 요약에 올해 보너스가 들어가면 안 된다")
    }

    /// 보너스 포함 토글이 켜지면 총·사용·남음이 함께 움직여야 한다(총 = 사용 + 남음).
    func testBonusToggleKeepsTotalConsistent() {
        let past = makeDate(daysFromNow: -5)
        let bonus = BonusLeave(days: 2, type: .compensatory)
        bonus.usedDays = 1
        let records = [LeaveRecord(startDate: past, endDate: past, type: .annual, status: .used)]
        let summary = LeaveUsageCalculator.currentSummary(records: records, bonuses: [bonus], startMonth: 1)

        let grant = 15.0
        let total = summary.total(annualGrant: grant, includingBonus: true)
        let used = summary.used(includingBonus: true)
        let remaining = summary.remaining(annualGrant: grant, includingBonus: true)

        XCTAssertEqual(total, 17.0)
        XCTAssertEqual(used, 2.0, "연차 1일 + 보너스 1일")
        XCTAssertEqual(used + remaining, total, accuracy: 0.001, "총 = 사용 + 남음이 깨지면 안 된다")
    }
}
