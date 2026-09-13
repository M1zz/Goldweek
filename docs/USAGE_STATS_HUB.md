# 사용 통계·피드백 허브 (FeedbackHub)

앱이 값을 하는지 **앱 안에서** 확인하기 위한 장치. 익명 사용 통계와 사용자 피드백을
같은 CloudKit 컨테이너(`iCloud.com.Ysoup.FeedbackHub`, public DB)에 쌓고, 설정 > 지원 >
사용 통계에서 그대로 읽는다. 별도 서버 없음, 새 외부 SDK 없음.

- 전송·조회 엔진: LeeoKit `LeeoUsageReporter` / `LeeoFeedbackService` (핀: 3.2.0, upToNextMajor)
- 계약: `Goldweek/Services/GoldweekSpec.swift` (LeeoAppSpec)
- 앱 정책: `Goldweek/Services/UsageReportingService.swift`
- 집계(순수 함수 + 테스트): `Goldweek/Services/UsageInsights.swift`, `Goldweek/UsageInsightsTests.swift`
- 조회 화면: `Goldweek/Views/UsageStatsView.swift` (마스터 모드 전용)

> Firebase를 걷어낸(af23e2a) 뒤로 **이 경로가 앱의 유일한 분석 수단**이다. 외부로 나가는 데이터는
> 개발자 본인의 iCloud(CloudKit public DB)뿐이고, 새 SDK는 들어오지 않는다.
> 무엇을 왜 재는지는 `docs/analytics-impact.md`(임팩트 측정 설계)가 기준이다.

## 무엇을 보내나

| 레코드 | 언제 | 내용 |
|---|---|---|
| `UsageSnapshot` | 앱을 앞으로 가져올 때, 설치당 1건 upsert (12시간 쓰로틀) | 익명 설치 UUID, 앱 버전·플랫폼·OS·로케일, 실행 횟수, 주요 행동 수, 설치 후 경과일, 마지막 활동 시각, `metrics` JSON |
| `UsageEvent` | 주요 행동 시, **이름당 6시간에 1건** (`app_open`만 20시간) | 이벤트 이름(+슬라이스), 앱 버전·플랫폼, 익명 설치 UUID, 발생 시각(`occurredAt`) |
| `Feedback` | 사용자가 피드백을 보낼 때 | LeeoKit 표준 피드백 (유형·내용·연락처는 사용자가 적은 것만) |
| `CrashReport` | iOS가 MetricKit 진단을 넘겨줄 때(하루 한 번꼴) | 종류(crash/hang/disk_write)·콜스택·앱 버전·OS·기기 종류. **설치 식별자도 안 붙는다** |
| `RemoteFlags` | (읽기 전용) | 개발자가 대시보드에서 켜고 끄는 킬스위치 |

`metrics` (설치당 대략 지표, 전부 숫자):
`leaves` `leavesThisYear` `restDays` `plannedLeaves` `usedLeaves` `adoptedRecommendations`
`annualUsed` `annualTotal` `usageRatePct` `bonusLeaves` `customHolidays` `partialDayLeaves`
`flag.isPro` `flag.autoDetect` `flag.sharing` `flag.familyShared` `flag.leisure`
`country.<국가>` `type.<사용자유형>`

**보내지 않는 것**: 이름, 휴가 사유·메모, 구체적인 날짜, 공유 상대, 이메일,
기기 식별자(IDFA/IDFV), 위치. 설치 식별은 앱이 만든 무작위 UUID(`leeo.usage.installID`)뿐이고
앱을 지웠다 깔면 새 값이 된다.

**옵트아웃 없음**: 사용자가 끄는 설정은 두지 않는다(항상 수집). 대신 개발자가 원격으로
멈출 수 있다(아래 킬스위치). 그래서 보내는 항목을 늘릴 때는 "이게 정말 익명 집계 수치인가"를
더 엄격히 따져야 하고, App Privacy 설문·개인정보 처리방침에 수집 사실이 정확히 적혀 있어야 한다.
⚠️ 심사 5.1.1(ii)와 EU GDPR 관점에서 지적 여지가 있는 선택이다. 리젝되면 옵트아웃 토글이 가장 빠른 해법이다.

