# Goldweek 📅 (골드위크)

<p align="center">
  <img src="docs/images/app-icon.png" width="120" alt="Goldweek App Icon">
</p>

<p align="center">
  <strong>스마트 연차 관리 & 황금연휴 플래너</strong><br>
  최소 연차로 최대 연휴를 — 공휴일을 활용한 최적의 휴가 조합을 추천받으세요.
</p>

<p align="center">
  <a href="https://apps.apple.com/app/id6739899592">
    <img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83" alt="Download on the App Store" height="50">
  </a>
</p>

<p align="center">
  <a href="https://m1zz.github.io/Goldweek/">🌐 Landing Page</a> •
  <a href="SUPPORT.md">📖 Support</a> •
  <a href="#features">✨ Features</a>
</p>

---

## Features

### 📊 연차 관리
- 총 연차, 사용 연차, 남은 연차를 한눈에 확인
- 연차, 반차(오전/오후), 반반차 등 다양한 휴가 유형 지원
- 회사 회계연도에 맞춰 연차 기준월 설정

### ✨ AI 휴가 추천
- 공휴일과 주말을 활용한 최적의 휴가 조합 추천
- 최소 연차로 최대 연휴를 만드는 "황금연휴" 플랜
- 개인 선호도(계절, 기간, 활동) 기반 맞춤 추천

### 🎁 보너스 연차
- 대체휴무, 포상휴가, 리프레시 휴가 등 추가 연차 관리
- 유효기간 설정으로 만료 전 알림

### 📱 홈 위젯
- 앱을 열지 않아도 남은 연차 확인
- 다가오는 휴가 일정 표시

### ☁️ iCloud 백업
- 소중한 연차 기록을 iCloud에 안전하게 백업
- 새 기기에서 간편하게 복원

### 🌏 4개국 지원
- 한국 🇰🇷, 일본 🇯🇵, 중국 🇨🇳, 미국 🇺🇸 공휴일
- 2024~2030년 공휴일 데이터 포함
- 다국어 UI (한국어, English, 日本語, 中文)

---

## Screenshots

| Home | Calendar | Recommendations | Register |
|:----:|:--------:|:---------------:|:--------:|
| ![Home](docs/images/screenshot-1.png) | ![Calendar](docs/images/screenshot-2.png) | ![Recommendations](docs/images/screenshot-3.png) | ![Register](docs/images/screenshot-4.png) |

---

## Requirements

- iOS 17.0+
- iPhone

---

## Tech Stack

- **SwiftUI** - 선언형 UI
- **SwiftData** - 로컬 데이터 저장
- **WidgetKit** - 홈 화면 위젯
- **StoreKit 2** - 인앱 결제 (Pro 버전)
- **CloudKit** - iCloud 백업

---

## Support

문제가 발생하거나 개선 의견이 있으시면 [SUPPORT.md](SUPPORT.md)를 참고하거나 이메일로 연락해주세요.

📧 support@goldweek.app  *(이메일 주소는 추후 변경 예정)*

---

## API 설정 (마이리얼트립 service-api)

추천 탭의 여행 큐레이션 카드를 실제 마이리얼트립 상품으로 교체하려면 API 키가 필요합니다.

### 키 설정 방법 (개발 환경)

**옵션 A — Xcode Run Scheme 환경변수** (권장 — 디버그 시 안전)

1. Xcode에서 `Product → Scheme → Edit Scheme...`
2. `Run → Arguments → Environment Variables`
3. 추가:
   - Name: `MRT_API_KEY`
   - Value: `<발급받은_키>`

**옵션 B — GoldweekSecrets.swift 파일** (배포 빌드용)

1. `Goldweek/GoldweekSecrets.swift` 파일 생성 (`.gitignore` 처리됨)
2. 다음 코드 작성:
   ```swift
   enum GoldweekSecrets {
       static let mrtAPIKey = "<발급받은_키>"
   }
   ```
3. `RecommendationsView.swift`의 `MRTConfig.apiKey`에서 fallback 라인 주석 해제

### API 명세 통합 (받으면 채울 위치)

`Goldweek/Views/RecommendationsView.swift` 하단의 `MRTConfig` 및 `MyRealTripAPIClient`에 다음을 채워 넣으세요:

