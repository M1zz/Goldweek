//
//  Strings.swift
//  Goldweek
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
            if let raw = UserDefaults.standard.string(forKey: "appLanguage"),
               let lang = AppLanguage(rawValue: raw) {
                return lang
            }
            return AppLanguage.fromDeviceLocale()
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "appLanguage")
            LanguageManager.shared.currentLanguage = newValue
        }
    }

    /// 디바이스 선호 언어 → 지원 언어. 미지원이면 영어.
    /// `Locale.preferredLanguages`는 사용자 우선순위 순서로 정렬되어 있어
    /// 첫 번째 일치 항목을 사용한다.
    static func fromDeviceLocale() -> AppLanguage {
        for code in Locale.preferredLanguages {
            let prefix = code.split(separator: "-").first.map(String.init) ?? code
            switch prefix {
            case "ko": return .korean
            case "ja": return .japanese
            case "zh": return .chinese
            case "en": return .english
            default: continue
            }
        }
        return .english
    }
}

// MARK: - 언어 변경 감지용 Observable
@Observable
class LanguageManager {
    static let shared = LanguageManager()
    var currentLanguage: AppLanguage

    private init() {
        if let raw = UserDefaults.standard.string(forKey: "appLanguage"),
           let lang = AppLanguage(rawValue: raw) {
            self.currentLanguage = lang
        } else {
            self.currentLanguage = AppLanguage.fromDeviceLocale()
        }
    }
}

// MARK: - 다국어 문자열
enum Strings {
    private static var lang: AppLanguage { LanguageManager.shared.currentLanguage }

