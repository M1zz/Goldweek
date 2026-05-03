//
//  Models.swift
//  LeaveWise
//
//  데이터 모델 정의
//

import Foundation
import SwiftData

// MARK: - 국가
enum Country: String, CaseIterable, Identifiable, Codable {
    case korea = "korea"
    case japan = "japan"
    case china = "china"
    case usa = "usa"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .korea: return "한국"
        case .japan: return "日本"
        case .china: return "中国"
        case .usa: return "USA"
        }
    }

    var flag: String {
        switch self {
        case .korea: return "🇰🇷"
        case .japan: return "🇯🇵"
        case .china: return "🇨🇳"
        case .usa: return "🇺🇸"
        }
    }

    var localeIdentifier: String {
        switch self {
        case .korea: return "ko_KR"
        case .japan: return "ja_JP"
        case .china: return "zh_CN"
        case .usa: return "en_US"
        }
    }

    static func fromDeviceLocale() -> Country {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        switch lang {
        case "ko": return .korea
        case "ja": return .japan
        case "zh": return .china
        default: return .usa
        }
    }
}

// MARK: - 사용자 유형

enum UserType: String, Codable, CaseIterable, Identifiable {
    case employee = "employee"   // 직장인 — 연차 관리
    case leisure = "leisure"     // 자유 계획 — 연차 없이 휴가 플래닝

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .employee: return "직장인"
        case .leisure: return "자유 계획"
        }
    }

    var icon: String {
        switch self {
        case .employee: return "briefcase"
        case .leisure: return "beach.umbrella"
        }
    }
}

// MARK: - 사용자 프로필
@Model
final class UserProfile {
    var id: UUID
    var name: String
    var yearStartMonth: Int              // 연차 기준 시작월 (1-12)
    var totalAnnualLeave: Double         // 총 연차 / 연간 목표 일수
    var usedLeave: Double                // 사용한 연차 (레거시 — records가 source of truth)
    var createdAt: Date
    var countryRaw: String               // 국가 코드
    var userTypeRaw: String = UserType.employee.rawValue  // 사용자 유형

    // 선호도 설정
    var preferredDurationRaw: String
    var preferredSeasonsRaw: String      // 쉼표로 구분된 문자열
    var preferLongWeekend: Bool
    var preferConsecutive: Bool
    var avoidPeakSeason: Bool
    var priorityActivitiesRaw: String    // 쉼표로 구분된 문자열

    init(
        name: String = "",
        yearStartMonth: Int = 1,
        totalAnnualLeave: Double = 15,
        usedLeave: Double = 0,
        country: Country = .korea,
        userType: UserType = .employee
    ) {
        self.id = UUID()
        self.name = name
        self.yearStartMonth = yearStartMonth
        self.totalAnnualLeave = totalAnnualLeave
        self.usedLeave = usedLeave
        self.createdAt = Date()
        self.countryRaw = country.rawValue
        self.userTypeRaw = userType.rawValue
        self.preferredDurationRaw = PreferredDuration.mixed.rawValue
        self.preferredSeasonsRaw = ""
        self.preferLongWeekend = true
        self.preferConsecutive = false
        self.avoidPeakSeason = false
        self.priorityActivitiesRaw = ""
    }
    
    var remainingLeave: Double {
        totalAnnualLeave - usedLeave
    }

    var country: Country {
        get { Country(rawValue: countryRaw) ?? .korea }
        set { countryRaw = newValue.rawValue }
    }

    var userType: UserType {
        get { UserType(rawValue: userTypeRaw) ?? .employee }
        set { userTypeRaw = newValue.rawValue }
    }

    var preferredDuration: PreferredDuration {
        get { PreferredDuration(rawValue: preferredDurationRaw) ?? .mixed }
        set { preferredDurationRaw = newValue.rawValue }
    }
    
    var preferredSeasons: [Season] {
        get {
            preferredSeasonsRaw.split(separator: ",")
                .compactMap { Season(rawValue: String($0)) }
        }
        set {
            preferredSeasonsRaw = newValue.map { $0.rawValue }.joined(separator: ",")
        }
    }
    
    var priorityActivities: [ActivityType] {
        get {
            priorityActivitiesRaw.split(separator: ",")
                .compactMap { ActivityType(rawValue: String($0)) }
        }
        set {
            priorityActivitiesRaw = newValue.map { $0.rawValue }.joined(separator: ",")
        }
    }
}

