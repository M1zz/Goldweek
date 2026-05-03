//
//  WidgetService.swift
//  LeaveWise
//
//  위젯 데이터 동기화 서비스
//

import Foundation
import WidgetKit
import SwiftData

class WidgetService {
    static let shared = WidgetService()

    private let suiteName = "group.com.Ysoup.LeaveWise"

    private init() {
        logDebug("WidgetService 초기화", category: .widget)
    }

    /// 위젯 데이터 업데이트
    func updateWidgetData(
        profile: UserProfile,
        bonusLeaves: [BonusLeave],
        leaveRecords: [LeaveRecord]
    ) {
        logDebug("위젯 데이터 업데이트 시작", category: .widget)

        guard let defaults = UserDefaults(suiteName: suiteName) else {
            logError("App Group UserDefaults 접근 실패: \(suiteName)", category: .widget)
            return
        }

        // 기본 연차 정보 (계획 중인 휴가도 사용된 것으로 계산)
        let total = profile.totalAnnualLeave
        let used = leaveRecords
            .filter { ($0.status == .used || $0.status == .planned) && $0.type.deductsFromAnnual }
            .reduce(0.0) { $0 + $1.effectiveLeaveDays }
        let remaining = max(0, total - used)

        defaults.set(remaining, forKey: "remainingLeave")
        defaults.set(total, forKey: "totalLeave")
        defaults.set(used, forKey: "usedLeave")
        logDebug("연차 정보 저장 - 잔여: \(remaining), 총: \(total), 사용: \(used)", category: .widget)

        // 보너스 연차
        let activeBonusLeave = bonusLeaves
            .filter { !$0.isUsed }
            .reduce(0.0) { $0 + $1.days }
        defaults.set(activeBonusLeave, forKey: "bonusLeave")
        logDebug("보너스 연차 저장: \(activeBonusLeave)일", category: .widget)

        // 사용자 이름
        defaults.set(profile.name, forKey: "userName")

        // 다가오는 휴가
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let upcomingLeave = leaveRecords
            .filter { $0.status == .planned && $0.startDate >= today }
            .sorted { $0.startDate < $1.startDate }
            .first

        if let nextLeave = upcomingLeave {
            defaults.set(nextLeave.startDate, forKey: "nextLeaveDate")
            defaults.set(nextLeave.type.rawValue, forKey: "nextLeaveType")
            defaults.set(nextLeave.note, forKey: "nextLeaveNote")

            let daysUntil = calendar.dateComponents([.day], from: today, to: nextLeave.startDate).day ?? 0
            defaults.set(daysUntil, forKey: "daysUntilNextLeave")

            // 휴가 기간 (일수)
            let duration = calendar.dateComponents([.day], from: nextLeave.startDate, to: nextLeave.endDate).day ?? 0
            defaults.set(duration + 1, forKey: "nextLeaveDuration")

            logDebug("다가오는 휴가 저장: D-\(daysUntil), 기간: \(duration + 1)일", category: .widget)
        } else {
            defaults.removeObject(forKey: "nextLeaveDate")
            defaults.removeObject(forKey: "nextLeaveType")
            defaults.removeObject(forKey: "nextLeaveNote")
            defaults.set(-1, forKey: "daysUntilNextLeave")
            defaults.set(0, forKey: "nextLeaveDuration")
            logDebug("다가오는 휴가 없음", category: .widget)
        }

        // 연차 소진 속도 계산
        let burnRateData = calculateBurnRate(
            yearStartMonth: profile.yearStartMonth,
            totalLeave: total,
            usedLeave: used
        )
        defaults.set(burnRateData.elapsedRatio, forKey: "elapsedRatio")
        defaults.set(burnRateData.idealUsedRatio, forKey: "idealUsedRatio")
        defaults.set(burnRateData.actualUsedRatio, forKey: "actualUsedRatio")
        defaults.set(burnRateData.burnRate, forKey: "burnRate")
        defaults.set(burnRateData.remainingDays, forKey: "remainingDaysUntilReset")
        defaults.set(profile.yearStartMonth, forKey: "yearStartMonth")
        logDebug("소진 속도 저장 - 경과: \(burnRateData.elapsedRatio), 실제: \(burnRateData.actualUsedRatio), 속도: \(burnRateData.burnRate)", category: .widget)

        // 즉시 디스크에 동기화
        defaults.synchronize()

        // 위젯 리로드
        WidgetCenter.shared.reloadAllTimelines()
        logInfo("위젯 타임라인 리로드 요청 완료 - 잔여: \(remaining)일", category: .widget)
    }

