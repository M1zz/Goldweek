//
//  RecommendationEngine.swift
//  Goldweek
//
//  휴가 추천 엔진 (다국가 지원)
//

import Foundation

class RecommendationEngine {

    private let holidayService = HolidayService()
    private let calendar = Calendar.current

    // 캐싱
    private var cachedRecommendations: [LeaveRecommendation] = []
    private var cacheKey: String = ""
    private var cacheTimestamp: Date?
    private let cacheValidDuration: TimeInterval = 3600 // 1시간

    // MARK: - 추천 생성

    func generateRecommendations(
        for profile: UserProfile,
        remainingLeave: Double,
        year: Int,
        country: Country? = nil,
        includePast: Bool = false   // true면 현재 날짜 이전 황금연휴도 함께 노출 (한 해 전체 보기)
    ) -> [LeaveRecommendation] {
        let targetCountry = country ?? profile.country
        logDebug("추천 생성 시작 - 연도: \(year), 잔여연차: \(remainingLeave), 국가: \(targetCountry.rawValue), includePast: \(includePast)", category: .recommendation)

        // 캐시 키 생성 — includePast도 키에 포함 (토글하면 캐시 무효화 효과)
        let newCacheKey = "\(year)-\(remainingLeave)-\(profile.preferredDurationRaw)-\(profile.preferredSeasonsRaw)-\(profile.preferLongWeekend)-\(profile.avoidPeakSeason)-\(targetCountry.rawValue)-past:\(includePast)"

        // 캐시 유효성 확인
        if let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) < cacheValidDuration,
           cacheKey == newCacheKey,
           !cachedRecommendations.isEmpty {
            logDebug("캐시 히트 - \(cachedRecommendations.count)개 추천 반환", category: .recommendation)
            return cachedRecommendations
        }

        logDebug("캐시 미스 - 새로운 추천 생성", category: .recommendation)

        var recommendations: [LeaveRecommendation] = []
        let holidays = holidayService.getHolidays(for: year, country: targetCountry)
        logDebug("\(year)년 공휴일 \(holidays.count)개 로드", category: .recommendation)

        // 1. 연차 없이 쉴 수 있는 황금연휴 자동 감지
        let goldenWeeksNoLeave = findGoldenWeeksWithoutLeave(holidays: holidays, year: year)
        recommendations.append(contentsOf: goldenWeeksNoLeave)

        // 2. 황금연휴 기회 탐색 (연차 활용)
        let goldenWeeks = findGoldenWeekOpportunities(holidays: holidays, year: year, country: targetCountry)
        recommendations.append(contentsOf: goldenWeeks)

        // 3. 징검다리 휴일 찾기
        let bridgeDays = findBridgeDayOpportunities(holidays: holidays, year: year)
        recommendations.append(contentsOf: bridgeDays)

        // 4. 연속 휴가 기회
        let consecutiveDays = findConsecutiveOpportunities(holidays: holidays, year: year)
        recommendations.append(contentsOf: consecutiveDays)

        // 5. 선호도 기반 필터링 및 점수 계산
        var scoredRecommendations = recommendations.map { recommendation in
            var scored = recommendation
            scored.matchScore = calculateMatchScore(
                recommendation: recommendation,
                profile: profile
            )
            return scored
        }

        // 6. 남은 연차 기준 필터링
        scoredRecommendations = scoredRecommendations.filter { $0.requiredLeaveDays <= remainingLeave }

        // 7. 현재 날짜 이후만 (includePast가 false일 때) — true면 한 해 전체 노출
        if !includePast {
            let today = Date()
            scoredRecommendations = scoredRecommendations.filter { $0.startDate > today }
        }

        // 8. 성수기 회피 필터링 (선호도 설정 반영)
        if profile.avoidPeakSeason {
            scoredRecommendations = scoredRecommendations.filter { recommendation in
                let month = calendar.component(.month, from: recommendation.startDate)
                let peakMonths = [7, 8]
                return !peakMonths.contains(month)
            }
        }

