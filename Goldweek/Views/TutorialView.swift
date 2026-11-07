//
//  TutorialView.swift
//  Goldweek
//
//  "이 앱을 어떻게 쓰는가"를 한 번에 보여주는 사용법 시트.
//
//  온보딩(첫 실행)과 역할이 다르다 —
//   · 온보딩: 이 앱이 **무엇을 해 주는지** 설득하고 연차 일수를 받아 온다. 한 번만 본다.
//   · 튜토리얼: **어디를 눌러야 하는지** 알려 준다. 설정에서 언제든 다시 열 수 있다.
//  그래서 온보딩을 늘리는 대신 이 화면을 따로 뒀다. 처음 온보딩을 마친 직후 한 번 자동으로 뜨고,
//  그 뒤로는 설정 > 도움말에서 사용자가 원할 때만 열린다.
//

import SwiftUI
import GoldweekCore

struct TutorialView: View {
    /// 페이지 그림 크기 — 글자 크기 설정을 따라 커진다
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 56
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    /// 한 페이지 = 기능 하나. 순서는 사람이 실제로 밟는 순서다(등록 → 가져오기 → 추천 → 보너스 → 공유 → 위젯).
    /// id 는 그림 이름으로 고정한다 — `pages` 는 그릴 때마다 새로 만들어지므로 UUID() 를 쓰면
    /// 페이지를 넘길 때마다 모든 페이지가 새 것으로 바뀌어 미끄러지는 애니메이션 없이 휙 넘어간다.
    private struct Page: Identifiable {
        var id: String { icon }
        let icon: String
        let tint: Color
        let title: String
        let message: String
    }

    private var pages: [Page] {
        let add = Page(icon: "plus.circle.fill", tint: AppTheme.Colors.brand,
                       title: Strings.tutorialAddTitle, message: Strings.tutorialAddMessage)
        let recommend = Page(icon: "sparkles", tint: AppTheme.Colors.bonus,
                             title: Strings.tutorialRecommendTitle, message: Strings.tutorialRecommendMessage)
        // 처음 쓰는 사람에게는 화면에 있는 것만 알려 준다
        if AppSurface.shared.isSimple { return [add, recommend] }
        return [
            add,
            Page(icon: "doc.text.viewfinder", tint: .blue,
                 title: Strings.tutorialPhotoTitle, message: Strings.tutorialPhotoMessage),
            recommend,
            Page(icon: "gift.fill", tint: AppTheme.Colors.bonus,
                 title: Strings.tutorialBonusTitle, message: Strings.tutorialBonusMessage),
            Page(icon: "person.2.fill", tint: .green,
                 title: Strings.tutorialShareTitle, message: Strings.tutorialShareMessage),
            Page(icon: "square.grid.2x2.fill", tint: .purple,
                 title: Strings.tutorialWidgetTitle, message: Strings.tutorialWidgetMessage),
        ]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        pageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // 진행 점 — 몇 장 남았는지 보여야 끝까지 넘긴다
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? AppTheme.Colors.brand : Color(.systemGray4))
                            .frame(width: index == currentPage ? 20 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                .accessibilityHidden(true)

                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation(.smooth(duration: 0.45)) { currentPage += 1 }
                    } else {
                        dismiss()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? Strings.next : Strings.tutorialDone)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 52)
                        .background(AppTheme.Colors.brand)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .navigationTitle(Strings.tutorialTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Strings.tutorialSkip) { dismiss() }
                }
            }
        }
    }

    private func pageView(_ page: Page) -> some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .fill(page.tint.opacity(0.12))
                    .frame(width: iconSize * 132 / 56, height: iconSize * 132 / 56)
                Image(systemName: page.icon)
                    .font(.system(size: iconSize))
                    .foregroundStyle(page.tint)
            }
            .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text(page.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(page.title), \(page.message)")
    }
}

#Preview {
    TutorialView()
}
