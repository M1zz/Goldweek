//
//  Strings.swift
//  LeaveWise
//
//  다국어 지원 헬퍼
//

import SwiftUI

// MARK: - 앱 언어
enum AppLanguage: String, CaseIterable, Identifiable {
    case korean = "ko"
    case english = "en"
    case japanese = "ja"
    case chinese = "zh"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .korean: return "한국어"
        case .english: return "English"
        case .japanese: return "日本語"
        case .chinese: return "中文"
        }
    }

    var flag: String {
        switch self {
        case .korean: return "🇰🇷"
        case .english: return "🇺🇸"
        case .japanese: return "🇯🇵"
        case .chinese: return "🇨🇳"
        }
    }

    static var current: AppLanguage {
        get {
            let raw = UserDefaults.standard.string(forKey: "appLanguage") ?? "ko"
            return AppLanguage(rawValue: raw) ?? .korean
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "appLanguage")
            LanguageManager.shared.currentLanguage = newValue
        }
    }
}

// MARK: - 언어 변경 감지용 Observable
@Observable
class LanguageManager {
    static let shared = LanguageManager()
    var currentLanguage: AppLanguage

    private init() {
        let raw = UserDefaults.standard.string(forKey: "appLanguage") ?? "ko"
        self.currentLanguage = AppLanguage(rawValue: raw) ?? .korean
    }
}

// MARK: - 다국어 문자열
enum Strings {
    private static var lang: AppLanguage { LanguageManager.shared.currentLanguage }

    // MARK: - 탭 / 네비게이션
    static var tabHome: String {
        switch lang {
        case .korean: return "홈"
        case .english: return "Home"
        case .japanese: return "ホーム"
        case .chinese: return "首页"
        }
    }

    static var tabCalendar: String {
        switch lang {
        case .korean: return "캘린더"
        case .english: return "Calendar"
        case .japanese: return "カレンダー"
        case .chinese: return "日历"
        }
    }

    static var tabRecommendations: String {
        switch lang {
        case .korean: return "추천"
        case .english: return "Recommend"
        case .japanese: return "おすすめ"
        case .chinese: return "推荐"
        }
    }

    static var tabRegister: String {
        switch lang {
        case .korean: return "등록"
        case .english: return "Register"
        case .japanese: return "登録"
        case .chinese: return "登记"
        }
    }

    static var dateRangeFormat: String {
        switch lang {
        case .korean: return "M/d(E)"
        case .english: return "M/d(EEE)"
        case .japanese: return "M/d(E)"
        case .chinese: return "M/d(E)"
        }
    }

    static var tabSettings: String {
        switch lang {
        case .korean: return "설정"
        case .english: return "Settings"
        case .japanese: return "設定"
        case .chinese: return "设置"
        }
    }

    // MARK: - 홈 화면
    static var navTitleHome: String {
        switch lang {
        case .korean: return "휴가플래너"
        case .english: return "Leave Planner"
        case .japanese: return "休暇プランナー"
        case .chinese: return "休假规划"
        }
    }

    static func annualLeaveStatus(year: Int) -> String {
        switch lang {
        case .korean: return "\(year)년 연차 현황"
        case .english: return "\(year) Annual Leave"
        case .japanese: return "\(year)年 有給休暇"
        case .chinese: return "\(year)年 年假概况"
        }
    }

    static var used: String {
        switch lang {
        case .korean: return "사용"
        case .english: return "Used"
        case .japanese: return "使用"
        case .chinese: return "已用"
        }
    }

    static var total: String {
        switch lang {
        case .korean: return "총"
        case .english: return "Total"
        case .japanese: return "合計"
        case .chinese: return "共"
        }
    }

    static var remaining: String {
        switch lang {
        case .korean: return "남음"
        case .english: return "Left"
        case .japanese: return "残り"
        case .chinese: return "剩余"
        }
    }

    static var upcomingLeaves: String {
        switch lang {
        case .korean: return "다가오는 휴가"
        case .english: return "Upcoming Leaves"
        case .japanese: return "今後の休暇"
        case .chinese: return "即将到来的假期"
        }
    }

    static var recommendedSchedule: String {
        switch lang {
        case .korean: return "추천 휴가 일정"
        case .english: return "Recommended Schedule"
        case .japanese: return "おすすめ休暇日程"
        case .chinese: return "推荐休假日程"
        }
    }

    static var generatingRecommendations: String {
        switch lang {
        case .korean: return "추천을 생성 중입니다..."
        case .english: return "Generating recommendations..."
        case .japanese: return "おすすめを作成中..."
        case .chinese: return "正在生成推荐..."
        }
    }

    static var addToSchedule: String {
        switch lang {
        case .korean: return "일정 추가하기"
        case .english: return "Add to Schedule"
        case .japanese: return "予定に追加"
        case .chinese: return "添加到日程"
        }
    }

    static var addedToSchedule: String {
        switch lang {
        case .korean: return "추가됨 ✓"
        case .english: return "Added ✓"
        case .japanese: return "追加済み ✓"
        case .chinese: return "已添加 ✓"
        }
    }

    static var efficiency: String {
        switch lang {
        case .korean: return "효율"
        case .english: return "Efficiency"
        case .japanese: return "効率"
        case .chinese: return "效率"
        }
    }

    static var leaveHistory: String {
        switch lang {
        case .korean: return "휴가 사용 내역"
        case .english: return "Leave History"
        case .japanese: return "休暇履歴"
        case .chinese: return "休假记录"
        }
    }

    static var checkPastRecords: String {
        switch lang {
        case .korean: return "지난 휴가 기록을 확인하세요"
        case .english: return "Check past leave records"
        case .japanese: return "過去の休暇記録を確認"
        case .chinese: return "查看过去的休假记录"
        }
    }

    static var vacation: String {
        switch lang {
        case .korean: return "휴가"
        case .english: return "Leave"
        case .japanese: return "休暇"
        case .chinese: return "假期"
        }
    }

    // MARK: - 캘린더 화면
    static var navTitleCalendar: String {
        switch lang {
        case .korean: return "캘린더"
        case .english: return "Calendar"
        case .japanese: return "カレンダー"
        case .chinese: return "日历"
        }
    }

    static var holiday: String {
        switch lang {
        case .korean: return "공휴일"
        case .english: return "Holiday"
        case .japanese: return "祝日"
        case .chinese: return "节假日"
        }
    }

    static var annualLeave: String {
        switch lang {
        case .korean: return "연차"
        case .english: return "Annual Leave"
        case .japanese: return "有給休暇"
        case .chinese: return "年假"
        }
    }

    static var weekend: String {
        switch lang {
        case .korean: return "주말"
        case .english: return "Weekend"
        case .japanese: return "週末"
        case .chinese: return "周末"
        }
    }

    static var noSchedule: String {
        switch lang {
        case .korean: return "일정 없음"
        case .english: return "No schedule"
        case .japanese: return "予定なし"
        case .chinese: return "无日程"
        }
    }

    static var substituteHoliday: String {
        switch lang {
        case .korean: return "대체공휴일"
        case .english: return "Substitute Holiday"
        case .japanese: return "振替休日"
        case .chinese: return "补休日"
        }
    }

    static var deleteLeave: String {
        switch lang {
        case .korean: return "휴가 삭제"
        case .english: return "Delete Leave"
        case .japanese: return "休暇を削除"
        case .chinese: return "删除假期"
        }
    }

    static var deleteLeaveConfirm: String {
        switch lang {
        case .korean: return "이 휴가 기록을 삭제하시겠습니까?\n연차가 복원됩니다."
        case .english: return "Delete this leave record?\nAnnual leave will be restored."
        case .japanese: return "この休暇記録を削除しますか？\n有給が復元されます。"
        case .chinese: return "确定删除此休假记录吗？\n年假将被恢复。"
        }
    }

    static var cancel: String {
        switch lang {
        case .korean: return "취소"
        case .english: return "Cancel"
        case .japanese: return "キャンセル"
        case .chinese: return "取消"
        }
    }

    static var delete: String {
        switch lang {
        case .korean: return "삭제"
        case .english: return "Delete"
        case .japanese: return "削除"
        case .chinese: return "删除"
        }
    }

    static var myLeaveSchedule: String {
        switch lang {
        case .korean: return "나의 연차 일정"
        case .english: return "My Leave Schedule"
        case .japanese: return "休暇スケジュール"
        case .chinese: return "我的年假日程"
        }
    }

    static var noLeaveRegistered: String {
        switch lang {
        case .korean: return "등록된 연차가 없습니다"
        case .english: return "No leave registered"
        case .japanese: return "登録された休暇がありません"
        case .chinese: return "没有登记的年假"
        }
    }

    static var tapToEditSwipeToDelete: String {
        switch lang {
        case .korean: return "탭하여 수정 · 스와이프하여 삭제"
        case .english: return "Tap to edit · Swipe to delete"
        case .japanese: return "タップで編集 · スワイプで削除"
        case .chinese: return "点击编辑 · 滑动删除"
        }
    }

