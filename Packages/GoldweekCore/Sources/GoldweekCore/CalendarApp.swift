import Foundation

extension Calendar {
    /// 앱이 날짜 계산에 쓰는 달력 — 언제나 양력(그레고리력).
    ///
    /// ⚠️ `Calendar.current` 를 그냥 쓰면 안 된다 — 태국 지역 폰은 기본이 불기(佛紀) 달력이라
    ///    올해가 2569년이 되고, 일본식 달력을 고른 폰은 연호로 센다. 공휴일·연차 계산이
    ///    전부 `DateComponents(year: 2026 …)` 같은 양력 숫자를 쓰므로 어긋난다.
    ///    양력 폰이면 그대로 `Calendar.current`(주 시작 요일·시간대 포함)를 돌려준다.
    public static var app: Calendar {
        let current = Calendar.current
        if current.identifier == .gregorian { return current }
        var cal = Calendar(identifier: .gregorian)
        cal.locale = current.locale
        cal.timeZone = current.timeZone
        cal.firstWeekday = current.firstWeekday
        cal.minimumDaysInFirstWeek = current.minimumDaysInFirstWeek
        return cal
    }
}

/// 처음 쓰는 사람에게 하나씩 여는 기능 — 적은 차례대로, 필요해진 순간이 온 첫 번째 것을 연다.
/// 달력 · 휴가 등록 · 추천 · 내역 · 근무 형태 설정은 앱의 핵심이라 여기 없다(처음부터 보인다).
public enum SurfaceFeature: String, CaseIterable {
    /// 앱을 열면 현황부터. 그 전에는 캘린더부터 연다 — 입력 없이도 연휴가 보이고, 현황 숫자는 아직 비어 있다.
    /// 휴가를 하나 잡아 두면 숫자가 진짜가 된다. 한 번 열리면 되돌리지 않는다(첫 화면이 왔다 갔다 하지 않게).
    case statusFirst
    case photoImport, sharePlan, restPace, leaveKinds, longView
    /// 나머지 전부. 이것을 확인하면 처음 화면이 끝난다.
    case everything

    public func isNeeded(_ facts: SurfaceFacts) -> Bool {
        switch self {
        case .statusFirst: return facts.upcomingCount >= 1        // 잡아 둔 휴가가 생겼다
        case .photoImport: return facts.recordCount >= 2          // 하나씩 넣기가 번거로워진다
        case .sharePlan: return facts.upcomingCount >= 1          // 알릴 일정이 생겼다
        case .restPace: return facts.recordCount >= 3             // 쉬는 흐름이 보일 만큼 쌓였다
        case .leaveKinds: return facts.usesOtherKind              // 연차 말고 다른 휴가를 쓴다
        case .longView: return facts.upcomingCount >= 2           // 앞으로의 일정이 여러 번이다
        case .everything: return facts.recordCount >= 8
        }
    }

    /// 지금 열 기능. 한 번에 말을 하나만 하도록 하루에 하나, 앞의 카드를 확인한 뒤에만 연다.
    public static func next(unlocked: Set<SurfaceFeature>, facts: SurfaceFacts, lastUnlock: Date?,
                     now: Date = Date(), calendar: Calendar = .app) -> SurfaceFeature? {
        if let lastUnlock, calendar.isDate(lastUnlock, inSameDayAs: now) { return nil }
        return allCases.first { !unlocked.contains($0) && $0.isNeeded(facts) }
    }
}

/// 보조 달력 — 달력 칸과 날짜 카드에 그 달력의 날짜를 **보여 주기만** 한다.
/// 휴가·공휴일 계산은 언제나 `Calendar.app`(양력)이다. 고르지 않으면 설정값이 빈 문자열이라 이 타입이 만들어지지 않는다.
public enum SecondaryCalendar: String, CaseIterable, Identifiable {
    case chinese, islamic, hebrew, persian, indian, buddhist

    public static let storageKey = "secondaryCalendar"

    public var id: String { rawValue }

    private var calendar: Calendar {
        let identifier: Calendar.Identifier
        switch self {
        case .chinese: identifier = .chinese
        case .islamic: identifier = .islamicUmmAlQura
        case .hebrew: identifier = .hebrew
        case .persian: identifier = .persian
        case .indian: identifier = .indian
        case .buddhist: identifier = .buddhist
        }
        var cal = Calendar(identifier: identifier)
        cal.timeZone = Calendar.app.timeZone
        return cal
    }

    /// 달력 칸에 쓸 날짜. 불기는 연도만 달라 칸에 쓰면 양력과 같은 숫자가 겹치므로 없다.
    public func dayText(for date: Date) -> String? {
        self == .buddhist ? nil : String(calendar.component(.day, from: date))
    }

    /// 날짜 카드에 쓸 글. 음력은 시스템 표기가 언어마다 깨져("23 M09") 가족 기념일의 음력 문구를 함께 쓴다.
    public func cardText(for date: Date) -> String {
        if self == .chinese { return LunarDate.label(from: date) }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = Locale(identifier: Strings.localeIdentifier)
        formatter.setLocalizedDateFormatFromTemplate("yMMMMd")
        return "\(Strings.secondaryCalendarName(self)): \(formatter.string(from: date))"
    }
}

/// 사는 나라와 상관없이 지키는 명절 — 켜면 그날을 쉬는 날로 세고 추천도 그날에 맞춘다.
/// 예: 영국에 사는 무슬림이 이드에 맞춰 휴가를 짠다.
public enum CulturalFestival: String, CaseIterable, Identifiable {
    case islamic, jewish, hindu, lunar

    /// 저장값은 켠 것만 쉼표로 ("islamic,hindu")
    public static let storageKey = "culturalFestivals"

    public var id: String { rawValue }

    public static var enabled: Set<CulturalFestival> {
        parse(UserDefaults.standard.string(forKey: storageKey) ?? "")
    }

    public static func parse(_ raw: String) -> Set<CulturalFestival> {
        Set(raw.split(separator: ",").compactMap { CulturalFestival(rawValue: String($0)) })
    }

    public static func raw(_ festivals: Set<CulturalFestival>) -> String {
        allCases.filter(festivals.contains).map(\.rawValue).joined(separator: ",")
    }
}

public struct SurfaceFacts: Equatable {
    public var recordCount: Int
    public var upcomingCount: Int
    public var usesOtherKind: Bool

    public init(recordCount: Int, upcomingCount: Int, usesOtherKind: Bool) {
        self.recordCount = recordCount
        self.upcomingCount = upcomingCount
        self.usesOtherKind = usesOtherKind
    }
}

/// 연차 일수를 정확하게 표시 (%.1f의 0.25→0.2 뱅커스 라운딩 버그 방지)
/// 1.0 → "1",  0.5 → "0.5",  0.25 → "0.25",  1.25 → "1.25"
public func formatLeave(_ value: Double) -> String {
    if value == Double(Int(value)) { return "\(Int(value))" }
    if value.truncatingRemainder(dividingBy: 0.5) == 0 { return String(format: "%.1f", value) }
    return String(format: "%.2f", value)
}