// MARK: - 연차 기록
@Model
final class LeaveRecord {
    var id: UUID
    var startDate: Date
    var endDate: Date
    var typeRaw: String
    var statusRaw: String
    var note: String
    var isRecommended: Bool
    /// 보너스 연차 사용 시 연결된 BonusLeave.id (일반 연차는 nil)
    var bonusLeaveId: UUID?

    init(
        startDate: Date,
        endDate: Date,
        type: LeaveType = .annual,
        status: LeaveStatus = .planned,
        note: String = "",
        isRecommended: Bool = false,
        bonusLeaveId: UUID? = nil
    ) {
        self.id = UUID()
        self.startDate = startDate
        self.endDate = endDate
        self.typeRaw = type.rawValue
        self.statusRaw = status.rawValue
        self.bonusLeaveId = bonusLeaveId
        self.note = note
        self.isRecommended = isRecommended
    }
    
    var type: LeaveType {
        get { LeaveType(rawValue: typeRaw) ?? .annual }
        set { typeRaw = newValue.rawValue }
    }
    
    var status: LeaveStatus {
        get { LeaveStatus(rawValue: statusRaw) ?? .planned }
        set { statusRaw = newValue.rawValue }
    }
    
    var daysCount: Int {
        let components = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }

    /// 연차 차감 일수 (반차 0.5, 반반차 0.25, 그 외 달력 일수)
    var effectiveLeaveDays: Double {
        switch type {
        case .half: return 0.5
        case .quarter: return 0.25
        default:
            let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
            return Double(days + 1)
        }
    }

    /// 실제 연차 차감 여부 — bonusLeaveId가 있으면 보너스 차감이므로 연차 차감 아님
    var deductsFromAnnualLeave: Bool {
        type.deductsFromAnnual && bonusLeaveId == nil
    }
}

// MARK: - 열거형 정의
enum PreferredDuration: String, Codable, CaseIterable, Identifiable {
    case short = "1-2일"
    case medium = "3-4일"
    case long = "5일 이상"
    case mixed = "혼합"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .short: return "⚡"
        case .medium: return "🌴"
        case .long: return "✈️"
        case .mixed: return "🎲"
        }
    }
}

enum Season: String, Codable, CaseIterable, Identifiable {
    case spring = "봄"
    case summer = "여름"
    case fall = "가을"
    case winter = "겨울"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .spring: return "🌸"
        case .summer: return "🌻"
        case .fall: return "🍂"
        case .winter: return "❄️"
        }
    }
    
    var months: [Int] {
        switch self {
        case .spring: return [3, 4, 5]
        case .summer: return [6, 7, 8]
        case .fall: return [9, 10, 11]
        case .winter: return [12, 1, 2]
        }
    }
}

enum ActivityType: String, Codable, CaseIterable, Identifiable {
    case travel = "여행"
    case rest = "휴식"
    case family = "가족시간"
    case hobby = "취미활동"
    case selfCare = "자기계발"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .travel: return "✈️"
        case .rest: return "🛋️"
        case .family: return "👨‍👩‍👧"
        case .hobby: return "🎨"
        case .selfCare: return "📚"
        }
    }
}

enum LeaveType: String, Codable, CaseIterable, Identifiable {
    case annual = "연차"
    case half = "반차"
    case quarter = "반반차"
    case compensatory = "대체휴무"
    case official = "공가"
    case sick = "병가"
    case special = "특별휴가"
    case businessTrip = "출장"

    var id: String { rawValue }

    /// 연차 차감 여부 (true면 연차에서 차감)
    var deductsFromAnnual: Bool {
        switch self {
        case .annual, .half, .quarter: return true
        case .compensatory, .official, .sick, .special, .businessTrip: return false
        }
    }

    var leaveValue: Double {
        switch self {
        case .annual: return 1.0
        case .half: return 0.5
        case .quarter: return 0.25
        case .compensatory, .official, .sick, .special, .businessTrip: return 0.0
        }
    }

    var icon: String {
        switch self {
        case .annual: return "calendar"
        case .half: return "calendar.badge.clock"
        case .quarter: return "clock"
        case .compensatory: return "arrow.triangle.2.circlepath"
        case .official: return "building.2"
        case .sick: return "cross.case"
        case .special: return "star"
        case .businessTrip: return "briefcase"
        }
    }

    var color: String {
        switch self {
        case .annual: return "blue"
        case .half: return "cyan"
        case .quarter: return "teal"
        case .compensatory: return "orange"
        case .official: return "purple"
        case .sick: return "red"
        case .special: return "yellow"
        case .businessTrip: return "brown"
        }
    }
}

