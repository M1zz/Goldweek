//
//  Models.swift
//  Goldweek
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
    case mexico = "mexico"
    case argentina = "argentina"
    case chile = "chile"
    case colombia = "colombia"
    case newZealand = "newzealand"
    case russia = "russia"           // 정부가 해마다 휴일을 옮긴다 (перенос выходных)
    case indonesia = "indonesia"     // 공휴일·공동 휴가를 해마다 SKB 로 정한다
    /// 지원하지 않는 나라 — 기본 공휴일 없이 사용자가 직접 넣는다 (예: 남아공)
    case custom = "custom"

    var id: String { rawValue }

    var displayName: String {
        Strings.countryDisplayName(self)
    }

    /// ISO 3166-1 지역 코드 — 기기 지역(`Locale.current.region`)과 맞춰 본다
    var regionCode: String {
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
        case .mexico: return "MX"
        case .argentina: return "AR"
        case .chile: return "CL"
        case .colombia: return "CO"
        case .newZealand: return "NZ"
        case .russia: return "RU"
        case .indonesia: return "ID"
        case .custom: return ""   // 어떤 기기 지역과도 맞지 않게
        }
    }

    var flag: String {
        if self == .custom { return "🌐" }
        // 지역 코드 두 글자를 국기 이모지(Regional Indicator)로 바꾼다
        return String(String.UnicodeScalarView(regionCode.unicodeScalars.compactMap {
            UnicodeScalar(0x1F1E6 - 0x41 + $0.value)
        }))
    }

    var localeIdentifier: String {
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
        case .mexico: return "es_MX"
        case .argentina: return "es_AR"
        case .chile: return "es_CL"
        case .colombia: return "es_CO"
        case .newZealand: return "en_NZ"
        case .russia: return "ru_RU"
        case .indonesia: return "id_ID"
        case .custom: return Locale.current.identifier
        }
    }

    /// 주말 요일 (Calendar weekday: 1=일 … 7=토). 사우디·카타르 등 걸프 지역 다수는 금·토.
    /// 직접 입력은 사용자가 고른 값을 `HolidayService.weekendDays(for:)`가 돌려준다.
    var standardWeekendDays: Set<Int> {
        switch self {
        case .saudiArabia, .qatar, .egypt: return [6, 7]
        default: return [1, 7]
        }
    }

    /// 그 나라 달력의 첫 요일 (Calendar weekday: 1=일, 2=월, 7=토) — 스페인·유럽 대부분은 월, 미국·한국은 일.
    /// 기기 언어와 상관없이 나라의 관습(CLDR)을 따른다.
    var standardFirstWeekday: Int {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: localeIdentifier)
        return cal.firstWeekday
    }

    /// 이슬람력(달 관측) 공휴일이 있는 나라 — 날짜가 공식 발표에서 하루쯤 바뀔 수 있다
    var hasMoonSightingHolidays: Bool {
        switch self {
        case .uae, .saudiArabia, .qatar, .turkey, .egypt: return true
        default: return false
        }
    }

    /// 주·지역마다 공휴일이 다른 나라의 지역 목록. 비어 있으면 전국 공통 공휴일만 있다.
    var holidayRegions: [HolidayRegion] {
        HolidayRegion.all.filter { $0.country == self }
    }

    static func fromDeviceLocale() -> Country {
        detect().country
    }

    /// 기기 **지역**으로 국가를 정한다. 언어만 보면 영국·호주 사용자가 미국 공휴일을,
    /// 대만·홍콩 사용자가 중국 본토 공휴일을 보게 된다.
    /// 지원하지 않는 지역이면 언어로 가장 가까운 나라를 고르고 `isSupported = false` 로 알린다.
    static func detect(locale: Locale = .current) -> (country: Country, isSupported: Bool) {
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
        default: fallback = .usa
        }
        return (fallback, false)
    }

    /// 기기 지역이 지원하지 않는 곳이면 그 지역 코드 (예: "AT"). 지원하는 곳이거나 알 수 없으면 nil.
    static var unsupportedDeviceRegion: String? {
        guard let region = Locale.current.region?.identifier,
              !allCases.contains(where: { $0.regionCode == region }) else { return nil }
        return region
    }
}