    static var upcomingSchedule: String {
        switch lang {
        case .korean: return "예정된 일정"
        case .english: return "Upcoming"
        case .japanese: return "予定"
        case .chinese: return "即将到来"
        }
    }

    static var pastSchedule: String {
        switch lang {
        case .korean: return "지난 일정"
        case .english: return "Past"
        case .japanese: return "過去"
        case .chinese: return "过去"
        }
    }

    static var today: String {
        switch lang {
        case .korean: return "오늘"
        case .english: return "Today"
        case .japanese: return "今日"
        case .chinese: return "今天"
        }
    }

    static var weekdays: [String] {
        switch lang {
        case .korean: return ["일", "월", "화", "수", "목", "금", "토"]
        case .english: return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        case .japanese: return ["日", "月", "火", "水", "木", "金", "土"]
        case .chinese: return ["日", "一", "二", "三", "四", "五", "六"]
        }
    }

    static func monthYearFormat(year: Int, month: Int) -> String {
        switch lang {
        case .korean: return "\(year)년 \(month)월"
        case .english:
            let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                              "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            return "\(monthNames[month - 1]) \(year)"
        case .japanese: return "\(year)年 \(month)月"
        case .chinese: return "\(year)年\(month)月"
        }
    }

    static func monthShort(_ month: Int) -> String {
        switch lang {
        case .korean: return "\(month)월"
        case .english:
            let names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            return names[month - 1]
        case .japanese: return "\(month)月"
        case .chinese: return "\(month)月"
        }
    }

    static func dayUnit(_ days: Int) -> String {
        switch lang {
        case .korean: return "\(days)일"
        case .english: return "\(days)d"
        case .japanese: return "\(days)日"
        case .chinese: return "\(days)天"
        }
    }

    static var dayUnitSuffix: String {
        switch lang {
        case .korean: return "일"
        case .english: return " days"
        case .japanese: return "日"
        case .chinese: return "天"
        }
    }

    // MARK: - 추천 화면
    static var navTitleRecommendations: String {
        switch lang {
        case .korean: return "휴가 추천"
        case .english: return "Leave Recommendations"
        case .japanese: return "休暇おすすめ"
        case .chinese: return "休假推荐"
        }
    }

    static func yearRecommendation(year: Int) -> String {
        switch lang {
        case .korean: return "\(year)년 추천"
        case .english: return "\(year) Recommendations"
        case .japanese: return "\(year)年 おすすめ"
        case .chinese: return "\(year)年推荐"
        }
    }

    static var availableLeave: String {
        switch lang {
        case .korean: return "사용 가능한 연차"
        case .english: return "Available Leave"
        case .japanese: return "利用可能な有給"
        case .chinese: return "可用年假"
        }
    }

    static var analyzingSchedule: String {
        switch lang {
        case .korean: return "추천 일정 분석 중..."
        case .english: return "Analyzing schedule..."
        case .japanese: return "スケジュール分析中..."
        case .chinese: return "正在分析日程..."
        }
    }

    static var noRecommendations: String {
        switch lang {
        case .korean: return "추천 일정이 없습니다"
        case .english: return "No recommendations"
        case .japanese: return "おすすめがありません"
        case .chinese: return "没有推荐日程"
        }
    }

    static var noRecommendationsHint: String {
        switch lang {
        case .korean: return "선호도 설정을 확인하거나\n연차를 더 확보해보세요"
        case .english: return "Check your preferences or\nsecure more leave days"
        case .japanese: return "設定を確認するか\n有給を確保してください"
        case .chinese: return "请检查偏好设置或\n确保有更多年假"
        }
    }

    static var previewCalendar: String {
        switch lang {
        case .korean: return "추천 일정 미리보기"
        case .english: return "Schedule Preview"
        case .japanese: return "スケジュールプレビュー"
        case .chinese: return "日程预览"
        }
    }

    static func leaveRequired(_ days: Int) -> String {
        switch lang {
        case .korean: return "\(days)일 연차"
        case .english: return "\(days)d leave"
        case .japanese: return "\(days)日有給"
        case .chinese: return "\(days)天年假"
        }
    }

    static func daysOff(_ days: Int) -> String {
        switch lang {
        case .korean: return "\(days)일 휴식"
        case .english: return "\(days)d off"
        case .japanese: return "\(days)日休み"
        case .chinese: return "\(days)天休息"
        }
    }

    static var addToScheduleAction: String {
        switch lang {
        case .korean: return "일정에 추가하기"
        case .english: return "Add to Schedule"
        case .japanese: return "予定に追加"
        case .chinese: return "添加到日程"
        }
    }

    static var addedToScheduleAction: String {
        switch lang {
        case .korean: return "일정에 추가됨"
        case .english: return "Added to Schedule"
        case .japanese: return "予定に追加済み"
        case .chinese: return "已添加到日程"
        }
    }

    // Date preview legend
    static var workday: String {
        switch lang {
        case .korean: return "평일"
        case .english: return "Workday"
        case .japanese: return "平日"
        case .chinese: return "工作日"
        }
    }

    // MARK: - 설정 화면
    static var navTitleSettings: String {
        switch lang {
        case .korean: return "설정"
        case .english: return "Settings"
        case .japanese: return "設定"
        case .chinese: return "设置"
        }
    }

    static var name: String {
        switch lang {
        case .korean: return "이름"
        case .english: return "Name"
        case .japanese: return "名前"
        case .chinese: return "姓名"
        }
    }

    static func joinDate(_ dateStr: String) -> String {
        switch lang {
        case .korean: return "가입일: \(dateStr)"
        case .english: return "Joined: \(dateStr)"
        case .japanese: return "登録日: \(dateStr)"
        case .chinese: return "注册日: \(dateStr)"
        }
    }

    static var countryAndLanguage: String {
        switch lang {
        case .korean: return "국가 및 언어"
        case .english: return "Country & Language"
        case .japanese: return "国と言語"
        case .chinese: return "国家和语言"
        }
    }

    static var country: String {
        switch lang {
        case .korean: return "국가"
        case .english: return "Country"
        case .japanese: return "国"
        case .chinese: return "国家"
        }
    }

    static var language: String {
        switch lang {
        case .korean: return "언어"
        case .english: return "Language"
        case .japanese: return "言語"
        case .chinese: return "语言"
        }
    }

    static var annualLeaveSettings: String {
        switch lang {
        case .korean: return "연차 설정"
        case .english: return "Annual Leave Settings"
        case .japanese: return "有給休暇設定"
        case .chinese: return "年假设置"
        }
    }

    static var availableLeaveLabel: String {
        switch lang {
        case .korean: return "사용 가능 연차"
        case .english: return "Available Leave"
        case .japanese: return "利用可能有給"
        case .chinese: return "可用年假"
        }
    }

    static func baseAndBonus(base: String, bonus: String) -> String {
        switch lang {
        case .korean: return "기본 \(base)일 + 보너스 \(bonus)일"
        case .english: return "Base \(base)d + Bonus \(bonus)d"
        case .japanese: return "基本 \(base)日 + ボーナス \(bonus)日"
        case .chinese: return "基本 \(base)天 + 奖励 \(bonus)天"
        }
    }

    static var totalLeave: String {
        switch lang {
        case .korean: return "총 연차"
        case .english: return "Total Leave"
        case .japanese: return "有給合計"
        case .chinese: return "总年假"
        }
    }

    static var usedLeave: String {
        switch lang {
        case .korean: return "사용한 연차"
        case .english: return "Used Leave"
        case .japanese: return "使用済み"
        case .chinese: return "已使用"
        }
    }

    static var yearStartMonth: String {
        switch lang {
        case .korean: return "연차 기준월"
        case .english: return "Year Start Month"
        case .japanese: return "基準月"
        case .chinese: return "年假起始月"
        }
    }

    static var bonusLeave: String {
        switch lang {
        case .korean: return "보너스 연차"
        case .english: return "Bonus Leave"
        case .japanese: return "ボーナス休暇"
        case .chinese: return "奖励年假"
        }
    }

    static var addBonusLeave: String {
        switch lang {
        case .korean: return "보너스 연차 추가"
        case .english: return "Add Bonus Leave"
        case .japanese: return "ボーナス休暇を追加"
        case .chinese: return "添加奖励年假"
        }
    }

    static var bonusLeaveFooter: String {
        switch lang {
        case .korean: return "대체휴무, 포상휴가 등 추가로 받은 연차를 관리합니다."
        case .english: return "Manage additional leave from comp time, rewards, etc."
        case .japanese: return "代替休暇、報奨休暇など追加の有給を管理します。"
        case .chinese: return "管理补休、奖励假等额外年假。"
        }
    }

    static var vacationStyle: String {
        switch lang {
        case .korean: return "휴가 스타일"
        case .english: return "Vacation Style"
        case .japanese: return "休暇スタイル"
        case .chinese: return "休假风格"
        }
    }

