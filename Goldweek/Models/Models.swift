//
//  Models.swift
//  Goldweek
//
//  데이터 모델 정의
//

import Foundation
import SwiftData
import GoldweekCore


// MARK: - 대륙 (국가 선택 대분류)



// MARK: - 공휴일 지역 (주·자치주·주/준주)


// MARK: - 사용자 유형


// MARK: - 사용자 프로필
@Model
final class UserProfile {
    var id: UUID
    var name: String
    var yearStartMonth: Int              // 연차 기준 시작월 (1-12)
    /// 연차 기준일의 '일' (1-31) — 입사일 기준이라 3월 21일에 새로 생기는 회사. 기본 1일.
    var yearStartDay: Int = 1
    var totalAnnualLeave: Double         // 총 연차 / 연간 목표 일수
    var usedLeave: Double                // 사용한 연차 (레거시 — records가 source of truth)
    var createdAt: Date
    var countryRaw: String = Country.korea.rawValue   // 국가 코드 (default: SwiftData lightweight migration용)
    var userTypeRaw: String = UserType.employee.rawValue  // 사용자 유형
    /// 공휴일 지역 (ISO 3166-2, 예: "DE-BY"). 빈 문자열이면 전국 공통 공휴일만 쓴다.
    var holidayRegionRaw: String = ""
    /// 사는 곳 지역 — 일하는 곳(holidayRegionRaw)과 공휴일이 다를 때. 비면 없음.
    var homeRegionRaw: String = ""
    /// 함께 볼 공휴일의 나라 — 회사 본사가 다른 나라거나 다른 나라에 살 때. 비면 일하는 나라와 같다.
    var homeCountryRaw: String = ""

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

    /// 연차가 새로 생기는 날 — 계산은 모두 이걸 쓴다 (월만 넘기면 일이 1일로 굳는다).
    var yearStart: YearStart { YearStart(month: yearStartMonth, day: yearStartDay) }

    /// 화면에 보여줄 이름.
    ///
    /// 기본 이름("사용자")은 프로필을 만든 시점의 언어로 저장돼 굳는다. 나중에 앱 언어를 바꾸면
    /// 영어 화면에 그 이름만 한국어로 남아 언어가 섞여 보인다 → 안 바꾼 기본 이름이면 지금 언어로 보여준다.
    /// (사용자가 직접 지은 이름은 당연히 그대로 둔다.)
    var displayName: String {
        Strings.defaultUserNames.contains(name) ? Strings.defaultUser : name
    }

    var country: Country {
        get { Country(rawValue: countryRaw) ?? .korea }
        set {
            // 나라가 바뀌면 이전 나라의 지역은 의미가 없다.
            // 함께 볼 공휴일은 다른 나라 것이면 그대로 두고, 같은 나라 지역이거나 새 나라와 같아지면 지운다.
            if newValue.rawValue != countryRaw {
                holidayRegion = nil
                if homeCountry == nil || homeCountry == newValue { homeCountry = nil; homeRegion = nil }
            }
            countryRaw = newValue.rawValue
        }
    }

    /// 공휴일 지역. 나라와 맞지 않는 값은 없는 것으로 본다.
    /// 쓸 때 `HolidayService` 가 읽는 값도 같이 바꾼다 (HolidayService 는 프로필을 모른다).
    var holidayRegion: HolidayRegion? {
        get {
            guard let region = HolidayRegion.find(holidayRegionRaw), region.country == country else { return nil }
            return region
        }
        set {
            holidayRegionRaw = newValue?.code ?? ""
            HolidayService.selectedRegionCode = holidayRegionRaw
            // 일하는 곳과 같아지면 사는 곳은 따로 둘 이유가 없다
            if homeRegionRaw == holidayRegionRaw { homeRegion = nil }
        }
    }

