//
//  WhatsNewView.swift
//  Goldweek
//
//  업데이트 뒤 처음 열 때 한 번 뜨는 "새로운 기능" 시트. 설정 > 도움말에서 다시 볼 수 있다.
//
//  ⚠️ **처음 받은 사람에게는 뜨지 않는다.** 그 사람은 온보딩과 사용법이 맞이한다 —
//     새로 온 사람에게 "새로워졌어요"는 무슨 말인지 알 수 없는 말이다(`WhatsNewGate`).
//

import SwiftUI

/// 이 안내가 소개하는 버전.
/// ⚠️ **내용을 바꿀 때 이 값도 같이 올릴 것.** 안 올리면 업데이트한 사람은 이미 본 것으로 기록돼 있어
///    새 안내를 한 번도 못 본다. 내용과 상관없는 버전 올림에서는 그대로 둔다(다시 뜨지 않게).
enum WhatsNewContent {
    static let version = "2.4.1"
}

/// 이번 실행에 안내를 띄울지 가르는 한 곳 — 순수 함수라 시험이 같은 입력을 직접 만든다.
enum WhatsNewGate: Equatable {
    /// 처음 설치 — 본 것으로 표시만 하고 넘어간다.
    case newcomer
    /// 쓰던 사람인데 이번 안내를 아직 못 봤다.
    case show
    /// 이미 봤다.
    case seen

    static let lastSeenKey = "whatsNew.lastSeenVersion"

    /// 앱이 뜬 순간 이미 온보딩을 마친 기기였는가 — 온보딩을 이번 실행에 마친 사람은 새로 온 사람이다.
    /// `GoldweekApp.init` 에서 한 번 적는다(온보딩이 값을 바꾸기 전에).
    nonisolated(unsafe) static var wasOnboardedAtLaunch = false

    static func captureLaunchState(defaults: UserDefaults = .standard) {
        wasOnboardedAtLaunch = defaults.bool(forKey: "hasCompletedOnboarding")
    }

    static func resolve(wasOnboardedAtLaunch: Bool, lastSeenVersion: String?,
                        currentVersion: String = WhatsNewContent.version) -> WhatsNewGate {
        guard wasOnboardedAtLaunch else { return .newcomer }
        return lastSeenVersion == currentVersion ? .seen : .show
    }

    /// 지금 띄워야 하나. 띄우지 않는 경우에도 새로 온 사람은 본 것으로 적어 둔다.
    static func shouldPresentNow(defaults: UserDefaults = .standard) -> Bool {
        guard !ScreenshotMode.isActive else { return false }
        let gate = resolve(wasOnboardedAtLaunch: wasOnboardedAtLaunch,
                           lastSeenVersion: defaults.string(forKey: lastSeenKey))
        if gate == .newcomer { markSeen(defaults: defaults) }
        return gate == .show
    }

    static func markSeen(defaults: UserDefaults = .standard) {
        defaults.set(WhatsNewContent.version, forKey: lastSeenKey)
    }
}

struct WhatsNewView: View {
    let onClose: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    private struct Item: Identifiable {
        var id: String { symbol }
        let symbol: String
        let color: Color
        let title: String
        let detail: String
    }

    /// 2.4.1 에 실제로 들어간 것만.
    private var items: [Item] {
        [
            Item(symbol: "crown.fill", color: AppTheme.Colors.bonus,
                 title: Strings.whatsNewBenefitsTitle, detail: Strings.whatsNewBenefitsDetail),
            Item(symbol: "ticket", color: .pink,
                 title: Strings.whatsNewCodeTitle, detail: Strings.whatsNewCodeDetail),
            Item(symbol: "map", color: .teal,
                 title: Strings.whatsNewRoadmapTitle, detail: Strings.whatsNewRoadmapDetail),
            Item(symbol: "accessibility", color: .blue,
                 title: Strings.whatsNewA11yTitle, detail: Strings.whatsNewA11yDetail),
        ]
    }

    var body: some View {
        let _ = LanguageManager.shared.currentLanguage
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.largeTitle.weight(.medium))
                            .foregroundStyle(AppTheme.Colors.bonus)
                            .padding(.top, 28)
                            .voDecorative()
                        Text(Strings.whatsNewTitle)
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                        Text(Strings.whatsNewSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            row(item)
                                // 움직임 줄이기: 밀려 올라오지 않고 그 자리에서 나타난다
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared || reduceMotion ? 0 : 12)
                                .animation(reduceMotion ? .easeOut(duration: 0.2)
                                           : .spring(response: 0.5, dampingFraction: 0.85).delay(Double(index) * 0.06),
                                           value: appeared)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 16)
            }

            Button {
                onClose()
            } label: {
                Text(Strings.whatsNewContinue)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 30)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(AppTheme.Colors.brand)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .accessibilityInputLabels([Text(Strings.whatsNewContinue), Text(Strings.close)])
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear { appeared = true }
        // 어떻게 닫든(밀어 내려도) 본 것으로 적는다
        .onDisappear { WhatsNewGate.markSeen() }
    }

    private func row(_ item: Item) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: item.symbol)
                .font(.title3)
                .foregroundStyle(item.color)
                .frame(width: 32, height: 32)
                .voDecorative()
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.headline)
                Text(item.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}