// MARK: - 대륙 (국가 선택 대분류)

/// 국가 선택을 대륙 → 나라 2단계로 찾게 묶는다. 직접 입력(.custom)은 어느 대륙에도 넣지 않는다.
enum Continent: String, CaseIterable, Identifiable {
    case asia, middleEast, europe, africa, northAmerica, southAmerica, oceania

    var id: String { rawValue }

    var countries: [Country] {
        Country.allCases.filter { $0.continent == self }
            .sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
    }

    var displayName: String { Strings.continentName(self) }

    var icon: String {
        switch self {
        case .asia, .oceania: return "globe.asia.australia.fill"
        case .middleEast, .europe, .africa: return "globe.europe.africa.fill"
        case .northAmerica, .southAmerica: return "globe.americas.fill"
        }
    }
}

extension Country {
    var continent: Continent? {
        switch self {
        case .korea, .japan, .china, .taiwan, .hongKong, .indonesia: return .asia
        case .uae, .saudiArabia, .qatar, .turkey: return .middleEast
        case .germany, .france, .uk, .spain, .italy, .netherlands, .belgium, .austria, .switzerland, .ireland, .portugal,
             .sweden, .norway, .denmark, .finland, .poland, .czechia, .greece, .russia: return .europe
        case .egypt, .southAfrica: return .africa
        case .usa, .canada, .mexico: return .northAmerica
        case .brazil, .peru, .argentina, .chile, .colombia: return .southAmerica
        case .australia, .newZealand: return .oceania
        case .custom: return nil
        }
    }
}

// MARK: - 공휴일 지역 (주·자치주·주/준주)

/// 나라 안에서 지역마다 공휴일이 다른 경우의 지역. 코드는 ISO 3166-2 (예: "DE-BY").
/// 이름은 현지 표기를 기본으로 하고, 그 나라 말이 아닌 화면에서는 영어 이름을 쓴다.
struct HolidayRegion: Identifiable, Hashable {
    let code: String
    let country: Country
    let localName: String
    let englishName: String?

    var id: String { code }