    static var preferencesSettings: String {
        switch lang {
        case .korean: return "선호도 설정"
        case .english: return "Preferences"
        case .japanese: return "好み設定"
        case .chinese: return "偏好设置"
        }
    }

    static var preferredDuration: String {
        switch lang {
        case .korean: return "선호 기간"
        case .english: return "Duration"
        case .japanese: return "期間"
        case .chinese: return "偏好时长"
        }
    }

    static var preferredSeason: String {
        switch lang {
        case .korean: return "선호 계절"
        case .english: return "Season"
        case .japanese: return "季節"
        case .chinese: return "偏好季节"
        }
    }

    static var preferredActivity: String {
        switch lang {
        case .korean: return "선호 활동"
        case .english: return "Activity"
        case .japanese: return "活動"
        case .chinese: return "偏好活动"
        }
    }

    static var usageStats: String {
        switch lang {
        case .korean: return "사용 통계"
        case .english: return "Usage Stats"
        case .japanese: return "利用統計"
        case .chinese: return "使用统计"
        }
    }

    static var completed: String {
        switch lang {
        case .korean: return "사용 완료"
        case .english: return "Completed"
        case .japanese: return "使用済み"
        case .chinese: return "已完成"
        }
    }

    static var plannedLeave: String {
        switch lang {
        case .korean: return "예정된 휴가"
        case .english: return "Planned Leave"
        case .japanese: return "予定の休暇"
        case .chinese: return "计划中的假期"
        }
    }

    static var leaveUsageRate: String {
        switch lang {
        case .korean: return "연차 소진율"
        case .english: return "Usage Rate"
        case .japanese: return "消化率"
        case .chinese: return "使用率"
        }
    }

    static var dataManagement: String {
        switch lang {
        case .korean: return "데이터 관리"
        case .english: return "Data Management"
        case .japanese: return "データ管理"
        case .chinese: return "数据管理"
        }
    }

    static var backupToICloud: String {
        switch lang {
        case .korean: return "iCloud에 백업"
        case .english: return "Backup to iCloud"
        case .japanese: return "iCloudにバックアップ"
        case .chinese: return "备份到iCloud"
        }
    }

    static var restoreFromICloud: String {
        switch lang {
        case .korean: return "iCloud에서 복원"
        case .english: return "Restore from iCloud"
        case .japanese: return "iCloudから復元"
        case .chinese: return "从iCloud恢复"
        }
    }

    static var resetData: String {
        switch lang {
        case .korean: return "연차 데이터 초기화"
        case .english: return "Reset Leave Data"
        case .japanese: return "データリセット"
        case .chinese: return "重置数据"
        }
    }

    static var resetDataTitle: String {
        switch lang {
        case .korean: return "연차 데이터 초기화"
        case .english: return "Reset Leave Data"
        case .japanese: return "データリセット"
        case .chinese: return "重置数据"
        }
    }

    static var resetDataMessage: String {
        switch lang {
        case .korean: return "모든 연차 기록이 삭제되고 사용한 연차가 0으로 초기화됩니다. 이 작업은 되돌릴 수 없습니다."
        case .english: return "All leave records will be deleted and used leave will be reset to 0. This cannot be undone."
        case .japanese: return "すべての休暇記録が削除され、使用済み休暇が0にリセットされます。この操作は元に戻せません。"
        case .chinese: return "所有休假记录将被删除，已使用年假将重置为0。此操作无法撤销。"
        }
    }

    static var reset: String {
        switch lang {
        case .korean: return "초기화"
        case .english: return "Reset"
        case .japanese: return "リセット"
        case .chinese: return "重置"
        }
    }

    static var appInfo: String {
        switch lang {
        case .korean: return "앱 정보"
        case .english: return "App Info"
        case .japanese: return "アプリ情報"
        case .chinese: return "应用信息"
        }
    }

    static var version: String {
        switch lang {
        case .korean: return "버전"
        case .english: return "Version"
        case .japanese: return "バージョン"
        case .chinese: return "版本"
        }
    }

    static var developer: String {
        switch lang {
        case .korean: return "개발"
        case .english: return "Developer"
        case .japanese: return "開発"
        case .chinese: return "开发者"
        }
    }

    static var rateApp: String {
        switch lang {
        case .korean: return "앱 평가하기"
        case .english: return "Rate This App"
        case .japanese: return "アプリを評価"
        case .chinese: return "评价应用"
        }
    }

    static var confirm: String {
        switch lang {
        case .korean: return "확인"
        case .english: return "OK"
        case .japanese: return "確認"
        case .chinese: return "确认"
        }
    }

    static var backup: String {
        switch lang {
        case .korean: return "백업"
        case .english: return "Backup"
        case .japanese: return "バックアップ"
        case .chinese: return "备份"
        }
    }

    static var restoreConfirmTitle: String {
        switch lang {
        case .korean: return "복원 확인"
        case .english: return "Confirm Restore"
        case .japanese: return "復元の確認"
        case .chinese: return "确认恢复"
        }
    }

    static var restore: String {
        switch lang {
        case .korean: return "복원"
        case .english: return "Restore"
        case .japanese: return "復元"
        case .chinese: return "恢复"
        }
    }

    static var restoreConfirmMessage: String {
        switch lang {
        case .korean: return "iCloud 백업에서 데이터를 복원합니다. 현재 데이터는 모두 삭제됩니다."
        case .english: return "Restore data from iCloud backup. All current data will be deleted."
        case .japanese: return "iCloudバックアップからデータを復元します。現在のデータはすべて削除されます。"
        case .chinese: return "从iCloud备份恢复数据。当前所有数据将被删除。"
        }
    }

    static func lastBackup(_ dateStr: String) -> String {
        switch lang {
        case .korean: return "마지막 백업: \(dateStr)"
        case .english: return "Last backup: \(dateStr)"
        case .japanese: return "最終バックアップ: \(dateStr)"
        case .chinese: return "上次备份: \(dateStr)"
        }
    }

    // MARK: - 선호도 설정
    static var navTitlePreferences: String {
        switch lang {
        case .korean: return "나의 휴가 스타일"
        case .english: return "My Vacation Style"
        case .japanese: return "休暇スタイル"
        case .chinese: return "我的休假风格"
        }
    }

    static var preferredDurationSection: String {
        switch lang {
        case .korean: return "선호하는 휴가 길이"
        case .english: return "Preferred Duration"
        case .japanese: return "好みの休暇期間"
        case .chinese: return "偏好休假时长"
        }
    }

    static var preferredSeasonSection: String {
        switch lang {
        case .korean: return "선호하는 계절 (복수 선택)"
        case .english: return "Preferred Season (Multiple)"
        case .japanese: return "好みの季節（複数選択）"
        case .chinese: return "偏好季节（可多选）"
        }
    }

    static var vacationStyleSection: String {
        switch lang {
        case .korean: return "휴가 스타일"
        case .english: return "Vacation Style"
        case .japanese: return "休暇スタイル"
        case .chinese: return "休假风格"
        }
    }

    static var useBridgeDays: String {
        switch lang {
        case .korean: return "징검다리 휴일 활용"
        case .english: return "Use Bridge Days"
        case .japanese: return "飛び石連休の活用"
        case .chinese: return "利用桥接假日"
        }
    }

    static var preferConsecutive: String {
        switch lang {
        case .korean: return "연속 휴가 선호"
        case .english: return "Prefer Consecutive"
        case .japanese: return "連続休暇を好む"
        case .chinese: return "偏好连续休假"
        }
    }

    static var avoidPeakSeason: String {
        switch lang {
        case .korean: return "성수기 회피"
        case .english: return "Avoid Peak Season"
        case .japanese: return "ピークシーズン回避"
        case .chinese: return "避开旺季"
        }
    }

    static var preferredActivitySection: String {
        switch lang {
        case .korean: return "주로 하고 싶은 활동"
        case .english: return "Preferred Activities"
        case .japanese: return "したい活動"
        case .chinese: return "想做的活动"
        }
    }

    static var save: String {
        switch lang {
        case .korean: return "저장"
        case .english: return "Save"
        case .japanese: return "保存"
        case .chinese: return "保存"
        }
    }

    // MARK: - 온보딩
    static var appName: String {
        switch lang {
        case .korean: return "휴가캘린더"
        case .english: return "Holy Planner"
        case .japanese: return "休暇カレンダー"
        case .chinese: return "休假日历"
        }
    }

    static var onboardingSubtitle: String {
        switch lang {
        case .korean: return "연차를 똑똑하게 관리하고\n최적의 휴가 일정을 추천받으세요"
        case .english: return "Manage your leave smartly and\nget optimal vacation recommendations"
        case .japanese: return "有給を賢く管理して\n最適な休暇日程を提案します"
        case .chinese: return "智能管理年假\n获取最佳休假推荐"
        }
    }

    static var getStarted: String {
        switch lang {
        case .korean: return "시작하기"
        case .english: return "Get Started"
        case .japanese: return "始める"
        case .chinese: return "开始"
        }
    }