    // MARK: - 탭 / 네비게이션
    static var tabHome: String {
        switch lang {
        case .korean: return "현황"
        case .english: return "Status"
        case .japanese: return "状況"
        case .chinese: return "概览"
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

    /// 연도 없는 연차 현황 제목
    static var annualLeaveStatusTitle: String {
        switch lang {
        case .korean: return "연차 현황"
        case .english: return "Annual Leave"
        case .japanese: return "有給休暇"
        case .chinese: return "年假概况"
        }
    }

    /// 연도 없는 자유 계획 제목
    static var leisureVacationPlanTitle: String {
        switch lang {
        case .korean: return "휴가 계획"
        case .english: return "Vacation Plan"
        case .japanese: return "休暇計画"
        case .chinese: return "休假计划"
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

    static var previousMonth: String {
        switch lang {
        case .korean: return "이전 달"
        case .english: return "Previous month"
        case .japanese: return "前の月"
        case .chinese: return "上个月"
        }
    }

    // MARK: - 휴가별 액티비티 추천 (EditLeaveSheet)
    static var leaveActivityTitle: String {
        switch lang {
        case .korean: return "이 휴가에 어울리는 여행 추천"
        case .english: return "Trips that match this leave"
        case .japanese: return "この休暇に合う旅行のおすすめ"
        case .chinese: return "适合此假期的旅行推荐"
        }
    }

    static var leaveActivitySubtitle: String {
        switch lang {
        case .korean: return "기간·계절·출발 국가 기반 큐레이션"
        case .english: return "Curated by duration, season, and origin"
        case .japanese: return "期間・季節・出発国に基づく厳選"
        case .chinese: return "根据时长、季节和出发国精选"
        }
    }

    static var leaveActivityLiveTitle: String {
        switch lang {
        case .korean: return "이 날짜로 검색한 실시간 항공·숙박"
        case .english: return "Live flights & stays for these dates"
        case .japanese: return "この日付のリアルタイム航空券・宿泊"
        case .chinese: return "针对这些日期的实时机票和住宿"
        }
    }

    static var leaveActivityLoading: String {
        switch lang {
        case .korean: return "추천 불러오는 중…"
        case .english: return "Loading recommendations…"
        case .japanese: return "おすすめを読み込み中…"
        case .chinese: return "正在加载推荐…"
        }
    }

    // MARK: - Pro 가치 제안 (Paywall 비교표)
    static var proFeatureAIAnnualPlanner: String {
        switch lang {
        case .korean: return "최적 연간 휴가 플래너"
        case .english: return "Optimal annual planner"
        case .japanese: return "最適な年間プランナー"
        case .chinese: return "最佳年度规划"
        }
    }

    // MARK: - 최적 연간 휴가 플래너
    static var optimalPlannerTitle: String {
        switch lang {
        case .korean: return "한 해 최적 휴가 플랜"
        case .english: return "Optimal year plan"
        case .japanese: return "年間最適プラン"
        case .chinese: return "全年最佳计划"
        }
    }

    static var optimalPlannerSubtitle: String {
        switch lang {
        case .korean: return "공휴일·주말을 분석해 가장 긴 연휴 조합을 자동으로 계산"
        case .english: return "Computes the longest break combinations from holidays & weekends"
        case .japanese: return "祝日・週末を分析して最長の連休組み合わせを自動算出"
        case .chinese: return "分析公共假日和周末，自动计算最长假期组合"
        }
    }

    static func optimalPlannerSummary(totalDays: Int, breaks: Int, leaveUsed: Int) -> String {
        switch lang {
        case .korean: return "연차 \(leaveUsed)일로 총 \(totalDays)일 휴식 (\(breaks)개의 연휴)"
        case .english: return "\(totalDays) days off with \(leaveUsed) PTO (\(breaks) breaks)"
        case .japanese: return "有給\(leaveUsed)日で計\(totalDays)日休み（\(breaks)回の連休）"
        case .chinese: return "用\(leaveUsed)天年假休息\(totalDays)天（\(breaks)次假期）"
        }
    }

    /// 접힘 상태에서 큰 숫자 옆 단위
    static var optimalPlannerSummaryUnit: String {
        switch lang {
        case .korean: return "일 휴식"
        case .english: return "days off"
        case .japanese: return "日休み"
        case .chinese: return "天假期"
        }
    }

    /// 접힘 상태에서 옆에 붙는 보조 정보: "연차 4일 · 5회 연휴"
    static func optimalPlannerSummaryAside(leaveUsed: Int, breaks: Int) -> String {
        switch lang {
        case .korean: return "연차 \(leaveUsed)일 · 연휴 \(breaks)회"
        case .english: return "\(leaveUsed) PTO · \(breaks) breaks"
        case .japanese: return "有給\(leaveUsed)日・\(breaks)回"
        case .chinese: return "年假\(leaveUsed)天·\(breaks)次"
        }
    }

    static var optimalPlannerExpandHint: String {
        switch lang {
        case .korean: return "이중 탭하여 펼치기"
        case .english: return "Double-tap to expand"
        case .japanese: return "ダブルタップで展開"
        case .chinese: return "双击展开"
        }
    }

    static var optimalPlannerCollapseHint: String {
        switch lang {
        case .korean: return "이중 탭하여 접기"
        case .english: return "Double-tap to collapse"
        case .japanese: return "ダブルタップで折りたたむ"
        case .chinese: return "双击折叠"
        }
    }

    static var optimalPlannerEmpty: String {
        switch lang {
        case .korean: return "추가 연차를 등록하면 더 긴 연휴를 만들 수 있어요"
        case .english: return "Register more PTO to unlock longer breaks"
        case .japanese: return "有給を追加すると、より長い連休が作れます"
        case .chinese: return "添加更多年假可获得更长假期"
        }
    }

    static var optimalPlannerProLockedTitle: String {
        switch lang {
        case .korean: return "한 해 휴가를 한 번에 최적 배치"
        case .english: return "Plan your year in one tap"
        case .japanese: return "1年の休暇を一度に最適配置"
        case .chinese: return "一键规划全年假期"
        }
    }

    static var optimalPlannerProLockedDesc: String {
        switch lang {
        case .korean: return "남은 연차를 모든 공휴일에 최적 배치해 최장 연휴 조합을 찾아드려요"
        case .english: return "Optimally place your remaining PTO around all public holidays for the longest possible breaks"
        case .japanese: return "残りの有給を公休に最適配置し、最長の連休を計算"
        case .chinese: return "将剩余年假最佳分配在所有公假周围,获取最长假期"
        }
    }

    static var optimalPlannerCTA: String {
        switch lang {
        case .korean: return "Pro로 최적 플랜 보기"
        case .english: return "Unlock optimal plan with Pro"
        case .japanese: return "Proで最適プランを見る"
        case .chinese: return "升级 Pro 查看最佳计划"
        }
    }

    static var optimalPlannerApplyAll: String {
        switch lang {
        case .korean: return "전부 캘린더에 추가"
        case .english: return "Add all to calendar"
        case .japanese: return "すべてカレンダーに追加"
        case .chinese: return "全部添加到日历"
        }
    }

    static func breakLabel(_ totalDays: Int, leaveUsed: Int) -> String {
        switch lang {
        case .korean: return "연차 \(leaveUsed)일 · \(totalDays)일 연휴"
        case .english: return "\(leaveUsed) PTO · \(totalDays)-day break"
        case .japanese: return "有給\(leaveUsed)日・\(totalDays)日連休"
        case .chinese: return "\(leaveUsed)天年假·\(totalDays)天假期"
        }
    }

    static var nextMonth: String {
        switch lang {
        case .korean: return "다음 달"
        case .english: return "Next month"
        case .japanese: return "次の月"
        case .chinese: return "下个月"
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

    /// 이름 수정 버튼 VoiceOver 라벨
    static var editName: String {
        switch lang {
        case .korean: return "이름 수정"
        case .english: return "Edit name"
        case .japanese: return "名前を編集"
        case .chinese: return "编辑姓名"
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
        case .korean: return "골드위크"
        case .english: return "Goldweek"
        case .japanese: return "ゴールドウィーク"
        case .chinese: return "Goldweek"
        }
    }

    static var onboardingSubtitle: String {
        switch lang {
        case .korean: return "최소 연차로 최대 연휴를\n공휴일을 활용한 황금연휴 플랜"
        case .english: return "Maximum days off with minimum PTO\nAI plans your perfect long weekend"
        case .japanese: return "最少の有給で最大の連休を\n祝日を活かしたゴールデンプラン"
        case .chinese: return "最少年假，最长假期\n善用节假日的黄金组合"
        }
    }

    static var onboardingValueTitle: String {
        switch lang {
        case .korean: return "3일 연차로\n9일 연휴"
        case .english: return "3 PTO days\n9 days off"
        case .japanese: return "3日の有給で\n9日の連休"
        case .chinese: return "3天年假\n9天假期"
        }
    }

    static var onboardingValueDesc: String {
        switch lang {
        case .korean: return "공휴일과 주말 사이 징검다리를 자동으로 찾아드려요"
        case .english: return "We automatically find the bridge days between holidays and weekends"
        case .japanese: return "祝日と週末の間にある飛び石を自動で見つけます"
        case .chinese: return "自动找出节假日与周末之间的搭桥日"
        }
    }

    static var onboardingValueLegendLeave: String {
        switch lang {
        case .korean: return "연차"
        case .english: return "PTO"
        case .japanese: return "有給"
        case .chinese: return "年假"
        }
    }

    static var onboardingValueLegendHoliday: String {
        switch lang {
        case .korean: return "공휴일"
        case .english: return "Holiday"
        case .japanese: return "祝日"
        case .chinese: return "假日"
        }
    }

    static var onboardingValueLegendWeekend: String {
        switch lang {
        case .korean: return "주말"
        case .english: return "Weekend"
        case .japanese: return "週末"
        case .chinese: return "周末"
        }
    }

    static var onboardingNameOptional: String {
        switch lang {
        case .korean: return "선택"
        case .english: return "Optional"
        case .japanese: return "任意"
        case .chinese: return "选填"
        }
    }

    static var onboardingHeroBadge: String {
        switch lang {
        case .korean: return "황금연휴 플래너"
        case .english: return "Long weekend planner"
        case .japanese: return "黄金連休プランナー"
        case .chinese: return "黄金假期规划"
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
            case .businessTrip: return "출장"
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
            case .businessTrip: return "Trip"
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
            case .businessTrip: return "出張"
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
            case .businessTrip: return "出差"
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

    /// 선택한 휴가 유형을 포함한 동적 등록 버튼 라벨
    /// 예) leaveType=출장 → "출장 등록하기"
    static func registerLeaveButtonWith(typeName: String) -> String {
        switch lang {
        case .korean: return "\(typeName) 등록하기"
        case .english: return "Register \(typeName)"
        case .japanese: return "\(typeName)を登録"
        case .chinese: return "登记\(typeName)"
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
        case .chinese: return "保存失败,请重试。"
        }
    }

    // MARK: - 백업 / 복원 / 데이터 알림
    static var backupSuccessMessage: String {
        switch lang {
        case .korean: return "iCloud에 백업되었습니다."
        case .english: return "Backed up to iCloud."
        case .japanese: return "iCloudにバックアップしました。"
        case .chinese: return "已备份到iCloud。"
        }
    }

    static var restoreSuccessMessage: String {
        switch lang {
        case .korean: return "복원이 완료되었습니다."
        case .english: return "Restore completed."
        case .japanese: return "復元が完了しました。"
        case .chinese: return "恢复已完成。"
        }
    }

    static func saveFailedWithReason(_ reason: String) -> String {
        switch lang {
        case .korean: return "저장에 실패했습니다: \(reason)"
        case .english: return "Save failed: \(reason)"
        case .japanese: return "保存に失敗しました: \(reason)"
        case .chinese: return "保存失败: \(reason)"
        }
    }

    static func resetFailedWithReason(_ reason: String) -> String {
        switch lang {
        case .korean: return "초기화에 실패했습니다: \(reason)"
        case .english: return "Reset failed: \(reason)"
        case .japanese: return "リセットに失敗しました: \(reason)"
        case .chinese: return "重置失败: \(reason)"
        }
    }

    static var shareSubject: String {
        switch lang {
        case .korean: return "Goldweek - 연차 관리 앱"
        case .english: return "Goldweek - Annual Leave Management"
        case .japanese: return "Goldweek - 有給管理アプリ"
        case .chinese: return "Goldweek - 年假管理应用"
        }
    }

    // MARK: - 통화 / 가격 표기
    /// 정수 금액을 현재 언어 로케일에 맞게 통화 표기로 변환.
    /// 마이리얼트립 API가 KRW를 반환하므로, 한국어가 아닌 경우에도 KRW로 표기.
    static func currency(_ amount: Int64) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.locale = Locale(identifier: localeIdentifier)
        let n = nf.string(from: NSNumber(value: amount)) ?? "\(amount)"
        switch lang {
        case .korean: return "\(n)원"
        case .english: return "₩\(n)"
        case .japanese: return "₩\(n)"
        case .chinese: return "₩\(n)"
        }
    }

    // MARK: - MRT API 에러
    static var mrtErrorNotConfigured: String {
        switch lang {
        case .korean: return "마이리얼트립 API가 설정되지 않았습니다."
        case .english: return "MyRealTrip API is not configured."
        case .japanese: return "MyRealTrip APIが設定されていません。"
        case .chinese: return "MyRealTrip API未配置。"
        }
    }

    static var mrtErrorInvalidURL: String {
        switch lang {
        case .korean: return "잘못된 URL입니다."
        case .english: return "Invalid URL."
        case .japanese: return "無効なURLです。"
        case .chinese: return "无效的URL。"
        }
    }

    static var mrtErrorBadRequest: String {
        switch lang {
        case .korean: return "잘못된 요청입니다."
        case .english: return "Bad request."
        case .japanese: return "不正なリクエストです。"
        case .chinese: return "请求无效。"
        }
    }

    static var mrtErrorUnauthorized: String {
        switch lang {
        case .korean: return "API 키가 유효하지 않습니다."
        case .english: return "Invalid API key."
        case .japanese: return "APIキーが無効です。"
        case .chinese: return "API密钥无效。"
        }
    }

    static var mrtErrorForbidden: String {
        switch lang {
        case .korean: return "이 API에 대한 접근 권한이 없습니다."
        case .english: return "Access denied to this API."
        case .japanese: return "このAPIへのアクセス権限がありません。"
        case .chinese: return "无权访问此API。"
        }
    }

    static var mrtErrorNotFound: String {
        switch lang {
        case .korean: return "엔드포인트를 찾을 수 없습니다."
        case .english: return "Endpoint not found."
        case .japanese: return "エンドポイントが見つかりません。"
        case .chinese: return "未找到端点。"
        }
    }

    static var mrtErrorRateLimited: String {
        switch lang {
        case .korean: return "요청 한도를 초과했습니다."
        case .english: return "Request rate limit exceeded."
        case .japanese: return "リクエスト上限を超えました。"
        case .chinese: return "请求次数超限。"
        }
    }

    static func mrtErrorServerError(_ code: Int) -> String {
        switch lang {
        case .korean: return "서버 오류 (\(code))"
        case .english: return "Server error (\(code))"
        case .japanese: return "サーバーエラー (\(code))"
        case .chinese: return "服务器错误 (\(code))"
        }
    }

    static var mrtErrorDecoding: String {
        switch lang {
        case .korean: return "응답 형식 오류"
        case .english: return "Invalid response format"
        case .japanese: return "応答形式エラー"
        case .chinese: return "响应格式错误"
        }
    }

    static var mrtErrorMaxRetries: String {
        switch lang {
        case .korean: return "재시도 한도를 초과했습니다."
        case .english: return "Max retries exceeded."
        case .japanese: return "再試行上限を超えました。"
        case .chinese: return "重试次数超限。"
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
    
    static var goldweekPro: String {
        switch lang {
        case .korean: return "골드위크 Pro"
        case .english: return "Goldweek Pro"
        case .japanese: return "ゴールドウィーク Pro"
        case .chinese: return "Goldweek Pro"
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
        case .korean: return "연차 수당 받지 말고 진짜로 쉬세요. 알고리즘이 최장 연휴 조합 자동 계산 🏖️"
        case .english: return "Don't take the cash — take the days. Algorithm finds your longest possible breaks 🏖️"
        case .japanese: return "有給を現金じゃなく、実際の休みに。アルゴリズムが最長の連休を自動算出 🏖️"
        case .chinese: return "别拿年假补偿，真正去休假吧。算法自动计算最长假期组合 🏖️"
        }
    }

    // MARK: - Pro 온보딩 페이지
    static var proOnboardingSubtitle: String {
        switch lang {
        case .korean: return "한 번 결제로 모든 기능을 영구적으로 사용하세요"
        case .english: return "One purchase. All features. Forever."
        case .japanese: return "一度の購入ですべての機能を永続利用"
        case .chinese: return "一次购买，永久使用全部功能"
        }
    }

    static var proOnboardingSkip: String {
        switch lang {
        case .korean: return "나중에 알아볼게요"
        case .english: return "Maybe later"
        case .japanese: return "あとで確認する"
        case .chinese: return "稍后了解"
        }
    }

    static var proFeatureRecommendTitle: String {
        switch lang {
        case .korean: return "무제한 AI 추천"
        case .english: return "Unlimited AI plans"
        case .japanese: return "無制限のAI推薦"
        case .chinese: return "无限AI推荐"
        }
    }

    static var proFeatureRecommendDesc: String {
        switch lang {
        case .korean: return "무료는 3개까지"
        case .english: return "Free is limited to 3"
        case .japanese: return "無料は3件まで"
        case .chinese: return "免费版最多3个"
        }
    }

    static var proFeatureBonusTitle: String {
        switch lang {
        case .korean: return "보너스 연차 관리"
        case .english: return "Bonus leave tracking"
        case .japanese: return "ボーナス休暇管理"
        case .chinese: return "奖励年假管理"
        }
    }

    static var proFeatureBonusDesc: String {
        switch lang {
        case .korean: return "보상 휴가, 특별 휴가, 병가"
        case .english: return "Comp days, special leave, sick"
        case .japanese: return "代休、特別休暇、病気休暇"
        case .chinese: return "补休、特别假、病假"
        }
    }

    static var proFeatureMultiYearTitle: String {
        switch lang {
        case .korean: return "멀티 연도 플래닝"
        case .english: return "Multi-year planning"
        case .japanese: return "複数年プランニング"
        case .chinese: return "跨年度规划"
        }
    }

    static var proFeatureMultiYearDesc: String {
        switch lang {
        case .korean: return "지난해와 내년까지 한눈에"
        case .english: return "Last year and next year at a glance"
        case .japanese: return "昨年と来年まで一目で"
        case .chinese: return "去年和明年一览"
        }
    }

    static var proFeatureCalendarTitle: String {
        switch lang {
        case .korean: return "캘린더 연동"
        case .english: return "Calendar sync"
        case .japanese: return "カレンダー連携"
        case .chinese: return "日历同步"
        }
    }

    static var proFeatureCalendarDesc: String {
        switch lang {
        case .korean: return "iOS 캘린더에 자동 동기화"
        case .english: return "Auto-sync with iOS Calendar"
        case .japanese: return "iOSカレンダーに自動同期"
        case .chinese: return "自动同步到iOS日历"
        }
    }

    // MARK: - 휴가 페이스 (번아웃 & 소진 속도)
    static var paceCardTitle: String {
        switch lang {
        case .korean: return "휴가 페이스"
        case .english: return "Vacation Pace"
        case .japanese: return "休暇ペース"
        case .chinese: return "休假节奏"
        }
    }

    static var paceYearProgressLabel: String {
        switch lang {
        case .korean: return "올해 진행"
        case .english: return "Year progress"
        case .japanese: return "今年の進捗"
        case .chinese: return "年度进度"
        }
    }

    static var paceUsageLabel: String {
        switch lang {
        case .korean: return "연차 사용"
        case .english: return "Leave used"
        case .japanese: return "有給使用"
        case .chinese: return "年假使用"
        }
    }

    static var paceLabelSlow: String {
        switch lang {
        case .korean: return "여유"
        case .english: return "Relaxed"
        case .japanese: return "ゆとり"
        case .chinese: return "宽松"
        }
    }

    static var paceLabelHealthy: String {
        switch lang {
        case .korean: return "적정"
        case .english: return "Balanced"
        case .japanese: return "適正"
        case .chinese: return "均衡"
        }
    }

    static var paceLabelFast: String {
        switch lang {
        case .korean: return "빠름"
        case .english: return "Fast"
        case .japanese: return "速い"
        case .chinese: return "偏快"
        }
    }

    static var paceLabelVeryFast: String {
        switch lang {
        case .korean: return "매우 빠름"
        case .english: return "Very fast"
        case .japanese: return "非常に速い"
        case .chinese: return "很快"
        }
    }

    static var paceMessageSlow: String {
        switch lang {
        case .korean: return "여유롭게 사용 중이에요. 다음 휴가를 미리 계획해 보세요."
        case .english: return "You're pacing slowly. Try planning ahead so days don't pile up."
        case .japanese: return "ゆったり使っています。次の休暇を計画してみましょう。"
        case .chinese: return "使用节奏宽松。可以提前规划下一次休假。"
        }
    }

    static var paceMessageHealthy: String {
        switch lang {
        case .korean: return "건강한 페이스로 휴가를 사용하고 있어요."
        case .english: return "Healthy pace. You're using leave at the right rate."
        case .japanese: return "健康的なペースで休暇を取れています。"
        case .chinese: return "节奏健康,休假分配合理。"
        }
    }

    static var paceMessageFast: String {
        switch lang {
        case .korean: return "최근 사용이 많네요. 남은 기간을 잘 안배해 보세요."
        case .english: return "You're using leave faster than average. Pace yourself for the rest of the year."
        case .japanese: return "やや早めの消化です。残りの期間を見ながら配分しましょう。"
        case .chinese: return "使用较快。请合理分配剩余时间。"
        }
    }

    static var paceMessageVeryFast: String {
        switch lang {
        case .korean: return "연차 소진이 매우 빨라요. 남은 일수가 부족할 수 있어요."
        case .english: return "Your leave is depleting very quickly. You might run short."
        case .japanese: return "有給の消化が非常に速いです。残日数が不足するかもしれません。"
        case .chinese: return "年假消耗非常快,剩余天数可能不足。"
        }
    }

    // 번아웃 신호 섹션
    static var burnoutSectionTitle: String {
        switch lang {
        case .korean: return "쉬어가는 흐름"
        case .english: return "Rest rhythm"
        case .japanese: return "休息のリズム"
        case .chinese: return "休息节奏"
        }
    }

    static var burnoutLast: String {
        switch lang {
        case .korean: return "지난 휴가"
        case .english: return "Last break"
        case .japanese: return "前回の休暇"
        case .chinese: return "上次休假"
        }
    }

    static var burnoutToday: String {
        switch lang {
        case .korean: return "오늘"
        case .english: return "Today"
        case .japanese: return "今日"
        case .chinese: return "今天"
        }
    }

    static var burnoutNext: String {
        switch lang {
        case .korean: return "다음 휴가"
        case .english: return "Next break"
        case .japanese: return "次の休暇"
        case .chinese: return "下次休假"
        }
    }

    static func burnoutDaysAgo(_ days: Int) -> String {
        switch lang {
        case .korean: return "\(days)일 전"
        case .english: return days == 1 ? "1 day ago" : "\(days) days ago"
        case .japanese: return "\(days)日前"
        case .chinese: return "\(days)天前"
        }
    }

    static func burnoutDaysAhead(_ days: Int) -> String {
        switch lang {
        case .korean: return "\(days)일 후"
        case .english: return days == 1 ? "in 1 day" : "in \(days) days"
        case .japanese: return "\(days)日後"
        case .chinese: return "\(days)天后"
        }
    }

    static var burnoutNoLast: String {
        switch lang {
        case .korean: return "기록 없음"
        case .english: return "No record"
        case .japanese: return "記録なし"
        case .chinese: return "无记录"
        }
    }

    static var burnoutNoNext: String {
        switch lang {
        case .korean: return "계획 없음"
        case .english: return "Not planned"
        case .japanese: return "未計画"
        case .chinese: return "未计划"
        }
    }

    static var burnoutMsgHealthy: String {
        switch lang {
        case .korean: return "휴가 간격이 건강해요. 지금 흐름을 유지하세요."
        case .english: return "Healthy gap between breaks. Keep this rhythm."
        case .japanese: return "休暇の間隔が健康的です。今のリズムを維持しましょう。"
        case .chinese: return "休假间隔健康,继续保持这个节奏。"
        }
    }

    static var burnoutMsgWarning: String {
        switch lang {
        case .korean: return "쉬어간 지 좀 됐어요. 짧게라도 휴식을 계획해 보세요."
        case .english: return "It's been a while. Consider planning even a short break."
        case .japanese: return "少し休んでいません。短い休みでも計画してみましょう。"
        case .chinese: return "已经有段时间没休息了,哪怕短假也好,试着安排一下吧。"
        }
    }

    static var burnoutMsgRisky: String {
        switch lang {
        case .korean: return "오랫동안 쉬지 못했어요. 번아웃 전에 휴가를 잡으세요."
        case .english: return "You haven't rested in a long time. Schedule a break before burnout sets in."
        case .japanese: return "長い間休めていません。バーンアウト前に休暇を入れましょう。"
        case .chinese: return "好久没休息了,在倦怠之前安排一次休假吧。"
        }
    }

    static var burnoutMsgPlannedAhead: String {
        switch lang {
        case .korean: return "다음 휴가가 곧이에요. 조금만 더 힘내세요."
        case .english: return "Your next break is coming up soon. Hang in there."
        case .japanese: return "次の休暇はすぐです。もう少しがんばりましょう。"
        case .chinese: return "下次休假就快到了,再坚持一下。"
        }
    }

    // MARK: - 회복 잔량 / 번아웃 예측 (Rest Radar)

    /// 회복 잔량 게이지 라벨
    static var recoveryReserveLabel: String {
        switch lang {
        case .korean: return "회복 잔량"
        case .english: return "Recovery reserve"
        case .japanese: return "回復残量"
        case .chinese: return "恢复余量"
        }
    }

    /// 내 평소 휴식 주기 — 개인화됐을 때
    static func personalCycleLabel(_ days: Int) -> String {
        switch lang {
        case .korean: return "평소 주기 \(days)일"
        case .english: return "Your usual cycle: \(days) days"
        case .japanese: return "いつもの周期\(days)日"
        case .chinese: return "你通常的周期为\(days)天"
        }
    }

    /// 번아웃 예측 — 위험 진입 예상 (월 단위 근사 표기)
    static func burnoutForecast(_ dateText: String) -> String {
        switch lang {
        case .korean: return "이대로면 \(dateText)쯤 번아웃 주의 구간"
        case .english: return "At this pace, burnout risk around \(dateText)"
        case .japanese: return "このままだと\(dateText)頃に注意ゾーン"
        case .chinese: return "照此节奏,\(dateText)前后进入倦怠风险区"
        }
    }

    /// 번아웃 예측 — 당분간 안전
    static var burnoutForecastClear: String {
        switch lang {
        case .korean: return "당분간 회복 흐름이 안정적이에요"
        case .english: return "Your recovery looks stable for now"
        case .japanese: return "当面は回復が安定しています"
        case .chinese: return "近期恢复状态稳定"
        }
    }

    /// 번아웃 예측 — 이미 위험 (지금 쉬어야)
    static var burnoutForecastNow: String {
        switch lang {
        case .korean: return "지금이 쉬어갈 때예요"
        case .english: return "Now is the time to rest"
        case .japanese: return "今が休む時です"
        case .chinese: return "现在该休息了"
        }
    }

    // MARK: - 피로 체크인 (단일문항 SIB)

    static var fatigueCheckInTitle: String {
        switch lang {
        case .korean: return "요즘 얼마나 지치셨나요?"
        case .english: return "How drained do you feel lately?"
        case .japanese: return "最近どれくらい疲れていますか?"
        case .chinese: return "最近你有多疲惫?"
        }
    }

    static var fatigueCheckInSubtitle: String {
        switch lang {
        case .korean: return "한 번의 답이 휴식 추천을 더 정확하게 만들어요."
        case .english: return "One quick answer sharpens your rest suggestions."
        case .japanese: return "ひとつの回答で休息提案がより正確になります。"
        case .chinese: return "一个简单的回答能让休息建议更准确。"
        }
    }

    static var fatigueLow: String {
        switch lang {
        case .korean: return "괜찮아요"
        case .english: return "Fine"
        case .japanese: return "元気"
        case .chinese: return "还好"
        }
    }

    static var fatigueHigh: String {
        switch lang {
        case .korean: return "완전 지침"
        case .english: return "Exhausted"
        case .japanese: return "限界"
        case .chinese: return "精疲力竭"
        }
    }

    static var fatigueSubmit: String {
        switch lang {
        case .korean: return "기록하기"
        case .english: return "Submit"
        case .japanese: return "記録する"
        case .chinese: return "提交"
        }
    }

    static var fatigueSkip: String {
        switch lang {
        case .korean: return "나중에"
        case .english: return "Later"
        case .japanese: return "あとで"
        case .chinese: return "稍后"
        }
    }

    // MARK: - 휴식 알림 설정 (Rest Radar)

    static var restRadarSection: String {
        switch lang {
        case .korean: return "휴식 알림"
        case .english: return "Rest reminders"
        case .japanese: return "休息リマインダー"
        case .chinese: return "休息提醒"
        }
    }

    static var restRadarToggle: String {
        switch lang {
        case .korean: return "휴식 레이더"
        case .english: return "Rest Radar"
        case .japanese: return "レストレーダー"
        case .chinese: return "休息雷达"
        }
    }

    static var restRadarFooter: String {
        switch lang {
        case .korean: return "오래 쉬지 못했을 때, 가까운 저비용 연휴와 함께 쉬어갈 때를 알려드려요."
        case .english: return "When you've gone too long without a break, we'll nudge you with a nearby low-cost getaway."
        case .japanese: return "長く休めていないとき、近くの低コストな連休とともにお知らせします。"
        case .chinese: return "当你太久没休息时,会结合就近的低成本假期提醒你。"
        }
    }

    // MARK: - 홈 카드 라벨 (LeaveStatusCard)
    static var includeBonus: String {
        switch lang {
        case .korean: return "보너스 포함"
        case .english: return "Include bonus"
        case .japanese: return "ボーナス含む"
        case .chinese: return "包含奖励"
        }
    }

    /// 보너스 포함 토글 VoiceOver 힌트
    static var includeBonusHint: String {
        switch lang {
        case .korean: return "켜면 보너스 연차가 잔여 일수에 합산됩니다"
        case .english: return "When on, bonus leave is added to your remaining days"
        case .japanese: return "オンにするとボーナス休暇が残日数に合算されます"
        case .chinese: return "开启后奖励假期将计入剩余天数"
        }
    }

    static var statRemainingGoal: String {
        switch lang {
        case .korean: return "남은 목표"
        case .english: return "Goal left"
        case .japanese: return "残り目標"
        case .chinese: return "目标剩余"
        }
    }

    static var usable: String {
        switch lang {
        case .korean: return "사용 가능"
        case .english: return "Available"
        case .japanese: return "利用可能"
        case .chinese: return "可用"
        }
    }

    static var goalNotSetDesc: String {
        switch lang {
        case .korean: return "목표 일수 없음 · 설정에서 연간 목표를 설정할 수 있어요"
        case .english: return "No goal set · You can set a yearly goal in Settings"
        case .japanese: return "目標日数なし · 設定で年間目標を設定できます"
        case .chinese: return "未设目标 · 可在设置中设定年度目标"
        }
    }

    static var pastLeaveSheetFooter: String {
        switch lang {
        case .korean: return "날짜별로 개별 입력하려면 + 탭을 이용하세요"
        case .english: return "Use the + tab to add leave by date"
        case .japanese: return "日付別に個別入力するには + タブを使ってください"
        case .chinese: return "如需按日期单独输入,请使用 + 标签"
        }
    }

    // MARK: - Pro 배너 메시지
    static func proBannerHolidayUpcoming(_ holidayName: String, days: Int) -> String {
        switch lang {
        case .korean: return "\(holidayName) D-\(days) · 연차 붙여 긴 휴가 만들어 보세요"
        case .english: return "\(holidayName) in \(days)d · Add PTO for a longer break"
        case .japanese: return "\(holidayName) あと\(days)日 · 有給を足して長い連休に"
        case .chinese: return "\(holidayName) 还有\(days)天 · 拼上年假打造长假"
        }
    }

    static func proBannerYearEndExpiry(_ daysText: String) -> String {
        switch lang {
        case .korean: return "연말까지 \(daysText)일 남았어요 · 소멸 전에 계획하세요"
        case .english: return "\(daysText) days left this year · Plan before they expire"
        case .japanese: return "年末まで\(daysText)日 · 消滅前に計画しましょう"
        case .chinese: return "今年还剩\(daysText)天 · 在到期前安排好"
        }
    }

    static var goldenSeasonName: String {
        switch lang {
        case .korean: return "황금연휴"
        case .english: return "Golden Week"
        case .japanese: return "ゴールデンウィーク"
        case .chinese: return "黄金周"
        }
    }

    static var chuseokSeasonName: String {
        switch lang {
        case .korean: return "추석 연휴"
        case .english: return "Autumn Holiday"
        case .japanese: return "秋の連休"
        case .chinese: return "中秋假期"
        }
    }

    static func proBannerSeasonOpportunity(_ seasonName: String) -> String {
        switch lang {
        case .korean: return "\(seasonName) 시즌 · AI 추천으로 최적의 일정 만들어 보세요"
        case .english: return "\(seasonName) season · Try AI recommendations for the best plan"
        case .japanese: return "\(seasonName)シーズン · AIおすすめで最適な日程を"
        case .chinese: return "\(seasonName)旺季 · 用AI推荐打造最佳行程"
        }
    }

    static func proBannerLowRemaining(_ daysText: String) -> String {
        switch lang {
        case .korean: return "남은 연차 \(daysText)일 · 효율적으로 배치해 보세요"
        case .english: return "\(daysText) days of leave left · Place them wisely"
        case .japanese: return "残り有給\(daysText)日 · 効率的に配置しましょう"
        case .chinese: return "剩余\(daysText)天年假 · 合理安排"
        }
    }

    static func proBannerEmptyPlan(_ daysText: String) -> String {
        switch lang {
        case .korean: return "\(daysText)일 연차가 비어 있어요 · AI 추천 받아보세요"
        case .english: return "\(daysText) days of leave unplanned · Get AI recommendations"
        case .japanese: return "\(daysText)日の有給が未計画です · AIおすすめを試してみては"
        case .chinese: return "还有\(daysText)天年假未安排 · 试试AI推荐"
        }
    }

    // MARK: - AddLeaveView 라벨
    static var leisureGoalRemaining: String {
        switch lang {
        case .korean: return "목표까지 남은 일수"
        case .english: return "Days to goal"
        case .japanese: return "目標まで残り日数"
        case .chinese: return "距目标天数"
        }
    }

    static var leisureTotalPlan: String {
        switch lang {
        case .korean: return "총 계획"
        case .english: return "Total planned"
        case .japanese: return "計画合計"
        case .chinese: return "计划合计"
        }
    }

    static var bonusUseSectionHeader: String {
        switch lang {
        case .korean: return "보너스 연차 사용"
        case .english: return "Use bonus leave"
        case .japanese: return "ボーナス休暇を使う"
        case .chinese: return "使用奖励年假"
        }
    }

    static var bonusUseFooterSelected: String {
        switch lang {
        case .korean: return "보너스 연차를 사용합니다. 연차에서 차감되지 않습니다."
        case .english: return "Bonus leave will be used. It won't be deducted from your annual leave."
        case .japanese: return "ボーナス休暇を使います。年次有給からは差し引かれません。"
        case .chinese: return "将使用奖励年假,不会从年假中扣除。"
        }
    }

    static var bonusUseFooterUnselected: String {
        switch lang {
        case .korean: return "탭하여 보너스 연차를 선택하면 연차 대신 사용할 수 있습니다."
        case .english: return "Tap to select bonus leave and use it instead of annual leave."
        case .japanese: return "タップしてボーナス休暇を選ぶと、年次有給の代わりに使えます。"
        case .chinese: return "点击选择奖励年假即可代替年假使用。"
        }
    }

    static var unitSectionTitleBonus: String {
        switch lang {
        case .korean: return "보너스 연차 사용 단위"
        case .english: return "Bonus leave unit"
        case .japanese: return "ボーナス休暇の単位"
        case .chinese: return "奖励年假单位"
        }
    }

    static var unitSectionTitleLeisure: String {
        switch lang {
        case .korean: return "휴가 기간"
        case .english: return "Vacation length"
        case .japanese: return "休暇の長さ"
        case .chinese: return "休假时长"
        }
    }

    static var unitSectionTitleEmployee: String {
        switch lang {
        case .korean: return "연차 차감 단위"
        case .english: return "Deduction unit"
        case .japanese: return "有給控除の単位"
        case .chinese: return "扣除单位"
        }
    }

    static func unitLabel(_ type: LeaveType, isLeisure: Bool) -> String {
        switch lang {
        case .korean:
            if isLeisure {
                switch type {
                case .quarter, .half: return "반나절"
                case .annual: return "휴가"
                default: return "휴가"
                }
            } else {
                switch type {
                case .quarter: return "반반차"
                case .half: return "반차"
                case .annual: return "연차"
                default: return "연차"
                }
            }
        case .english:
            if isLeisure {
                switch type {
                case .quarter: return "Quarter"
                case .half: return "Half"
                case .annual: return "Day off"
                default: return "Day off"
                }
            } else {
                switch type {
                case .quarter: return "Quarter PTO"
                case .half: return "Half PTO"
                case .annual: return "PTO"
                default: return "PTO"
                }
            }
        case .japanese:
            if isLeisure {
                switch type {
                case .quarter, .half: return "半日"
                case .annual: return "休み"
                default: return "休み"
                }
            } else {
                switch type {
                case .quarter: return "四半休"
                case .half: return "半休"
                case .annual: return "有給"
                default: return "有給"
                }
            }
        case .chinese:
            if isLeisure {
                switch type {
                case .quarter, .half: return "半天"
                case .annual: return "休假"
                default: return "休假"
                }
            } else {
                switch type {
                case .quarter: return "四分一休"
                case .half: return "半休"
                case .annual: return "年假"
                default: return "年假"
                }
            }
        }
    }

    static var otherTypesSectionHeader: String {
        switch lang {
        case .korean: return "기타 (연차 미차감)"
        case .english: return "Other (no deduction)"
        case .japanese: return "その他 (有給控除なし)"
        case .chinese: return "其他 (不扣除年假)"
        }
    }

    static var bonusLeaveFooterFree: String {
        switch lang {
        case .korean: return "보너스 연차 추가는 Pro 기능입니다. 이미 추가된 항목은 수정 가능합니다."
        case .english: return "Adding bonus leave is a Pro feature. You can still edit existing items."
        case .japanese: return "ボーナス休暇の追加はPro機能です。既存項目の編集は可能です。"
        case .chinese: return "新增奖励年假为Pro功能。已添加的项目仍可编辑。"
        }
    }

    static func bonusEditUsedRemaining(used: String, remaining: String) -> String {
        switch lang {
        case .korean: return "이미 \(used)일 사용됨 · 잔여 \(remaining)일"
        case .english: return "\(used) days used · \(remaining) days remaining"
        case .japanese: return "すでに\(used)日使用 · 残り\(remaining)日"
        case .chinese: return "已使用\(used)天 · 剩余\(remaining)天"
        }
    }

    static var bonusEditTitle: String {
        switch lang {
        case .korean: return "보너스 연차 수정"
        case .english: return "Edit bonus leave"
        case .japanese: return "ボーナス休暇を編集"
        case .chinese: return "编辑奖励年假"
        }
    }

    // MARK: - 마이리얼트립 연계 프로모션
    static var mrtPromoBadge: String {
        switch lang {
        case .korean: return "여행 추천"
        case .english: return "Travel"
        case .japanese: return "旅行"
        case .chinese: return "旅行推荐"
        }
    }

    static var mrtPromoTitle: String {
        switch lang {
        case .korean: return "이 연휴, 떠나볼까요?"
        case .english: return "Make the most of this break"
        case .japanese: return "この連休、出かけませんか?"
        case .chinese: return "这个假期,出发吧?"
        }
    }

    static var mrtPromoSubtitle: String {
        switch lang {
        case .korean: return "마이리얼트립에서 항공·숙박·투어를 한 번에 확인해보세요"
        case .english: return "Check flights, hotels, and tours together on MyRealTrip"
        case .japanese: return "マイリアルトリップで航空券・ホテル・ツアーをまとめてチェック"
        case .chinese: return "在MyRealTrip上一站查看机票、酒店和旅游产品"
        }
    }

    static var mrtPromoCTA: String {
        switch lang {
        case .korean: return "마이리얼트립에서 보기"
        case .english: return "Open MyRealTrip"
        case .japanese: return "マイリアルトリップで見る"
        case .chinese: return "在MyRealTrip中查看"
        }
    }

    // MARK: - 추천 opt-in
    static var mrtOptInTitle: String {
        switch lang {
        case .korean: return "이 연휴에 해보면 좋을 액티비티들이 있는데\n추천해드릴까요?"
        case .english: return "We've found some activities for this break.\nShow recommendations?"
        case .japanese: return "この連休にぴったりのアクティビティがあります。\nおすすめを表示しますか?"
        case .chinese: return "我们为这个假期找到了一些活动。\n要查看推荐吗?"
        }
    }

    static var mrtOptInSubtitle: String {
        switch lang {
        case .korean: return "마이리얼트립에서 항공·숙박·투어를 함께 살펴봅니다"
        case .english: return "Flights, stays, and tours from MyRealTrip"
        case .japanese: return "マイリアルトリップで航空券・ホテル・ツアーをまとめて確認"
        case .chinese: return "MyRealTrip上的机票、住宿和旅游产品"
        }
    }

    static var mrtOptInShow: String {
        switch lang {
        case .korean: return "추천 받기"
        case .english: return "Show me"
        case .japanese: return "見てみる"
        case .chinese: return "查看推荐"
        }
    }

    static var mrtOptInDismiss: String {
        switch lang {
        case .korean: return "괜찮아요"
        case .english: return "No thanks"
        case .japanese: return "結構です"
        case .chinese: return "不用了"
        }
    }

    // MARK: - 추천 이유
    static func mrtCityReason(city: String, season: String, days: Int) -> String {
        switch lang {
        case .korean: return "\(days)일 연휴엔 \(city) — \(season)"
        case .english: return "\(city) for a \(days)-day break — \(season)"
        case .japanese: return "\(days)日の連休には\(city) — \(season)"
        case .chinese: return "\(days)天假期就去\(city) — \(season)"
        }
    }

    static var mrtFlightReasonCheapest: String {
        switch lang {
        case .korean: return "가장 저렴"
        case .english: return "Cheapest"
        case .japanese: return "最安値"
        case .chinese: return "最便宜"
        }
    }

    static var mrtFlightReasonDirect: String {
        switch lang {
        case .korean: return "직항"
        case .english: return "Direct"
        case .japanese: return "直行"
        case .chinese: return "直飞"
        }
    }

    static var mrtAccomReasonTopRated: String {
        switch lang {
        case .korean: return "베스트 평점"
        case .english: return "Top rated"
        case .japanese: return "高評価"
        case .chinese: return "高分推荐"
        }
    }

    static var mrtTourReasonBestseller: String {
        switch lang {
        case .korean: return "베스트셀러"
        case .english: return "Bestseller"
        case .japanese: return "ベストセラー"
        case .chinese: return "热销"
        }
    }

    static var mrtPackageHeader: String {
        switch lang {
        case .korean: return "추천 패키지"
        case .english: return "Suggested package"
        case .japanese: return "おすすめパッケージ"
        case .chinese: return "推荐套餐"
        }
    }

    static var mrtChangePreference: String {
        switch lang {
        case .korean: return "다음부터 자동으로 안 볼래요"
        case .english: return "Don't show automatically"
        case .japanese: return "次回から自動表示しない"
        case .chinese: return "不再自动显示"
        }
    }

    // MARK: - 사용자 유형
    static var userTypeEmployee: String {
        switch lang {
        case .korean: return "직장인"
        case .english: return "Employee"
        case .japanese: return "会社員"
        case .chinese: return "上班族"
        }
    }

    static var userTypeLeisure: String {
        switch lang {
        case .korean: return "자유 계획"
        case .english: return "Free Plan"
        case .japanese: return "自由計画"
        case .chinese: return "自由规划"
        }
    }

    static var userTypeSection: String {
        switch lang {
        case .korean: return "사용자 유형"
        case .english: return "User Type"
        case .japanese: return "ユーザータイプ"
        case .chinese: return "用户类型"
        }
    }

    static var userTypeMode: String {
        switch lang {
        case .korean: return "모드"
        case .english: return "Mode"
        case .japanese: return "モード"
        case .chinese: return "模式"
        }
    }

    static var userTypeLeisureDesc: String {
        switch lang {
        case .korean: return "연차 제한 없이 자유롭게 휴가를 계획하고 싶은 분을 위한 모드입니다."
        case .english: return "A mode for those who want to plan vacations freely without leave-day limits."
        case .japanese: return "有給日数の制限なく自由に休暇を計画したい方向けのモードです。"
        case .chinese: return "适合不受年假天数限制、自由规划休假的用户。"
        }
    }

    static var leisureVacationSettings: String {
        switch lang {
        case .korean: return "휴가 설정"
        case .english: return "Vacation Settings"
        case .japanese: return "休暇設定"
        case .chinese: return "休假设置"
        }
    }

    static var leisureAnnualGoal: String {
        switch lang {
        case .korean: return "연간 목표 일수"
        case .english: return "Annual Goal Days"
        case .japanese: return "年間目標日数"
        case .chinese: return "年度目标天数"
        }
    }

    static var leisureUnlimited: String {
        switch lang {
        case .korean: return "무제한"
        case .english: return "Unlimited"
        case .japanese: return "無制限"
        case .chinese: return "无限"
        }
    }

    static var leisurePlannedLeave: String {
        switch lang {
        case .korean: return "계획된 휴가"
        case .english: return "Planned Leave"
        case .japanese: return "計画した休暇"
        case .chinese: return "计划休假"
        }
    }

    static var leisureYearStartMonth: String {
        switch lang {
        case .korean: return "기준 연도 시작월"
        case .english: return "Year Start Month"
        case .japanese: return "基準年度の開始月"
        case .chinese: return "起始月份"
        }
    }

    // MARK: - 공휴일 관리
    static var holidayMgmtTitle: String {
        switch lang {
        case .korean: return "공휴일 관리"
        case .english: return "Holiday Management"
        case .japanese: return "祝日管理"
        case .chinese: return "假日管理"
        }
    }

    static var holidayMgmtSubtitle: String {
        switch lang {
        case .korean: return "공휴일 추가·숨기기"
        case .english: return "Add or hide holidays"
        case .japanese: return "祝日の追加・非表示"
        case .chinese: return "添加·隐藏假日"
        }
    }

    static var holidayMgmtRestoreAll: String {
        switch lang {
        case .korean: return "기본 공휴일 모두 복원"
        case .english: return "Restore all default holidays"
        case .japanese: return "すべてのデフォルト祝日を復元"
        case .chinese: return "恢复所有默认假日"
        }
    }

    static var holidayDeleteAlertTitle: String {
        switch lang {
        case .korean: return "공휴일 삭제"
        case .english: return "Delete Holiday"
        case .japanese: return "祝日を削除"
        case .chinese: return "删除假日"
        }
    }

    static var holidayDeleteAlertMessage: String {
        switch lang {
        case .korean: return "이 공휴일을 삭제할까요?"
        case .english: return "Delete this holiday?"
        case .japanese: return "この祝日を削除しますか?"
        case .chinese: return "要删除此假日吗?"
        }
    }

    static var commonDelete: String {
        switch lang {
        case .korean: return "삭제"
        case .english: return "Delete"
        case .japanese: return "削除"
        case .chinese: return "删除"
        }
    }

    static var commonAdd: String {
        switch lang {
        case .korean: return "추가"
        case .english: return "Add"
        case .japanese: return "追加"
        case .chinese: return "添加"
        }
    }

    static var holidayDefaultSection: String {
        switch lang {
        case .korean: return "기본 공휴일"
        case .english: return "Default Holidays"
        case .japanese: return "デフォルト祝日"
        case .chinese: return "默认假日"
        }
    }

    static var holidayDefaultFooter: String {
        switch lang {
        case .korean: return "토글을 끄면 캘린더와 추천에서 해당 공휴일이 숨겨집니다."
        case .english: return "Turn off the toggle to hide the holiday from the calendar and recommendations."
        case .japanese: return "トグルをオフにすると、カレンダーとおすすめから該当祝日が非表示になります。"
        case .chinese: return "关闭开关后,该假日将从日历和推荐中隐藏。"
        }
    }

    static var holidayCustomSection: String {
        switch lang {
        case .korean: return "내 공휴일"
        case .english: return "My Holidays"
        case .japanese: return "マイ祝日"
        case .chinese: return "我的假日"
        }
    }

    static var holidayCustomEmpty: String {
        switch lang {
        case .korean: return "직접 추가한 공휴일이 없습니다"
        case .english: return "No custom holidays added"
        case .japanese: return "追加した祝日はありません"
        case .chinese: return "未添加自定义假日"
        }
    }

    static var holidayCustomFooter: String {
        switch lang {
        case .korean: return "직접 추가한 공휴일은 캘린더와 추천에 반영됩니다."
        case .english: return "Custom holidays will appear in the calendar and recommendations."
        case .japanese: return "追加した祝日はカレンダーとおすすめに反映されます。"
        case .chinese: return "自定义假日将显示在日历和推荐中。"
        }
    }

    static var holidaySubstitute: String {
        switch lang {
        case .korean: return "대체공휴일"
        case .english: return "Substitute Holiday"
        case .japanese: return "振替休日"
        case .chinese: return "调休"
        }
    }

    static var holidayAddedByMe: String {
        switch lang {
        case .korean: return "내가 추가"
        case .english: return "Added by me"
        case .japanese: return "自分で追加"
        case .chinese: return "我添加的"
        }
    }

    /// 펼침/접힘 상태 (VoiceOver accessibilityValue)
    static var a11yExpanded: String {
        switch lang {
        case .korean: return "펼침"
        case .english: return "Expanded"
        case .japanese: return "展開"
        case .chinese: return "已展开"
        }
    }

    static var a11yCollapsed: String {
        switch lang {
        case .korean: return "접힘"
        case .english: return "Collapsed"
        case .japanese: return "折りたたみ"
        case .chinese: return "已折叠"
        }
    }

    /// 휴가 기록 행 VoiceOver 힌트
    static var editLeaveHint: String {
        switch lang {
        case .korean: return "이중 탭하여 수정"
        case .english: return "Double tap to edit"
        case .japanese: return "ダブルタップで編集"
        case .chinese: return "双击以编辑"
        }
    }

    /// 추천 황금연휴로 등록된 휴가 표식 (VoiceOver)
    static var recommendedMark: String {
        switch lang {
        case .korean: return "추천 황금연휴"
        case .english: return "Recommended holiday"
        case .japanese: return "おすすめの連休"
        case .chinese: return "推荐黄金假期"
        }
    }

    /// 공휴일 표시 토글 VoiceOver 힌트
    static var holidayVisibilityHint: String {
        switch lang {
        case .korean: return "끄면 달력에서 숨겨집니다"
        case .english: return "Turn off to hide it from the calendar"
        case .japanese: return "オフにするとカレンダーから非表示になります"
        case .chinese: return "关闭后将从日历中隐藏"
        }
    }

    static var holidayDateSection: String {
        switch lang {
        case .korean: return "날짜"
        case .english: return "Date"
        case .japanese: return "日付"
        case .chinese: return "日期"
        }
    }

    static var holidayDatePickerLabel: String {
        switch lang {
        case .korean: return "날짜 선택"
        case .english: return "Select Date"
        case .japanese: return "日付選択"
        case .chinese: return "选择日期"
        }
    }

    static var holidayNameSection: String {
        switch lang {
        case .korean: return "이름"
        case .english: return "Name"
        case .japanese: return "名前"
        case .chinese: return "名称"
        }
    }

    static var holidayNamePlaceholder: String {
        switch lang {
        case .korean: return "공휴일 이름 (예: 창립기념일)"
        case .english: return "Holiday name (e.g. Founding Day)"
        case .japanese: return "祝日名 (例: 創立記念日)"
        case .chinese: return "假日名称 (例如: 创立纪念日)"
        }
    }

    static var holidayAddTitle: String {
        switch lang {
        case .korean: return "공휴일 추가"
        case .english: return "Add Holiday"
        case .japanese: return "祝日を追加"
        case .chinese: return "添加假日"
        }
    }

    // MARK: - Register / Bonus 등
    static func availableDays(_ daysText: String) -> String {
        switch lang {
        case .korean: return "\(daysText)\(dayUnitSuffix) 사용 가능"
        case .english: return "\(daysText) days available"
        case .japanese: return "\(daysText)日利用可能"
        case .chinese: return "可用\(daysText)天"
        }
    }

    static func expiresBy(_ dateText: String) -> String {
        switch lang {
        case .korean: return "~\(dateText) 만료"
        case .english: return "Until \(dateText)"
        case .japanese: return "\(dateText)まで"
        case .chinese: return "至\(dateText)到期"
        }
    }

    // MARK: - 섹션 헤더 (마이리얼트립)
    static var sectionFlight: String {
        switch lang {
        case .korean: return "항공권"
        case .english: return "Flights"
        case .japanese: return "航空券"
        case .chinese: return "机票"
        }
    }

    static var sectionAccommodation: String {
        switch lang {
        case .korean: return "숙박"
        case .english: return "Stays"
        case .japanese: return "宿泊"
        case .chinese: return "住宿"
        }
    }

    static var sectionTour: String {
        switch lang {
        case .korean: return "투어·티켓"
        case .english: return "Tours & Tickets"
        case .japanese: return "ツアー・チケット"
        case .chinese: return "旅游·门票"
        }
    }

    // MARK: - 자유 계획 헤더
    static func leisureYearVacationPlan(year: Int) -> String {
        switch lang {
        case .korean: return "\(year)년 휴가 계획"
        case .english: return "\(year) Vacation Plan"
        case .japanese: return "\(year)年の休暇計画"
        case .chinese: return "\(year)年休假计划"
        }
    }

    // MARK: - 페이월
    static var paywallNoPurchaseFound: String {
        switch lang {
        case .korean: return "구매 기록을 찾을 수 없습니다."
        case .english: return "No purchase records found."
        case .japanese: return "購入履歴が見つかりません。"
        case .chinese: return "未找到购买记录。"
        }
    }

    static var paywallFeaturesHeader: String {
        switch lang {
        case .korean: return "기능"
        case .english: return "Features"
        case .japanese: return "機能"
        case .chinese: return "功能"
        }
    }

    // MARK: - 런치 스크린
    static var launchTitle: String {
        switch lang {
        case .korean: return "골드위크"
        case .english: return "Goldweek"
        case .japanese: return "ゴールドウィーク"
        case .chinese: return "Goldweek"
        }
    }

    static var launchSubtitle: String {
        switch lang {
        case .korean: return "똑똑한 연차 관리"
        case .english: return "Smart leave management"
        case .japanese: return "スマートな休暇管理"
        case .chinese: return "智能年假管理"
        }
    }

    // MARK: - 국가명 (Settings 노출용)
    static func countryDisplayName(_ country: Country) -> String {
        switch lang {
        case .korean:
            switch country {
            case .korea: return "한국"; case .japan: return "일본"
            case .china: return "중국"; case .usa: return "미국"
            case .germany: return "독일"; case .france: return "프랑스"
            }
        case .english:
            switch country {
            case .korea: return "Korea"; case .japan: return "Japan"
            case .china: return "China"; case .usa: return "USA"
            case .germany: return "Germany"; case .france: return "France"
            }
        case .japanese:
            switch country {
            case .korea: return "韓国"; case .japan: return "日本"
            case .china: return "中国"; case .usa: return "アメリカ"
            case .germany: return "ドイツ"; case .france: return "フランス"
            }
        case .chinese:
            switch country {
            case .korea: return "韩国"; case .japan: return "日本"
            case .china: return "中国"; case .usa: return "美国"
            case .germany: return "德国"; case .france: return "法国"
            }
        }
    }

    // MARK: - 여행 큐레이션 섹션
    static var travelSuggestionsHeader: String {
        switch lang {
        case .korean: return "이 연휴에 어울리는 여행"
        case .english: return "Trips that fit this break"
        case .japanese: return "この連休にぴったりの旅"
        case .chinese: return "适合此假期的旅行"
        }
    }

    static var travelSuggestionsSubtitle: String {
        switch lang {
        case .korean: return "연휴 길이와 시즌에 맞춰 골랐어요. 탭하면 마이리얼트립에서 상품을 확인할 수 있어요."
        case .english: return "Picked for this break's length and season. Tap to see options on MyRealTrip."
        case .japanese: return "連休の長さと季節に合わせて選びました。タップでマイリアルトリップの商品を確認。"
        case .chinese: return "根据假期长度和季节精选。点击可在MyRealTrip中查看商品。"
        }
    }

    static func cityName(_ key: String) -> String {
        switch lang {
        case .korean:
            switch key {
            case "osaka": return "오사카"
            case "fukuoka": return "후쿠오카"
            case "tokyo": return "도쿄"
            case "sapporo": return "삿포로"
            case "kyoto": return "교토"
            case "okinawa": return "오키나와"
            case "danang": return "다낭"
            case "bangkok": return "방콕"
            case "taipei": return "타이베이"
            case "bali": return "발리"
            case "jeju": return "제주"
            case "busan": return "부산"
            case "guam": return "괌"
            case "saipan": return "사이판"
            case "hanoi": return "하노이"
            case "phuket": return "푸켓"
            default: return key
            }
        case .english:
            switch key {
            case "osaka": return "Osaka"
            case "fukuoka": return "Fukuoka"
            case "tokyo": return "Tokyo"
            case "sapporo": return "Sapporo"
            case "kyoto": return "Kyoto"
            case "okinawa": return "Okinawa"
            case "danang": return "Da Nang"
            case "bangkok": return "Bangkok"
            case "taipei": return "Taipei"
            case "bali": return "Bali"
            case "jeju": return "Jeju"
            case "busan": return "Busan"
            case "guam": return "Guam"
            case "saipan": return "Saipan"
            case "hanoi": return "Hanoi"
            case "phuket": return "Phuket"
            default: return key.capitalized
            }
        case .japanese:
            switch key {
            case "osaka": return "大阪"
            case "fukuoka": return "福岡"
            case "tokyo": return "東京"
            case "sapporo": return "札幌"
            case "kyoto": return "京都"
            case "okinawa": return "沖縄"
            case "danang": return "ダナン"
            case "bangkok": return "バンコク"
            case "taipei": return "台北"
            case "bali": return "バリ島"
            case "jeju": return "済州島"
            case "busan": return "釜山"
            case "guam": return "グアム"
            case "saipan": return "サイパン"
            case "hanoi": return "ハノイ"
            case "phuket": return "プーケット"
            default: return key
            }
        case .chinese:
            switch key {
            case "osaka": return "大阪"
            case "fukuoka": return "福冈"
            case "tokyo": return "东京"
            case "sapporo": return "札幌"
            case "kyoto": return "京都"
            case "okinawa": return "冲绳"
            case "danang": return "岘港"
            case "bangkok": return "曼谷"
            case "taipei": return "台北"
            case "bali": return "巴厘岛"
            case "jeju": return "济州岛"
            case "busan": return "釜山"
            case "guam": return "关岛"
            case "saipan": return "塞班岛"
            case "hanoi": return "河内"
            case "phuket": return "普吉岛"
            default: return key
            }
        }
    }

    static func travelThemeName(_ key: String) -> String {
        switch lang {
        case .korean:
            switch key {
            case "family": return "가족 여행"
            case "rest": return "휴양"
            case "foodie": return "미식"
            case "shopping": return "쇼핑"
            case "nature": return "자연"
            case "romantic": return "로맨틱"
            case "culture": return "문화"
            case "activity": return "액티비티"
            default: return key
            }
        case .english:
            switch key {
            case "family": return "Family"
            case "rest": return "Resort"
            case "foodie": return "Foodie"
            case "shopping": return "Shopping"
            case "nature": return "Nature"
            case "romantic": return "Romantic"
            case "culture": return "Culture"
            case "activity": return "Activity"
            default: return key.capitalized
            }
        case .japanese:
            switch key {
            case "family": return "家族旅行"
            case "rest": return "リゾート"
            case "foodie": return "グルメ"
            case "shopping": return "ショッピング"
            case "nature": return "自然"
            case "romantic": return "ロマンチック"
            case "culture": return "文化"
            case "activity": return "アクティビティ"
            default: return key
            }
        case .chinese:
            switch key {
            case "family": return "家庭旅行"
            case "rest": return "度假"
            case "foodie": return "美食"
            case "shopping": return "购物"
            case "nature": return "自然"
            case "romantic": return "浪漫"
            case "culture": return "文化"
            case "activity": return "活动"
            default: return key
            }
        }
    }

    static func travelReasonLabel(_ key: String) -> String {
        switch lang {
        case .korean:
            switch key {
            case "bestSeason": return "지금이 베스트 시즌"
            case "shortNearby": return "가깝고 부담 없이"
            case "longResort": return "긴 휴가에 제대로"
            case "burnoutRecovery": return "번아웃 회복에"
            case "offSeasonDeal": return "비수기, 합리적 가격"
            case "familyTime": return "가족과 함께"
            case "couplesTrip": return "둘이 떠나기 좋은"
            case "weekendEscape": return "주말+1일이면 충분"
            case "foodieParadise": return "미식 천국"
            case "cultureExplore": return "문화 탐방"
            default: return ""
            }
        case .english:
            switch key {
            case "bestSeason": return "Peak season now"
            case "shortNearby": return "Close & easy"
            case "longResort": return "Perfect for long breaks"
            case "burnoutRecovery": return "Reset & recharge"
            case "offSeasonDeal": return "Off-season deals"
            case "familyTime": return "Family-friendly"
            case "couplesTrip": return "Romantic getaway"
            case "weekendEscape": return "Long weekend ready"
            case "foodieParadise": return "Foodie paradise"
            case "cultureExplore": return "Culture & history"
            default: return ""
            }
        case .japanese:
            switch key {
            case "bestSeason": return "今がベストシーズン"
            case "shortNearby": return "近くて気軽に"
            case "longResort": return "長期休暇にぴったり"
            case "burnoutRecovery": return "心身のリセットに"
            case "offSeasonDeal": return "オフシーズンでお得"
            case "familyTime": return "家族で楽しめる"
            case "couplesTrip": return "二人旅にぴったり"
            case "weekendEscape": return "週末+1日で十分"
            case "foodieParadise": return "グルメ天国"
            case "cultureExplore": return "文化を体験"
            default: return ""
            }
        case .chinese:
            switch key {
            case "bestSeason": return "现在正是好时节"
            case "shortNearby": return "近且轻松"
            case "longResort": return "长假首选"
            case "burnoutRecovery": return "适合放空充电"
            case "offSeasonDeal": return "淡季更划算"
            case "familyTime": return "适合家庭"
            case "couplesTrip": return "适合情侣"
            case "weekendEscape": return "周末+1天足够"
            case "foodieParadise": return "美食天堂"
            case "cultureExplore": return "文化探索"
            default: return ""
            }
        }
    }

    static func priceTierLabel(_ key: String) -> String {
        switch lang {
        case .korean:
            switch key {
            case "budget": return "알뜰"
            case "mid": return "적정"
            case "premium": return "프리미엄"
            default: return key
            }
        case .english:
            switch key {
            case "budget": return "Budget"
            case "mid": return "Mid-range"
            case "premium": return "Premium"
            default: return key.capitalized
            }
        case .japanese:
            switch key {
            case "budget": return "お手頃"
            case "mid": return "スタンダード"
            case "premium": return "プレミアム"
            default: return key
            }
        case .chinese:
            switch key {
            case "budget": return "经济"
            case "mid": return "标准"
            case "premium": return "高端"
            default: return key
            }
        }
    }

    // MARK: - 이전 연차 빠른 입력
    static var pastLeavePromptTitle: String {
        switch lang {
        case .korean: return "올해 사용한 연차가 있나요?"
        case .english: return "Did you take any leave this year?"
        case .japanese: return "今年すでに有給を使いましたか？"
        case .chinese: return "今年已经使用过年假吗？"
        }
    }

    static var pastLeavePromptDesc: String {
        switch lang {
        case .korean: return "지금까지 사용한 연차를 입력하면 남은 연차를 정확히 파악할 수 있어요"
        case .english: return "Log your past leave to see your accurate remaining balance"
        case .japanese: return "過去の有給を入力して正確な残日数を確認しましょう"
        case .chinese: return "输入已使用的年假以准确查看剩余天数"
        }
    }

    static var pastLeaveQuickAdd: String {
        switch lang {
        case .korean: return "빠른 입력"
        case .english: return "Quick Entry"
        case .japanese: return "クイック入力"
        case .chinese: return "快速输入"
        }
    }

    static var pastLeaveTotalUsed: String {
        switch lang {
        case .korean: return "사용한 연차"
        case .english: return "Leave days used"
        case .japanese: return "使用した有給日数"
        case .chinese: return "已使用年假"
        }
    }

    static var pastLeaveSheetTitle: String {
        switch lang {
        case .korean: return "이전 연차 입력"
        case .english: return "Add Past Leave"
        case .japanese: return "過去の有給を入力"
        case .chinese: return "输入过去的年假"
        }
    }

    static var pastLeaveSheetDesc: String {
        switch lang {
        case .korean: return "올해 이미 사용한 연차 일수를 입력하세요.\n정확한 날짜는 + 탭에서 개별 입력할 수 있어요."
        case .english: return "Enter the total leave days already used this year.\nFor exact dates, add them individually in the + tab."
        case .japanese: return "今年すでに使用した有給日数を入力してください。\n正確な日付は＋タブから個別入力できます。"
        case .chinese: return "请输入今年已使用的年假天数。\n精确日期可在+标签中单独输入。"
        }
    }

    static var pastLeaveConfirm: String {
        switch lang {
        case .korean: return "반영하기"
        case .english: return "Confirm"
        case .japanese: return "反映する"
        case .chinese: return "确认"
        }
    }

    static var pastLeaveSummaryNote: String {
        switch lang {
        case .korean: return "이전 사용 연차 (일괄 입력)"
        case .english: return "Prior leave (bulk entry)"
        case .japanese: return "過去の有給（一括入力）"
        case .chinese: return "过去的年假（批量录入）"
        }
    }

    static var pastLeaveAutoUsed: String {
        switch lang {
        case .korean: return "과거 날짜 선택 시 자동으로 '사용 완료' 처리됩니다"
        case .english: return "Past dates are automatically marked as 'Used'"
        case .japanese: return "過去の日付は自動的に「使用済み」になります"
        case .chinese: return "过去日期会自动标记为「已使用」"
        }
    }

    // MARK: - 연휴 알림 섹션
    static var upcomingHolidaysSection: String {
        switch lang {
        case .korean: return "연차 없이 쉬는 날"
        case .english: return "Free Days Off"
        case .japanese: return "有給不要の連休"
        case .chinese: return "无需年假的假期"
        }
    }

    /// 한 해 전체 황금연휴 보기 토글
    static var showAllYearToggle: String {
        switch lang {
        case .korean: return "한 해 전체 보기 (지난 휴가 포함)"
        case .english: return "Show whole year (include past)"
        case .japanese: return "1年分すべて表示(過去も含む)"
        case .chinese: return "查看全年(包含过去)"
        }
    }

    static var upcomingHolidaysSectionSubtitle: String {
        switch lang {
        case .korean: return "이미 연휴가 있어요. 연차를 추가하면 더 길게 쉴 수 있어요."
        case .english: return "Holidays are already here. Add leave to extend them."
        case .japanese: return "連休があります。有給を追加して延ばせます。"
        case .chinese: return "已有假期。添加年假可以延长假期。"
        }
    }

    static var addWithPro: String {
        switch lang {
        case .korean: return "Pro로 일정 추가"
        case .english: return "Add with Pro"
        case .japanese: return "Proで追加"
        case .chinese: return "Pro版添加"
        }
    }

    static var proUnlockHint: String {
        switch lang {
        case .korean: return "Pro로 업그레이드하면 모든 추천을 일정에 추가할 수 있어요"
        case .english: return "Upgrade to Pro to add all recommendations to your schedule"
        case .japanese: return "Proにアップグレードしてすべての推薦を追加できます"
        case .chinese: return "升级Pro版即可添加所有推荐到日程"
        }
    }
}
