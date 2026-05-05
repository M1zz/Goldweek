//
//  CalendarService.swift
//  Goldweek
//
//  EventKit 시스템 캘린더 연동 서비스 (Pro 전용 기능)
//

import Foundation
import EventKit
import SwiftUI

@Observable
class CalendarService {
    static let shared = CalendarService()
    
    private let eventStore = EKEventStore()
    // 기존 사용자 데이터 호환을 위해 UserDefaults 키는 보존
    private let calendarIdentifierKey = "LeaveWiseCalendarIdentifier"
    private let calendarTitle = "Goldweek 연차"
    private let legacyCalendarTitle = "LeaveWise 연차"
    
    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }
    
    var isAuthorized: Bool {
        authorizationStatus == .fullAccess || authorizationStatus == .authorized
    }
    
    private init() {}
    
    // MARK: - Permission Management
    
    /// EventKit 권한 요청
    func requestCalendarAccess() async throws -> Bool {
        let status = authorizationStatus
        
        switch status {
        case .authorized, .fullAccess:
            logInfo("EventKit 권한이 이미 허용됨", category: .app)
            return true
            
        case .denied, .restricted:
            logWarning("EventKit 권한이 거부됨", category: .app)
            throw CalendarError.permissionDenied
            
        case .notDetermined, .writeOnly:
            // iOS 17+ 에서는 requestFullAccessToEvents 사용
            if #available(iOS 17.0, *) {
                let granted = try await eventStore.requestFullAccessToEvents()
                logInfo("EventKit 권한 요청 결과: \(granted)", category: .app)
                return granted
            } else {
                // iOS 16 이하에서는 requestAccess 사용
                return try await withCheckedThrowingContinuation { continuation in
                    eventStore.requestAccess(to: .event) { granted, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: granted)
                        }
                    }
                }
            }
            
        @unknown default:
            throw CalendarError.unknownPermissionStatus
        }
    }
    
    // MARK: - Calendar Management
    
    /// Goldweek 전용 캘린더 찾기 또는 생성
    func getOrCreateGoldweekCalendar() throws -> EKCalendar {
        // 기존 캘린더 찾기 (LeaveWise → Goldweek 리브랜딩 마이그레이션 포함)
        if let savedIdentifier = UserDefaults.standard.string(forKey: calendarIdentifierKey),
           let existingCalendar = eventStore.calendar(withIdentifier: savedIdentifier) {
            // 레거시 제목인 경우 자동으로 새 제목으로 변경
            if existingCalendar.title == legacyCalendarTitle {
                existingCalendar.title = calendarTitle
                do {
                    try eventStore.saveCalendar(existingCalendar, commit: true)
                    logInfo("캘린더 제목 마이그레이션 완료: \(legacyCalendarTitle) → \(calendarTitle)", category: .app)
                } catch {
                    logWarning("캘린더 제목 마이그레이션 실패: \(error.localizedDescription)", category: .app)
                }
            }
            logDebug("기존 캘린더 발견: \(existingCalendar.title)", category: .app)
            return existingCalendar
        }

        // 새 캘린더 생성
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = calendarTitle
        calendar.cgColor = UIColor.systemBlue.cgColor

        // iCloud 계정이 있으면 iCloud에, 아니면 로컬에 저장
        if let iCloudSource = eventStore.sources.first(where: { $0.sourceType == .calDAV }) {
            calendar.source = iCloudSource
            logDebug("iCloud 계정에 캘린더 생성", category: .app)
        } else if let localSource = eventStore.sources.first(where: { $0.sourceType == .local }) {
            calendar.source = localSource
            logDebug("로컬에 캘린더 생성", category: .app)
        } else {
            throw CalendarError.noAvailableSource
        }

        try eventStore.saveCalendar(calendar, commit: true)

        // 캘린더 식별자 저장
        UserDefaults.standard.set(calendar.calendarIdentifier, forKey: calendarIdentifierKey)

        logInfo("Goldweek 캘린더 생성 완료: \(calendar.calendarIdentifier)", category: .app)
        return calendar
    }
    
    // MARK: - Event Management
    
    /// 연차 일정을 시스템 캘린더에 추가
    func addLeaveToCalendar(_ leaveRecord: LeaveRecord) async throws {
        // Pro 권한 확인
        guard ProManager.shared.isPro else {
            throw CalendarError.proFeatureRequired
        }
        
        // 권한 확인
        if !isAuthorized {
            let granted = try await requestCalendarAccess()
            guard granted else {
                throw CalendarError.permissionDenied
            }
        }
        guard isAuthorized else {
            throw CalendarError.permissionDenied
        }
        
        let calendar = try getOrCreateGoldweekCalendar()
        
        // 이벤트 생성
        let event = EKEvent(eventStore: eventStore)
        event.title = generateEventTitle(for: leaveRecord)
        event.notes = leaveRecord.note.isEmpty ? nil : leaveRecord.note
        event.calendar = calendar
        event.isAllDay = true
        
        // 시작일과 종료일 설정
        let startOfDay = Calendar.current.startOfDay(for: leaveRecord.startDate)
        event.startDate = startOfDay
        
        // 종일 이벤트는 다음 날 자정으로 설정
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: leaveRecord.endDate) ?? leaveRecord.endDate
        event.endDate = Calendar.current.startOfDay(for: endOfDay)
        
        // 알림 설정 (연차 하루 전)
        if leaveRecord.type == .annual {
            let alarm = EKAlarm(relativeOffset: -24 * 60 * 60) // 24시간 전
            event.addAlarm(alarm)
        }
        
        // 이벤트 저장
        try eventStore.save(event, span: .thisEvent)
        
        logInfo("캘린더에 연차 추가 완료: \(event.title ?? "제목없음")", category: .app)
    }
    
    /// 연차 일정을 시스템 캘린더에서 삭제
    func removeLeaveFromCalendar(_ leaveRecord: LeaveRecord) async throws {
        guard ProManager.shared.isPro else {
            throw CalendarError.proFeatureRequired
        }
        
        guard isAuthorized else {
            throw CalendarError.permissionDenied
        }
        
        let calendar = try getOrCreateGoldweekCalendar()
        let eventTitle = generateEventTitle(for: leaveRecord)
        
        // 해당 날짜 범위의 이벤트 검색
        let startDate = Calendar.current.startOfDay(for: leaveRecord.startDate)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: leaveRecord.endDate) ?? leaveRecord.endDate
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: [calendar]
        )
        
        let events = eventStore.events(matching: predicate)
        
        // 제목과 날짜가 일치하는 이벤트 찾기
        for event in events {
            if event.title == eventTitle {
                try eventStore.remove(event, span: .thisEvent)
                logInfo("캘린더에서 연차 삭제 완료: \(eventTitle)", category: .app)
                return
            }
        }
        
        logWarning("삭제할 연차 이벤트를 찾을 수 없음: \(eventTitle)", category: .app)
    }
    
    /// 여러 연차 일정을 일괄 추가
    func addLeavesToCalendar(_ leaveRecords: [LeaveRecord]) async throws {
        guard ProManager.shared.isPro else {
            throw CalendarError.proFeatureRequired
        }
        
        for record in leaveRecords {
            do {
                try await addLeaveToCalendar(record)
            } catch {
                logError("연차 캘린더 추가 실패 (\(record.startDate)): \(error.localizedDescription)", category: .app)
                // 개별 실패해도 계속 진행
            }
        }
    }
    
    // MARK: - Utility Methods
    
    /// 연차 타입에 따른 이벤트 제목 생성
    private func generateEventTitle(for leaveRecord: LeaveRecord) -> String {
        let typeString = Strings.leaveTypeName(leaveRecord.type)
        
        if leaveRecord.startDate == leaveRecord.endDate {
            return "\(typeString)"
        } else {
            let days = leaveRecord.daysCount
            return "\(typeString) (\(days)일)"
        }
    }
    
    /// Goldweek 캘린더의 모든 이벤트 가져오기
    func getGoldweekEvents(from startDate: Date, to endDate: Date) throws -> [EKEvent] {
        guard isAuthorized else {
            throw CalendarError.permissionDenied
        }
        
        let calendar = try getOrCreateGoldweekCalendar()
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: [calendar]
        )
        
        return eventStore.events(matching: predicate)
    }
    
    /// Goldweek 캘린더 삭제 (설정 리셋용)
    func deleteGoldweekCalendar() throws {
        guard let savedIdentifier = UserDefaults.standard.string(forKey: calendarIdentifierKey),
              let calendar = eventStore.calendar(withIdentifier: savedIdentifier) else {
            logInfo("삭제할 Goldweek 캘린더가 없음", category: .app)
            return
        }

        try eventStore.removeCalendar(calendar, commit: true)
        UserDefaults.standard.removeObject(forKey: calendarIdentifierKey)

        logInfo("Goldweek 캘린더 삭제 완료", category: .app)
    }
    
    /// 시스템 캘린더 동기화 상태 확인
    func getSyncStatus() -> CalendarSyncStatus {
        guard ProManager.shared.isPro else {
            return .proRequired
        }
        
        switch authorizationStatus {
        case .authorized, .fullAccess:
            if let _ = UserDefaults.standard.string(forKey: calendarIdentifierKey) {
                return .synced
            } else {
                return .notConfigured
            }
        case .denied, .restricted:
            return .permissionDenied
        case .notDetermined, .writeOnly:
            return .permissionRequired
        @unknown default:
            return .error
        }
    }
}

