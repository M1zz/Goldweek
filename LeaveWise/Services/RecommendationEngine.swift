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

        // 1. 황금연휴 기회 탐색
        let goldenWeeks = findGoldenWeekOpportunities(holidays: holidays, year: year)
        recommendations.append(contentsOf: goldenWeeks)

        // 2. 징검다리 휴일 찾기
        let bridgeDays = findBridgeDayOpportunities(holidays: holidays, year: year)
        recommendations.append(contentsOf: bridgeDays)

        // 3. 연속 휴가 기회
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

        // 8. 효율성 + 매칭점수로 정렬
        scoredRecommendations.sort { ($0.efficiency + $0.matchScore) > ($1.efficiency + $1.matchScore) }

        // 캐시 저장
        cachedRecommendations = scoredRecommendations
        cacheKey = newCacheKey
        cacheTimestamp = Date()

        logInfo("추천 생성 완료 - \(scoredRecommendations.count)개 추천", category: .recommendation)
        return scoredRecommendations
    }

    /// 캐시 무효화
    func invalidateCache() {
        logDebug("추천 캐시 무효화", category: .recommendation)
        cachedRecommendations = []
        cacheKey = ""
        cacheTimestamp = nil
    }
    
    // MARK: - 황금연휴 찾기
    
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
    
    // MARK: - 연속 휴가 기회
    
    private func findConsecutiveOpportunities(holidays: [Holiday], year: Int) -> [LeaveRecommendation] {
        var opportunities: [LeaveRecommendation] = []
        
        // 각 계절별 추천 휴가 시기
        let seasonalOpportunities: [(month: Int, name: String, description: String)] = [
            (3, "봄 여행", "벚꽃 시즌에 맞춘 봄 여행"),
            (7, "여름 휴가", "본격 여름 휴가 시즌"),
            (10, "가을 단풍 여행", "단풍 시즌 가을 여행"),
            (12, "연말 휴가", "연말연시 특별 휴가")
        ]
        
        for seasonal in seasonalOpportunities {
            var components = DateComponents()
            components.year = year
            components.month = seasonal.month
            components.day = 15  // 월 중순
            
            guard let midMonth = calendar.date(from: components) else { continue }
            
            // 해당 주의 월~금 찾기
            let weekday = calendar.component(.weekday, from: midMonth)
            let daysToMonday = weekday == 1 ? 1 : (weekday == 7 ? 2 : -(weekday - 2))
            
            guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: midMonth),
                  let friday = calendar.date(byAdding: .day, value: 4, to: monday),
                  let sunday = calendar.date(byAdding: .day, value: 6, to: monday) else {
                continue
            }
            
            opportunities.append(LeaveRecommendation(
                title: seasonal.name,
                description: "\(seasonal.description). 연차 5일로 9일 연휴를 즐기세요!",
                startDate: calendar.date(byAdding: .day, value: -2, to: monday)!,
                endDate: sunday,
                requiredLeaveDays: 5,
                totalDaysOff: 9,
                tags: ["연속휴가", Season.allCases[seasonal.month / 4].rawValue, "여행"],
                reason: seasonal.description
            ))
        }
        
        return opportunities
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