    /// 함께 볼 공휴일의 나라 — 일하는 나라와 다를 때만 값이 있다 (같은 나라 다른 지역이면 nil + homeRegion)
    var homeCountry: Country? {
        get {
            guard let c = Country(rawValue: homeCountryRaw), c != country, c != .custom else { return nil }
            return c
        }
        set {
            homeCountryRaw = newValue?.rawValue ?? ""
            HolidayService.homeCountryCode = homeCountryRaw
        }
    }

    /// 함께 볼 공휴일의 지역 — 다른 나라면 그 나라의 지역(없으면 전국), 같은 나라면 일하는 곳과 다른 지역일 때만 의미가 있다.
    var homeRegion: HolidayRegion? {
        get {
            guard let region = HolidayRegion.find(homeRegionRaw), region.country == (homeCountry ?? country),
                  region.code != holidayRegionRaw else { return nil }
            return region
        }
        set {
            homeRegionRaw = newValue?.code ?? ""
            HolidayService.homeRegionCode = homeRegionRaw
        }
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
    /// 휴가 길이(종일/반차/반반차/시간). nil이면 레거시 기록으로, typeRaw의 반차/반반차에서 추론한다.
    var lengthRaw: String?
    /// 시간 단위 휴가의 길이(분) — length 가 .hours 일 때만 쓴다
    var durationMinutes: Int?
    /// 직접 만든 휴가 종류(CustomLeaveType.id) — 있으면 이름·색은 그 종류를 따른다.
    /// 연차 차감 여부는 typeRaw(.annual / .special)로 함께 저장해 기존 계산이 그대로 돈다.
    var customTypeId: UUID?
    /// 이 휴가를 잡을 때의 공휴일 데이터 버전(`HolidayOverrideStore.dataVersion`).
    /// 나중에 공휴일이 바뀌면 그 전에 잡은 계획을 가려낸다. 예전 기록은 nil(모름).
    var holidayDataVersion: String?

    init(
        startDate: Date,
        endDate: Date,
        type: LeaveType = .annual,
        status: LeaveStatus = .planned,
        note: String = "",
        isRecommended: Bool = false,
        length: LeaveLength? = nil,
        bonusLeaveId: UUID? = nil,
        durationMinutes: Int? = nil,
        customTypeId: UUID? = nil
    ) {
        self.id = UUID()
        self.durationMinutes = durationMinutes
        self.customTypeId = customTypeId
        self.startDate = startDate
        self.endDate = endDate
        self.typeRaw = type.rawValue
        self.statusRaw = status.rawValue
        self.bonusLeaveId = bonusLeaveId
        self.lengthRaw = length?.rawValue
        self.note = note
        self.isRecommended = isRecommended
        self.holidayDataVersion = HolidayOverrideStore.dataVersion
    }

    var type: LeaveType {
        get { LeaveType(rawValue: typeRaw) ?? .annual }
        set { typeRaw = newValue.rawValue }
    }

    /// 휴가 길이 — 신규 기록은 lengthRaw에 저장, 레거시(type이 반차/반반차) 기록은 유형에서 추론
    var length: LeaveLength {
        get {
            if let lengthRaw, let l = LeaveLength(rawValue: lengthRaw) { return l }
            switch type {
            case .half: return .half
            case .quarter: return .quarter
            default: return .full
            }
        }
        set { lengthRaw = newValue.rawValue }
    }

    /// 휴가 카테고리 — 레거시 반차/반반차는 연차 카테고리로 정규화 (길이는 length가 담당)
    var category: LeaveType {
        switch type {
        case .half, .quarter: return .annual
        default: return type
        }
    }

    var status: LeaveStatus {
        get { LeaveStatus(rawValue: statusRaw) ?? .planned }
        set { statusRaw = newValue.rawValue }
    }

    var daysCount: Int {
        let components = Calendar.app.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }

    /// 실제 차감 일수 — 반차/반반차 길이는 하루 비율, 종일은 **쉬는 날을 뺀 평일 수**.
    ///
    /// 금~월로 등록해도 주말·공휴일·내 방학은 차감하지 않는다 (쉬는 날 판정: `DayOffCalendar`).
    /// 예외: "이전 사용 연차 일괄 입력"은 N일을 달력 일수로 펼쳐 저장한 요약 기록이라 달력 일수 그대로 센다.
    var effectiveLeaveDays: Double {
        // 일괄 입력을 시간으로 넣은 요약 기록 — 요일별 근무 시간과 상관없이 하루 근무 시간으로 나눈다
        if length == .hours, isBulkSummary { return LeaveLength.days(forMinutes: durationMinutes ?? 0) }
        if length == .hours { return LeaveLength.days(forMinutes: durationMinutes ?? 0, on: startDate) }
        if length != .full { return length.fraction }
        if isBulkSummary { return Double(daysCount) }
        return Double(DayOffCalendar.shared.workdays(from: startDate, to: endDate))
    }

    /// "이전 사용 연차 (일괄 입력)" 요약 기록인지 — 메모로 판별한다 (백업·복원을 거쳐도 남는 유일한 표식).
    /// 입력 당시 앱 언어로 저장되므로 모든 언어의 문구와 비교한다.
    var isBulkSummary: Bool {
        Self.bulkSummaryNotes.contains(note)
    }

    /// `Strings.pastLeaveSummaryNote` 의 23개 언어 전부 — 빠진 언어가 있으면 그 기록을 근무일로 세어 줄어든다
    static let bulkSummaryNotes: Set<String> = [
        "이전 사용 연차 (일괄 입력)",
        "Prior leave (bulk entry)",
        "Tidigare ledighet (samlad inmatning)",
        "Tidligere ferie (samlet registrering)",
        "Tidligere ferie (samlet indtastning)",
        "Aiempi loma (kertasyöttö)",
        "Wcześniejszy urlop (wpis zbiorczy)",
        "Dřívější dovolená (hromadně)",
        "Προηγούμενη άδεια (μαζική εισαγωγή)",
        "Önceki izin (toplu giriş)",
        "Прошлый отпуск (одной записью)",
        "Cuti sebelumnya (input sekaligus)",
        "Eerder verlof (bulkinvoer)",
        "過去の有給（一括入力）",
        "过去的年假（批量录入）",
        "Früherer Urlaub (Sammeleingabe)",
        "Congés antérieurs (saisie groupée)",
        "Vacaciones anteriores (entrada en bloque)",
        "Ferie precedenti (inserimento in blocco)",
        "Férias anteriores (entrada em lote)",
        "先前特休（批次輸入）",
        "วันลาก่อนหน้า (กรอกรวม)",
        "Phép trước đó (nhập gộp)",
    ]

    /// 실제 연차 차감 여부 — bonusLeaveId가 있으면 보너스 차감이므로 연차 차감 아님
    var deductsFromAnnualLeave: Bool {
        category.deductsFromAnnual && bonusLeaveId == nil
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

    /// 보너스 연차를 시간으로 넣고 보여 줄지 (저장은 언제나 일수 — 하루 근무 시간으로 바꾼다)
    static let inputInHoursKey = "bonusLeaveInHours"

    /// 일수 → 분 (하루 근무 시간 기준, 5분 단위로 반올림)
    static func minutes(forDays days: Double) -> Int {
        Int((max(0, days) * Double(LeaveLength.workdayMinutes) / 5).rounded()) * 5
    }
}

// MARK: - 기존 기록 길이 보정 (마이그레이션)
/// 파서 개선 이전에 저장된 기록을 보정한다.
/// note에 "(1/2)"·"½" 같은 분수 표기가 있는데 길이가 종일(1일)로 남아 있으면 실제 길이(반차/반반차)로 교정.
/// 예) "자녀돌봄(1/2)"이 1일로 저장된 과거 데이터를 0.5일로 되돌린다.
enum LeaveRecordMaintenance {
    @discardableResult
    static func backfillLengths(records: [LeaveRecord]) -> Bool {
        var changed = false
        let cal = Calendar.app
        for r in records {
            // 이미 반차/반반차로 지정된 기록·다일 기간은 건드리지 않는다
            guard r.length == .full,
                  cal.isDate(r.startDate, inSameDayAs: r.endDate),
                  let frac = LeaveTableParser.fractionalDay(in: r.note) else { continue }
            let newLength: LeaveLength = frac <= 0.3 ? .quarter : (frac < 1.0 ? .half : .full)
            guard newLength != .full else { continue }
            r.length = newLength
            changed = true
        }
        return changed
    }
}

// MARK: - 보너스 연차 사용량 재계산
/// 휴가 사용 내역(LeaveRecord)을 근거로 보너스 연차의 사용량을 재산정한다.
/// 저장된 `usedDays` 카운터가 실제 기록과 어긋나거나, 보너스 유형에 해당하는
/// 특별휴가 기록이 보너스에 연결(`bonusLeaveId`)되지 않은 과거 데이터를 함께 보정한다.
enum BonusLeaveReconciler {
    /// 1) 연차를 차감하지 않는 미연결 특별휴가 기록을, 유형이 맞고 잔여가 충분한 보너스에 자동 연결
    ///    — 유형은 휴가 카테고리(대체휴무·공가·병가)로 먼저 판단하고, 없으면 메모에서 찾는다
    /// 2) 모든 보너스의 `usedDays`/`isUsed`를 연결된 기록 기준으로 재산정
    ///
    /// ⚠️ 취소(`.cancelled`)된 기록은 보너스를 쓰지 않은 것이다 — 연결은 남겨 두되 사용량에 세지 않는다
    ///    (`LeaveUsageCalculator`의 "취소는 어디에도 세지 않는다"와 같은 규칙).
    /// - Returns: 데이터가 실제로 변경되면 true (호출 측에서 save 트리거용)
    @discardableResult
    static func reconcile(records: [LeaveRecord], bonuses: [BonusLeave]) -> Bool {
        guard !bonuses.isEmpty else { return false }
        var changed = false

        // 잔여 추적 — 이미 연결된 기록부터 차감
        var remaining: [UUID: Double] = [:]
        for b in bonuses { remaining[b.id] = b.days }
        for r in records where r.status != .cancelled {
            guard let id = r.bonusLeaveId, remaining[id] != nil else { continue }
            remaining[id]! -= r.effectiveLeaveDays
        }

        // 1단계: 미연결 특별휴가 → 유형 매칭 보너스 자동 연결 (오래된 기록부터 안정적으로)
        for r in records.sorted(by: { $0.startDate < $1.startDate }) {
            guard r.bonusLeaveId == nil, r.status != .cancelled, !r.type.deductsFromAnnual else { continue }
            guard let matchType = BonusLeaveType(category: r.category) ?? BonusLeaveType.matching(r.note) else { continue }
            let days = r.effectiveLeaveDays
            guard let target = bonuses.first(where: {
                $0.type == matchType && (remaining[$0.id] ?? 0) >= days
            }) else { continue }
            r.bonusLeaveId = target.id
            remaining[target.id]! -= days
            changed = true
        }

        // 2단계: usedDays / isUsed 재산정
        for b in bonuses {
            let used = records
                .filter { $0.bonusLeaveId == b.id && $0.status != .cancelled }
                .reduce(0.0) { $0 + $1.effectiveLeaveDays }
            if abs(used - b.usedDays) > 0.001 {
                b.usedDays = used
                changed = true
            }
            let shouldBeUsed = b.remainingDays <= 0
            if b.isUsed != shouldBeUsed {
                b.isUsed = shouldBeUsed
                changed = true
            }
        }
        return changed
    }
}


extension LeaveRecommendation {
    /// 이 추천을 일정에 넣을 때 만들 기록 — 주말·공휴일을 뺀 연차 내는 날만.
    func plannedRecords(country: Country, calendar: Calendar = .app) -> [LeaveRecord] {
        let years = Set([startDate, endDate].map { calendar.component(.year, from: $0) })
        let holidays = years.flatMap { DayOffCalendar.shared.holidays(for: $0, country: country) }
        return leaveSegments(holidays: holidays, country: country, calendar: calendar).map {
            LeaveRecord(startDate: $0.start, endDate: $0.end, type: .annual, status: .planned,
                        note: title, isRecommended: true)
        }
    }

    /// 추천 기간 중 **실제로 연차를 내야 하는 날**만 연속 구간으로 묶는다.
    ///
    /// 추천의 startDate~endDate는 "쉬는 기간 전체"(주말·공휴일 포함)다. 그대로 등록하면
    /// 주말·공휴일까지 휴가로 잡히고, 차감 일수(달력 일수)도 그만큼 부풀어 연차가 과하게 빠진다.
    func leaveSegments(holidays: [Holiday], country: Country = DayOffCalendar.shared.country, calendar: Calendar = .app) -> [(start: Date, end: Date)] {
        let holidayDays = Set(holidays.map { calendar.startOfDay(for: $0.date) })
        var segments: [(start: Date, end: Date)] = []
        var d = calendar.startOfDay(for: startDate)
        let last = calendar.startOfDay(for: endDate)
        while d <= last {
            let isDayOff = HolidayService.isRestWeekend(d, country: country, calendar: calendar) || holidayDays.contains(d)
            if !isDayOff {
                if let prev = segments.last,
                   let next = calendar.date(byAdding: .day, value: 1, to: prev.end),
                   calendar.isDate(next, inSameDayAs: d) {
                    segments[segments.count - 1].end = d
                } else {
                    segments.append((d, d))
                }
            }
            d = calendar.date(byAdding: .day, value: 1, to: d)!
        }
        return segments
    }
}


// MARK: - 방학


@Model
final class SchoolBreak {
    var id: UUID = UUID()
    var name: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var kindRaw: String = SchoolBreakKind.child.rawValue
    var createdAt: Date = Date()

    init(name: String, startDate: Date, endDate: Date, kind: SchoolBreakKind) {
        self.id = UUID()
        self.name = name
        self.startDate = Calendar.app.startOfDay(for: startDate)
        self.endDate = Calendar.app.startOfDay(for: endDate)
        self.kindRaw = kind.rawValue
        self.createdAt = Date()
    }

    var kind: SchoolBreakKind {
        get { SchoolBreakKind(rawValue: kindRaw) ?? .child }
        set { kindRaw = newValue.rawValue }
    }
}

// MARK: - 사용자 정의 공휴일
@Model
class CustomHoliday {
    var id: UUID
    var date: Date
    var name: String
    var createdAt: Date
    /// 매년 같은 월·일에 반복 (default: SwiftData lightweight migration용)
    var repeatsYearly: Bool = false

    init(date: Date, name: String, repeatsYearly: Bool = false) {
        self.id = UUID()
        self.date = date
        self.name = name
        self.createdAt = Date()
        self.repeatsYearly = repeatsYearly
    }

    /// 그해에 이 공휴일이 오는 날. 반복이면 모든 해, 아니면 넣은 해에만.
    /// 2월 29일 반복은 평년엔 건너뛴다.
    func occurrence(in year: Int, calendar: Calendar = .app) -> Date? {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        if !repeatsYearly { return comps.year == year ? calendar.startOfDay(for: date) : nil }
        guard let d = calendar.date(from: DateComponents(year: year, month: comps.month, day: comps.day)),
              calendar.component(.day, from: d) == comps.day else { return nil }
        return d
    }
}

// MARK: - 가족 기념일


/// 가족 기념일 — 가족 안에서는 공휴일이나 다름없는 날 (생신·결혼기념일·기일).
/// 쉬는 날은 아니다(연차 계산 그대로). 달력에 표시하고, 그날이 든 추천을 앞세우고, 미리 휴가를 챙기라고 알린다.
/// 매년 반복이 기본이고, 음력이면 처음 날짜의 음력 월·일을 해마다 따른다.
@Model
final class FamilyAnniversary {
    var id: UUID = UUID()
    /// 직접 붙인 이름 — 비면 관계와 종류로 보여 준다 ("엄마 · 생일")
    var name: String = ""
    /// 누구의 날인지 (예: "엄마") — 비어 있어도 된다
    var relation: String = ""
    var kindRaw: String = AnniversaryKind.birthday.rawValue
    /// 처음 날짜 (태어난 날·결혼한 날). 해마다의 날짜와 "몇 번째"를 여기서 센다
    var date: Date = Date()
    /// 음력 날짜 — `date` 의 음력 월·일을 해마다 양력으로 옮긴다
    var isLunar: Bool = false
    /// 2주 전에 휴가를 챙기라는 알림과 당일 알림
    var reminds: Bool = true
    var createdAt: Date = Date()

    init(name: String, relation: String, kind: AnniversaryKind, date: Date, isLunar: Bool, reminds: Bool = true) {
        self.id = UUID()
        self.name = name
        self.relation = relation
        self.kindRaw = kind.rawValue
        self.date = Calendar.app.startOfDay(for: date)
        self.isLunar = isLunar
        self.reminds = reminds
        self.createdAt = Date()
    }

    var kind: AnniversaryKind {
        get { AnniversaryKind(rawValue: kindRaw) ?? .other }
        set { kindRaw = newValue.rawValue }
    }

    /// 그해(양력)에 이 기념일이 오는 날. 2월 29일은 평년엔 2월 28일로 당긴다.
    /// 음력은 해에 따라 한 해에 두 번(음력 11·12월) 오거나 안 올 수 있어, 그해 안에 드는 첫 날을 고른다.
    func occurrence(in year: Int, calendar: Calendar = .app) -> Date? {
        Self.occurrence(of: date, isLunar: isLunar, in: year, calendar: calendar)
    }

    /// 모델 밖(추천 엔진처럼 다른 스레드)에서도 같은 규칙으로 셀 수 있게 값만 받는 판
    static func occurrence(of date: Date, isLunar: Bool, in year: Int, calendar: Calendar = .app) -> Date? {
        if isLunar {
            let lunar = LunarDate.components(from: date, calendar: calendar)
            return (year - 1...year)
                .compactMap { LunarDate.occurrence(month: lunar.month, day: lunar.day, isLeap: lunar.isLeap,
                                                   inLunarYearStartingIn: $0, calendar: calendar) }
                .first { calendar.component(.year, from: $0) == year }
        }
        let comps = calendar.dateComponents([.month, .day], from: date)
        guard let month = comps.month, let day = comps.day else { return nil }
        if let d = calendar.date(from: DateComponents(year: year, month: month, day: day)),
           calendar.component(.day, from: d) == day {
            return d
        }
        // 2월 29일 → 평년엔 2월 28일
        return calendar.date(from: DateComponents(year: year, month: month, day: day - 1))
    }

    /// 오늘 이후(오늘 포함) 가장 가까운 날
    func nextOccurrence(from reference: Date = Date(), calendar: Calendar = .app) -> Date? {
        let today = calendar.startOfDay(for: reference)
        let year = calendar.component(.year, from: today)
        return (year...year + 1).compactMap { occurrence(in: $0, calendar: calendar) }.first { $0 >= today }
    }

    /// 그날이 몇 번째인지 (2026년의 1960년생 생일 → 66). 처음 날짜 그해면 nil
    func ordinal(at occurrence: Date, calendar: Calendar = .app) -> Int? {
        let n = calendar.component(.year, from: occurrence) - calendar.component(.year, from: date)
        return n > 0 ? n : nil
    }
}

