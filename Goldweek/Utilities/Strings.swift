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
    case german = "de"
    case french = "fr"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .korean: return "한국어"
        case .english: return "English"
        case .japanese: return "日本語"
        case .chinese: return "中文"
        case .german: return "Deutsch"
        case .french: return "Français"
        }
    }

    var flag: String {
        switch self {
        case .korean: return "🇰🇷"
        case .english: return "🇺🇸"
        case .japanese: return "🇯🇵"
        case .chinese: return "🇨🇳"
        case .german: return "🇩🇪"
        case .french: return "🇫🇷"
        }
    }

    /// 번들 리소스(문자열 카탈로그·LeeoKit)를 고를 때 쓰는 코드.
    /// ⚠️ 중국어는 `zh`가 아니라 `zh-Hans`여야 카탈로그가 매칭된다.
    var bundleLanguageCode: String {
        switch self {
        case .korean: return "ko"
        case .english: return "en"
        case .japanese: return "ja"
        case .chinese: return "zh-Hans"
        case .german: return "de"
        case .french: return "fr"
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
            // 앱 번들 문구(LeeoKit 피드백 화면, 시스템 공유 시트 등)는 이 앱의 언어 설정이 아니라
            // **번들 언어**를 따른다. 이 값을 같이 써 둬야 기기 언어가 한국어인 사용자가 앱만
            // 영어로 바꿨을 때 그 화면들까지 따라온다.
            // ⚠️ 번들 문구는 **다음 실행부터** 반영된다(이미 로드된 번들 캐시는 안 바뀐다).
            //    설정 화면의 행 이름들은 Strings 를 쓰므로 즉시 바뀐다.
            // 지원하지 않는 언어에서 개발 언어(한국어)로 떨어지지 않도록 영어를 뒤에 둔다.
            let fallback = newValue == .english ? [] : ["en"]
            UserDefaults.standard.set([newValue.bundleLanguageCode] + fallback, forKey: "AppleLanguages")
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
            case "de": return .german
            case "fr": return .french
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
        case .german: return "Status"
        case .french: return "Aperçu"
        }
    }

    static var tabCalendar: String {
        switch lang {
        case .korean: return "캘린더"
        case .english: return "Calendar"
        case .japanese: return "カレンダー"
        case .chinese: return "日历"
        case .german: return "Kalender"
        case .french: return "Calendrier"
        }
    }

    static var tabRecommendations: String {
        switch lang {
        case .korean: return "추천"
        case .english: return "Recommend"
        case .japanese: return "おすすめ"
        case .chinese: return "推荐"
        case .german: return "Tipps"
        case .french: return "Idées"
        }
    }

    static var tabRegister: String {
        switch lang {
        case .korean: return "등록"
        case .english: return "Register"
        case .japanese: return "登録"
        case .chinese: return "登记"
        case .german: return "Eintragen"
        case .french: return "Ajouter"
        }
    }

    static var dateRangeFormat: String {
        switch lang {
        case .korean: return "M/d(E)"
        case .english: return "M/d(EEE)"
        case .japanese: return "M/d(E)"
        case .chinese: return "M/d(E)"
        case .german: return "d.M. (EEE)"
        case .french: return "d/M (EEE)"
        }
    }

    static var tabSettings: String {
        switch lang {
        case .korean: return "설정"
        case .english: return "Settings"
        case .japanese: return "設定"
        case .chinese: return "设置"
        case .german: return "Einstellungen"
        case .french: return "Réglages"
        }
    }

    // MARK: - 홈 화면
    static var navTitleHome: String {
        switch lang {
        case .korean: return "휴가플래너"
        case .english: return "Leave Planner"
        case .japanese: return "休暇プランナー"
        case .chinese: return "休假规划"
        case .german: return "Urlaubsplaner"
        case .french: return "Planificateur de congés"
        }
    }

    static func annualLeaveStatus(year: Int) -> String {
        switch lang {
        case .korean: return "\(year)년 연차 현황"
        case .english: return "\(year) Annual Leave"
        case .japanese: return "\(year)年 有給休暇"
        case .chinese: return "\(year)年 年假概况"
        case .german: return "Urlaub \(year)"
        case .french: return "Congés \(year)"
        }
    }

    /// 연도 없는 연차 현황 제목
    static var annualLeaveStatusTitle: String {
        switch lang {
        case .korean: return "연차 현황"
        case .english: return "Annual Leave"
        case .japanese: return "有給休暇"
        case .chinese: return "年假概况"
        case .german: return "Urlaub"
        case .french: return "Congés"
        }
    }

    /// 연도 없는 자유 계획 제목
    static var leisureVacationPlanTitle: String {
        switch lang {
        case .korean: return "휴가 계획"
        case .english: return "Vacation Plan"
        case .japanese: return "休暇計画"
        case .chinese: return "休假计划"
        case .german: return "Urlaubsplan"
        case .french: return "Plan de vacances"
        }
    }

    static var used: String {
        switch lang {
        case .korean: return "사용"
        case .english: return "Used"
        case .japanese: return "使用"
        case .chinese: return "已用"
        case .german: return "Genommen"
        case .french: return "Pris"
        }
    }

    static var total: String {
        switch lang {
        case .korean: return "총"
        case .english: return "Total"
        case .japanese: return "合計"
        case .chinese: return "共"
        case .german: return "Gesamt"
        case .french: return "Total"
        }
    }

    static var remaining: String {
        switch lang {
        case .korean: return "남음"
        case .english: return "Left"
        case .japanese: return "残り"
        case .chinese: return "剩余"
        case .german: return "Übrig"
        case .french: return "Restant"
        }
    }

    static var upcomingLeaves: String {
        switch lang {
        case .korean: return "다가오는 휴가"
        case .english: return "Upcoming Leaves"
        case .japanese: return "今後の休暇"
        case .chinese: return "即将到来的假期"
        case .german: return "Bevorstehender Urlaub"
        case .french: return "Congés à venir"
        }
    }

    static var recommendedSchedule: String {
        switch lang {
        case .korean: return "추천 휴가 일정"
        case .english: return "Recommended Schedule"
        case .japanese: return "おすすめ休暇日程"
        case .chinese: return "推荐休假日程"
        case .german: return "Empfohlene Urlaubsplanung"
        case .french: return "Planning recommandé"
        }
    }

    static var generatingRecommendations: String {
        switch lang {
        case .korean: return "추천을 생성 중입니다..."
        case .english: return "Generating recommendations..."
        case .japanese: return "おすすめを作成中..."
        case .chinese: return "正在生成推荐..."
        case .german: return "Empfehlungen werden erstellt..."
        case .french: return "Création des recommandations..."
        }
    }

    static var addToSchedule: String {
        switch lang {
        case .korean: return "일정 추가하기"
        case .english: return "Add to Schedule"
        case .japanese: return "予定に追加"
        case .chinese: return "添加到日程"
        case .german: return "Zum Plan hinzufügen"
        case .french: return "Ajouter au planning"
        }
    }

    static var addedToSchedule: String {
        switch lang {
        case .korean: return "추가됨 ✓"
        case .english: return "Added ✓"
        case .japanese: return "追加済み ✓"
        case .chinese: return "已添加 ✓"
        case .german: return "Hinzugefügt ✓"
        case .french: return "Ajouté ✓"
        }
    }

    static var efficiency: String {
        switch lang {
        case .korean: return "효율"
        case .english: return "Efficiency"
        case .japanese: return "効率"
        case .chinese: return "效率"
        case .german: return "Effizienz"
        case .french: return "Efficacité"
        }
    }

    static var leaveHistory: String {
        switch lang {
        case .korean: return "휴가 사용 내역"
        case .english: return "Leave History"
        case .japanese: return "休暇履歴"
        case .chinese: return "休假记录"
        case .german: return "Urlaubsverlauf"
        case .french: return "Historique des congés"
        }
    }

    static var checkPastRecords: String {
        switch lang {
        case .korean: return "지난 휴가 기록을 확인하세요"
        case .english: return "Check past leave records"
        case .japanese: return "過去の休暇記録を確認"
        case .chinese: return "查看过去的休假记录"
        case .german: return "Vergangene Urlaube ansehen"
        case .french: return "Consultez vos congés passés"
        }
    }

    static var vacation: String {
        switch lang {
        case .korean: return "휴가"
        case .english: return "Leave"
        case .japanese: return "休暇"
        case .chinese: return "假期"
        case .german: return "Urlaub"
        case .french: return "Congé"
        }
    }

    // MARK: - 캘린더 화면
    static var navTitleCalendar: String {
        switch lang {
        case .korean: return "캘린더"
        case .english: return "Calendar"
        case .japanese: return "カレンダー"
        case .chinese: return "日历"
        case .german: return "Kalender"
        case .french: return "Calendrier"
        }
    }

    static var holiday: String {
        switch lang {
        case .korean: return "공휴일"
        case .english: return "Holiday"
        case .japanese: return "祝日"
        case .chinese: return "节假日"
        case .german: return "Feiertag"
        case .french: return "Jour férié"
        }
    }

    static var annualLeave: String {
        switch lang {
        case .korean: return "연차"
        case .english: return "Annual Leave"
        case .japanese: return "有給休暇"
        case .chinese: return "年假"
        case .german: return "Jahresurlaub"
        case .french: return "Congés annuels"
        }
    }

    static var weekend: String {
        switch lang {
        case .korean: return "주말"
        case .english: return "Weekend"
        case .japanese: return "週末"
        case .chinese: return "周末"
        case .german: return "Wochenende"
        case .french: return "Week-end"
        }
    }

    static var noSchedule: String {
        switch lang {
        case .korean: return "일정 없음"
        case .english: return "No schedule"
        case .japanese: return "予定なし"
        case .chinese: return "无日程"
        case .german: return "Kein Termin"
        case .french: return "Aucun événement"
        }
    }

    static var substituteHoliday: String {
        switch lang {
        case .korean: return "대체공휴일"
        case .english: return "Substitute Holiday"
        case .japanese: return "振替休日"
        case .chinese: return "补休日"
        case .german: return "Ersatzfeiertag"
        case .french: return "Jour férié de remplacement"
        }
    }

    static var deleteLeave: String {
        switch lang {
        case .korean: return "휴가 삭제"
        case .english: return "Delete Leave"
        case .japanese: return "休暇を削除"
        case .chinese: return "删除假期"
        case .german: return "Urlaub löschen"
        case .french: return "Supprimer le congé"
        }
    }

    static var deleteLeaveConfirm: String {
        switch lang {
        case .korean: return "이 휴가 기록을 삭제하시겠습니까?\n연차가 복원됩니다."
        case .english: return "Delete this leave record?\nAnnual leave will be restored."
        case .japanese: return "この休暇記録を削除しますか？\n有給が復元されます。"
        case .chinese: return "确定删除此休假记录吗？\n年假将被恢复。"
        case .german: return "Diesen Urlaubseintrag löschen?\nDie Urlaubstage werden zurückgebucht."
        case .french: return "Supprimer ce congé ?\nLes jours de congé seront restitués."
        }
    }

    static var cancel: String {
        switch lang {
        case .korean: return "취소"
        case .english: return "Cancel"
        case .japanese: return "キャンセル"
        case .chinese: return "取消"
        case .german: return "Abbrechen"
        case .french: return "Annuler"
        }
    }

    static var delete: String {
        switch lang {
        case .korean: return "삭제"
        case .english: return "Delete"
        case .japanese: return "削除"
        case .chinese: return "删除"
        case .german: return "Löschen"
        case .french: return "Supprimer"
        }
    }

    static var myLeaveSchedule: String {
        switch lang {
        case .korean: return "나의 연차 일정"
        case .english: return "My Leave Schedule"
        case .japanese: return "休暇スケジュール"
        case .chinese: return "我的年假日程"
        case .german: return "Mein Urlaubsplan"
        case .french: return "Mes congés"
        }
    }

    static var noLeaveRegistered: String {
        switch lang {
        case .korean: return "등록된 연차가 없습니다"
        case .english: return "No leave registered"
        case .japanese: return "登録された休暇がありません"
        case .chinese: return "没有登记的年假"
        case .german: return "Kein Urlaub eingetragen"
        case .french: return "Aucun congé enregistré"
        }
    }

    static var tapToEditSwipeToDelete: String {
        switch lang {
        case .korean: return "탭하여 수정 · 스와이프하여 삭제"
        case .english: return "Tap to edit · Swipe to delete"
        case .japanese: return "タップで編集 · スワイプで削除"
        case .chinese: return "点击编辑 · 滑动删除"
        case .german: return "Tippen zum Bearbeiten · Wischen zum Löschen"
        case .french: return "Touchez pour modifier · Balayez pour supprimer"
        }
    }

    static var upcomingSchedule: String {
        switch lang {
        case .korean: return "예정된 일정"
        case .english: return "Upcoming"
        case .japanese: return "予定"
        case .chinese: return "即将到来"
        case .german: return "Anstehend"
        case .french: return "À venir"
        }
    }

    static var pastSchedule: String {
        switch lang {
        case .korean: return "지난 일정"
        case .english: return "Past"
        case .japanese: return "過去"
        case .chinese: return "过去"
        case .german: return "Vergangen"
        case .french: return "Passés"
        }
    }

    static var today: String {
        switch lang {
        case .korean: return "오늘"
        case .english: return "Today"
        case .japanese: return "今日"
        case .chinese: return "今天"
        case .german: return "Heute"
        case .french: return "Aujourd’hui"
        }
    }

    static var previousMonth: String {
        switch lang {
        case .korean: return "이전 달"
        case .english: return "Previous month"
        case .japanese: return "前の月"
        case .chinese: return "上个月"
        case .german: return "Vorheriger Monat"
        case .french: return "Mois précédent"
        }
    }

    static var previousYear: String {
        switch lang {
        case .korean: return "이전 연도"
        case .english: return "Previous year"
        case .japanese: return "前の年"
        case .chinese: return "上一年"
        case .german: return "Vorheriges Jahr"
        case .french: return "Année précédente"
        }
    }

    static var nextYear: String {
        switch lang {
        case .korean: return "다음 연도"
        case .english: return "Next year"
        case .japanese: return "次の年"
        case .chinese: return "下一年"
        case .german: return "Nächstes Jahr"
        case .french: return "Année suivante"
        }
    }

    // MARK: - 휴가별 액티비티 추천 (EditLeaveSheet)
    static var leaveActivityTitle: String {
        switch lang {
        case .korean: return "이 휴가에 어울리는 여행 추천"
        case .english: return "Trips that match this leave"
        case .japanese: return "この休暇に合う旅行のおすすめ"
        case .chinese: return "适合此假期的旅行推荐"
        case .german: return "Reisen, die zu diesem Urlaub passen"
        case .french: return "Voyages adaptés à ce congé"
        }
    }

    static var leaveActivitySubtitle: String {
        switch lang {
        case .korean: return "기간·계절·출발 국가 기반 큐레이션"
        case .english: return "Curated by duration, season, and origin"
        case .japanese: return "期間・季節・出発国に基づく厳選"
        case .chinese: return "根据时长、季节和出发国精选"
        case .german: return "Nach Dauer, Jahreszeit und Abflugland ausgewählt"
        case .french: return "Sélection selon la durée, la saison et le pays de départ"
        }
    }

    static var leaveActivityLiveTitle: String {
        switch lang {
        case .korean: return "이 날짜로 검색한 실시간 항공·숙박"
        case .english: return "Live flights & stays for these dates"
        case .japanese: return "この日付のリアルタイム航空券・宿泊"
        case .chinese: return "针对这些日期的实时机票和住宿"
        case .german: return "Live-Flüge & Unterkünfte für diese Tage"
        case .french: return "Vols et hébergements en direct pour ces dates"
        }
    }

    static var leaveActivityLoading: String {
        switch lang {
        case .korean: return "추천 불러오는 중…"
        case .english: return "Loading recommendations…"
        case .japanese: return "おすすめを読み込み中…"
        case .chinese: return "正在加载推荐…"
        case .german: return "Empfehlungen werden geladen…"
        case .french: return "Chargement des recommandations…"
        }
    }

    // MARK: - Pro 가치 제안 (Paywall 비교표)
    static var proFeatureAIAnnualPlanner: String {
        switch lang {
        case .korean: return "최적 연간 휴가 플래너"
        case .english: return "Optimal annual planner"
        case .japanese: return "最適な年間プランナー"
        case .chinese: return "最佳年度规划"
        case .german: return "Optimaler Jahresplaner"
        case .french: return "Planificateur annuel optimal"
        }
    }

    // MARK: - 최적 연간 휴가 플래너
    static var optimalPlannerTitle: String {
        switch lang {
        case .korean: return "한 해 최적 휴가 플랜"
        case .english: return "Optimal year plan"
        case .japanese: return "年間最適プラン"
        case .chinese: return "全年最佳计划"
        case .german: return "Optimaler Urlaubsplan fürs Jahr"
        case .french: return "Plan de congés optimal pour l’année"
        }
    }

    static var optimalPlannerSubtitle: String {
        switch lang {
        case .korean: return "공휴일·주말을 분석해 가장 긴 연휴 조합을 자동으로 계산"
        case .english: return "Computes the longest break combinations from holidays & weekends"
        case .japanese: return "祝日・週末を分析して最長の連休組み合わせを自動算出"
        case .chinese: return "分析公共假日和周末，自动计算最长假期组合"
        case .german: return "Berechnet aus Feiertagen und Wochenenden die längsten Auszeiten"
        case .french: return "Calcule les plus longues périodes de repos à partir des jours fériés et week-ends"
        }
    }

    static func optimalPlannerSummary(totalDays: Int, breaks: Int, leaveUsed: Int) -> String {
        switch lang {
        case .korean: return "연차 \(leaveUsed)일로 총 \(totalDays)일 휴식 (\(breaks)개의 연휴)"
        case .english: return "\(totalDays) days off with \(leaveUsed) PTO (\(breaks) breaks)"
        case .japanese: return "有給\(leaveUsed)日で計\(totalDays)日休み（\(breaks)回の連休）"
        case .chinese: return "用\(leaveUsed)天年假休息\(totalDays)天（\(breaks)次假期）"
        case .german: return "\(totalDays) freie Tage mit \(leaveUsed) Urlaubstagen (\(breaks) Auszeiten)"
        case .french: return "\(totalDays) jours de repos avec \(leaveUsed) congés (\(breaks) pauses)"
        }
    }

    /// 접힘 상태에서 큰 숫자 옆 단위
    static var optimalPlannerSummaryUnit: String {
        switch lang {
        case .korean: return "일 휴식"
        case .english: return "days off"
        case .japanese: return "日休み"
        case .chinese: return "天假期"
        case .german: return "freie Tage"
        case .french: return "jours de repos"
        }
    }

    /// 접힘 상태에서 옆에 붙는 보조 정보: "연차 4일 · 5회 연휴"
    static func optimalPlannerSummaryAside(leaveUsed: Int, breaks: Int) -> String {
        switch lang {
        case .korean: return "연차 \(leaveUsed)일 · 연휴 \(breaks)회"
        case .english: return "\(leaveUsed) PTO · \(breaks) breaks"
        case .japanese: return "有給\(leaveUsed)日・\(breaks)回"
        case .chinese: return "年假\(leaveUsed)天·\(breaks)次"
        case .german: return "\(leaveUsed) Urlaubstage · \(breaks) Auszeiten"
        case .french: return "\(leaveUsed) congés · \(breaks) pauses"
        }
    }

    static var optimalPlannerExpandHint: String {
        switch lang {
        case .korean: return "이중 탭하여 펼치기"
        case .english: return "Double-tap to expand"
        case .japanese: return "ダブルタップで展開"
        case .chinese: return "双击展开"
        case .german: return "Doppeltippen zum Erweitern"
        case .french: return "Touchez deux fois pour développer"
        }
    }

    static var optimalPlannerCollapseHint: String {
        switch lang {
        case .korean: return "이중 탭하여 접기"
        case .english: return "Double-tap to collapse"
        case .japanese: return "ダブルタップで折りたたむ"
        case .chinese: return "双击折叠"
        case .german: return "Doppeltippen zum Einklappen"
        case .french: return "Touchez deux fois pour réduire"
        }
    }

    static var optimalPlannerEmpty: String {
        switch lang {
        case .korean: return "추가 연차를 등록하면 더 긴 연휴를 만들 수 있어요"
        case .english: return "Register more PTO to unlock longer breaks"
        case .japanese: return "有給を追加すると、より長い連休が作れます"
        case .chinese: return "添加更多年假可获得更长假期"
        case .german: return "Trage mehr Urlaub ein, um längere Auszeiten zu ermöglichen"
        case .french: return "Ajoutez des congés pour débloquer de plus longues pauses"
        }
    }

    static var optimalPlannerProLockedTitle: String {
        switch lang {
        case .korean: return "한 해 휴가를 한 번에 최적 배치"
        case .english: return "Plan your year in one tap"
        case .japanese: return "1年の休暇を一度に最適配置"
        case .chinese: return "一键规划全年假期"
        case .german: return "Plane dein Jahr mit einem Tipp"
        case .french: return "Planifiez votre année en un geste"
        }
    }

    static var optimalPlannerProLockedDesc: String {
        switch lang {
        case .korean: return "남은 연차를 모든 공휴일에 최적 배치해 최장 연휴 조합을 찾아드려요"
        case .english: return "Optimally place your remaining PTO around all public holidays for the longest possible breaks"
        case .japanese: return "残りの有給を公休に最適配置し、最長の連休を計算"
        case .chinese: return "将剩余年假最佳分配在所有公假周围,获取最长假期"
        case .german: return "Verteile deine restlichen Urlaubstage optimal rund um alle Feiertage, für die längstmöglichen Auszeiten"
        case .french: return "Répartissez au mieux vos congés restants autour de tous les jours fériés pour des pauses les plus longues possible"
        }
    }

    static var optimalPlannerCTA: String {
        switch lang {
        case .korean: return "Pro로 최적 플랜 보기"
        case .english: return "Unlock optimal plan with Pro"
        case .japanese: return "Proで最適プランを見る"
        case .chinese: return "升级 Pro 查看最佳计划"
        case .german: return "Optimalen Plan mit Pro freischalten"
        case .french: return "Débloquer le plan optimal avec Pro"
        }
    }

    static var optimalPlannerApplyAll: String {
        switch lang {
        case .korean: return "전부 캘린더에 추가"
        case .english: return "Add all to calendar"
        case .japanese: return "すべてカレンダーに追加"
        case .chinese: return "全部添加到日历"
        case .german: return "Alle zum Kalender hinzufügen"
        case .french: return "Tout ajouter au calendrier"
        }
    }

    static func breakLabel(_ totalDays: Int, leaveUsed: Int) -> String {
        switch lang {
        case .korean: return "연차 \(leaveUsed)일 · \(totalDays)일 연휴"
        case .english: return "\(leaveUsed) PTO · \(totalDays)-day break"
        case .japanese: return "有給\(leaveUsed)日・\(totalDays)日連休"
        case .chinese: return "\(leaveUsed)天年假·\(totalDays)天假期"
        case .german: return "\(leaveUsed) Urlaubstage · \(totalDays) Tage frei"
        case .french: return "\(leaveUsed) congés · \(totalDays) jours de repos"
        }
    }

    static var nextMonth: String {
        switch lang {
        case .korean: return "다음 달"
        case .english: return "Next month"
        case .japanese: return "次の月"
        case .chinese: return "下个月"
        case .german: return "Nächster Monat"
        case .french: return "Mois suivant"
        }
    }

    static var weekdays: [String] {
        switch lang {
        case .korean: return ["일", "월", "화", "수", "목", "금", "토"]
        case .english: return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        case .japanese: return ["日", "月", "火", "水", "木", "金", "土"]
        case .chinese: return ["日", "一", "二", "三", "四", "五", "六"]
        case .german: return ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]
        case .french: return ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"]
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
        case .german:
            let monthNames = ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun",
                              "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"]
            return "\(monthNames[month - 1]) \(year)"
        case .french:
            let monthNames = ["janv.", "févr.", "mars", "avr.", "mai", "juin",
                              "juil.", "août", "sept.", "oct.", "nov.", "déc."]
            return "\(monthNames[month - 1]) \(year)"
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
        case .german:
            let names = ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun",
                         "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"]
            return names[month - 1]
        case .french:
            let names = ["janv.", "févr.", "mars", "avr.", "mai", "juin",
                         "juil.", "août", "sept.", "oct.", "nov.", "déc."]
            return names[month - 1]
        }
    }

    static func dayUnit(_ days: Int) -> String {
        switch lang {
        case .korean: return "\(days)일"
        case .english: return "\(days)d"
        case .japanese: return "\(days)日"
        case .chinese: return "\(days)天"
        case .german: return "\(days) T"
        case .french: return "\(days) j"
        }
    }

    static var dayUnitSuffix: String {
        switch lang {
        case .korean: return "일"
        case .english: return " days"
        case .japanese: return "日"
        case .chinese: return "天"
        case .german: return " Tage"
        case .french: return " jours"
        }
    }

    /// 일수 표기 — 영어의 "1 days"를 막는다.
    /// (`dayUnitSuffix`는 숫자에 그냥 붙이는 접미사라 단수를 구분하지 못한다)
    static func dayCount(_ value: Double) -> String {
        let text = formatLeave(value)
        switch lang {
        case .korean: return "\(text)일"
        case .english: return value == 1 ? "1 day" : "\(text) days"
        case .japanese: return "\(text)日"
        case .chinese: return "\(text)天"
        case .german: return value == 1 ? "1 Tag" : "\(text) Tage"
        case .french: return value == 1 ? "1 jour" : "\(text) jours"
        }
    }

    // MARK: - 추천 화면
    static var navTitleRecommendations: String {
        switch lang {
        case .korean: return "휴가 추천"
        case .english: return "Leave Recommendations"
        case .japanese: return "休暇おすすめ"
        case .chinese: return "休假推荐"
        case .german: return "Urlaubsempfehlungen"
        case .french: return "Recommandations de congés"
        }
    }

    static func yearRecommendation(year: Int) -> String {
        switch lang {
        case .korean: return "\(year)년 추천"
        case .english: return "\(year) Recommendations"
        case .japanese: return "\(year)年 おすすめ"
        case .chinese: return "\(year)年推荐"
        case .german: return "Empfehlungen \(year)"
        case .french: return "Recommandations \(year)"
        }
    }

    static var availableLeave: String {
        switch lang {
        case .korean: return "사용 가능한 연차"
        case .english: return "Available Leave"
        case .japanese: return "利用可能な有給"
        case .chinese: return "可用年假"
        case .german: return "Verfügbarer Urlaub"
        case .french: return "Congés disponibles"
        }
    }

    static var analyzingSchedule: String {
        switch lang {
        case .korean: return "추천 일정 분석 중..."
        case .english: return "Analyzing schedule..."
        case .japanese: return "スケジュール分析中..."
        case .chinese: return "正在分析日程..."
        case .german: return "Plan wird analysiert..."
        case .french: return "Analyse du planning..."
        }
    }

    static var noRecommendations: String {
        switch lang {
        case .korean: return "추천 일정이 없습니다"
        case .english: return "No recommendations"
        case .japanese: return "おすすめがありません"
        case .chinese: return "没有推荐日程"
        case .german: return "Keine Empfehlungen"
        case .french: return "Aucune recommandation"
        }
    }

    static var noRecommendationsHint: String {
        switch lang {
        case .korean: return "선호도 설정을 확인하거나\n연차를 더 확보해보세요"
        case .english: return "Check your preferences or\nsecure more leave days"
        case .japanese: return "設定を確認するか\n有給を確保してください"
        case .chinese: return "请检查偏好设置或\n确保有更多年假"
        case .german: return "Prüfe deine Einstellungen oder\nsichere dir mehr Urlaubstage"
        case .french: return "Vérifiez vos préférences ou\nobtenez plus de jours de congé"
        }
    }

    static var previewCalendar: String {
        switch lang {
        case .korean: return "추천 일정 미리보기"
        case .english: return "Schedule Preview"
        case .japanese: return "スケジュールプレビュー"
        case .chinese: return "日程预览"
        case .german: return "Vorschau des Plans"
        case .french: return "Aperçu du planning"
        }
    }

    static func leaveRequired(_ days: Int) -> String {
        switch lang {
        case .korean: return "\(days)일 연차"
        case .english: return "\(days)d leave"
        case .japanese: return "\(days)日有給"
        case .chinese: return "\(days)天年假"
        case .german: return "\(days) Urlaubstg."
        case .french: return "\(days) j de congé"
        }
    }

    static func daysOff(_ days: Int) -> String {
        switch lang {
        case .korean: return "\(days)일 휴식"
        case .english: return "\(days)d off"
        case .japanese: return "\(days)日休み"
        case .chinese: return "\(days)天休息"
        case .german: return "\(days) Tage frei"
        case .french: return "\(days) j de repos"
        }
    }

    static var addToScheduleAction: String {
        switch lang {
        case .korean: return "일정에 추가하기"
        case .english: return "Add to Schedule"
        case .japanese: return "予定に追加"
        case .chinese: return "添加到日程"
        case .german: return "Zum Plan hinzufügen"
        case .french: return "Ajouter au planning"
        }
    }

    static var addedToScheduleAction: String {
        switch lang {
        case .korean: return "일정에 추가됨"
        case .english: return "Added to Schedule"
        case .japanese: return "予定に追加済み"
        case .chinese: return "已添加到日程"
        case .german: return "Zum Plan hinzugefügt"
        case .french: return "Ajouté au planning"
        }
    }

    // Date preview legend
    static var workday: String {
        switch lang {
        case .korean: return "평일"
        case .english: return "Workday"
        case .japanese: return "平日"
        case .chinese: return "工作日"
        case .german: return "Werktag"
        case .french: return "Jour ouvré"
        }
    }

    // MARK: - 설정 화면
    static var navTitleSettings: String {
        switch lang {
        case .korean: return "설정"
        case .english: return "Settings"
        case .japanese: return "設定"
        case .chinese: return "设置"
        case .german: return "Einstellungen"
        case .french: return "Réglages"
        }
    }

    static var name: String {
        switch lang {
        case .korean: return "이름"
        case .english: return "Name"
        case .japanese: return "名前"
        case .chinese: return "姓名"
        case .german: return "Name"
        case .french: return "Nom"
        }
    }

    /// 이름 수정 버튼 VoiceOver 라벨
    static var editName: String {
        switch lang {
        case .korean: return "이름 수정"
        case .english: return "Edit name"
        case .japanese: return "名前を編集"
        case .chinese: return "编辑姓名"
        case .german: return "Name bearbeiten"
        case .french: return "Modifier le nom"
        }
    }

    static func joinDate(_ dateStr: String) -> String {
        switch lang {
        case .korean: return "가입일: \(dateStr)"
        case .english: return "Joined: \(dateStr)"
        case .japanese: return "登録日: \(dateStr)"
        case .chinese: return "注册日: \(dateStr)"
        case .german: return "Dabei seit: \(dateStr)"
        case .french: return "Inscrit le : \(dateStr)"
        }
    }

    static var countryAndLanguage: String {
        switch lang {
        case .korean: return "국가 및 언어"
        case .english: return "Country & Language"
        case .japanese: return "国と言語"
        case .chinese: return "国家和语言"
        case .german: return "Land & Sprache"
        case .french: return "Pays et langue"
        }
    }

    static var country: String {
        switch lang {
        case .korean: return "국가"
        case .english: return "Country"
        case .japanese: return "国"
        case .chinese: return "国家"
        case .german: return "Land"
        case .french: return "Pays"
        }
    }

    static var language: String {
        switch lang {
        case .korean: return "언어"
        case .english: return "Language"
        case .japanese: return "言語"
        case .chinese: return "语言"
        case .german: return "Sprache"
        case .french: return "Langue"
        }
    }

    static var annualLeaveSettings: String {
        switch lang {
        case .korean: return "연차 설정"
        case .english: return "Annual Leave Settings"
        case .japanese: return "有給休暇設定"
        case .chinese: return "年假设置"
        case .german: return "Urlaubseinstellungen"
        case .french: return "Réglages des congés"
        }
    }

    static var availableLeaveLabel: String {
        switch lang {
        case .korean: return "사용 가능 연차"
        case .english: return "Available Leave"
        case .japanese: return "利用可能有給"
        case .chinese: return "可用年假"
        case .german: return "Verfügbarer Urlaub"
        case .french: return "Congés disponibles"
        }
    }

    static func baseAndBonus(base: String, bonus: String) -> String {
        switch lang {
        case .korean: return "기본 \(base)일 + 보너스 \(bonus)일"
        case .english: return "Base \(base)d + Bonus \(bonus)d"
        case .japanese: return "基本 \(base)日 + ボーナス \(bonus)日"
        case .chinese: return "基本 \(base)天 + 奖励 \(bonus)天"
        case .german: return "Basis \(base) T. + Bonus \(bonus) T."
        case .french: return "Base \(base) j + bonus \(bonus) j"
        }
    }

    static var totalLeave: String {
        switch lang {
        case .korean: return "총 연차"
        case .english: return "Total Leave"
        case .japanese: return "有給合計"
        case .chinese: return "总年假"
        case .german: return "Urlaub gesamt"
        case .french: return "Total des congés"
        }
    }

    static var usedLeave: String {
        switch lang {
        case .korean: return "사용한 연차"
        case .english: return "Used Leave"
        case .japanese: return "使用済み"
        case .chinese: return "已使用"
        case .german: return "Genommener Urlaub"
        case .french: return "Congés pris"
        }
    }

    static var yearStartMonth: String {
        switch lang {
        case .korean: return "연차 기준월"
        case .english: return "Year Start Month"
        case .japanese: return "基準月"
        case .chinese: return "年假起始月"
        case .german: return "Startmonat des Urlaubsjahres"
        case .french: return "Mois de début d'année"
        }
    }

    static var bonusLeave: String {
        switch lang {
        case .korean: return "보너스 연차"
        case .english: return "Bonus Leave"
        case .japanese: return "ボーナス休暇"
        case .chinese: return "奖励年假"
        case .german: return "Bonusurlaub"
        case .french: return "Congés bonus"
        }
    }

    static var addBonusLeave: String {
        switch lang {
        case .korean: return "보너스 연차 추가"
        case .english: return "Add Bonus Leave"
        case .japanese: return "ボーナス休暇を追加"
        case .chinese: return "添加奖励年假"
        case .german: return "Bonusurlaub hinzufügen"
        case .french: return "Ajouter des congés bonus"
        }
    }

    static var bonusLeaveFooter: String {
        switch lang {
        case .korean: return "대체휴무, 포상휴가 등 추가로 받은 연차를 관리합니다."
        case .english: return "Manage additional leave from comp time, rewards, etc."
        case .japanese: return "代替休暇、報奨休暇など追加の有給を管理します。"
        case .chinese: return "管理补休、奖励假等额外年假。"
        case .german: return "Verwalte zusätzlichen Urlaub, z. B. Freizeitausgleich oder Prämien."
        case .french: return "Gérez les congés supplémentaires : récupérations, récompenses, etc."
        }
    }

    static var vacationStyle: String {
        switch lang {
        case .korean: return "휴가 스타일"
        case .english: return "Vacation Style"
        case .japanese: return "休暇スタイル"
        case .chinese: return "休假风格"
        case .german: return "Urlaubsstil"
        case .french: return "Style de vacances"
        }
    }

    static var preferencesSettings: String {
        switch lang {
        case .korean: return "선호도 설정"
        case .english: return "Preferences"
        case .japanese: return "好み設定"
        case .chinese: return "偏好设置"
        case .german: return "Vorlieben"
        case .french: return "Préférences"
        }
    }

    static var preferredDuration: String {
        switch lang {
        case .korean: return "선호 기간"
        case .english: return "Duration"
        case .japanese: return "期間"
        case .chinese: return "偏好时长"
        case .german: return "Dauer"
        case .french: return "Durée"
        }
    }

    static var preferredSeason: String {
        switch lang {
        case .korean: return "선호 계절"
        case .english: return "Season"
        case .japanese: return "季節"
        case .chinese: return "偏好季节"
        case .german: return "Jahreszeit"
        case .french: return "Saison"
        }
    }

    static var preferredActivity: String {
        switch lang {
        case .korean: return "선호 활동"
        case .english: return "Activity"
        case .japanese: return "活動"
        case .chinese: return "偏好活动"
        case .german: return "Aktivität"
        case .french: return "Activité"
        }
    }

    static var usageStats: String {
        switch lang {
        case .korean: return "사용 통계"
        case .english: return "Usage Stats"
        case .japanese: return "利用統計"
        case .chinese: return "使用统计"
        case .german: return "Nutzungsstatistik"
        case .french: return "Statistiques d'utilisation"
        }
    }

    static var completed: String {
        switch lang {
        case .korean: return "사용 완료"
        case .english: return "Completed"
        case .japanese: return "使用済み"
        case .chinese: return "已完成"
        case .german: return "Genommen"
        case .french: return "Pris"
        }
    }

    static var plannedLeave: String {
        switch lang {
        case .korean: return "예정된 휴가"
        case .english: return "Planned Leave"
        case .japanese: return "予定の休暇"
        case .chinese: return "计划中的假期"
        case .german: return "Geplanter Urlaub"
        case .french: return "Congés prévus"
        }
    }

    static var leaveUsageRate: String {
        switch lang {
        case .korean: return "연차 소진율"
        case .english: return "Usage Rate"
        case .japanese: return "消化率"
        case .chinese: return "使用率"
        case .german: return "Nutzungsquote"
        case .french: return "Taux d'utilisation"
        }
    }

    static var dataManagement: String {
        switch lang {
        case .korean: return "데이터 관리"
        case .english: return "Data Management"
        case .japanese: return "データ管理"
        case .chinese: return "数据管理"
        case .german: return "Datenverwaltung"
        case .french: return "Gestion des données"
        }
    }

    static var backupToICloud: String {
        switch lang {
        case .korean: return "iCloud에 백업"
        case .english: return "Backup to iCloud"
        case .japanese: return "iCloudにバックアップ"
        case .chinese: return "备份到iCloud"
        case .german: return "In iCloud sichern"
        case .french: return "Sauvegarder sur iCloud"
        }
    }

    static var restoreFromICloud: String {
        switch lang {
        case .korean: return "iCloud에서 복원"
        case .english: return "Restore from iCloud"
        case .japanese: return "iCloudから復元"
        case .chinese: return "从iCloud恢复"
        case .german: return "Aus iCloud wiederherstellen"
        case .french: return "Restaurer depuis iCloud"
        }
    }

    // MARK: - 기능 팁 (TipKit)

    static var tipPhotoImportTitle: String {
        switch lang {
        case .korean: return "사진으로 휴가 등록"
        case .english: return "Add Leaves from a Photo"
        case .japanese: return "写真で休暇を登録"
        case .chinese: return "用照片登记休假"
        case .german: return "Urlaub per Foto eintragen"
        case .french: return "Ajouter des congés par photo"
        }
    }

    static var tipPhotoImportMessage: String {
        switch lang {
        case .korean: return "회사 시스템의 휴가 신청 내역을 찍으면 자동으로 인식해서 등록해드려요."
        case .english: return "Snap your company's leave request history and it's recognized and added automatically."
        case .japanese: return "会社システムの休暇申請履歴を撮影すると、自動で認識して登録します。"
        case .chinese: return "拍摄公司系统的休假申请记录，即可自动识别并登记。"
        case .german: return "Fotografiere die Urlaubsübersicht deiner Firma, und sie wird automatisch erkannt und eingetragen."
        case .french: return "Photographiez l'historique de congés de votre entreprise : il est reconnu et ajouté automatiquement."
        }
    }

    static var tipFamilyShareTitle: String {
        switch lang {
        case .korean: return "가족에게 일정을 공유해보세요"
        case .english: return "Share Your Schedule with Family"
        case .japanese: return "家族に予定を共有してみましょう"
        case .chinese: return "与家人共享日程"
        case .german: return "Teile deinen Plan mit der Familie"
        case .french: return "Partagez votre planning en famille"
        }
    }

    static var tipFamilyShareMessage: String {
        switch lang {
        case .korean: return "설정 → 일정 공유에서 초대 링크를 보내면, 가족의 휴가 일정을 가족 탭에서 함께 볼 수 있어요."
        case .english: return "Send an invite from Settings → Share Schedule to see each other's leaves in the Family tab."
        case .japanese: return "設定 → 予定の共有から招待リンクを送ると、家族の休暇予定を「家族」タブで一緒に見られます。"
        case .chinese: return "在设置 → 日程共享中发送邀请链接，即可在\"家人\"标签页中查看彼此的休假日程。"
        case .german: return "Sende unter Einstellungen → Plan teilen eine Einladung, um euren Urlaub im Tab „Familie“ gemeinsam zu sehen."
        case .french: return "Envoyez une invitation via Réglages → Partager le planning pour voir vos congés respectifs dans l'onglet Famille."
        }
    }

    static var tipTimeMachineTitle: String {
        switch lang {
        case .korean: return "타임머신이 지켜드려요"
        case .english: return "Time Machine Has Your Back"
        case .japanese: return "タイムマシンが守ります"
        case .chinese: return "时光机为您保驾护航"
        case .german: return "Die Zeitmaschine sichert dich ab"
        case .french: return "La machine à remonter le temps veille"
        }
    }

    static var tipTimeMachineMessage: String {
        switch lang {
        case .korean: return "데이터가 바뀔 때마다 자동으로 스냅샷이 저장돼요. 실수해도 원하는 시점으로 되돌릴 수 있어요."
        case .english: return "A snapshot is saved automatically whenever your data changes, so you can always roll back."
        case .japanese: return "データが変更されるたびに自動でスナップショットを保存。いつでも元に戻せます。"
        case .chinese: return "每当数据变化时都会自动保存快照，随时可以恢复到任意时间点。"
        case .german: return "Bei jeder Änderung wird automatisch ein Snapshot gespeichert, sodass du jederzeit zurückgehen kannst."
        case .french: return "Un instantané est enregistré à chaque modification de vos données, pour pouvoir toujours revenir en arrière."
        }
    }

    static var tipCalendarTapTitle: String {
        switch lang {
        case .korean: return "날짜를 탭해서 바로 등록"
        case .english: return "Tap a Date to Register"
        case .japanese: return "日付をタップしてすぐ登録"
        case .chinese: return "点按日期即可登记"
        case .german: return "Datum antippen zum Eintragen"
        case .french: return "Touchez une date pour l'ajouter"
        }
    }

    static var tipCalendarTapMessage: String {
        switch lang {
        case .korean: return "캘린더에서 날짜를 선택하면 그 날짜로 휴가를 바로 등록할 수 있어요."
        case .english: return "Select any date on the calendar to register a leave for that day instantly."
        case .japanese: return "カレンダーで日付を選ぶと、その日の休暇をすぐに登録できます。"
        case .chinese: return "在日历上选择日期，即可立即为该日期登记休假。"
        case .german: return "Wähle ein Datum im Kalender, um sofort Urlaub für diesen Tag einzutragen."
        case .french: return "Sélectionnez une date dans le calendrier pour y ajouter un congé instantanément."
        }
    }

    // MARK: - 사진에서 가져오기

    static var importFromPhoto: String {
        switch lang {
        case .korean: return "사진에서 가져오기"
        case .english: return "Import from Photo"
        case .japanese: return "写真から取り込む"
        case .chinese: return "从照片导入"
        case .german: return "Aus Foto importieren"
        case .french: return "Importer depuis une photo"
        }
    }

    static var importFromPhotoDescription: String {
        switch lang {
        case .korean: return "휴가 신청 내역 화면을 찍으면 자동으로 인식해요"
        case .english: return "Snap your leave request history to import it automatically"
        case .japanese: return "休暇申請履歴の画面を撮影すると自動で認識します"
        case .chinese: return "拍摄休假申请记录页面即可自动识别"
        case .german: return "Fotografiere deine Urlaubsübersicht für den automatischen Import"
        case .french: return "Photographiez votre historique de congés pour l'importer automatiquement"
        }
    }

    static var photoImportGuide: String {
        switch lang {
        case .korean: return "회사 시스템의 휴가 신청 내역 화면을 촬영하거나 스크린샷을 선택하세요.\n날짜·유형·차감 일수를 자동으로 인식합니다."
        case .english: return "Take a photo or choose a screenshot of your company's leave request history.\nDates, types, and deductions are recognized automatically."
        case .japanese: return "会社システムの休暇申請履歴画面を撮影するか、スクリーンショットを選択してください。\n日付・種類・控除日数を自動で認識します。"
        case .chinese: return "拍摄或选择公司系统的休假申请记录截图。\n将自动识别日期、类型和扣除天数。"
        case .german: return "Fotografiere die Urlaubsübersicht deiner Firma oder wähle einen Screenshot.\nDaten, Arten und abgezogene Tage werden automatisch erkannt."
        case .french: return "Prenez en photo l'historique de congés de votre entreprise ou choisissez une capture d'écran.\nLes dates, types et jours déduits sont reconnus automatiquement."
        }
    }

    static var takePhoto: String {
        switch lang {
        case .korean: return "카메라로 촬영"
        case .english: return "Take Photo"
        case .japanese: return "カメラで撮影"
        case .chinese: return "用相机拍摄"
        case .german: return "Foto aufnehmen"
        case .french: return "Prendre une photo"
        }
    }

    static var choosePhoto: String {
        switch lang {
        case .korean: return "사진 보관함에서 선택"
        case .english: return "Choose from Library"
        case .japanese: return "写真ライブラリから選択"
        case .chinese: return "从相册选择"
        case .german: return "Aus Mediathek wählen"
        case .french: return "Choisir dans la photothèque"
        }
    }

    static var chooseAnotherPhoto: String {
        switch lang {
        case .korean: return "다른 사진 선택"
        case .english: return "Choose Another Photo"
        case .japanese: return "別の写真を選択"
        case .chinese: return "选择其他照片"
        case .german: return "Anderes Foto wählen"
        case .french: return "Choisir une autre photo"
        }
    }

    static var scanningPhoto: String {
        switch lang {
        case .korean: return "사진에서 휴가 내역을 인식하는 중..."
        case .english: return "Recognizing leave records in photo..."
        case .japanese: return "写真から休暇履歴を認識中..."
        case .chinese: return "正在识别照片中的休假记录..."
        case .german: return "Urlaubseinträge im Foto werden erkannt ..."
        case .french: return "Reconnaissance des congés sur la photo..."
        }
    }

    static var noLeaveFoundInPhoto: String {
        switch lang {
        case .korean: return "사진에서 휴가 내역을 찾지 못했습니다.\n표가 선명하게 나오도록 다시 촬영해 주세요."
        case .english: return "No leave records found in the photo.\nPlease retake it so the table is clearly visible."
        case .japanese: return "写真から休暇履歴が見つかりませんでした。\n表が鮮明に写るように撮り直してください。"
        case .chinese: return "未能在照片中找到休假记录。\n请重新拍摄，确保表格清晰可见。"
        case .german: return "Im Foto wurden keine Urlaubseinträge gefunden.\nBitte fotografiere es erneut, sodass die Tabelle gut lesbar ist."
        case .french: return "Aucun congé trouvé sur la photo.\nVeuillez la reprendre en veillant à ce que le tableau soit bien net."
        }
    }

    static func photoImportAllDuplicates(_ count: Int) -> String {
        switch lang {
        case .korean: return "인식된 \(count)건이 모두 이미 등록되어 있어요."
        case .english: return "All \(count) recognized records are already registered."
        case .japanese: return "認識された\(count)件はすべて登録済みです。"
        case .chinese: return "识别出的\(count)条记录均已登记。"
        case .german: return "Alle \(count) erkannten Einträge sind bereits vorhanden."
        case .french: return "Les \(count) entrées reconnues sont déjà enregistrées."
        }
    }

    static func duplicatesExcluded(_ count: Int) -> String {
        switch lang {
        case .korean: return "이미 등록된 \(count)건은 제외했습니다."
        case .english: return "\(count) already-registered records were excluded."
        case .japanese: return "登録済みの\(count)件は除外しました。"
        case .chinese: return "已排除\(count)条已登记的记录。"
        case .german: return "\(count) bereits vorhandene Einträge wurden ausgelassen."
        case .french: return "\(count) entrées déjà enregistrées ont été exclues."
        }
    }

    static var photoImportFooter: String {
        switch lang {
        case .korean: return "실공제수가 없는 대체휴가·자녀돌봄 등은 연차 차감 없이 등록됩니다."
        case .english: return "Records without a deduction (compensatory leave, family care, etc.) are added without reducing your annual leave."
        case .japanese: return "控除のない代替休暇・子育て休暇などは、年休を減らさずに登録されます。"
        case .chinese: return "无扣除天数的调休、育儿假等将在不扣减年假的情况下登记。"
        case .german: return "Einträge ohne Abzug (Freizeitausgleich, Kinderbetreuung usw.) werden ohne Abzug vom Jahresurlaub eingetragen."
        case .french: return "Les entrées sans déduction (récupération, garde d'enfant, etc.) sont ajoutées sans réduire vos congés annuels."
        }
    }

    static var noDeduction: String {
        switch lang {
        case .korean: return "연차 차감 없음"
        case .english: return "No deduction"
        case .japanese: return "年休控除なし"
        case .chinese: return "不扣年假"
        case .german: return "Kein Abzug"
        case .french: return "Aucune déduction"
        }
    }

    static var photoImportInvalidImage: String {
        switch lang {
        case .korean: return "사진을 불러올 수 없습니다."
        case .english: return "Unable to load the photo."
        case .japanese: return "写真を読み込めません。"
        case .chinese: return "无法加载照片。"
        case .german: return "Das Foto konnte nicht geladen werden."
        case .french: return "Impossible de charger la photo."
        }
    }

    // MARK: - 타임머신

    static var timeMachine: String {
        switch lang {
        case .korean: return "타임머신"
        case .english: return "Time Machine"
        case .japanese: return "タイムマシン"
        case .chinese: return "时光机"
        case .german: return "Zeitmaschine"
        case .french: return "Machine à remonter le temps"
        }
    }

    static var timeMachineFooter: String {
        switch lang {
        case .korean: return "데이터가 바뀔 때마다 자동으로 스냅샷이 저장됩니다. 원하는 시점을 선택하면 그때의 데이터로 되돌릴 수 있습니다."
        case .english: return "A snapshot is saved automatically whenever your data changes. Select a point in time to restore your data to that moment."
        case .japanese: return "データが変更されるたびにスナップショットが自動保存されます。時点を選択すると、その時のデータに戻せます。"
        case .chinese: return "每当数据发生变化时都会自动保存快照。选择一个时间点即可将数据恢复到当时的状态。"
        case .german: return "Bei jeder Änderung wird automatisch ein Snapshot gespeichert. Wähle einen Zeitpunkt, um deine Daten auf diesen Stand zurückzusetzen."
        case .french: return "Un instantané est enregistré à chaque modification de vos données. Choisissez un point dans le temps pour restaurer vos données à ce moment."
        }
    }

    static var snapshotNow: String {
        switch lang {
        case .korean: return "지금 스냅샷 만들기"
        case .english: return "Create Snapshot Now"
        case .japanese: return "今すぐスナップショットを作成"
        case .chinese: return "立即创建快照"
        case .german: return "Jetzt Snapshot erstellen"
        case .french: return "Créer un instantané"
        }
    }

    static var snapshotList: String {
        switch lang {
        case .korean: return "저장된 시점"
        case .english: return "Saved Points"
        case .japanese: return "保存された時点"
        case .chinese: return "已保存的时间点"
        case .german: return "Gespeicherte Zeitpunkte"
        case .french: return "Points enregistrés"
        }
    }

    static var noSnapshots: String {
        switch lang {
        case .korean: return "저장된 스냅샷이 없습니다"
        case .english: return "No snapshots saved yet"
        case .japanese: return "保存されたスナップショットはありません"
        case .chinese: return "尚无已保存的快照"
        case .german: return "Noch keine Snapshots gespeichert"
        case .french: return "Aucun instantané enregistré"
        }
    }

    static var restoreSnapshotTitle: String {
        switch lang {
        case .korean: return "이 시점으로 복원"
        case .english: return "Restore This Point"
        case .japanese: return "この時点に復元"
        case .chinese: return "恢复到此时间点"
        case .german: return "Diesen Zeitpunkt wiederherstellen"
        case .french: return "Restaurer ce point"
        }
    }

    static func restoreSnapshotMessage(_ date: String) -> String {
        switch lang {
        case .korean: return "\(date) 시점의 데이터로 되돌립니다. 복원 직전 상태도 자동으로 저장되므로 언제든 다시 되돌릴 수 있습니다."
        case .english: return "Your data will be restored to \(date). The current state is saved automatically before restoring, so you can always go back."
        case .japanese: return "\(date) 時点のデータに戻します。復元直前の状態も自動保存されるため、いつでも元に戻せます。"
        case .chinese: return "数据将恢复到 \(date)。恢复前会自动保存当前状态，因此您随时可以撤销。"
        case .german: return "Deine Daten werden auf den Stand vom \(date) zurückgesetzt. Der aktuelle Stand wird vorher automatisch gespeichert, sodass du jederzeit zurückkehren kannst."
        case .french: return "Vos données seront restaurées à l'état du \(date). L'état actuel est enregistré automatiquement avant la restauration, vous pouvez donc toujours revenir en arrière."
        }
    }

    static func snapshotSummary(leaves: Int, bonuses: Int) -> String {
        switch lang {
        case .korean: return "연차 \(leaves)건 · 보너스 \(bonuses)건"
        case .english: return "\(leaves) leaves · \(bonuses) bonuses"
        case .japanese: return "休暇 \(leaves)件 · ボーナス \(bonuses)件"
        case .chinese: return "休假 \(leaves)条 · 奖励 \(bonuses)条"
        case .german: return "\(leaves) Urlaube · \(bonuses) Boni"
        case .french: return "\(leaves) congés · \(bonuses) bonus"
        }
    }

    static var snapshotCreated: String {
        switch lang {
        case .korean: return "스냅샷이 저장되었습니다."
        case .english: return "Snapshot saved."
        case .japanese: return "スナップショットを保存しました。"
        case .chinese: return "快照已保存。"
        case .german: return "Snapshot gespeichert."
        case .french: return "Instantané enregistré."
        }
    }

    static var snapshotFailed: String {
        switch lang {
        case .korean: return "스냅샷 저장에 실패했습니다."
        case .english: return "Failed to save snapshot."
        case .japanese: return "スナップショットの保存に失敗しました。"
        case .chinese: return "快照保存失败。"
        case .german: return "Snapshot konnte nicht gespeichert werden."
        case .french: return "Échec de l'enregistrement de l'instantané."
        }
    }

    static var snapshotChecksumMismatch: String {
        switch lang {
        case .korean: return "스냅샷 데이터 무결성 검증에 실패했습니다."
        case .english: return "Snapshot integrity check failed."
        case .japanese: return "スナップショットの整合性検証に失敗しました。"
        case .chinese: return "快照完整性校验失败。"
        case .german: return "Integritätsprüfung des Snapshots fehlgeschlagen."
        case .french: return "Échec de la vérification d'intégrité de l'instantané."
        }
    }

    static var snapshotReasonAuto: String {
        switch lang {
        case .korean: return "자동"
        case .english: return "Auto"
        case .japanese: return "自動"
        case .chinese: return "自动"
        case .german: return "Automatisch"
        case .french: return "Auto"
        }
    }

    static var snapshotReasonBackground: String {
        switch lang {
        case .korean: return "앱 전환"
        case .english: return "App switch"
        case .japanese: return "アプリ切替"
        case .chinese: return "应用切换"
        case .german: return "App-Wechsel"
        case .french: return "Changement d'app"
        }
    }

    static var snapshotReasonManual: String {
        switch lang {
        case .korean: return "수동"
        case .english: return "Manual"
        case .japanese: return "手動"
        case .chinese: return "手动"
        case .german: return "Manuell"
        case .french: return "Manuel"
        }
    }

    static var snapshotReasonPreRestore: String {
        switch lang {
        case .korean: return "복원 전 저장"
        case .english: return "Pre-restore"
        case .japanese: return "復元前の保存"
        case .chinese: return "恢复前保存"
        case .german: return "Vor Wiederherstellung"
        case .french: return "Avant restauration"
        }
    }

    static var resetData: String {
        switch lang {
        case .korean: return "연차 데이터 초기화"
        case .english: return "Reset Leave Data"
        case .japanese: return "データリセット"
        case .chinese: return "重置数据"
        case .german: return "Urlaubsdaten zurücksetzen"
        case .french: return "Réinitialiser les congés"
        }
    }

    static var resetDataTitle: String {
        switch lang {
        case .korean: return "연차 데이터 초기화"
        case .english: return "Reset Leave Data"
        case .japanese: return "データリセット"
        case .chinese: return "重置数据"
        case .german: return "Urlaubsdaten zurücksetzen"
        case .french: return "Réinitialiser les congés"
        }
    }

    static var resetDataMessage: String {
        switch lang {
        case .korean: return "모든 연차 기록이 삭제되고 사용한 연차가 0으로 초기화됩니다. 이 작업은 되돌릴 수 없습니다."
        case .english: return "All leave records will be deleted and used leave will be reset to 0. This cannot be undone."
        case .japanese: return "すべての休暇記録が削除され、使用済み休暇が0にリセットされます。この操作は元に戻せません。"
        case .chinese: return "所有休假记录将被删除，已使用年假将重置为0。此操作无法撤销。"
        case .german: return "Alle Urlaubseinträge werden gelöscht und der genommene Urlaub wird auf 0 gesetzt. Das lässt sich nicht rückgängig machen."
        case .french: return "Tous les congés seront supprimés et les congés pris remis à 0. Cette action est irréversible."
        }
    }

    static var reset: String {
        switch lang {
        case .korean: return "초기화"
        case .english: return "Reset"
        case .japanese: return "リセット"
        case .chinese: return "重置"
        case .german: return "Zurücksetzen"
        case .french: return "Réinitialiser"
        }
    }

    // MARK: - 사용법 튜토리얼 · 도움말

    /// 설정 > 도움말 · 온보딩 직후 1회 노출되는 사용법 시트
    static var tutorialTitle: String {
        switch lang {
        case .korean: return "골드위크 사용법"
        case .english: return "How to Use Goldweek"
        case .japanese: return "Goldweekの使い方"
        case .chinese: return "Goldweek 使用方法"
        case .german: return "So funktioniert Goldweek"
        case .french: return "Utiliser Goldweek"
        }
    }

    static var tutorialDone: String {
        switch lang {
        case .korean: return "시작하기"
        case .english: return "Get Started"
        case .japanese: return "はじめる"
        case .chinese: return "开始使用"
        case .german: return "Los geht's"
        case .french: return "Commencer"
        }
    }

    static var tutorialSkip: String {
        switch lang {
        case .korean: return "건너뛰기"
        case .english: return "Skip"
        case .japanese: return "スキップ"
        case .chinese: return "跳过"
        case .german: return "Überspringen"
        case .french: return "Passer"
        }
    }

    static var tutorialAddTitle: String {
        switch lang {
        case .korean: return "휴가는 이렇게 등록해요"
        case .english: return "Adding a Leave"
        case .japanese: return "休暇の登録"
        case .chinese: return "登记休假"
        case .german: return "Urlaub eintragen"
        case .french: return "Ajouter un congé"
        }
    }

    static var tutorialAddMessage: String {
        switch lang {
        case .korean: return "홈의 + 버튼이나 캘린더에서 날짜를 눌러 등록하세요. 반차·반반차는 길이만 골라 주면 돼요."
        case .english: return "Tap + on the home card, or pick a date on the calendar. For half days, just choose the length."
        case .japanese: return "ホームの＋、またはカレンダーで日付をタップ。半休は長さを選ぶだけです。"
        case .chinese: return "点击主页的 +，或在日历上选择日期。半天假只需选择时长。"
        case .german: return "Tippe auf der Startkarte auf + oder wähle ein Datum im Kalender. Für halbe Tage wählst du einfach die Länge."
        case .french: return "Touchez + sur la carte d'accueil ou choisissez une date dans le calendrier. Pour une demi-journée, choisissez simplement la durée."
        }
    }

    static var tutorialPhotoTitle: String {
        switch lang {
        case .korean: return "사진 한 장이면 끝"
        case .english: return "One Photo Is Enough"
        case .japanese: return "写真1枚でOK"
        case .chinese: return "一张照片就够了"
        case .german: return "Ein Foto genügt"
        case .french: return "Une photo suffit"
        }
    }

    static var tutorialPhotoMessage: String {
        switch lang {
        case .korean: return "회사 시스템의 휴가 내역을 찍으면 날짜와 종류를 알아서 읽어 등록해요."
        case .english: return "Snap your company's leave history and the dates and types are read for you."
        case .japanese: return "社内システムの休暇履歴を撮ると、日付と種類を読み取って登録します。"
        case .chinese: return "拍下公司系统的休假记录，应用会自动读取日期与类型。"
        case .german: return "Fotografiere die Urlaubsübersicht deiner Firma, und Daten und Arten werden automatisch gelesen."
        case .french: return "Photographiez l'historique de congés de votre entreprise : les dates et types sont lus pour vous."
        }
    }

    static var tutorialRecommendTitle: String {
        switch lang {
        case .korean: return "연차 1일로 며칠 쉴까"
        case .english: return "Stretch One Day Off"
        case .japanese: return "有給1日で何日休む"
        case .chinese: return "用1天年假休几天"
        case .german: return "Mit einem Tag mehr frei"
        case .french: return "Un jour pour plus de repos"
        }
    }

    static var tutorialRecommendMessage: String {
        switch lang {
        case .korean: return "캘린더의 노란 표시는 공휴일에 연차를 붙여 만든 연휴예요. 눌러서 그대로 등록하세요."
        case .english: return "Yellow marks on the calendar are breaks built by attaching leave to holidays. Tap to add one."
        case .japanese: return "カレンダーの黄色は祝日に有給をつなげた連休です。タップでそのまま登録できます。"
        case .chinese: return "日历上的黄色标记是把年假接在节假日上的连休。点击即可直接登记。"
        case .german: return "Gelbe Markierungen im Kalender sind Auszeiten, bei denen Urlaub an Feiertage anschließt. Tippe darauf, um sie einzutragen."
        case .french: return "Les repères jaunes du calendrier sont des pauses créées en accolant des congés aux jours fériés. Touchez-en un pour l'ajouter."
        }
    }

    static var tutorialBonusTitle: String {
        switch lang {
        case .korean: return "대체휴무는 따로 관리"
        case .english: return "Bonus Leave Stays Separate"
        case .japanese: return "代休は別で管理"
        case .chinese: return "补休单独管理"
        case .german: return "Bonusurlaub bleibt separat"
        case .french: return "Les congés bonus restent à part"
        }
    }

    static var tutorialBonusMessage: String {
        switch lang {
        case .korean: return "보너스 연차로 등록하면 연차를 깎지 않고 따로 세요. 만료일도 함께 챙겨 줘요."
        case .english: return "Logged as bonus leave, it never eats into your annual days — and expiry dates are tracked."
        case .japanese: return "ボーナス休暇として登録すれば有給を減らさず別に管理され、有効期限も追えます。"
        case .chinese: return "登记为奖励假后不会占用年假，并会一并跟踪有效期。"
        case .german: return "Als Bonusurlaub eingetragen, geht er nie von deinen Urlaubstagen ab – Ablaufdaten werden mitverfolgt."
        case .french: return "Enregistrés comme congés bonus, ils ne réduisent jamais vos congés annuels, et les dates d'expiration sont suivies."
        }
    }

    static var tutorialShareTitle: String {
        switch lang {
        case .korean: return "가족과 일정 맞추기"
        case .english: return "Line Up with Family"
        case .japanese: return "家族と予定を合わせる"
        case .chinese: return "与家人对好行程"
        case .german: return "Pläne mit der Familie abstimmen"
        case .french: return "Se coordonner en famille"
        }
    }

    static var tutorialShareMessage: String {
        switch lang {
        case .korean: return "일정을 공유하면 가족 탭에서 서로의 휴가를 한눈에 볼 수 있어요."
        case .english: return "Share your schedule and see each other's time off in the Family tab."
        case .japanese: return "予定を共有すると、家族タブでお互いの休暇を一覧できます。"
        case .chinese: return "共享日程后，可在家庭标签中一览彼此的假期。"
        case .german: return "Teile deinen Plan und sieh im Tab „Familie“ den Urlaub der anderen auf einen Blick."
        case .french: return "Partagez votre planning et voyez les congés de chacun dans l'onglet Famille."
        }
    }

    static var tutorialWidgetTitle: String {
        switch lang {
        case .korean: return "홈 화면에서 바로 확인"
        case .english: return "Right on Your Home Screen"
        case .japanese: return "ホーム画面でひと目"
        case .chinese: return "在主屏幕上一眼看到"
        case .german: return "Direkt auf dem Home-Bildschirm"
        case .french: return "Directement sur l'écran d'accueil"
        }
    }

    static var tutorialWidgetMessage: String {
        switch lang {
        case .korean: return "위젯을 추가하면 남은 연차와 다음 휴가가 잠금화면에서도 보여요. 기록은 iCloud로 백업돼요."
        case .english: return "Add a widget to see remaining leave and your next break, even on the Lock Screen. Records back up to iCloud."
        case .japanese: return "ウィジェットを追加すると、残りの有給と次の休暇をロック画面でも確認できます。記録はiCloudにバックアップされます。"
        case .chinese: return "添加小组件后，在锁定屏幕也能看到剩余年假和下次休假。记录会备份到 iCloud。"
        case .german: return "Mit einem Widget siehst du Resturlaub und deine nächste Auszeit, auch auf dem Sperrbildschirm. Einträge werden in iCloud gesichert."
        case .french: return "Ajoutez un widget pour voir vos congés restants et votre prochaine pause, même sur l'écran verrouillé. Les données sont sauvegardées sur iCloud."
        }
    }

    static var helpSection: String {
        switch lang {
        case .korean: return "도움말"
        case .english: return "Help"
        case .japanese: return "ヘルプ"
        case .chinese: return "帮助"
        case .german: return "Hilfe"
        case .french: return "Aide"
        }
    }

    static var helpTutorial: String {
        switch lang {
        case .korean: return "사용법 다시 보기"
        case .english: return "How to Use Goldweek"
        case .japanese: return "使い方をもう一度見る"
        case .chinese: return "重看使用方法"
        case .german: return "So funktioniert Goldweek"
        case .french: return "Utiliser Goldweek"
        }
    }

    static var helpOnboarding: String {
        switch lang {
        case .korean: return "처음 안내 다시 보기"
        case .english: return "Replay Intro"
        case .japanese: return "初回案内をもう一度"
        case .chinese: return "重看初次引导"
        case .german: return "Einführung erneut ansehen"
        case .french: return "Revoir l'introduction"
        }
    }

    static var helpResetTips: String {
        switch lang {
        case .korean: return "기능 팁 다시 보기"
        case .english: return "Show Feature Tips Again"
        case .japanese: return "機能のヒントを再表示"
        case .chinese: return "重新显示功能提示"
        case .german: return "Funktionstipps erneut anzeigen"
        case .french: return "Réafficher les astuces"
        }
    }

    static var helpResetTipsDone: String {
        switch lang {
        case .korean: return "앱을 다시 실행하면 기능 팁이 처음부터 다시 나타나요."
        case .english: return "Feature tips will appear again the next time you open the app."
        case .japanese: return "アプリを開き直すと、機能のヒントが最初から表示されます。"
        case .chinese: return "下次打开应用时，功能提示会重新出现。"
        case .german: return "Die Funktionstipps erscheinen beim nächsten Öffnen der App erneut."
        case .french: return "Les astuces réapparaîtront à la prochaine ouverture de l'app."
        }
    }

    static var tipRecommendTitle: String {
        switch lang {
        case .korean: return "추천 연휴를 눌러 보세요"
        case .english: return "Tap a Suggested Break"
        case .japanese: return "おすすめの連休をタップ"
        case .chinese: return "点点推荐的连休"
        case .german: return "Tippe auf eine empfohlene Auszeit"
        case .french: return "Touchez une pause suggérée"
        }
    }

    static var tipRecommendMessage: String {
        switch lang {
        case .korean: return "노란 표시는 연차를 조금 써서 만든 연휴예요. 눌러 바로 등록할 수 있어요."
        case .english: return "Yellow marks are breaks made with just a day or two of leave. Tap to add one."
        case .japanese: return "黄色の印は少ない有給で作った連休です。タップして登録できます。"
        case .chinese: return "黄色标记是只用一两天年假拼出的连休，点击即可登记。"
        case .german: return "Gelbe Markierungen sind Auszeiten mit nur ein oder zwei Urlaubstagen. Tippe darauf, um sie einzutragen."
        case .french: return "Les repères jaunes sont des pauses créées avec seulement un ou deux jours de congé. Touchez-en un pour l'ajouter."
        }
    }

    static var tipSharePlanTitle: String {
        switch lang {
        case .korean: return "연차 현황을 이미지로"
        case .english: return "Share Your Leave Status"
        case .japanese: return "有給の状況を画像で"
        case .chinese: return "把年假状况变成图片"
        case .german: return "Urlaubsstand teilen"
        case .french: return "Partager votre situation de congés"
        }
    }

    static var tipSharePlanMessage: String {
        switch lang {
        case .korean: return "공유 버튼을 누르면 카드 이미지를 만들어 친구·가족에게 보낼 수 있어요."
        case .english: return "Tap share to turn your status into a card you can send to family or friends."
        case .japanese: return "共有ボタンでカード画像を作り、家族や友人に送れます。"
        case .chinese: return "点击分享，即可生成卡片图片发给家人或朋友。"
        case .german: return "Tippe auf Teilen, um aus deinem Stand eine Karte für Familie oder Freunde zu erstellen."
        case .french: return "Touchez Partager pour créer une carte de votre situation à envoyer à votre famille ou vos amis."
        }
    }

    static var tipBonusLeaveTitle: String {
        switch lang {
        case .korean: return "대체휴무·포상휴가는 여기"
        case .english: return "Bonus Leave Goes Here"
        case .japanese: return "代休・特別休暇はこちら"
        case .chinese: return "补休和奖励假在这里"
        case .german: return "Bonusurlaub kommt hierher"
        case .french: return "Les congés bonus, c'est ici"
        }
    }

    static var tipBonusLeaveMessage: String {
        switch lang {
        case .korean: return "보너스 연차로 등록하면 연차와 따로 관리되고 만료일도 챙겨 줘요."
        case .english: return "Add it as bonus leave — it's tracked separately from annual days, expiry included."
        case .japanese: return "ボーナス休暇として登録すると有給とは別に管理され、期限も追えます。"
        case .chinese: return "登记为奖励假后与年假分开管理，并会跟踪有效期。"
        case .german: return "Trage ihn als Bonusurlaub ein – er wird getrennt von den Urlaubstagen verwaltet, samt Ablaufdatum."
        case .french: return "Ajoutez-les comme congés bonus : ils sont suivis séparément des congés annuels, échéance comprise."
        }
    }

    static var tipLeaveHistoryTitle: String {
        switch lang {
        case .korean: return "지난 휴가 돌아보기"
        case .english: return "Look Back at Your Leave"
        case .japanese: return "これまでの休暇をふり返る"
        case .chinese: return "回顾过往假期"
        case .german: return "Rückblick auf deinen Urlaub"
        case .french: return "Revoir vos congés passés"
        }
    }

    static var tipLeaveHistoryMessage: String {
        switch lang {
        case .korean: return "연도별로 얼마나 썼는지, 어떤 휴가를 썼는지 한 번에 볼 수 있어요."
        case .english: return "See how much you used each year, and which kinds of leave they were."
        case .japanese: return "年ごとの使用日数と休暇の種類をまとめて確認できます。"
        case .chinese: return "可以按年份查看用了多少天、用的是哪类假期。"
        case .german: return "Sieh, wie viel du pro Jahr genommen hast und welche Urlaubsarten es waren."
        case .french: return "Voyez combien vous en avez pris chaque année, et de quel type."
        }
    }

    static var appInfo: String {
        switch lang {
        case .korean: return "앱 정보"
        case .english: return "App Info"
        case .japanese: return "アプリ情報"
        case .chinese: return "应用信息"
        case .german: return "App-Info"
        case .french: return "Infos sur l'app"
        }
    }

    /// 설정 > 지원 섹션 (피드백·리뷰·법적 링크·버전).
    static var supportSection: String {
        switch lang {
        case .korean: return "지원"
        case .english: return "Support"
        case .japanese: return "サポート"
        case .chinese: return "支持"
        case .german: return "Support"
        case .french: return "Assistance"
        }
    }

    static var sendFeedback: String {
        switch lang {
        case .korean: return "피드백 보내기"
        case .english: return "Send Feedback"
        case .japanese: return "フィードバックを送る"
        case .chinese: return "发送反馈"
        case .german: return "Feedback senden"
        case .french: return "Envoyer un avis"
        }
    }

    static var supportPage: String {
        switch lang {
        case .korean: return "지원 페이지"
        case .english: return "Support Page"
        case .japanese: return "サポートページ"
        case .chinese: return "支持页面"
        case .german: return "Support-Seite"
        case .french: return "Page d'assistance"
        }
    }

    /// 마스터 모드에서만 보이는 개발자 행들.
    /// 화면 안쪽은 개발자용이라 번역하지 않지만, **설정 목록에 한국어가 섞여 보이면 안 되므로**
    /// 행 이름은 다른 행들과 같은 언어를 따른다.
    static var devFeedbackInbox: String {
        switch lang {
        case .korean: return "접수된 피드백 (개발자)"
        case .english: return "Feedback Inbox (Developer)"
        case .japanese: return "受信フィードバック（開発者）"
        case .chinese: return "收到的反馈（开发者）"
        case .german: return "Feedback-Eingang (Entwickler)"
        case .french: return "Boîte des retours (développeur)"
        }
    }

    static var devUsageStats: String {
        switch lang {
        case .korean: return "사용 통계 (개발자)"
        case .english: return "Usage Stats (Developer)"
        case .japanese: return "利用統計（開発者）"
        case .chinese: return "使用统计（开发者）"
        case .german: return "Nutzungsstatistik (Entwickler)"
        case .french: return "Statistiques d'utilisation (dév.)"
        }
    }

    static var devCrashReports: String {
        switch lang {
        case .korean: return "안정성 (개발자)"
        case .english: return "Stability (Developer)"
        case .japanese: return "安定性（開発者）"
        case .chinese: return "稳定性（开发者）"
        case .german: return "Stabilität (Entwickler)"
        case .french: return "Stabilité (dév.)"
        }
    }

    static var version: String {
        switch lang {
        case .korean: return "버전"
        case .english: return "Version"
        case .japanese: return "バージョン"
        case .chinese: return "版本"
        case .german: return "Version"
        case .french: return "Version"
        }
    }

    static var developer: String {
        switch lang {
        case .korean: return "개발"
        case .english: return "Developer"
        case .japanese: return "開発"
        case .chinese: return "开发者"
        case .german: return "Entwicklung"
        case .french: return "Développeur"
        }
    }

    static var rateApp: String {
        switch lang {
        case .korean: return "앱 평가하기"
        case .english: return "Rate This App"
        case .japanese: return "アプリを評価"
        case .chinese: return "评价应用"
        case .german: return "App bewerten"
        case .french: return "Noter l'app"
        }
    }

    static var contactDeveloperSection: String {
        switch lang {
        case .korean: return "개발자에게 문의"
        case .english: return "Contact the Developer"
        case .japanese: return "開発者に問い合わせ"
        case .chinese: return "联系开发者"
        case .german: return "Entwickler kontaktieren"
        case .french: return "Contacter le développeur"
        }
    }

    static var contactByEmail: String {
        switch lang {
        case .korean: return "이메일로 문의하기"
        case .english: return "Contact via Email"
        case .japanese: return "メールで問い合わせ"
        case .chinese: return "通过邮件联系"
        case .german: return "Per E-Mail kontaktieren"
        case .french: return "Contacter par e-mail"
        }
    }

    static var contactByInstagram: String {
        switch lang {
        case .korean: return "인스타그램 DM (@lee25_ios)"
        case .english: return "Instagram DM (@lee25_ios)"
        case .japanese: return "Instagram DM (@lee25_ios)"
        case .chinese: return "Instagram 私信 (@lee25_ios)"
        case .german: return "Instagram-DM (@lee25_ios)"
        case .french: return "DM Instagram (@lee25_ios)"
        }
    }

    static var contactDeveloperFooter: String {
        switch lang {
        case .korean: return "버그 제보와 기능 제안을 환영합니다."
        case .english: return "Bug reports and feature suggestions are welcome."
        case .japanese: return "バグ報告や機能提案を歓迎します。"
        case .chinese: return "欢迎反馈问题和提出功能建议。"
        case .german: return "Fehlerberichte und Funktionsvorschläge sind willkommen."
        case .french: return "Signalements de bugs et suggestions bienvenus."
        }
    }

    static var confirm: String {
        switch lang {
        case .korean: return "확인"
        case .english: return "OK"
        case .japanese: return "確認"
        case .chinese: return "确认"
        case .german: return "OK"
        case .french: return "OK"
        }
    }

    static var backup: String {
        switch lang {
        case .korean: return "백업"
        case .english: return "Backup"
        case .japanese: return "バックアップ"
        case .chinese: return "备份"
        case .german: return "Backup"
        case .french: return "Sauvegarde"
        }
    }

    static var restoreConfirmTitle: String {
        switch lang {
        case .korean: return "복원 확인"
        case .english: return "Confirm Restore"
        case .japanese: return "復元の確認"
        case .chinese: return "确认恢复"
        case .german: return "Wiederherstellung bestätigen"
        case .french: return "Confirmer la restauration"
        }
    }

    static var restore: String {
        switch lang {
        case .korean: return "복원"
        case .english: return "Restore"
        case .japanese: return "復元"
        case .chinese: return "恢复"
        case .german: return "Wiederherstellen"
        case .french: return "Restaurer"
        }
    }

    static var restoreConfirmMessage: String {
        switch lang {
        case .korean: return "iCloud 백업에서 데이터를 복원합니다. 현재 데이터는 모두 삭제됩니다."
        case .english: return "Restore data from iCloud backup. All current data will be deleted."
        case .japanese: return "iCloudバックアップからデータを復元します。現在のデータはすべて削除されます。"
        case .chinese: return "从iCloud备份恢复数据。当前所有数据将被删除。"
        case .german: return "Daten aus dem iCloud-Backup wiederherstellen. Alle aktuellen Daten werden gelöscht."
        case .french: return "Restaurer les données depuis la sauvegarde iCloud. Toutes les données actuelles seront supprimées."
        }
    }

    static func lastBackup(_ dateStr: String) -> String {
        switch lang {
        case .korean: return "마지막 백업: \(dateStr)"
        case .english: return "Last backup: \(dateStr)"
        case .japanese: return "最終バックアップ: \(dateStr)"
        case .chinese: return "上次备份: \(dateStr)"
        case .german: return "Letztes Backup: \(dateStr)"
        case .french: return "Dernière sauvegarde : \(dateStr)"
        }
    }

    // MARK: - 선호도 설정
    static var navTitlePreferences: String {
        switch lang {
        case .korean: return "나의 휴가 스타일"
        case .english: return "My Vacation Style"
        case .japanese: return "休暇スタイル"
        case .chinese: return "我的休假风格"
        case .german: return "Mein Urlaubsstil"
        case .french: return "Mon style de congés"
        }
    }

    static var preferredDurationSection: String {
        switch lang {
        case .korean: return "선호하는 휴가 길이"
        case .english: return "Preferred Duration"
        case .japanese: return "好みの休暇期間"
        case .chinese: return "偏好休假时长"
        case .german: return "Bevorzugte Dauer"
        case .french: return "Durée préférée"
        }
    }

    static var preferredSeasonSection: String {
        switch lang {
        case .korean: return "선호하는 계절 (복수 선택)"
        case .english: return "Preferred Season (Multiple)"
        case .japanese: return "好みの季節（複数選択）"
        case .chinese: return "偏好季节（可多选）"
        case .german: return "Bevorzugte Jahreszeit (Mehrfachauswahl)"
        case .french: return "Saison préférée (choix multiple)"
        }
    }

    static var vacationStyleSection: String {
        switch lang {
        case .korean: return "휴가 스타일"
        case .english: return "Vacation Style"
        case .japanese: return "休暇スタイル"
        case .chinese: return "休假风格"
        case .german: return "Urlaubsstil"
        case .french: return "Style de congés"
        }
    }

    static var useBridgeDays: String {
        switch lang {
        case .korean: return "징검다리 휴일 활용"
        case .english: return "Use Bridge Days"
        case .japanese: return "飛び石連休の活用"
        case .chinese: return "利用桥接假日"
        case .german: return "Brückentage nutzen"
        case .french: return "Utiliser les ponts"
        }
    }

    static var preferConsecutive: String {
        switch lang {
        case .korean: return "연속 휴가 선호"
        case .english: return "Prefer Consecutive"
        case .japanese: return "連続休暇を好む"
        case .chinese: return "偏好连续休假"
        case .german: return "Zusammenhängenden Urlaub bevorzugen"
        case .french: return "Privilégier les congés consécutifs"
        }
    }

    static var avoidPeakSeason: String {
        switch lang {
        case .korean: return "성수기 회피"
        case .english: return "Avoid Peak Season"
        case .japanese: return "ピークシーズン回避"
        case .chinese: return "避开旺季"
        case .german: return "Hauptsaison meiden"
        case .french: return "Éviter la haute saison"
        }
    }

    static var preferredActivitySection: String {
        switch lang {
        case .korean: return "주로 하고 싶은 활동"
        case .english: return "Preferred Activities"
        case .japanese: return "したい活動"
        case .chinese: return "想做的活动"
        case .german: return "Bevorzugte Aktivitäten"
        case .french: return "Activités préférées"
        }
    }

    static var save: String {
        switch lang {
        case .korean: return "저장"
        case .english: return "Save"
        case .japanese: return "保存"
        case .chinese: return "保存"
        case .german: return "Sichern"
        case .french: return "Enregistrer"
        }
    }

    // MARK: - 온보딩
    static var appName: String {
        switch lang {
        case .korean: return "골드위크"
        case .english: return "Goldweek"
        case .japanese: return "ゴールドウィーク"
        case .chinese: return "Goldweek"
        case .german: return "Goldweek"
        case .french: return "Goldweek"
        }
    }

    static var onboardingSubtitle: String {
        switch lang {
        case .korean: return "최소 연차로 최대 연휴를\n공휴일을 활용한 황금연휴 플랜"
        case .english: return "Maximum days off with minimum PTO\nAI plans your perfect long weekend"
        case .japanese: return "最少の有給で最大の連休を\n祝日を活かしたゴールデンプラン"
        case .chinese: return "最少年假，最长假期\n善用节假日的黄金组合"
        case .german: return "Maximale freie Tage mit minimalem Urlaub\nKI plant dein perfektes langes Wochenende"
        case .french: return "Un maximum de jours off avec un minimum de congés\nL'IA planifie votre week-end prolongé idéal"
        }
    }

    static var onboardingValueTitle: String {
        switch lang {
        case .korean: return "3일 연차로\n9일 연휴"
        case .english: return "3 PTO days\n9 days off"
        case .japanese: return "3日の有給で\n9日の連休"
        case .chinese: return "3天年假\n9天假期"
        case .german: return "3 Urlaubstage\n9 Tage frei"
        case .french: return "3 jours de congé\n9 jours off"
        }
    }

    static var onboardingValueDesc: String {
        switch lang {
        case .korean: return "공휴일과 주말 사이 징검다리를 자동으로 찾아드려요"
        case .english: return "We automatically find the bridge days between holidays and weekends"
        case .japanese: return "祝日と週末の間にある飛び石を自動で見つけます"
        case .chinese: return "自动找出节假日与周末之间的搭桥日"
        case .german: return "Wir finden automatisch die Brückentage zwischen Feiertagen und Wochenenden"
        case .french: return "Nous trouvons automatiquement les ponts entre jours fériés et week-ends"
        }
    }

    static var onboardingValueLegendLeave: String {
        switch lang {
        case .korean: return "연차"
        case .english: return "PTO"
        case .japanese: return "有給"
        case .chinese: return "年假"
        case .german: return "Urlaub"
        case .french: return "Congé"
        }
    }

    static var onboardingValueLegendHoliday: String {
        switch lang {
        case .korean: return "공휴일"
        case .english: return "Holiday"
        case .japanese: return "祝日"
        case .chinese: return "假日"
        case .german: return "Feiertag"
        case .french: return "Jour férié"
        }
    }

    static var onboardingValueLegendWeekend: String {
        switch lang {
        case .korean: return "주말"
        case .english: return "Weekend"
        case .japanese: return "週末"
        case .chinese: return "周末"
        case .german: return "Wochenende"
        case .french: return "Week-end"
        }
    }

    static var onboardingNameOptional: String {
        switch lang {
        case .korean: return "선택"
        case .english: return "Optional"
        case .japanese: return "任意"
        case .chinese: return "选填"
        case .german: return "Optional"
        case .french: return "Facultatif"
        }
    }

    static var onboardingHeroBadge: String {
        switch lang {
        case .korean: return "황금연휴 플래너"
        case .english: return "Long weekend planner"
        case .japanese: return "黄金連休プランナー"
        case .chinese: return "黄金假期规划"
        case .german: return "Planer für lange Wochenenden"
        case .french: return "Planificateur de longs week-ends"
        }
    }

    static var getStarted: String {
        switch lang {
        case .korean: return "시작하기"
        case .english: return "Get Started"
        case .japanese: return "始める"
        case .chinese: return "开始"
        case .german: return "Los geht's"
        case .french: return "Commencer"
        }
    }

    static var next: String {
        switch lang {
        case .korean: return "다음"
        case .english: return "Next"
        case .japanese: return "次へ"
        case .chinese: return "下一步"
        case .german: return "Weiter"
        case .french: return "Suivant"
        }
    }

    static var mainFeatures: String {
        switch lang {
        case .korean: return "주요 기능"
        case .english: return "Key Features"
        case .japanese: return "主な機能"
        case .chinese: return "主要功能"
        case .german: return "Hauptfunktionen"
        case .french: return "Fonctions clés"
        }
    }

    static var featureLeaveManagement: String {
        switch lang {
        case .korean: return "연차 관리"
        case .english: return "Leave Management"
        case .japanese: return "有給管理"
        case .chinese: return "年假管理"
        case .german: return "Urlaubsverwaltung"
        case .french: return "Gestion des congés"
        }
    }

    static var featureLeaveManagementDesc: String {
        switch lang {
        case .korean: return "연차, 반차, 대체휴무 등\n다양한 휴가를 기록하세요"
        case .english: return "Track annual, half-day, and\ncompensatory leave"
        case .japanese: return "有給、半休、代替休暇など\n様々な休暇を記録"
        case .chinese: return "记录年假、半天假、\n补休等各种休假"
        case .german: return "Erfasse Jahresurlaub, halbe Tage und\nFreizeitausgleich"
        case .french: return "Suivez congés payés, demi-journées\net jours de récupération"
        }
    }

    static var featureAIRecommend: String {
        switch lang {
        case .korean: return "AI 추천"
        case .english: return "AI Recommend"
        case .japanese: return "AIおすすめ"
        case .chinese: return "AI推荐"
        case .german: return "KI-Empfehlung"
        case .french: return "Suggestions IA"
        }
    }

    static var featureAIRecommendDesc: String {
        switch lang {
        case .korean: return "공휴일과 주말을 활용한\n최적의 휴가 조합을 추천"
        case .english: return "Optimal leave combos using\nholidays and weekends"
        case .japanese: return "祝日と週末を活用した\n最適な休暇の組み合わせ"
        case .chinese: return "利用节假日和周末\n推荐最佳休假组合"
        case .german: return "Optimale Urlaubskombis mit\nFeiertagen und Wochenenden"
        case .french: return "Combinaisons de congés optimales\navec jours fériés et week-ends"
        }
    }

    static var featureBonusLeave: String {
        switch lang {
        case .korean: return "보너스 연차"
        case .english: return "Bonus Leave"
        case .japanese: return "ボーナス休暇"
        case .chinese: return "奖励年假"
        case .german: return "Bonusurlaub"
        case .french: return "Congés bonus"
        }
    }

    static var featureBonusLeaveDesc: String {
        switch lang {
        case .korean: return "대체휴무, 포상휴가 등\n추가 연차도 관리"
        case .english: return "Manage comp time, rewards\nand extra leave"
        case .japanese: return "代替休暇、報奨休暇など\n追加の有給も管理"
        case .chinese: return "管理补休、奖励假\n等额外年假"
        case .german: return "Verwalte Zeitausgleich, Prämien\nund Zusatzurlaub"
        case .french: return "Gérez récupérations, primes\net congés supplémentaires"
        }
    }

    static var featureWidget: String {
        switch lang {
        case .korean: return "위젯"
        case .english: return "Widget"
        case .japanese: return "ウィジェット"
        case .chinese: return "小组件"
        case .german: return "Widget"
        case .french: return "Widget"
        }
    }

    static var featureWidgetDesc: String {
        switch lang {
        case .korean: return "홈 화면에서 바로\n남은 연차 확인"
        case .english: return "Check remaining leave\nright from home screen"
        case .japanese: return "ホーム画面から\n残り有給を確認"
        case .chinese: return "在主屏幕上\n直接查看剩余年假"
        case .german: return "Resturlaub direkt\nauf dem Home-Bildschirm"
        case .french: return "Congés restants directement\nsur l'écran d'accueil"
        }
    }

    static var selectCountry: String {
        switch lang {
        case .korean: return "국가를 선택하세요"
        case .english: return "Select your country"
        case .japanese: return "国を選んでください"
        case .chinese: return "选择您的国家"
        case .german: return "Wähle dein Land"
        case .french: return "Choisissez votre pays"
        }
    }

    static var selectCountryDesc: String {
        switch lang {
        case .korean: return "공휴일 데이터가 국가에 맞게 설정됩니다"
        case .english: return "Holiday data will be set for your country"
        case .japanese: return "祝日データが国に合わせて設定されます"
        case .chinese: return "节假日数据将根据您的国家设置"
        case .german: return "Die Feiertage werden an dein Land angepasst"
        case .french: return "Les jours fériés seront adaptés à votre pays"
        }
    }

    static var enterName: String {
        switch lang {
        case .korean: return "이름을 알려주세요"
        case .english: return "What's your name?"
        case .japanese: return "お名前を教えてください"
        case .chinese: return "请输入您的姓名"
        case .german: return "Wie heißt du?"
        case .french: return "Comment vous appelez-vous ?"
        }
    }

    static var enterNameDesc: String {
        switch lang {
        case .korean: return "앱에서 사용할 이름을 입력해주세요"
        case .english: return "Enter the name to use in the app"
        case .japanese: return "アプリで使う名前を入力してください"
        case .chinese: return "请输入在应用中使用的姓名"
        case .german: return "Gib den Namen ein, der in der App verwendet wird"
        case .french: return "Saisissez le nom à utiliser dans l'app"
        }
    }

    static var leaveSetup: String {
        switch lang {
        case .korean: return "연차 정보 설정"
        case .english: return "Leave Setup"
        case .japanese: return "有給設定"
        case .chinese: return "年假设置"
        case .german: return "Urlaub einrichten"
        case .french: return "Configuration des congés"
        }
    }

    static var leaveSetupDesc: String {
        switch lang {
        case .korean: return "나중에 설정에서 변경할 수 있어요"
        case .english: return "You can change this later in settings"
        case .japanese: return "後で設定で変更できます"
        case .chinese: return "稍后可在设置中更改"
        case .german: return "Du kannst das später in den Einstellungen ändern"
        case .french: return "Vous pourrez modifier cela plus tard dans les réglages"
        }
    }

    static var totalAnnualLeave: String {
        switch lang {
        case .korean: return "올해 총 연차"
        case .english: return "Total Annual Leave"
        case .japanese: return "今年の有給合計"
        case .chinese: return "今年总年假"
        case .german: return "Jahresurlaub gesamt"
        case .french: return "Total des congés annuels"
        }
    }

    static var yearStartMonthLabel: String {
        switch lang {
        case .korean: return "연차 기준월"
        case .english: return "Year Start Month"
        case .japanese: return "基準月"
        case .chinese: return "年假起始月"
        case .german: return "Startmonat des Urlaubsjahrs"
        case .french: return "Mois de début de l'année"
        }
    }

    static var yearStartMonthDesc: String {
        switch lang {
        case .korean: return "연차가 갱신되는 시작 월"
        case .english: return "Month when annual leave renews"
        case .japanese: return "有給が更新される月"
        case .chinese: return "年假更新的月份"
        case .german: return "Monat, in dem der Jahresurlaub erneuert wird"
        case .french: return "Mois de renouvellement des congés annuels"
        }
    }

    static var defaultUser: String {
        switch lang {
        case .korean: return "사용자"
        case .english: return "User"
        case .japanese: return "ユーザー"
        case .chinese: return "用户"
        case .german: return "Nutzer"
        case .french: return "Utilisateur"
        }
    }

    /// 모든 언어의 기본 이름 — "이 이름을 아직 안 바꿨다"를 알아보는 데 쓴다.
    /// 기본 이름은 프로필을 만든 시점의 언어로 저장돼 굳기 때문에, 나중에 언어를 바꾸면
    /// 영어 화면에 "사용자"만 혼자 한국어로 남는다.
    static let defaultUserNames: Set<String> = ["사용자", "User", "ユーザー", "用户"]

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
        case .german:
            switch duration {
            case .short: return "1–2 Tage"
            case .medium: return "3–4 Tage"
            case .long: return "5+ Tage"
            case .mixed: return "Gemischt"
            }
        case .french:
            switch duration {
            case .short: return "1-2 jours"
            case .medium: return "3-4 jours"
            case .long: return "5+ jours"
            case .mixed: return "Mixte"
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
        case .german:
            switch season {
            case .spring: return "Frühling"
            case .summer: return "Sommer"
            case .fall: return "Herbst"
            case .winter: return "Winter"
            }
        case .french:
            switch season {
            case .spring: return "Printemps"
            case .summer: return "Été"
            case .fall: return "Automne"
            case .winter: return "Hiver"
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
        case .german:
            switch activity {
            case .travel: return "Reisen"
            case .rest: return "Erholung"
            case .family: return "Familie"
            case .hobby: return "Hobby"
            case .selfCare: return "Selbstfürsorge"
            }
        case .french:
            switch activity {
            case .travel: return "Voyage"
            case .rest: return "Repos"
            case .family: return "Famille"
            case .hobby: return "Loisirs"
            case .selfCare: return "Bien-être"
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
        case .german:
            switch type {
            case .annual: return "Urlaub"
            case .half: return "Halber Tag"
            case .quarter: return "Viertel Tag"
            case .compensatory: return "Zeitausgleich"
            case .official: return "Freistellung"
            case .sick: return "Krank"
            case .special: return "Sonderurlaub"
            case .businessTrip: return "Dienstreise"
            }
        case .french:
            switch type {
            case .annual: return "Congé payé"
            case .half: return "Demi-journée"
            case .quarter: return "Quart de jour"
            case .compensatory: return "Récup."
            case .official: return "Officiel"
            case .sick: return "Maladie"
            case .special: return "Congé spécial"
            case .businessTrip: return "Déplacement"
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
        case .german:
            switch status {
            case .planned: return "Geplant"
            case .used: return "Genommen"
            case .cancelled: return "Storniert"
            }
        case .french:
            switch status {
            case .planned: return "Prévu"
            case .used: return "Pris"
            case .cancelled: return "Annulé"
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
        case .german:
            switch type {
            case .compensatory: return "Zeitausgleich"
            case .reward: return "Belohnung"
            case .refresh: return "Auszeit"
            case .marriage: return "Hochzeit"
            case .bereavement: return "Trauerfall"
            case .sick: return "Krank"
            case .maternity: return "Mutterschaft"
            case .familyBalance: return "Familie"
            case .official: return "Freistellung"
            case .other: return "Sonstiges"
            }
        case .french:
            switch type {
            case .compensatory: return "Récupération"
            case .reward: return "Récompense"
            case .refresh: return "Ressourcement"
            case .marriage: return "Mariage"
            case .bereavement: return "Deuil"
            case .sick: return "Maladie"
            case .maternity: return "Maternité"
            case .familyBalance: return "Famille"
            case .official: return "Officiel"
            case .other: return "Autre"
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
        case .german: return "Goldene Woche"
        case .french: return "Semaine d'or"
        }
    }

    static var noLeaveRequired: String {
        switch lang {
        case .korean: return "연차없음"
        case .english: return "No Leave"
        case .japanese: return "有給不要"
        case .chinese: return "无需年假"
        case .german: return "Ohne Urlaub"
        case .french: return "Sans congé"
        }
    }

    static var bridgeDay: String {
        switch lang {
        case .korean: return "징검다리"
        case .english: return "Bridge Day"
        case .japanese: return "飛び石"
        case .chinese: return "桥接假"
        case .german: return "Brückentag"
        case .french: return "Pont"
        }
    }

    static var topEfficiency: String {
        switch lang {
        case .korean: return "효율최고"
        case .english: return "Best Value"
        case .japanese: return "最高効率"
        case .chinese: return "最高效率"
        case .german: return "Beste Ausbeute"
        case .french: return "Meilleur rapport"
        }
    }

    static var consecutiveLeave: String {
        switch lang {
        case .korean: return "연속휴가"
        case .english: return "Extended Leave"
        case .japanese: return "連続休暇"
        case .chinese: return "连续休假"
        case .german: return "Langer Urlaub"
        case .french: return "Congé prolongé"
        }
    }

    static var efficient: String {
        switch lang {
        case .korean: return "효율적"
        case .english: return "Efficient"
        case .japanese: return "効率的"
        case .chinese: return "高效"
        case .german: return "Effizient"
        case .french: return "Efficace"
        }
    }

    static var weekendHoliday: String {
        switch lang {
        case .korean: return "주말 연휴"
        case .english: return "Weekend Holiday"
        case .japanese: return "週末休暇"
        case .chinese: return "周末假日"
        case .german: return "Feiertag am Wochenende"
        case .french: return "Férié le week-end"
        }
    }

    static var familyTrip: String {
        switch lang {
        case .korean: return "가족여행"
        case .english: return "Family Trip"
        case .japanese: return "家族旅行"
        case .chinese: return "家庭旅行"
        case .german: return "Familienreise"
        case .french: return "Voyage en famille"
        }
    }

    static var family: String {
        switch lang {
        case .korean: return "가족"
        case .english: return "Family"
        case .japanese: return "家族"
        case .chinese: return "家庭"
        case .german: return "Familie"
        case .french: return "Famille"
        }
    }

    static var majorHoliday: String {
        switch lang {
        case .korean: return "명절연휴"
        case .english: return "Major Holiday"
        case .japanese: return "大型連休"
        case .chinese: return "重大节日"
        case .german: return "Großer Feiertag"
        case .french: return "Grande fête"
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
        case .german:
            switch month {
            case 3, 4, 5: return "Ideal für Frühlingsausflüge."
            case 6, 7, 8: return "Perfekte Sommerferien."
            case 9, 10, 11: return "Genieße die Herbstfarben."
            case 12, 1, 2: return "Entspannung zum Jahreswechsel."
            default: return ""
            }
        case .french:
            switch month {
            case 3, 4, 5: return "Idéal pour les sorties de printemps."
            case 6, 7, 8: return "Parfait pour les vacances d'été."
            case 9, 10, 11: return "Profitez des couleurs d'automne."
            case 12, 1, 2: return "Détente de fin d'année."
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
        case .german: return "\(days)-Tage-Pause"
        case .french: return "\(days) jours de repos"
        }
    }

    static func goldenWeekTitle(holidayName: String) -> String {
        switch lang {
        case .korean: return "\(holidayName) 황금연휴"
        case .english: return "\(holidayName) Golden Week"
        case .japanese: return "\(holidayName) ゴールデンウィーク"
        case .chinese: return "\(holidayName) 黄金周"
        case .german: return "Goldene Woche: \(holidayName)"
        case .french: return "Semaine d'or : \(holidayName)"
        }
    }

    static func holidayBreak(name: String) -> String {
        switch lang {
        case .korean: return "\(name) 연휴"
        case .english: return "\(name) Break"
        case .japanese: return "\(name) 連休"
        case .chinese: return "\(name) 假期"
        case .german: return "\(name)-Pause"
        case .french: return "Congés : \(name)"
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
        case .german: return "\(weekdayStart)–\(weekdayEnd): \(totalDays) freie Tage mit \(holidayDesc), ohne Urlaub!"
        case .french: return "\(weekdayStart)–\(weekdayEnd) : \(totalDays) jours off avec \(holidayDesc), sans congé !"
        }
    }

    static func bridgeDayTitle(holidayName: String) -> String {
        switch lang {
        case .korean: return "\(holidayName) 징검다리 연휴"
        case .english: return "\(holidayName) Bridge Holiday"
        case .japanese: return "\(holidayName) 飛び石連休"
        case .chinese: return "\(holidayName) 桥接假期"
        case .german: return "Brückentage: \(holidayName)"
        case .french: return "Pont : \(holidayName)"
        }
    }

    static func bridgeDayDescMonday(holidayName: String) -> String {
        switch lang {
        case .korean: return "월요일 연차 1일로 4일 연휴! \(holidayName) 앞 월요일을 활용하세요."
        case .english: return "1 day leave on Monday for 4-day weekend! Use Monday before \(holidayName)."
        case .japanese: return "月曜1日の有給で4連休！\(holidayName)前の月曜を活用。"
        case .chinese: return "周一请1天年假获得4天假期！利用\(holidayName)前的周一。"
        case .german: return "1 Urlaubstag am Montag für 4 freie Tage! Nutze den Montag vor \(holidayName)."
        case .french: return "1 jour de congé le lundi pour 4 jours off ! Profitez du lundi avant \(holidayName)."
        }
    }

    static func bridgeDayDescFriday(holidayName: String) -> String {
        switch lang {
        case .korean: return "금요일 연차 1일로 4일 연휴! \(holidayName) 다음 금요일을 활용하세요."
        case .english: return "1 day leave on Friday for 4-day weekend! Use Friday after \(holidayName)."
        case .japanese: return "金曜1日の有給で4連休！\(holidayName)後の金曜を活用。"
        case .chinese: return "周五请1天年假获得4天假期！利用\(holidayName)后的周五。"
        case .german: return "1 Urlaubstag am Freitag für 4 freie Tage! Nutze den Freitag nach \(holidayName)."
        case .french: return "1 jour de congé le vendredi pour 4 jours off ! Profitez du vendredi après \(holidayName)."
        }
    }

    static func connectedLeaveTitle(holidayName: String) -> String {
        switch lang {
        case .korean: return "\(holidayName) 연계 휴가"
        case .english: return "\(holidayName) Extended Leave"
        case .japanese: return "\(holidayName) 連携休暇"
        case .chinese: return "\(holidayName) 连休"
        case .german: return "Verlängerter Urlaub: \(holidayName)"
        case .french: return "Congé prolongé : \(holidayName)"
        }
    }

    static func connectedLeaveDesc(holidayName: String, leaveDays: Int, totalDays: Int) -> String {
        switch lang {
        case .korean: return "\(holidayName) 연휴를 활용하여 연차 \(leaveDays)일로 \(totalDays)일 연휴를 만들 수 있어요."
        case .english: return "Use \(leaveDays) leave days around \(holidayName) for \(totalDays) days off."
        case .japanese: return "\(holidayName)を活用して有給\(leaveDays)日で\(totalDays)連休。"
        case .chinese: return "利用\(holidayName)，请\(leaveDays)天年假获得\(totalDays)天假期。"
        case .german: return "Mit \(leaveDays) Urlaubstagen rund um \(holidayName) bekommst du \(totalDays) freie Tage."
        case .french: return "Avec \(leaveDays) jours de congé autour de \(holidayName), profitez de \(totalDays) jours off."
        }
    }

    static func weeklyLeaveTitle(holidayName: String) -> String {
        switch lang {
        case .korean: return "\(holidayName) 연계 주간휴가"
        case .english: return "\(holidayName) Week Off"
        case .japanese: return "\(holidayName) 週間休暇"
        case .chinese: return "\(holidayName) 周假"
        case .german: return "Urlaubswoche: \(holidayName)"
        case .french: return "Semaine de congé : \(holidayName)"
        }
    }

    static func weeklyLeaveDesc(holidayName: String, leaveDays: Int) -> String {
        switch lang {
        case .korean: return "\(holidayName)이 있는 주를 활용! 연차 \(leaveDays)일로 9일 연휴."
        case .english: return "Take the week with \(holidayName)! \(leaveDays) leave days for 9 days off."
        case .japanese: return "\(holidayName)のある週を活用！有給\(leaveDays)日で9連休。"
        case .chinese: return "利用\(holidayName)所在周！请\(leaveDays)天年假获得9天假期。"
        case .german: return "Nimm die Woche mit \(holidayName)! \(leaveDays) Urlaubstage für 9 freie Tage."
        case .french: return "Prenez la semaine de \(holidayName) ! \(leaveDays) jours de congé pour 9 jours off."
        }
    }

    static func mayGoldenWeekDesc(leaveDays: Int, totalDays: Int) -> String {
        switch lang {
        case .korean: return "어린이날과 근로자의 날을 활용한 황금연휴! 연차 \(leaveDays)일로 \(totalDays)일 연휴를 만들 수 있어요."
        case .english: return "Golden week around Children's Day! \(leaveDays) leave days for \(totalDays) days off."
        case .japanese: return "こどもの日を活用したゴールデンウィーク！有給\(leaveDays)日で\(totalDays)連休。"
        case .chinese: return "利用五一黄金周！请\(leaveDays)天年假获得\(totalDays)天假期。"
        case .german: return "Goldene Woche rund um den Kindertag! \(leaveDays) Urlaubstage für \(totalDays) freie Tage."
        case .french: return "Semaine d’or autour de la Fête des enfants : \(leaveDays) jours de congé pour \(totalDays) jours de repos."
        }
    }

    static var mayGoldenWeekTitle: String {
        switch lang {
        case .korean: return "5월 황금연휴"
        case .english: return "May Golden Week"
        case .japanese: return "5月ゴールデンウィーク"
        case .chinese: return "五月黄金周"
        case .german: return "Goldene Woche im Mai"
        case .french: return "Semaine d'or de mai"
        }
    }

    // MARK: - 날짜 로케일
    static var localeIdentifier: String {
        switch lang {
        case .korean: return "ko_KR"
        case .english: return "en_US"
        case .japanese: return "ja_JP"
        case .chinese: return "zh_CN"
        case .german: return "de_DE"
        case .french: return "fr_FR"
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
            case .german: return "d. MMM (E)"
            case .french: return "E d MMM"
            }
        case "monthDayOnly":
            switch lang {
            case .korean: return "M월 d일"
            case .english: return "MMM d"
            case .japanese: return "M月d日"
            case .chinese: return "M月d日"
            case .german: return "d. MMM"
            case .french: return "d MMM"
            }
        case "yearMonth":
            switch lang {
            case .korean: return "yyyy년 M월"
            case .english: return "MMM yyyy"
            case .japanese: return "yyyy年M月"
            case .chinese: return "yyyy年M月"
            case .german: return "MMM yyyy"
            case .french: return "MMM yyyy"
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
        case .german: return "Goldene Woche"
        case .french: return "Semaine d'or"
        }
    }

    static var bridgeDayLegend: String {
        switch lang {
        case .korean: return "징검다리"
        case .english: return "Bridge"
        case .japanese: return "飛び石"
        case .chinese: return "桥接假"
        case .german: return "Brücke"
        case .french: return "Pont"
        }
    }

    static var consecutiveLeaveLegend: String {
        switch lang {
        case .korean: return "연속휴가"
        case .english: return "Extended"
        case .japanese: return "連続"
        case .chinese: return "连休"
        case .german: return "Verlängert"
        case .french: return "Prolongé"
        }
    }

    // Extra items count
    static func moreItems(_ count: Int) -> String {
        switch lang {
        case .korean: return "외 \(count)건"
        case .english: return "+\(count) more"
        case .japanese: return "他\(count)件"
        case .chinese: return "另外\(count)项"
        case .german: return "+\(count) weitere"
        case .french: return "+\(count) autres"
        }
    }

    // Items count
    static func itemCount(_ count: Int) -> String {
        switch lang {
        case .korean: return "\(count)건"
        case .english: return "\(count)"
        case .japanese: return "\(count)件"
        case .chinese: return "\(count)项"
        case .german: return "\(count)"
        case .french: return "\(count)"
        }
    }

    static func itemCountUnit(_ count: Int) -> String {
        switch lang {
        case .korean: return "\(count)개"
        case .english: return "\(count)"
        case .japanese: return "\(count)個"
        case .chinese: return "\(count)个"
        case .german: return "\(count)"
        case .french: return "\(count)"
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
            case .german: parts.append("ausgewählt")
            case .french: parts.append("sélectionné")
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
        case .german: return "Legende: Rot für Feiertage, Grün für Urlaub, Blau für Wochenenden"
        case .french: return "Légende : rouge pour les jours fériés, vert pour les congés, bleu pour les week-ends"
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
        case .german: return "Urlaubsverwaltung"
        case .french: return "Gestion des congés"
        }
    }

    static var basicLeave: String {
        switch lang {
        case .korean: return "기본 연차"
        case .english: return "Base Leave"
        case .japanese: return "基本有給"
        case .chinese: return "基本年假"
        case .german: return "Grundurlaub"
        case .french: return "Congés de base"
        }
    }

    static var bonus: String {
        switch lang {
        case .korean: return "보너스"
        case .english: return "Bonus"
        case .japanese: return "ボーナス"
        case .chinese: return "奖励"
        case .german: return "Bonus"
        case .french: return "Bonus"
        }
    }

    static var totalAvailable: String {
        switch lang {
        case .korean: return "총 사용 가능"
        case .english: return "Total Available"
        case .japanese: return "利用可能合計"
        case .chinese: return "可用总数"
        case .german: return "Insgesamt verfügbar"
        case .french: return "Total disponible"
        }
    }

    static var managementType: String {
        switch lang {
        case .korean: return "관리 유형"
        case .english: return "Type"
        case .japanese: return "管理タイプ"
        case .chinese: return "管理类型"
        case .german: return "Art"
        case .french: return "Type"
        }
    }

    static var registerLeave: String {
        switch lang {
        case .korean: return "휴가 등록"
        case .english: return "Register Leave"
        case .japanese: return "休暇登録"
        case .chinese: return "登记休假"
        case .german: return "Urlaub eintragen"
        case .french: return "Enregistrer un congé"
        }
    }

    static var addLeave: String {
        switch lang {
        case .korean: return "연차 추가"
        case .english: return "Add Leave"
        case .japanese: return "有給追加"
        case .chinese: return "添加年假"
        case .german: return "Urlaub hinzufügen"
        case .french: return "Ajouter un congé"
        }
    }

    static var leaveTypeSection: String {
        switch lang {
        case .korean: return "휴가 유형"
        case .english: return "Leave Type"
        case .japanese: return "休暇タイプ"
        case .chinese: return "休假类型"
        case .german: return "Urlaubsart"
        case .french: return "Type de congé"
        }
    }

    static func noDeductionInfo(_ typeName: String) -> String {
        switch lang {
        case .korean: return "\(typeName)은(는) 연차에서 차감되지 않습니다."
        case .english: return "\(typeName) does not deduct from annual leave."
        case .japanese: return "\(typeName)は有給から差し引かれません。"
        case .chinese: return "\(typeName)不从年假中扣除。"
        case .german: return "\(typeName) wird nicht vom Jahresurlaub abgezogen."
        case .french: return "\(typeName) n'est pas déduit des congés annuels."
        }
    }

    static var dateSelection: String {
        switch lang {
        case .korean: return "날짜 선택"
        case .english: return "Select Dates"
        case .japanese: return "日付選択"
        case .chinese: return "选择日期"
        case .german: return "Datum wählen"
        case .french: return "Choisir les dates"
        }
    }

    static var startDate: String {
        switch lang {
        case .korean: return "시작일"
        case .english: return "Start Date"
        case .japanese: return "開始日"
        case .chinese: return "开始日期"
        case .german: return "Startdatum"
        case .french: return "Date de début"
        }
    }

    static var endDate: String {
        switch lang {
        case .korean: return "종료일"
        case .english: return "End Date"
        case .japanese: return "終了日"
        case .chinese: return "终止日期"
        case .german: return "Enddatum"
        case .french: return "Date de fin"
        }
    }

    static var daysUsed: String {
        switch lang {
        case .korean: return "사용일수"
        case .english: return "Days Used"
        case .japanese: return "使用日数"
        case .chinese: return "使用天数"
        case .german: return "Genutzte Tage"
        case .french: return "Jours utilisés"
        }
    }

    static var memoOptional: String {
        switch lang {
        case .korean: return "메모 (선택)"
        case .english: return "Note (Optional)"
        case .japanese: return "メモ（任意）"
        case .chinese: return "备注（可选）"
        case .german: return "Notiz (optional)"
        case .french: return "Note (facultatif)"
        }
    }

    static var memoPlaceholder: String {
        switch lang {
        case .korean: return "휴가 목적을 입력하세요"
        case .english: return "Enter leave purpose"
        case .japanese: return "休暇の目的を入力"
        case .chinese: return "请输入休假目的"
        case .german: return "Urlaubszweck eingeben"
        case .french: return "Saisissez le motif du congé"
        }
    }

    static var registerLeaveButton: String {
        switch lang {
        case .korean: return "휴가 등록하기"
        case .english: return "Register Leave"
        case .japanese: return "休暇を登録"
        case .chinese: return "登记休假"
        case .german: return "Urlaub eintragen"
        case .french: return "Enregistrer le congé"
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
        case .german: return "\(typeName) eintragen"
        case .french: return "Enregistrer : \(typeName)"
        }
    }

    static var recentRecords: String {
        switch lang {
        case .korean: return "최근 등록 내역"
        case .english: return "Recent Records"
        case .japanese: return "最近の登録"
        case .chinese: return "最近记录"
        case .german: return "Letzte Einträge"
        case .french: return "Enregistrements récents"
        }
    }

    static var alert: String {
        switch lang {
        case .korean: return "알림"
        case .english: return "Alert"
        case .japanese: return "お知らせ"
        case .chinese: return "提示"
        case .german: return "Hinweis"
        case .french: return "Alerte"
        }
    }

    static var insufficientLeave: String {
        switch lang {
        case .korean: return "연차가 부족합니다."
        case .english: return "Insufficient leave days."
        case .japanese: return "有給が不足しています。"
        case .chinese: return "年假不足。"
        case .german: return "Nicht genügend Urlaubstage."
        case .french: return "Jours de congé insuffisants."
        }
    }

    static func leaveRegistered(_ typeName: String) -> String {
        switch lang {
        case .korean: return "\(typeName)이(가) 등록되었습니다!"
        case .english: return "\(typeName) has been registered!"
        case .japanese: return "\(typeName)が登録されました！"
        case .chinese: return "\(typeName)已登记！"
        case .german: return "\(typeName) wurde eingetragen!"
        case .french: return "\(typeName) a été enregistré !"
        }
    }

    static var saveFailed: String {
        switch lang {
        case .korean: return "저장에 실패했습니다. 다시 시도해주세요."
        case .english: return "Save failed. Please try again."
        case .japanese: return "保存に失敗しました。もう一度お試しください。"
        case .chinese: return "保存失败,请重试。"
        case .german: return "Speichern fehlgeschlagen. Bitte versuche es erneut."
        case .french: return "Échec de l’enregistrement. Veuillez réessayer."
        }
    }

    // MARK: - 백업 / 복원 / 데이터 알림
    static var backupSuccessMessage: String {
        switch lang {
        case .korean: return "iCloud에 백업되었습니다."
        case .english: return "Backed up to iCloud."
        case .japanese: return "iCloudにバックアップしました。"
        case .chinese: return "已备份到iCloud。"
        case .german: return "In iCloud gesichert."
        case .french: return "Sauvegardé dans iCloud."
        }
    }

    static var restoreSuccessMessage: String {
        switch lang {
        case .korean: return "복원이 완료되었습니다."
        case .english: return "Restore completed."
        case .japanese: return "復元が完了しました。"
        case .chinese: return "恢复已完成。"
        case .german: return "Wiederherstellung abgeschlossen."
        case .french: return "Restauration terminée."
        }
    }

    static func saveFailedWithReason(_ reason: String) -> String {
        switch lang {
        case .korean: return "저장에 실패했습니다: \(reason)"
        case .english: return "Save failed: \(reason)"
        case .japanese: return "保存に失敗しました: \(reason)"
        case .chinese: return "保存失败: \(reason)"
        case .german: return "Speichern fehlgeschlagen: \(reason)"
        case .french: return "Échec de l’enregistrement : \(reason)"
        }
    }

    static func resetFailedWithReason(_ reason: String) -> String {
        switch lang {
        case .korean: return "초기화에 실패했습니다: \(reason)"
        case .english: return "Reset failed: \(reason)"
        case .japanese: return "リセットに失敗しました: \(reason)"
        case .chinese: return "重置失败: \(reason)"
        case .german: return "Zurücksetzen fehlgeschlagen: \(reason)"
        case .french: return "Échec de la réinitialisation : \(reason)"
        }
    }

    static var deleteFailed: String {
        switch lang {
        case .korean: return "삭제에 실패했습니다. 다시 시도해주세요."
        case .english: return "Delete failed. Please try again."
        case .japanese: return "削除に失敗しました。もう一度お試しください。"
        case .chinese: return "删除失败,请重试。"
        case .german: return "Löschen fehlgeschlagen. Bitte versuche es erneut."
        case .french: return "Échec de la suppression. Veuillez réessayer."
        }
    }

    static var deleteBonusLeaveTitle: String {
        switch lang {
        case .korean: return "보너스 연차 삭제"
        case .english: return "Delete Bonus Leave"
        case .japanese: return "ボーナス休暇を削除"
        case .chinese: return "删除奖励年假"
        case .german: return "Bonusurlaub löschen"
        case .french: return "Supprimer le congé bonus"
        }
    }

    static var deleteBonusLeaveConfirm: String {
        switch lang {
        case .korean: return "이 보너스 연차를 삭제하시겠습니까?"
        case .english: return "Delete this bonus leave?"
        case .japanese: return "このボーナス休暇を削除しますか？"
        case .chinese: return "确定删除此奖励年假吗？"
        case .german: return "Diesen Bonusurlaub löschen?"
        case .french: return "Supprimer ce congé bonus ?"
        }
    }

    static var retry: String {
        switch lang {
        case .korean: return "다시 시도"
        case .english: return "Retry"
        case .japanese: return "再試行"
        case .chinese: return "重试"
        case .german: return "Erneut versuchen"
        case .french: return "Réessayer"
        }
    }

    // MARK: - 캘린더 → 등록 연동
    static var addLeaveOnThisDate: String {
        switch lang {
        case .korean: return "이 날짜로 휴가 등록"
        case .english: return "Add leave on this date"
        case .japanese: return "この日付で休暇を登録"
        case .chinese: return "在此日期登记休假"
        case .german: return "Urlaub für dieses Datum eintragen"
        case .french: return "Ajouter un congé à cette date"
        }
    }

    // MARK: - 홈 빈 상태
    static var emptyHomeTitle: String {
        switch lang {
        case .korean: return "첫 휴가를 계획해보세요"
        case .english: return "Plan your first leave"
        case .japanese: return "最初の休暇を計画しましょう"
        case .chinese: return "计划您的第一个假期"
        case .german: return "Plane deinen ersten Urlaub"
        case .french: return "Planifiez votre premier congé"
        }
    }

    static var emptyHomeMessage: String {
        switch lang {
        case .korean: return "휴가를 등록하면 잔여 연차와 다가오는 일정을 한눈에 볼 수 있어요."
        case .english: return "Register a leave to see your remaining days and upcoming plans at a glance."
        case .japanese: return "休暇を登録すると、残りの有給と今後の予定が一目でわかります。"
        case .chinese: return "登记休假后,可一目了然地查看剩余年假和即将到来的日程。"
        case .german: return "Trage Urlaub ein, um verbleibende Tage und anstehende Pläne auf einen Blick zu sehen."
        case .french: return "Enregistrez un congé pour voir vos jours restants et vos prochains plans d’un coup d’œil."
        }
    }

    static var emptyHomeCTA: String {
        switch lang {
        case .korean: return "휴가 등록하기"
        case .english: return "Add Leave"
        case .japanese: return "休暇を登録"
        case .chinese: return "登记休假"
        case .german: return "Urlaub hinzufügen"
        case .french: return "Ajouter un congé"
        }
    }

    // MARK: - 공휴일 데이터 만료 안내
    static func holidayDataMayBeInaccurate(_ year: Int) -> String {
        switch lang {
        case .korean: return "\(year)년 공휴일 정보는 정확하지 않을 수 있어요. 앱을 최신 버전으로 업데이트해주세요."
        case .english: return "Holiday data for \(year) may be inaccurate. Please update the app to the latest version."
        case .japanese: return "\(year)年の祝日情報は正確でない可能性があります。アプリを最新版に更新してください。"
        case .chinese: return "\(year)年的节假日信息可能不准确,请将应用更新到最新版本。"
        case .german: return "Die Feiertage für \(year) sind möglicherweise ungenau. Bitte aktualisiere die App auf die neueste Version."
        case .french: return "Les jours fériés de \(year) peuvent être inexacts. Veuillez mettre à jour l’app vers la dernière version."
        }
    }

    // MARK: - 구매 복원 결과
    static var restorePurchasesSuccess: String {
        switch lang {
        case .korean: return "구매가 복원되었습니다."
        case .english: return "Purchases restored."
        case .japanese: return "購入が復元されました。"
        case .chinese: return "购买已恢复。"
        case .german: return "Käufe wiederhergestellt."
        case .french: return "Achats restaurés."
        }
    }

    static var restorePurchasesNone: String {
        switch lang {
        case .korean: return "복원할 구매 내역이 없습니다."
        case .english: return "No purchases to restore."
        case .japanese: return "復元できる購入履歴がありません。"
        case .chinese: return "没有可恢复的购买记录。"
        case .german: return "Keine Käufe zum Wiederherstellen."
        case .french: return "Aucun achat à restaurer."
        }
    }

    static func restorePurchasesFailed(_ reason: String) -> String {
        switch lang {
        case .korean: return "구매 복원에 실패했습니다: \(reason)"
        case .english: return "Restore failed: \(reason)"
        case .japanese: return "購入の復元に失敗しました: \(reason)"
        case .chinese: return "恢复购买失败: \(reason)"
        case .german: return "Wiederherstellung fehlgeschlagen: \(reason)"
        case .french: return "Échec de la restauration : \(reason)"
        }
    }

    static var priceLoadFailed: String {
        switch lang {
        case .korean: return "가격 정보를 불러오지 못했어요. 네트워크 연결을 확인해주세요."
        case .english: return "Couldn't load price info. Please check your network connection."
        case .japanese: return "価格情報を読み込めませんでした。ネットワーク接続をご確認ください。"
        case .chinese: return "无法加载价格信息,请检查网络连接。"
        case .german: return "Preise konnten nicht geladen werden. Bitte prüfe deine Netzwerkverbindung."
        case .french: return "Impossible de charger les prix. Vérifiez votre connexion réseau."
        }
    }

    static var termsOfService: String {
        switch lang {
        case .korean: return "이용약관"
        case .english: return "Terms of Service"
        case .japanese: return "利用規約"
        case .chinese: return "服务条款"
        case .german: return "Nutzungsbedingungen"
        case .french: return "Conditions d’utilisation"
        }
    }

    static var privacyPolicy: String {
        switch lang {
        case .korean: return "개인정보처리방침"
        case .english: return "Privacy Policy"
        case .japanese: return "プライバシーポリシー"
        case .chinese: return "隐私政策"
        case .german: return "Datenschutzerklärung"
        case .french: return "Politique de confidentialité"
        }
    }

    // MARK: - 캘린더 휴가 가져오기
    static var importFromCalendar: String {
        switch lang {
        case .korean: return "캘린더에서 휴가 가져오기"
        case .english: return "Import Leaves from Calendar"
        case .japanese: return "カレンダーから休暇を取り込む"
        case .chinese: return "从日历导入休假"
        case .german: return "Urlaub aus Kalender importieren"
        case .french: return "Importer les congés du calendrier"
        }
    }

    static var importFromCalendarDescription: String {
        switch lang {
        case .korean: return "캘린더에서 휴가로 보이는 일정을 찾아 추가할 수 있어요."
        case .english: return "Find calendar events that look like leaves and add them."
        case .japanese: return "カレンダーから休暇と思われる予定を見つけて追加できます。"
        case .chinese: return "从日历中查找疑似休假的日程并添加。"
        case .german: return "Finde Kalendereinträge, die nach Urlaub aussehen, und füge sie hinzu."
        case .french: return "Trouvez les événements du calendrier qui ressemblent à des congés et ajoutez-les."
        }
    }

    static var detectedLeaveCandidates: String {
        switch lang {
        case .korean: return "휴가로 보이는 일정"
        case .english: return "Events that look like leaves"
        case .japanese: return "休暇と思われる予定"
        case .chinese: return "疑似休假的日程"
        case .german: return "Einträge, die nach Urlaub aussehen"
        case .french: return "Événements ressemblant à des congés"
        }
    }

    static var noLeaveCandidatesFound: String {
        switch lang {
        case .korean: return "휴가로 보이는 일정을 찾지 못했어요.\n(이미 등록된 휴가는 제외돼요)"
        case .english: return "No leave-like events found.\n(Already-registered leaves are excluded)"
        case .japanese: return "休暇と思われる予定が見つかりませんでした。\n(登録済みの休暇は除外されます)"
        case .chinese: return "未找到疑似休假的日程。\n(已登记的休假会被排除)"
        case .german: return "Keine urlaubsähnlichen Einträge gefunden.\n(Bereits eingetragener Urlaub wird ausgeschlossen)"
        case .french: return "Aucun événement ressemblant à un congé trouvé.\n(Les congés déjà enregistrés sont exclus)"
        }
    }

    static func importSelectedLeaves(_ count: Int) -> String {
        switch lang {
        case .korean: return "\(count)건 추가"
        case .english: return "Add \(count)"
        case .japanese: return "\(count)件を追加"
        case .chinese: return "添加\(count)项"
        case .german: return "\(count) hinzufügen"
        case .french: return "Ajouter \(count)"
        }
    }

    static func leavesImported(_ count: Int) -> String {
        switch lang {
        case .korean: return "휴가 \(count)건을 추가했어요."
        case .english: return "Added \(count) leave(s)."
        case .japanese: return "休暇\(count)件を追加しました。"
        case .chinese: return "已添加\(count)项休假。"
        case .german: return "\(count) Urlaubseintrag/-einträge hinzugefügt."
        case .french: return "\(count) congé(s) ajouté(s)."
        }
    }

    // MARK: - 캘린더 자동 감지 (Pro)
    static var autoDetectBannerTitle: String {
        switch lang {
        case .korean: return "캘린더에서 휴가 발견"
        case .english: return "Leaves found in your calendar"
        case .japanese: return "カレンダーで休暇を発見"
        case .chinese: return "在日历中发现休假"
        case .german: return "Urlaub im Kalender gefunden"
        case .french: return "Congés trouvés dans votre calendrier"
        }
    }

    static func autoDetectBannerMessage(_ count: Int) -> String {
        switch lang {
        case .korean: return "휴가로 보이는 일정 \(count)건을 찾았어요. 확인 후 한 번에 추가할 수 있어요."
        case .english: return "Found \(count) event(s) that look like leaves. Review and add them in one tap."
        case .japanese: return "休暇と思われる予定を\(count)件見つけました。確認してまとめて追加できます。"
        case .chinese: return "找到\(count)项疑似休假的日程,确认后可一键添加。"
        case .german: return "\(count) Eintrag/Einträge gefunden, die nach Urlaub aussehen. Prüfe sie und füge sie mit einem Tipp hinzu."
        case .french: return "\(count) événement(s) ressemblant à des congés trouvé(s). Vérifiez-les et ajoutez-les en un geste."
        }
    }

    static var autoDetectReview: String {
        switch lang {
        case .korean: return "확인하기"
        case .english: return "Review"
        case .japanese: return "確認する"
        case .chinese: return "查看"
        case .german: return "Prüfen"
        case .french: return "Vérifier"
        }
    }

    static var autoDetectSettingTitle: String {
        switch lang {
        case .korean: return "캘린더 자동 감지"
        case .english: return "Auto-Detect from Calendar"
        case .japanese: return "カレンダー自動検出"
        case .chinese: return "日历自动检测"
        case .german: return "Automatische Kalendererkennung"
        case .french: return "Détection auto depuis le calendrier"
        }
    }

    static var autoDetectSettingDescription: String {
        switch lang {
        case .korean: return "앱을 열 때 캘린더에서 새 휴가 일정을 자동으로 찾아 알려드려요."
        case .english: return "Automatically finds new leave events in your calendar when you open the app."
        case .japanese: return "アプリを開くとカレンダーから新しい休暇予定を自動で見つけてお知らせします。"
        case .chinese: return "打开应用时自动从日历中查找新的休假日程并提醒您。"
        case .german: return "Findet beim Öffnen der App automatisch neue Urlaubseinträge in deinem Kalender."
        case .french: return "Trouve automatiquement les nouveaux congés de votre calendrier à l’ouverture de l’app."
        }
    }

    static var proBannerAutoDetect: String {
        switch lang {
        case .korean: return "캘린더 속 휴가 일정, Pro가 자동으로 찾아드려요"
        case .english: return "Pro automatically finds leave events in your calendar"
        case .japanese: return "カレンダーの休暇予定、Proが自動で見つけます"
        case .chinese: return "Pro自动为您查找日历中的休假日程"
        case .german: return "Pro findet Urlaubseinträge in deinem Kalender automatisch"
        case .french: return "Pro trouve automatiquement les congés de votre calendrier"
        }
    }

    // MARK: - 연차 플랜 공유
    static var sharePlan: String {
        switch lang {
        case .korean: return "연차 플랜 공유"
        case .english: return "Share Leave Plan"
        case .japanese: return "休暇プランを共有"
        case .chinese: return "分享休假计划"
        case .german: return "Urlaubsplan teilen"
        case .french: return "Partager le plan de congés"
        }
    }

    /// 공유 미리보기 시트
    static var sharePreviewTitle: String {
        switch lang {
        case .korean: return "공유 미리보기"
        case .english: return "Share Preview"
        case .japanese: return "共有プレビュー"
        case .chinese: return "分享预览"
        case .german: return "Vorschau teilen"
        case .french: return "Aperçu du partage"
        }
    }

    static var sharePreviewHint: String {
        switch lang {
        case .korean: return "이 이미지가 공유돼요"
        case .english: return "This image will be shared"
        case .japanese: return "この画像が共有されます"
        case .chinese: return "将分享这张图片"
        case .german: return "Dieses Bild wird geteilt"
        case .french: return "Cette image sera partagée"
        }
    }

    static var shareNow: String {
        switch lang {
        case .korean: return "공유하기"
        case .english: return "Share"
        case .japanese: return "共有する"
        case .chinese: return "分享"
        case .german: return "Teilen"
        case .french: return "Partager"
        }
    }

    static var shareCardTitle: String {
        switch lang {
        case .korean: return "나의 연차 현황"
        case .english: return "My Leave Status"
        case .japanese: return "私の休暇状況"
        case .chinese: return "我的年假概览"
        case .german: return "Mein Urlaubsstand"
        case .french: return "Mon solde de congés"
        }
    }

    static var shareCardFooter: String {
        switch lang {
        case .korean: return "Goldweek — 연차를 황금연휴로"
        case .english: return "Goldweek — Turn your leaves into golden weeks"
        case .japanese: return "Goldweek — 有給をゴールデンウィークに"
        case .chinese: return "Goldweek — 把年假变成黄金周"
        case .german: return "Goldweek — Mach aus Urlaubstagen goldene Wochen"
        case .french: return "Goldweek — Transformez vos congés en semaines dorées"
        }
    }

    static var openSettings: String {
        switch lang {
        case .korean: return "설정 열기"
        case .english: return "Open Settings"
        case .japanese: return "設定を開く"
        case .chinese: return "打开设置"
        case .german: return "Einstellungen öffnen"
        case .french: return "Ouvrir les réglages"
        }
    }

    static var scanningCalendar: String {
        switch lang {
        case .korean: return "캘린더를 확인하는 중..."
        case .english: return "Scanning calendar..."
        case .japanese: return "カレンダーを確認中..."
        case .chinese: return "正在检查日历..."
        case .german: return "Kalender wird geprüft ..."
        case .french: return "Analyse du calendrier..."
        }
    }

    // MARK: - 등록 불가 사유
    static var reasonEndBeforeStart: String {
        switch lang {
        case .korean: return "종료일이 시작일보다 빠릅니다."
        case .english: return "End date is before start date."
        case .japanese: return "終了日が開始日より前です。"
        case .chinese: return "结束日期早于开始日期。"
        case .german: return "Das Enddatum liegt vor dem Startdatum."
        case .french: return "La date de fin est antérieure à la date de début."
        }
    }

    static var reasonOverlappingLeave: String {
        switch lang {
        case .korean: return "이미 등록된 연차와 겹치는 기간입니다."
        case .english: return "This period overlaps with an existing leave."
        case .japanese: return "登録済みの休暇と期間が重なっています。"
        case .chinese: return "该时间段与已登记的休假重叠。"
        case .german: return "Dieser Zeitraum überschneidet sich mit bereits eingetragenem Urlaub."
        case .french: return "Cette période chevauche un congé existant."
        }
    }

    static var shareSubject: String {
        switch lang {
        case .korean: return "Goldweek - 연차 관리 앱"
        case .english: return "Goldweek - Annual Leave Management"
        case .japanese: return "Goldweek - 有給管理アプリ"
        case .chinese: return "Goldweek - 年假管理应用"
        case .german: return "Goldweek - Urlaubsplaner"
        case .french: return "Goldweek - Gestion des congés"
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
        case .german: return "\(n) ₩"
        case .french: return "\(n) ₩"
        }
    }

    // MARK: - MRT API 에러
    static var mrtErrorNotConfigured: String {
        switch lang {
        case .korean: return "마이리얼트립 API가 설정되지 않았습니다."
        case .english: return "MyRealTrip API is not configured."
        case .japanese: return "MyRealTrip APIが設定されていません。"
        case .chinese: return "MyRealTrip API未配置。"
        case .german: return "Die MyRealTrip-API ist nicht konfiguriert."
        case .french: return "L’API MyRealTrip n’est pas configurée."
        }
    }

    static var mrtErrorInvalidURL: String {
        switch lang {
        case .korean: return "잘못된 URL입니다."
        case .english: return "Invalid URL."
        case .japanese: return "無効なURLです。"
        case .chinese: return "无效的URL。"
        case .german: return "Ungültige URL."
        case .french: return "URL non valide."
        }
    }

    static var mrtErrorBadRequest: String {
        switch lang {
        case .korean: return "잘못된 요청입니다."
        case .english: return "Bad request."
        case .japanese: return "不正なリクエストです。"
        case .chinese: return "请求无效。"
        case .german: return "Ungültige Anfrage."
        case .french: return "Requête non valide."
        }
    }

    static var mrtErrorUnauthorized: String {
        switch lang {
        case .korean: return "API 키가 유효하지 않습니다."
        case .english: return "Invalid API key."
        case .japanese: return "APIキーが無効です。"
        case .chinese: return "API密钥无效。"
        case .german: return "Ungültiger API-Schlüssel."
        case .french: return "Clé API non valide."
        }
    }

    static var mrtErrorForbidden: String {
        switch lang {
        case .korean: return "이 API에 대한 접근 권한이 없습니다."
        case .english: return "Access denied to this API."
        case .japanese: return "このAPIへのアクセス権限がありません。"
        case .chinese: return "无权访问此API。"
        case .german: return "Zugriff auf diese API verweigert."
        case .french: return "Accès à cette API refusé."
        }
    }

    static var mrtErrorNotFound: String {
        switch lang {
        case .korean: return "엔드포인트를 찾을 수 없습니다."
        case .english: return "Endpoint not found."
        case .japanese: return "エンドポイントが見つかりません。"
        case .chinese: return "未找到端点。"
        case .german: return "Endpunkt nicht gefunden."
        case .french: return "Point de terminaison introuvable."
        }
    }

    static var mrtErrorRateLimited: String {
        switch lang {
        case .korean: return "요청 한도를 초과했습니다."
        case .english: return "Request rate limit exceeded."
        case .japanese: return "リクエスト上限を超えました。"
        case .chinese: return "请求次数超限。"
        case .german: return "Anfragelimit überschritten."
        case .french: return "Limite de requêtes dépassée."
        }
    }

    static func mrtErrorServerError(_ code: Int) -> String {
        switch lang {
        case .korean: return "서버 오류 (\(code))"
        case .english: return "Server error (\(code))"
        case .japanese: return "サーバーエラー (\(code))"
        case .chinese: return "服务器错误 (\(code))"
        case .german: return "Serverfehler (\(code))"
        case .french: return "Erreur serveur (\(code))"
        }
    }

    static var mrtErrorDecoding: String {
        switch lang {
        case .korean: return "응답 형식 오류"
        case .english: return "Invalid response format"
        case .japanese: return "応答形式エラー"
        case .chinese: return "响应格式错误"
        case .german: return "Ungültiges Antwortformat"
        case .french: return "Format de réponse non valide"
        }
    }

    static var mrtErrorMaxRetries: String {
        switch lang {
        case .korean: return "재시도 한도를 초과했습니다."
        case .english: return "Max retries exceeded."
        case .japanese: return "再試行上限を超えました。"
        case .chinese: return "重试次数超限。"
        case .german: return "Maximale Anzahl an Wiederholungen überschritten."
        case .french: return "Nombre maximal de tentatives dépassé."
        }
    }

    // MARK: - 보너스 연차 (BonusLeaveView)
    static var available: String {
        switch lang {
        case .korean: return "사용 가능"
        case .english: return "Available"
        case .japanese: return "利用可能"
        case .chinese: return "可用"
        case .german: return "Verfügbar"
        case .french: return "Disponible"
        }
    }

    static var usedComplete: String {
        switch lang {
        case .korean: return "사용 완료"
        case .english: return "Used"
        case .japanese: return "使用済み"
        case .chinese: return "已使用"
        case .german: return "Genommen"
        case .french: return "Utilisé"
        }
    }

    static var noBonusLeave: String {
        switch lang {
        case .korean: return "등록된 보너스 연차가 없습니다"
        case .english: return "No bonus leave registered"
        case .japanese: return "ボーナス有給がありません"
        case .chinese: return "没有登记的奖励假"
        case .german: return "Kein Bonusurlaub eingetragen"
        case .french: return "Aucun congé bonus enregistré"
        }
    }

    static var leaveDaysSection: String {
        switch lang {
        case .korean: return "연차 일수"
        case .english: return "Leave Days"
        case .japanese: return "有給日数"
        case .chinese: return "年假天数"
        case .german: return "Urlaubstage"
        case .french: return "Jours de congé"
        }
    }

    static var daysToAdd: String {
        switch lang {
        case .korean: return "추가할 일수"
        case .english: return "Days to Add"
        case .japanese: return "追加日数"
        case .chinese: return "添加天数"
        case .german: return "Hinzuzufügende Tage"
        case .french: return "Jours à ajouter"
        }
    }

    static var typeSection: String {
        switch lang {
        case .korean: return "유형"
        case .english: return "Type"
        case .japanese: return "タイプ"
        case .chinese: return "类型"
        case .german: return "Art"
        case .french: return "Type"
        }
    }

    static var reasonSection: String {
        switch lang {
        case .korean: return "사유"
        case .english: return "Reason"
        case .japanese: return "理由"
        case .chinese: return "原因"
        case .german: return "Grund"
        case .french: return "Motif"
        }
    }

    static var reasonPlaceholder: String {
        switch lang {
        case .korean: return "예: 휴일근무 대체, 프로젝트 포상 등"
        case .english: return "e.g. Holiday work comp, Project reward"
        case .japanese: return "例：休日出勤代替、プロジェクト報奨など"
        case .chinese: return "例：节假日加班补休、项目奖励等"
        case .german: return "z. B. Ausgleich für Feiertagsarbeit, Projektprämie"
        case .french: return "p. ex. récupération jour férié travaillé, prime de projet"
        }
    }

    static var setExpiration: String {
        switch lang {
        case .korean: return "만료일 설정"
        case .english: return "Set Expiration"
        case .japanese: return "有効期限設定"
        case .chinese: return "设置到期日"
        case .german: return "Ablauf festlegen"
        case .french: return "Définir une expiration"
        }
    }

    static var expirationDate: String {
        switch lang {
        case .korean: return "만료일"
        case .english: return "Expiration"
        case .japanese: return "有効期限"
        case .chinese: return "到期日"
        case .german: return "Ablaufdatum"
        case .french: return "Expiration"
        }
    }

    static var expirationFooter: String {
        switch lang {
        case .korean: return "만료일을 설정하지 않으면 연말까지 사용 가능합니다."
        case .english: return "If no expiration is set, it can be used until year-end."
        case .japanese: return "有効期限を設定しない場合、年末まで使用可能です。"
        case .chinese: return "不设置到期日则可使用到年末。"
        case .german: return "Ohne Ablaufdatum kann er bis zum Jahresende genutzt werden."
        case .french: return "Sans date d’expiration, il reste utilisable jusqu’à la fin de l’année."
        }
    }

    // MARK: - 휴가 사용 내역 (LeaveHistoryView)
    static var navTitleLeaveHistory: String {
        switch lang {
        case .korean: return "휴가 사용 내역"
        case .english: return "Leave History"
        case .japanese: return "休暇履歴"
        case .chinese: return "休假记录"
        case .german: return "Urlaubsverlauf"
        case .french: return "Historique des congés"
        }
    }

    static var close: String {
        switch lang {
        case .korean: return "닫기"
        case .english: return "Close"
        case .japanese: return "閉じる"
        case .chinese: return "关闭"
        case .german: return "Schließen"
        case .french: return "Fermer"
        }
    }

    static var all: String {
        switch lang {
        case .korean: return "전체"
        case .english: return "All"
        case .japanese: return "すべて"
        case .chinese: return "全部"
        case .german: return "Alle"
        case .french: return "Tous"
        }
    }

    static var allTypes: String {
        switch lang {
        case .korean: return "전체 유형"
        case .english: return "All Types"
        case .japanese: return "全タイプ"
        case .chinese: return "全部类型"
        case .german: return "Alle Arten"
        case .french: return "Tous les types"
        }
    }

    static var statUsed: String {
        switch lang {
        case .korean: return "사용 완료"
        case .english: return "Used"
        case .japanese: return "使用済み"
        case .chinese: return "已使用"
        case .german: return "Genommen"
        case .french: return "Utilisés"
        }
    }

    static var statPlanned: String {
        switch lang {
        case .korean: return "예정"
        case .english: return "Planned"
        case .japanese: return "予定"
        case .chinese: return "计划中"
        case .german: return "Geplant"
        case .french: return "Prévus"
        }
    }

    static var statCancelled: String {
        switch lang {
        case .korean: return "취소"
        case .english: return "Cancelled"
        case .japanese: return "キャンセル"
        case .chinese: return "已取消"
        case .german: return "Storniert"
        case .french: return "Annulés"
        }
    }

    static func casesCount(_ count: Int) -> String {
        switch lang {
        case .korean: return "\(count)건"
        case .english: return "\(count)"
        case .japanese: return "\(count)件"
        case .chinese: return "\(count)项"
        case .german: return "\(count)"
        case .french: return "\(count)"
        }
    }

    static var noLeaveRecords: String {
        switch lang {
        case .korean: return "휴가 기록이 없습니다"
        case .english: return "No leave records"
        case .japanese: return "休暇記録がありません"
        case .chinese: return "没有休假记录"
        case .german: return "Keine Urlaubseinträge"
        case .french: return "Aucun congé enregistré"
        }
    }

    static func noLeaveForYear(_ year: Int) -> String {
        switch lang {
        case .korean: return "\(year)년에 등록된 휴가가 없습니다.\n새로운 휴가를 등록해보세요."
        case .english: return "No leave registered for \(year).\nTry registering a new leave."
        case .japanese: return "\(year)年の休暇がありません。\n新しい休暇を登録してみましょう。"
        case .chinese: return "\(year)年没有登记的休假。\n请尝试登记新的休假。"
        case .german: return "Für \(year) ist kein Urlaub eingetragen.\nTrage einen neuen Urlaub ein."
        case .french: return "Aucun congé enregistré pour \(year).\nEssayez d’en ajouter un."
        }
    }

    static func yearLabel(_ year: Int) -> String {
        switch lang {
        case .korean: return "\(year)년"
        case .english: return "\(year)"
        case .japanese: return "\(year)年"
        case .chinese: return "\(year)年"
        case .german: return "\(year)"
        case .french: return "\(year)"
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
        case .german:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "de_DE")
            return formatter.shortMonthSymbols[month - 1]
        case .french:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "fr_FR")
            return formatter.shortMonthSymbols[month - 1]
        }
    }

    static func daysCountLabel(_ count: Int) -> String {
        switch lang {
        case .korean: return "(\(count)일)"
        case .english: return "(\(count) days)"
        case .japanese: return "(\(count)日)"
        case .chinese: return "(\(count)天)"
        case .german: return "(\(count) Tage)"
        case .french: return "(\(count) jours)"
        }
    }

    static var edit: String {
        switch lang {
        case .korean: return "수정"
        case .english: return "Edit"
        case .japanese: return "編集"
        case .chinese: return "编辑"
        case .german: return "Bearbeiten"
        case .french: return "Modifier"
        }
    }

    // MARK: - 휴가 수정 (EditLeaveSheet)
    static var navTitleEditLeave: String {
        switch lang {
        case .korean: return "휴가 수정"
        case .english: return "Edit Leave"
        case .japanese: return "休暇編集"
        case .chinese: return "编辑休假"
        case .german: return "Urlaub bearbeiten"
        case .french: return "Modifier le congé"
        }
    }

    static var statusSection: String {
        switch lang {
        case .korean: return "상태"
        case .english: return "Status"
        case .japanese: return "ステータス"
        case .chinese: return "状态"
        case .german: return "Status"
        case .french: return "Statut"
        }
    }

    static var dateSection: String {
        switch lang {
        case .korean: return "날짜"
        case .english: return "Dates"
        case .japanese: return "日付"
        case .chinese: return "日期"
        case .german: return "Datum"
        case .french: return "Dates"
        }
    }

    static func additionalLeaveUsed(_ days: String) -> String {
        switch lang {
        case .korean: return "연차 \(days)일 추가 사용"
        case .english: return "\(days) more leave days used"
        case .japanese: return "有給\(days)日追加使用"
        case .chinese: return "额外使用\(days)天年假"
        case .german: return "\(days) weitere Urlaubstage genommen"
        case .french: return "\(days) jours de congé supplémentaires utilisés"
        }
    }

    static func leaveRestored(_ days: String) -> String {
        switch lang {
        case .korean: return "연차 \(days)일 복원"
        case .english: return "\(days) leave days restored"
        case .japanese: return "有給\(days)日復元"
        case .chinese: return "恢复\(days)天年假"
        case .german: return "\(days) Urlaubstage zurückgebucht"
        case .french: return "\(days) jours de congé restitués"
        }
    }

    static var memo: String {
        switch lang {
        case .korean: return "메모"
        case .english: return "Note"
        case .japanese: return "メモ"
        case .chinese: return "备注"
        case .german: return "Notiz"
        case .french: return "Note"
        }
    }

    static var leavePurpose: String {
        switch lang {
        case .korean: return "휴가 목적"
        case .english: return "Leave purpose"
        case .japanese: return "休暇の目的"
        case .chinese: return "休假目的"
        case .german: return "Urlaubszweck"
        case .french: return "Motif du congé"
        }
    }

    static var schedulePreview: String {
        switch lang {
        case .korean: return "일정 미리보기"
        case .english: return "Schedule Preview"
        case .japanese: return "スケジュールプレビュー"
        case .chinese: return "日程预览"
        case .german: return "Terminvorschau"
        case .french: return "Aperçu du planning"
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
            case .german: return "Sa"
            case .french: return "Sam"
            }
        case .sunday:
            switch lang {
            case .korean: return "일"
            case .english: return "Sun"
            case .japanese: return "日"
            case .chinese: return "日"
            case .german: return "So"
            case .french: return "Dim"
            }
        case .holiday:
            switch lang {
            case .korean: return "휴일"
            case .english: return "Holiday"
            case .japanese: return "祝日"
            case .chinese: return "节日"
            case .german: return "Feiertag"
            case .french: return "Férié"
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
        case .german: return "Auf Pro upgraden"
        case .french: return "Passer à Pro"
        }
    }
    
    static var goldweekPro: String {
        switch lang {
        case .korean: return "골드위크 Pro"
        case .english: return "Goldweek Pro"
        case .japanese: return "ゴールドウィーク Pro"
        case .chinese: return "Goldweek Pro"
        case .german: return "Goldweek Pro"
        case .french: return "Goldweek Pro"
        }
    }
    
    static var unlockAllFeatures: String {
        switch lang {
        case .korean: return "모든 기능을 잠금해제하세요"
        case .english: return "Unlock all features"
        case .japanese: return "すべての機能をアンロック"
        case .chinese: return "解锁所有功能"
        case .german: return "Schalte alle Funktionen frei"
        case .french: return "Débloquez toutes les fonctionnalités"
        }
    }
    
    static var freeVersion: String {
        switch lang {
        case .korean: return "무료 버전"
        case .english: return "Free"
        case .japanese: return "無料版"
        case .chinese: return "免费版"
        case .german: return "Kostenlos"
        case .french: return "Gratuit"
        }
    }
    
    static var proVersion: String {
        switch lang {
        case .korean: return "Pro 버전"
        case .english: return "Pro"
        case .japanese: return "Pro版"
        case .chinese: return "Pro版"
        case .german: return "Pro"
        case .french: return "Pro"
        }
    }
    
    static var purchase: String {
        switch lang {
        case .korean: return "구매하기"
        case .english: return "Purchase"
        case .japanese: return "購入"
        case .chinese: return "购买"
        case .german: return "Kaufen"
        case .french: return "Acheter"
        }
    }
    
    static var restorePurchase: String {
        switch lang {
        case .korean: return "구매 복원"
        case .english: return "Restore Purchase"
        case .japanese: return "購入を復元"
        case .chinese: return "恢复购买"
        case .german: return "Kauf wiederherstellen"
        case .french: return "Restaurer l’achat"
        }
    }
    
    static var featureComparison: String {
        switch lang {
        case .korean: return "기능 비교"
        case .english: return "Feature Comparison"
        case .japanese: return "機能比較"
        case .chinese: return "功能对比"
        case .german: return "Funktionsvergleich"
        case .french: return "Comparatif des fonctions"
        }
    }
    
    static var basicLeaveManagement: String {
        switch lang {
        case .korean: return "기본 연차 관리"
        case .english: return "Basic Leave Management"
        case .japanese: return "基本的な有給管理"
        case .chinese: return "基本年假管理"
        case .german: return "Urlaubsverwaltung (Basis)"
        case .french: return "Gestion des congés de base"
        }
    }
    
    static var leaveRecommendations: String {
        switch lang {
        case .korean: return "연차 추천"
        case .english: return "Leave Recommendations"
        case .japanese: return "有給おすすめ"
        case .chinese: return "年假推荐"
        case .german: return "Urlaubsempfehlungen"
        case .french: return "Recommandations de congés"
        }
    }
    
    static var limitedRecommendations: String {
        switch lang {
        case .korean: return "3개 추천만 표시"
        case .english: return "3 recommendations only"
        case .japanese: return "3つの推奨のみ"
        case .chinese: return "仅显示3个推荐"
        case .german: return "Nur 3 Empfehlungen"
        case .french: return "3 recommandations seulement"
        }
    }
    
    static var unlimitedRecommendations: String {
        switch lang {
        case .korean: return "모든 추천 표시"
        case .english: return "All recommendations"
        case .japanese: return "すべての推奨"
        case .chinese: return "显示所有推荐"
        case .german: return "Alle Empfehlungen"
        case .french: return "Toutes les recommandations"
        }
    }
    
    static var yearSelector: String {
        switch lang {
        case .korean: return "연도 선택"
        case .english: return "Year Selection"
        case .japanese: return "年選択"
        case .chinese: return "年份选择"
        case .german: return "Jahresauswahl"
        case .french: return "Choix de l'année"
        }
    }
    
    static var currentYearOnly: String {
        switch lang {
        case .korean: return "올해만"
        case .english: return "Current year only"
        case .japanese: return "今年のみ"
        case .chinese: return "仅当前年"
        case .german: return "Nur aktuelles Jahr"
        case .french: return "Année en cours uniquement"
        }
    }
    
    static var allYears: String {
        switch lang {
        case .korean: return "모든 년도"
        case .english: return "All years"
        case .japanese: return "すべての年"
        case .chinese: return "所有年份"
        case .german: return "Alle Jahre"
        case .french: return "Toutes les années"
        }
    }
    
    static var systemCalendarSync: String {
        switch lang {
        case .korean: return "시스템 캘린더 연동"
        case .english: return "System Calendar Sync"
        case .japanese: return "システムカレンダー連携"
        case .chinese: return "系统日历同步"
        case .german: return "Kalender-Synchronisierung"
        case .french: return "Synchronisation du calendrier"
        }
    }
    
    static var notAvailable: String {
        switch lang {
        case .korean: return "사용 불가"
        case .english: return "Not available"
        case .japanese: return "利用不可"
        case .chinese: return "不可用"
        case .german: return "Nicht verfügbar"
        case .french: return "Non disponible"
        }
    }
    
    static var bonusLeaveManagement: String {
        switch lang {
        case .korean: return "보너스 연차 관리"
        case .english: return "Bonus Leave Management"
        case .japanese: return "ボーナス休暇管理"
        case .chinese: return "奖励年假管理"
        case .german: return "Bonusurlaub verwalten"
        case .french: return "Gestion des congés bonus"
        }
    }
    
    static var iCloudBackup: String {
        switch lang {
        case .korean: return "iCloud 백업"
        case .english: return "iCloud Backup"
        case .japanese: return "iCloudバックアップ"
        case .chinese: return "iCloud备份"
        case .german: return "iCloud-Backup"
        case .french: return "Sauvegarde iCloud"
        }
    }
    
    static var oneTimePurchase: String {
        switch lang {
        case .korean: return "1회 구매, 평생 사용"
        case .english: return "One-time purchase, lifetime access"
        case .japanese: return "一度の購入で永続利用"
        case .chinese: return "一次购买，终身使用"
        case .german: return "Einmalkauf, lebenslang nutzen"
        case .french: return "Achat unique, accès à vie"
        }
    }
    
    static var noSubscription: String {
        switch lang {
        case .korean: return "구독 없음"
        case .english: return "No subscription"
        case .japanese: return "サブスクなし"
        case .chinese: return "无订阅"
        case .german: return "Kein Abo"
        case .french: return "Sans abonnement"
        }
    }
    
    static var purchasing: String {
        switch lang {
        case .korean: return "구매 중..."
        case .english: return "Purchasing..."
        case .japanese: return "購入中..."
        case .chinese: return "购买中..."
        case .german: return "Kauf läuft …"
        case .french: return "Achat en cours…"
        }
    }
    
    static var purchaseSuccess: String {
        switch lang {
        case .korean: return "구매 완료!"
        case .english: return "Purchase successful!"
        case .japanese: return "購入完了！"
        case .chinese: return "购买成功！"
        case .german: return "Kauf abgeschlossen!"
        case .french: return "Achat réussi !"
        }
    }
    
    static var purchaseError: String {
        switch lang {
        case .korean: return "구매 실패"
        case .english: return "Purchase failed"
        case .japanese: return "購入失敗"
        case .chinese: return "购买失败"
        case .german: return "Kauf fehlgeschlagen"
        case .french: return "Échec de l'achat"
        }
    }
    
    static var restoreSuccess: String {
        switch lang {
        case .korean: return "복원 완료!"
        case .english: return "Restore successful!"
        case .japanese: return "復元完了！"
        case .chinese: return "恢复成功！"
        case .german: return "Wiederherstellung abgeschlossen!"
        case .french: return "Restauration réussie !"
        }
    }
    
    static var youArePro: String {
        switch lang {
        case .korean: return "Pro 사용자입니다!"
        case .english: return "You are a Pro user!"
        case .japanese: return "Pro ユーザーです！"
        case .chinese: return "您是Pro用户！"
        case .german: return "Du bist Pro-Nutzer!"
        case .french: return "Vous êtes utilisateur Pro !"
        }
    }
    
    static var proFeaturesBanner: String {
        switch lang {
        case .korean: return "더 많은 기능을 원하시나요? Pro로 업그레이드하세요"
        case .english: return "Want more features? Upgrade to Pro"
        case .japanese: return "もっと機能が欲しい？Proにアップグレード"
        case .chinese: return "想要更多功能？升级到Pro版"
        case .german: return "Mehr Funktionen gewünscht? Upgrade auf Pro"
        case .french: return "Envie de plus de fonctions ? Passez à Pro"
        }
    }
    
    // MARK: - 앱 공유
    static var shareApp: String {
        switch lang {
        case .korean: return "앱 공유하기"
        case .english: return "Share App"
        case .japanese: return "アプリを共有"
        case .chinese: return "分享应用"
        case .german: return "App teilen"
        case .french: return "Partager l'app"
        }
    }
    
    static var shareMessage: String {
        switch lang {
        case .korean: return "연차 수당 받지 말고 진짜로 쉬세요. 알고리즘이 최장 연휴 조합 자동 계산 🏖️"
        case .english: return "Don't take the cash — take the days. Algorithm finds your longest possible breaks 🏖️"
        case .japanese: return "有給を現金じゃなく、実際の休みに。アルゴリズムが最長の連休を自動算出 🏖️"
        case .chinese: return "别拿年假补偿，真正去休假吧。算法自动计算最长假期组合 🏖️"
        case .german: return "Lass dir Urlaub nicht auszahlen – nimm ihn dir. Der Algorithmus findet deine längsten Auszeiten 🏖️"
        case .french: return "Ne vous faites pas payer vos congés, prenez-les. L'algorithme trouve vos plus longues pauses 🏖️"
        }
    }

    // MARK: - Pro 온보딩 페이지
    static var proOnboardingSubtitle: String {
        switch lang {
        case .korean: return "한 번 결제로 모든 기능을 영구적으로 사용하세요"
        case .english: return "One purchase. All features. Forever."
        case .japanese: return "一度の購入ですべての機能を永続利用"
        case .chinese: return "一次购买，永久使用全部功能"
        case .german: return "Einmal zahlen. Alle Funktionen. Für immer."
        case .french: return "Un seul paiement. Toutes les fonctions. Pour toujours."
        }
    }

    static var proOnboardingSkip: String {
        switch lang {
        case .korean: return "나중에 알아볼게요"
        case .english: return "Maybe later"
        case .japanese: return "あとで確認する"
        case .chinese: return "稍后了解"
        case .german: return "Vielleicht später"
        case .french: return "Peut-être plus tard"
        }
    }

    static var proFeatureRecommendTitle: String {
        switch lang {
        case .korean: return "무제한 AI 추천"
        case .english: return "Unlimited AI plans"
        case .japanese: return "無制限のAI推薦"
        case .chinese: return "无限AI推荐"
        case .german: return "Unbegrenzte KI-Pläne"
        case .french: return "Plans IA illimités"
        }
    }

    static var proFeatureRecommendDesc: String {
        switch lang {
        case .korean: return "무료는 3개까지"
        case .english: return "Free is limited to 3"
        case .japanese: return "無料は3件まで"
        case .chinese: return "免费版最多3个"
        case .german: return "Kostenlos nur bis zu 3"
        case .french: return "Gratuit : 3 maximum"
        }
    }

    static var proFeatureBonusTitle: String {
        switch lang {
        case .korean: return "보너스 연차 관리"
        case .english: return "Bonus leave tracking"
        case .japanese: return "ボーナス休暇管理"
        case .chinese: return "奖励年假管理"
        case .german: return "Bonusurlaub verwalten"
        case .french: return "Suivi des congés bonus"
        }
    }

    static var proFeatureBonusDesc: String {
        switch lang {
        case .korean: return "보상 휴가, 특별 휴가, 병가"
        case .english: return "Comp days, special leave, sick"
        case .japanese: return "代休、特別休暇、病気休暇"
        case .chinese: return "补休、特别假、病假"
        case .german: return "Ausgleichstage, Sonderurlaub, Krankheit"
        case .french: return "Récup, congés spéciaux, maladie"
        }
    }

    static var proFeatureMultiYearTitle: String {
        switch lang {
        case .korean: return "멀티 연도 플래닝"
        case .english: return "Multi-year planning"
        case .japanese: return "複数年プランニング"
        case .chinese: return "跨年度规划"
        case .german: return "Mehrjahresplanung"
        case .french: return "Planification pluriannuelle"
        }
    }

    static var proFeatureMultiYearDesc: String {
        switch lang {
        case .korean: return "지난해와 내년까지 한눈에"
        case .english: return "Last year and next year at a glance"
        case .japanese: return "昨年と来年まで一目で"
        case .chinese: return "去年和明年一览"
        case .german: return "Letztes und nächstes Jahr im Blick"
        case .french: return "Année passée et suivante en un coup d'œil"
        }
    }

    static var proFeatureCalendarTitle: String {
        switch lang {
        case .korean: return "캘린더 연동"
        case .english: return "Calendar sync"
        case .japanese: return "カレンダー連携"
        case .chinese: return "日历同步"
        case .german: return "Kalender-Sync"
        case .french: return "Synchro du calendrier"
        }
    }

    static var proFeatureCalendarDesc: String {
        switch lang {
        case .korean: return "iOS 캘린더에 자동 동기화"
        case .english: return "Auto-sync with iOS Calendar"
        case .japanese: return "iOSカレンダーに自動同期"
        case .chinese: return "自动同步到iOS日历"
        case .german: return "Automatisch mit dem iOS-Kalender synchronisieren"
        case .french: return "Synchro automatique avec le calendrier iOS"
        }
    }

    // MARK: - 휴가 페이스 (번아웃 & 소진 속도)
    static var paceCardTitle: String {
        switch lang {
        case .korean: return "휴가 페이스"
        case .english: return "Vacation Pace"
        case .japanese: return "休暇ペース"
        case .chinese: return "休假节奏"
        case .german: return "Urlaubstempo"
        case .french: return "Rythme des congés"
        }
    }

    static var paceYearProgressLabel: String {
        switch lang {
        case .korean: return "올해 진행"
        case .english: return "Year progress"
        case .japanese: return "今年の進捗"
        case .chinese: return "年度进度"
        case .german: return "Jahresfortschritt"
        case .french: return "Avancement de l'année"
        }
    }

    static var paceUsageLabel: String {
        switch lang {
        case .korean: return "연차 사용"
        case .english: return "Leave used"
        case .japanese: return "有給使用"
        case .chinese: return "年假使用"
        case .german: return "Urlaub genommen"
        case .french: return "Congés pris"
        }
    }

    static var paceLabelSlow: String {
        switch lang {
        case .korean: return "여유"
        case .english: return "Relaxed"
        case .japanese: return "ゆとり"
        case .chinese: return "宽松"
        case .german: return "Entspannt"
        case .french: return "Serein"
        }
    }

    static var paceLabelHealthy: String {
        switch lang {
        case .korean: return "적정"
        case .english: return "Balanced"
        case .japanese: return "適正"
        case .chinese: return "均衡"
        case .german: return "Ausgewogen"
        case .french: return "Équilibré"
        }
    }

    static var paceLabelFast: String {
        switch lang {
        case .korean: return "빠름"
        case .english: return "Fast"
        case .japanese: return "速い"
        case .chinese: return "偏快"
        case .german: return "Schnell"
        case .french: return "Rapide"
        }
    }

    static var paceLabelVeryFast: String {
        switch lang {
        case .korean: return "매우 빠름"
        case .english: return "Very fast"
        case .japanese: return "非常に速い"
        case .chinese: return "很快"
        case .german: return "Sehr schnell"
        case .french: return "Très rapide"
        }
    }

    static var paceMessageSlow: String {
        switch lang {
        case .korean: return "여유롭게 사용 중이에요. 다음 휴가를 미리 계획해 보세요."
        case .english: return "You're pacing slowly. Try planning ahead so days don't pile up."
        case .japanese: return "ゆったり使っています。次の休暇を計画してみましょう。"
        case .chinese: return "使用节奏宽松。可以提前规划下一次休假。"
        case .german: return "Du nutzt deinen Urlaub gemächlich. Plane vorausschauend, damit sich keine Tage anhäufen."
        case .french: return "Vous prenez vos congés tranquillement. Planifiez à l'avance pour ne pas accumuler de jours."
        }
    }

    static var paceMessageHealthy: String {
        switch lang {
        case .korean: return "건강한 페이스로 휴가를 사용하고 있어요."
        case .english: return "Healthy pace. You're using leave at the right rate."
        case .japanese: return "健康的なペースで休暇を取れています。"
        case .chinese: return "节奏健康,休假分配合理。"
        case .german: return "Gesundes Tempo. Du nutzt deinen Urlaub im richtigen Maß."
        case .french: return "Rythme sain. Vous utilisez vos congés au bon rythme."
        }
    }

    static var paceMessageFast: String {
        switch lang {
        case .korean: return "최근 사용이 많네요. 남은 기간을 잘 안배해 보세요."
        case .english: return "You're using leave faster than average. Pace yourself for the rest of the year."
        case .japanese: return "やや早めの消化です。残りの期間を見ながら配分しましょう。"
        case .chinese: return "使用较快。请合理分配剩余时间。"
        case .german: return "Du nimmst Urlaub schneller als der Durchschnitt. Teile dir den Rest des Jahres gut ein."
        case .french: return "Vous posez vos congés plus vite que la moyenne. Répartissez bien le reste de l'année."
        }
    }

    static var paceMessageVeryFast: String {
        switch lang {
        case .korean: return "연차 소진이 매우 빨라요. 남은 일수가 부족할 수 있어요."
        case .english: return "Your leave is depleting very quickly. You might run short."
        case .japanese: return "有給の消化が非常に速いです。残日数が不足するかもしれません。"
        case .chinese: return "年假消耗非常快,剩余天数可能不足。"
        case .german: return "Dein Urlaub schwindet sehr schnell. Am Ende könnten Tage fehlen."
        case .french: return "Vos congés fondent très vite. Il pourrait vous manquer des jours."
        }
    }

    // 번아웃 신호 섹션
    static var burnoutSectionTitle: String {
        switch lang {
        case .korean: return "쉬어가는 흐름"
        case .english: return "Rest rhythm"
        case .japanese: return "休息のリズム"
        case .chinese: return "休息节奏"
        case .german: return "Erholungsrhythmus"
        case .french: return "Rythme de repos"
        }
    }

    static var burnoutLast: String {
        switch lang {
        case .korean: return "지난 휴가"
        case .english: return "Last break"
        case .japanese: return "前回の休暇"
        case .chinese: return "上次休假"
        case .german: return "Zuletzt"
        case .french: return "Dernière"
        }
    }

    static var burnoutToday: String {
        switch lang {
        case .korean: return "오늘"
        case .english: return "Today"
        case .japanese: return "今日"
        case .chinese: return "今天"
        case .german: return "Heute"
        case .french: return "Aujourd'hui"
        }
    }

    static var burnoutNext: String {
        switch lang {
        case .korean: return "다음 휴가"
        case .english: return "Next break"
        case .japanese: return "次の休暇"
        case .chinese: return "下次休假"
        case .german: return "Als Nächstes"
        case .french: return "Prochaine"
        }
    }

    static func burnoutDaysAgo(_ days: Int) -> String {
        switch lang {
        case .korean: return "\(days)일 전"
        case .english: return days == 1 ? "1 day ago" : "\(days) days ago"
        case .japanese: return "\(days)日前"
        case .chinese: return "\(days)天前"
        case .german: return days == 1 ? "vor 1 Tag" : "vor \(days) Tagen"
        case .french: return days == 1 ? "il y a 1 jour" : "il y a \(days) jours"
        }
    }

    static func burnoutDaysAhead(_ days: Int) -> String {
        switch lang {
        case .korean: return "\(days)일 후"
        case .english: return days == 1 ? "in 1 day" : "in \(days) days"
        case .japanese: return "\(days)日後"
        case .chinese: return "\(days)天后"
        case .german: return days == 1 ? "in 1 Tag" : "in \(days) Tagen"
        case .french: return days == 1 ? "dans 1 jour" : "dans \(days) jours"
        }
    }

    static var burnoutNoLast: String {
        switch lang {
        case .korean: return "기록 없음"
        case .english: return "No record"
        case .japanese: return "記録なし"
        case .chinese: return "无记录"
        case .german: return "Kein Eintrag"
        case .french: return "Aucun enregistrement"
        }
    }

    static var burnoutNoNext: String {
        switch lang {
        case .korean: return "계획 없음"
        case .english: return "Not planned"
        case .japanese: return "未計画"
        case .chinese: return "未计划"
        case .german: return "Nicht geplant"
        case .french: return "Non planifié"
        }
    }

    static var burnoutMsgHealthy: String {
        switch lang {
        case .korean: return "휴가 간격이 건강해요. 지금 흐름을 유지하세요."
        case .english: return "Healthy gap between breaks. Keep this rhythm."
        case .japanese: return "休暇の間隔が健康的です。今のリズムを維持しましょう。"
        case .chinese: return "休假间隔健康,继续保持这个节奏。"
        case .german: return "Gesunder Abstand zwischen den Auszeiten. Behalte diesen Rhythmus bei."
        case .french: return "Bon écart entre vos pauses. Gardez ce rythme."
        }
    }

    static var burnoutMsgWarning: String {
        switch lang {
        case .korean: return "쉬어간 지 좀 됐어요. 짧게라도 휴식을 계획해 보세요."
        case .english: return "It's been a while. Consider planning even a short break."
        case .japanese: return "少し休んでいません。短い休みでも計画してみましょう。"
        case .chinese: return "已经有段时间没休息了,哪怕短假也好,试着安排一下吧。"
        case .german: return "Deine letzte Auszeit ist schon eine Weile her. Plane auch mal eine kurze Pause."
        case .french: return "Cela fait un moment. Pensez à planifier une petite pause."
        }
    }

    static var burnoutMsgRisky: String {
        switch lang {
        case .korean: return "오랫동안 쉬지 못했어요. 번아웃 전에 휴가를 잡으세요."
        case .english: return "You haven't rested in a long time. Schedule a break before burnout sets in."
        case .japanese: return "長い間休めていません。バーンアウト前に休暇を入れましょう。"
        case .chinese: return "好久没休息了,在倦怠之前安排一次休假吧。"
        case .german: return "Du hast dich lange nicht erholt. Plane Urlaub, bevor es zum Burnout kommt."
        case .french: return "Vous ne vous êtes pas reposé depuis longtemps. Posez des congés avant le burn-out."
        }
    }

    static var burnoutMsgPlannedAhead: String {
        switch lang {
        case .korean: return "다음 휴가가 곧이에요. 조금만 더 힘내세요."
        case .english: return "Your next break is coming up soon. Hang in there."
        case .japanese: return "次の休暇はすぐです。もう少しがんばりましょう。"
        case .chinese: return "下次休假就快到了,再坚持一下。"
        case .german: return "Deine nächste Auszeit steht bald an. Halte noch ein bisschen durch."
        case .french: return "Votre prochaine pause approche. Tenez bon encore un peu."
        }
    }

    // MARK: - 회복 잔량 / 번아웃 예측 (Rest Radar)

    /// 내 평소 휴식 주기 — 개인화됐을 때
    static func personalCycleLabel(_ days: Int) -> String {
        switch lang {
        case .korean: return "평소 주기 \(days)일"
        case .english: return "Your usual cycle: \(days) days"
        case .japanese: return "いつもの周期\(days)日"
        case .chinese: return "你通常的周期为\(days)天"
        case .german: return "Dein üblicher Zyklus: \(days) Tage"
        case .french: return "Votre cycle habituel : \(days) jours"
        }
    }

    /// 캘린더 범례 — 번아웃 주의 구간
    static var burnoutWarningLegend: String {
        switch lang {
        case .korean: return "번아웃 주의"
        case .english: return "Burnout risk"
        case .japanese: return "バーンアウト注意"
        case .chinese: return "倦怠风险"
        case .german: return "Burnout-Risiko"
        case .french: return "Risque de burn-out"
        }
    }

    // MARK: - 피로 체크인 (단일문항 SIB)

    static var fatigueCheckInTitle: String {
        switch lang {
        case .korean: return "요즘 얼마나 지치셨나요?"
        case .english: return "How drained do you feel lately?"
        case .japanese: return "最近どれくらい疲れていますか?"
        case .chinese: return "最近你有多疲惫?"
        case .german: return "Wie erschöpft fühlst du dich zurzeit?"
        case .french: return "À quel point êtes-vous épuisé en ce moment ?"
        }
    }

    static var fatigueCheckInSubtitle: String {
        switch lang {
        case .korean: return "한 번의 답이 휴식 추천을 더 정확하게 만들어요."
        case .english: return "One quick answer sharpens your rest suggestions."
        case .japanese: return "ひとつの回答で休息提案がより正確になります。"
        case .chinese: return "一个简单的回答能让休息建议更准确。"
        case .german: return "Eine kurze Antwort macht deine Erholungstipps treffsicherer."
        case .french: return "Une réponse rapide affine vos suggestions de repos."
        }
    }

    static var fatigueLow: String {
        switch lang {
        case .korean: return "괜찮아요"
        case .english: return "Fine"
        case .japanese: return "元気"
        case .chinese: return "还好"
        case .german: return "Geht so gut"
        case .french: return "Ça va"
        }
    }

    static var fatigueHigh: String {
        switch lang {
        case .korean: return "완전 지침"
        case .english: return "Exhausted"
        case .japanese: return "限界"
        case .chinese: return "精疲力竭"
        case .german: return "Völlig erschöpft"
        case .french: return "Épuisé"
        }
    }

    static var fatigueSubmit: String {
        switch lang {
        case .korean: return "기록하기"
        case .english: return "Submit"
        case .japanese: return "記録する"
        case .chinese: return "提交"
        case .german: return "Speichern"
        case .french: return "Enregistrer"
        }
    }

    static var fatigueSkip: String {
        switch lang {
        case .korean: return "나중에"
        case .english: return "Later"
        case .japanese: return "あとで"
        case .chinese: return "稍后"
        case .german: return "Später"
        case .french: return "Plus tard"
        }
    }

    // MARK: - 휴식 알림 설정 (Rest Radar)

    static var restRadarSection: String {
        switch lang {
        case .korean: return "휴식 알림"
        case .english: return "Rest reminders"
        case .japanese: return "休息リマインダー"
        case .chinese: return "休息提醒"
        case .german: return "Erholungserinnerungen"
        case .french: return "Rappels de repos"
        }
    }

    static var restRadarToggle: String {
        switch lang {
        case .korean: return "휴식 레이더"
        case .english: return "Rest Radar"
        case .japanese: return "レストレーダー"
        case .chinese: return "休息雷达"
        case .german: return "Erholungsradar"
        case .french: return "Radar de repos"
        }
    }

    static var restRadarFooter: String {
        switch lang {
        case .korean: return "오래 쉬지 못했을 때, 가까운 저비용 연휴와 함께 쉬어갈 때를 알려드려요."
        case .english: return "When you've gone too long without a break, we'll nudge you with a nearby low-cost getaway."
        case .japanese: return "長く休めていないとき、近くの低コストな連休とともにお知らせします。"
        case .chinese: return "当你太久没休息时,会结合就近的低成本假期提醒你。"
        case .german: return "Wenn du zu lange keine Pause hattest, erinnern wir dich an einen günstigen Kurztrip in der Nähe."
        case .french: return "Si vous n'avez pas fait de pause depuis trop longtemps, nous vous suggérerons une escapade économique à proximité."
        }
    }

    /// 알림 내 스누즈 액션 버튼
    static var restRadarSnoozeAction: String {
        switch lang {
        case .korean: return "2주 뒤에 다시"
        case .english: return "Remind in 2 weeks"
        case .japanese: return "2週間後に再通知"
        case .chinese: return "两周后再提醒"
        case .german: return "In 2 Wochen erinnern"
        case .french: return "Rappeler dans 2 semaines"
        }
    }

    // MARK: - 홈 카드 라벨 (LeaveStatusCard)
    static var includeBonus: String {
        switch lang {
        case .korean: return "보너스 포함"
        case .english: return "Include bonus"
        case .japanese: return "ボーナス含む"
        case .chinese: return "包含奖励"
        case .german: return "Bonus einbeziehen"
        case .french: return "Inclure le bonus"
        }
    }

    /// 보너스 포함 토글 VoiceOver 힌트
    static var includeBonusHint: String {
        switch lang {
        case .korean: return "켜면 보너스 연차가 잔여 일수에 합산됩니다"
        case .english: return "When on, bonus leave is added to your remaining days"
        case .japanese: return "オンにするとボーナス休暇が残日数に合算されます"
        case .chinese: return "开启后奖励假期将计入剩余天数"
        case .german: return "Wenn aktiviert, wird Bonusurlaub zu deinen Resttagen addiert"
        case .french: return "Si activé, les congés bonus s'ajoutent à vos jours restants"
        }
    }

    static var statRemainingGoal: String {
        switch lang {
        case .korean: return "남은 목표"
        case .english: return "Goal left"
        case .japanese: return "残り目標"
        case .chinese: return "目标剩余"
        case .german: return "Restziel"
        case .french: return "Objectif restant"
        }
    }

    static var usable: String {
        switch lang {
        case .korean: return "사용 가능"
        case .english: return "Available"
        case .japanese: return "利用可能"
        case .chinese: return "可用"
        case .german: return "Verfügbar"
        case .french: return "Disponible"
        }
    }

    static var goalNotSetDesc: String {
        switch lang {
        case .korean: return "목표 일수 없음 · 설정에서 연간 목표를 설정할 수 있어요"
        case .english: return "No goal set · You can set a yearly goal in Settings"
        case .japanese: return "目標日数なし · 設定で年間目標を設定できます"
        case .chinese: return "未设目标 · 可在设置中设定年度目标"
        case .german: return "Kein Ziel festgelegt · Du kannst in den Einstellungen ein Jahresziel setzen"
        case .french: return "Aucun objectif défini · Vous pouvez en fixer un dans les Réglages"
        }
    }

    static var pastLeaveSheetFooter: String {
        switch lang {
        case .korean: return "날짜별로 개별 입력하려면 + 탭을 이용하세요"
        case .english: return "Use the + tab to add leave by date"
        case .japanese: return "日付別に個別入力するには + タブを使ってください"
        case .chinese: return "如需按日期单独输入,请使用 + 标签"
        case .german: return "Nutze den +-Tab, um Urlaub nach Datum einzutragen"
        case .french: return "Utilisez l'onglet + pour ajouter des congés par date"
        }
    }

    // MARK: - Pro 배너 메시지
    static func proBannerHolidayUpcoming(_ holidayName: String, days: Int) -> String {
        switch lang {
        case .korean: return "\(holidayName) D-\(days) · 연차 붙여 긴 휴가 만들어 보세요"
        case .english: return "\(holidayName) in \(days)d · Add PTO for a longer break"
        case .japanese: return "\(holidayName) あと\(days)日 · 有給を足して長い連休に"
        case .chinese: return "\(holidayName) 还有\(days)天 · 拼上年假打造长假"
        case .german: return "\(holidayName) in \(days) T. · Mit Urlaub zur längeren Auszeit"
        case .french: return "\(holidayName) dans \(days) j · Posez des congés pour une pause plus longue"
        }
    }

    static func proBannerYearEndExpiry(_ daysText: String) -> String {
        switch lang {
        case .korean: return "연말까지 \(daysText)일 남았어요 · 소멸 전에 계획하세요"
        case .english: return "\(daysText) days left this year · Plan before they expire"
        case .japanese: return "年末まで\(daysText)日 · 消滅前に計画しましょう"
        case .chinese: return "今年还剩\(daysText)天 · 在到期前安排好"
        case .german: return "Noch \(daysText) Tage in diesem Jahr · Plane, bevor sie verfallen"
        case .french: return "Plus que \(daysText) jours cette année · Planifiez avant qu'ils expirent"
        }
    }

    static var goldenSeasonName: String {
        switch lang {
        case .korean: return "황금연휴"
        case .english: return "Golden Week"
        case .japanese: return "ゴールデンウィーク"
        case .chinese: return "黄金周"
        case .german: return "Goldene Woche"
        case .french: return "Golden Week"
        }
    }

    static var chuseokSeasonName: String {
        switch lang {
        case .korean: return "추석 연휴"
        case .english: return "Autumn Holiday"
        case .japanese: return "秋の連休"
        case .chinese: return "中秋假期"
        case .german: return "Herbstferien"
        case .french: return "Vacances d'automne"
        }
    }

    static func proBannerSeasonOpportunity(_ seasonName: String) -> String {
        switch lang {
        case .korean: return "\(seasonName) 시즌 · AI 추천으로 최적의 일정 만들어 보세요"
        case .english: return "\(seasonName) season · Try AI recommendations for the best plan"
        case .japanese: return "\(seasonName)シーズン · AIおすすめで最適な日程を"
        case .chinese: return "\(seasonName)旺季 · 用AI推荐打造最佳行程"
        case .german: return "Saison: \(seasonName) · Mit KI-Empfehlungen den besten Plan finden"
        case .french: return "Saison : \(seasonName) · Trouvez le meilleur plan avec l'IA"
        }
    }

    static func proBannerLowRemaining(_ daysText: String) -> String {
        switch lang {
        case .korean: return "남은 연차 \(daysText)일 · 효율적으로 배치해 보세요"
        case .english: return "\(daysText) days of leave left · Place them wisely"
        case .japanese: return "残り有給\(daysText)日 · 効率的に配置しましょう"
        case .chinese: return "剩余\(daysText)天年假 · 合理安排"
        case .german: return "Noch \(daysText) Urlaubstage · Setze sie klug ein"
        case .french: return "Plus que \(daysText) jours de congé · Placez-les judicieusement"
        }
    }

    static func proBannerEmptyPlan(_ daysText: String) -> String {
        switch lang {
        case .korean: return "\(daysText)일 연차가 비어 있어요 · AI 추천 받아보세요"
        case .english: return "\(daysText) days of leave unplanned · Get AI recommendations"
        case .japanese: return "\(daysText)日の有給が未計画です · AIおすすめを試してみては"
        case .chinese: return "还有\(daysText)天年假未安排 · 试试AI推荐"
        case .german: return "\(daysText) Urlaubstage noch ungeplant · Hol dir KI-Empfehlungen"
        case .french: return "\(daysText) jours de congé non planifiés · Obtenez des recommandations IA"
        }
    }

    // MARK: - AddLeaveView 라벨
    static var leisureGoalRemaining: String {
        switch lang {
        case .korean: return "목표까지 남은 일수"
        case .english: return "Days to goal"
        case .japanese: return "目標まで残り日数"
        case .chinese: return "距目标天数"
        case .german: return "Tage bis zum Ziel"
        case .french: return "Jours avant l'objectif"
        }
    }

    static var leisureTotalPlan: String {
        switch lang {
        case .korean: return "총 계획"
        case .english: return "Total planned"
        case .japanese: return "計画合計"
        case .chinese: return "计划合计"
        case .german: return "Gesamt geplant"
        case .french: return "Total planifié"
        }
    }

    static var bonusUseSectionHeader: String {
        switch lang {
        case .korean: return "보너스 연차 사용"
        case .english: return "Use bonus leave"
        case .japanese: return "ボーナス休暇を使う"
        case .chinese: return "使用奖励年假"
        case .german: return "Bonusurlaub nutzen"
        case .french: return "Utiliser les congés bonus"
        }
    }

    static var bonusUseFooterSelected: String {
        switch lang {
        case .korean: return "보너스 연차를 사용합니다. 연차에서 차감되지 않습니다."
        case .english: return "Bonus leave will be used. It won't be deducted from your annual leave."
        case .japanese: return "ボーナス休暇を使います。年次有給からは差し引かれません。"
        case .chinese: return "将使用奖励年假,不会从年假中扣除。"
        case .german: return "Bonusurlaub wird verwendet. Er wird nicht von deinem Jahresurlaub abgezogen."
        case .french: return "Les congés bonus seront utilisés. Ils ne seront pas déduits de vos congés annuels."
        }
    }

    static var bonusUseFooterUnselected: String {
        switch lang {
        case .korean: return "탭하여 보너스 연차를 선택하면 연차 대신 사용할 수 있습니다."
        case .english: return "Tap to select bonus leave and use it instead of annual leave."
        case .japanese: return "タップしてボーナス休暇を選ぶと、年次有給の代わりに使えます。"
        case .chinese: return "点击选择奖励年假即可代替年假使用。"
        case .german: return "Tippe, um Bonusurlaub auszuwählen und ihn statt Jahresurlaub zu nutzen."
        case .french: return "Touchez pour choisir des congés bonus et les utiliser à la place des congés annuels."
        }
    }

    static var unitSectionTitleBonus: String {
        switch lang {
        case .korean: return "보너스 연차 사용 단위"
        case .english: return "Bonus leave unit"
        case .japanese: return "ボーナス休暇の単位"
        case .chinese: return "奖励年假单位"
        case .german: return "Einheit für Bonusurlaub"
        case .french: return "Unité des congés bonus"
        }
    }

    static var unitSectionTitleLeisure: String {
        switch lang {
        case .korean: return "휴가 기간"
        case .english: return "Vacation length"
        case .japanese: return "休暇の長さ"
        case .chinese: return "休假时长"
        case .german: return "Urlaubsdauer"
        case .french: return "Durée des vacances"
        }
    }

    static var unitSectionTitleEmployee: String {
        switch lang {
        case .korean: return "연차 차감 단위"
        case .english: return "Deduction unit"
        case .japanese: return "有給控除の単位"
        case .chinese: return "扣除单位"
        case .german: return "Abzugseinheit"
        case .french: return "Unité de déduction"
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
        case .german:
            if isLeisure {
                switch type {
                case .quarter: return "Viertel"
                case .half: return "Halb"
                case .annual: return "Freier Tag"
                default: return "Freier Tag"
                }
            } else {
                switch type {
                case .quarter: return "Viertel Urlaubstag"
                case .half: return "Halber Urlaubstag"
                case .annual: return "Urlaubstag"
                default: return "Urlaubstag"
                }
            }
        case .french:
            if isLeisure {
                switch type {
                case .quarter: return "Quart"
                case .half: return "Demi"
                case .annual: return "Jour off"
                default: return "Jour off"
                }
            } else {
                switch type {
                case .quarter: return "Quart de congé"
                case .half: return "Demi-congé"
                case .annual: return "Congé"
                default: return "Congé"
                }
            }
        }
    }

    /// 길이(종일/반차/반반차) 이름
    static func leaveLengthName(_ length: LeaveLength) -> String {
        switch lang {
        case .korean:
            switch length {
            case .full: return "종일"
            case .half: return "반차"
            case .quarter: return "반반차"
            }
        case .english:
            switch length {
            case .full: return "Full day"
            case .half: return "Half day"
            case .quarter: return "Quarter day"
            }
        case .japanese:
            switch length {
            case .full: return "終日"
            case .half: return "半休"
            case .quarter: return "四半休"
            }
        case .chinese:
            switch length {
            case .full: return "全天"
            case .half: return "半天"
            case .quarter: return "四分之一天"
            }
        case .german:
            switch length {
            case .full: return "Ganzer Tag"
            case .half: return "Halber Tag"
            case .quarter: return "Viertel Tag"
            }
        case .french:
            switch length {
            case .full: return "Journée entière"
            case .half: return "Demi-journée"
            case .quarter: return "Quart de journée"
            }
        }
    }

    /// "휴가 종류" 섹션 헤더
    static var leaveCategorySectionHeader: String {
        switch lang {
        case .korean: return "휴가 종류"
        case .english: return "Leave type"
        case .japanese: return "休暇の種類"
        case .chinese: return "休假类型"
        case .german: return "Urlaubsart"
        case .french: return "Type de congé"
        }
    }

    /// "사용 길이" 섹션 헤더
    static var leaveLengthSectionHeader: String {
        switch lang {
        case .korean: return "사용 길이"
        case .english: return "Length"
        case .japanese: return "使用単位"
        case .chinese: return "使用长度"
        case .german: return "Dauer"
        case .french: return "Durée"
        }
    }

    static var otherTypesSectionHeader: String {
        switch lang {
        case .korean: return "기타 (연차 미차감)"
        case .english: return "Other (no deduction)"
        case .japanese: return "その他 (有給控除なし)"
        case .chinese: return "其他 (不扣除年假)"
        case .german: return "Sonstige (ohne Abzug)"
        case .french: return "Autres (sans déduction)"
        }
    }

    static var bonusLeaveFooterFree: String {
        switch lang {
        case .korean: return "보너스 연차 추가는 Pro 기능입니다. 이미 추가된 항목은 수정 가능합니다."
        case .english: return "Adding bonus leave is a Pro feature. You can still edit existing items."
        case .japanese: return "ボーナス休暇の追加はPro機能です。既存項目の編集は可能です。"
        case .chinese: return "新增奖励年假为Pro功能。已添加的项目仍可编辑。"
        case .german: return "Bonusurlaub hinzuzufügen ist eine Pro-Funktion. Vorhandene Einträge kannst du weiterhin bearbeiten."
        case .french: return "L'ajout de congés bonus est une fonction Pro. Vous pouvez toujours modifier les éléments existants."
        }
    }

    /// 부여 일수 대비 사용량을 짧게 (예: "1.5/3일").
    /// 화면에는 이걸 쓰고, 문장형(`bonusUsedOfGranted`)은 VoiceOver 낭독에만 쓴다 —
    /// 눈으로는 분수가 빠르고, 귀로는 문장이 알아듣기 쉽다.
    static func bonusUsedFraction(used: String, granted: String) -> String {
        switch lang {
        case .korean: return "\(used)/\(granted)일"
        case .english: return "\(used)/\(granted) days"
        case .japanese: return "\(used)/\(granted)日"
        case .chinese: return "\(used)/\(granted)天"
        case .german: return "\(used)/\(granted) Tage"
        case .french: return "\(used)/\(granted) jours"
        }
    }

    /// 부여 일수 중 사용량 표시 (예: "3일 중 1일 사용")
    static func bonusUsedOfGranted(used: String, granted: String) -> String {
        switch lang {
        case .korean: return "\(granted)\(dayUnitSuffix) 중 \(used)\(dayUnitSuffix) 사용"
        case .english: return "\(used) of \(granted) days used"
        case .japanese: return "\(granted)日中\(used)日使用"
        case .chinese: return "\(granted)天中已用\(used)天"
        case .german: return "\(used) von \(granted) Tagen genutzt"
        case .french: return "\(used) jours sur \(granted) utilisés"
        }
    }

    static func bonusEditUsedRemaining(used: String, remaining: String) -> String {
        switch lang {
        case .korean: return "이미 \(used)일 사용됨 · 잔여 \(remaining)일"
        case .english: return "\(used) days used · \(remaining) days remaining"
        case .japanese: return "すでに\(used)日使用 · 残り\(remaining)日"
        case .chinese: return "已使用\(used)天 · 剩余\(remaining)天"
        case .german: return "\(used) Tage genutzt · \(remaining) Tage übrig"
        case .french: return "\(used) jours utilisés · \(remaining) jours restants"
        }
    }

    static var bonusEditTitle: String {
        switch lang {
        case .korean: return "보너스 연차 수정"
        case .english: return "Edit bonus leave"
        case .japanese: return "ボーナス休暇を編集"
        case .chinese: return "编辑奖励年假"
        case .german: return "Bonusurlaub bearbeiten"
        case .french: return "Modifier les congés bonus"
        }
    }

    // MARK: - 마이리얼트립 연계 프로모션
    static var mrtPromoBadge: String {
        switch lang {
        case .korean: return "여행 추천"
        case .english: return "Travel"
        case .japanese: return "旅行"
        case .chinese: return "旅行推荐"
        case .german: return "Reisen"
        case .french: return "Voyage"
        }
    }

    static var mrtPromoTitle: String {
        switch lang {
        case .korean: return "이 연휴, 떠나볼까요?"
        case .english: return "Make the most of this break"
        case .japanese: return "この連休、出かけませんか?"
        case .chinese: return "这个假期,出发吧?"
        case .german: return "Mach das Beste aus dieser Auszeit"
        case .french: return "Profitez au mieux de cette pause"
        }
    }

    static var mrtPromoSubtitle: String {
        switch lang {
        case .korean: return "마이리얼트립에서 항공·숙박·투어를 한 번에 확인해보세요"
        case .english: return "Check flights, hotels, and tours together on MyRealTrip"
        case .japanese: return "マイリアルトリップで航空券・ホテル・ツアーをまとめてチェック"
        case .chinese: return "在MyRealTrip上一站查看机票、酒店和旅游产品"
        case .german: return "Vergleiche Flüge, Hotels und Touren gemeinsam bei MyRealTrip"
        case .french: return "Comparez vols, hôtels et visites en un seul endroit sur MyRealTrip"
        }
    }

    static var mrtPromoCTA: String {
        switch lang {
        case .korean: return "마이리얼트립에서 보기"
        case .english: return "Open MyRealTrip"
        case .japanese: return "マイリアルトリップで見る"
        case .chinese: return "在MyRealTrip中查看"
        case .german: return "MyRealTrip öffnen"
        case .french: return "Ouvrir MyRealTrip"
        }
    }

    // MARK: - 추천 opt-in
    static var mrtOptInTitle: String {
        switch lang {
        case .korean: return "이 연휴에 해보면 좋을 액티비티들이 있는데\n추천해드릴까요?"
        case .english: return "We've found some activities for this break.\nShow recommendations?"
        case .japanese: return "この連休にぴったりのアクティビティがあります。\nおすすめを表示しますか?"
        case .chinese: return "我们为这个假期找到了一些活动。\n要查看推荐吗?"
        case .german: return "Wir haben Aktivitäten für diese Auszeit gefunden.\nEmpfehlungen anzeigen?"
        case .french: return "Nous avons trouvé des activités pour cette pause.\nAfficher les recommandations ?"
        }
    }

    static var mrtOptInSubtitle: String {
        switch lang {
        case .korean: return "마이리얼트립에서 항공·숙박·투어를 함께 살펴봅니다"
        case .english: return "Flights, stays, and tours from MyRealTrip"
        case .japanese: return "マイリアルトリップで航空券・ホテル・ツアーをまとめて確認"
        case .chinese: return "MyRealTrip上的机票、住宿和旅游产品"
        case .german: return "Flüge, Unterkünfte und Touren von MyRealTrip"
        case .french: return "Vols, hébergements et visites sur MyRealTrip"
        }
    }

    static var mrtOptInShow: String {
        switch lang {
        case .korean: return "추천 받기"
        case .english: return "Show me"
        case .japanese: return "見てみる"
        case .chinese: return "查看推荐"
        case .german: return "Zeig mal"
        case .french: return "Voir"
        }
    }

    static var mrtOptInDismiss: String {
        switch lang {
        case .korean: return "괜찮아요"
        case .english: return "No thanks"
        case .japanese: return "結構です"
        case .chinese: return "不用了"
        case .german: return "Nein danke"
        case .french: return "Non merci"
        }
    }

    // MARK: - 추천 이유
    static func mrtCityReason(city: String, season: String, days: Int) -> String {
        switch lang {
        case .korean: return "\(days)일 연휴엔 \(city) — \(season)"
        case .english: return "\(city) for a \(days)-day break — \(season)"
        case .japanese: return "\(days)日の連休には\(city) — \(season)"
        case .chinese: return "\(days)天假期就去\(city) — \(season)"
        case .german: return "\(city) für \(days) freie Tage — \(season)"
        case .french: return "\(city) pour \(days) jours de pause — \(season)"
        }
    }

    static var mrtFlightReasonCheapest: String {
        switch lang {
        case .korean: return "가장 저렴"
        case .english: return "Cheapest"
        case .japanese: return "最安値"
        case .chinese: return "最便宜"
        case .german: return "Am günstigsten"
        case .french: return "Le moins cher"
        }
    }

    static var mrtFlightReasonDirect: String {
        switch lang {
        case .korean: return "직항"
        case .english: return "Direct"
        case .japanese: return "直行"
        case .chinese: return "直飞"
        case .german: return "Direktflug"
        case .french: return "Vol direct"
        }
    }

    static var mrtAccomReasonTopRated: String {
        switch lang {
        case .korean: return "베스트 평점"
        case .english: return "Top rated"
        case .japanese: return "高評価"
        case .chinese: return "高分推荐"
        case .german: return "Bestbewertet"
        case .french: return "Mieux noté"
        }
    }

    static var mrtTourReasonBestseller: String {
        switch lang {
        case .korean: return "베스트셀러"
        case .english: return "Bestseller"
        case .japanese: return "ベストセラー"
        case .chinese: return "热销"
        case .german: return "Bestseller"
        case .french: return "Meilleure vente"
        }
    }

    static var mrtPackageHeader: String {
        switch lang {
        case .korean: return "추천 패키지"
        case .english: return "Suggested package"
        case .japanese: return "おすすめパッケージ"
        case .chinese: return "推荐套餐"
        case .german: return "Paketvorschlag"
        case .french: return "Forfait suggéré"
        }
    }

    static var mrtChangePreference: String {
        switch lang {
        case .korean: return "다음부터 자동으로 안 볼래요"
        case .english: return "Don't show automatically"
        case .japanese: return "次回から自動表示しない"
        case .chinese: return "不再自动显示"
        case .german: return "Nicht mehr automatisch zeigen"
        case .french: return "Ne plus afficher automatiquement"
        }
    }

    // MARK: - 사용자 유형
    static var userTypeEmployee: String {
        switch lang {
        case .korean: return "직장인"
        case .english: return "Employee"
        case .japanese: return "会社員"
        case .chinese: return "上班族"
        case .german: return "Angestellte"
        case .french: return "Salarié"
        }
    }

    static var userTypeLeisure: String {
        switch lang {
        case .korean: return "자유 계획"
        case .english: return "Free Plan"
        case .japanese: return "自由計画"
        case .chinese: return "自由规划"
        case .german: return "Freie Planung"
        case .french: return "Planning libre"
        }
    }

    static var userTypeSection: String {
        switch lang {
        case .korean: return "사용자 유형"
        case .english: return "User Type"
        case .japanese: return "ユーザータイプ"
        case .chinese: return "用户类型"
        case .german: return "Nutzertyp"
        case .french: return "Type d'utilisateur"
        }
    }

    static var userTypeMode: String {
        switch lang {
        case .korean: return "모드"
        case .english: return "Mode"
        case .japanese: return "モード"
        case .chinese: return "模式"
        case .german: return "Modus"
        case .french: return "Mode"
        }
    }

    static var userTypeLeisureDesc: String {
        switch lang {
        case .korean: return "연차 제한 없이 자유롭게 휴가를 계획하고 싶은 분을 위한 모드입니다."
        case .english: return "A mode for those who want to plan vacations freely without leave-day limits."
        case .japanese: return "有給日数の制限なく自由に休暇を計画したい方向けのモードです。"
        case .chinese: return "适合不受年假天数限制、自由规划休假的用户。"
        case .german: return "Ein Modus für alle, die ihren Urlaub frei und ohne Urlaubstage-Limit planen möchten."
        case .french: return "Un mode pour planifier vos vacances librement, sans limite de jours de congé."
        }
    }

    static var leisureVacationSettings: String {
        switch lang {
        case .korean: return "휴가 설정"
        case .english: return "Vacation Settings"
        case .japanese: return "休暇設定"
        case .chinese: return "休假设置"
        case .german: return "Urlaubseinstellungen"
        case .french: return "Réglages des congés"
        }
    }

    static var leisureAnnualGoal: String {
        switch lang {
        case .korean: return "연간 목표 일수"
        case .english: return "Annual Goal Days"
        case .japanese: return "年間目標日数"
        case .chinese: return "年度目标天数"
        case .german: return "Jahresziel in Tagen"
        case .french: return "Objectif annuel (jours)"
        }
    }

    static var leisureUnlimited: String {
        switch lang {
        case .korean: return "무제한"
        case .english: return "Unlimited"
        case .japanese: return "無制限"
        case .chinese: return "无限"
        case .german: return "Unbegrenzt"
        case .french: return "Illimité"
        }
    }

    static var leisurePlannedLeave: String {
        switch lang {
        case .korean: return "계획된 휴가"
        case .english: return "Planned Leave"
        case .japanese: return "計画した休暇"
        case .chinese: return "计划休假"
        case .german: return "Geplanter Urlaub"
        case .french: return "Congés planifiés"
        }
    }

    static var leisureYearStartMonth: String {
        switch lang {
        case .korean: return "기준 연도 시작월"
        case .english: return "Year Start Month"
        case .japanese: return "基準年度の開始月"
        case .chinese: return "起始月份"
        case .german: return "Startmonat des Jahres"
        case .french: return "Mois de début d'année"
        }
    }

    // MARK: - 공휴일 관리
    // MARK: - 방학

    static var childBreakTag: String {
        switch lang {
        case .korean: return "자녀 방학"
        case .english: return "Kids' break"
        case .japanese: return "子どもの休み"
        case .chinese: return "孩子放假"
        case .german: return "Schulferien"
        case .french: return "Vacances scolaires"
        }
    }

    static var myBreakLabel: String {
        switch lang {
        case .korean: return "내 방학"
        case .english: return "My break"
        case .japanese: return "自分の休み"
        case .chinese: return "我的假期"
        case .german: return "Meine Ferien"
        case .french: return "Mes vacances"
        }
    }

    static var breakSectionTitle: String {
        switch lang {
        case .korean: return "방학"
        case .english: return "School Breaks"
        case .japanese: return "長期休み"
        case .chinese: return "假期"
        case .german: return "Ferien"
        case .french: return "Vacances"
        }
    }

    static var breakSectionFooter: String {
        switch lang {
        case .korean: return "자녀 방학은 달력에 표시하고, 그 기간에 쉴 수 있는 추천을 먼저 보여줘요. 내 방학은 공휴일처럼 쉬는 날로 쳐서 연차에서 빠지지 않아요."
        case .english: return "Kids' breaks are shown on the calendar, and suggestions during them come first. My break counts as days off like holidays, so no leave is deducted."
        case .japanese: return "子どもの休みはカレンダーに表示し、その期間のおすすめを優先します。自分の休みは祝日と同じく休日として扱い、有給から差し引きません。"
        case .chinese: return "孩子放假会显示在日历上，并优先推荐该期间的休假。我的假期视同节假日，不扣年假。"
        case .german: return "Schulferien der Kinder werden im Kalender angezeigt und Vorschläge in dieser Zeit zuerst gezeigt. Deine eigenen Ferien zählen wie Feiertage als frei – es wird kein Urlaub abgezogen."
        case .french: return "Les vacances des enfants s’affichent dans le calendrier et les suggestions pendant cette période passent en premier. Vos propres vacances comptent comme des jours fériés : aucun congé n’est décompté."
        }
    }

    static var breakEmpty: String {
        switch lang {
        case .korean: return "추가한 방학이 없어요"
        case .english: return "No breaks added yet"
        case .japanese: return "追加した長期休みはありません"
        case .chinese: return "尚未添加假期"
        case .german: return "Noch keine Ferien eingetragen"
        case .french: return "Aucune période de vacances ajoutée"
        }
    }

    static var breakAddTitle: String {
        switch lang {
        case .korean: return "방학 추가"
        case .english: return "Add Break"
        case .japanese: return "長期休みを追加"
        case .chinese: return "添加假期"
        case .german: return "Ferien hinzufügen"
        case .french: return "Ajouter des vacances"
        }
    }

    static var breakEditTitle: String {
        switch lang {
        case .korean: return "방학 수정"
        case .english: return "Edit Break"
        case .japanese: return "長期休みを編集"
        case .chinese: return "编辑假期"
        case .german: return "Ferien bearbeiten"
        case .french: return "Modifier les vacances"
        }
    }

    static var breakKindSection: String {
        switch lang {
        case .korean: return "누구의 방학인가요?"
        case .english: return "Whose break is it?"
        case .japanese: return "誰の休みですか？"
        case .chinese: return "是谁的假期？"
        case .german: return "Wessen Ferien?"
        case .french: return "Les vacances de qui ?"
        }
    }

    static var breakKindChildDesc: String {
        switch lang {
        case .korean: return "달력에 표시하고 이 기간의 추천을 앞세워요. 내 연차는 그대로 계산해요."
        case .english: return "Shown on the calendar; suggestions in this period come first. Your leave is counted as usual."
        case .japanese: return "カレンダーに表示し、この期間のおすすめを優先します。有給の計算は変わりません。"
        case .chinese: return "在日历上显示，并优先推荐该期间。年假照常计算。"
        case .german: return "Wird im Kalender angezeigt, Vorschläge in diesem Zeitraum kommen zuerst. Dein Urlaub wird normal gezählt."
        case .french: return "Affichées dans le calendrier ; les suggestions sur cette période passent en premier. Vos congés sont comptés normalement."
        }
    }

    static var breakKindMineDesc: String {
        switch lang {
        case .korean: return "교사·학생처럼 나도 쉬는 기간이에요. 연차에서 빠지지 않고, 쉰 기간으로 계산해요."
        case .english: return "For teachers and students: you're off too. No leave is deducted and it counts as rest."
        case .japanese: return "教師や学生のように自分も休む期間です。有給から差し引かず、休んだ期間として扱います。"
        case .chinese: return "像教师、学生一样自己也放假。不扣年假，并计为休息。"
        case .german: return "Für Lehrkräfte und Studierende: Du hast auch frei. Es wird kein Urlaub abgezogen, und es zählt als Erholung."
        case .french: return "Pour les enseignants et étudiants : vous êtes aussi en repos. Aucun congé décompté, la période compte comme du repos."
        }
    }

    static var breakPeriodSection: String {
        switch lang {
        case .korean: return "기간"
        case .english: return "Period"
        case .japanese: return "期間"
        case .chinese: return "期间"
        case .german: return "Zeitraum"
        case .french: return "Période"
        }
    }

    static var breakNameSection: String {
        switch lang {
        case .korean: return "이름"
        case .english: return "Name"
        case .japanese: return "名前"
        case .chinese: return "名称"
        case .german: return "Name"
        case .french: return "Nom"
        }
    }

    static var breakNamePlaceholder: String {
        switch lang {
        case .korean: return "예: 여름방학"
        case .english: return "e.g. Summer break"
        case .japanese: return "例：夏休み"
        case .chinese: return "例如：暑假"
        case .german: return "z. B. Sommerferien"
        case .french: return "ex. : Vacances d’été"
        }
    }

    static var breakDeleteAlertTitle: String {
        switch lang {
        case .korean: return "방학을 삭제할까요?"
        case .english: return "Delete this break?"
        case .japanese: return "この長期休みを削除しますか？"
        case .chinese: return "删除此假期？"
        case .german: return "Diese Ferien löschen?"
        case .french: return "Supprimer ces vacances ?"
        }
    }

    static var breakInvalidRange: String {
        switch lang {
        case .korean: return "종료일이 시작일보다 빨라요"
        case .english: return "End date is before start date"
        case .japanese: return "終了日が開始日より前です"
        case .chinese: return "结束日期早于开始日期"
        case .german: return "Das Enddatum liegt vor dem Startdatum"
        case .french: return "La date de fin précède la date de début"
        }
    }

    static func breakDays(_ n: Int) -> String {
        switch lang {
        case .korean: return "\(n)일"
        case .english: return n == 1 ? "1 day" : "\(n) days"
        case .japanese: return "\(n)日間"
        case .chinese: return "\(n)天"
        case .german: return n == 1 ? "1 Tag" : "\(n) Tage"
        case .french: return n == 1 ? "1 jour" : "\(n) jours"
        }
    }

    static var holidayMgmtTitle: String {
        switch lang {
        case .korean: return "공휴일·방학 관리"
        case .english: return "Holidays & Breaks"
        case .japanese: return "祝日・長期休み管理"
        case .chinese: return "假日·假期管理"
        case .german: return "Feiertage & Ferien"
        case .french: return "Jours fériés et vacances"
        }
    }

    static var holidayMgmtSubtitle: String {
        switch lang {
        case .korean: return "공휴일 추가·숨기기, 방학 추가"
        case .english: return "Add or hide holidays, add school breaks"
        case .japanese: return "祝日の追加・非表示、長期休みの追加"
        case .chinese: return "添加·隐藏假日，添加假期"
        case .german: return "Feiertage verwalten, Ferien eintragen"
        case .french: return "Gérer les jours fériés, ajouter des vacances"
        }
    }

    /// 설정 > 공휴일 — 홈의 "다가오는 휴가" 카드에 공휴일을 함께 보여줄지
    static var showHolidaysInUpcomingTitle: String {
        switch lang {
        case .korean: return "다가오는 휴가에 공휴일 표시"
        case .english: return "Show Holidays in Upcoming"
        case .japanese: return "「今後の休暇」に祝日を表示"
        case .chinese: return "在即将到来的假期中显示节假日"
        case .german: return "Feiertage in Anstehendem zeigen"
        case .french: return "Jours fériés dans À venir"
        }
    }

    static var showHolidaysInUpcomingDescription: String {
        switch lang {
        case .korean: return "홈 화면 카드에 다가오는 공휴일도 함께 보여줘요"
        case .english: return "Also list upcoming public holidays on the home card"
        case .japanese: return "ホームのカードに今後の祝日も表示します"
        case .chinese: return "在主页卡片中一并显示即将到来的节假日"
        case .german: return "Zeigt auf der Startseite auch anstehende Feiertage an"
        case .french: return "Affiche aussi les prochains jours fériés sur l'accueil"
        }
    }

    static var holidayMgmtRestoreAll: String {
        switch lang {
        case .korean: return "기본 공휴일 모두 복원"
        case .english: return "Restore all default holidays"
        case .japanese: return "すべてのデフォルト祝日を復元"
        case .chinese: return "恢复所有默认假日"
        case .german: return "Alle Standard-Feiertage wiederherstellen"
        case .french: return "Rétablir tous les jours fériés par défaut"
        }
    }

    static var holidayDeleteAlertTitle: String {
        switch lang {
        case .korean: return "공휴일 삭제"
        case .english: return "Delete Holiday"
        case .japanese: return "祝日を削除"
        case .chinese: return "删除假日"
        case .german: return "Feiertag löschen"
        case .french: return "Supprimer le jour férié"
        }
    }

    static var holidayDeleteAlertMessage: String {
        switch lang {
        case .korean: return "이 공휴일을 삭제할까요?"
        case .english: return "Delete this holiday?"
        case .japanese: return "この祝日を削除しますか?"
        case .chinese: return "要删除此假日吗?"
        case .german: return "Diesen Feiertag löschen?"
        case .french: return "Supprimer ce jour férié ?"
        }
    }

    static var commonDelete: String {
        switch lang {
        case .korean: return "삭제"
        case .english: return "Delete"
        case .japanese: return "削除"
        case .chinese: return "删除"
        case .german: return "Löschen"
        case .french: return "Supprimer"
        }
    }

    static var commonAdd: String {
        switch lang {
        case .korean: return "추가"
        case .english: return "Add"
        case .japanese: return "追加"
        case .chinese: return "添加"
        case .german: return "Hinzufügen"
        case .french: return "Ajouter"
        }
    }

    static var holidayDefaultSection: String {
        switch lang {
        case .korean: return "기본 공휴일"
        case .english: return "Default Holidays"
        case .japanese: return "デフォルト祝日"
        case .chinese: return "默认假日"
        case .german: return "Standard-Feiertage"
        case .french: return "Jours fériés par défaut"
        }
    }

    static var holidayDefaultFooter: String {
        switch lang {
        case .korean: return "토글을 끄면 캘린더와 추천에서 해당 공휴일이 숨겨집니다."
        case .english: return "Turn off the toggle to hide the holiday from the calendar and recommendations."
        case .japanese: return "トグルをオフにすると、カレンダーとおすすめから該当祝日が非表示になります。"
        case .chinese: return "关闭开关后,该假日将从日历和推荐中隐藏。"
        case .german: return "Wenn du den Schalter ausschaltest, wird der Feiertag im Kalender und in den Empfehlungen ausgeblendet."
        case .french: return "Si vous désactivez l'interrupteur, ce jour férié sera masqué du calendrier et des recommandations."
        }
    }

    static var holidayCustomSection: String {
        switch lang {
        case .korean: return "내 공휴일"
        case .english: return "My Holidays"
        case .japanese: return "マイ祝日"
        case .chinese: return "我的假日"
        case .german: return "Meine Feiertage"
        case .french: return "Mes jours fériés"
        }
    }

    static var holidayCustomEmpty: String {
        switch lang {
        case .korean: return "직접 추가한 공휴일이 없습니다"
        case .english: return "No custom holidays added"
        case .japanese: return "追加した祝日はありません"
        case .chinese: return "未添加自定义假日"
        case .german: return "Keine eigenen Feiertage hinzugefügt"
        case .french: return "Aucun jour férié personnalisé ajouté"
        }
    }

    static var holidayCustomFooter: String {
        switch lang {
        case .korean: return "직접 추가한 공휴일은 캘린더와 추천에 반영됩니다."
        case .english: return "Custom holidays will appear in the calendar and recommendations."
        case .japanese: return "追加した祝日はカレンダーとおすすめに反映されます。"
        case .chinese: return "自定义假日将显示在日历和推荐中。"
        case .german: return "Eigene Feiertage erscheinen im Kalender und in den Empfehlungen."
        case .french: return "Les jours fériés personnalisés apparaissent dans le calendrier et les recommandations."
        }
    }

    static var holidaySubstitute: String {
        switch lang {
        case .korean: return "대체공휴일"
        case .english: return "Substitute Holiday"
        case .japanese: return "振替休日"
        case .chinese: return "调休"
        case .german: return "Ersatzfeiertag"
        case .french: return "Jour férié de remplacement"
        }
    }

    static var holidayAddedByMe: String {
        switch lang {
        case .korean: return "내가 추가"
        case .english: return "Added by me"
        case .japanese: return "自分で追加"
        case .chinese: return "我添加的"
        case .german: return "Von mir hinzugefügt"
        case .french: return "Ajouté par moi"
        }
    }

    /// 펼침/접힘 상태 (VoiceOver accessibilityValue)
    static var a11yExpanded: String {
        switch lang {
        case .korean: return "펼침"
        case .english: return "Expanded"
        case .japanese: return "展開"
        case .chinese: return "已展开"
        case .german: return "Ausgeklappt"
        case .french: return "Développé"
        }
    }

    static var a11yCollapsed: String {
        switch lang {
        case .korean: return "접힘"
        case .english: return "Collapsed"
        case .japanese: return "折りたたみ"
        case .chinese: return "已折叠"
        case .german: return "Eingeklappt"
        case .french: return "Réduit"
        }
    }

    /// 휴가 기록 행 VoiceOver 힌트
    static var editLeaveHint: String {
        switch lang {
        case .korean: return "이중 탭하여 수정"
        case .english: return "Double tap to edit"
        case .japanese: return "ダブルタップで編集"
        case .chinese: return "双击以编辑"
        case .german: return "Doppeltippen zum Bearbeiten"
        case .french: return "Appuyez deux fois pour modifier"
        }
    }

    /// 추천 황금연휴로 등록된 휴가 표식 (VoiceOver)
    static var recommendedMark: String {
        switch lang {
        case .korean: return "추천 황금연휴"
        case .english: return "Recommended holiday"
        case .japanese: return "おすすめの連休"
        case .chinese: return "推荐黄金假期"
        case .german: return "Empfohlene Brückentage"
        case .french: return "Ponts recommandés"
        }
    }

    /// 공휴일 표시 토글 VoiceOver 힌트
    static var holidayVisibilityHint: String {
        switch lang {
        case .korean: return "끄면 달력에서 숨겨집니다"
        case .english: return "Turn off to hide it from the calendar"
        case .japanese: return "オフにするとカレンダーから非表示になります"
        case .chinese: return "关闭后将从日历中隐藏"
        case .german: return "Ausschalten, um ihn im Kalender auszublenden"
        case .french: return "Désactivez pour le masquer du calendrier"
        }
    }

    static var holidayDateSection: String {
        switch lang {
        case .korean: return "날짜"
        case .english: return "Date"
        case .japanese: return "日付"
        case .chinese: return "日期"
        case .german: return "Datum"
        case .french: return "Date"
        }
    }

    static var holidayDatePickerLabel: String {
        switch lang {
        case .korean: return "날짜 선택"
        case .english: return "Select Date"
        case .japanese: return "日付選択"
        case .chinese: return "选择日期"
        case .german: return "Datum wählen"
        case .french: return "Choisir la date"
        }
    }

    static var holidayNameSection: String {
        switch lang {
        case .korean: return "이름"
        case .english: return "Name"
        case .japanese: return "名前"
        case .chinese: return "名称"
        case .german: return "Name"
        case .french: return "Nom"
        }
    }

    static var holidayNamePlaceholder: String {
        switch lang {
        case .korean: return "공휴일 이름 (예: 창립기념일)"
        case .english: return "Holiday name (e.g. Founding Day)"
        case .japanese: return "祝日名 (例: 創立記念日)"
        case .chinese: return "假日名称 (例如: 创立纪念日)"
        case .german: return "Name des Feiertags (z. B. Firmengründung)"
        case .french: return "Nom du jour férié (ex. : Fête de l'entreprise)"
        }
    }

    static var holidayAddTitle: String {
        switch lang {
        case .korean: return "공휴일 추가"
        case .english: return "Add Holiday"
        case .japanese: return "祝日を追加"
        case .chinese: return "添加假日"
        case .german: return "Feiertag hinzufügen"
        case .french: return "Ajouter un jour férié"
        }
    }

    // MARK: - Register / Bonus 등
    static func availableDays(_ daysText: String) -> String {
        switch lang {
        case .korean: return "\(daysText)\(dayUnitSuffix) 사용 가능"
        case .english: return "\(daysText) days available"
        case .japanese: return "\(daysText)日利用可能"
        case .chinese: return "可用\(daysText)天"
        case .german: return "\(daysText) Tage verfügbar"
        case .french: return "\(daysText) jours disponibles"
        }
    }

    static func expiresBy(_ dateText: String) -> String {
        switch lang {
        case .korean: return "~\(dateText) 만료"
        case .english: return "Until \(dateText)"
        case .japanese: return "\(dateText)まで"
        case .chinese: return "至\(dateText)到期"
        case .german: return "Bis \(dateText)"
        case .french: return "Jusqu'au \(dateText)"
        }
    }

    static var bonusDeductNone: String {
        switch lang {
        case .korean: return "보너스 차감 안 함"
        case .english: return "No bonus deduction"
        case .japanese: return "ボーナス差引なし"
        case .chinese: return "不扣除奖励年假"
        case .german: return "Kein Bonusabzug"
        case .french: return "Aucune déduction de bonus"
        }
    }

    static func bonusDeductionSummary(name: String, daysText: String) -> String {
        switch lang {
        case .korean: return "\(name)에서 \(daysText)\(dayUnitSuffix) 차감"
        case .english: return "Deduct \(daysText)\(dayUnitSuffix) from \(name)"
        case .japanese: return "\(name)から\(daysText)日差引"
        case .chinese: return "从\(name)扣除\(daysText)天"
        case .german: return "\(daysText)\(dayUnitSuffix) von \(name) abziehen"
        case .french: return "Déduire \(daysText)\(dayUnitSuffix) de \(name)"
        }
    }

    static func insufficientBonus(_ name: String) -> String {
        switch lang {
        case .korean: return "'\(name)' 보너스의 잔여 일수가 부족합니다."
        case .english: return "Not enough remaining days in '\(name)' bonus."
        case .japanese: return "「\(name)」ボーナスの残日数が不足しています。"
        case .chinese: return "「\(name)」奖励年假剩余天数不足。"
        case .german: return "Im Bonus „\(name)“ sind nicht genug Tage übrig."
        case .french: return "Pas assez de jours restants dans le bonus « \(name) »."
        }
    }

    // MARK: - 섹션 헤더 (마이리얼트립)
    static var sectionFlight: String {
        switch lang {
        case .korean: return "항공권"
        case .english: return "Flights"
        case .japanese: return "航空券"
        case .chinese: return "机票"
        case .german: return "Flüge"
        case .french: return "Vols"
        }
    }

    static var sectionAccommodation: String {
        switch lang {
        case .korean: return "숙박"
        case .english: return "Stays"
        case .japanese: return "宿泊"
        case .chinese: return "住宿"
        case .german: return "Unterkünfte"
        case .french: return "Hébergements"
        }
    }

    static var sectionTour: String {
        switch lang {
        case .korean: return "투어·티켓"
        case .english: return "Tours & Tickets"
        case .japanese: return "ツアー・チケット"
        case .chinese: return "旅游·门票"
        case .german: return "Touren & Tickets"
        case .french: return "Visites et billets"
        }
    }

    // MARK: - 자유 계획 헤더
    static func leisureYearVacationPlan(year: Int) -> String {
        switch lang {
        case .korean: return "\(year)년 휴가 계획"
        case .english: return "\(year) Vacation Plan"
        case .japanese: return "\(year)年の休暇計画"
        case .chinese: return "\(year)年休假计划"
        case .german: return "Urlaubsplan \(year)"
        case .french: return "Plan de congés \(year)"
        }
    }

    // MARK: - 페이월
    static var paywallNoPurchaseFound: String {
        switch lang {
        case .korean: return "구매 기록을 찾을 수 없습니다."
        case .english: return "No purchase records found."
        case .japanese: return "購入履歴が見つかりません。"
        case .chinese: return "未找到购买记录。"
        case .german: return "Keine Käufe gefunden."
        case .french: return "Aucun achat trouvé."
        }
    }

    static var paywallFeaturesHeader: String {
        switch lang {
        case .korean: return "기능"
        case .english: return "Features"
        case .japanese: return "機能"
        case .chinese: return "功能"
        case .german: return "Funktionen"
        case .french: return "Fonctionnalités"
        }
    }

    // MARK: - 런치 스크린
    static var launchTitle: String {
        switch lang {
        case .korean: return "골드위크"
        case .english: return "Goldweek"
        case .japanese: return "ゴールドウィーク"
        case .chinese: return "Goldweek"
        case .german: return "Goldweek"
        case .french: return "Goldweek"
        }
    }

    static var launchSubtitle: String {
        switch lang {
        case .korean: return "똑똑한 연차 관리"
        case .english: return "Smart leave management"
        case .japanese: return "スマートな休暇管理"
        case .chinese: return "智能年假管理"
        case .german: return "Smarte Urlaubsplanung"
        case .french: return "Gestion malin des congés"
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
        case .german:
            switch country {
            case .korea: return "Südkorea"; case .japan: return "Japan"
            case .china: return "China"; case .usa: return "USA"
            case .germany: return "Deutschland"; case .france: return "Frankreich"
            }
        case .french:
            switch country {
            case .korea: return "Corée du Sud"; case .japan: return "Japon"
            case .china: return "Chine"; case .usa: return "États-Unis"
            case .germany: return "Allemagne"; case .france: return "France"
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
        case .german: return "Reisen für diese freien Tage"
        case .french: return "Voyages pour cette pause"
        }
    }

    static var travelSuggestionsSubtitle: String {
        switch lang {
        case .korean: return "연휴 길이와 시즌에 맞춰 골랐어요. 탭하면 마이리얼트립에서 상품을 확인할 수 있어요."
        case .english: return "Picked for this break's length and season. Tap to see options on MyRealTrip."
        case .japanese: return "連休の長さと季節に合わせて選びました。タップでマイリアルトリップの商品を確認。"
        case .chinese: return "根据假期长度和季节精选。点击可在MyRealTrip中查看商品。"
        case .german: return "Passend zu Länge und Jahreszeit dieser freien Tage ausgewählt. Tippe, um Angebote bei MyRealTrip zu sehen."
        case .french: return "Sélection selon la durée et la saison. Touchez pour voir les offres sur MyRealTrip."
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
        case .german:
            switch key {
            case "osaka": return "Osaka"
            case "fukuoka": return "Fukuoka"
            case "tokyo": return "Tokio"
            case "sapporo": return "Sapporo"
            case "kyoto": return "Kyoto"
            case "okinawa": return "Okinawa"
            case "danang": return "Da Nang"
            case "bangkok": return "Bangkok"
            case "taipei": return "Taipeh"
            case "bali": return "Bali"
            case "jeju": return "Jeju"
            case "busan": return "Busan"
            case "guam": return "Guam"
            case "saipan": return "Saipan"
            case "hanoi": return "Hanoi"
            case "phuket": return "Phuket"
            default: return key.capitalized
            }
        case .french:
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
            case "hanoi": return "Hanoï"
            case "phuket": return "Phuket"
            default: return key.capitalized
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
        case .german:
            switch key {
            case "family": return "Familie"
            case "rest": return "Erholung"
            case "foodie": return "Kulinarik"
            case "shopping": return "Shopping"
            case "nature": return "Natur"
            case "romantic": return "Romantik"
            case "culture": return "Kultur"
            case "activity": return "Aktivurlaub"
            default: return key.capitalized
            }
        case .french:
            switch key {
            case "family": return "Famille"
            case "rest": return "Détente"
            case "foodie": return "Gastronomie"
            case "shopping": return "Shopping"
            case "nature": return "Nature"
            case "romantic": return "Romantique"
            case "culture": return "Culture"
            case "activity": return "Activités"
            default: return key.capitalized
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
        case .german:
            switch key {
            case "bestSeason": return "Jetzt Hochsaison"
            case "shortNearby": return "Nah und entspannt"
            case "longResort": return "Ideal für lange Auszeiten"
            case "burnoutRecovery": return "Abschalten und auftanken"
            case "offSeasonDeal": return "Günstig in der Nebensaison"
            case "familyTime": return "Familienfreundlich"
            case "couplesTrip": return "Romantische Auszeit"
            case "weekendEscape": return "Perfekt fürs lange Wochenende"
            case "foodieParadise": return "Paradies für Genießer"
            case "cultureExplore": return "Kultur und Geschichte"
            default: return ""
            }
        case .french:
            switch key {
            case "bestSeason": return "Pleine saison"
            case "shortNearby": return "Proche et facile"
            case "longResort": return "Idéal pour les longs congés"
            case "burnoutRecovery": return "Se ressourcer"
            case "offSeasonDeal": return "Bons prix hors saison"
            case "familyTime": return "Idéal en famille"
            case "couplesTrip": return "Escapade romantique"
            case "weekendEscape": return "Parfait pour un long week-end"
            case "foodieParadise": return "Paradis gourmand"
            case "cultureExplore": return "Culture et histoire"
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
        case .german:
            switch key {
            case "budget": return "Günstig"
            case "mid": return "Mittelklasse"
            case "premium": return "Premium"
            default: return key.capitalized
            }
        case .french:
            switch key {
            case "budget": return "Économique"
            case "mid": return "Milieu de gamme"
            case "premium": return "Premium"
            default: return key.capitalized
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
        case .german: return "Hast du dieses Jahr schon Urlaub genommen?"
        case .french: return "Avez-vous déjà pris des congés cette année ?"
        }
    }

    static var pastLeavePromptDesc: String {
        switch lang {
        case .korean: return "지금까지 사용한 연차를 입력하면 남은 연차를 정확히 파악할 수 있어요"
        case .english: return "Log your past leave to see your accurate remaining balance"
        case .japanese: return "過去の有給を入力して正確な残日数を確認しましょう"
        case .chinese: return "输入已使用的年假以准确查看剩余天数"
        case .german: return "Trag deinen bisherigen Urlaub ein, um den Resturlaub genau zu sehen"
        case .french: return "Saisissez vos congés déjà pris pour connaître précisément votre solde restant"
        }
    }

    static var pastLeaveQuickAdd: String {
        switch lang {
        case .korean: return "빠른 입력"
        case .english: return "Quick Entry"
        case .japanese: return "クイック入力"
        case .chinese: return "快速输入"
        case .german: return "Schnelleingabe"
        case .french: return "Saisie rapide"
        }
    }

    static var pastLeaveTotalUsed: String {
        switch lang {
        case .korean: return "사용한 연차"
        case .english: return "Leave days used"
        case .japanese: return "使用した有給日数"
        case .chinese: return "已使用年假"
        case .german: return "Genommene Urlaubstage"
        case .french: return "Jours de congé pris"
        }
    }

    static var pastLeaveSheetTitle: String {
        switch lang {
        case .korean: return "이전 연차 입력"
        case .english: return "Add Past Leave"
        case .japanese: return "過去の有給を入力"
        case .chinese: return "输入过去的年假"
        case .german: return "Bisherigen Urlaub eintragen"
        case .french: return "Ajouter des congés passés"
        }
    }

    static var pastLeaveSheetDesc: String {
        switch lang {
        case .korean: return "올해 이미 사용한 연차 일수를 입력하세요.\n정확한 날짜는 + 탭에서 개별 입력할 수 있어요."
        case .english: return "Enter the total leave days already used this year.\nFor exact dates, add them individually in the + tab."
        case .japanese: return "今年すでに使用した有給日数を入力してください。\n正確な日付は＋タブから個別入力できます。"
        case .chinese: return "请输入今年已使用的年假天数。\n精确日期可在+标签中单独输入。"
        case .german: return "Gib die Gesamtzahl der dieses Jahr bereits genommenen Urlaubstage ein.\nGenaue Daten kannst du einzeln im Tab + hinzufügen."
        case .french: return "Saisissez le total des jours de congé déjà pris cette année.\nPour des dates précises, ajoutez-les une à une dans l'onglet +."
        }
    }

    static var pastLeaveConfirm: String {
        switch lang {
        case .korean: return "반영하기"
        case .english: return "Confirm"
        case .japanese: return "反映する"
        case .chinese: return "确认"
        case .german: return "Bestätigen"
        case .french: return "Confirmer"
        }
    }

    static var pastLeaveSummaryNote: String {
        switch lang {
        case .korean: return "이전 사용 연차 (일괄 입력)"
        case .english: return "Prior leave (bulk entry)"
        case .japanese: return "過去の有給（一括入力）"
        case .chinese: return "过去的年假（批量录入）"
        case .german: return "Früherer Urlaub (Sammeleingabe)"
        case .french: return "Congés antérieurs (saisie groupée)"
        }
    }

    static var pastLeaveAutoUsed: String {
        switch lang {
        case .korean: return "과거 날짜 선택 시 자동으로 '사용 완료' 처리됩니다"
        case .english: return "Past dates are automatically marked as 'Used'"
        case .japanese: return "過去の日付は自動的に「使用済み」になります"
        case .chinese: return "过去日期会自动标记为「已使用」"
        case .german: return "Vergangene Daten werden automatisch als „Genommen“ markiert"
        case .french: return "Les dates passées sont automatiquement marquées « Pris »"
        }
    }

    // MARK: - 연휴 알림 섹션
    static var upcomingHolidaysSection: String {
        switch lang {
        case .korean: return "연차 없이 쉬는 날"
        case .english: return "Free Days Off"
        case .japanese: return "有給不要の連休"
        case .chinese: return "无需年假的假期"
        case .german: return "Freie Tage ohne Urlaub"
        case .french: return "Jours off sans congé"
        }
    }

    /// 한 해 전체 황금연휴 보기 토글
    static var showAllYearToggle: String {
        switch lang {
        case .korean: return "한 해 전체 보기 (지난 휴가 포함)"
        case .english: return "Show whole year (include past)"
        case .japanese: return "1年分すべて表示(過去も含む)"
        case .chinese: return "查看全年(包含过去)"
        case .german: return "Ganzes Jahr zeigen (inkl. Vergangenes)"
        case .french: return "Afficher toute l'année (passé inclus)"
        }
    }

    static var upcomingHolidaysSectionSubtitle: String {
        switch lang {
        case .korean: return "이미 연휴가 있어요. 연차를 추가하면 더 길게 쉴 수 있어요."
        case .english: return "Holidays are already here. Add leave to extend them."
        case .japanese: return "連休があります。有給を追加して延ばせます。"
        case .chinese: return "已有假期。添加年假可以延长假期。"
        case .german: return "Hier sind schon freie Tage. Mit Urlaub wird die Auszeit länger."
        case .french: return "Il y a déjà des jours de repos. Ajoutez des congés pour les prolonger."
        }
    }

    static var addWithPro: String {
        switch lang {
        case .korean: return "Pro로 일정 추가"
        case .english: return "Add with Pro"
        case .japanese: return "Proで追加"
        case .chinese: return "Pro版添加"
        case .german: return "Mit Pro hinzufügen"
        case .french: return "Ajouter avec Pro"
        }
    }

    static var proUnlockHint: String {
        switch lang {
        case .korean: return "Pro로 업그레이드하면 모든 추천을 일정에 추가할 수 있어요"
        case .english: return "Upgrade to Pro to add all recommendations to your schedule"
        case .japanese: return "Proにアップグレードしてすべての推薦を追加できます"
        case .chinese: return "升级Pro版即可添加所有推荐到日程"
        case .german: return "Mit Pro kannst du alle Empfehlungen zu deinem Plan hinzufügen"
        case .french: return "Passez à Pro pour ajouter toutes les recommandations à votre planning"
        }
    }

    // MARK: - 일정 공유 (CloudKit CKShare)
    static var shareScheduleTitle: String {
        switch lang {
        case .korean: return "일정 공유"
        case .english: return "Schedule Sharing"
        case .japanese: return "スケジュール共有"
        case .chinese: return "日程共享"
        case .german: return "Plan teilen"
        case .french: return "Partage du planning"
        }
    }

    static var shareScheduleSubtitle: String {
        switch lang {
        case .korean: return "가족·친구와 휴가 일정을 실시간으로 공유"
        case .english: return "Share your leave schedule with family & friends in real time"
        case .japanese: return "家族や友達と休暇予定をリアルタイムで共有"
        case .chinese: return "与家人朋友实时共享休假日程"
        case .german: return "Teile deinen Urlaubsplan in Echtzeit mit Familie und Freunden"
        case .french: return "Partagez vos congés en temps réel avec famille et amis"
        }
    }

    static var shareMySection: String {
        switch lang {
        case .korean: return "내 일정 공유"
        case .english: return "Share My Schedule"
        case .japanese: return "自分の予定を共有"
        case .chinese: return "共享我的日程"
        case .german: return "Meinen Plan teilen"
        case .french: return "Partager mon planning"
        }
    }

    static var shareStartButton: String {
        switch lang {
        case .korean: return "공유 시작하기"
        case .english: return "Start Sharing"
        case .japanese: return "共有を開始"
        case .chinese: return "开始共享"
        case .german: return "Teilen starten"
        case .french: return "Commencer le partage"
        }
    }

    static var shareInviteLink: String {
        switch lang {
        case .korean: return "초대 링크 보내기"
        case .english: return "Send Invite Link"
        case .japanese: return "招待リンクを送る"
        case .chinese: return "发送邀请链接"
        case .german: return "Einladungslink senden"
        case .french: return "Envoyer le lien d'invitation"
        }
    }

    static var shareStatusActive: String {
        switch lang {
        case .korean: return "공유 중"
        case .english: return "Sharing Active"
        case .japanese: return "共有中"
        case .chinese: return "共享中"
        case .german: return "Teilen aktiv"
        case .french: return "Partage actif"
        }
    }

    static func shareParticipants(_ count: Int) -> String {
        switch lang {
        case .korean: return "참여자 \(count)명"
        case .english: return count == 1 ? "1 participant" : "\(count) participants"
        case .japanese: return "参加者\(count)人"
        case .chinese: return "\(count)位参与者"
        case .german: return count == 1 ? "1 Teilnehmer" : "\(count) Teilnehmer"
        case .french: return count == 1 ? "1 participant" : "\(count) participants"
        }
    }

    static var shareNoParticipants: String {
        switch lang {
        case .korean: return "아직 참여자가 없어요. 초대 링크를 보내보세요."
        case .english: return "No participants yet. Send an invite link."
        case .japanese: return "まだ参加者がいません。招待リンクを送ってみましょう。"
        case .chinese: return "还没有参与者。发送邀请链接试试吧。"
        case .german: return "Noch keine Teilnehmer. Sende einen Einladungslink."
        case .french: return "Aucun participant pour l'instant. Envoyez un lien d'invitation."
        }
    }

    static var shareSyncNow: String {
        switch lang {
        case .korean: return "지금 동기화"
        case .english: return "Sync Now"
        case .japanese: return "今すぐ同期"
        case .chinese: return "立即同步"
        case .german: return "Jetzt synchronisieren"
        case .french: return "Synchroniser"
        }
    }

    static func shareLastSync(_ date: String) -> String {
        switch lang {
        case .korean: return "마지막 동기화: \(date)"
        case .english: return "Last synced: \(date)"
        case .japanese: return "最終同期: \(date)"
        case .chinese: return "上次同步: \(date)"
        case .german: return "Zuletzt synchronisiert: \(date)"
        case .french: return "Dernière synchro : \(date)"
        }
    }

    static var shareStop: String {
        switch lang {
        case .korean: return "공유 중지"
        case .english: return "Stop Sharing"
        case .japanese: return "共有を停止"
        case .chinese: return "停止共享"
        case .german: return "Teilen beenden"
        case .french: return "Arrêter le partage"
        }
    }

    static var shareStopConfirmTitle: String {
        switch lang {
        case .korean: return "공유를 중지할까요?"
        case .english: return "Stop sharing?"
        case .japanese: return "共有を停止しますか?"
        case .chinese: return "要停止共享吗?"
        case .german: return "Teilen beenden?"
        case .french: return "Arrêter le partage ?"
        }
    }

    static var shareStopConfirmMessage: String {
        switch lang {
        case .korean: return "공유된 일정이 모든 참여자의 기기에서 제거됩니다. 내 기기의 데이터는 그대로 유지됩니다."
        case .english: return "Your shared schedule will be removed from all participants' devices. Data on your device stays intact."
        case .japanese: return "共有された予定はすべての参加者のデバイスから削除されます。自分のデバイスのデータはそのまま残ります。"
        case .chinese: return "共享的日程将从所有参与者的设备中移除。您设备上的数据保持不变。"
        case .german: return "Dein geteilter Plan wird von den Geräten aller Teilnehmer entfernt. Die Daten auf deinem Gerät bleiben erhalten."
        case .french: return "Votre planning partagé sera supprimé des appareils de tous les participants. Les données de votre appareil sont conservées."
        }
    }

    static var shareReceivedSection: String {
        switch lang {
        case .korean: return "공유받은 일정"
        case .english: return "Shared With Me"
        case .japanese: return "共有された予定"
        case .chinese: return "收到的共享"
        case .german: return "Mit mir geteilt"
        case .french: return "Partagés avec moi"
        }
    }

    static var shareReceivedEmpty: String {
        switch lang {
        case .korean: return "아직 공유받은 일정이 없어요.\n가족이나 친구가 보낸 초대 링크를 열면 여기에 표시됩니다."
        case .english: return "No shared schedules yet.\nOpen an invite link from family or friends and it will appear here."
        case .japanese: return "まだ共有された予定がありません。\n家族や友達からの招待リンクを開くとここに表示されます。"
        case .chinese: return "还没有收到共享的日程。\n打开家人或朋友发送的邀请链接后会显示在这里。"
        case .german: return "Noch keine geteilten Pläne.\nÖffne einen Einladungslink von Familie oder Freunden, dann erscheint er hier."
        case .french: return "Aucun planning partagé pour l'instant.\nOuvrez un lien d'invitation de vos proches et il apparaîtra ici."
        }
    }

    static var shareLeaveButton: String {
        switch lang {
        case .korean: return "공유 나가기"
        case .english: return "Leave Share"
        case .japanese: return "共有から退出"
        case .chinese: return "退出共享"
        case .german: return "Teilen verlassen"
        case .french: return "Quitter le partage"
        }
    }

    static func shareLeaveConfirmMessage(_ name: String) -> String {
        switch lang {
        case .korean: return "\(name)님의 일정 공유에서 나갑니다. 다시 보려면 새 초대 링크가 필요합니다."
        case .english: return "You will leave \(name)'s shared schedule. You'll need a new invite link to see it again."
        case .japanese: return "\(name)さんの予定共有から退出します。再度見るには新しい招待リンクが必要です。"
        case .chinese: return "您将退出\(name)的日程共享。再次查看需要新的邀请链接。"
        case .german: return "Du verlässt den geteilten Plan von \(name). Um ihn wieder zu sehen, brauchst du einen neuen Einladungslink."
        case .french: return "Vous quittez le planning partagé de \(name). Il vous faudra un nouveau lien d'invitation pour le revoir."
        }
    }

    static var shareICloudRequired: String {
        switch lang {
        case .korean: return "iCloud 로그인이 필요합니다. 설정 앱에서 iCloud에 로그인해주세요."
        case .english: return "iCloud sign-in required. Please sign in to iCloud in the Settings app."
        case .japanese: return "iCloudへのサインインが必要です。設定アプリでiCloudにサインインしてください。"
        case .chinese: return "需要登录iCloud。请在设置应用中登录iCloud。"
        case .german: return "iCloud-Anmeldung erforderlich. Bitte melde dich in den Einstellungen bei iCloud an."
        case .french: return "Connexion à iCloud requise. Connectez-vous à iCloud dans l'app Réglages."
        }
    }

    static func shareCKTitle(_ name: String) -> String {
        switch lang {
        case .korean: return "\(name)님의 휴가 일정"
        case .english: return "\(name)'s Leave Schedule"
        case .japanese: return "\(name)さんの休暇予定"
        case .chinese: return "\(name)的休假日程"
        case .german: return "Urlaubsplan von \(name)"
        case .french: return "Congés de \(name)"
        }
    }

    static var shareOwnerFallback: String {
        switch lang {
        case .korean: return "이름 없는 사용자"
        case .english: return "Unknown User"
        case .japanese: return "名前のないユーザー"
        case .chinese: return "未知用户"
        case .german: return "Unbekannter Nutzer"
        case .french: return "Utilisateur inconnu"
        }
    }

    static var shareNoUpcoming: String {
        switch lang {
        case .korean: return "예정된 휴가가 없어요"
        case .english: return "No upcoming leaves"
        case .japanese: return "予定されている休暇はありません"
        case .chinese: return "没有即将到来的休假"
        case .german: return "Kein anstehender Urlaub"
        case .french: return "Aucun congé à venir"
        }
    }

    static func shareUpcomingCount(_ count: Int) -> String {
        switch lang {
        case .korean: return "다가오는 휴가 \(count)건"
        case .english: return count == 1 ? "1 upcoming leave" : "\(count) upcoming leaves"
        case .japanese: return "今後の休暇\(count)件"
        case .chinese: return "\(count)个即将到来的休假"
        case .german: return count == 1 ? "1 anstehender Urlaub" : "\(count) anstehende Urlaube"
        case .french: return count == 1 ? "1 congé à venir" : "\(count) congés à venir"
        }
    }

    static var shareErrorTitle: String {
        switch lang {
        case .korean: return "공유 오류"
        case .english: return "Sharing Error"
        case .japanese: return "共有エラー"
        case .chinese: return "共享错误"
        case .german: return "Fehler beim Teilen"
        case .french: return "Erreur de partage"
        }
    }

    static func shareErrorGeneric(_ message: String) -> String {
        switch lang {
        case .korean: return "공유 작업에 실패했습니다: \(message)"
        case .english: return "Sharing operation failed: \(message)"
        case .japanese: return "共有操作に失敗しました: \(message)"
        case .chinese: return "共享操作失败: \(message)"
        case .german: return "Teilen fehlgeschlagen: \(message)"
        case .french: return "Échec du partage : \(message)"
        }
    }

    static var shareFooterPrivacy: String {
        switch lang {
        case .korean: return "휴가 날짜와 종류만 공유되며, 메모는 공유되지 않습니다."
        case .english: return "Only leave dates and types are shared. Notes are never shared."
        case .japanese: return "休暇の日付と種類のみ共有され、メモは共有されません。"
        case .chinese: return "仅共享休假日期和类型，备注不会被共享。"
        case .german: return "Nur Urlaubsdaten und -arten werden geteilt. Notizen bleiben privat."
        case .french: return "Seuls les dates et types de congé sont partagés. Les notes ne le sont jamais."
        }
    }

    // MARK: - 가족 탭
    static var tabFamily: String {
        switch lang {
        case .korean: return "가족"
        case .english: return "Family"
        case .japanese: return "家族"
        case .chinese: return "家人"
        case .german: return "Familie"
        case .french: return "Famille"
        }
    }

    static var familyNavTitle: String {
        switch lang {
        case .korean: return "가족 일정"
        case .english: return "Family Schedules"
        case .japanese: return "家族の予定"
        case .chinese: return "家人日程"
        case .german: return "Familienpläne"
        case .french: return "Plannings famille"
        }
    }

    static var familyOnLeave: String {
        switch lang {
        case .korean: return "휴가 중"
        case .english: return "On Leave"
        case .japanese: return "休暇中"
        case .chinese: return "休假中"
        case .german: return "Im Urlaub"
        case .french: return "En congé"
        }
    }

    static func familyDday(_ days: Int) -> String {
        switch lang {
        case .korean: return "D-\(days)"
        case .english: return days == 1 ? "in 1 day" : "in \(days) days"
        case .japanese: return "あと\(days)日"
        case .chinese: return "还有\(days)天"
        case .german: return days == 1 ? "in 1 Tag" : "in \(days) Tagen"
        case .french: return days == 1 ? "dans 1 jour" : "dans \(days) jours"
        }
    }
}
