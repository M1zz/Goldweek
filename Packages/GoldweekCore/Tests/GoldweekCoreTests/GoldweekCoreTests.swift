import XCTest
@testable import GoldweekCore

final class GoldweekCoreTests: XCTestCase {
    /// 모든 언어에 문구가 있다 (빠지면 DEBUG 에서 `Strings.pick` 이 멈춘다).
    func testEveryLanguageHasAName() {
        for lang in AppLanguage.allCases {
            XCTAssertFalse(lang.rawValue.isEmpty)
        }
    }
}
