//
//  Accessibility.swift
//  Goldweek
//
//  VoiceOver 접근성 표준 modifier 및 라벨 빌더
//

import SwiftUI

// MARK: - View Modifiers

extension View {
    /// 카드 단위로 자식 요소를 하나의 VoiceOver 엔티티로 묶는다.
    /// 카드/리스트 행/요약 박스에 사용.
    func voCard(_ label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(label))
            .accessibilityHint(hint.map(Text.init) ?? Text(""))
    }

    /// 버튼/탭 가능한 요소를 단일 VoiceOver 버튼으로 묶는다.
    /// 활성화 트레이트가 포함되어 "이중 탭하여 활성화" 안내가 나온다.
    func voButton(_ label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(label))
            .accessibilityHint(hint.map(Text.init) ?? Text(""))
            .accessibilityAddTraits(.isButton)
    }

    /// 장식용 아이콘/이모지/색상 표시를 VoiceOver에서 숨긴다.
    /// 의미가 없는 시각 요소(구분점, 장식 이모지, 그라데이션 등)에 사용.
    func voDecorative() -> some View {
        self.accessibilityHidden(true)
    }

    /// 토글/선택 상태를 VoiceOver에 알린다.
    func voSelected(_ isSelected: Bool) -> some View {
        self.accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// 헤더(섹션 제목)임을 VoiceOver에 알린다.
    func voHeader() -> some View {
        self.accessibilityAddTraits(.isHeader)
    }
}

// MARK: - VoiceOver Label Builders

/// 화면 곳곳에서 재사용되는 VoiceOver 문구 빌더.
/// 시각적 라벨을 그대로 읽으면 어색한 경우(아이콘+숫자+단위 분리, 색만으로 상태 표시 등)
/// 자연어 한 문장으로 합쳐서 반환한다.
enum VoiceOverLabel {

    /// 연차 잔여 요약: "연차 21일 중 12일 사용, 9일 남음"
    static func leaveBalance(total: Double, used: Double, remaining: Double) -> String {
        let lang = LanguageManager.shared.currentLanguage
        let t = formatDays(total)
        let u = formatDays(used)
        let r = formatDays(remaining)
        switch lang {
        case .korean: return "연차 \(t)일 중 \(u)일 사용, \(r)일 남음"
        case .english: return "\(u) of \(t) days used, \(r) remaining"
        case .japanese: return "有給\(t)日中\(u)日使用、残り\(r)日"
        case .chinese: return "年假\(t)天中已使用\(u)天，剩余\(r)天"
        }
    }

    /// 보너스 일수: "보너스 사용 가능 3.5일"
    static func bonus(days: Double) -> String {
        let lang = LanguageManager.shared.currentLanguage
        let d = formatDays(days)
        switch lang {
        case .korean: return "보너스 사용 가능 \(d)일"
        case .english: return "Bonus available: \(d) days"
        case .japanese: return "ボーナス使用可能 \(d)日"
        case .chinese: return "可用奖励 \(d) 天"
        }
    }

    /// 다가오는 휴가 행: "11월 3일 월요일부터 5일까지, 연차 3일, 5일 남음"
    static func upcomingLeave(dateRange: String, typeLabel: String, days: Double, dDay: Int) -> String {
        let lang = LanguageManager.shared.currentLanguage
        let d = formatDays(days)
        switch lang {
        case .korean: return "\(dateRange), \(typeLabel) \(d)일, \(dDay)일 남음"
        case .english: return "\(dateRange), \(typeLabel) \(d) days, in \(dDay) days"
        case .japanese: return "\(dateRange)、\(typeLabel)\(d)日、あと\(dDay)日"
        case .chinese: return "\(dateRange)，\(typeLabel)\(d)天，还有\(dDay)天"
        }
    }

