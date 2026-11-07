//
//  LeaveManager.swift
//  Goldweek
//
//  연차 관리 서비스
//

import Foundation
import SwiftData
import GoldweekCore

@MainActor
class LeaveManager: ObservableObject {

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

// MARK: - 데이터 보정

enum LeaveMigrations {
    private static let splitRecommendedKey = "migration.splitRecommendedLeaves.v1"

    /// 예전 버전은 추천을 "쉬는 기간 전체"(주말·공휴일 포함)로 등록했다.
    /// 추천으로 만든 기록을 연차 내는 날만 남도록 연속 구간으로 나눈다. 한 번만 돈다.
    ///
    /// ⚠️ `DayOffCalendar`가 사용자 국가·공휴일로 채워진 뒤에 불러야 한다.
    static func splitRecommendedLeavesIfNeeded(records: [LeaveRecord], context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: splitRecommendedKey) else { return }
        let dayOff = DayOffCalendar.shared
        let calendar = Calendar.app
        var changed = 0

        for record in records where record.isRecommended && record.length == .full && !record.isBulkSummary {
            // 연차 낼 날만 연속 구간으로
            var segments: [(start: Date, end: Date)] = []
            var d = calendar.startOfDay(for: record.startDate)
            let last = calendar.startOfDay(for: record.endDate)
            while d <= last {
                if !dayOff.isDayOff(d) {
                    if let prev = segments.last, calendar.date(byAdding: .day, value: 1, to: prev.end) == d {
                        segments[segments.count - 1].end = d
                    } else {
                        segments.append((d, d))
                    }
                }
                d = calendar.date(byAdding: .day, value: 1, to: d)!
            }

            // 이미 연차일만 담고 있거나(구간 1개가 전체와 같음), 전부 쉬는 날이면 그대로 둔다
            guard let first = segments.first else { continue }
            if segments.count == 1, first.start == calendar.startOfDay(for: record.startDate),
               first.end == last { continue }

            record.startDate = first.start
            record.endDate = first.end
            for seg in segments.dropFirst() {
                let copy = LeaveRecord(startDate: seg.start, endDate: seg.end, type: record.type,
                                       status: record.status, note: record.note, isRecommended: true,
                                       length: record.length, bonusLeaveId: record.bonusLeaveId)
                context.insert(copy)
            }
            changed += 1
        }

        if changed > 0 {
            do {
                try context.save()
                logInfo("추천 휴가 \(changed)건을 연차일 구간으로 나눔", category: .data)
            } catch {
                logError("추천 휴가 구간 나누기 실패: \(error.localizedDescription)", category: .data)
                return   // 다음 실행에 다시 시도
            }
        }
        UserDefaults.standard.set(true, forKey: splitRecommendedKey)
    }
}