        // 9. 의미없는 추천 제거 (정교한 필터링)
        scoredRecommendations = scoredRecommendations.filter { recommendation in
            if recommendation.requiredLeaveDays == 0 && recommendation.totalDaysOff >= 3 {
                let recommendationYear = calendar.component(.year, from: recommendation.startDate)
                return recommendationYear == year
            }

            guard recommendation.efficiency >= 1.5 else { return false }
            guard recommendation.totalDaysOff >= 3 else { return false }

            // 5일 이상 연차를 쓰는 경우는 효율 기준을 더 엄격하게 (긴 연차는 진짜 가치 있을 때만)
            if recommendation.requiredLeaveDays >= 5 && recommendation.efficiency < 1.6 {
                return false
            }

            let recommendationYear = calendar.component(.year, from: recommendation.startDate)
            if recommendationYear != year {
                return false
            }

            return true
        }

        // 10. 중복 제거
        scoredRecommendations = removeDuplicateRecommendations(scoredRecommendations)

        // 11. 효율성 + 매칭점수로 정렬 (각 월 내부 우선순위)
        scoredRecommendations.sort { ($0.efficiency + $0.matchScore) > ($1.efficiency + $1.matchScore) }

        // 12. 월별 라운드 로빈으로 시기 다양성 확보
        // 가까운 미래의 월부터 1개씩 돌아가며 배치 → 5월·6월·9월·10월 등 골고루 보임
        scoredRecommendations = diversifyByMonth(scoredRecommendations)

        // 캐시 저장
        cachedRecommendations = scoredRecommendations
        cacheKey = newCacheKey
        cacheTimestamp = Date()