    /// 추천 황금연휴: "10월 1일부터 6일까지 6일 연휴, 연차 2일 필요, 추천 점수 92"
    static func recommendation(dateRange: String, totalDays: Int, leavesNeeded: Int, score: Int?) -> String {
        let lang = LanguageManager.shared.currentLanguage
        let scorePart: String = {
            guard let score else { return "" }
            switch lang {
            case .korean: return ", 추천 점수 \(score)"
            case .english: return ", recommendation score \(score)"
            case .japanese: return "、おすすめスコア\(score)"
            case .chinese: return "，推荐分数\(score)"
            }
        }()
        switch lang {
        case .korean: return "\(dateRange), 총 \(totalDays)일 연휴, 연차 \(leavesNeeded)일 필요\(scorePart)"
        case .english: return "\(dateRange), \(totalDays)-day holiday, \(leavesNeeded) leave days required\(scorePart)"
        case .japanese: return "\(dateRange)、合計\(totalDays)日の連休、有給\(leavesNeeded)日必要\(scorePart)"
        case .chinese: return "\(dateRange)，共\(totalDays)天连假，需请\(leavesNeeded)天年假\(scorePart)"
        }
    }

    /// 항공권 카드: "서울에서 홍콩, 11월 3일부터 7일, 대한항공 직항, 42만 8천원"
    static func flight(origin: String, destination: String, dateRange: String, airline: String?, direct: Bool, priceText: String) -> String {
        let lang = LanguageManager.shared.currentLanguage
        let airlinePart = airline.map { " \($0)" } ?? ""
        let directPart: String = {
            guard direct else { return "" }
            switch lang {
            case .korean: return " 직항"
            case .english: return " direct"
            case .japanese: return " 直行"
            case .chinese: return " 直飞"
            }
        }()
        switch lang {
        case .korean: return "\(origin)에서 \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .english: return "\(origin) to \(destination), \(dateRange),\(airlinePart)\(directPart), \(priceText)"
        case .japanese: return "\(origin)から\(destination)、\(dateRange)、\(airlinePart)\(directPart)、\(priceText)"
        case .chinese: return "\(origin)到\(destination)，\(dateRange)，\(airlinePart)\(directPart)，\(priceText)"
        }
    }

    /// 숙박 카드: "호텔명, 별점 4.5, 1박 12만원"
    static func accommodation(name: String, rating: Double?, priceText: String) -> String {
        let lang = LanguageManager.shared.currentLanguage
        let ratingPart: String = {
            guard let rating else { return "" }
            let r = String(format: "%.1f", rating)
            switch lang {
            case .korean: return ", 별점 \(r)"
            case .english: return ", rating \(r)"
            case .japanese: return "、評価\(r)"
            case .chinese: return "，评分\(r)"
            }
        }()
        switch lang {
        case .korean: return "\(name)\(ratingPart), \(priceText)"
        case .english: return "\(name)\(ratingPart), \(priceText)"
        case .japanese: return "\(name)\(ratingPart)、\(priceText)"
        case .chinese: return "\(name)\(ratingPart)，\(priceText)"
        }
    }

    /// D-Day 표시: "오늘", "5일 남음", "3일 지남"
    static func dDay(_ daysRemaining: Int) -> String {
        let lang = LanguageManager.shared.currentLanguage
        if daysRemaining == 0 {
            switch lang {
            case .korean: return "오늘"
            case .english: return "Today"
            case .japanese: return "今日"
            case .chinese: return "今天"
            }
        }
        let n = abs(daysRemaining)
        if daysRemaining > 0 {
            switch lang {
            case .korean: return "\(n)일 남음"
            case .english: return "in \(n) days"
            case .japanese: return "あと\(n)日"
            case .chinese: return "还有\(n)天"
            }
        } else {
            switch lang {
            case .korean: return "\(n)일 지남"
            case .english: return "\(n) days ago"
            case .japanese: return "\(n)日経過"
            case .chinese: return "已过\(n)天"
            }
        }
    }

    // MARK: - Helpers

    private static func formatDays(_ days: Double) -> String {
        if days == days.rounded() {
            return "\(Int(days))"
        }
        return String(format: "%.1f", days)
    }
}
