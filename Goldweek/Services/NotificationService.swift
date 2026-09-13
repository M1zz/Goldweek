//
//  NotificationService.swift
//  Goldweek
//
//  "지금 쉬어갈 때예요" 선제 알림 — 계획 시즌 밖에서도 앱을 열게 만드는 리텐션 훅.
//
//  한 알림에 두 근거를 결합한다:
//   1) 과학/이력: 평소 휴식 주기를 넘김 (BurnoutEngine)
//   2) 알고리즘: 가까운 미래의 저비용 휴식 창 (LeavePlanner / RecommendationEngine)
//   → "마지막 휴식 후 67일(평소 52일 초과). 2주 뒤 공휴일에 연차 1일이면 4일 휴식."
//
//  설계 원칙:
//   - 마찰 최소: 하루 1회 이하, overdue 이상일 때만, 스누즈/쿨다운 존중.
//   - UserNotifications 미링크 환경에서도 빌드되도록 canImport 가드.
//

import Foundation

#if canImport(UserNotifications)
import UserNotifications
#endif

/// 단일문항 번아웃 체크인 (SIB, 0~10). 검증된 저마찰 측정 — docs/rest-radar-research.md 근거 E.
/// 가끔 사용자에게 물어 모델을 주관 상태로 보정한다. 묻는 빈도는 최소화.
enum FatigueCheckIn {
    private static let valueKey = "sib_value"          // 마지막 답변값 (0~10)
    private static let answeredKey = "sib_answered_at"  // 마지막 답변 시각
    private static let promptKey = "sib_prompted_at"    // 마지막 노출/스누즈 시각

    /// 답변값이 유효하다고 볼 기간 (이후엔 만료 — 상태는 변하므로)
    static let recencyDays = 14
    /// 체크인을 다시 물어보기까지의 최소 간격
    static let promptIntervalDays = 21

    /// 최근(유효 기간 내) 답변값. 없거나 만료면 nil → 엔진에서 미사용.
    static var recentValue: Int? {
        guard UserDefaults.standard.object(forKey: valueKey) != nil,
              let answered = UserDefaults.standard.object(forKey: answeredKey) as? Date else { return nil }
        let days = Calendar.current.dateComponents([.day], from: answered, to: Date()).day ?? 999
        guard days <= recencyDays else { return nil }
        return UserDefaults.standard.integer(forKey: valueKey)
    }

    /// 지금 체크인을 물어볼 때인가. 이력이 있고, 최근 답변이 없고, 쿨다운이 지났을 때.
    static func isDue(hasHistory: Bool) -> Bool {
        guard hasHistory, recentValue == nil else { return false }
        guard let prompted = UserDefaults.standard.object(forKey: promptKey) as? Date else { return true }
        let days = Calendar.current.dateComponents([.day], from: prompted, to: Date()).day ?? 999
        return days >= promptIntervalDays
    }

    /// 답변 기록.
    static func record(_ value: Int) {
        let v = max(0, min(10, value))
        UserDefaults.standard.set(v, forKey: valueKey)
        UserDefaults.standard.set(Date(), forKey: answeredKey)
        UserDefaults.standard.set(Date(), forKey: promptKey)
        logInfo("피로 체크인 기록: \(v)/10", category: .app)
    }

    /// "나중에" — 노출 시각만 갱신해 쿨다운 시작.
    static func skip() {
        UserDefaults.standard.set(Date(), forKey: promptKey)
    }
}

/// 알림 동행으로 전달할 "저비용 휴식 창" (LeavePlanner/RecommendationEngine에서 생성).
struct RestWindowHint {
    let startDate: Date
    let leaveDaysNeeded: Int
    let totalDaysOff: Int
    /// 포함된 대표 공휴일 이름 (없으면 빈 문자열)
    let holidayName: String
}

enum NotificationService {

    private static let restRadarIdentifier = "goldweek.rest_radar"
    private static let snoozeKey = "rest_radar_snooze_until"
    private static let lastShownKey = "rest_radar_last_shown"
    private static let enabledKey = "rest_radar_enabled"

    /// 알림 카테고리/액션 식별자 (델리게이트에서 탭/스누즈 구분용)
    static let categoryID = "rest_radar_category"
    static let snoozeActionID = "rest_radar_snooze_action"
    /// 알림 내 스누즈 액션 누름 시 보류 기간
    static let snoozeDays = 14

