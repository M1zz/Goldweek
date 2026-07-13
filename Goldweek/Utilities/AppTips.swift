//
//  AppTips.swift
//  Goldweek
//
//  TipKit 기능 발견 팁 — 새 기능을 화면 맥락 안에서 자연스럽게 소개한다.
//  표시 빈도는 GoldweekApp의 Tips.configure(displayFrequency: .daily)로 하루 1개씩 노출되고,
//  해당 기능을 실제로 사용하면 invalidate 되어 다시 보이지 않는다.
//

import SwiftUI
import TipKit

enum AppTips {
    static let photoImport = PhotoImportTip()
    static let familyShare = FamilyShareTip()
    static let timeMachine = TimeMachineTip()
    static let calendarTap = CalendarTapTip()
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
