//
//  LeaveManager.swift
//  Goldweek
//
//  연차 관리 서비스
//

import Foundation
import SwiftData

@MainActor
class LeaveManager: ObservableObject {

    // MARK: - 연차 계산

    /// 특정 기간의 실제 연차 사용일 계산 (주말, 공휴일 제외)
    static func calculateLeaveDays(
        from startDate: Date,
        to endDate: Date,
        holidays: [Holiday],
        excludeWeekends: Bool = true
    ) -> Double {
        let calendar = Calendar.current
        var currentDate = startDate
        var leaveDays = 0.0

        while currentDate <= endDate {
            let weekday = calendar.component(.weekday, from: currentDate)
            let isWeekend = weekday == 1 || weekday == 7
            let isHoliday = holidays.contains { calendar.isDate($0.date, inSameDayAs: currentDate) }

            if !isWeekend || !excludeWeekends {
                if !isHoliday {
                    leaveDays += 1
                }
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        logDebug("연차 계산: \(startDate) ~ \(endDate) = \(leaveDays)일", category: .data)
        return leaveDays
    }
    
    /// 연차 소진 예상일 계산
    static func calculateExpiryDate(profile: UserProfile) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        
        // 다음 갱신월 계산
        if let currentMonth = components.month {
            if currentMonth >= profile.yearStartMonth {
                components.year! += 1
            }
            components.month = profile.yearStartMonth
            components.day = 1
        }
        
        return calendar.date(from: components) ?? Date()
    }
    
    /// 월별 연차 사용 통계
    static func getMonthlyUsage(records: [LeaveRecord], year: Int) -> [Int: Double] {
        let calendar = Calendar.current
        var monthlyUsage: [Int: Double] = [:]
        
        for month in 1...12 {
            monthlyUsage[month] = 0
        }
        
        for record in records where record.status != .cancelled {
            let recordYear = calendar.component(.year, from: record.startDate)
            if recordYear == year {
                let month = calendar.component(.month, from: record.startDate)
                let days = record.type == .half ? 0.5 : Double(record.daysCount)
                monthlyUsage[month, default: 0] += days
            }
        }
        
        return monthlyUsage
    }
    
    // MARK: - 연차 유효성 검사
    
    /// 날짜 범위 중복 체크
    static func hasOverlap(
        startDate: Date,
        endDate: Date,
        existingRecords: [LeaveRecord]
    ) -> Bool {
        for record in existingRecords where record.status != .cancelled {
            if startDate <= record.endDate && endDate >= record.startDate {
                return true
            }
        }
        return false
    }
    
    /// 연차 등록 가능 여부 확인
    static func canAddLeave(
        profile: UserProfile,
        startDate: Date,
        endDate: Date,
        type: LeaveType,
        existingRecords: [LeaveRecord],
        holidays: [Holiday]
    ) -> (canAdd: Bool, reason: String?) {
        logDebug("연차 등록 가능 여부 확인 - \(startDate) ~ \(endDate), 타입: \(type.rawValue)", category: .data)

        // 날짜 유효성
        if startDate > endDate {
            logWarning("연차 등록 실패: 시작일이 종료일보다 늦음", category: .data)
            return (false, "시작일이 종료일보다 늦습니다.")
        }

        // 중복 체크
        if hasOverlap(startDate: startDate, endDate: endDate, existingRecords: existingRecords) {
            logWarning("연차 등록 실패: 기존 연차와 중복", category: .data)
            return (false, "이미 등록된 연차와 겹치는 기간입니다.")
        }

        // 연차 잔여일 체크
        let requiredDays = type == .half ? 0.5 : calculateLeaveDays(from: startDate, to: endDate, holidays: holidays)
        if profile.remainingLeave < requiredDays {
            logWarning("연차 등록 실패: 잔여 연차 부족 (필요: \(requiredDays), 남음: \(profile.remainingLeave))", category: .data)
            return (false, "연차가 부족합니다. (필요: \(requiredDays)일, 남음: \(profile.remainingLeave)일)")
        }

        logDebug("연차 등록 가능", category: .data)
        return (true, nil)
    }
    
    // MARK: - 연차 상태 업데이트

    /// 지난 연차 자동 완료 처리
    static func updatePastLeaves(records: [LeaveRecord], modelContext: ModelContext) {
        let today = Date()
        var updatedCount = 0

        for record in records {
            if record.status == .planned && record.endDate < today {
                record.status = .used
                updatedCount += 1
            }
        }

        if updatedCount > 0 {
            logInfo("지난 연차 \(updatedCount)건 자동 완료 처리", category: .data)
            do {
                try modelContext.save()
                logDebug("연차 상태 업데이트 저장 완료", category: .data)
            } catch {
                logError("연차 상태 업데이트 저장 실패: \(error.localizedDescription)", category: .data)
            }
        }
    }
}
