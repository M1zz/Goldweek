//
//  ProBenefits.swift
//  Goldweek
//
//  '내 혜택' 화면이 세는 것 — 화면과 떨어뜨려 시험한다.
//

import Foundation

/// 산 사람이 **지금 무엇을 얼마나 쓰고 있는가**를 센다.
///
/// ⚠️ 무료 한도는 게이트와 **같은 상수·같은 셈법**을 쓴다(`ProManager.freeRecommendationAddLimit`).
///    추천 화면은 무료일 때 그해 추천 목록 앞 3개까지만 등록하게 한다 — 그래서 여기서도
///    "그해 등록한 추천 일정" 을 센다. 한 추천은 쉬는 날을 사이에 두고 여러 기록으로 나뉘어 저장되지만
///    (`LeaveRecommendation.leaveSegments`) 모두 같은 메모(추천 제목)를 달고 있어 제목으로 묶으면 한 개다.
enum ProBenefits {

    /// 휴가 기록에서 세는 데 필요한 것만 — 시험에서 SwiftData 없이 만든다.
    struct Entry: Equatable {
        let note: String
        let startDate: Date
        let isRecommended: Bool
        let isCancelled: Bool
    }

    /// 그해(달력 연도) 등록한 추천 일정 수. 취소한 것은 세지 않는다.
    static func recommendedPlanCount(_ entries: [Entry], year: Int, calendar: Calendar = .app) -> Int {
        Set(entries
            .filter { $0.isRecommended && !$0.isCancelled && calendar.component(.year, from: $0.startDate) == year }
            .map(\.note)
        ).count
    }

    /// 무료 한도를 넘어 쓰는 만큼. 한도 안이면 0 — 0 을 화면에 달면 손해 본 것처럼 읽히니 그리지 않는다.
    static func extra(used: Int, freeLimit: Int) -> Int { max(0, used - freeLimit) }

    /// 지금 등급 바로 위 등급. 맨 위(패밀리)면 nil.
    static func nextTier(after tier: ProTier) -> ProTier? {
        switch tier {
        case .free: return .plus
        case .plus: return .pro
        case .pro: return .family
        case .family: return nil
        }
    }
}

extension ProBenefits.Entry {
    init(_ record: LeaveRecord) {
        self.init(note: record.note, startDate: record.startDate,
                  isRecommended: record.isRecommended, isCancelled: record.status == .cancelled)
    }
}