    static var next: String {
        switch lang {
        case .korean: return "다음"
        case .english: return "Next"
        case .japanese: return "次へ"
        case .chinese: return "下一步"
        }
    }

    static var mainFeatures: String {
        switch lang {
        case .korean: return "주요 기능"
        case .english: return "Key Features"
        case .japanese: return "主な機能"
        case .chinese: return "主要功能"
        }
    }

    static var featureLeaveManagement: String {
        switch lang {
        case .korean: return "연차 관리"
        case .english: return "Leave Management"
        case .japanese: return "有給管理"
        case .chinese: return "年假管理"
        }
    }

    static var featureLeaveManagementDesc: String {
        switch lang {
        case .korean: return "연차, 반차, 대체휴무 등\n다양한 휴가를 기록하세요"
        case .english: return "Track annual, half-day, and\ncompensatory leave"
        case .japanese: return "有給、半休、代替休暇など\n様々な休暇を記録"
        case .chinese: return "记录年假、半天假、\n补休等各种休假"
        }
    }

    static var featureAIRecommend: String {
        switch lang {
        case .korean: return "AI 추천"
        case .english: return "AI Recommend"
        case .japanese: return "AIおすすめ"
        case .chinese: return "AI推荐"
        }
    }

    static var featureAIRecommendDesc: String {
        switch lang {
        case .korean: return "공휴일과 주말을 활용한\n최적의 휴가 조합을 추천"
        case .english: return "Optimal leave combos using\nholidays and weekends"
        case .japanese: return "祝日と週末を活用した\n最適な休暇の組み合わせ"
        case .chinese: return "利用节假日和周末\n推荐最佳休假组合"
        }
    }

    static var featureBonusLeave: String {
        switch lang {
        case .korean: return "보너스 연차"
        case .english: return "Bonus Leave"
        case .japanese: return "ボーナス休暇"
        case .chinese: return "奖励年假"
        }
    }

    static var featureBonusLeaveDesc: String {
        switch lang {
        case .korean: return "대체휴무, 포상휴가 등\n추가 연차도 관리"
        case .english: return "Manage comp time, rewards\nand extra leave"
        case .japanese: return "代替休暇、報奨休暇など\n追加の有給も管理"
        case .chinese: return "管理补休、奖励假\n等额外年假"
        }
    }

    static var featureWidget: String {
        switch lang {
        case .korean: return "위젯"
        case .english: return "Widget"
        case .japanese: return "ウィジェット"
        case .chinese: return "小组件"
        }
    }

    static var featureWidgetDesc: String {
        switch lang {
        case .korean: return "홈 화면에서 바로\n남은 연차 확인"
        case .english: return "Check remaining leave\nright from home screen"
        case .japanese: return "ホーム画面から\n残り有給を確認"
        case .chinese: return "在主屏幕上\n直接查看剩余年假"
        }
    }

    static var selectCountry: String {
        switch lang {
        case .korean: return "국가를 선택하세요"
        case .english: return "Select your country"
        case .japanese: return "国を選んでください"
        case .chinese: return "选择您的国家"
        }
    }

    static var selectCountryDesc: String {
        switch lang {
        case .korean: return "공휴일 데이터가 국가에 맞게 설정됩니다"
        case .english: return "Holiday data will be set for your country"
        case .japanese: return "祝日データが国に合わせて設定されます"
        case .chinese: return "节假日数据将根据您的国家设置"
        }
    }

    static var enterName: String {
        switch lang {
        case .korean: return "이름을 알려주세요"
        case .english: return "What's your name?"
        case .japanese: return "お名前を教えてください"
        case .chinese: return "请输入您的姓名"
        }
    }

    static var enterNameDesc: String {
        switch lang {
        case .korean: return "앱에서 사용할 이름을 입력해주세요"
        case .english: return "Enter the name to use in the app"
        case .japanese: return "アプリで使う名前を入力してください"
        case .chinese: return "请输入在应用中使用的姓名"
        }
    }

    static var leaveSetup: String {
        switch lang {
        case .korean: return "연차 정보 설정"
        case .english: return "Leave Setup"
        case .japanese: return "有給設定"
        case .chinese: return "年假设置"
        }
    }

    static var leaveSetupDesc: String {
        switch lang {
        case .korean: return "나중에 설정에서 변경할 수 있어요"
        case .english: return "You can change this later in settings"
        case .japanese: return "後で設定で変更できます"
        case .chinese: return "稍后可在设置中更改"
        }
    }

    static var totalAnnualLeave: String {
        switch lang {
        case .korean: return "올해 총 연차"
        case .english: return "Total Annual Leave"
        case .japanese: return "今年の有給合計"
        case .chinese: return "今年总年假"
        }
    }

    static var yearStartMonthLabel: String {
        switch lang {
        case .korean: return "연차 기준월"
        case .english: return "Year Start Month"
        case .japanese: return "基準月"
        case .chinese: return "年假起始月"
        }
    }

    static var yearStartMonthDesc: String {
        switch lang {
        case .korean: return "연차가 갱신되는 시작 월"
        case .english: return "Month when annual leave renews"
        case .japanese: return "有給が更新される月"
        case .chinese: return "年假更新的月份"
        }
    }

    static var defaultUser: String {
        switch lang {
        case .korean: return "사용자"
        case .english: return "User"
        case .japanese: return "ユーザー"
        case .chinese: return "用户"
        }
    }

    // MARK: - 열거형 표시 이름

    // PreferredDuration
    static func durationName(_ duration: PreferredDuration) -> String {
        switch lang {
        case .korean:
            switch duration {
            case .short: return "1-2일"
            case .medium: return "3-4일"
            case .long: return "5일 이상"
            case .mixed: return "혼합"
            }
        case .english:
            switch duration {
            case .short: return "1-2 days"
            case .medium: return "3-4 days"
            case .long: return "5+ days"
            case .mixed: return "Mixed"
            }
        case .japanese:
            switch duration {
            case .short: return "1-2日"
            case .medium: return "3-4日"
            case .long: return "5日以上"
            case .mixed: return "混合"
            }
        case .chinese:
            switch duration {
            case .short: return "1-2天"
            case .medium: return "3-4天"
            case .long: return "5天以上"
            case .mixed: return "混合"
            }
        }
    }

    // Season
    static func seasonName(_ season: Season) -> String {
        switch lang {
        case .korean:
            switch season {
            case .spring: return "봄"
            case .summer: return "여름"
            case .fall: return "가을"
            case .winter: return "겨울"
            }
        case .english:
            switch season {
            case .spring: return "Spring"
            case .summer: return "Summer"
            case .fall: return "Fall"
            case .winter: return "Winter"
            }
        case .japanese:
            switch season {
            case .spring: return "春"
            case .summer: return "夏"
            case .fall: return "秋"
            case .winter: return "冬"
            }
        case .chinese:
            switch season {
            case .spring: return "春"
            case .summer: return "夏"
            case .fall: return "秋"
            case .winter: return "冬"
            }
        }
    }

    // ActivityType
    static func activityName(_ activity: ActivityType) -> String {
        switch lang {
        case .korean:
            switch activity {
            case .travel: return "여행"
            case .rest: return "휴식"
            case .family: return "가족시간"
            case .hobby: return "취미활동"
            case .selfCare: return "자기계발"
            }
        case .english:
            switch activity {
            case .travel: return "Travel"
            case .rest: return "Rest"
            case .family: return "Family"
            case .hobby: return "Hobby"
            case .selfCare: return "Self-care"
            }
        case .japanese:
            switch activity {
            case .travel: return "旅行"
            case .rest: return "休息"
            case .family: return "家族"
            case .hobby: return "趣味"
            case .selfCare: return "自己啓発"
            }
        case .chinese:
            switch activity {
            case .travel: return "旅行"
            case .rest: return "休息"
            case .family: return "家庭"
            case .hobby: return "爱好"
            case .selfCare: return "自我提升"
            }
        }
    }

    // LeaveType
    static func leaveTypeName(_ type: LeaveType) -> String {
        switch lang {
        case .korean:
            switch type {
            case .annual: return "연차"
            case .half: return "반차"
            case .quarter: return "반반차"
            case .compensatory: return "대체휴무"
            case .official: return "공가"
            case .sick: return "병가"
            case .special: return "특별휴가"
            }
        case .english:
            switch type {
            case .annual: return "Annual"
            case .half: return "Half-day"
            case .quarter: return "Quarter-day"
            case .compensatory: return "Comp"
            case .official: return "Official"
            case .sick: return "Sick"
            case .special: return "Special"
            }
        case .japanese:
            switch type {
            case .annual: return "有給"
            case .half: return "半休"
            case .quarter: return "時間休"
            case .compensatory: return "代替休暇"
            case .official: return "公休"
            case .sick: return "病休"
            case .special: return "特別休暇"
            }
        case .chinese:
            switch type {
            case .annual: return "年假"
            case .half: return "半天假"
            case .quarter: return "短假"
            case .compensatory: return "补休"
            case .official: return "公假"
            case .sick: return "病假"
            case .special: return "特殊假"
            }
        }
    }

