//
//  Extensions.swift
//  Goldweek
//
//  유틸리티 확장
//

import Foundation
import SwiftUI
import GoldweekCore

// MARK: - Calendar




/// 처음 쓰는 사람의 화면 — 온보딩을 거친 새 설치만 켜진다. 값이 없는 기존 사용자는 모든 기능이 그대로 보인다.
@MainActor @Observable
final class AppSurface {
    static let shared = AppSurface()
    private static let simpleKey = "simpleSurface"
    private static let unlockedKey = "simpleSurface.unlocked"
    private static let pendingKey = "simpleSurface.pending"
    private static let lastUnlockKey = "simpleSurface.lastUnlock"

    private(set) var isSimple: Bool
    private var unlocked: Set<SurfaceFeature>
    /// 방금 열려 카드로 설명 중인 기능
    private(set) var pending: SurfaceFeature?

    private init() {
        let defaults = UserDefaults.standard
        isSimple = defaults.bool(forKey: Self.simpleKey)
        unlocked = Set((defaults.stringArray(forKey: Self.unlockedKey) ?? []).compactMap(SurfaceFeature.init))
        pending = defaults.string(forKey: Self.pendingKey).flatMap(SurfaceFeature.init)
    }

    func shows(_ feature: SurfaceFeature) -> Bool { !isSimple || unlocked.contains(feature) }

    func startSimple() {
        isSimple = true
        save()
    }

    func evaluate(facts: SurfaceFacts, isPro: Bool, now: Date = Date()) {
        guard isSimple else { return }
        // 값을 치른 기능을 숨길 수는 없다
        if isPro { return showEverything() }
        let lastUnlock = UserDefaults.standard.object(forKey: Self.lastUnlockKey) as? Date
        guard pending == nil,
              let feature = SurfaceFeature.next(unlocked: unlocked, facts: facts, lastUnlock: lastUnlock, now: now)
        else { return }
        unlocked.insert(feature)
        pending = feature
        UserDefaults.standard.set(now, forKey: Self.lastUnlockKey)
        save()
        UsageReportingService.record(event: "surface_unlock:\(feature.rawValue)")
    }

    func confirmPending() {
        if pending == .everything { isSimple = false }
        pending = nil
        save()
    }

    func showEverything() {
        isSimple = false
        pending = nil
        save()
    }

    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(isSimple, forKey: Self.simpleKey)
        defaults.set(unlocked.map(\.rawValue), forKey: Self.unlockedKey)
        defaults.set(pending?.rawValue, forKey: Self.pendingKey)
    }
}


// MARK: - Date Extensions

extension Date {
    
    /// **앱 언어 설정**을 따르는 날짜 문자열.
    ///
    /// ⚠️ `Date.formatted(...)`를 그냥 쓰면 안 된다 — 그건 **기기 언어**를 따라간다.
    ///    이 앱은 설정에서 언어를 따로 고를 수 있어서, 기기가 한국어인 채 앱만 영어로 바꾸면
    ///    "Joined: 2026년 8월 15일"처럼 한 줄에 두 언어가 섞인다.
    func appFormatted(date: DateFormatter.Style = .medium, time: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Strings.localeIdentifier)
        formatter.dateStyle = date
        formatter.timeStyle = time
        return formatter.string(from: self)
    }

    /// 연도 없는 짧은 날짜 ("8월 15일" / "Aug 15") — 앱 언어를 따른다.
    var appMonthDay: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Strings.localeIdentifier)
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        return formatter.string(from: self)
    }
}

// MARK: - Leave Days Formatting