1. **`MRTConfig.baseURL`** — 마이리얼트립 service-api 베이스 URL
2. **`MRTConfig.authHeader`** — 인증 헤더 형태 (Bearer / X-API-Key 등)
3. **`MRTTourTicket / MRTAccommodation / MRTFlight` 모델의 `CodingKeys`** — 응답 필드명 매핑
4. **`MyRealTripAPIClient.searchTourTickets / searchAccommodations / searchFlights`의 `path`** — 정확한 엔드포인트 경로

### 보안 주의

- **API 키는 절대 Git에 커밋하지 마세요.** `.gitignore`에 secrets 패턴 등록 완료
- 마이리얼트립 약관에 따라 **iOS 앱 클라이언트에서 직접 호출 가능** (확인됨)
- 다만 키가 앱 번들에 포함되므로 디컴파일 시 노출 가능성은 있습니다. 다음 추가 보호 권장:
  - 가벼운 난독화 (Base64/XOR 등)
  - 키별 호출 한도 모니터링 (마이리얼트립 대시보드)
  - 의심 트래픽 발견 시 키 즉시 재발급
- **민감한 결제·예약 API**가 추후 추가되면 그때는 백엔드 경유 권장

---

## Firebase Analytics + Crashlytics 셋업

`AnalyticsService.swift`는 `#if canImport(FirebaseCore)` 가드로 작성되어, Firebase SDK가 없어도 빌드됩니다. SDK 추가 시 자동 활성화.

### 1. Firebase 콘솔에서 프로젝트 생성

