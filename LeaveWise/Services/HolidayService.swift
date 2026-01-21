//
//  HolidayService.swift
//  LeaveWise
//
//  한국 공휴일 서비스
//

import Foundation

class HolidayService {
    
    private let calendar = Calendar.current
    
    // MARK: - 공휴일 데이터
    
    /// 해당 연도의 공휴일 목록 반환
    func getHolidays(for year: Int) -> [Holiday] {
        var holidays: [Holiday] = []
        
        // 고정 공휴일
        holidays.append(contentsOf: getFixedHolidays(for: year))
        
        // 음력 공휴일 (설날, 추석, 부처님오신날)
        holidays.append(contentsOf: getLunarHolidays(for: year))
        
        // 대체공휴일 계산
        holidays.append(contentsOf: getSubstituteHolidays(holidays: holidays, year: year))
        
        return holidays.sorted { $0.date < $1.date }
    }
    
    // MARK: - 고정 공휴일
    
    private func getFixedHolidays(for year: Int) -> [Holiday] {
        var holidays: [Holiday] = []
        
        let fixedDates: [(month: Int, day: Int, name: String)] = [
            (1, 1, "신정"),
            (3, 1, "삼일절"),
            (5, 5, "어린이날"),
            (6, 6, "현충일"),
            (8, 15, "광복절"),
            (10, 3, "개천절"),
            (10, 9, "한글날"),
            (12, 25, "크리스마스")
        ]
        
        for fixed in fixedDates {
            var components = DateComponents()
            components.year = year
            components.month = fixed.month
            components.day = fixed.day
            
            if let date = calendar.date(from: components) {
                holidays.append(Holiday(date: date, name: fixed.name))
            }
        }
        
        return holidays
    }
    
    // MARK: - 음력 공휴일

    private func getLunarHolidays(for year: Int) -> [Holiday] {
        var holidays: [Holiday] = []

        // 음력 날짜는 매년 다르므로 근사값 사용 (실제로는 API 연동 필요)
        // 2024~2030년 데이터
        let lunarHolidayData: [Int: [(month: Int, day: Int, name: String, duration: Int)]] = [
            2024: [
                (2, 9, "설날 연휴", 3),    // 2/9 ~ 2/11
                (5, 15, "부처님오신날", 1),
                (9, 16, "추석 연휴", 3)     // 9/16 ~ 9/18
            ],
            2025: [
                (1, 28, "설날 연휴", 3),    // 1/28 ~ 1/30
                (5, 5, "부처님오신날", 1),   // 어린이날과 겹침
                (10, 5, "추석 연휴", 3)      // 10/5 ~ 10/7
            ],
            2026: [
                (2, 16, "설날 연휴", 3),    // 2/16 ~ 2/18
                (5, 24, "부처님오신날", 1),
                (9, 24, "추석 연휴", 3)      // 9/24 ~ 9/26
            ],
            2027: [
                (2, 6, "설날 연휴", 3),     // 2/6 ~ 2/8
                (5, 13, "부처님오신날", 1),
                (9, 14, "추석 연휴", 3)      // 9/14 ~ 9/16
            ],
            2028: [
                (1, 26, "설날 연휴", 3),    // 1/26 ~ 1/28
                (5, 2, "부처님오신날", 1),
                (10, 2, "추석 연휴", 3)      // 10/2 ~ 10/4
            ],
            2029: [
                (2, 12, "설날 연휴", 3),    // 2/12 ~ 2/14
                (5, 20, "부처님오신날", 1),
                (9, 21, "추석 연휴", 3)      // 9/21 ~ 9/23
            ],
            2030: [
                (2, 2, "설날 연휴", 3),     // 2/2 ~ 2/4
                (5, 9, "부처님오신날", 1),
                (9, 11, "추석 연휴", 3)      // 9/11 ~ 9/13
            ]
        ]
        
        guard let yearData = lunarHolidayData[year] else {
            // 데이터가 없는 연도는 기본값 사용
            return getDefaultLunarHolidays(for: year)
        }
        
        for holiday in yearData {
            var components = DateComponents()
            components.year = year
            components.month = holiday.month
            components.day = holiday.day
            
            guard let startDate = calendar.date(from: components) else { continue }
            
            if holiday.duration > 1 {
                // 연휴인 경우 각 날짜 추가
                for i in 0..<holiday.duration {
                    if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                        let dayName: String
                        if holiday.name.contains("설날") {
                            dayName = i == 1 ? "설날" : "설날 연휴"
                        } else {
                            dayName = i == 1 ? "추석" : "추석 연휴"
                        }
                        holidays.append(Holiday(date: date, name: dayName))
                    }
                }
            } else {
                holidays.append(Holiday(date: startDate, name: holiday.name))
            }
        }
        
