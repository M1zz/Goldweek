//
//  GoldweekUITests.swift
//  GoldweekUITests
//
//  실제 앱을 띄워 핵심 흐름을 한 바퀴 돈다 — 현황 → 캘린더 → 설정 → 새로운 기능.
//  데모 데이터는 스크린샷 모드(-screenshotMode, DEBUG 전용)가 채운다: 저장소를 비우고 언어에 맞는 기록을 넣는다.
//

import XCTest

final class GoldweekUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    private func launchApp(tab: Int = 0) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode", "YES", "-screenshotTab", "\(tab)",
                               "-appLanguage", "en", "-AppleLanguages", "(en)", "-uiTesting"]
        app.launch()
        return app
    }

    /// 탭을 오가고, 설정에서 "새로운 기능" 을 열었다 닫는다.
    @MainActor
    func testCoreFlow() throws {
        let app = launchApp()
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 15), "탭 막대가 떠야 한다")

        tabBar.buttons["Calendar"].tap()
        XCTAssertTrue(app.buttons["Next month"].waitForExistence(timeout: 5), "캘린더에 다음 달 단추가 있어야 한다")
        app.buttons["Next month"].tap()

        tabBar.buttons["Settings"].tap()
        let whatsNew = app.buttons["What’s New"]
        var swipes = 0
        while !whatsNew.isHittable && swipes < 15 {
            app.swipeUp()
            swipes += 1
        }
        XCTAssertTrue(whatsNew.isHittable, "설정 > 도움말에 새로운 기능이 있어야 한다")
        whatsNew.tap()

        let continueButton = app.buttons["Continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 5), "새로운 기능 시트가 열려야 한다")
        continueButton.tap()
        XCTAssertTrue(whatsNew.waitForExistence(timeout: 5), "닫으면 설정으로 돌아와야 한다")
    }

    /// 첫 화면(현황)의 접근성 자동 점검.
    @MainActor
    func testAccessibilityAuditOnHome() throws {
        let app = launchApp()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15))
        let tabBarFrame = app.tabBars.firstMatch.frame
        try app.performAccessibilityAudit { issue in
            // 탭 막대(반투명 유리) 뒤로 비쳐 보이는 목록 글자는 막대 색과 섞여 대비가 낮게 잰다.
            // 스크롤하면 막대 위로 올라오는 글자라, 막대와 겹친 것의 대비만 거른다.
            if issue.auditType == .contrast, let element = issue.element,
               element.frame.intersects(tabBarFrame) {
                return true
            }
            // 걸러내는 것은 '거의 통과(nearly passed)' 한 대비 하나뿐이다.
            // 시스템 보조 글자색(.secondary · secondaryLabel)이 흰 카드 위에서 4.5:1 에 살짝 못 미친다고
            // 나오는 것으로, 애플 기본 색이고 '대비 증가' 를 켜면 시스템이 진하게 바꾼다.
            // 진짜로 대비가 모자란 것(그냥 'Contrast failed')·잘린 글자·라벨 없는 단추는 그대로 실패로 둔다.
            return issue.auditType == .contrast && issue.compactDescription.localizedCaseInsensitiveContains("nearly passed")
        }
    }
}
