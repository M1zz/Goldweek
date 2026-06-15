//
//  GoldweekSecrets.example.swift
//  Goldweek
//
//  📋 템플릿 파일입니다 (이 파일은 커밋됩니다 / 실제 키 ❌).
//
//  사용법:
//    1. 이 파일을 같은 폴더에 GoldweekSecrets.swift 로 복사
//         cp Goldweek/GoldweekSecrets.example.swift Goldweek/GoldweekSecrets.swift
//    2. 복사본의 mrtAPIKey 값에 실제 마이리얼트립(MRT) API 키를 넣기
//       (키가 없으면 그대로 둬도 됨 — MRT 여행 추천만 비활성화되고 앱은 정상 동작)
//
//  ⚠️ 복사본 GoldweekSecrets.swift 는 .gitignore 처리되어 커밋되지 않습니다.
//     실제 키는 절대 이 example 파일에 넣지 마세요.
//

enum GoldweekSecrets {
    /// 마이리얼트립 service-api 키. 환경변수 MRT_API_KEY 가 있으면 그쪽이 우선합니다.
    /// 플레이스홀더 값은 코드에서 자동으로 nil 처리됩니다.
    static let mrtAPIKey = "YOUR_MRT_API_KEY_HERE"
}