// MARK: - Sync Status

enum CalendarSyncStatus {
    case synced
    case notConfigured
    case permissionRequired
    case permissionDenied
    case proRequired
    case error
    
    var displayText: String {
        switch self {
        case .synced:
            switch LanguageManager.shared.currentLanguage {
            case .korean: return "동기화됨"
            case .english: return "Synced"
            case .japanese: return "同期済み"
            case .chinese: return "已同步"
            }
        case .notConfigured:
            switch LanguageManager.shared.currentLanguage {
            case .korean: return "설정 필요"
            case .english: return "Setup Required"
            case .japanese: return "設定が必要"
            case .chinese: return "需要设置"
            }
        case .permissionRequired:
            switch LanguageManager.shared.currentLanguage {
            case .korean: return "권한 필요"
            case .english: return "Permission Required"
            case .japanese: return "権限が必要"
            case .chinese: return "需要权限"
            }
        case .permissionDenied:
            switch LanguageManager.shared.currentLanguage {
            case .korean: return "권한 거부됨"
            case .english: return "Permission Denied"
            case .japanese: return "権限が拒否"
            case .chinese: return "权限被拒绝"
            }
        case .proRequired:
            switch LanguageManager.shared.currentLanguage {
            case .korean: return "Pro 필요"
            case .english: return "Pro Required"
            case .japanese: return "Pro が必要"
            case .chinese: return "需要Pro版"
            }
        case .error:
            switch LanguageManager.shared.currentLanguage {
            case .korean: return "오류"
            case .english: return "Error"
            case .japanese: return "エラー"
            case .chinese: return "错误"
            }
        }
    }
    