enum LeaveStatus: String, Codable, CaseIterable, Identifiable {
    case planned = "예정"
    case used = "사용완료"
    case cancelled = "취소"
    
    var id: String { rawValue }
    
    var color: String {
        switch self {
        case .planned: return "blue"
        case .used: return "green"
        case .cancelled: return "gray"
        }
    }
}

// MARK: - 추천 결과 (비영구 모델)
struct LeaveRecommendation: Identifiable {
    let id: UUID
    var title: String
    var description: String
    var startDate: Date
    var endDate: Date
    var requiredLeaveDays: Double
    var totalDaysOff: Int
    var efficiency: Double
    var matchScore: Double
    var tags: [String]
    var reason: String
    
    init(
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        requiredLeaveDays: Double,
        totalDaysOff: Int,
        tags: [String] = [],
        reason: String = ""
    ) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.requiredLeaveDays = requiredLeaveDays
        self.totalDaysOff = totalDaysOff
        self.efficiency = Double(totalDaysOff) / max(requiredLeaveDays, 1)
        self.matchScore = 0.0
        self.tags = tags
        self.reason = reason
    }
    
    var efficiencyStars: String {
        let stars = min(5, Int(efficiency))
        return String(repeating: "⭐", count: stars)
    }
}

// MARK: - 보너스 연차 (대체휴무, 포상휴가 등으로 받은 추가 연차)
@Model
final class BonusLeave {
    var id: UUID
    var days: Double                     // 최초 부여 일수 (절대 변경하지 않음)
    var usedDays: Double = 0             // 사용된 일수 (증가만 함)
    var typeRaw: String                  // 보너스 유형
    var reason: String                   // 사유
    var grantedDate: Date                // 부여 날짜
    var expirationDate: Date?            // 만료일 (없으면 연말까지)
    var isUsed: Bool                     // 완전 소진 여부

    /// 잔여 일수 (부여 - 사용)
    var remainingDays: Double {
        max(0, days - usedDays)
    }

    init(
        days: Double,
        type: BonusLeaveType,
        reason: String = "",
        grantedDate: Date = Date(),
        expirationDate: Date? = nil
    ) {
        self.id = UUID()
        self.days = days
        self.usedDays = 0
        self.typeRaw = type.rawValue
        self.reason = reason
        self.grantedDate = grantedDate
        self.expirationDate = expirationDate
        self.isUsed = false
    }

    var type: BonusLeaveType {
        get { BonusLeaveType(rawValue: typeRaw) ?? .other }
        set { typeRaw = newValue.rawValue }
    }
}

enum BonusLeaveType: String, Codable, CaseIterable, Identifiable {
    case compensatory = "대체휴무"       // 휴일 근무 대체
    case reward = "포상휴가"            // 성과 포상
    case refresh = "리프레시휴가"        // 장기근속 등
    case marriage = "결혼"              // 본인/자녀 결혼
    case bereavement = "사망"           // 조의 휴가
    case sick = "병가"                  // 병가
    case maternity = "임신/출산"         // 임신, 출산, 육아
    case familyBalance = "일가정균형"    // 가족돌봄 등
    case official = "공가"              // 공적 업무
    case other = "기타"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .compensatory: return "arrow.triangle.2.circlepath"
        case .reward: return "gift"
        case .refresh: return "sparkles"
        case .marriage: return "heart.fill"
        case .bereavement: return "leaf.fill"
        case .sick: return "cross.case.fill"
        case .maternity: return "figure.and.child.holdinghands"
        case .familyBalance: return "house.and.flag.fill"
        case .official: return "building.2.fill"
        case .other: return "plus.circle"
        }
    }
}

// MARK: - 공휴일
struct Holiday: Identifiable {
    let id: UUID = UUID()
    let date: Date
    let name: String
    let isSubstitute: Bool
    let isCustom: Bool

    init(date: Date, name: String, isSubstitute: Bool = false, isCustom: Bool = false) {
        self.date = date
        self.name = name
        self.isSubstitute = isSubstitute
        self.isCustom = isCustom
    }
}

// MARK: - 사용자 정의 공휴일
@Model
class CustomHoliday {
    var id: UUID
    var date: Date
    var name: String
    var createdAt: Date

    init(date: Date, name: String) {
        self.id = UUID()
        self.date = date
        self.name = name
        self.createdAt = Date()
    }
}
