import Foundation

// MARK: - 국가
public enum Country: String, CaseIterable, Identifiable, Codable {
    case korea = "korea"
    case japan = "japan"
    case china = "china"
    case usa = "usa"
    case germany = "germany"   // Brückentag 문화 — Goldweek 핵심 타깃 시장
    case france = "france"     // Faire le pont 문화 — Goldweek 핵심 타깃 시장
    case uk = "uk"
    case canada = "canada"
    case australia = "australia"
    case spain = "spain"       // Puente 문화
    case italy = "italy"       // Ponte 문화
    case brazil = "brazil"     // Enforcado(징검다리) 문화
    case taiwan = "taiwan"
    case hongKong = "hongkong"
    case uae = "uae"                   // 주말 토·일 (2022~)
    case saudiArabia = "saudiarabia"   // 주말 금·토
    case qatar = "qatar"               // 주말 금·토
    case peru = "peru"
    case netherlands = "netherlands"
    case belgium = "belgium"
    case austria = "austria"
    case switzerland = "switzerland"
    case ireland = "ireland"
    case portugal = "portugal"
    case sweden = "sweden"
    case norway = "norway"
    case denmark = "denmark"
    case finland = "finland"
    case poland = "poland"
    case czechia = "czechia"
    case greece = "greece"
    case turkey = "turkey"
    case egypt = "egypt"
    case southAfrica = "southafrica"
    case morocco = "morocco"         // 이슬람 명절은 모로코가 직접 달을 보고 정한다
    case mexico = "mexico"
    case argentina = "argentina"
    case chile = "chile"
    case colombia = "colombia"
    case newZealand = "newzealand"
    case russia = "russia"           // 정부가 해마다 휴일을 옮긴다 (перенос выходных)
    case indonesia = "indonesia"     // 공휴일·공동 휴가를 해마다 SKB 로 정한다
    case singapore = "singapore"     // 이슬람·힌두 명절 날짜를 인력부(MOM)가 해마다 발표한다
    /// 지원하지 않는 나라 — 기본 공휴일 없이 사용자가 직접 넣는다 (예: 남아공)
    case custom = "custom"

    public var id: String { rawValue }

    public var displayName: String {
        Strings.countryDisplayName(self)
    }

    /// ISO 3166-1 지역 코드 — 기기 지역(`Locale.current.region`)과 맞춰 본다
    public var regionCode: String {
        switch self {
        case .korea: return "KR"
        case .japan: return "JP"
        case .china: return "CN"
        case .usa: return "US"
        case .germany: return "DE"
        case .france: return "FR"
        case .uk: return "GB"
        case .canada: return "CA"
        case .australia: return "AU"
        case .spain: return "ES"
        case .italy: return "IT"
        case .brazil: return "BR"
        case .taiwan: return "TW"
        case .hongKong: return "HK"
        case .uae: return "AE"
        case .saudiArabia: return "SA"
        case .qatar: return "QA"
        case .peru: return "PE"
        case .netherlands: return "NL"
        case .belgium: return "BE"
        case .austria: return "AT"
        case .switzerland: return "CH"
        case .ireland: return "IE"
        case .portugal: return "PT"
        case .sweden: return "SE"
        case .norway: return "NO"
        case .denmark: return "DK"
        case .finland: return "FI"
        case .poland: return "PL"
        case .czechia: return "CZ"
        case .greece: return "GR"
        case .turkey: return "TR"
        case .egypt: return "EG"
        case .southAfrica: return "ZA"
        case .morocco: return "MA"
        case .mexico: return "MX"
        case .argentina: return "AR"
        case .chile: return "CL"
        case .colombia: return "CO"
        case .newZealand: return "NZ"
        case .russia: return "RU"
        case .indonesia: return "ID"
        case .singapore: return "SG"
        case .custom: return ""   // 어떤 기기 지역과도 맞지 않게
        }
    }

