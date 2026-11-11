//
//  AppTheme.swift
//  Goldweek
//
//  앱 테마 및 시맨틱 컬러 정의
//

import SwiftUI
import GoldweekCore

// MARK: - 앱 컬러 테마
struct AppTheme {
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

/// 앱의 모든 카드 바탕 — 위에서 빛이 비치는 한 장의 판처럼 보이게 한다.
/// - 테두리: 윗변이 밝고 아랫변이 어둡다(빛을 받는 모서리). 머리카락 굵기.
/// - 그림자: 바로 밑의 짧은 접지 그림자 + 넓고 옅은 공기 그림자 두 겹. 글자에는 그림자를 주지 않는다(바탕에만).
/// - 어두운 모드: 검은 바탕에서 그림자는 보이지 않으므로 윗부분을 살짝 밝혀 떠 있는 느낌을 낸다.
/// `accent` 를 주면 테두리를 그 색으로 — 경고처럼 눈에 띄어야 하는 카드.
struct CardSurface: ViewModifier {
    var accent: Color?
    @Environment(\.displayScale) private var displayScale
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
        let dark = colorScheme == .dark
        content
            .background {
                shape
                    .fill(Color(.secondarySystemGroupedBackground))
                    .overlay {
                        // 윗부분의 은은한 빛 — 어두운 모드에서만 (밝은 모드 흰 카드는 이미 밝다)
                        if dark {
                            shape.fill(LinearGradient(colors: [.white.opacity(0.06), .clear],
                                                      startPoint: .top, endPoint: .center))
                        }
                    }
                    .shadow(color: .black.opacity(dark ? 0.5 : 0.06), radius: 1, y: 1)
                    .shadow(color: .black.opacity(dark ? 0.6 : 0.08), radius: 16, y: 8)
            }
            .overlay {
                shape.strokeBorder(edge(dark: dark), lineWidth: accent == nil ? 1 / displayScale : 1)
            }
    }

    /// 빛을 받는 윗변은 밝게, 아랫변은 어둡게
    private func edge(dark: Bool) -> LinearGradient {
        let colors: [Color]
        if let accent {
            colors = [accent.opacity(0.6), accent.opacity(0.25)]
        } else if dark {
            colors = [.white.opacity(0.18), .white.opacity(0.04)]
        } else {
            colors = [.black.opacity(0.04), .black.opacity(0.12)]
        }
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
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
// Vision Pro 에는 진동이 없다 — 빈 함수로 둔다.
struct HapticFeedback {
    static func success() {
        #if !os(visionOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    static func error() {
        #if !os(visionOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }

    static func selection() {
        #if !os(visionOS)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }
}