    /// 같은 알림을 다시 보내기까지의 최소 간격(쿨다운).
    private static let cooldownDays = 7

    // MARK: - 사용자 설정

    /// 휴식 레이더 알림 on/off (기본 on). 설정 화면에서 토글.
    static var isEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: enabledKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: enabledKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: enabledKey) }
    }

    /// "나중에" — N일간 알림 보류.
    static func snooze(days: Int = 14) {
        let until = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        UserDefaults.standard.set(until, forKey: snoozeKey)
        cancelPending()
        logInfo("휴식 레이더 \(days)일 스누즈", category: .app)
    }

    private static var isSnoozed: Bool {
        guard let until = UserDefaults.standard.object(forKey: snoozeKey) as? Date else { return false }
        return Date() < until
    }

    private static var inCooldown: Bool {
        guard let last = UserDefaults.standard.object(forKey: lastShownKey) as? Date else { return false }
        let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 999
        return days < cooldownDays
    }

    // MARK: - 권한

    /// 알림 권한 요청. 이미 결정됐으면 현 상태 반환.
    @discardableResult
    static func requestAuthorization() async -> Bool {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                // provisional = 조용한 알림(권한 팝업 없이 알림센터에 전달) — 첫 마찰 최소화
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge, .provisional])
                logInfo("알림 권한 요청 결과: \(granted)", category: .app)
                return granted
            } catch {
                logWarning("알림 권한 요청 실패: \(error.localizedDescription)", category: .app)
                return false
            }
        @unknown default:
            return false
        }
        #else
        return false
        #endif
    }

    /// 델리게이트 + 카테고리(스누즈 액션) 등록. 앱 시작 시 1회 호출.
    /// 포그라운드 배너 표시 + 탭/스누즈 추적을 가능하게 한다.
    static func registerDelegate() {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        center.delegate = RestRadarNotificationDelegate.shared

        let snooze = UNNotificationAction(
            identifier: snoozeActionID,
            title: Strings.restRadarSnoozeAction,
            options: []
        )
        let category = UNNotificationCategory(
            identifier: categoryID,
            actions: [snooze],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
        #endif
    }

    // MARK: - 휴식 레이더 메인 진입점

    /// 번아웃 평가 + 저비용 창을 받아 필요 시 알림 예약.
    /// 보통 앱 진입/백그라운드 진입 시 호출.
    static func refreshRestRadar(assessment: BurnoutAssessment, window: RestWindowHint?) async {
        guard isEnabled else { cancelPending(); return }

        // overdue 이상 + 스누즈/쿨다운 아님일 때만
        guard assessment.level >= .overdue, !isSnoozed, !inCooldown else {
            logDebug("휴식 레이더 미발화 (level=\(assessment.level), snoozed=\(isSnoozed), cooldown=\(inCooldown))", category: .app)
            return
        }

        guard await requestAuthorization() else {
            logDebug("알림 권한 없음 — 휴식 레이더 건너뜀", category: .app)
            return
        }

        let (title, body) = content(for: assessment, window: window)
        await schedule(title: title, body: body)

        UserDefaults.standard.set(Date(), forKey: lastShownKey)
    }

    // MARK: - 예약/취소

    private static func schedule(title: String, body: String) async {
        #if canImport(UserNotifications)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = categoryID
        content.userInfo = ["type": "rest_radar"]

        // 내일 오전 10시 — 업무 시작 직후, 휴식 계획에 적당한 시간
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.day = (comps.day ?? 1) + 1
        comps.hour = 10
        comps.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let request = UNNotificationRequest(identifier: restRadarIdentifier, content: content, trigger: trigger)
        do {
            // 기존 동일 알림 교체
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [restRadarIdentifier])
            try await UNUserNotificationCenter.current().add(request)
            logInfo("휴식 레이더 알림 예약: \(title)", category: .app)
        } catch {
            logWarning("휴식 레이더 알림 예약 실패: \(error.localizedDescription)", category: .app)
        }
        #endif
    }

    static func cancelPending() {
        #if canImport(UserNotifications)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [restRadarIdentifier])
        #endif
    }

    // MARK: - 문구 생성 (다국어)

    /// 과학(주기) + 알고리즘(저비용 창)을 결합한 알림 문구.
    static func content(for a: BurnoutAssessment, window: RestWindowHint?) -> (String, String) {
        let lang = AppLanguage.current
        let since = a.daysSinceLastBreak
        let cycle = a.personalCycleDays

        let title: String
        switch lang {
        case .korean:   title = a.level == .critical ? "지금 쉬어갈 때예요 🌿" : "슬슬 쉬어갈 때예요 🌿"
        case .japanese: title = a.level == .critical ? "そろそろ休む時です 🌿" : "休憩を考える時期です 🌿"
        case .chinese:  title = a.level == .critical ? "该休息一下了 🌿" : "是时候安排休息了 🌿"
        case .english:  title = a.level == .critical ? "Time to recharge 🌿" : "A break is due soon 🌿"
        }

        // 1절: 이력 기반 사유
        let reasonText: String
        switch lang {
        case .korean:
            if let s = since, a.cycleIsPersonalized {
                reasonText = "마지막 휴식 후 \(s)일 — 평소 주기 \(cycle)일을 넘겼어요."
            } else if let s = since {
                reasonText = "마지막 휴식 후 \(s)일이 지났어요."
            } else {
                reasonText = "아직 올해 쉰 기록이 없어요."
            }
        case .japanese:
            if let s = since, a.cycleIsPersonalized {
                reasonText = "前回の休みから\(s)日 — いつもの周期\(cycle)日を超えました。"
            } else if let s = since {
                reasonText = "前回の休みから\(s)日が経ちました。"
            } else {
                reasonText = "今年はまだ休んだ記録がありません。"
            }
        case .chinese:
            if let s = since, a.cycleIsPersonalized {
                reasonText = "距上次休息已\(s)天 — 超过了你通常的\(cycle)天周期。"
            } else if let s = since {
                reasonText = "距上次休息已过\(s)天。"
            } else {
                reasonText = "今年还没有休息记录。"
            }
        case .english:
            if let s = since, a.cycleIsPersonalized {
                reasonText = "It's been \(s) days since your last break — past your usual \(cycle)-day cycle."
            } else if let s = since {
                reasonText = "It's been \(s) days since your last break."
            } else {
                reasonText = "No rest logged yet this year."
            }
        }

        // 2절: 알고리즘 기반 저비용 창 (있으면)
        var windowText = ""
        if let w = window {
            switch lang {
            case .korean:
                let h = w.holidayName.isEmpty ? "" : "\(w.holidayName)에 "
                windowText = " \(daysFromNow(w.startDate, lang))후 \(h)연차 \(w.leaveDaysNeeded)일이면 \(w.totalDaysOff)일 휴식이 가능해요."
            case .japanese:
                let h = w.holidayName.isEmpty ? "" : "\(w.holidayName)に"
                windowText = " \(daysFromNow(w.startDate, lang))後、\(h)有給\(w.leaveDaysNeeded)日で\(w.totalDaysOff)連休が作れます。"
            case .chinese:
                let h = w.holidayName.isEmpty ? "" : "在\(w.holidayName)"
                windowText = " \(daysFromNow(w.startDate, lang))后\(h)请\(w.leaveDaysNeeded)天年假即可获得\(w.totalDaysOff)天假期。"
            case .english:
                let h = w.holidayName.isEmpty ? "" : " around \(w.holidayName)"
                windowText = " In \(daysFromNow(w.startDate, lang)),\(h) just \(w.leaveDaysNeeded) leave day(s) makes a \(w.totalDaysOff)-day break."
            }
        }

        return (title, reasonText + windowText)
    }

    private static func daysFromNow(_ date: Date, _ lang: AppLanguage) -> String {
        let d = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()),
                                                to: Calendar.current.startOfDay(for: date)).day ?? 0
        switch lang {
        case .korean:   return "\(max(0, d))일"
        case .japanese: return "\(max(0, d))日"
        case .chinese:  return "\(max(0, d))天"
        case .english:  return "\(max(0, d)) day(s)"
        }
    }
}

// MARK: - 알림 델리게이트

#if canImport(UserNotifications)
/// 포그라운드 배너 표시 + 탭/스누즈 추적. 앱 시작 시 registerDelegate()로 연결.
final class RestRadarNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = RestRadarNotificationDelegate()

    /// 앱이 열려 있을 때도 배너로 표시 (기본은 억제됨)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }

    /// 알림 탭(앱 진입) / 스누즈 액션 처리
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case NotificationService.snoozeActionID:
            NotificationService.snooze(days: NotificationService.snoozeDays)
        default:
            break
        }
        completionHandler()
    }
}
#endif