        return holidays
    }
    
    private func getDefaultLunarHolidays(for year: Int) -> [Holiday] {
        // 대략적인 기본값 (실제 서비스에서는 API 연동 필요)
        var holidays: [Holiday] = []
        var components = DateComponents()
        components.year = year
        
        // 설날 (대략 1월 말 ~ 2월 초)
        components.month = 2
        components.day = 1
        if let date = calendar.date(from: components) {
            for i in -1...1 {
                if let d = calendar.date(byAdding: .day, value: i, to: date) {
                    holidays.append(Holiday(date: d, name: i == 0 ? "설날" : "설날 연휴"))
                }
            }
        }
        
        // 부처님오신날 (대략 5월 중순)
        components.month = 5
        components.day = 15
        if let date = calendar.date(from: components) {
            holidays.append(Holiday(date: date, name: "부처님오신날"))
        }
        
        // 추석 (대략 9월 중순)
        components.month = 9
        components.day = 15
        if let date = calendar.date(from: components) {
            for i in -1...1 {
                if let d = calendar.date(byAdding: .day, value: i, to: date) {
                    holidays.append(Holiday(date: d, name: i == 0 ? "추석" : "추석 연휴"))
                }
            }
        }
        
        return holidays
    }
    
    // MARK: - 대체공휴일

    private func getSubstituteHolidays(holidays: [Holiday], year: Int) -> [Holiday] {
        var substituteHolidays: [Holiday] = []

        // 대체공휴일 적용 대상 확인
        let substituteEligible = ["어린이날", "설날", "설날 연휴", "추석", "추석 연휴",
                                   "삼일절", "광복절", "개천절", "한글날", "크리스마스"]

        for holiday in holidays {
            let weekday = calendar.component(.weekday, from: holiday.date)

            // 토요일(7) 또는 일요일(1)인 경우 대체공휴일 적용
            let isWeekend = weekday == 1 || weekday == 7

            if isWeekend && substituteEligible.contains(where: { holiday.name.contains($0) }) {
                // 다음 평일 찾기
                var nextDay = calendar.date(byAdding: .day, value: 1, to: holiday.date)!

                while true {
                    let nextWeekday = calendar.component(.weekday, from: nextDay)
                    let isAlreadyHoliday = holidays.contains { calendar.isDate($0.date, inSameDayAs: nextDay) }
                    let isAlreadySubstitute = substituteHolidays.contains { calendar.isDate($0.date, inSameDayAs: nextDay) }

                    if nextWeekday != 1 && nextWeekday != 7 && !isAlreadyHoliday && !isAlreadySubstitute {
                        substituteHolidays.append(Holiday(
                            date: nextDay,
                            name: "\(holiday.name) 대체공휴일",
                            isSubstitute: true
                        ))
                        break
                    }

                    nextDay = calendar.date(byAdding: .day, value: 1, to: nextDay)!
                }
            }
        }

        return substituteHolidays
    }
    
    // MARK: - 유틸리티
    
    /// 특정 날짜가 공휴일인지 확인
    func isHoliday(_ date: Date, in year: Int) -> Bool {
        let holidays = getHolidays(for: year)
        return holidays.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    /// 특정 날짜의 공휴일 정보 반환
    func getHoliday(for date: Date, in year: Int) -> Holiday? {
        let holidays = getHolidays(for: year)
        return holidays.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    /// 특정 월의 공휴일 목록
    func getHolidays(for month: Int, year: Int) -> [Holiday] {
        let allHolidays = getHolidays(for: year)
        return allHolidays.filter { 
            calendar.component(.month, from: $0.date) == month 
        }
    }
}
