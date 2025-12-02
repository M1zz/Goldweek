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

        // 기본 연차 정보
        defaults.set(profile.remainingLeave, forKey: "remainingLeave")
        defaults.set(profile.totalAnnualLeave, forKey: "totalLeave")
        defaults.set(profile.usedLeave, forKey: "usedLeave")
        logDebug("연차 정보 저장 - 잔여: \(profile.remainingLeave), 총: \(profile.totalAnnualLeave), 사용: \(profile.usedLeave)", category: .widget)

        // 보너스 연차
        let activeBonusLeave = bonusLeaves
            .filter { !$0.isUsed }
            .reduce(0) { $0 + $1.days }
        defaults.set(activeBonusLeave, forKey: "bonusLeave")
        logDebug("보너스 연차 저장: \(activeBonusLeave)일", category: .widget)

        // 다가오는 휴가
        let today = Calendar.current.startOfDay(for: Date())
        let upcomingLeave = leaveRecords
            .filter { $0.status == .planned && $0.startDate >= today }
            .sorted { $0.startDate < $1.startDate }
            .first

        if let nextLeave = upcomingLeave {
            defaults.set(nextLeave.startDate, forKey: "nextLeaveDate")
            defaults.set(nextLeave.type.rawValue, forKey: "nextLeaveType")
            logDebug("다가오는 휴가 저장: \(nextLeave.startDate), 타입: \(nextLeave.type.rawValue)", category: .widget)
        } else {
            defaults.removeObject(forKey: "nextLeaveDate")
            defaults.removeObject(forKey: "nextLeaveType")
            logDebug("다가오는 휴가 없음", category: .widget)
        }

        // 위젯 리로드
        WidgetCenter.shared.reloadAllTimelines()
        logInfo("위젯 타임라인 리로드 요청 완료", category: .widget)
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

        WidgetCenter.shared.reloadAllTimelines()
        logInfo("위젯 데이터 초기화 완료", category: .widget)
    }
}
