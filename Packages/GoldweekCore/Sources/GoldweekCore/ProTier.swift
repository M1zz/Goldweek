import Foundation

/// 유료 칸. 위 칸은 아래 칸 기능을 모두 포함한다. 무엇을 왜 어느 칸에 두는지는 docs/MONETIZATION.md.
/// - 플러스: 최적 플래너·추천 무제한·다른 해 추천·캘린더 앱으로 보내기 (`isPro`로 본다)
/// - 프로: + 보너스 연차·캘린더 자동 감지·종류별 한도·학교 달력·함께 쉬기·가족 기념일 (`hasProTier`·`has(_:)`)
///
/// 2.4.2 전에는 프로 위에 패밀리(rawValue 3)가 있었다. 패밀리는 프로에 합쳤다.
/// 기기에 남은 3 은 프로로 읽는다(`init`).
public enum ProTier: Int, Comparable, CaseIterable {
    case free
    case plus
    case pro

    public static func < (a: ProTier, b: ProTier) -> Bool { a.rawValue < b.rawValue }
}

extension ProTier: Identifiable {
    public var id: Int { rawValue }
}