    var displayName: String {
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

    static func find(_ code: String) -> HolidayRegion? {
        all.first { $0.code == code }
    }

    private static func r(_ code: String, _ country: Country, _ local: String, _ english: String? = nil) -> HolidayRegion {
        HolidayRegion(code: code, country: country, localName: local, englishName: english)
    }

    static let all: [HolidayRegion] = [
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

// MARK: - 사용자 유형

enum UserType: String, Codable, CaseIterable, Identifiable {
    case employee = "employee"   // 직장인 — 연차 관리
    case leisure = "leisure"     // 자유 계획 — 연차 없이 휴가 플래닝

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .employee: return Strings.userTypeEmployee
        case .leisure: return Strings.userTypeLeisure
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
    
    var remainingLeave: Double {
        totalAnnualLeave - usedLeave
    }

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
    /// 휴가 길이(종일/반차/반반차). nil이면 레거시 기록으로, typeRaw의 반차/반반차에서 추론한다.
    var lengthRaw: String?

    init(
        startDate: Date,
        endDate: Date,
        type: LeaveType = .annual,
        status: LeaveStatus = .planned,
        note: String = "",
        isRecommended: Bool = false,
        length: LeaveLength? = nil,
        bonusLeaveId: UUID? = nil
    ) {
        self.id = UUID()
        self.startDate = startDate
        self.endDate = endDate
        self.typeRaw = type.rawValue
        self.statusRaw = status.rawValue
        self.bonusLeaveId = bonusLeaveId
        self.lengthRaw = length?.rawValue
        self.note = note
        self.isRecommended = isRecommended
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
        let components = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }

    /// 실제 차감 일수 — 반차/반반차 길이는 하루 비율, 종일은 **쉬는 날을 뺀 평일 수**.
    ///
    /// 금~월로 등록해도 주말·공휴일·내 방학은 차감하지 않는다 (쉬는 날 판정: `DayOffCalendar`).
    /// 예외: "이전 사용 연차 일괄 입력"은 N일을 달력 일수로 펼쳐 저장한 요약 기록이라 달력 일수 그대로 센다.
    var effectiveLeaveDays: Double {
        if length != .full { return length.fraction }
        if isBulkSummary { return Double(daysCount) }
        return Double(DayOffCalendar.shared.workdays(from: startDate, to: endDate))
    }

    /// "이전 사용 연차 (일괄 입력)" 요약 기록인지 — 메모로 판별한다 (백업·복원을 거쳐도 남는 유일한 표식).
    /// 입력 당시 앱 언어로 저장되므로 모든 언어의 문구와 비교한다.
    var isBulkSummary: Bool {
        Self.bulkSummaryNotes.contains(note)
    }

    static let bulkSummaryNotes: Set<String> = [
        "이전 사용 연차 (일괄 입력)", "Prior leave (bulk entry)", "過去の有給（一括入力）",
        "过去的年假（批量录入）", "Früherer Urlaub (Sammeleingabe)", "Congés antérieurs (saisie groupée)",
    ]

    /// 실제 연차 차감 여부 — bonusLeaveId가 있으면 보너스 차감이므로 연차 차감 아님
    var deductsFromAnnualLeave: Bool {
        category.deductsFromAnnual && bonusLeaveId == nil
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

    /// 순수 카테고리 목록 — 길이 축 분리 후 입력 UI에 노출한다. 레거시 반차/반반차는 길이로 흡수되므로 제외.
    static var categories: [LeaveType] {
        [.annual, .compensatory, .official, .sick, .special, .businessTrip]
    }

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

/// 휴가 길이(사용 단위) — 휴가 카테고리와 직교하는 축.
/// 어떤 휴가 종류(연차·특별휴가·병가 등)든 종일/반차/반반차로 사용할 수 있어 카테고리 n × 길이 3 조합이 성립한다.
enum LeaveLength: String, Codable, CaseIterable, Identifiable {
    case full = "종일"
    case half = "반차"
    case quarter = "반반차"

    var id: String { rawValue }

    /// 하루 대비 사용 비율 (종일 1.0, 반차 0.5, 반반차 0.25)
    var fraction: Double {
        switch self {
        case .full: return 1.0
        case .half: return 0.5
        case .quarter: return 0.25
        }
    }

    var icon: String {
        switch self {
        case .full: return "sun.max"
        case .half: return "clock.badge"
        case .quarter: return "clock"
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

// MARK: - 기존 기록 길이 보정 (마이그레이션)
/// 파서 개선 이전에 저장된 기록을 보정한다.
/// note에 "(1/2)"·"½" 같은 분수 표기가 있는데 길이가 종일(1일)로 남아 있으면 실제 길이(반차/반반차)로 교정.
/// 예) "자녀돌봄(1/2)"이 1일로 저장된 과거 데이터를 0.5일로 되돌린다.
enum LeaveRecordMaintenance {
    @discardableResult
    static func backfillLengths(records: [LeaveRecord]) -> Bool {
        var changed = false
        let cal = Calendar.current
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
    /// 1) 연차를 차감하지 않는 미연결 특별휴가 기록을, 유형(이름)이 맞고 잔여가 충분한 보너스에 자동 연결
    /// 2) 모든 보너스의 `usedDays`/`isUsed`를 연결된 기록 기준으로 재산정
    /// - Returns: 데이터가 실제로 변경되면 true (호출 측에서 save 트리거용)
    @discardableResult
    static func reconcile(records: [LeaveRecord], bonuses: [BonusLeave]) -> Bool {
        guard !bonuses.isEmpty else { return false }
        var changed = false

        // 잔여 추적 — 이미 연결된 기록부터 차감
        var remaining: [UUID: Double] = [:]
        for b in bonuses { remaining[b.id] = b.days }
        for r in records {
            guard let id = r.bonusLeaveId, remaining[id] != nil else { continue }
            remaining[id]! -= r.effectiveLeaveDays
        }

        // 1단계: 미연결 특별휴가 → 유형 매칭 보너스 자동 연결 (오래된 기록부터 안정적으로)
        for r in records.sorted(by: { $0.startDate < $1.startDate }) {
            guard r.bonusLeaveId == nil, !r.type.deductsFromAnnual else { continue }
            guard let matchType = BonusLeaveType.matching(r.note) else { continue }
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
                .filter { $0.bonusLeaveId == b.id }
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

    /// 휴가 유형명 원문(예: "자녀돌봄(1/2)", "포상휴가")에서 대응하는 보너스 유형을 추론.
    /// 사진 가져오기에서 특별휴가류를 보너스 연차와 자동 연결할 때 사용.
    static func matching(_ text: String) -> BonusLeaveType? {
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

extension LeaveRecommendation {
    /// 추천 기간 중 **실제로 연차를 내야 하는 날**만 연속 구간으로 묶는다.
    ///
    /// 추천의 startDate~endDate는 "쉬는 기간 전체"(주말·공휴일 포함)다. 그대로 등록하면
    /// 주말·공휴일까지 휴가로 잡히고, 차감 일수(달력 일수)도 그만큼 부풀어 연차가 과하게 빠진다.
    func leaveSegments(holidays: [Holiday], country: Country = DayOffCalendar.shared.country, calendar: Calendar = .current) -> [(start: Date, end: Date)] {
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

// MARK: - 공휴일
struct Holiday: Identifiable {
    let id: UUID = UUID()
    let date: Date
    let name: String
    let isSubstitute: Bool
    let isCustom: Bool
    /// 내 방학(교사·학생) — 공휴일처럼 쉬는 날이지만 달력에서 색을 달리한다
    let isBreak: Bool
    /// 정부가 정한 공동 휴가(인도네시아 cuti bersama) — 쉬는 날이지만 연휴 이름은 진짜 공휴일을 따른다
    var isCollective = false

    init(date: Date, name: String, isSubstitute: Bool = false, isCustom: Bool = false, isBreak: Bool = false) {
        self.date = date
        self.name = name
        self.isSubstitute = isSubstitute
        self.isCustom = isCustom
        self.isBreak = isBreak
    }
}

// MARK: - 방학

enum SchoolBreakKind: String, CaseIterable, Identifiable {
    /// 자녀 방학 — 참고용. 달력에 표시하고 그 기간의 추천을 앞세운다. 내 연차 계산은 그대로.
    case child
    /// 내 방학(교사·학생) — 공휴일처럼 쉬는 날. 연차 차감 없음, 추천·번아웃 계산에서 휴식으로 본다.
    case mine

    var id: String { rawValue }
}

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
        self.startDate = Calendar.current.startOfDay(for: startDate)
        self.endDate = Calendar.current.startOfDay(for: endDate)
        self.kindRaw = kind.rawValue
        self.createdAt = Date()
    }

    var kind: SchoolBreakKind {
        get { SchoolBreakKind(rawValue: kindRaw) ?? .child }
        set { kindRaw = newValue.rawValue }
    }

    func contains(_ date: Date) -> Bool {
        let d = Calendar.current.startOfDay(for: date)
        return d >= Calendar.current.startOfDay(for: startDate) && d <= Calendar.current.startOfDay(for: endDate)
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
    func occurrence(in year: Int, calendar: Calendar = .current) -> Date? {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        if !repeatsYearly { return comps.year == year ? calendar.startOfDay(for: date) : nil }
        guard let d = calendar.date(from: DateComponents(year: year, month: comps.month, day: comps.day)),
              calendar.component(.day, from: d) == comps.day else { return nil }
        return d
    }
}
