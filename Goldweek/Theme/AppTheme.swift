//
//  AppTheme.swift
//  Goldweek
//
//  앱 테마 및 시맨틱 컬러 정의
//

import SwiftUI

// MARK: - 앱 컬러 테마
struct AppTheme {
    // MARK: - Primary Colors
    static let primary = Color("PrimaryColor", bundle: nil)
    static let secondary = Color("SecondaryColor", bundle: nil)

    // MARK: - Semantic Colors (다크모드 자동 대응)
    struct Colors {
        // 브랜드 컬러
        static var brand: Color {
            Color(light: Color(red: 0.0, green: 0.4, blue: 0.9),
                  dark: Color(red: 0.3, green: 0.6, blue: 1.0))
        }

        // 연차 유형별 컬러
        static var annual: Color {
            Color(light: Color(red: 0.0, green: 0.4, blue: 0.9),
                  dark: Color(red: 0.4, green: 0.65, blue: 1.0))
        }

        static var half: Color {
            Color(light: Color(red: 0.0, green: 0.6, blue: 0.8),
                  dark: Color(red: 0.3, green: 0.7, blue: 0.9))
        }

        static var quarter: Color {
            Color(light: Color(red: 0.0, green: 0.55, blue: 0.55),
                  dark: Color(red: 0.2, green: 0.7, blue: 0.7))
        }

        static var compensatory: Color {
            Color(light: Color(red: 0.95, green: 0.5, blue: 0.0),
                  dark: Color(red: 1.0, green: 0.6, blue: 0.2))
        }

        static var official: Color {
            Color(light: Color(red: 0.6, green: 0.2, blue: 0.8),
                  dark: Color(red: 0.75, green: 0.45, blue: 0.95))
        }

        static var sick: Color {
            Color(light: Color(red: 0.9, green: 0.2, blue: 0.2),
                  dark: Color(red: 1.0, green: 0.4, blue: 0.4))
        }

        static var special: Color {
            Color(light: Color(red: 0.85, green: 0.6, blue: 0.0),
                  dark: Color(red: 1.0, green: 0.75, blue: 0.2))
        }

        // 상태 컬러
        static var success: Color {
            Color(light: Color(red: 0.15, green: 0.68, blue: 0.38),
                  dark: Color(red: 0.3, green: 0.8, blue: 0.5))
        }

        static var warning: Color {
            Color(light: Color(red: 0.95, green: 0.6, blue: 0.0),
                  dark: Color(red: 1.0, green: 0.7, blue: 0.2))
        }

        static var error: Color {
            Color(light: Color(red: 0.9, green: 0.2, blue: 0.2),
                  dark: Color(red: 1.0, green: 0.4, blue: 0.4))
        }

        // 휴일/연차 표시 컬러
        static var holiday: Color {
            Color(light: Color(red: 0.9, green: 0.2, blue: 0.2),
                  dark: Color(red: 1.0, green: 0.4, blue: 0.4))
        }

        static var leave: Color {
            Color(light: Color(red: 0.15, green: 0.68, blue: 0.38),
                  dark: Color(red: 0.3, green: 0.8, blue: 0.5))
        }

        static var weekend: Color {
            Color(light: Color(red: 0.0, green: 0.4, blue: 0.9),
                  dark: Color(red: 0.4, green: 0.65, blue: 1.0))
        }

        // 보너스 연차 전용 시맨틱 컬러 (모든 탭 통일)
        static var bonus: Color {
            Color(light: Color(red: 1.0, green: 0.45, blue: 0.0),
                  dark: Color(red: 1.0, green: 0.62, blue: 0.22))
        }
    }
}

// MARK: - 카드 표면

/// 모서리는 두 단계뿐이다 — 카드, 그리고 카드 안의 칸·버튼. 둘 다 연속 곡률(.continuous)이라 모서리가 매끈하다.
enum AppRadius {
    static let card: CGFloat = 20
    static let inner: CGFloat = 12
}

/// 앱의 모든 카드 바탕. 그림자 대신 머리카락 굵기 테두리로 떼어 놓는다 —
/// 그림자는 어두운 모드에서 보이지 않아 카드가 바탕에 녹고, 밝은 모드에서는 화면을 탁하게 한다.
/// `accent` 를 주면 테두리만 그 색으로 — 경고처럼 눈에 띄어야 하는 카드.
struct CardSurface: ViewModifier {
    var accent: Color?
    @Environment(\.displayScale) private var displayScale

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
        content
            .background(Color(.secondarySystemGroupedBackground), in: shape)
            .overlay {
                shape.strokeBorder(accent?.opacity(0.45) ?? Color.primary.opacity(0.09),
                                   lineWidth: accent == nil ? 1 / displayScale : 1)
            }
    }
}

extension View {
    func cardSurface(accent: Color? = nil) -> some View {
        modifier(CardSurface(accent: accent))
    }

    /// 카드 안의 칸 · 숫자 알약 — 카드보다 한 단계 짙은 바탕
    func innerSurface() -> some View {
        background(Color(.tertiarySystemGroupedBackground),
                   in: RoundedRectangle(cornerRadius: AppRadius.inner, style: .continuous))
    }
}

// MARK: - Color Extension for Light/Dark Mode
extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - LeaveType Color Extension
extension LeaveType {
    var themeColor: Color {
        switch self {
        case .annual: return AppTheme.Colors.annual
        case .half: return AppTheme.Colors.half
        case .quarter: return AppTheme.Colors.quarter
        case .compensatory: return AppTheme.Colors.compensatory
        case .official: return AppTheme.Colors.official
        case .sick: return AppTheme.Colors.sick
        case .special: return AppTheme.Colors.special
        case .businessTrip: return Color.brown
        }
    }
}

// MARK: - LeaveStatus Color Extension
extension LeaveStatus {
    var themeColor: Color {
        switch self {
        case .planned: return AppTheme.Colors.brand
        case .used: return AppTheme.Colors.success
        case .cancelled: return Color.secondary
        }
    }
}

// MARK: - Haptic Feedback Helper
struct HapticFeedback {
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
