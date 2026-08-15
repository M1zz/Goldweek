//
//  AppTips.swift
//  Goldweek
//
//  TipKit 기능 발견 팁 — 새 기능을 화면 맥락 안에서 자연스럽게 소개한다.
//  표시 빈도는 GoldweekApp의 Tips.configure(displayFrequency: .daily)로 하루 1개씩 노출되고,
//  해당 기능을 실제로 사용하면 invalidate 되어 다시 보이지 않는다.
//
//  ⚠️ 팁은 "이런 게 있어요" 한 줄이다. 사용법을 길게 설명해야 하면 팁이 아니라
//     사용법 시트(`TutorialView`)에 넣는다 — 팁이 길어지면 아무도 안 읽는다.
//

import SwiftUI
import TipKit

enum AppTips {
    static let photoImport = PhotoImportTip()
    static let familyShare = FamilyShareTip()
    static let timeMachine = TimeMachineTip()
    static let calendarTap = CalendarTapTip()
    static let recommendation = RecommendationTip()
    static let sharePlan = SharePlanTip()
    static let bonusLeave = BonusLeaveTip()
    static let leaveHistory = LeaveHistoryTip()

    /// 설정 > 도움말의 "기능 팁 다시 보기".
    ///
    /// TipKit의 저장소 초기화(`Tips.resetDatastore()`)는 **`Tips.configure()` 전에만** 유효해서
    /// 지금 당장 되돌릴 수가 없다. 그래서 요청만 남겨 두고 다음 실행 때 앱 진입점에서 처리한다.
    /// (사용자에게도 "다시 실행하면 나타난다"고 알려 준다 — 눌렀는데 아무 일도 없으면 안 되니까)
    static let resetRequestKey = "tips.resetRequested"

    static func requestResetOnNextLaunch() {
        UserDefaults.standard.set(true, forKey: resetRequestKey)
    }

    /// 앱 진입점에서 `Tips.configure()` **직전에** 부른다.
    static func performPendingResetIfNeeded() {
        guard UserDefaults.standard.bool(forKey: resetRequestKey) else { return }
        UserDefaults.standard.set(false, forKey: resetRequestKey)
        try? Tips.resetDatastore()
    }
}

/// 사진으로 휴가 등록 — 홈 카드의 스캔 버튼에 popover로 표시
struct PhotoImportTip: Tip {
    var title: Text { Text(Strings.tipPhotoImportTitle) }
    var message: Text? { Text(Strings.tipPhotoImportMessage) }
    var image: Image? { Image(systemName: "doc.text.viewfinder") }
    var options: [any TipOption] { MaxDisplayCount(3) }
}

/// 가족과 일정 공유 — 홈 화면에 인라인으로 표시
struct FamilyShareTip: Tip {
    var title: Text { Text(Strings.tipFamilyShareTitle) }
    var message: Text? { Text(Strings.tipFamilyShareMessage) }
    var image: Image? { Image(systemName: "person.2.fill") }
    var options: [any TipOption] { MaxDisplayCount(3) }
}

/// 타임머신 — 설정의 타임머신 행에 popover로 표시
struct TimeMachineTip: Tip {
    var title: Text { Text(Strings.tipTimeMachineTitle) }
    var message: Text? { Text(Strings.tipTimeMachineMessage) }
    var image: Image? { Image(systemName: "clock.arrow.circlepath") }
    var options: [any TipOption] { MaxDisplayCount(2) }
}

/// 캘린더 날짜 탭 등록 — 캘린더 탭에 인라인으로 표시
struct CalendarTapTip: Tip {
    var title: Text { Text(Strings.tipCalendarTapTitle) }
    var message: Text? { Text(Strings.tipCalendarTapMessage) }
    var image: Image? { Image(systemName: "hand.tap.fill") }
    var options: [any TipOption] { MaxDisplayCount(2) }
}

/// 추천 연휴 — 캘린더의 추천 표시를 눌러 보게 한다
struct RecommendationTip: Tip {
    var title: Text { Text(Strings.tipRecommendTitle) }
    var message: Text? { Text(Strings.tipRecommendMessage) }
    var image: Image? { Image(systemName: "sparkles") }
    var options: [any TipOption] { MaxDisplayCount(3) }
}

/// 연차 현황 공유 — 홈 카드의 공유 버튼에 popover로 표시
struct SharePlanTip: Tip {
    var title: Text { Text(Strings.tipSharePlanTitle) }
    var message: Text? { Text(Strings.tipSharePlanMessage) }
    var image: Image? { Image(systemName: "square.and.arrow.up") }
    var options: [any TipOption] { MaxDisplayCount(2) }
}

/// 보너스 연차 — 설정의 보너스 섹션에 표시
struct BonusLeaveTip: Tip {
    var title: Text { Text(Strings.tipBonusLeaveTitle) }
    var message: Text? { Text(Strings.tipBonusLeaveMessage) }
    var image: Image? { Image(systemName: "gift.fill") }
    var options: [any TipOption] { MaxDisplayCount(2) }
}

/// 휴가 사용 내역 — 홈 하단 버튼에 popover로 표시
struct LeaveHistoryTip: Tip {
    var title: Text { Text(Strings.tipLeaveHistoryTitle) }
    var message: Text? { Text(Strings.tipLeaveHistoryMessage) }
    var image: Image? { Image(systemName: "list.bullet.rectangle") }
    var options: [any TipOption] { MaxDisplayCount(2) }
}
