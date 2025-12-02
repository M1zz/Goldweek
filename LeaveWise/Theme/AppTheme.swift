//
//  AppTheme.swift
//  LeaveWise
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