        logInfo("추천 생성 완료 - \(scoredRecommendations.count)개 추천", category: .recommendation)
        return scoredRecommendations
    }

    /// 월별 라운드 로빈으로 추천 재배치 (시기 다양성)
    /// - 입력: 효율성 순으로 정렬된 추천 리스트
    /// - 출력: 가까운 미래의 월부터 1개씩 돌아가며 배치된 리스트
    /// - 각 월 내부에서는 효율성 높은 순서가 유지됨
    private func diversifyByMonth(_ sorted: [LeaveRecommendation]) -> [LeaveRecommendation] {
        guard sorted.count > 3 else { return sorted }

        let byMonth = Dictionary(grouping: sorted) { rec in
            calendar.component(.month, from: rec.startDate)
        }

        // 가까운 미래의 월 우선 (오늘 월부터 1년 후까지의 거리 순)
        let currentMonth = calendar.component(.month, from: Date())
        let monthsAvailable = byMonth.keys.sorted { a, b in
            let aDist = (a - currentMonth + 12) % 12
            let bDist = (b - currentMonth + 12) % 12
            return aDist < bDist
        }

        var result: [LeaveRecommendation] = []
        var indices: [Int: Int] = [:]
        let totalCount = sorted.count

        // 라운드 로빈: 각 월에서 1개씩 돌아가면서 추가
        while result.count < totalCount {
            var addedThisRound = false
            for month in monthsAvailable {
                let i = indices[month, default: 0]
                if let monthRecs = byMonth[month], i < monthRecs.count {
                    result.append(monthRecs[i])
                    indices[month] = i + 1
                    addedThisRound = true
                }
            }
            if !addedThisRound { break }
        }
        return result
    }

    // MARK: - 중복 제거

    private func removeDuplicateRecommendations(_ recommendations: [LeaveRecommendation]) -> [LeaveRecommendation] {
        var result: [LeaveRecommendation] = []

        let sorted = recommendations.sorted {
            ($0.efficiency + $0.matchScore) > ($1.efficiency + $1.matchScore)
        }

        for recommendation in sorted {
            // 같은 카테고리(둘 다 무료 또는 둘 다 연차필요) 안에서만 날짜 중복 체크.
            // 추석 5일 무료 추천과 추석 9일 연차활용 추천은 서로 다른 가치 제안이므로 둘 다 노출.
            let isFree = recommendation.requiredLeaveDays == 0
            let hasSignificantOverlap = result.contains { existing in
                let existingIsFree = existing.requiredLeaveDays == 0
                guard isFree == existingIsFree else { return false }
                return datesOverlapSignificantly(
                    start1: existing.startDate, end1: existing.endDate,
                    start2: recommendation.startDate, end2: recommendation.endDate,
                    threshold: 0.5
                )
            }

            if hasSignificantOverlap {
                continue
            }

            let month = calendar.component(.month, from: recommendation.startDate)
            let sameMonthCount = result.filter {
                calendar.component(.month, from: $0.startDate) == month
            }.count

            // 한 달에 최대 5개까지 허용 (3 → 5로 완화: 10월처럼 공휴일 많은 달에 선택지 다양화)
            if sameMonthCount >= 5 {
                continue
            }

            result.append(recommendation)
        }

        return result
    }

    private func datesOverlapSignificantly(start1: Date, end1: Date, start2: Date, end2: Date, threshold: Double) -> Bool {
        let overlapStart = max(start1, start2)
        let overlapEnd = min(end1, end2)

        if overlapStart > overlapEnd {
            return false
        }

        let overlapDays = calendar.dateComponents([.day], from: overlapStart, to: overlapEnd).day ?? 0
        let period1Days = calendar.dateComponents([.day], from: start1, to: end1).day ?? 0
        let period2Days = calendar.dateComponents([.day], from: start2, to: end2).day ?? 0

        let minPeriod = min(period1Days, period2Days)

        return minPeriod > 0 && Double(overlapDays) / Double(minPeriod) >= threshold
    }

    /// 캐시 무효화
    func invalidateCache() {
        logDebug("추천 캐시 무효화", category: .recommendation)
        cachedRecommendations = []
        cacheKey = ""
        cacheTimestamp = nil
    }

    // MARK: - 연차 없이 쉴 수 있는 황금연휴 자동 감지

    private func findGoldenWeeksWithoutLeave(holidays: [Holiday], year: Int) -> [LeaveRecommendation] {
        var recommendations: [LeaveRecommendation] = []

        var components = DateComponents()
        components.year = year
        components.month = 1
        components.day = 1

        guard let yearStart = calendar.date(from: components) else { return [] }

        components.month = 12
        components.day = 31
        guard let yearEnd = calendar.date(from: components) else { return [] }

        var currentDate = yearStart
        var consecutiveStart: Date?
        var consecutiveDays: [Date] = []
        var includedHolidays: [String] = []

        while currentDate <= yearEnd {
            let isOff = isNonWorkingDay(currentDate, holidays: holidays)

            if isOff {
                if consecutiveStart == nil {
                    consecutiveStart = currentDate
                }
                consecutiveDays.append(currentDate)

                if let holiday = holidays.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                    if !includedHolidays.contains(holiday.name) && !holiday.name.contains(Strings.substituteHoliday) {
                        includedHolidays.append(holiday.name)
                    }
                }
            } else {
                if consecutiveDays.count >= 3, let start = consecutiveStart {
                    let end = consecutiveDays.last!
                    let recommendation = createGoldenWeekRecommendation(
                        start: start,
                        end: end,
                        totalDays: consecutiveDays.count,
                        holidayNames: includedHolidays,
                        year: year
                    )
                    recommendations.append(recommendation)
                }

                consecutiveStart = nil
                consecutiveDays = []
                includedHolidays = []
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        if consecutiveDays.count >= 3, let start = consecutiveStart {
            let end = consecutiveDays.last!
            let recommendation = createGoldenWeekRecommendation(
                start: start,
                end: end,
                totalDays: consecutiveDays.count,
                holidayNames: includedHolidays,
                year: year
            )
            recommendations.append(recommendation)
        }

        return recommendations
    }

    private func isNonWorkingDay(_ date: Date, holidays: [Holiday]) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        let isWeekend = weekday == 1 || weekday == 7
        let isHoliday = holidays.contains { calendar.isDate($0.date, inSameDayAs: date) }
        return isWeekend || isHoliday
    }

    private func createGoldenWeekRecommendation(
        start: Date,
        end: Date,
        totalDays: Int,
        holidayNames: [String],
        year: Int
    ) -> LeaveRecommendation {
        let title = generateGoldenWeekTitle(holidayNames: holidayNames, totalDays: totalDays)

        let description = generateGoldenWeekDescription(
            start: start,
            end: end,
            totalDays: totalDays,
            holidayNames: holidayNames
        )

        var tags = [Strings.goldenWeek, Strings.noLeaveRequired]
        tags.append(contentsOf: holidayNames.prefix(2))
        tags.append(Strings.seasonTag(for: calendar.component(.month, from: start)))

        return LeaveRecommendation(
            title: title,
            description: description,
            startDate: start,
            endDate: end,
            requiredLeaveDays: 0,
            totalDaysOff: totalDays,
            tags: tags,
            reason: holidayNames.isEmpty ? Strings.weekendHoliday : holidayNames.joined(separator: " + ")
        )
    }

    private func generateGoldenWeekTitle(holidayNames: [String], totalDays: Int) -> String {
        if holidayNames.isEmpty {
            return Strings.daysHoliday(totalDays)
        }

        let mainHoliday = holidayNames.first?.replacingOccurrences(of: " 연휴", with: "")
            .replacingOccurrences(of: " Holiday", with: "")
            .replacingOccurrences(of: "連休", with: "")
            .replacingOccurrences(of: "假期", with: "") ?? ""

        if totalDays >= 4 {
            return Strings.goldenWeekTitle(holidayName: mainHoliday)
        } else {
            return Strings.holidayBreak(name: mainHoliday)
        }
    }

    private func generateGoldenWeekDescription(
        start: Date,
        end: Date,
        totalDays: Int,
        holidayNames: [String]
    ) -> String {
        let startWeekday = getWeekdayName(for: start)
        let endWeekday = getWeekdayName(for: end)

        let holidayDesc = holidayNames.isEmpty ? Strings.weekendHoliday : holidayNames.joined(separator: " + ")

        var desc = Strings.noLeaveDaysOff(
            weekdayStart: startWeekday,
            weekdayEnd: endWeekday,
            holidayDesc: holidayDesc,
            totalDays: totalDays
        )

        let month = calendar.component(.month, from: start)
        let advice = Strings.seasonalAdvice(month: month)
        if !advice.isEmpty {
            desc += " " + advice
        }

        return desc
    }

    private func getWeekdayName(for date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        let names = Strings.weekdays
        return names[weekday - 1]
    }

    // MARK: - 황금연휴 찾기 (연차 활용)

    private func findGoldenWeekOpportunities(holidays: [Holiday], year: Int, country: Country) -> [LeaveRecommendation] {
        var opportunities: [LeaveRecommendation] = []

        switch country {
        case .korea:
            if let mayOpportunity = findMayGoldenWeek(holidays: holidays, year: year) {
                opportunities.append(mayOpportunity)
            }
            opportunities.append(contentsOf: findMajorHolidayExtensions(holidays: holidays, year: year, country: country))

        case .japan:
            // Japan: Golden Week (4/29 - 5/5)
            if let gwOpportunity = findJapanGoldenWeek(holidays: holidays, year: year) {
                opportunities.append(gwOpportunity)
            }
            // Obon, Year-end
            opportunities.append(contentsOf: findJapanSeasonalOpportunities(holidays: holidays, year: year))

        case .china:
            // Spring Festival, National Day extensions
            opportunities.append(contentsOf: findMajorHolidayExtensions(holidays: holidays, year: year, country: country))

        case .usa:
            // Thanksgiving weekend, 4th of July, Memorial/Labor Day
            opportunities.append(contentsOf: findUSAOpportunities(holidays: holidays, year: year))

        case .germany, .france:
            // 알고리즘 기반 OptimalLeavePlannerCard가 자동 처리 (Brückentag / pont)
            // 여기서는 일반적인 공휴일 연장만 제공
            opportunities.append(contentsOf: findMajorHolidayExtensions(holidays: holidays, year: year, country: country))
        }

        return opportunities
    }

    private func findMayGoldenWeek(holidays: [Holiday], year: Int) -> LeaveRecommendation? {
        var components = DateComponents()
        components.year = year
        components.month = 5

        let mayHolidays = holidays.filter {
            calendar.component(.month, from: $0.date) == 5
        }

        guard !mayHolidays.isEmpty else { return nil }

        components.day = 1
        guard let may1 = calendar.date(from: components) else { return nil }

        components.day = 5
        guard let may5 = calendar.date(from: components) else { return nil }

        var requiredLeave = 0.0
        var currentDate = may1

        while currentDate <= may5 {
            let weekday = calendar.component(.weekday, from: currentDate)
            let isWeekend = weekday == 1 || weekday == 7
            let isHoliday = holidays.contains { calendar.isDate($0.date, inSameDayAs: currentDate) }

            if !isWeekend && !isHoliday {
                requiredLeave += 1
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        components.day = 1
        let startDate = calendar.date(from: components)!
        components.day = 6
        let endDate = calendar.date(from: components)!

        return LeaveRecommendation(
            title: Strings.mayGoldenWeekTitle,
            description: Strings.mayGoldenWeekDesc(leaveDays: Int(requiredLeave)),
            startDate: startDate,
            endDate: endDate,
            requiredLeaveDays: requiredLeave,
            totalDaysOff: 6,
            tags: [Strings.goldenWeek, Strings.monthShort(5), Strings.familyTrip],
            reason: "5월 연계"
        )
    }

    private func findJapanGoldenWeek(holidays: [Holiday], year: Int) -> LeaveRecommendation? {
        var components = DateComponents()
        components.year = year; components.month = 4; components.day = 29
        guard let start = calendar.date(from: components) else { return nil }
        components.month = 5; components.day = 5
        guard let end = calendar.date(from: components) else { return nil }

        var requiredLeave = 0.0
        var currentDate = start
        while currentDate <= end {
            let weekday = calendar.component(.weekday, from: currentDate)
            let isWeekend = weekday == 1 || weekday == 7
            let isHoliday = holidays.contains { calendar.isDate($0.date, inSameDayAs: currentDate) }
            if !isWeekend && !isHoliday { requiredLeave += 1 }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        let totalDays = calendar.dateComponents([.day], from: start, to: end).day! + 1

        let lang = AppLanguage.current
        let title: String
        let desc: String
        switch lang {
        case .korean:
            title = "골든위크"
            desc = "일본 골든위크! 연차 \(Int(requiredLeave))일로 \(totalDays)일 연휴."
        case .english:
            title = "Golden Week"
            desc = "Japan's Golden Week! \(Int(requiredLeave)) leave days for \(totalDays) days off."
        case .japanese:
            title = "ゴールデンウィーク"
            desc = "ゴールデンウィーク！有給\(Int(requiredLeave))日で\(totalDays)連休。"
        case .chinese:
            title = "黄金周"
            desc = "日本黄金周！请\(Int(requiredLeave))天年假获得\(totalDays)天假期。"
        }

        return LeaveRecommendation(
            title: title,
            description: desc,
            startDate: start,
            endDate: end,
            requiredLeaveDays: requiredLeave,
            totalDaysOff: totalDays,
            tags: [Strings.goldenWeek, Strings.familyTrip],
            reason: "Golden Week"
        )
    }

    private func findJapanSeasonalOpportunities(holidays: [Holiday], year: Int) -> [LeaveRecommendation] {
        var opportunities: [LeaveRecommendation] = []
        let lang = AppLanguage.current

        // Obon (Aug 11-16 typical)
        var comp = DateComponents(); comp.year = year; comp.month = 8; comp.day = 11
        if let obonStart = calendar.date(from: comp) {
            comp.day = 16
            if let obonEnd = calendar.date(from: comp) {
                var requiredLeave = 0.0
                var cur = obonStart
                while cur <= obonEnd {
                    let wd = calendar.component(.weekday, from: cur)
                    let isWE = wd == 1 || wd == 7
                    let isH = holidays.contains { calendar.isDate($0.date, inSameDayAs: cur) }
                    if !isWE && !isH { requiredLeave += 1 }
                    cur = calendar.date(byAdding: .day, value: 1, to: cur)!
                }
                let totalDays = calendar.dateComponents([.day], from: obonStart, to: obonEnd).day! + 1

                let title: String
                let desc: String
                switch lang {
                case .korean: title = "오봉 연휴"; desc = "일본 오봉 기간! 연차 \(Int(requiredLeave))일로 \(totalDays)일 연휴."
                case .english: title = "Obon Break"; desc = "Obon season! \(Int(requiredLeave)) leave days for \(totalDays) days off."
                case .japanese: title = "お盆休み"; desc = "お盆休み！有給\(Int(requiredLeave))日で\(totalDays)連休。"
                case .chinese: title = "盂兰盆节假期"; desc = "盂兰盆节！请\(Int(requiredLeave))天年假获得\(totalDays)天假期。"
                }

                opportunities.append(LeaveRecommendation(
                    title: title, description: desc,
                    startDate: obonStart, endDate: obonEnd,
                    requiredLeaveDays: requiredLeave, totalDaysOff: totalDays,
                    tags: [Strings.seasonTag(for: 8), Strings.family],
                    reason: "Obon"
                ))
            }
        }

        return opportunities
    }

    private func findUSAOpportunities(holidays: [Holiday], year: Int) -> [LeaveRecommendation] {
        var opportunities: [LeaveRecommendation] = []
        let lang = AppLanguage.current

        // Find Thanksgiving and create long weekend
        let thanksgivingHolidays = holidays.filter { h in
            let m = calendar.component(.month, from: h.date)
            let wd = calendar.component(.weekday, from: h.date)
            return m == 11 && wd == 5  // Thursday in November
        }

        if let thanksgiving = thanksgivingHolidays.first {
            // Wed before to Sun after = 5 days off with 1 leave day (Friday)
            if let wed = calendar.date(byAdding: .day, value: -1, to: thanksgiving.date),
               let sun = calendar.date(byAdding: .day, value: 3, to: thanksgiving.date) {
                let title: String
                let desc: String
                switch lang {
                case .korean: title = "추수감사절 연휴"; desc = "금요일 연차 1일로 5일 연휴!"
                case .english: title = "Thanksgiving Break"; desc = "1 leave day (Friday) for a 5-day break!"
                case .japanese: title = "感謝祭連休"; desc = "金曜1日の有給で5連休！"
                case .chinese: title = "感恩节假期"; desc = "周五请1天年假获得5天假期！"
                }

                opportunities.append(LeaveRecommendation(
                    title: title, description: desc,
                    startDate: wed, endDate: sun,
                    requiredLeaveDays: 1, totalDaysOff: 5,
                    tags: [Strings.bridgeDay, Strings.family, Strings.topEfficiency],
                    reason: "Thanksgiving"
                ))
            }
        }

        // 4th of July extension
        let julyHolidays = holidays.filter { h in
            let comp = calendar.dateComponents([.month, .day], from: h.date)
            return comp.month == 7 && comp.day == 4
        }

        if let july4 = julyHolidays.first {
            let wd = calendar.component(.weekday, from: july4.date)
            // If Tue or Thu, bridge day opportunity
            if wd == 3 { // Tuesday
                if let _ = calendar.date(byAdding: .day, value: -1, to: july4.date),
                   let prevSat = calendar.date(byAdding: .day, value: -3, to: july4.date) {
                    let title: String
                    let desc: String
                    switch lang {
                    case .korean: title = "독립기념일 연휴"; desc = "월요일 연차 1일로 4일 연휴!"
                    case .english: title = "July 4th Long Weekend"; desc = "1 leave day (Monday) for 4-day weekend!"
                    case .japanese: title = "独立記念日連休"; desc = "月曜1日の有給で4連休！"
                    case .chinese: title = "独立日假期"; desc = "周一请1天年假获得4天假期！"
                    }
                    opportunities.append(LeaveRecommendation(
                        title: title, description: desc,
                        startDate: prevSat, endDate: july4.date,
                        requiredLeaveDays: 1, totalDaysOff: 4,
                        tags: [Strings.bridgeDay, Strings.topEfficiency],
                        reason: "July 4th"
                    ))
                }
            } else if wd == 5 { // Thursday
                if let fri = calendar.date(byAdding: .day, value: 1, to: july4.date),
                   let sun = calendar.date(byAdding: .day, value: 2, to: fri) {
                    let title: String
                    let desc: String
                    switch lang {
                    case .korean: title = "독립기념일 연휴"; desc = "금요일 연차 1일로 4일 연휴!"
                    case .english: title = "July 4th Long Weekend"; desc = "1 leave day (Friday) for 4-day weekend!"
                    case .japanese: title = "独立記念日連休"; desc = "金曜1日の有給で4連休！"
                    case .chinese: title = "独立日假期"; desc = "周五请1天年假获得4天假期！"
                    }
                    opportunities.append(LeaveRecommendation(
                        title: title, description: desc,
                        startDate: july4.date, endDate: sun,
                        requiredLeaveDays: 1, totalDaysOff: 4,
                        tags: [Strings.bridgeDay, Strings.topEfficiency],
                        reason: "July 4th"
                    ))
                }
            }
        }

        return opportunities
    }

    private func findMajorHolidayExtensions(holidays: [Holiday], year: Int, country: Country) -> [LeaveRecommendation] {
        var recommendations: [LeaveRecommendation] = []

        // Find major multi-day holidays to extend
        let majorHolidays: [Holiday]
        switch country {
        case .korea:
            majorHolidays = holidays.filter {
                $0.name.contains("설날") || $0.name.contains("추석") ||
                $0.name.contains("Seollal") || $0.name.contains("Chuseok") ||
                $0.name.contains("ソルラル") || $0.name.contains("秋夕") ||
                $0.name.contains("春节") || $0.name.contains("中秋")
            }
        case .china:
            majorHolidays = holidays.filter {
                $0.name.contains("春节") || $0.name.contains("Spring Festival") ||
                $0.name.contains("国庆") || $0.name.contains("National Day") ||
                $0.name.contains("春節") || $0.name.contains("国慶")
            }
        default:
            majorHolidays = []
        }

        for holiday in majorHolidays {
            if let recommendation = analyzeHolidayExtension(holiday: holiday, holidays: holidays) {
                recommendations.append(recommendation)
            }
        }

        return recommendations
    }

    private func analyzeHolidayExtension(holiday: Holiday, holidays: [Holiday]) -> LeaveRecommendation? {
        let relatedHolidays = holidays.filter {
            abs(calendar.dateComponents([.day], from: holiday.date, to: $0.date).day ?? 100) <= 3
        }

        guard let firstDay = relatedHolidays.map({ $0.date }).min(),
              let lastDay = relatedHolidays.map({ $0.date }).max() else {
            return nil
        }

        var extendedStart = firstDay
        var extendedEnd = lastDay

        while true {
            let prevDay = calendar.date(byAdding: .day, value: -1, to: extendedStart)!
            let weekday = calendar.component(.weekday, from: prevDay)
            if weekday == 1 || weekday == 7 {
                extendedStart = prevDay
            } else {
                break
            }
        }

        while true {
            let nextDay = calendar.date(byAdding: .day, value: 1, to: extendedEnd)!
            let weekday = calendar.component(.weekday, from: nextDay)
            if weekday == 1 || weekday == 7 {
                extendedEnd = nextDay
            } else {
                break
            }
        }

        var requiredLeave = 0.0
        var currentDate = extendedStart

        while currentDate <= extendedEnd {
            let weekday = calendar.component(.weekday, from: currentDate)
            let isWeekend = weekday == 1 || weekday == 7
            let isHoliday = holidays.contains { calendar.isDate($0.date, inSameDayAs: currentDate) }

            if !isWeekend && !isHoliday {
                requiredLeave += 1
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        let totalDays = calendar.dateComponents([.day], from: extendedStart, to: extendedEnd).day! + 1
        let holidayName = holiday.name

        return LeaveRecommendation(
            title: Strings.connectedLeaveTitle(holidayName: holidayName),
            description: Strings.connectedLeaveDesc(holidayName: holidayName, leaveDays: Int(requiredLeave), totalDays: totalDays),
            startDate: extendedStart,
            endDate: extendedEnd,
            requiredLeaveDays: requiredLeave,
            totalDaysOff: totalDays,
            tags: [holidayName, Strings.majorHoliday, Strings.family],
            reason: "\(holidayName) 연계"
        )
    }

    // MARK: - 징검다리 휴일 찾기

    private func findBridgeDayOpportunities(holidays: [Holiday], year: Int) -> [LeaveRecommendation] {
        var opportunities: [LeaveRecommendation] = []

        for holiday in holidays {
            let weekday = calendar.component(.weekday, from: holiday.date)

            // 화요일인 공휴일 → 월요일 연차로 4일 연휴
            if weekday == 3 {
                if let bridgeDay = calendar.date(byAdding: .day, value: -1, to: holiday.date) {
                    let weekendStart = calendar.date(byAdding: .day, value: -2, to: bridgeDay)!

                    opportunities.append(LeaveRecommendation(
                        title: Strings.bridgeDayTitle(holidayName: holiday.name),
                        description: Strings.bridgeDayDescMonday(holidayName: holiday.name),
                        startDate: weekendStart,
                        endDate: holiday.date,
                        requiredLeaveDays: 1,
                        totalDaysOff: 4,
                        tags: [Strings.bridgeDay, Strings.topEfficiency, holiday.name],
                        reason: "화요일 공휴일 활용"
                    ))
                }
            }

            // 목요일인 공휴일 → 금요일 연차로 4일 연휴
            if weekday == 5 {
                if let bridgeDay = calendar.date(byAdding: .day, value: 1, to: holiday.date) {
                    let weekendEnd = calendar.date(byAdding: .day, value: 2, to: bridgeDay)!

                    opportunities.append(LeaveRecommendation(
                        title: Strings.bridgeDayTitle(holidayName: holiday.name),
                        description: Strings.bridgeDayDescFriday(holidayName: holiday.name),
                        startDate: holiday.date,
                        endDate: weekendEnd,
                        requiredLeaveDays: 1,
                        totalDaysOff: 4,
                        tags: [Strings.bridgeDay, Strings.topEfficiency, holiday.name],
                        reason: "목요일 공휴일 활용"
                    ))
                }
            }
        }

        return opportunities
    }

    // MARK: - 연속 휴가 기회 (공휴일 연계)

    private func findConsecutiveOpportunities(holidays: [Holiday], year: Int) -> [LeaveRecommendation] {
        var opportunities: [LeaveRecommendation] = []

        for holiday in holidays {
            let weekday = calendar.component(.weekday, from: holiday.date)

            guard weekday >= 2 && weekday <= 6 else { continue }

            let daysToMonday = -(weekday - 2)
            guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: holiday.date),
                  let friday = calendar.date(byAdding: .day, value: 4, to: monday),
                  let prevSaturday = calendar.date(byAdding: .day, value: -2, to: monday),
                  let nextSunday = calendar.date(byAdding: .day, value: 6, to: monday) else {
                continue
            }

            var holidaysInWeek = 0
            var currentDate = monday
            while currentDate <= friday {
                if holidays.contains(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                    holidaysInWeek += 1
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }

            let requiredLeave = Double(5 - holidaysInWeek)

            guard requiredLeave > 0 else { continue }

            let efficiency = 9.0 / requiredLeave

            guard efficiency >= 2.5 else { continue }

            let month = calendar.component(.month, from: holiday.date)

            opportunities.append(LeaveRecommendation(
                title: Strings.weeklyLeaveTitle(holidayName: holiday.name),
                description: Strings.weeklyLeaveDesc(holidayName: holiday.name, leaveDays: Int(requiredLeave)),
                startDate: prevSaturday,
                endDate: nextSunday,
                requiredLeaveDays: requiredLeave,
                totalDaysOff: 9,
                tags: [Strings.consecutiveLeave, Strings.seasonTag(for: month), Strings.efficient],
                reason: "\(holiday.name) 연계"
            ))
        }

        return opportunities
    }

    // MARK: - 선호도 매칭 점수 계산

    private func calculateMatchScore(recommendation: LeaveRecommendation, profile: UserProfile) -> Double {
        var score = 0.0

        let month = calendar.component(.month, from: recommendation.startDate)
        if !profile.preferredSeasons.isEmpty {
            for season in profile.preferredSeasons {
                if season.months.contains(month) {
                    score += 0.3
                    break
                }
            }
        } else {
            score += 0.1
        }

        switch profile.preferredDuration {
        case .short:
            if recommendation.totalDaysOff <= 3 { score += 0.25 }
            else if recommendation.totalDaysOff <= 4 { score += 0.1 }
        case .medium:
            if recommendation.totalDaysOff >= 3 && recommendation.totalDaysOff <= 5 { score += 0.25 }
            else if recommendation.totalDaysOff >= 2 && recommendation.totalDaysOff <= 6 { score += 0.1 }
        case .long:
            if recommendation.totalDaysOff >= 5 { score += 0.25 }
            else if recommendation.totalDaysOff >= 4 { score += 0.1 }
        case .mixed:
            score += 0.15
        }

        if profile.preferLongWeekend && recommendation.tags.contains(Strings.bridgeDay) {
            score += 0.3
        }

        if profile.preferConsecutive && recommendation.totalDaysOff >= 5 {
            score += 0.2
        }

        if recommendation.efficiency >= 4 {
            score += 0.25
        } else if recommendation.efficiency >= 3 {
            score += 0.15
        } else if recommendation.efficiency >= 2 {
            score += 0.1
        }

        return min(score, 1.0)
    }
}