    // LeaveStatus
    static func leaveStatusName(_ status: LeaveStatus) -> String {
        switch lang {
        case .korean:
            switch status {
            case .planned: return "예정"
            case .used: return "사용완료"
            case .cancelled: return "취소"
            }
        case .english:
            switch status {
            case .planned: return "Planned"
            case .used: return "Used"
            case .cancelled: return "Cancelled"
            }
        case .japanese:
            switch status {
            case .planned: return "予定"
            case .used: return "使用済み"
            case .cancelled: return "キャンセル"
            }
        case .chinese:
            switch status {
            case .planned: return "计划中"
            case .used: return "已使用"
            case .cancelled: return "已取消"
            }
        }
    }

    // BonusLeaveType
    static func bonusLeaveTypeName(_ type: BonusLeaveType) -> String {
        switch lang {
        case .korean: return type.rawValue
        case .english:
            switch type {
            case .compensatory: return "Comp Time"
            case .reward: return "Reward"
            case .refresh: return "Refresh"
            case .marriage: return "Marriage"
            case .bereavement: return "Bereavement"
            case .sick: return "Sick"
            case .maternity: return "Maternity"
            case .familyBalance: return "Family"
            case .official: return "Official"
            case .other: return "Other"
            }
        case .japanese:
            switch type {
            case .compensatory: return "代替休暇"
            case .reward: return "報奨休暇"
            case .refresh: return "リフレッシュ"
            case .marriage: return "結婚"
            case .bereavement: return "忌引"
            case .sick: return "病休"
            case .maternity: return "産休"
            case .familyBalance: return "家族"
            case .official: return "公休"
            case .other: return "その他"
            }
        case .chinese:
            switch type {
            case .compensatory: return "补休"
            case .reward: return "奖励假"
            case .refresh: return "疗养假"
            case .marriage: return "婚假"
            case .bereavement: return "丧假"
            case .sick: return "病假"
            case .maternity: return "产假"
            case .familyBalance: return "家庭假"
            case .official: return "公假"
            case .other: return "其他"
            }
        }
    }

    // MARK: - 추천 엔진 문자열
    static var goldenWeek: String {
        switch lang {
        case .korean: return "황금연휴"
        case .english: return "Golden Week"
        case .japanese: return "ゴールデンウィーク"
        case .chinese: return "黄金周"
        }
    }

    static var noLeaveRequired: String {
        switch lang {
        case .korean: return "연차없음"
        case .english: return "No Leave"
        case .japanese: return "有給不要"
        case .chinese: return "无需年假"
        }
    }

    static var bridgeDay: String {
        switch lang {
        case .korean: return "징검다리"
        case .english: return "Bridge Day"
        case .japanese: return "飛び石"
        case .chinese: return "桥接假"
        }
    }

    static var topEfficiency: String {
        switch lang {
        case .korean: return "효율최고"
        case .english: return "Best Value"
        case .japanese: return "最高効率"
        case .chinese: return "最高效率"
        }
    }

    static var consecutiveLeave: String {
        switch lang {
        case .korean: return "연속휴가"
        case .english: return "Extended Leave"
        case .japanese: return "連続休暇"
        case .chinese: return "连续休假"
        }
    }

    static var efficient: String {
        switch lang {
        case .korean: return "효율적"
        case .english: return "Efficient"
        case .japanese: return "効率的"
        case .chinese: return "高效"
        }
    }

    static var weekendHoliday: String {
        switch lang {
        case .korean: return "주말 연휴"
        case .english: return "Weekend Holiday"
        case .japanese: return "週末休暇"
        case .chinese: return "周末假日"
        }
    }

    static var familyTrip: String {
        switch lang {
        case .korean: return "가족여행"
        case .english: return "Family Trip"
        case .japanese: return "家族旅行"
        case .chinese: return "家庭旅行"
        }
    }

    static var family: String {
        switch lang {
        case .korean: return "가족"
        case .english: return "Family"
        case .japanese: return "家族"
        case .chinese: return "家庭"
        }
    }

    static var majorHoliday: String {
        switch lang {
        case .korean: return "명절연휴"
        case .english: return "Major Holiday"
        case .japanese: return "大型連休"
        case .chinese: return "重大节日"
        }
    }

    static func seasonTag(for month: Int) -> String {
        switch month {
        case 3, 4, 5: return seasonName(.spring)
        case 6, 7, 8: return seasonName(.summer)
        case 9, 10, 11: return seasonName(.fall)
        default: return seasonName(.winter)
        }
    }

    static func seasonalAdvice(month: Int) -> String {
        switch lang {
        case .korean:
            switch month {
            case 3, 4, 5: return "봄나들이 추천."
            case 6, 7, 8: return "여름 휴가 적기."
            case 9, 10, 11: return "단풍 여행 추천."
            case 12, 1, 2: return "연말연시 힐링."
            default: return ""
            }
        case .english:
            switch month {
            case 3, 4, 5: return "Great for spring outings."
            case 6, 7, 8: return "Perfect summer vacation."
            case 9, 10, 11: return "Enjoy autumn colors."
            case 12, 1, 2: return "Year-end relaxation."
            default: return ""
            }
        case .japanese:
            switch month {
            case 3, 4, 5: return "春のお出かけに最適。"
            case 6, 7, 8: return "夏休みにぴったり。"
            case 9, 10, 11: return "紅葉旅行におすすめ。"
            case 12, 1, 2: return "年末年始のリラックス。"
            default: return ""
            }
        case .chinese:
            switch month {
            case 3, 4, 5: return "适合春游。"
            case 6, 7, 8: return "暑假好时机。"
            case 9, 10, 11: return "赏秋好时节。"
            case 12, 1, 2: return "年末休息。"
            default: return ""
            }
        }
    }

    static func daysHoliday(_ days: Int) -> String {
        switch lang {
        case .korean: return "\(days)일 연휴"
        case .english: return "\(days)-day break"
        case .japanese: return "\(days)日連休"
        case .chinese: return "\(days)天假期"
        }
    }

    static func goldenWeekTitle(holidayName: String) -> String {
        switch lang {
        case .korean: return "\(holidayName) 황금연휴"
        case .english: return "\(holidayName) Golden Week"
        case .japanese: return "\(holidayName) ゴールデンウィーク"
        case .chinese: return "\(holidayName) 黄金周"
        }
    }

    static func holidayBreak(name: String) -> String {
        switch lang {
        case .korean: return "\(name) 연휴"
        case .english: return "\(name) Break"
        case .japanese: return "\(name) 連休"
        case .chinese: return "\(name) 假期"
        }
    }

    static func noLeaveDaysOff(weekdayStart: String, weekdayEnd: String, holidayDesc: String, totalDays: Int) -> String {
        switch lang {
        case .korean:
            return "\(weekdayStart)~\(weekdayEnd) \(holidayDesc)로 연차 없이 \(totalDays)일 연휴!"
        case .english:
            return "\(weekdayStart)-\(weekdayEnd): \(totalDays) days off with \(holidayDesc), no leave needed!"
        case .japanese:
            return "\(weekdayStart)〜\(weekdayEnd) \(holidayDesc)で有給なし\(totalDays)日連休！"
        case .chinese:
            return "\(weekdayStart)~\(weekdayEnd) \(holidayDesc)，无需年假\(totalDays)天假期！"
        }
    }

    static func bridgeDayTitle(holidayName: String) -> String {
        switch lang {
        case .korean: return "\(holidayName) 징검다리 연휴"
        case .english: return "\(holidayName) Bridge Holiday"
        case .japanese: return "\(holidayName) 飛び石連休"
        case .chinese: return "\(holidayName) 桥接假期"
        }
    }

    static func bridgeDayDescMonday(holidayName: String) -> String {
        switch lang {
        case .korean: return "월요일 연차 1일로 4일 연휴! \(holidayName) 앞 월요일을 활용하세요."
        case .english: return "1 day leave on Monday for 4-day weekend! Use Monday before \(holidayName)."
        case .japanese: return "月曜1日の有給で4連休！\(holidayName)前の月曜を活用。"
        case .chinese: return "周一请1天年假获得4天假期！利用\(holidayName)前的周一。"
        }
    }

    static func bridgeDayDescFriday(holidayName: String) -> String {
        switch lang {
        case .korean: return "금요일 연차 1일로 4일 연휴! \(holidayName) 다음 금요일을 활용하세요."
        case .english: return "1 day leave on Friday for 4-day weekend! Use Friday after \(holidayName)."
        case .japanese: return "金曜1日の有給で4連休！\(holidayName)後の金曜を活用。"
        case .chinese: return "周五请1天年假获得4天假期！利用\(holidayName)后的周五。"
        }
    }