## 이벤트는 어디서 나오나

각 화면에서 `UsageReportingService.record(event:)`를 직접 부른다. 지금 배선된 곳:

| 이벤트 | 위치 |
|---|---|
| `onboarding_complete` | `OnboardingView.completeOnboarding()` |
| `leave_added:<유형>` | `AddLeaveView` 저장 |
| `leave_added:photo_import` / `:calendar_import` | 사진·캘린더 가져오기 |
| `leave_deleted:<유형>` | `LeaveHistoryView` 삭제 |
| `recommendation_added` | `RecommendationsView` 추천 수락 — 이 앱의 aha 지점 |
| `paywall_view` / `paywall_purchase:success` | `PaywallView` |
| `app_open` | `ContentView` (하루 1건) |

이름 뒤 `:슬라이스`는 한 조각만 붙인다. 도시명처럼 가짓수가 많은 값은 붙이지 않는다 —
이벤트 목록이 폭발한다.

LeeoKit 내부 이벤트(페이월·피드백 제출·리뷰)는 `LeeoAnalyticsCenter.register(GoldweekSpec.self)`로
같은 경로에 합류한다.

### `app_open`은 앞으로 나온 순간에만
이 앱은 공유 일정 silent push로도 프로세스가 뜬다. `GoldweekApp.init`에서 실행을 세면
**앱을 열지도 않은 사람이 활성 사용자로 잡힌다.** 그래서 실행 횟수와 `app_open`은
화면이 실제로 뜨는 `ContentView`에서만 남긴다(그래서 `LeeoKit.bootstrap`을 쓰지 않는다).

## 무엇을 보고 판단하나

통계 화면(설정 > 지원 > 사용 통계)의 순서가 곧 판단 순서다.

1. **효용 지표** — 휴가를 등록한 설치 비율, 추천을 받아들인 설치 비율, 설치당 확보한 쉬는 날.
   설치 수가 늘어도 이 숫자가 안 늘면 앱이 값을 못 하고 있는 것이다.
2. **활성화 퍼널** — 설치 → 온보딩 → 첫 휴가 등록 → 추천 채택. 가장 크게 떨어지는 칸이 지금 고칠 곳.
3. **리텐션(주간 코호트)** — D1/D7/D30. 연차 앱은 매일 여는 앱이 아니라 D1이 낮은 게 정상이고,
   D30이 살아 있는지가 진짜 신호다.
4. **기간별 추이** — 활동한 사용자/사용 건수/신규 사용자를 일·주·월·연으로.
5. **피드백** — 숫자가 왜 그런지는 결국 사람이 적어 준 문장에 있다.
6. **안정성**(설정 > 지원 > 안정성) — 버전별 크래시·멈춤 건수. 지표가 갑자기 나빠졌다면
   기능 문제가 아니라 크래시일 수 있다. ⚠️ MetricKit은 하루 한 번꼴로 묶여 오고 시뮬레이터에서는 거의 안 온다.

⚠️ 이벤트에 6시간 쓰로틀이 걸려 있어 **건수는 실제보다 작다.** 절대 건수 대신
"설치 몇 곳이 하는가"와 단계 사이 비율을 본다. 이벤트 조회는 최근 3,000건까지다.

## 원격 킬스위치

레코드 타입 `RemoteFlags` / recordName `flags_com.Ysoup.LeaveWise`.
필드(Int64, 1=켬 0=끔): `usageReportingEnabled` `shareEnabled` `paywallEnabled`.

- 값을 0으로 바꾸면 다음 실행부터 그 기능이 멈춘다(캐시 갱신 주기 6시간).
- **조회 실패는 켬으로 친다** — 네트워크 때문에 기능이 꺼지면 킬스위치가 장애 원인이 된다.
- 필드를 안 만들어도 된다(없으면 켬).
- 현재 실제로 배선된 것은 `usageReportingEnabled` 하나다. 나머지 둘은 자리만 잡아 뒀다 —
  쓰려면 각 기능 진입점에서 `LeeoRemoteFlags.isEnabled(GoldweekFlag.shareEnabled)`를 확인해야 한다.