    public var flag: String {
        if self == .custom { return "🌐" }
        // 지역 코드 두 글자를 국기 이모지(Regional Indicator)로 바꾼다
        return String(String.UnicodeScalarView(regionCode.unicodeScalars.compactMap {
            UnicodeScalar(0x1F1E6 - 0x41 + $0.value)
        }))
    }

    public var localeIdentifier: String {
        switch self {
        case .korea: return "ko_KR"
        case .japan: return "ja_JP"
        case .china: return "zh_CN"
        case .usa: return "en_US"
        case .germany: return "de_DE"
        case .france: return "fr_FR"
        case .uk: return "en_GB"
        case .canada: return "en_CA"
        case .australia: return "en_AU"
        case .spain: return "es_ES"
        case .italy: return "it_IT"
        case .brazil: return "pt_BR"
        case .taiwan: return "zh_TW"
        case .hongKong: return "zh_HK"
        case .uae: return "en_AE"
        case .saudiArabia: return "en_SA"
        case .qatar: return "en_QA"
        case .peru: return "es_PE"
        case .netherlands: return "nl_NL"
        case .belgium: return "nl_BE"
        case .austria: return "de_AT"
        case .switzerland: return "de_CH"
        case .ireland: return "en_IE"
        case .portugal: return "pt_PT"
        case .sweden: return "sv_SE"
        case .norway: return "nb_NO"
        case .denmark: return "da_DK"
        case .finland: return "fi_FI"
        case .poland: return "pl_PL"
        case .czechia: return "cs_CZ"
        case .greece: return "el_GR"
        case .turkey: return "tr_TR"
        case .egypt: return "ar_EG"
        case .southAfrica: return "en_ZA"
        case .morocco: return "fr_MA"
        case .mexico: return "es_MX"
        case .argentina: return "es_AR"
        case .chile: return "es_CL"
        case .colombia: return "es_CO"
        case .newZealand: return "en_NZ"
        case .russia: return "ru_RU"
        case .indonesia: return "id_ID"
        case .singapore: return "en_SG"
        case .custom: return Locale.current.identifier
        }
    }

    /// 주말 요일 (Calendar weekday: 1=일 … 7=토). 사우디·카타르 등 걸프 지역 다수는 금·토.
    /// 직접 입력은 사용자가 고른 값을 `HolidayService.weekendDays(for:)`가 돌려준다.
    public var standardWeekendDays: Set<Int> {
        switch self {
        case .saudiArabia, .qatar, .egypt: return [6, 7]
        default: return [1, 7]
        }
    }