    static func connectedLeaveTitle(holidayName: String) -> String {
        switch lang {
        case .korean: return "\(holidayName) 연계 휴가"
        case .english: return "\(holidayName) Extended Leave"
        case .japanese: return "\(holidayName) 連携休暇"
        case .chinese: return "\(holidayName) 连休"
        }
    }

    static func connectedLeaveDesc(holidayName: String, leaveDays: Int, totalDays: Int) -> String {
        switch lang {
        case .korean: return "\(holidayName) 연휴를 활용하여 연차 \(leaveDays)일로 \(totalDays)일 연휴를 만들 수 있어요."
        case .english: return "Use \(leaveDays) leave days around \(holidayName) for \(totalDays) days off."
        case .japanese: return "\(holidayName)を活用して有給\(leaveDays)日で\(totalDays)連休。"
        case .chinese: return "利用\(holidayName)，请\(leaveDays)天年假获得\(totalDays)天假期。"
        }
    }

    static func weeklyLeaveTitle(holidayName: String) -> String {
        switch lang {
        case .korean: return "\(holidayName) 연계 주간휴가"
        case .english: return "\(holidayName) Week Off"
        case .japanese: return "\(holidayName) 週間休暇"
        case .chinese: return "\(holidayName) 周假"
        }
    }

    static func weeklyLeaveDesc(holidayName: String, leaveDays: Int) -> String {
        switch lang {
        case .korean: return "\(holidayName)이 있는 주를 활용! 연차 \(leaveDays)일로 9일 연휴."
        case .english: return "Take the week with \(holidayName)! \(leaveDays) leave days for 9 days off."
        case .japanese: return "\(holidayName)のある週を活用！有給\(leaveDays)日で9連休。"
        case .chinese: return "利用\(holidayName)所在周！请\(leaveDays)天年假获得9天假期。"
        }
    }

    static func mayGoldenWeekDesc(leaveDays: Int) -> String {
        switch lang {
        case .korean: return "어린이날과 근로자의 날을 활용한 황금연휴! 연차 \(leaveDays)일로 최대 6일 연휴를 만들 수 있어요."
        case .english: return "Golden week around Children's Day! \(leaveDays) leave days for up to 6 days off."
        case .japanese: return "こどもの日を活用したゴールデンウィーク！有給\(leaveDays)日で最大6連休。"
        case .chinese: return "利用五一黄金周！请\(leaveDays)天年假获得最多6天假期。"
        }
    }

    static var mayGoldenWeekTitle: String {
        switch lang {
        case .korean: return "5월 황금연휴"
        case .english: return "May Golden Week"
        case .japanese: return "5月ゴールデンウィーク"
        case .chinese: return "五月黄金周"
        }
    }

    // MARK: - 날짜 로케일
    static var localeIdentifier: String {
        switch lang {
        case .korean: return "ko_KR"
        case .english: return "en_US"
        case .japanese: return "ja_JP"
        case .chinese: return "zh_CN"
        }
    }

    static func dateFormat(style: String) -> String {
        switch style {
        case "monthDay":
            switch lang {
            case .korean: return "M월 d일 (E)"
            case .english: return "MMM d (E)"
            case .japanese: return "M月d日(E)"
            case .chinese: return "M月d日(E)"
            }
        case "monthDayOnly":
            switch lang {
            case .korean: return "M월 d일"
            case .english: return "MMM d"
            case .japanese: return "M月d日"
            case .chinese: return "M月d日"
            }
        case "yearMonth":
            switch lang {
            case .korean: return "yyyy년 M월"
            case .english: return "MMM yyyy"
            case .japanese: return "yyyy年M月"
            case .chinese: return "yyyy年M月"
            }
        default:
            return "M/d(E)"
        }
    }

    // Legend labels for recommendation calendar preview
    static var goldenWeekLegend: String {
        switch lang {
        case .korean: return "황금연휴"
        case .english: return "Golden Week"
        case .japanese: return "GW"
        case .chinese: return "黄金周"
        }
    }

    static var bridgeDayLegend: String {
        switch lang {
        case .korean: return "징검다리"
        case .english: return "Bridge"
        case .japanese: return "飛び石"
        case .chinese: return "桥接假"
        }
    }

    static var consecutiveLeaveLegend: String {
        switch lang {
        case .korean: return "연속휴가"
        case .english: return "Extended"
        case .japanese: return "連続"
        case .chinese: return "连休"
        }
    }

    // Extra items count
    static func moreItems(_ count: Int) -> String {
        switch lang {
        case .korean: return "외 \(count)건"
        case .english: return "+\(count) more"
        case .japanese: return "他\(count)件"
        case .chinese: return "另外\(count)项"
        }
    }

    // Items count
    static func itemCount(_ count: Int) -> String {
        switch lang {
        case .korean: return "\(count)건"
        case .english: return "\(count)"
        case .japanese: return "\(count)件"
        case .chinese: return "\(count)项"
        }
    }

    static func itemCountUnit(_ count: Int) -> String {
        switch lang {
        case .korean: return "\(count)개"
        case .english: return "\(count)"
        case .japanese: return "\(count)個"
        case .chinese: return "\(count)个"
        }
    }

    // Accessibility
    static func accessibilityDayLabel(day: Int, isToday: Bool, isHoliday: Bool, isLeave: Bool, isSelected: Bool) -> String {
        var parts: [String] = ["\(day)\(dayUnitSuffix)"]
        if isToday { parts.append(today) }
        if isHoliday { parts.append(holiday) }
        if isLeave { parts.append(annualLeave) }
        if isSelected {
            switch lang {
            case .korean: parts.append("선택됨")
            case .english: parts.append("selected")
            case .japanese: parts.append("選択中")
            case .chinese: parts.append("已选中")
            }
        }
        return parts.joined(separator: ", ")
    }

    static var legendAccessibility: String {
        switch lang {
        case .korean: return "범례: 빨간색 공휴일, 초록색 연차, 파란색 주말"
        case .english: return "Legend: Red for holidays, Green for leave, Blue for weekends"
        case .japanese: return "凡例: 赤は祝日、緑は有給、青は週末"
        case .chinese: return "图例：红色节假日，绿色年假，蓝色周末"
        }
    }

    // DayType labels (for recommendation date preview)
    // MARK: - 연차 관리 (AddLeaveView)
    static var navTitleLeaveManagement: String {
        switch lang {
        case .korean: return "연차 관리"
        case .english: return "Leave Management"
        case .japanese: return "休暇管理"
        case .chinese: return "年假管理"
        }
    }

    static var basicLeave: String {
        switch lang {
        case .korean: return "기본 연차"
        case .english: return "Base Leave"
        case .japanese: return "基本有給"
        case .chinese: return "基本年假"
        }
    }

    static var bonus: String {
        switch lang {
        case .korean: return "보너스"
        case .english: return "Bonus"
        case .japanese: return "ボーナス"
        case .chinese: return "奖励"
        }
    }

    static var totalAvailable: String {
        switch lang {
        case .korean: return "총 사용 가능"
        case .english: return "Total Available"
        case .japanese: return "利用可能合計"
        case .chinese: return "可用总数"
        }
    }

    static var managementType: String {
        switch lang {
        case .korean: return "관리 유형"
        case .english: return "Type"
        case .japanese: return "管理タイプ"
        case .chinese: return "管理类型"
        }
    }

    static var registerLeave: String {
        switch lang {
        case .korean: return "휴가 등록"
        case .english: return "Register Leave"
        case .japanese: return "休暇登録"
        case .chinese: return "登记休假"
        }
    }

    static var addLeave: String {
        switch lang {
        case .korean: return "연차 추가"
        case .english: return "Add Leave"
        case .japanese: return "有給追加"
        case .chinese: return "添加年假"
        }
    }

    static var leaveTypeSection: String {
        switch lang {
        case .korean: return "휴가 유형"
        case .english: return "Leave Type"
        case .japanese: return "休暇タイプ"
        case .chinese: return "休假类型"
        }
    }

    static func noDeductionInfo(_ typeName: String) -> String {
        switch lang {
        case .korean: return "\(typeName)은(는) 연차에서 차감되지 않습니다."
        case .english: return "\(typeName) does not deduct from annual leave."
        case .japanese: return "\(typeName)は有給から差し引かれません。"
        case .chinese: return "\(typeName)不从年假中扣除。"
        }
    }

    static var dateSelection: String {
        switch lang {
        case .korean: return "날짜 선택"
        case .english: return "Select Dates"
        case .japanese: return "日付選択"
        case .chinese: return "选择日期"
        }
    }

    static var startDate: String {
        switch lang {
        case .korean: return "시작일"
        case .english: return "Start Date"
        case .japanese: return "開始日"
        case .chinese: return "开始日期"
        }
    }

    static var endDate: String {
        switch lang {
        case .korean: return "종료일"
        case .english: return "End Date"
        case .japanese: return "終了日"
        case .chinese: return "终止日期"
        }
    }

    static var daysUsed: String {
        switch lang {
        case .korean: return "사용일수"
        case .english: return "Days Used"
        case .japanese: return "使用日数"
        case .chinese: return "使用天数"
        }
    }

