// swift-tools-version: 6.0
//
//  GoldweekCore — 화면과 저장소(SwiftData @Model)를 뺀 기반 코드.
//  문구(23개 언어) · 값 타입 · 공휴일 데이터 · 계산. 화면을 고쳐도 이 모듈은 다시 컴파일하지 않는다.
//  ⚠️ @Model 클래스는 앱에 둔다 — 저장소 스키마가 모듈 이름에 묶이지 않게.
//
import PackageDescription

let package = Package(
    name: "GoldweekCore",
    platforms: [.iOS(.v17), .macCatalyst(.v17)],
    products: [.library(name: "GoldweekCore", targets: ["GoldweekCore"])],
    targets: [
        .target(
            name: "GoldweekCore",
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("MemberImportVisibility"),
            ]
        ),
        .testTarget(name: "GoldweekCoreTests", dependencies: ["GoldweekCore"]),
    ],
    swiftLanguageModes: [.v5]
)