    /// 그 나라 달력의 첫 요일 (Calendar weekday: 1=일, 2=월, 7=토) — 스페인·유럽 대부분은 월, 미국·한국은 일.
    /// 기기 언어와 상관없이 나라의 관습(CLDR)을 따른다.
    public var standardFirstWeekday: Int {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: localeIdentifier)
        return cal.firstWeekday
    }

    /// 이슬람력(달 관측) 공휴일이 있는 나라 — 날짜가 공식 발표에서 하루쯤 바뀔 수 있다
    public var hasMoonSightingHolidays: Bool {
        switch self {
        case .uae, .saudiArabia, .qatar, .turkey, .egypt, .morocco: return true
        default: return false
        }
    }

    /// 주·지역마다 공휴일이 다른 나라의 지역 목록. 비어 있으면 전국 공통 공휴일만 있다.
    public var holidayRegions: [HolidayRegion] {
        HolidayRegion.all.filter { $0.country == self }
    }

    public static func fromDeviceLocale() -> Country {
        detect().country
    }

    /// 기기 **지역**으로 국가를 정한다. 언어만 보면 영국·호주 사용자가 미국 공휴일을,
    /// 대만·홍콩 사용자가 중국 본토 공휴일을 보게 된다.
    /// 지원하지 않는 지역이면 언어로 가장 가까운 나라를 고르고 `isSupported = false` 로 알린다.
    public static func detect(locale: Locale = .current) -> (country: Country, isSupported: Bool) {
        if let region = locale.region?.identifier,
           let match = allCases.first(where: { $0.regionCode == region }) {
            return (match, true)
        }
        let lang = locale.language.languageCode?.identifier ?? "en"
        let fallback: Country
        switch lang {
        case "ko": fallback = .korea
        case "ja": fallback = .japan
        case "zh": fallback = locale.language.script?.identifier == "Hant" ? .taiwan : .china
        case "de": fallback = .germany
        case "fr": fallback = .france
        case "es": fallback = .spain
        case "it": fallback = .italy
        case "pt": fallback = .brazil
        case "nl": fallback = .netherlands
        case "sv": fallback = .sweden
        case "nb", "nn", "no": fallback = .norway
        case "da": fallback = .denmark
        case "fi": fallback = .finland
        case "pl": fallback = .poland
        case "cs": fallback = .czechia
        case "el": fallback = .greece
        case "tr": fallback = .turkey
        case "ru": fallback = .russia
        case "id": fallback = .indonesia
        // 아랍어 — 지원하지 않는 아랍 나라(쿠웨이트·요르단 등)라도 미국보다 주말(금·토)과 이슬람 명절이 맞는
        // 이웃 나라가 낫다. 마그레브는 모로코, 그 밖은 사우디.
        case "ar":
            let region = locale.region?.identifier ?? ""
            fallback = ["TN", "DZ", "LY", "MR"].contains(region) ? .morocco : .saudiArabia
        default: fallback = .usa
        }
        return (fallback, false)
    }

    /// 기기 지역이 지원하지 않는 곳이면 그 지역 코드 (예: "AT"). 지원하는 곳이거나 알 수 없으면 nil.
    public static var unsupportedDeviceRegion: String? {
        guard let region = Locale.current.region?.identifier,
              !allCases.contains(where: { $0.regionCode == region }) else { return nil }
        return region
    }
}

/// 국가 선택을 대륙 → 나라 2단계로 찾게 묶는다. 직접 입력(.custom)은 어느 대륙에도 넣지 않는다.
public enum Continent: String, CaseIterable, Identifiable {
    case asia, middleEast, europe, africa, northAmerica, southAmerica, oceania

    public var id: String { rawValue }

    public var countries: [Country] {
        Country.allCases.filter { $0.continent == self }
            .sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
    }

    public var displayName: String { Strings.continentName(self) }

    public var icon: String {
        switch self {
        case .asia, .oceania: return "globe.asia.australia.fill"
        case .middleEast, .europe, .africa: return "globe.europe.africa.fill"
        case .northAmerica, .southAmerica: return "globe.americas.fill"
        }
    }
}

extension Country {
    public var continent: Continent? {
        switch self {
        case .korea, .japan, .china, .taiwan, .hongKong, .indonesia, .singapore: return .asia
        case .uae, .saudiArabia, .qatar, .turkey: return .middleEast
        case .germany, .france, .uk, .spain, .italy, .netherlands, .belgium, .austria, .switzerland, .ireland, .portugal,
             .sweden, .norway, .denmark, .finland, .poland, .czechia, .greece, .russia: return .europe
        case .egypt, .southAfrica, .morocco: return .africa
        case .usa, .canada, .mexico: return .northAmerica
        case .brazil, .peru, .argentina, .chile, .colombia: return .southAmerica
        case .australia, .newZealand: return .oceania
        case .custom: return nil
        }
    }
}

/// 나라 안에서 지역마다 공휴일이 다른 경우의 지역. 코드는 ISO 3166-2 (예: "DE-BY").
/// 이름은 현지 표기를 기본으로 하고, 그 나라 말이 아닌 화면에서는 영어 이름을 쓴다.
public struct HolidayRegion: Identifiable, Hashable {
    public let code: String
    public let country: Country
    public let localName: String
    public let englishName: String?

    public init(code: String, country: Country, localName: String, englishName: String? = nil) {
        self.code = code
        self.country = country
        self.localName = localName
        self.englishName = englishName
    }

    public var id: String { code }

    public var displayName: String {
        let lang = AppLanguage.current
        let native: Bool
        switch country {
        case .germany: native = lang == .german
        case .spain: native = lang == .spanish
        case .canada: native = lang == .english || lang == .french
        default: native = true   // 영어권(미국·영국·호주)은 현지명이 곧 영어 이름
        }
        return native ? localName : (englishName ?? localName)
    }