    static var memoOptional: String {
        switch lang {
        case .korean: return "메모 (선택)"
        case .english: return "Note (Optional)"
        case .japanese: return "メモ（任意）"
        case .chinese: return "备注（可选）"
        }
    }

    static var memoPlaceholder: String {
        switch lang {
        case .korean: return "휴가 목적을 입력하세요"
        case .english: return "Enter leave purpose"
        case .japanese: return "休暇の目的を入力"
        case .chinese: return "请输入休假目的"
        }
    }

    static var registerLeaveButton: String {
        switch lang {
        case .korean: return "휴가 등록하기"
        case .english: return "Register Leave"
        case .japanese: return "休暇を登録"
        case .chinese: return "登记休假"
        }
    }

    static var recentRecords: String {
        switch lang {
        case .korean: return "최근 등록 내역"
        case .english: return "Recent Records"
        case .japanese: return "最近の登録"
        case .chinese: return "最近记录"
        }
    }

    static var alert: String {
        switch lang {
        case .korean: return "알림"
        case .english: return "Alert"
        case .japanese: return "お知らせ"
        case .chinese: return "提示"
        }
    }

    static var insufficientLeave: String {
        switch lang {
        case .korean: return "연차가 부족합니다."
        case .english: return "Insufficient leave days."
        case .japanese: return "有給が不足しています。"
        case .chinese: return "年假不足。"
        }
    }

    static func leaveRegistered(_ typeName: String) -> String {
        switch lang {
        case .korean: return "\(typeName)이(가) 등록되었습니다!"
        case .english: return "\(typeName) has been registered!"
        case .japanese: return "\(typeName)が登録されました！"
        case .chinese: return "\(typeName)已登记！"
        }
    }

    static var saveFailed: String {
        switch lang {
        case .korean: return "저장에 실패했습니다. 다시 시도해주세요."
        case .english: return "Save failed. Please try again."
        case .japanese: return "保存に失敗しました。もう一度お試しください。"
        case .chinese: return "保存失败，请重试。"
        }
    }

    // MARK: - 보너스 연차 (BonusLeaveView)
    static var available: String {
        switch lang {
        case .korean: return "사용 가능"
        case .english: return "Available"
        case .japanese: return "利用可能"
        case .chinese: return "可用"
        }
    }

    static var usedComplete: String {
        switch lang {
        case .korean: return "사용 완료"
        case .english: return "Used"
        case .japanese: return "使用済み"
        case .chinese: return "已使用"
        }
    }

    static var noBonusLeave: String {
        switch lang {
        case .korean: return "등록된 보너스 연차가 없습니다"
        case .english: return "No bonus leave registered"
        case .japanese: return "ボーナス有給がありません"
        case .chinese: return "没有登记的奖励假"
        }
    }

    static var leaveDaysSection: String {
        switch lang {
        case .korean: return "연차 일수"
        case .english: return "Leave Days"
        case .japanese: return "有給日数"
        case .chinese: return "年假天数"
        }
    }

    static var daysToAdd: String {
        switch lang {
        case .korean: return "추가할 일수"
        case .english: return "Days to Add"
        case .japanese: return "追加日数"
        case .chinese: return "添加天数"
        }
    }

    static var typeSection: String {
        switch lang {
        case .korean: return "유형"
        case .english: return "Type"
        case .japanese: return "タイプ"
        case .chinese: return "类型"
        }
    }

    static var reasonSection: String {
        switch lang {
        case .korean: return "사유"
        case .english: return "Reason"
        case .japanese: return "理由"
        case .chinese: return "原因"
        }
    }

    static var reasonPlaceholder: String {
        switch lang {
        case .korean: return "예: 휴일근무 대체, 프로젝트 포상 등"
        case .english: return "e.g. Holiday work comp, Project reward"
        case .japanese: return "例：休日出勤代替、プロジェクト報奨など"
        case .chinese: return "例：节假日加班补休、项目奖励等"
        }
    }

    static var setExpiration: String {
        switch lang {
        case .korean: return "만료일 설정"
        case .english: return "Set Expiration"
        case .japanese: return "有効期限設定"
        case .chinese: return "设置到期日"
        }
    }

    static var expirationDate: String {
        switch lang {
        case .korean: return "만료일"
        case .english: return "Expiration"
        case .japanese: return "有効期限"
        case .chinese: return "到期日"
        }
    }

    static var expirationFooter: String {
        switch lang {
        case .korean: return "만료일을 설정하지 않으면 연말까지 사용 가능합니다."
        case .english: return "If no expiration is set, it can be used until year-end."
        case .japanese: return "有効期限を設定しない場合、年末まで使用可能です。"
        case .chinese: return "不设置到期日则可使用到年末。"
        }
    }

    // MARK: - 휴가 사용 내역 (LeaveHistoryView)
    static var navTitleLeaveHistory: String {
        switch lang {
        case .korean: return "휴가 사용 내역"
        case .english: return "Leave History"
        case .japanese: return "休暇履歴"
        case .chinese: return "休假记录"
        }
    }

    static var close: String {
        switch lang {
        case .korean: return "닫기"
        case .english: return "Close"
        case .japanese: return "閉じる"
        case .chinese: return "关闭"
        }
    }

    static var all: String {
        switch lang {
        case .korean: return "전체"
        case .english: return "All"
        case .japanese: return "すべて"
        case .chinese: return "全部"
        }
    }

    static var allTypes: String {
        switch lang {
        case .korean: return "전체 유형"
        case .english: return "All Types"
        case .japanese: return "全タイプ"
        case .chinese: return "全部类型"
        }
    }

    static var statUsed: String {
        switch lang {
        case .korean: return "사용 완료"
        case .english: return "Used"
        case .japanese: return "使用済み"
        case .chinese: return "已使用"
        }
    }

    static var statPlanned: String {
        switch lang {
        case .korean: return "예정"
        case .english: return "Planned"
        case .japanese: return "予定"
        case .chinese: return "计划中"
        }
    }

    static var statCancelled: String {
        switch lang {
        case .korean: return "취소"
        case .english: return "Cancelled"
        case .japanese: return "キャンセル"
        case .chinese: return "已取消"
        }
    }

    static func casesCount(_ count: Int) -> String {
        switch lang {
        case .korean: return "\(count)건"
        case .english: return "\(count)"
        case .japanese: return "\(count)件"
        case .chinese: return "\(count)项"
        }
    }

    static var noLeaveRecords: String {
        switch lang {
        case .korean: return "휴가 기록이 없습니다"
        case .english: return "No leave records"
        case .japanese: return "休暇記録がありません"
        case .chinese: return "没有休假记录"
        }
    }

    static func noLeaveForYear(_ year: Int) -> String {
        switch lang {
        case .korean: return "\(year)년에 등록된 휴가가 없습니다.\n새로운 휴가를 등록해보세요."
        case .english: return "No leave registered for \(year).\nTry registering a new leave."
        case .japanese: return "\(year)年の休暇がありません。\n新しい休暇を登録してみましょう。"
        case .chinese: return "\(year)年没有登记的休假。\n请尝试登记新的休假。"
        }
    }

    static func yearLabel(_ year: Int) -> String {
        switch lang {
        case .korean: return "\(year)년"
        case .english: return "\(year)"
        case .japanese: return "\(year)年"
        case .chinese: return "\(year)年"
        }
    }

    static func monthLabel(_ month: Int) -> String {
        switch lang {
        case .korean: return "\(month)월"
        case .english:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            return formatter.shortMonthSymbols[month - 1]
        case .japanese: return "\(month)月"
        case .chinese: return "\(month)月"
        }
    }

    static func daysCountLabel(_ count: Int) -> String {
        switch lang {
        case .korean: return "(\(count)일)"
        case .english: return "(\(count) days)"
        case .japanese: return "(\(count)日)"
        case .chinese: return "(\(count)天)"
        }
    }

    static var edit: String {
        switch lang {
        case .korean: return "수정"
        case .english: return "Edit"
        case .japanese: return "編集"
        case .chinese: return "编辑"
        }
    }

    // MARK: - 휴가 수정 (EditLeaveSheet)
    static var navTitleEditLeave: String {
        switch lang {
        case .korean: return "휴가 수정"
        case .english: return "Edit Leave"
        case .japanese: return "休暇編集"
        case .chinese: return "编辑休假"
        }
    }

    static var statusSection: String {
        switch lang {
        case .korean: return "상태"
        case .english: return "Status"
        case .japanese: return "ステータス"
        case .chinese: return "状态"
        }
    }

    static var dateSection: String {
        switch lang {
        case .korean: return "날짜"
        case .english: return "Dates"
        case .japanese: return "日付"
        case .chinese: return "日期"
        }
    }

    static func additionalLeaveUsed(_ days: String) -> String {
        switch lang {
        case .korean: return "연차 \(days)일 추가 사용"
        case .english: return "\(days) more leave days used"
        case .japanese: return "有給\(days)日追加使用"
        case .chinese: return "额外使用\(days)天年假"
        }
    }

