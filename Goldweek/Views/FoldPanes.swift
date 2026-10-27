//
//  FoldPanes.swift
//  Goldweek
//
//  아이폰 듀오를 폈을 때 탭마다 접힌 선 양쪽에 무엇이 서는가.
//  자리 셈 · 시트 가드 · 탭 막대는 LeeoKit Fold 모듈이 하고, 여기는 이 앱의 짝만 정한다.
//  시안: 골드위크 듀오 시안 (https://claude.ai/artifact/K6qv6q4fJwivvimcBBhrcA)
//
//  - 펼치면 오른쪽(세로면 위)에는 **현황**이 선다. 왼쪽(아래)은 캘린더 · 가족 · 설정 중 고른 탭.
//    그래서 현황 탭은 따로 서지 않고, 펼친 탭 막대에는 셋만 선다.
//    가족 탭만 오른쪽에 다 같이 쉬는 날(`FamilyTogetherView`, 프로)이 선다.
//  - 캘린더에서 추천을 누르면 현황에 "추가하면 남은 연차 N일"이 미리 그려진다(`FoldLeavePreview`).
//    넣기 전에 결과를 보는 것 — 접힌 선의 '하기 전 | 한 뒤'가 이 앱에서 하는 일이다.
//
//  ⚠️ 넓은 화면 판정(`LayoutMode.isLargeScreen`)은 아이폰이 아닐 때만 참이라 듀오에서는 늘 거짓이다.
//     듀오는 두 칸 화면(`WideMainView`)이 아니라 이 탭 + `FoldSplitView` 로 선다 — 탭 구조가 그대로라
//     펴고 접어도 보던 달 · 시트가 남는다(if/else 로 갈아 끼우면 전부 처음으로 돌아간다).
//

import SwiftUI
import LeeoKit

// MARK: - 추천 미리보기

/// 펼친 화면에서 캘린더의 추천을 하나 고르면, 현황이 그걸 넣었을 때의 숫자를 미리 그린다.
@MainActor
@Observable
final class FoldLeavePreview {
    static let shared = FoldLeavePreview()
    private(set) var recommendationID: UUID?
    private(set) var leaveDays: Double = 0
    private init() {}

    var isShowing: Bool { recommendationID != nil && leaveDays > 0 }

    func toggle(_ recommendation: LeaveRecommendation) {
        if recommendationID == recommendation.id {
            clear()
        } else {
            recommendationID = recommendation.id
            leaveDays = recommendation.requiredLeaveDays
        }
    }

    func clear() {
        recommendationID = nil
        leaveDays = 0
    }
}

extension View {
    /// 추천 카드에 건다. 펼친 화면에서만 눌러 고를 수 있고, 고른 카드는 테두리가 선다.
    /// 이미 넣은 추천은 고를 것이 없다.
    func foldPreviewSelectable(_ recommendation: LeaveRecommendation, isAdded: Bool) -> some View {
        modifier(FoldPreviewSelectable(recommendation: recommendation, isAdded: isAdded))
    }
}

private struct FoldPreviewSelectable: ViewModifier {
    @Environment(\.foldLayout) private var fold
    let recommendation: LeaveRecommendation
    let isAdded: Bool

    func body(content: Content) -> some View {
        let preview = FoldLeavePreview.shared
        if fold.isUnfolded, !isAdded {
            let isOn = preview.recommendationID == recommendation.id
            content
                .overlay {
                    if isOn {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.yellow, lineWidth: 2.5)
                            .allowsHitTesting(false)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) { preview.toggle(recommendation) }
                }
                .accessibilityAddTraits(isOn ? .isSelected : [])
        } else {
            content
        }
    }
}

/// 현황 막대 위에 얹는 빗금 칸. 넣으면 줄어들 남은 연차의 자리다.
struct FoldPreviewStripes: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.blue.opacity(0.18)))
            var x: CGFloat = -size.height
            while x < size.width {
                var line = Path()
                line.move(to: CGPoint(x: x, y: size.height))
                line.addLine(to: CGPoint(x: x + size.height, y: 0))
                context.stroke(line, with: .color(.blue.opacity(0.7)), lineWidth: 2)
                x += 6
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - 탭

/// 펼친 화면의 탭 한 장: 왼쪽 고른 탭 | 오른쪽 현황(또는 그 탭이 정한 결과).
struct FoldTab<Choose: View, Result: View>: View {
    @ViewBuilder let choose: () -> Choose
    @ViewBuilder let result: () -> Result

    var body: some View {
        FoldSplitView {
            choose()
        } result: {
            result()
                // 오른쪽 판 안에서는 접히지 않은 화면처럼 선다(그 안의 줄은 그 판 안에서 밀려 들어간다).
                .environment(\.foldLayout, .single)
        }
        .foldTabBarRoom()
    }
}

extension FoldTab where Result == HomeView {
    /// 오른쪽에 현황이 서는 탭.
    init(profile: UserProfile, @ViewBuilder choose: @escaping () -> Choose) {
        self.init(choose: choose, result: { HomeView(profile: profile) })
    }
}

/// 가족 탭의 오른쪽 판. 프로면 다 같이 쉬는 날, 아니면 현황.
/// 잠금은 그대로다. 펼친다고 프로 기능이 열리지 않는다.
struct FoldFamilyResult: View {
    @Bindable var profile: UserProfile

    var body: some View {
        if ProManager.shared.hasProTier {
            NavigationStack { FamilyTogetherView(profile: profile) }
        } else {
            HomeView(profile: profile)
        }
    }
}

enum FoldTabs {
    /// 펼쳤을 때 고르는 쪽 판 바닥에 서는 칸. 현황(0)은 늘 오른쪽 판에 있으므로 빠진다.
    static func items(showsFamily: Bool) -> [FoldTabBar<Int>.Item] {
        var items: [FoldTabBar<Int>.Item] = [.init(value: 1, title: Strings.tabCalendar, symbol: "calendar")]
        if showsFamily {
            items.append(.init(value: 2, title: Strings.tabFamily, symbol: "person.2.fill"))
        }
        items.append(.init(value: 3, title: Strings.tabSettings, symbol: "gearshape.fill"))
        return items
    }
}

extension View {
    /// 펼쳤을 때 현황 탭에 있었다면 캘린더로 옮긴다. 현황은 그 오른쪽 판에 그대로 서 있다.
    /// 접으면 미리보기를 거둔다 — 바깥 화면에는 현황과 캘린더가 함께 서지 않는다.
    func foldHomeTabRedirect(selectedTab: Binding<Int>) -> some View {
        modifier(FoldHomeTabRedirect(selectedTab: selectedTab))
    }
}

private struct FoldHomeTabRedirect: ViewModifier {
    @Environment(\.foldLayout) private var fold
    @Binding var selectedTab: Int

    func body(content: Content) -> some View {
        content.onChange(of: fold.isUnfolded, initial: true) { _, unfolded in
            if unfolded, selectedTab == 0 { selectedTab = 1 }
            if !unfolded { FoldLeavePreview.shared.clear() }
        }
    }
}