    public static func find(_ code: String) -> HolidayRegion? {
        all.first { $0.code == code }
    }

    private static func r(_ code: String, _ country: Country, _ local: String, _ english: String? = nil) -> HolidayRegion {
        HolidayRegion(code: code, country: country, localName: local, englishName: english)
    }

    public static let all: [HolidayRegion] = [
        // 독일 — 16개 주 전부
        r("DE-BW", .germany, "Baden-Württemberg"),
        r("DE-BY", .germany, "Bayern", "Bavaria"),
        r("DE-BE", .germany, "Berlin"),
        r("DE-BB", .germany, "Brandenburg"),
        r("DE-HB", .germany, "Bremen"),
        r("DE-HH", .germany, "Hamburg"),
        r("DE-HE", .germany, "Hessen", "Hesse"),
        r("DE-MV", .germany, "Mecklenburg-Vorpommern", "Mecklenburg-Western Pomerania"),
        r("DE-NI", .germany, "Niedersachsen", "Lower Saxony"),
        r("DE-NW", .germany, "Nordrhein-Westfalen", "North Rhine-Westphalia"),
        r("DE-RP", .germany, "Rheinland-Pfalz", "Rhineland-Palatinate"),
        r("DE-SL", .germany, "Saarland"),
        r("DE-SN", .germany, "Sachsen", "Saxony"),
        r("DE-ST", .germany, "Sachsen-Anhalt", "Saxony-Anhalt"),
        r("DE-SH", .germany, "Schleswig-Holstein"),
        r("DE-TH", .germany, "Thüringen", "Thuringia"),

        // 미국 — 연방 공휴일과 다른 주 공휴일이 뚜렷한 주만. 나머지 주는 연방 공휴일(기본값)을 쓴다.
        r("US-AK", .usa, "Alaska"),
        r("US-CA", .usa, "California"),
        r("US-DC", .usa, "District of Columbia"),
        r("US-FL", .usa, "Florida"),
        r("US-HI", .usa, "Hawaii"),
        r("US-IL", .usa, "Illinois"),
        r("US-LA", .usa, "Louisiana"),
        r("US-ME", .usa, "Maine"),
        r("US-MA", .usa, "Massachusetts"),
        r("US-NY", .usa, "New York"),
        r("US-TX", .usa, "Texas"),
        r("US-WA", .usa, "Washington"),

        // 스페인 — 17개 자치주 + 세우타·멜리야
        r("ES-AN", .spain, "Andalucía", "Andalusia"),
        r("ES-AR", .spain, "Aragón", "Aragon"),
        r("ES-AS", .spain, "Asturias"),
        r("ES-IB", .spain, "Illes Balears", "Balearic Islands"),
        r("ES-CN", .spain, "Canarias", "Canary Islands"),
        r("ES-CB", .spain, "Cantabria"),
        r("ES-CL", .spain, "Castilla y León", "Castile and León"),
        r("ES-CM", .spain, "Castilla-La Mancha", "Castilla–La Mancha"),
        r("ES-CT", .spain, "Catalunya", "Catalonia"),
        r("ES-VC", .spain, "Comunitat Valenciana", "Valencian Community"),
        r("ES-EX", .spain, "Extremadura"),
        r("ES-GA", .spain, "Galicia"),
        r("ES-MD", .spain, "Comunidad de Madrid", "Madrid"),
        r("ES-MC", .spain, "Región de Murcia", "Murcia"),
        r("ES-NC", .spain, "Navarra", "Navarre"),
        r("ES-PV", .spain, "País Vasco", "Basque Country"),
        r("ES-RI", .spain, "La Rioja"),
        r("ES-CE", .spain, "Ceuta"),
        r("ES-ML", .spain, "Melilla"),

        // 영국 — 공휴일 체계가 다른 세 지역
        r("GB-ENG", .uk, "England & Wales"),
        r("GB-SCT", .uk, "Scotland"),
        r("GB-NIR", .uk, "Northern Ireland"),

        // 캐나다 — 10개 주 (준주는 연방 공휴일)
        r("CA-AB", .canada, "Alberta"),
        r("CA-BC", .canada, "British Columbia", "British Columbia"),
        r("CA-MB", .canada, "Manitoba"),
        r("CA-NB", .canada, "New Brunswick"),
        r("CA-NL", .canada, "Newfoundland and Labrador"),
        r("CA-NS", .canada, "Nova Scotia"),
        r("CA-ON", .canada, "Ontario"),
        r("CA-PE", .canada, "Prince Edward Island"),
        r("CA-QC", .canada, "Québec", "Quebec"),
        r("CA-SK", .canada, "Saskatchewan"),

        // 호주 — 6개 주 + 2개 준주
        r("AU-ACT", .australia, "Australian Capital Territory"),
        r("AU-NSW", .australia, "New South Wales"),
        r("AU-NT", .australia, "Northern Territory"),
        r("AU-QLD", .australia, "Queensland"),
        r("AU-SA", .australia, "South Australia"),
        r("AU-TAS", .australia, "Tasmania"),
        r("AU-VIC", .australia, "Victoria"),
        r("AU-WA", .australia, "Western Australia"),
    ]
}

