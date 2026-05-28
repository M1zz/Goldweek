//
//  Components.swift
//  Goldweek
//
//  공통 UI 컴포넌트
//

import SwiftUI

// MARK: - 카드 컨테이너
struct CardContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - 그라데이션 버튼
struct GradientButton: View {
    let title: String
    let icon: String?
    let colors: [Color]
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        colors: [Color] = [.blue, .cyan],
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.colors = colors
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: colors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - 정보 배지
struct InfoBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

// MARK: - 섹션 헤더
struct SectionHeader: View {
    let title: String
    let icon: String?
    
    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Text(icon)
            }
            Text(title)
                .font(.headline)
            Spacer()
        }
    }
}

// MARK: - 빈 상태 뷰
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(.largeTitle))
                .foregroundStyle(.secondary)
                .voDecorative()
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
            }
        }
        .padding(40)
    }
}

// MARK: - 로딩 뷰
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(40)
    }
}

// MARK: - 프로그레스 바
struct ProgressBar: View {
    let progress: Double
    let height: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    
    init(
        progress: Double,
        height: CGFloat = 8,
        backgroundColor: Color = Color.gray.opacity(0.2),
        foregroundColor: Color = .blue
    ) {
        self.progress = progress
        self.height = height
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: height)
    }
}

// MARK: - 날짜 범위 표시
struct DateRangeLabel: View {
    let startDate: Date
    let endDate: Date
    
    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: Strings.localeIdentifier)
        f.dateFormat = Strings.dateRangeFormat
        return f
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(formatter.string(from: startDate))
            
            if !Calendar.current.isDate(startDate, inSameDayAs: endDate) {
                Text("-")
                Text(formatter.string(from: endDate))
            }
        }
        .font(.subheadline)
    }
}

// MARK: - D-Day 라벨
struct DDayLabel: View {
    let targetDate: Date
    
    private var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
    }
    
    var body: some View {
        Text(daysRemaining == 0 ? "D-Day" : (daysRemaining > 0 ? "D-\(daysRemaining)" : "D+\(abs(daysRemaining))"))
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(daysRemaining <= 0 ? Color.red : Color.blue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 20) {
        CardContainer {
            VStack {
                Text("카드 컨텐츠")
                Text("여기에 내용이 들어갑니다")
            }
        }
        
        GradientButton(title: "시작하기", icon: "arrow.right") {
            print("Tapped")
        }
        .padding(.horizontal)
        
        HStack {
            InfoBadge(text: "연차", color: .blue)
            InfoBadge(text: "예정", color: .green)
            InfoBadge(text: "취소됨", color: .gray)
        }
        
        ProgressBar(progress: 0.6)
            .padding(.horizontal)
        
        DateRangeLabel(
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        )
        
        DDayLabel(targetDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!)
    }
    .padding()
}