    var icon: String {
        switch self {
        case .synced: return "checkmark.circle.fill"
        case .notConfigured: return "gear"
        case .permissionRequired: return "questionmark.circle"
        case .permissionDenied: return "xmark.circle"
        case .proRequired: return "crown"
        case .error: return "exclamationmark.triangle"
        }
    }
    
    var color: Color {
        switch self {
        case .synced: return .green
        case .notConfigured: return .orange
        case .permissionRequired: return .blue
        case .permissionDenied: return .red
        case .proRequired: return .yellow
        case .error: return .red
        }
    }
}

// MARK: - Errors

enum CalendarError: LocalizedError {
    case permissionDenied
    case unknownPermissionStatus
    case noAvailableSource
    case proFeatureRequired
    case eventNotFound
    case calendarNotFound
    
    var errorDescription: String? {
        switch LanguageManager.shared.currentLanguage {
        case .korean:
            switch self {
            case .permissionDenied: return "캘린더 접근 권한이 거부되었습니다."
            case .unknownPermissionStatus: return "알 수 없는 권한 상태입니다."
            case .noAvailableSource: return "사용 가능한 캘린더 소스가 없습니다."
            case .proFeatureRequired: return "Pro 기능이 필요합니다."
            case .eventNotFound: return "이벤트를 찾을 수 없습니다."
            case .calendarNotFound: return "캘린더를 찾을 수 없습니다."
            }
        case .english:
            switch self {
            case .permissionDenied: return "Calendar access permission denied."
            case .unknownPermissionStatus: return "Unknown permission status."
            case .noAvailableSource: return "No available calendar source."
            case .proFeatureRequired: return "Pro feature required."
            case .eventNotFound: return "Event not found."
            case .calendarNotFound: return "Calendar not found."
            }
        case .japanese:
            switch self {
            case .permissionDenied: return "カレンダーのアクセス権限が拒否されました。"
            case .unknownPermissionStatus: return "不明な権限状態です。"
            case .noAvailableSource: return "利用可能なカレンダーソースがありません。"
            case .proFeatureRequired: return "Pro機能が必要です。"
            case .eventNotFound: return "イベントが見つかりません。"
            case .calendarNotFound: return "カレンダーが見つかりません。"
            }
        case .chinese:
            switch self {
            case .permissionDenied: return "日历访问权限被拒绝。"
            case .unknownPermissionStatus: return "未知的权限状态。"
            case .noAvailableSource: return "没有可用的日历源。"
            case .proFeatureRequired: return "需要Pro功能。"
            case .eventNotFound: return "找不到事件。"
            case .calendarNotFound: return "找不到日历。"
            }
        }
    }
}