public enum UserType: String, Codable, CaseIterable, Identifiable {
    case employee = "employee"   // 직장인 — 연차 관리
    case leisure = "leisure"     // 자유 계획 — 연차 없이 휴가 플래닝

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .employee: return Strings.userTypeEmployee
        case .leisure: return Strings.userTypeLeisure
        }
    }

    public var icon: String {
        switch self {
        case .employee: return "briefcase"
        case .leisure: return "beach.umbrella"
        }
    }
}

// MARK: - 열거형 정의
public enum PreferredDuration: String, Codable, CaseIterable, Identifiable {
    case short = "1-2일"
    case medium = "3-4일"
    case long = "5일 이상"
    case mixed = "혼합"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .short: return "⚡"
        case .medium: return "🌴"
        case .long: return "✈️"
        case .mixed: return "🎲"
        }
    }
}

public enum Season: String, Codable, CaseIterable, Identifiable {
    case spring = "봄"
    case summer = "여름"
    case fall = "가을"
    case winter = "겨울"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .spring: return "🌸"
        case .summer: return "🌻"
        case .fall: return "🍂"
        case .winter: return "❄️"
        }
    }
    
    public var months: [Int] {
        switch self {
        case .spring: return [3, 4, 5]
        case .summer: return [6, 7, 8]
        case .fall: return [9, 10, 11]
        case .winter: return [12, 1, 2]
        }
    }
}

public enum ActivityType: String, Codable, CaseIterable, Identifiable {
    case travel = "여행"
    case rest = "휴식"
    case family = "가족시간"
    case hobby = "취미활동"
    case selfCare = "자기계발"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .travel: return "✈️"
        case .rest: return "🛋️"
        case .family: return "👨‍👩‍👧"
        case .hobby: return "🎨"
        case .selfCare: return "📚"
        }
    }
}

public enum LeaveType: String, Codable, CaseIterable, Identifiable {
    case annual = "연차"
    case half = "반차"
    case quarter = "반반차"
    case compensatory = "대체휴무"
    case official = "공가"
    case sick = "병가"
    case special = "특별휴가"
    case businessTrip = "출장"

    public var id: String { rawValue }

    /// 순수 카테고리 목록 — 길이 축 분리 후 입력 UI에 노출한다. 레거시 반차/반반차는 길이로 흡수되므로 제외.
    public static var categories: [LeaveType] {
        [.annual, .compensatory, .official, .sick, .special, .businessTrip]
    }

    /// 연차 차감 여부 (true면 연차에서 차감)
    public var deductsFromAnnual: Bool {
        switch self {
        case .annual, .half, .quarter: return true
        case .compensatory, .official, .sick, .special, .businessTrip: return false
        }
    }

