//
//  OnboardingView.swift
//  LeaveWise
//
//  온보딩 화면 - 앱 첫 실행 시 표시
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isOnboardingComplete: Bool

    @State private var currentPage = 0
    @State private var userName = ""
    @State private var totalLeave: Double = 15
    @State private var yearStartMonth = 1

    private let blueColor = Color(red: 0.0, green: 0.4, blue: 0.9)
    private let greenColor = Color(red: 0.15, green: 0.68, blue: 0.38)

    var body: some View {
        VStack(spacing: 0) {
            // 페이지 인디케이터
            HStack(spacing: 8) {
                ForEach(0..<4) { index in
                    Circle()
                        .fill(currentPage == index ? blueColor : Color(.systemGray4))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 20)

            TabView(selection: $currentPage) {
                // 페이지 1: 환영
                WelcomePage()
                    .tag(0)

                // 페이지 2: 기능 소개
                FeaturesPage()
                    .tag(1)

                // 페이지 3: 이름 입력
                NameInputPage(userName: $userName)
                    .tag(2)

                // 페이지 4: 연차 설정
                LeaveSetupPage(
                    totalLeave: $totalLeave,
                    yearStartMonth: $yearStartMonth,
                    onComplete: completeOnboarding
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // 하단 버튼
            if currentPage < 3 {
                Button {
                    withAnimation {
                        currentPage += 1
                    }
                } label: {
                    Text(currentPage == 0 ? "시작하기" : "다음")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(blueColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private func completeOnboarding() {
        let profile = UserProfile(
            name: userName.isEmpty ? "사용자" : userName,
            yearStartMonth: yearStartMonth,
            totalAnnualLeave: totalLeave,
            usedLeave: 0
        )
        modelContext.insert(profile)
        try? modelContext.save()

        withAnimation {
            isOnboardingComplete = true
        }
    }
}

// MARK: - 환영 페이지
struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 80))
                .foregroundStyle(Color(red: 0.0, green: 0.4, blue: 0.9))
                .padding(.bottom, 20)

            Text("휴가캘린더")
                .font(.largeTitle.bold())

            Text("연차를 똑똑하게 관리하고\n최적의 휴가 일정을 추천받으세요")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - 기능 소개 페이지
struct FeaturesPage: View {
    private let features = [
        ("calendar.badge.plus", "연차 관리", "연차, 반차, 대체휴무 등\n다양한 휴가를 기록하세요"),
        ("sparkles", "AI 추천", "공휴일과 주말을 활용한\n최적의 휴가 조합을 추천"),
        ("gift.fill", "보너스 연차", "대체휴무, 포상휴가 등\n추가 연차도 관리"),
        ("apps.iphone", "위젯", "홈 화면에서 바로\n남은 연차 확인")
    ]

    var body: some View {
        VStack(spacing: 32) {
            Text("주요 기능")
                .font(.title.bold())
                .padding(.top, 40)

            VStack(spacing: 20) {
                ForEach(features, id: \.1) { icon, title, description in
                    FeatureRow(icon: icon, title: title, description: description)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(Color(red: 0.0, green: 0.4, blue: 0.9))
                .frame(width: 50, height: 50)
                .background(Color(red: 0.0, green: 0.4, blue: 0.9).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 이름 입력 페이지
struct NameInputPage: View {
    @Binding var userName: String
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color(red: 0.0, green: 0.4, blue: 0.9))

            VStack(spacing: 8) {
                Text("이름을 알려주세요")
                    .font(.title.bold())
                Text("앱에서 사용할 이름을 입력해주세요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TextField("이름", text: $userName)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .focused($isFocused)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
        .onAppear {
            isFocused = true
        }
    }
}

// MARK: - 연차 설정 페이지
struct LeaveSetupPage: View {
    @Binding var totalLeave: Double
    @Binding var yearStartMonth: Int
    let onComplete: () -> Void

    private let blueColor = Color(red: 0.0, green: 0.4, blue: 0.9)

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("연차 정보 설정")
                    .font(.title.bold())
                Text("나중에 설정에서 변경할 수 있어요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)

            VStack(spacing: 20) {
                // 총 연차
                VStack(alignment: .leading, spacing: 12) {
                    Text("올해 총 연차")
                        .font(.headline)

                    HStack {
                        Text("\(Int(totalLeave))일")
                            .font(.title.bold())
                            .foregroundStyle(blueColor)

                        Spacer()

                        Stepper("", value: $totalLeave, in: 1...30, step: 1)
                            .labelsHidden()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // 연차 기준월
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("연차 기준월")
                            .font(.headline)
                        Spacer()
                        Text("\(yearStartMonth)월")
                            .font(.title2.bold())
                            .foregroundStyle(blueColor)
                    }

                    Text("연차가 갱신되는 시작 월")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Picker("기준월", selection: $yearStartMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text("\(month)").tag(month)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Spacer()

            // 완료 버튼
            Button(action: onComplete) {
                Text("시작하기")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(blueColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
