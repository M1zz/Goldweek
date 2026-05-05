//
//  Extensions.swift
//  Goldweek
//
//  유틸리티 확장
//

import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    
    /// 한국어 날짜 포맷
    var koreanFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: self)
    }
    
    /// 짧은 날짜 포맷
    var shortFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: self)
    }
    
    /// 해당 날짜의 시작 (00:00:00)
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// 해당 날짜의 끝 (23:59:59)
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    /// 해당 월의 첫 날
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    /// 해당 월의 마지막 날
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth) ?? self
    }
    
    /// 주말 여부
    var isWeekend: Bool {
        let weekday = Calendar.current.component(.weekday, from: self)
        return weekday == 1 || weekday == 7
    }
    
    /// 해당 계절
    var season: Season {
        let month = Calendar.current.component(.month, from: self)
        switch month {
        case 3, 4, 5: return .spring
        case 6, 7, 8: return .summer
        case 9, 10, 11: return .fall
        default: return .winter
        }
    }
}

// MARK: - Calendar Extensions

extension Calendar {
    
    /// 두 날짜 사이의 평일 수 계산
    func countWeekdays(from start: Date, to end: Date) -> Int {
        var count = 0
        var current = start
        
        while current <= end {
            if !current.isWeekend {
                count += 1
            }
            current = date(byAdding: .day, value: 1, to: current) ?? current
        }
        
        return count
    }
    
    /// 두 날짜 사이의 모든 날짜 배열
    func dates(from start: Date, to end: Date) -> [Date] {
        var dates: [Date] = []
        var current = start
        
        while current <= end {
            dates.append(current)
            current = date(byAdding: .day, value: 1, to: current) ?? current
        }
        
        return dates
    }
}

// MARK: - Color Extensions

extension Color {
    
    /// 앱 테마 색상
    static let appPrimary = Color.blue
    static let appSecondary = Color.cyan
    static let appAccent = Color.orange
    
    /// 상태 색상
    static let statusPlanned = Color.blue
    static let statusUsed = Color.green
    static let statusCancelled = Color.gray
    
    /// 그라데이션
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [.appPrimary, .appSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - View Extensions

extension View {
    
    /// 카드 스타일 적용
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    /// 조건부 modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Double Extensions

extension Double {
    
    /// 연차 일수 포맷
    var leaveFormatted: String {
        if self == floor(self) {
            return String(format: "%.0f일", self)
        } else {
            return String(format: "%.1f일", self)
        }
    }
}

// MARK: - String Extensions

extension String {
    
    /// 빈 문자열 확인 후 기본값 반환
    func ifEmpty(_ defaultValue: String) -> String {
        isEmpty ? defaultValue : self
    }
}

// MARK: - Array Extensions

extension Array where Element == LeaveRecord {
    
    /// 특정 상태의 레코드만 필터링
    func filtered(by status: LeaveStatus) -> [LeaveRecord] {
        filter { $0.status == status }
    }
    
    /// 특정 기간 내 레코드 필터링
    func filtered(from start: Date, to end: Date) -> [LeaveRecord] {
        filter { $0.startDate >= start && $0.endDate <= end }
    }
    
    /// 총 사용 일수 계산
    var totalDays: Double {
        reduce(0) { $0 + ($1.type == .half ? 0.5 : Double($1.daysCount)) }
    }
}

// MARK: - Leave Days Formatting

/// 연차 일수를 정확하게 표시 (%.1f의 0.25→0.2 뱅커스 라운딩 버그 방지)
/// 1.0 → "1",  0.5 → "0.5",  0.25 → "0.25",  1.25 → "1.25"
func formatLeave(_ value: Double) -> String {
    if value == Double(Int(value)) { return "\(Int(value))" }
    if value.truncatingRemainder(dividingBy: 0.5) == 0 { return String(format: "%.1f", value) }
    return String(format: "%.2f", value)
}

// MARK: - Notification Names

extension Notification.Name {
    static let leaveRecordUpdated = Notification.Name("leaveRecordUpdated")
    static let profileUpdated = Notification.Name("profileUpdated")
    static let recommendationsUpdated = Notification.Name("recommendationsUpdated")
}