1. [console.firebase.google.com](https://console.firebase.google.com/) → "프로젝트 추가" → 이름: `Goldweek`
2. Google Analytics 활성화 (Yes)
3. **iOS 앱 등록**:
   - Bundle ID: `com.Ysoup.LeaveWise` (Bundle ID 보존 정책)
   - 닉네임: Goldweek
4. `GoogleService-Info.plist` 다운로드 → `Goldweek/` 폴더에 추가 (Xcode "Copy items if needed" + Goldweek 메인 타겟만 체크)

### 2. SDK 추가 (Swift Package Manager)

Xcode → File → Add Package Dependencies → `https://github.com/firebase/firebase-ios-sdk`

**필요한 Products** (Goldweek 메인 타겟에만):
- `FirebaseAnalyticsWithoutAdIdSupport` ⭐ (IDFA 사용 안 함, ATT 모달 안 뜸)
- `FirebaseCrashlytics`

### 3. Crashlytics build phase 추가 (dSYM 자동 업로드)

Xcode → Goldweek 타겟 → Build Phases → "+" → New Run Script Phase

- 이름: `Crashlytics Upload Symbols`
- Script:
  ```bash
  "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
  ```
- Input Files (1번 누르고 추가):
  ```
  ${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
  $(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)
  ```

### 4. 자동으로 활성화되는 이벤트

`AnalyticsService.swift`가 코드에 이미 통합되어 있어 SDK 추가 후 다음 이벤트 자동 수집:

| 이벤트 | 발생 시점 | 파라미터 |
|---|---|---|
| `onboarding_complete` | 온보딩 완료 | country, total_leave |
| `leave_added` | 휴가 등록 | type, days, is_recommended |
| `leave_deleted` | 휴가 삭제 | type |
| `recommendation_added` | 추천 일정 추가 | days, efficiency |
| `mrt_optin_show` / `mrt_optin_dismiss` | 마이리얼트립 opt-in | - |
| `mrt_card_tap` | 항공/숙박/투어 카드 탭 | category, city |
| `paywall_view` | 페이월 진입 | source |
| `paywall_purchase` | Pro 구매 시도 | success, product_id |
| `screen_view` | 화면 전환 | (자동) |

크래시는 별도 코드 없이 자동 수집. 비치명적 에러는 `AnalyticsService.recordError()`로 명시 호출 (이미 SwiftData 저장 실패 등에 통합됨).

### 5. 보안 / 개인정보

- `GoogleService-Info.plist`는 **Git에 커밋 OK** (클라이언트용 키만 포함, 노출 안전)
- IDFA를 안 쓰는 `FirebaseAnalyticsWithoutAdIdSupport` 사용 → ATT 권한 요청 모달 안 뜸
- 개인정보 처리방침(`SUPPORT.md`)에 분석 SDK 사용 명시 완료
- App Store Connect → 앱 → 개인정보 처리방침 섹션도 동일하게 업데이트 필요

---

## 마이리얼트립 MCP를 LLM과 함께 쓰기

Goldweek 사용자가 ChatGPT, Claude Desktop, Claude Code, Cursor 같은 **AI 에이전트**에서 마이리얼트립 MCP를 등록해두면, Goldweek가 추천한 연휴 일정에 맞는 실제 항공권·숙박·투어를 **자연어로 검색**할 수 있습니다.

**MCP 엔드포인트**: `https://mcp-servers.myrealtrip.com/mcp`
**인증**: 별도 인증 불필요 (공개 MCP 서버)

### 제공 도구 11종

| 카테고리 | 도구 |
|---|---|
| 숙소 | `searchStays`, `getStayDetail` |
| 항공 | `searchDomesticFlights`, `searchInternationalFlights`, `getPromotionAirlines`, `flightsFareCalendar` |
| 투어/액티비티 | `searchTnas`, `getTnaDetail`, `getTnaOptions`, `getCategoryList` |
| 공통 | `getCurrentTime` |

### 1. Claude Desktop

`Settings → 커넥터 → 사용자 지정 → + 커스텀 커넥터 추가`

- 이름: `myrealtrip`
- 주소: `https://mcp-servers.myrealtrip.com/mcp`

### 2. Claude Code (CLI)
```bash
claude mcp add --transport http myrealtrip https://mcp-servers.myrealtrip.com/mcp
```

### 3. Cursor

`Settings → Tools & MCP → "+ Add new MCP server"` 클릭 후 mcp.json에 추가:
```json
{
  "mcpServers": {
    "myrealtrip": {
      "url": "https://mcp-servers.myrealtrip.com/mcp"
    }
  }
}
```

### 4. Codex CLI
```bash
codex mcp add myrealtrip --url https://mcp-servers.myrealtrip.com/mcp
```

### 5. Gemini CLI
```bash
gemini mcp add -t http -s user myrealtrip https://mcp-servers.myrealtrip.com/mcp
```

### 6. Windsurf

`~/.codeium/windsurf/mcp_config.json`:
```json
{
  "mcpServers": {
    "myrealtrip": {
      "serverUrl": "https://mcp-servers.myrealtrip.com/mcp"
    }
  }
}
```

### 7. Cline (VS Code)

Cline 아이콘 → MCP Servers → Remote Servers:
```json
{
  "mcpServers": {
    "myrealtrip": {
      "url": "https://mcp-servers.myrealtrip.com/mcp",
      "disabled": false
    }
  }
}
```

### 추천 프롬프트 (Goldweek 일정과 연계)

#### 항공·숙박·투어 통합 큐레이션
```
5월 1일~5월 5일 (5일 연휴) 다낭 4인 가족 여행:
- 항공권 (인천 출발) 가성비 3개
- 4성 호텔 한강뷰 추천 4박
- 1일 한국어 가이드 투어 1개 (바나힐 위주)
모두 마이리얼트립에서 찾아 가격과 함께 정리해줘.
```

#### 번아웃 회복용 짧은 휴양
```
3일 연휴(7월 첫째주) 동안 인천에서 2시간 비행 이내, 휴양에 좋은 곳 + 호텔 1박당 10만원 이하.
마이리얼트립에서 평점 4.5 이상으로 5개 추천.
```

#### 황금연휴 미리 예약
```
9월 추석 연휴 5박 6일 일본 오사카, 가족 4명, 예산 400만원.
마이리얼트립에서 항공+호텔+USJ 1일권 조합 3가지로 묶어줘.
```

#### 캘린더 최저가 활용
```
인천 → 후쿠오카 5월 한 달 동안 5박 6일 기준 최저가 캘린더 보여주고,
가장 저렴한 출발일 TOP 3 + 그 호텔/투어까지 패키지로 짜줘.
```

---

## Contributing

버그 리포트나 기능 제안은 [Issues](https://github.com/M1zz/Goldweek/issues)에 남겨주세요!

---

## License

© 2024 Goldweek. All rights reserved.