    public var leaveValue: Double {
        switch self {
        case .annual: return 1.0
        case .half: return 0.5
        case .quarter: return 0.25
        case .compensatory, .official, .sick, .special, .businessTrip: return 0.0
        }
    }

    public var icon: String {
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

    public var color: String {
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

/// 휴가 길이(사용 단위) — 휴가 카테고리와 직교하는 축.
/// 어떤 휴가 종류(연차·특별휴가·병가 등)든 종일/반차/반반차로 사용할 수 있어 카테고리 n × 길이 3 조합이 성립한다.
public enum LeaveLength: String, Codable, CaseIterable, Identifiable {
    case full = "종일"
    case half = "반차"
    case quarter = "반반차"
    /// 시간·분 단위 (이탈리아 permessi 처럼 몇 시간만 쓰는 휴가) — 길이는 LeaveRecord.durationMinutes
    case hours = "시간"

    public var id: String { rawValue }

    /// 하루 대비 사용 비율 (종일 1.0, 반차 0.5, 반반차 0.25).
    /// 시간 단위는 기록마다 다르다 — `days(forMinutes:)` 로 계산한다 (여기서는 0).
    public var fraction: Double {
        switch self {
        case .full: return 1.0
        case .half: return 0.5
        case .quarter: return 0.25
        case .hours: return 0
        }
    }

    public var icon: String {
        switch self {
        case .full: return "sun.max"
        case .half: return "clock.badge"
        case .quarter: return "clock"
        case .hours: return "hourglass"
        }
    }

    /// 하루 근무 시간(분) — 시간 단위 휴가를 일수로 바꾸는 기준. 설정에서 바꾼다 (기본 8시간).
    public static var workdayMinutes: Int {
        get {
            let v = UserDefaults.standard.integer(forKey: "workdayMinutes")
            return v > 0 ? v : 480
        }
        set { UserDefaults.standard.set(newValue, forKey: "workdayMinutes") }
    }

    /// 분 → 차감 일수 (하루 근무 시간 기준)
    public static func days(forMinutes minutes: Int) -> Double {
        Double(max(0, minutes)) / Double(workdayMinutes)
    }

    public static let usesHourlyLeaveKey = "usesHourlyLeave"

    /// 시간 단위 휴가를 쓰는지 — 끄면 "시간 단위" 버튼과 근무 시간 설정을 숨긴다.
    /// 고른 적 없으면 근무 시간을 바꾼 적이 있는지로 짐작한다 (시간 기록이 있으면 ContentView 가 켠다).
    public static var usesHourlyLeave: Bool {
        get {
            let d = UserDefaults.standard
            if let v = d.object(forKey: usesHourlyLeaveKey) as? Bool { return v }
            return d.object(forKey: "workdayMinutes") != nil || d.object(forKey: weekdayMinutesKey) != nil
        }
        set { UserDefaults.standard.set(newValue, forKey: usesHourlyLeaveKey) }
    }

    private static let weekdayMinutesKey = "workdayMinutesByWeekday"

    /// 요일마다 근무 시간이 다른 경우 (예: 월~목 7시간 30분, 금 7시간) — 요일(1=일 … 7=토) → 분.
    /// 비어 있으면 모든 요일이 `workdayMinutes`.
    public static var workdayMinutesByWeekday: [Int: Int] {
        get {
            guard let data = UserDefaults.standard.data(forKey: weekdayMinutesKey),
                  let map = try? JSONDecoder().decode([String: Int].self, from: data) else { return [:] }
            return Dictionary(uniqueKeysWithValues: map.compactMap { k, v in Int(k).map { ($0, v) } })
        }
        set {
            let map = Dictionary(uniqueKeysWithValues: newValue.filter { $0.value > 0 }.map { (String($0.key), $0.value) })
            if map.isEmpty {
                UserDefaults.standard.removeObject(forKey: weekdayMinutesKey)
            } else if let data = try? JSONEncoder().encode(map) {
                UserDefaults.standard.set(data, forKey: weekdayMinutesKey)
            }
        }
    }

    /// 그 날의 근무 시간(분) — 요일별로 정했으면 그 값, 아니면 하루 근무 시간
    public static func workdayMinutes(on date: Date, calendar: Calendar = .app) -> Int {
        workdayMinutesByWeekday[calendar.component(.weekday, from: date)] ?? workdayMinutes
    }

    /// 분 → 차감 일수 (그 날의 근무 시간 기준 — 금요일 1시간은 7시간 근무면 1/7일)
    public static func days(forMinutes minutes: Int, on date: Date) -> Double {
        Double(max(0, minutes)) / Double(max(1, workdayMinutes(on: date)))
    }
}

public enum LeaveStatus: String, Codable, CaseIterable, Identifiable {
    case planned = "예정"
    case used = "사용완료"
    case cancelled = "취소"
    
    public var id: String { rawValue }
    
    public var color: String {
        switch self {
        case .planned: return "blue"
        case .used: return "green"
        case .cancelled: return "gray"
        }
    }
}

public enum BonusLeaveType: String, Codable, CaseIterable, Identifiable {
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

    public var id: String { rawValue }

    /// 휴가 유형명 원문(예: "자녀돌봄(1/2)", "포상휴가")에서 대응하는 보너스 유형을 추론.
    /// 사진 가져오기에서 특별휴가류를 보너스 연차와 자동 연결할 때 사용.
    /// 휴가 카테고리에 대응하는 보너스 유형 — 대체휴무·공가·병가는 이름이 같은 보너스에서 쓴다.
    /// 메모가 비어 있거나 한국어가 아니어도 카테고리만으로 연결되게 한다.
    public init?(category: LeaveType) {
        switch category {
        case .compensatory: self = .compensatory
        case .official: self = .official
        case .sick: self = .sick
        default: return nil
        }
    }

    public static func matching(_ text: String) -> BonusLeaveType? {
        let table: [(keyword: String, type: BonusLeaveType)] = [
            ("대체", .compensatory), ("보상", .compensatory),
            ("포상", .reward),
            ("리프레시", .refresh), ("안식", .refresh),
            ("결혼", .marriage),
            ("조의", .bereavement), ("사망", .bereavement), ("장례", .bereavement),
            ("병가", .sick), ("병휴", .sick),
            ("임신", .maternity), ("출산", .maternity), ("육아", .maternity),
            ("돌봄", .familyBalance), ("일가정", .familyBalance), ("가족", .familyBalance),
            ("공가", .official),
        ]
        return table.first { text.contains($0.keyword) }?.type
    }

    public var icon: String {
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
public struct Holiday: Identifiable {
    public let id: UUID = UUID()
    public let date: Date
    public let name: String
    public let isSubstitute: Bool
    public let isCustom: Bool
    /// 내 방학(교사·학생) — 공휴일처럼 쉬는 날이지만 달력에서 색을 달리한다
    public let isBreak: Bool
    /// 정부가 정한 공동 휴가(인도네시아 cuti bersama) — 쉬는 날이지만 연휴 이름은 진짜 공휴일을 따른다
    public var isCollective = false
    /// 내가 켠 문화별 명절(`CulturalFestival`) — 나라 공휴일이 아니지만 쉬는 날로 센다
    public var isCultural = false

    public init(date: Date, name: String, isSubstitute: Bool = false, isCustom: Bool = false, isBreak: Bool = false) {
        self.date = date
        self.name = name
        self.isSubstitute = isSubstitute
        self.isCustom = isCustom
        self.isBreak = isBreak
    }
}

public enum SchoolBreakKind: String, CaseIterable, Identifiable {
    /// 자녀 방학 — 참고용. 달력에 표시하고 그 기간의 추천을 앞세운다. 내 연차 계산은 그대로.
    case child
    /// 내 방학(교사·학생) — 공휴일처럼 쉬는 날. 연차 차감 없음, 추천·번아웃 계산에서 휴식으로 본다.
    case mine
    /// 휴가 불가 기간 — 직장 규정상 휴가를 낼 수 없는 기간(결산·성수기 등). 쉬는 날이 아니라 일하는 날이며,
    /// 추천·최적 플랜이 피하고 휴가 등록 때 경고한다. 방학과 같은 모델에 담아 동기화·타임머신을 그대로 탄다.
    /// ⚠️ 이 값을 모르는 예전 버전은 자녀 방학(`child`)으로 읽는다 — 연차 계산엔 영향 없음.
    case blackout

    public var id: String { rawValue }
}

/// 가족 기념일의 종류 — 표시 이름·아이콘·"몇 번째" 문구가 달라진다
public enum AnniversaryKind: String, CaseIterable, Identifiable {
    case birthday
    case wedding
    /// 기일·제사
    case memorial
    case other

    public var id: String { rawValue }

    public var symbol: String {
        switch self {
        case .birthday: return "birthday.cake.fill"
        case .wedding: return "heart.fill"
        case .memorial: return "leaf.fill"
        case .other: return "star.fill"
        }
    }
}

/// 음력(중국력) 변환 — 한국 음력과 같은 달력. 음력 생신·제사를 해마다 양력으로 옮길 때 쓴다.
public enum LunarDate {
    private static func chinese(_ calendar: Calendar) -> Calendar {
        var c = Calendar(identifier: .chinese)
        c.timeZone = calendar.timeZone
        return c
    }

    public static func components(from date: Date, calendar: Calendar = .app) -> (month: Int, day: Int, isLeap: Bool) {
        let comps = chinese(calendar).dateComponents([.month, .day], from: date)
        return (comps.month ?? 1, comps.day ?? 1, comps.isLeapMonth ?? false)
    }

    /// 양력 `year` 의 설 이후 시작하는 음력 해에서 음력 월·일의 양력 날짜.
    /// 윤달이 없는 해는 평달로, 30일이 없는 달은 29일로 당긴다.
    public static func occurrence(month: Int, day: Int, isLeap: Bool, inLunarYearStartingIn year: Int,
                           calendar: Calendar = .app) -> Date? {
        let lunarCal = chinese(calendar)
        guard let midYear = calendar.date(from: DateComponents(year: year, month: 7, day: 1)) else { return nil }
        let era = lunarCal.component(.era, from: midYear)
        let lunarYear = lunarCal.component(.year, from: midYear)
        for leap in (isLeap ? [true, false] : [false]) {
            for d in stride(from: day, through: max(day - 2, 1), by: -1) {
                var comps = DateComponents()
                comps.era = era
                comps.year = lunarYear
                comps.month = month
                comps.day = d
                comps.isLeapMonth = leap
                guard let date = lunarCal.date(from: comps) else { continue }
                let check = lunarCal.dateComponents([.month, .day], from: date)
                if check.month == month, check.day == d, (check.isLeapMonth ?? false) == leap {
                    return calendar.startOfDay(for: date)
                }
            }
        }
        return nil
    }

    public static func label(from date: Date, calendar: Calendar = .app) -> String {
        let c = components(from: date, calendar: calendar)
        return Strings.lunarDateLabel(month: c.month, day: c.day, isLeap: c.isLeap)
    }
}

/// 근무 형태 — 온보딩·설정에서 고른다. 형태에 맞는 기능만 보이고 쉬는 날 계산에 쓰인다.
/// 다른 형태로 바꿔도 파트타임 요일·교대 휴무 기록은 지우지 않는다 (다시 바꾸면 그대로 돌아온다).
public enum WorkPattern: String, CaseIterable, Identifiable {
    /// 매주 같은 요일 근무 (주말만 쉼)
    case fixed
    /// 매주 쉬는 요일이 정해져 있고 가끔 그 주만 옮긴다 (네덜란드 피드백)
    case partTime
    /// 쉬는 날이 주마다 바뀐다 — 날짜마다 휴무·근무를 정한다 (교대 근무 피드백)
    case shift

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .fixed: return "calendar"
        case .partTime: return "calendar.badge.minus"
        case .shift: return "arrow.triangle.2.circlepath"
        }
    }
}