    /// 연차 소진 속도 계산
    private func calculateBurnRate(
        yearStartMonth: Int,
        totalLeave: Double,
        usedLeave: Double
    ) -> (elapsedRatio: Double, idealUsedRatio: Double, actualUsedRatio: Double, burnRate: Double, remainingDays: Int) {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        // 연차 시작일 계산
        var startComponents = DateComponents()
        startComponents.day = 1
        startComponents.month = yearStartMonth

        // 현재 월이 시작월보다 이전이면 작년부터 시작
        if currentMonth < yearStartMonth {
            startComponents.year = currentYear - 1
        } else {
            startComponents.year = currentYear
        }

        guard let yearStartDate = calendar.date(from: startComponents) else {
            return (0, 0, 0, 1.0, 0)
        }

        // 연차 종료일 (시작일 + 1년)
        guard let yearEndDate = calendar.date(byAdding: .year, value: 1, to: yearStartDate) else {
            return (0, 0, 0, 1.0, 0)
        }

        // 전체 기간 (일)
        let totalDays = calendar.dateComponents([.day], from: yearStartDate, to: yearEndDate).day ?? 365

        // 경과 기간 (일)
        let elapsedDays = calendar.dateComponents([.day], from: yearStartDate, to: now).day ?? 0

        // 남은 기간 (일)
        let remainingDays = max(0, totalDays - elapsedDays)

        // 경과 비율 (0~1)
        let elapsedRatio = min(1.0, max(0, Double(elapsedDays) / Double(totalDays)))

        // 이상적인 사용 비율 = 경과 비율
        let idealUsedRatio = elapsedRatio

        // 실제 사용 비율
        let actualUsedRatio = totalLeave > 0 ? usedLeave / totalLeave : 0

        // 소진 속도 (1.0 = 적정, <1.0 = 느림, >1.0 = 빠름)
        let burnRate: Double
        if idealUsedRatio > 0 {
            burnRate = actualUsedRatio / idealUsedRatio
        } else {
            burnRate = actualUsedRatio > 0 ? 2.0 : 1.0
        }

        return (elapsedRatio, idealUsedRatio, actualUsedRatio, burnRate, remainingDays)
    }

    /// 모든 위젯 데이터 초기화
    func clearWidgetData() {
        logInfo("위젯 데이터 초기화 시작", category: .widget)

        guard let defaults = UserDefaults(suiteName: suiteName) else {
            logError("App Group UserDefaults 접근 실패: \(suiteName)", category: .widget)
            return
        }

        defaults.removeObject(forKey: "remainingLeave")
        defaults.removeObject(forKey: "totalLeave")
        defaults.removeObject(forKey: "usedLeave")
        defaults.removeObject(forKey: "bonusLeave")
        defaults.removeObject(forKey: "nextLeaveDate")
        defaults.removeObject(forKey: "nextLeaveType")
        defaults.removeObject(forKey: "nextLeaveNote")
        defaults.removeObject(forKey: "userName")
        defaults.set(-1, forKey: "daysUntilNextLeave")
        defaults.set(0, forKey: "nextLeaveDuration")

        WidgetCenter.shared.reloadAllTimelines()
        logInfo("위젯 데이터 초기화 완료", category: .widget)
    }
}
