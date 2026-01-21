//
//  RecommendationEngine.swift
//  LeaveWise
//
//  휴가 추천 엔진
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
        year: Int
    ) -> [LeaveRecommendation] {
        logDebug("추천 생성 시작 - 연도: \(year), 잔여연차: \(remainingLeave)", category: .recommendation)

        // 캐시 키 생성
        let newCacheKey = "\(year)-\(remainingLeave)-\(profile.preferredDurationRaw)-\(profile.preferredSeasonsRaw)-\(profile.preferLongWeekend)-\(profile.avoidPeakSeason)"

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
        let holidays = holidayService.getHolidays(for: year)
        logDebug("\(year)년 공휴일 \(holidays.count)개 로드", category: .recommendation)

        // 1. 연차 없이 쉴 수 있는 황금연휴 자동 감지
        let goldenWeeksNoLeave = findGoldenWeeksWithoutLeave(holidays: holidays, year: year)
        recommendations.append(contentsOf: goldenWeeksNoLeave)

        // 2. 황금연휴 기회 탐색 (연차 활용)
        let goldenWeeks = findGoldenWeekOpportunities(holidays: holidays, year: year)
        recommendations.append(contentsOf: goldenWeeks)

        // 3. 징검다리 휴일 찾기
        let bridgeDays = findBridgeDayOpportunities(holidays: holidays, year: year)
        recommendations.append(contentsOf: bridgeDays)

        // 4. 연속 휴가 기회
        let consecutiveDays = findConsecutiveOpportunities(holidays: holidays, year: year)
        recommendations.append(contentsOf: consecutiveDays)

        // 4. 선호도 기반 필터링 및 점수 계산
        var scoredRecommendations = recommendations.map { recommendation in
            var scored = recommendation
            scored.matchScore = calculateMatchScore(
                recommendation: recommendation,
                profile: profile
            )
            return scored
        }

        // 5. 남은 연차 기준 필터링
        scoredRecommendations = scoredRecommendations.filter { $0.requiredLeaveDays <= remainingLeave }

        // 6. 현재 날짜 이후만
        let today = Date()
        scoredRecommendations = scoredRecommendations.filter { $0.startDate > today }

        // 7. 성수기 회피 필터링 (선호도 설정 반영)
        if profile.avoidPeakSeason {
            scoredRecommendations = scoredRecommendations.filter { recommendation in
                let month = calendar.component(.month, from: recommendation.startDate)
                // 성수기: 7-8월, 12월 말 ~ 1월 초
                let peakMonths = [7, 8]
                return !peakMonths.contains(month)
            }
        }

        // 8. 의미없는 추천 제거 (정교한 필터링)
        scoredRecommendations = scoredRecommendations.filter { recommendation in
            // 연차 0일인 황금연휴는 무조건 허용
            if recommendation.requiredLeaveDays == 0 && recommendation.totalDaysOff >= 3 {
                let recommendationYear = calendar.component(.year, from: recommendation.startDate)
                return recommendationYear == year
            }

            // 연차가 필요한 경우: 효율이 2.0 미만이면 제외
            guard recommendation.efficiency >= 2.0 else { return false }

            // 총 휴일이 3일 미만이면 제외
            guard recommendation.totalDaysOff >= 3 else { return false }

            // 실제 휴식일(연차+주말+공휴일 조합)이 의미있는지 확인
            // 연차 5일로 5일 쉬는 것은 비효율 (주말 미포함)
            if recommendation.requiredLeaveDays >= 5 && Double(recommendation.totalDaysOff) <= recommendation.requiredLeaveDays + 1 {
                return false
            }

            // 해당 연도 내의 추천만 포함
            let recommendationYear = calendar.component(.year, from: recommendation.startDate)
            if recommendationYear != year {
                return false
            }

            return true
        }

        // 9. 중복 제거 (날짜가 겹치는 추천 중 더 좋은 것만 유지)
        scoredRecommendations = removeDuplicateRecommendations(scoredRecommendations)

        // 10. 효율성 + 매칭점수로 정렬
        scoredRecommendations.sort { ($0.efficiency + $0.matchScore) > ($1.efficiency + $1.matchScore) }

        // 캐시 저장
        cachedRecommendations = scoredRecommendations
        cacheKey = newCacheKey
        cacheTimestamp = Date()

        logInfo("추천 생성 완료 - \(scoredRecommendations.count)개 추천", category: .recommendation)
        return scoredRecommendations
    }

    // MARK: - 중복 제거

    private func removeDuplicateRecommendations(_ recommendations: [LeaveRecommendation]) -> [LeaveRecommendation] {
        var result: [LeaveRecommendation] = []
        var seenTitlePatterns: Set<String> = []

        // 효율+매칭점수 기준 정렬 후 처리 (좋은 것 먼저)
        let sorted = recommendations.sorted {
            ($0.efficiency + $0.matchScore) > ($1.efficiency + $1.matchScore)
        }

        for recommendation in sorted {
            // 1. 같은 제목 패턴 중복 체크 (같은 유형의 추천)
            let titlePattern = extractTitlePattern(recommendation.title)
            if seenTitlePatterns.contains(titlePattern) {
                continue
            }

            // 2. 날짜 겹침 체크 (30% 이상 겹치면 중복)
            let hasSignificantOverlap = result.contains { existing in
                datesOverlapSignificantly(
                    start1: existing.startDate, end1: existing.endDate,
                    start2: recommendation.startDate, end2: recommendation.endDate,
                    threshold: 0.3
                )
            }

            if hasSignificantOverlap {
                continue
            }

            // 3. 같은 월에 유사한 추천 제한 (월당 최대 3개)
            let month = calendar.component(.month, from: recommendation.startDate)
            let sameMonthCount = result.filter {
                calendar.component(.month, from: $0.startDate) == month
            }.count

            if sameMonthCount >= 3 {
                continue
            }

            result.append(recommendation)
            seenTitlePatterns.insert(titlePattern)
        }

        return result
    }

    /// 제목에서 패턴 추출 (예: "5월 황금연휴" -> "황금연휴", "추석 징검다리 연휴" -> "추석 징검다리")
    private func extractTitlePattern(_ title: String) -> String {
        // 명절 이름 + 타입 조합으로 패턴 생성
        let patterns = ["황금연휴", "징검다리", "연계 휴가", "봄 여행", "여름 휴가", "가을 단풍", "연말 휴가"]
        for pattern in patterns {
            if title.contains(pattern) {
                // 명절 이름이 있으면 포함
                if title.contains("설날") { return "설날-\(pattern)" }
                if title.contains("추석") { return "추석-\(pattern)" }
                return pattern
            }
        }
        return title
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

        // 1년 전체를 스캔하여 연속 휴일(주말+공휴일) 찾기
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

                // 공휴일 이름 수집
                if let holiday = holidays.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                    if !includedHolidays.contains(holiday.name) && !holiday.name.contains("대체") {
                        includedHolidays.append(holiday.name)
                    }
                }
            } else {
                // 연속 휴일 종료 - 3일 이상이면 추천 생성
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

                // 리셋
                consecutiveStart = nil
                consecutiveDays = []
                includedHolidays = []
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        // 마지막 연속 휴일 처리
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

    /// 해당 날짜가 쉬는 날인지 확인 (주말 또는 공휴일)
    private func isNonWorkingDay(_ date: Date, holidays: [Holiday]) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        let isWeekend = weekday == 1 || weekday == 7 // 일요일(1), 토요일(7)
        let isHoliday = holidays.contains { calendar.isDate($0.date, inSameDayAs: date) }
        return isWeekend || isHoliday
    }

    /// 황금연휴 추천 생성
    private func createGoldenWeekRecommendation(
        start: Date,
        end: Date,
        totalDays: Int,
        holidayNames: [String],
        year: Int
    ) -> LeaveRecommendation {
        // 제목 생성
        let title = generateGoldenWeekTitle(holidayNames: holidayNames, totalDays: totalDays)

        // 설명 생성
        let description = generateGoldenWeekDescription(
            start: start,
            end: end,
            totalDays: totalDays,
            holidayNames: holidayNames
        )

        // 태그 생성
        var tags = ["황금연휴", "연차없음"]
        tags.append(contentsOf: holidayNames.prefix(2))
        tags.append(getSeasonTag(for: start))

        return LeaveRecommendation(
            title: title,
            description: description,
            startDate: start,
            endDate: end,
            requiredLeaveDays: 0,
            totalDaysOff: totalDays,
            tags: tags,
            reason: holidayNames.isEmpty ? "주말 연휴" : holidayNames.joined(separator: " + ")
        )
    }

    /// 황금연휴 제목 생성
    private func generateGoldenWeekTitle(holidayNames: [String], totalDays: Int) -> String {
        if holidayNames.isEmpty {
            return "\(totalDays)일 연휴"
        }

        // 명절 우선
        if holidayNames.contains(where: { $0.contains("설날") }) {
            return "설날 황금연휴"
        }
        if holidayNames.contains(where: { $0.contains("추석") }) {
            return "추석 황금연휴"
        }

        // 첫 번째 공휴일 이름 사용
        let mainHoliday = holidayNames.first?.replacingOccurrences(of: " 연휴", with: "") ?? ""
        return totalDays >= 4 ? "\(mainHoliday) 황금연휴" : "\(mainHoliday) 연휴"
    }

    /// 황금연휴 설명 생성
    private func generateGoldenWeekDescription(
        start: Date,
        end: Date,
        totalDays: Int,
        holidayNames: [String]
    ) -> String {
        let startWeekday = getWeekdayName(for: start)
        let endWeekday = getWeekdayName(for: end)

        var desc = "\(startWeekday)~\(endWeekday) "

        if holidayNames.isEmpty {
            desc += "주말 연휴로 "
        } else {
            desc += "\(holidayNames.joined(separator: " + "))로 "
        }

        desc += "연차 없이 \(totalDays)일 연휴!"

        // 계절별 추천 문구
        let month = calendar.component(.month, from: start)
        switch month {
        case 3, 4, 5:
            desc += " 봄나들이 추천."
        case 6, 7, 8:
            desc += " 여름 휴가 적기."
        case 9, 10, 11:
            desc += " 단풍 여행 추천."
        case 12, 1, 2:
            desc += " 연말연시 힐링."
        default:
            break
        }

        return desc
    }

    /// 요일 이름 반환
    private func getWeekdayName(for date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        let names = ["일", "월", "화", "수", "목", "금", "토"]
        return names[weekday - 1]
    }

    /// 계절 태그 반환
    private func getSeasonTag(for date: Date) -> String {
        let month = calendar.component(.month, from: date)
        switch month {
        case 3, 4, 5: return "봄"
        case 6, 7, 8: return "여름"
        case 9, 10, 11: return "가을"
        default: return "겨울"
        }
    }

    // MARK: - 황금연휴 찾기 (연차 활용)

    private func findGoldenWeekOpportunities(holidays: [Holiday], year: Int) -> [LeaveRecommendation] {
        var opportunities: [LeaveRecommendation] = []
        
        // 5월 황금연휴 (어린이날 전후)
        if let mayOpportunity = findMayGoldenWeek(holidays: holidays, year: year) {
            opportunities.append(mayOpportunity)
        }
        
        // 추석/설날 연계 연휴
        opportunities.append(contentsOf: findMajorHolidayExtensions(holidays: holidays, year: year))
        
        return opportunities
    }
    
    private func findMayGoldenWeek(holidays: [Holiday], year: Int) -> LeaveRecommendation? {
        // 5월 1일 ~ 5월 5일 사이 분석
        var components = DateComponents()
        components.year = year
        components.month = 5
        
        // 어린이날 (5/5) 찾기
        let mayHolidays = holidays.filter {
            calendar.component(.month, from: $0.date) == 5
        }
        
        guard !mayHolidays.isEmpty else { return nil }
        
        // 5월 초 연휴 분석
        components.day = 1
        guard let may1 = calendar.date(from: components) else { return nil }
        
        components.day = 5
        guard let may5 = calendar.date(from: components) else { return nil }
        
        // 필요한 연차 계산
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
        
        // 주말 포함 총 휴일 계산
        components.day = 1
        let startDate = calendar.date(from: components)!
        components.day = 6
        let endDate = calendar.date(from: components)!
        
        return LeaveRecommendation(
            title: "5월 황금연휴",
            description: "어린이날과 근로자의 날을 활용한 황금연휴! 연차 \(Int(requiredLeave))일로 최대 6일 연휴를 만들 수 있어요.",
            startDate: startDate,
            endDate: endDate,
            requiredLeaveDays: requiredLeave,
            totalDaysOff: 6,
            tags: ["황금연휴", "5월", "가족여행"],
            reason: "어린이날 연계"
        )
    }
    
    private func findMajorHolidayExtensions(holidays: [Holiday], year: Int) -> [LeaveRecommendation] {
        var recommendations: [LeaveRecommendation] = []
        
        // 설날, 추석 찾기
        let lunarHolidays = holidays.filter { $0.name.contains("설날") || $0.name.contains("추석") }
        
        for holiday in lunarHolidays {
            // 앞뒤로 연장 가능한지 분석
            if let recommendation = analyzeHolidayExtension(holiday: holiday, holidays: holidays) {
                recommendations.append(recommendation)
            }
        }
        
        return recommendations
    }
    
    private func analyzeHolidayExtension(holiday: Holiday, holidays: [Holiday]) -> LeaveRecommendation? {
        // 해당 명절 연휴 기간 파악
        let relatedHolidays = holidays.filter { 
            abs(calendar.dateComponents([.day], from: holiday.date, to: $0.date).day ?? 100) <= 3
        }
        
        guard let firstDay = relatedHolidays.map({ $0.date }).min(),
              let lastDay = relatedHolidays.map({ $0.date }).max() else {
            return nil
        }
        
        // 앞뒤 주말 확인하여 확장
        var extendedStart = firstDay
        var extendedEnd = lastDay
        
        // 앞으로 확장 (주말까지)
        while true {
            let prevDay = calendar.date(byAdding: .day, value: -1, to: extendedStart)!
            let weekday = calendar.component(.weekday, from: prevDay)
            if weekday == 1 || weekday == 7 {
                extendedStart = prevDay
            } else {
                break
            }
        }
        
        // 뒤로 확장 (주말까지)
        while true {
            let nextDay = calendar.date(byAdding: .day, value: 1, to: extendedEnd)!
            let weekday = calendar.component(.weekday, from: nextDay)
            if weekday == 1 || weekday == 7 {
                extendedEnd = nextDay
            } else {
                break
            }
        }
        
        // 필요 연차 계산
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
        
        let holidayName = holiday.name.contains("설날") ? "설날" : "추석"
        
        return LeaveRecommendation(
            title: "\(holidayName) 연계 휴가",
            description: "\(holidayName) 연휴를 활용하여 연차 \(Int(requiredLeave))일로 \(totalDays)일 연휴를 만들 수 있어요.",
            startDate: extendedStart,
            endDate: extendedEnd,
            requiredLeaveDays: requiredLeave,
            totalDaysOff: totalDays,
            tags: [holidayName, "명절연휴", "가족"],
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
                        title: "\(holiday.name) 징검다리 연휴",
                        description: "월요일 연차 1일로 4일 연휴! \(holiday.name) 앞 월요일을 활용하세요.",
                        startDate: weekendStart,
                        endDate: holiday.date,
                        requiredLeaveDays: 1,
                        totalDaysOff: 4,
                        tags: ["징검다리", "효율최고", holiday.name],
                        reason: "화요일 공휴일 활용"
                    ))
                }
            }
            
            // 목요일인 공휴일 → 금요일 연차로 4일 연휴
            if weekday == 5 {
                if let bridgeDay = calendar.date(byAdding: .day, value: 1, to: holiday.date) {
                    let weekendEnd = calendar.date(byAdding: .day, value: 2, to: bridgeDay)!
                    
                    opportunities.append(LeaveRecommendation(
                        title: "\(holiday.name) 징검다리 연휴",
                        description: "금요일 연차 1일로 4일 연휴! \(holiday.name) 다음 금요일을 활용하세요.",
                        startDate: holiday.date,
                        endDate: weekendEnd,
                        requiredLeaveDays: 1,
                        totalDaysOff: 4,
                        tags: ["징검다리", "효율최고", holiday.name],
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

        // 공휴일 주변 연속 휴가 기회 찾기
        for holiday in holidays {
            // 해당 공휴일 주의 월~금 분석
            let weekday = calendar.component(.weekday, from: holiday.date)

            // 주중 공휴일만 (월~금)
            guard weekday >= 2 && weekday <= 6 else { continue }

            // 해당 주의 월요일과 금요일 찾기
            let daysToMonday = -(weekday - 2)
            guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: holiday.date),
                  let friday = calendar.date(byAdding: .day, value: 4, to: monday),
                  let prevSaturday = calendar.date(byAdding: .day, value: -2, to: monday),
                  let nextSunday = calendar.date(byAdding: .day, value: 6, to: monday) else {
                continue
            }

            // 해당 주의 공휴일 개수 계산
            var holidaysInWeek = 0
            var currentDate = monday
            while currentDate <= friday {
                if holidays.contains(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                    holidaysInWeek += 1
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }

            // 공휴일이 2개 이상인 주는 더 효율적
            let requiredLeave = Double(5 - holidaysInWeek)

            // 연차가 0이면 스킵
            guard requiredLeave > 0 else { continue }

            let efficiency = 9.0 / requiredLeave

            // 효율이 좋은 경우만 추천 (최소 2.5 이상)
            guard efficiency >= 2.5 else { continue }

            let month = calendar.component(.month, from: holiday.date)
            let seasonName = getSeasonName(for: month)

            opportunities.append(LeaveRecommendation(
                title: "\(holiday.name) 연계 주간휴가",
                description: "\(holiday.name)이 있는 주를 활용! 연차 \(Int(requiredLeave))일로 9일 연휴.",
                startDate: prevSaturday,
                endDate: nextSunday,
                requiredLeaveDays: requiredLeave,
                totalDaysOff: 9,
                tags: ["연속휴가", seasonName, "효율적"],
                reason: "\(holiday.name) 연계"
            ))
        }

        return opportunities
    }

    private func getSeasonName(for month: Int) -> String {
        switch month {
        case 3, 4, 5: return "봄"
        case 6, 7, 8: return "여름"
        case 9, 10, 11: return "가을"
        default: return "겨울"
        }
    }
    
    // MARK: - 선호도 매칭 점수 계산

    private func calculateMatchScore(recommendation: LeaveRecommendation, profile: UserProfile) -> Double {
        var score = 0.0

        // 계절 선호도 매칭 (선호 계절이 설정된 경우)
        let month = calendar.component(.month, from: recommendation.startDate)
        if !profile.preferredSeasons.isEmpty {
            for season in profile.preferredSeasons {
                if season.months.contains(month) {
                    score += 0.3
                    break
                }
            }
        } else {
            // 선호 계절 미설정 시 기본 점수
            score += 0.1
        }

        // 휴가 길이 선호도
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

        // 징검다리 선호 (1일 연차로 4일 연휴)
        if profile.preferLongWeekend && recommendation.tags.contains("징검다리") {
            score += 0.3
        }

        // 연속 휴가 선호
        if profile.preferConsecutive && recommendation.totalDaysOff >= 5 {
            score += 0.2
        }

        // 효율성 보너스 (연차 대비 휴일 비율)
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