## CloudKit Dashboard 준비 (1회, 아직 안 함)

https://icloud.developer.apple.com → `iCloud.com.Ysoup.FeedbackHub`

0. **Apple Developer 포털**: App ID `com.Ysoup.LeaveWise`의 iCloud 컨테이너에
   `iCloud.com.Ysoup.FeedbackHub`를 추가하고 프로비저닝 프로파일을 갱신한다.
   (엔타이틀먼트에는 이미 넣어 뒀다 — 포털 쪽이 안 맞으면 서명이 실패한다.)
1. **스키마 생성**: Development 환경에서 앱을 한 번 실행(스냅샷)하고 주요 행동을 한 번 하면
   `UsageSnapshot` / `UsageEvent` 레코드 타입이 자동 생성된다. 피드백도 한 번 보내 `Feedback`을 만든다.
2. **인덱스**:
   - `UsageSnapshot`: `recordName` **Queryable**
   - `UsageEvent`: `recordName` **Queryable** + `createdTimestamp` **Sortable**
   - `CrashReport`: `recordName` **Queryable** + `createdTimestamp` **Sortable**
     (진단이 한 건도 안 올라온 동안에는 안정성 화면이 "스키마 미배포" 안내를 보여준다 — 정상)
   - `appId`는 인덱스 없이 클라이언트에서 필터한다(인덱스 배포를 늘리지 않으려고).
3. **Security Roles**: `_world`는 create만, read 제거. admin 역할에 read + 개발자 본인
   userRecordName 등록 (피드백 인박스 하단에서 userRecordName을 복사할 수 있다).
4. **Production 배포**: Schema → Deploy Schema Changes to Production.

배포 전에는 통계 화면이 "불러오지 못했어요 / read 권한 필요" 안내를 보여준다(정상).

### 🚨 순서 주의 — Production 스키마는 잠겨 있다
레코드 타입에 없는 필드를 담아 저장하면 **그 저장이 통째로 실패한다.** 새 필드
(`occurredAt`, `metrics` 등)를 쓰는 빌드를 심사에 올리기 **전에** Development에서 필드를
만들고 Production에 배포할 것. 순서가 뒤집히면 그 기간의 이벤트는 복구되지 않는다
(로컬 쓰로틀이 이미 찍혀 다시 나가지 않는다).

## App Store 제출 시

익명 사용 데이터를 수집하므로 **App Privacy 설문**을 갱신해야 한다:

- Data Type: *Product Interaction* (Usage Data) — 목적 Analytics, **사용자와 연결되지 않음**,
  추적(Tracking) 아님(ATT 불필요, 광고/데이터 브로커 공유 없음).
- 피드백에 사용자가 직접 적은 이메일/이름이 들어갈 수 있다 → *Contact Info*, 목적 Customer Support.
- MetricKit 진단 → *Crash Data*(미연결·비추적). Crashlytics 때문에 이미 신고돼 있다면 추가 항목 없음.
- 개인정보 처리방침(`docs/support.html#privacy`)에 수집 항목·목적·보관을 명시했는지 확인할 것.
  (앱 안에 끄는 스위치가 없으므로 문구가 유일한 고지 수단이다.)

## 마스터 모드

설정 > 지원 > **버전 행을 7번 탭**하면 켜진다(`dev.masterMode`). 켜지면:
- 접수된 피드백 (개발자) — LeeoKit 인박스
- 사용 통계 (개발자) — 위 화면
- 안정성 (개발자) — 크래시·멈춤 진단 (`Goldweek/Views/CrashReportsView.swift`)

같은 방법으로 다시 7번 탭하면 꺼진다. 사용자에게 노출되는 UI가 아니라 통계 화면의
문자열은 번역하지 않는다(`Text(verbatim:)`을 써서 문자열 카탈로그에도 쌓이지 않게 했다).