    static func leaveRestored(_ days: String) -> String {
        switch lang {
        case .korean: return "연차 \(days)일 복원"
        case .english: return "\(days) leave days restored"
        case .japanese: return "有給\(days)日復元"
        case .chinese: return "恢复\(days)天年假"
        }
    }

    static var memo: String {
        switch lang {
        case .korean: return "메모"
        case .english: return "Note"
        case .japanese: return "メモ"
        case .chinese: return "备注"
        }
    }

    static var leavePurpose: String {
        switch lang {
        case .korean: return "휴가 목적"
        case .english: return "Leave purpose"
        case .japanese: return "休暇の目的"
        case .chinese: return "休假目的"
        }
    }

    static var schedulePreview: String {
        switch lang {
        case .korean: return "일정 미리보기"
        case .english: return "Schedule Preview"
        case .japanese: return "スケジュールプレビュー"
        case .chinese: return "日程预览"
        }
    }

    static func dayTypeLabel(_ type: DayType) -> String {
        switch type {
        case .leave: return annualLeave
        case .saturday:
            switch lang {
            case .korean: return "토"
            case .english: return "Sat"
            case .japanese: return "土"
            case .chinese: return "六"
            }
        case .sunday:
            switch lang {
            case .korean: return "일"
            case .english: return "Sun"
            case .japanese: return "日"
            case .chinese: return "日"
            }
        case .holiday:
            switch lang {
            case .korean: return "휴일"
            case .english: return "Holiday"
            case .japanese: return "祝日"
            case .chinese: return "节日"
            }
        case .workday: return workday
        }
    }
    
    // MARK: - Pro / Paywall
    static var upgradeToPro: String {
        switch lang {
        case .korean: return "Pro로 업그레이드"
        case .english: return "Upgrade to Pro"
        case .japanese: return "Proにアップグレード"
        case .chinese: return "升级到Pro版"
        }
    }
    
    static var leaveWisePro: String {
        switch lang {
        case .korean: return "휴가플래너 Pro"
        case .english: return "Leave Planner Pro"
        case .japanese: return "休暇プランナー Pro"
        case .chinese: return "休假规划 Pro"
        }
    }
    
    static var unlockAllFeatures: String {
        switch lang {
        case .korean: return "모든 기능을 잠금해제하세요"
        case .english: return "Unlock all features"
        case .japanese: return "すべての機能をアンロック"
        case .chinese: return "解锁所有功能"
        }
    }
    
    static var freeVersion: String {
        switch lang {
        case .korean: return "무료 버전"
        case .english: return "Free"
        case .japanese: return "無料版"
        case .chinese: return "免费版"
        }
    }
    
    static var proVersion: String {
        switch lang {
        case .korean: return "Pro 버전"
        case .english: return "Pro"
        case .japanese: return "Pro版"
        case .chinese: return "Pro版"
        }
    }
    
    static var purchase: String {
        switch lang {
        case .korean: return "구매하기"
        case .english: return "Purchase"
        case .japanese: return "購入"
        case .chinese: return "购买"
        }
    }
    
    static var restorePurchase: String {
        switch lang {
        case .korean: return "구매 복원"
        case .english: return "Restore Purchase"
        case .japanese: return "購入を復元"
        case .chinese: return "恢复购买"
        }
    }
    
    static var featureComparison: String {
        switch lang {
        case .korean: return "기능 비교"
        case .english: return "Feature Comparison"
        case .japanese: return "機能比較"
        case .chinese: return "功能对比"
        }
    }
    
    static var basicLeaveManagement: String {
        switch lang {
        case .korean: return "기본 연차 관리"
        case .english: return "Basic Leave Management"
        case .japanese: return "基本的な有給管理"
        case .chinese: return "基本年假管理"
        }
    }
    
    static var leaveRecommendations: String {
        switch lang {
        case .korean: return "연차 추천"
        case .english: return "Leave Recommendations"
        case .japanese: return "有給おすすめ"
        case .chinese: return "年假推荐"
        }
    }
    
    static var limitedRecommendations: String {
        switch lang {
        case .korean: return "3개 추천만 표시"
        case .english: return "3 recommendations only"
        case .japanese: return "3つの推奨のみ"
        case .chinese: return "仅显示3个推荐"
        }
    }
    
    static var unlimitedRecommendations: String {
        switch lang {
        case .korean: return "모든 추천 표시"
        case .english: return "All recommendations"
        case .japanese: return "すべての推奨"
        case .chinese: return "显示所有推荐"
        }
    }
    
    static var yearSelector: String {
        switch lang {
        case .korean: return "연도 선택"
        case .english: return "Year Selection"
        case .japanese: return "年選択"
        case .chinese: return "年份选择"
        }
    }
    
    static var currentYearOnly: String {
        switch lang {
        case .korean: return "올해만"
        case .english: return "Current year only"
        case .japanese: return "今年のみ"
        case .chinese: return "仅当前年"
        }
    }
    
    static var allYears: String {
        switch lang {
        case .korean: return "모든 년도"
        case .english: return "All years"
        case .japanese: return "すべての年"
        case .chinese: return "所有年份"
        }
    }
    
    static var systemCalendarSync: String {
        switch lang {
        case .korean: return "시스템 캘린더 연동"
        case .english: return "System Calendar Sync"
        case .japanese: return "システムカレンダー連携"
        case .chinese: return "系统日历同步"
        }
    }
    
    static var notAvailable: String {
        switch lang {
        case .korean: return "사용 불가"
        case .english: return "Not available"
        case .japanese: return "利用不可"
        case .chinese: return "不可用"
        }
    }
    
    static var bonusLeaveManagement: String {
        switch lang {
        case .korean: return "보너스 연차 관리"
        case .english: return "Bonus Leave Management"
        case .japanese: return "ボーナス休暇管理"
        case .chinese: return "奖励年假管理"
        }
    }
    
    static var iCloudBackup: String {
        switch lang {
        case .korean: return "iCloud 백업"
        case .english: return "iCloud Backup"
        case .japanese: return "iCloudバックアップ"
        case .chinese: return "iCloud备份"
        }
    }
    
    static var oneTimePurchase: String {
        switch lang {
        case .korean: return "1회 구매, 평생 사용"
        case .english: return "One-time purchase, lifetime access"
        case .japanese: return "一度の購入で永続利用"
        case .chinese: return "一次购买，终身使用"
        }
    }
    
    static var noSubscription: String {
        switch lang {
        case .korean: return "구독 없음"
        case .english: return "No subscription"
        case .japanese: return "サブスクなし"
        case .chinese: return "无订阅"
        }
    }
    
    static var purchasing: String {
        switch lang {
        case .korean: return "구매 중..."
        case .english: return "Purchasing..."
        case .japanese: return "購入中..."
        case .chinese: return "购买中..."
        }
    }
    
    static var purchaseSuccess: String {
        switch lang {
        case .korean: return "구매 완료!"
        case .english: return "Purchase successful!"
        case .japanese: return "購入完了！"
        case .chinese: return "购买成功！"
        }
    }
    
    static var purchaseError: String {
        switch lang {
        case .korean: return "구매 실패"
        case .english: return "Purchase failed"
        case .japanese: return "購入失敗"
        case .chinese: return "购买失败"
        }
    }
    
    static var restoreSuccess: String {
        switch lang {
        case .korean: return "복원 완료!"
        case .english: return "Restore successful!"
        case .japanese: return "復元完了！"
        case .chinese: return "恢复成功！"
        }
    }
    
    static var youArePro: String {
        switch lang {
        case .korean: return "Pro 사용자입니다!"
        case .english: return "You are a Pro user!"
        case .japanese: return "Pro ユーザーです！"
        case .chinese: return "您是Pro用户！"
        }
    }
    
    static var proFeaturesBanner: String {
        switch lang {
        case .korean: return "더 많은 기능을 원하시나요? Pro로 업그레이드하세요"
        case .english: return "Want more features? Upgrade to Pro"
        case .japanese: return "もっと機能が欲しい？Proにアップグレード"
        case .chinese: return "想要更多功能？升级到Pro版"
        }
    }
    
    // MARK: - 앱 공유
    static var shareApp: String {
        switch lang {
        case .korean: return "앱 공유하기"
        case .english: return "Share App"
        case .japanese: return "アプリを共有"
        case .chinese: return "分享应用"
        }
    }
    
    static var shareMessage: String {
        switch lang {
        case .korean: return "연차 관리가 편해지는 앱! 공휴일을 활용한 최적의 휴가 추천까지 받아보세요 🏖️"
        case .english: return "The easiest way to manage your annual leave! Get AI-powered vacation recommendations 🏖️"
        case .japanese: return "有給管理が楽になるアプリ！祝日を活用した最適な休暇をおすすめ 🏖️"
        case .chinese: return "轻松管理年假！获取利用节假日的最佳休假推荐 🏖️"
        }
    }
}
