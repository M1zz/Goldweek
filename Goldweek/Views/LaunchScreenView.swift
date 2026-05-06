//
//  LaunchScreenView.swift
//  Goldweek
//
//  런치 스크린 (앱 시작 화면)
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.35, blue: 0.85),
                    Color(red: 0.0, green: 0.5, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // 앱 아이콘
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 50, weight: .medium))
                        .foregroundStyle(.white)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.7)
                }

                // 앱 이름
                Text(Strings.launchTitle)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                // 슬로건
                Text(Strings.launchSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
