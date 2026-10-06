# Goldweek TODO

## 진행 중

### 주요 국가 21개 추가 · 주말 근무 옵션 (2026-10-06)
- [x] 유럽 13: 네덜란드(요청)·벨기에·오스트리아·스위스(취리히 기준)·아일랜드·포르투갈·스웨덴·노르웨이·덴마크·핀란드·폴란드·체코·그리스(정교회 부활절)
- [x] 튀르키예·이집트(금·토 주말, 이슬람 명절 움 알쿠라)·남아공(일요일 → 월요일 대체)
- [x] 멕시코·아르헨티나·칠레·콜롬비아(이동 공휴일 규칙)·뉴질랜드(먼데이화, 마타리키 표 2022~2035)
- [x] 대륙에 아프리카 추가, 언어 폴백(nl·sv·nb·da·fi·pl·cs·el·tr)
- [x] 주말 설정을 모든 나라로: 나라 기본 / 토·일 / 금·토 / 목·금 / 일 / 금 / 토 / 주말 없음(매일 근무)
- [ ] 제외: 인도·인도네시아·싱가포르·태국·베트남·말레이시아·필리핀·이스라엘 (주별 공휴일·힌두력·불교력·발표표 필요)
- [ ] 뉴질랜드 마타리키 2036~ 표 추가, 스위스 칸톤별 지역 선택
- [x] 네덜란드어 UI (앱 문자열 702곳·위젯·권한 문구, 네덜란드·벨기에 공휴일 현지 이름) — 기계 번역 수준
- [ ] 네덜란드어 원어민 검수 ("Golden Week" 그대로 둠, "Opfrisverlof" 등 조어 확인), LeeoKit 화면은 영어로 폴백
- [ ] App Store Connect nl-NL 로컬라이제이션·스크린샷
- [ ] 다음 언어 후보: 스웨덴어·노르웨이어·덴마크어·핀란드어·폴란드어·체코어·그리스어·튀르키예어, 아랍어(RTL)

### 페루 추가 · 국가 선택 대륙별 (2026-10-06)
- [x] 페루 국가 공휴일 16일 (2026 기준) — 신설 6/7(2023~)·7/23(2024~)·8/6·12/9(2022~)는 신설 연도부터
- [x] 국가 선택을 대륙 → 나라 2단계로: 설정은 대륙 목록 → 나라 목록 화면 + 검색, 온보딩·홈 안내 카드는 대륙별 하위 메뉴
- [x] 테스트: 페루 공휴일 수, 모든 나라가 대륙 하나에 속하는지
- [ ] 실기기에서 설정 → 나라 → 대륙 → 나라 고른 뒤 설정까지 한 번에 돌아오는지 확인
- [ ] 페루 사용자에게 답장

### 중동 사용자 피드백 — 공휴일·연차 기준·Pro 상태·온보딩 결제 (2026-10-06)
- [x] UAE·사우디·카타르 추가 — 이슬람 명절은 움 알쿠라 달력 계산, 공휴일 관리에 "달 관측으로 하루 달라질 수 있음" 안내
- [x] 국가별 주말 (사우디·카타르 금·토) — 연차 차감·추천·연휴 플래너·달력 색에 반영
- [x] 직접 입력 국가 주말 요일 선택 (토·일 / 금·토 / 목·금 / 금 / 일)
- [x] 연차는 근무일 기준 안내 — 설정·온보딩, 휴가 등록 시 "달력 N일 중 M일 차감"
- [x] 설정에 이용 중인 버전(무료/Pro) 섹션, 페이월도 Pro면 "이용 중" 표시
- [x] 온보딩 Pro 페이지: 큰 버튼이 결제가 아니라 "시작하기"라 아무 일도 없어 보이던 것 → "Pro 잠금 해제 · 가격"(실제 결제) / "무료 버전으로 계속" / 구매 복원 분리, 이미 Pro면 상태 표시
- [x] StoreKit 거래 리스너를 앱 실행 즉시 시작 — 앱 밖에서 리딤한 오퍼 코드가 늦게 반영되던 것
- [ ] 실기기에서 오퍼 코드 리딤 → 첫 실행 온보딩에 Pro 표시되는지 확인
- [ ] UAE 공휴일 대체(금요일 이동) 발표 반영 여부 검토, 쿠웨이트·바레인·오만·이집트 추가 검토
- [ ] 피드백 보낸 사용자에게 답장

### 처음 나라 자동 설정 표시 (2026-10-06)
- [x] 감지 규칙 유지: 기기 지역 우선, 지원 안 하는 지역이면 언어(영어 → 미국)
- [x] 온보딩 연차 입력 화면에 "공휴일 기준 나라" 카드 — 감지된 나라 표시, 바로 변경, 언어로 골랐으면 그 이유 안내
- [x] "처음 안내 다시 보기"가 고른 나라·연차·기준월을 감지값·기본값으로 덮어쓰던 것
- [x] 감지 테스트 추가 (en_ZA → 미국, ar_SA → 사우디, en_AE → UAE)

### LeeoKit 3.13.0 → 3.15.0 (2026-10-06)
- [x] 패키지 최소 버전 3.15.0, iOS·Mac Catalyst 빌드 확인
- [ ] 의견 답장 기능 쓰려면: 설정에 LeeoSentFeedbackRow 추가(설정이 LeeoSupportSection 대신 행을 직접 그려서 자동으로 안 들어옴) + CloudKit Dashboard에 FeedbackReply 타입·World Read·Production 배포

### 직접 입력 국가 (남아공 사용자 피드백, 2026-10-06)
- [x] Country.custom "기타 (직접 입력)" — 기본 공휴일 없음, 국가 선택 목록 맨 끝
- [x] 내 공휴일 "매년 반복" 옵션 (CustomHoliday.repeatsYearly, 2/29는 평년 건너뜀) — 달력·연차 차감·추천 반영
- [x] 홈 미지원 국가 카드에 "공휴일 직접 입력하기" 버튼 → 공휴일 관리로 이동, 비어 있으면 "공휴일을 추가해 주세요" 카드
- [x] 공휴일 관리: 직접 입력 모드 안내, 반복 공휴일 행에 "매년" 표시 / 타임머신 스냅샷에 반복 여부 보존
- [x] 단위 테스트 3개 (기본 공휴일 없음, 매년 반복, 윤일)
- [ ] 실기기에서 남아공 지역으로 온보딩 → 직접 입력 전환 흐름 확인
- [ ] 피드백 보낸 사용자에게 업데이트 안내 답장
- [ ] 내 공휴일 수정(이름·날짜·반복) — 지금은 삭제 후 다시 추가

### Reddit 오퍼 코드 딜 포스트 (2026-10-06)
- [x] 제목 규칙([Platform] [Title] [Price Change] [Description]) 맞춘 초안: docs/reddit-offercode.md
- [ ] ASC에서 코드 OCTO 수량·만료·인앱 구입 표시 이름·미국 가격 확인
- [ ] 리딤 링크 실기기 확인 후 포스트, 첫 1~2시간 댓글 응대

### Mac(Catalyst)·iPad 지원 (2026-09-29)
- [x] Mac Catalyst 켜기, 번들 ID 동일 → 유니버설 구매
- [x] iPad 판매 안 함: 기기군을 SDK별로 — iOS 빌드 iPhone 전용(UIDeviceFamily [1]), Mac 빌드만 Catalyst 요구사항대로 iPad 관용구
- [x] Mac 전용 entitlements (샌드박스·네트워크·캘린더·카메라·사진·iCloud·푸시)
- [x] Mac 레이아웃: 왼쪽 캘린더 + 오른쪽 현황 대시보드, 설정·가족은 상단 버튼(시트) — 아이폰 가로에선 안 씀
- [x] 넓은 화면에서 캘린더 칸 확대, 온보딩 폭 제한, Mac 창 최소 크기
- [x] Mac 스크린샷 2560×1600 × 6개 언어 (scripts/take_mac_screenshots.sh → docs/screenshots-mac)
- [ ] App Store Connect: 같은 앱에 macOS 플랫폼 추가 → Mac 빌드(Any Mac) 업로드 + Mac 스크린샷
- [ ] macOS 버전 페이지 키워드·설명 따로 입력 (플랫폼별 버전 메타데이터)
- [ ] 개발자 포털: App ID에 Mac Catalyst 활성화, iCloud·App Group·Push 프로파일 갱신
- [ ] "Designed for iPad"(아이폰 앱을 Mac에서 그대로)로 실행 시 온보딩 직후 스택 오버플로 크래시 — Catalyst 빌드에선 재현 안 됨. 실기기 아이폰 온보딩 한 번 확인 필요
- [ ] Mac 메뉴 단축키(⌘N 휴가 등록 등), 사진 가져오기(카메라 없음) 동작 확인

### 전세계 판매 준비 (2026-09-29)
- [x] main ↔ dev 정리: origin/main 으로 fast-forward, dev 를 main 에서 다시 분기
- [x] 독일어·프랑스어 UI 추가 (앱 문자열 640곳 + 위젯·InfoPlist 카탈로그)
- [x] 미지원 언어 → 영어 폴백 (앱 언어 + developmentRegion en 으로 번들 리소스까지)
- [x] 독일·프랑스 공휴일 이름 현지어화
- [x] 스크린샷 자동 촬영: `scripts/take_screenshots.sh` (DEBUG 스크린샷 모드, 6개 언어 × 3화면 → docs/screenshots)
- [ ] 번역 원어민 검수 (de/fr는 기계 번역 수준 — 특히 "Goldene Woche", 휴가 종류명)
- [ ] App Store Connect 에 de-DE / fr-FR / 기타 로컬라이제이션 추가 + docs/aso-keywords.md 메타데이터 입력
- [ ] 스크린샷에 마케팅 문구 프레임 입히기 (현재는 원본 화면 캡처)
- [ ] LeeoKit(피드백·페이월) 문구 de/fr 번역 — 현재는 영어로 폴백
- [ ] 개인정보 처리방침·지원 페이지 de/fr
- [ ] 가격 티어·판매 국가 설정 확인

### 국가별 공휴일 검토 (2026-09-29)
- [x] 한국: 크리스마스 토요일 대체공휴일, 공휴일 겹침 대체(2025 어린이날=부처님, 2028 추석=개천절), 2028 총선·2030 지방선거
- [x] 일본: 振替休日 다음 비공휴일까지 밀기(2026-05-06), 国民の休日(2026-09-22)
- [x] 중국: 2024~2026 국무원 발표 휴무표 반영, 2027~ 추정 규칙 개선, 신뢰 범위 2026까지
- [x] 미국: 1/1(토) 대체일 12/31을 전년도 목록에
- [ ] 독일 주(Bundesland)별 공휴일 — Fronleichnam·Allerheiligen·Reformationstag 등 (지역 선택 UI 필요)
- [ ] 프랑스 Alsace-Moselle (Vendredi saint, 26 déc)
- [ ] 중국 调休 보강 근무일(주말 출근) — 추천 계산이 주말을 무조건 휴일로 본다
- [ ] 매년 11월 중국 차년도 휴무표 발표 → chinaOfficialSchedule 갱신
- [ ] 일본 연말연시(12/29~1/3) 회사 휴무 관행 옵션 검토

### 추천이 주말·공휴일에 연차를 넣던 문제 (2026-09-29)
- [x] 추천 등록 시 주말·공휴일을 빼고 연차 내는 날만 기록 (전에는 기간 전체 → 차감 일수 부풀음)
- [x] 추천 카드 미리보기가 한국 공휴일로 칠해지던 문제 (미국 추수감사절이 "연차"로 표시)
- [x] 엔진 최종 검증: 연차일(주말·공휴일 제외)과 표기 일수가 다르면 추천 제외 — 중국 춘절 기간 "징검다리" 등
- [x] 추수감사절이 재향군인의 날(11/11 목)로 잡히던 문제, 5월 황금연휴 범위 오류
- [x] 번아웃 주의 점선 링을 평일에만 + 범례를 점선 링 모양으로
- [x] 연차 차감은 평일만 — 주말·공휴일·내 방학 제외 (DayOffCalendar). "이전 사용 연차 일괄 입력"만 달력 일수 유지
- [x] 예전에 추천으로 등록된 기록을 연차일 구간으로 나누는 1회 마이그레이션

### 방학 기능 (2026-09-29)
- [x] SchoolBreak 모델 (자녀 방학 = 참고용 / 내 방학 = 쉬는 날)
- [x] 공휴일·방학 관리 화면에서 추가·수정·삭제
- [x] 달력: 내 방학 남색 막대, 자녀 방학 청록 띠, 범례, 날짜 상세
- [x] 추천: 내 방학은 쉬는 날로, 자녀 방학과 겹치는 추천은 앞세우고 "자녀 방학" 태그
- [x] 번아웃: 내 방학을 휴식으로 인정 / 타임머신 스냅샷에 방학 포함
- [ ] 레거시 백업(DataProtectionService JSON)에는 방학이 빠져 있음 — 필요하면 추가
- [ ] 위젯 문구·다국어 원어민 검수

### v2.1.2 출시 전 (릴리즈 노트: docs/release-notes.md)
- [ ] **CloudKit 배포 선행** — 포털에 `iCloud.com.Ysoup.FeedbackHub` 컨테이너 추가 +
      Dashboard 스키마(Feedback·UsageSnapshot·UsageEvent·CrashReport) Production 배포
      ⚠️ 안 하면 릴리즈 노트에 적은 "피드백 보내기"가 전송 실패한다
- [ ] App Store Connect 개인정보 설문 갱신
- [ ] 아카이브 빌드 확인

### 사용 통계·피드백 허브 — 남은 운영 작업 (코드는 끝, 대시보드가 남음)
- [ ] Apple Developer 포털: App ID `com.Ysoup.LeaveWise`에 iCloud 컨테이너
      `iCloud.com.Ysoup.FeedbackHub` 추가 + 프로비저닝 프로파일 갱신
      (안 하면 "Invalid bundle ID for container" 오류로 조회가 실패한다)
- [ ] CloudKit Dashboard(FeedbackHub): Development에서 스키마 생성(UsageSnapshot·UsageEvent·
      Feedback·CrashReport) → 인덱스 → Security Roles(admin read + 내 userRecordName) → Production 배포
- [ ] App Store Connect 개인정보(App Privacy) 설문 갱신:
      Product Interaction(Analytics, 미연결) + Contact Info(피드백) + Crash Data(MetricKit)
- [ ] 절차 전문: `docs/USAGE_STATS_HUB.md`

## 완료 (사용 통계·피드백 허브 + 다국어 정리)
- [x] LeeoKit 3.2.0 도입 + GoldweekSpec 계약, 원격 킬스위치(GoldweekFlag)
- [x] 익명 스냅샷(효용 지표) + 주요 행동 이벤트 — Firebase 제거로 비어 있던 분석 경로를 대체
      (onboarding_complete / leave_added / leave_deleted / recommendation_added / paywall_* / app_open)
- [x] 마스터 모드(버전 7탭): 접수된 피드백 · 사용 통계 · 안정성(MetricKit 크래시)
- [x] 만족도 프롬프트 — 좋으면 리뷰, 아쉬우면 피드백. 휴가 등록 후 자동 별점 요청은 제거(중복 방지)
- [x] 위젯 문자열 21개 미번역 → en/ja/zh-Hans 채움
- [x] 공유·가족 화면의 enum rawValue 직접 표시 3곳 수정
- [x] 날짜 18곳: `Date.formatted()`(기기 언어) → `appFormatted()`(앱 언어 설정)
- [x] 기본 이름("사용자")이 만든 시점 언어로 굳던 문제 — `UserProfile.displayName`
- [x] 설정 > 지원 섹션을 직접 그려 앱 언어를 따르게 + `AppleLanguages` 동기화
- [x] 개인정보 처리방침 4개 언어 갱신 (익명 통계·크래시 진단 고지, Firebase 문구 정리)
- [x] 집계 로직 유닛 테스트 9개

## 완료 (Firebase/GA 완전 제거 세션 2026-07-21)
- [x] AnalyticsService.swift 삭제 + 전 화면 호출부(~35곳) 제거 (온보딩·휴가등록/삭제·추천·MRT·페이월·휴식레이더·공유 등)
- [x] GoogleService-Info.plist 삭제
- [x] pbxproj에서 firebase-ios-sdk SPM 패키지·5개 product(Firebase Analytics/Core/IdentitySupport/Core/Crashlytics)·빌드파일·리소스 참조 전부 제거
- [x] GoldweekApp.configure() 호출 제거
- [x] 빌드·전체 테스트 통과, 스테일 Firebase 프레임워크 정리됨

## 완료 (휴가 = 카테고리 × 길이 직교 구조 세션 2026-07-21)
- [x] LeaveLength enum 추가 (종일 1.0 / 반차 0.5 / 반반차 0.25) — 카테고리와 직교
- [x] LeaveRecord: lengthRaw 저장 + length/category 계산 속성, effectiveLeaveDays·deductsFromAnnualLeave 길이 기반으로 변경 (레거시 반차/반반차 자동 흡수, 마이그레이션 불필요)
- [x] LeaveType.categories (연차·대체휴무·공가·병가·특별휴가·출장) — 입력 UI용 순수 카테고리
- [x] 파서: 유형명 "(1/2)"·"½" 등 분수 → suggestedLength(반차/반반차)로 추론. 날짜 슬래시 오인 방지(괄호 요구). 테스트 3개 추가
- [x] PhotoImport 파이프라인: DetectedLeaveCandidate.suggestedLength → LeaveRecord.length 전달, effectiveDays 반영
- [x] AddLeaveView: 길이 선택 + 카테고리 선택 2축으로 재구성 (특별휴가·반차, 자녀돌봄·반차 등 n×n 조합 가능)
- [x] EditLeaveSheet: 카테고리 Picker + 길이 세그먼트 추가 → 기존 기록 재분류 가능
- [x] 사용 내역 행에 길이 배지 표시, 전체 테스트 통과

## 완료 (보너스 사용량 기록 기준 재계산 세션 2026-07-21)
- [x] BonusLeaveReconciler 추가 (Models.swift) — 휴가 사용 내역 기준으로 보너스 usedDays 재산정
  - 연차 비차감 미연결 특별휴가(자녀돌봄 등)를 유형·잔여 맞는 보너스에 자동 연결(bonusLeaveId)
  - 모든 보너스 usedDays/isUsed를 연결 기록 기준으로 재산정
- [x] LeaveHistoryView.repairBonusLeaveUsage → 리컨실러 호출로 교체
- [x] HomeView 현황 카드 onAppear에서도 리컨실 실행 → 홈에서 바로 반영
- [x] 주의: 자녀돌봄은 보너스 유형이 "일가정균형"으로 등록돼 있어야 자동 연결됨

## 완료 (보너스 사용 현황 노출 세션 2026-07-21)
- [x] 설정 화면 보너스 연차 행에 "N일 중 M일 사용" 캡션 추가 (Strings.bonusUsedOfGranted, 4개 언어)
- [x] 홈 현황 카드에 보너스 사용 현황 표시 — 부여 대비 사용량 + 진행률 바 + 잔여 강조 (부여받은 보너스가 있으면 항상 노출)
- [x] AddLeave(+ 탭)는 이미 보너스 선택 차감 지원 확인 (별도 구현 불필요)
- [x] 앱 버전 2.1.1

## 완료 (특별휴가-보너스 연결 세션 2026-07-13)
- [x] 버전 2.1.0으로 업데이트 (MARKETING_VERSION, 앱+위젯 전 타깃)
- [x] 릴리즈 노트 작성 (docs/release-notes.md v2.1.0 — App Store 4개 언어 + 내부 체인지로그)
- [x] 사진 가져오기(OCR): 특별휴가류(자녀돌봄 등)가 아무 차감 없이 등록되던 갭 해소
  - 자동 매칭: 연차 차감 없는 후보의 유형명(돌봄/포상/리프레시 등)을 BonusLeaveType.matching으로 추론해 유형·잔여가 맞는 보너스 연차에 자동 연결 (잔여 누적 추적으로 과할당 방지)
  - 확인 화면 UI: 후보별 "보너스에서 차감" 메뉴 추가 — 자동 매칭 결과 표시, 사용자가 행별로 변경/해제 가능
  - 저장 시 bonusLeaveId 연결 + usedDays 차감, 잔여 부족 시 등록 차단, 저장 실패 시 롤백. 삭제 시 복원은 기존 LeaveHistoryView 로직 재사용
  - 신규 문자열 3개(4개 언어), 빌드·전체 테스트 통과

## 완료 (브랜치 정리 세션 2026-07-13)
- [x] dev ↔ origin/dev 분기 해소: 멈춰 있던 머지 충돌 3파일 해결 후 머지 커밋(eb299e4) + push
  - ContentView: refreshRestRadar(로컬 번아웃) + syncSharedSchedules/타임머신 백그라운드 캡처(원격) 모두 유지
  - HomeView: 피로 체크인 시트(로컬) + AddLeave/캘린더 가져오기 시트(원격) 모두 유지
  - pbxproj: ID 충돌 수정 — 원격의 LeaveTableParserTests/AppTips가 로컬의 BurnoutEngine/NotificationService와 같은 ID(A…60/61) 사용 → A…63/64로 재번호. MARKETING_VERSION은 2.0.9 채택
  - 시뮬레이터 빌드 검증 통과

## 완료 (개인화 추천 세션)
- [x] 추천 탭 제거 (홈·캘린더·설정 3탭). 추천 기능은 캘린더에 통합 유지
- [x] 선호 기간 기반 추천: 공휴일에 연차를 며칠 붙여 선호 길이(짧음3/보통5/김7)에 맞춰 확장(일반화된 징검다리), 기간 매칭 가중치 강화
- [x] 번아웃 텀 반영: 직전 휴식 이후 공백이 길면 가산(60일+ 강하게), 기존 휴가와 너무 붙으면 감산. 기존 휴가와 겹치는 추천 제거
- [x] 설정(PreferencesView)의 선호 기간/롱위켄드/연속/성수기회피가 캘린더 추천에 실시간 반영(.task id + 캐시키)

## 완료 (추천·캘린더 연동 세션)
- [x] 플래너: 연차 1일로 단순 3일(금/월+주말)만 만드는 사소한 연휴 후보 제외
- [x] 최적 플랜 카드: 슬림 리스트 → 시각화 카드(구성 막대 주말/공휴일/연차, 효율 배지, 포함 공휴일)
- [x] 캘린더 추천 일정: 추천 탭과 동일한 RecommendationEngine 사용. 공휴일 포함+연차 필요 추천의 연차일을 노란색 표시(범례 추가)
- [x] 캘린더 날짜 탭: 추천 일정 포함 날이면 "일정 없음" 대신 추천 상세(제목·기간·휴식/연차·설명) 표시

## 완료 (UI/공휴일 개선 세션)
- [x] 휴가 페이스 카드: 막대 2개 → 단일 연간 축 + 핀 2개(올해 진행/연차 사용)로 직관화, paceMessage 해설 복원
- [x] 홈 다가오는 휴가 섹션 카드화(아이콘+개수 배지+그림자), 휴가 사용 내역 버튼 맨 아래로 이동
- [x] 캘린더 휴가 표시: 점 → 이어지는 선(막대), 연속일은 칸 사이 간격까지 메워 하나로 연결
- [x] 캘린더 주말 브릿지: 금·월처럼 양옆이 휴가인 주말도 선으로 이어 표현
- [x] 쉬어가는 흐름 타임라인: 오늘 위치를 이전/다음 거리 비율(완화·클램프)로 이동해 직관화
- [x] 공휴일 데이터: 제헌절(7/17) 2026년부터 공휴일 재지정 반영(2025-01-29 공휴일법 개정 통과)
- [x] 대체공휴일 규칙 정확화: 토·일 적용(삼일절·광복절·개천절·한글날·어린이날·부처님오신날·제헌절) vs 일요일만 적용(설날·추석·크리스마스) 분리. 근로자의 날(관공서 공휴일 아님) 대체 대상에서 제거. → 추석 9/26(토) 잘못된 대체일 생성 버그 수정

## 완료 (이번 세션 추가)
- [x] 시크릿 운영 체계: GoldweekSecrets.example.swift 템플릿 + pre-commit 훅(.githooks) + README 갱신 (커밋 de0d91f)
- [x] 홈 "연차 현황" 정리
  - "2026년 연차 현황" → "연차 현황" (연도 제거)
  - 보너스 포함 토글: 홈에서 제거 → 설정 > 보너스 연차 섹션으로 이전
  - 카드 제목 앞 심볼 제거: 📅(다가오는 휴가), speedometer(휴가 페이스), 번아웃 아이콘
  - 휴가 페이스 카드: 설명 문구 제거(paceMessage "여유롭게 사용 중이에요…", burnoutMessage) + 죽은 코드 정리

## 완료
- [x] 시각장애인 접근성(VoiceOver) 전체 화면 점검·보강 (빌드 성공 검증)
  - [x] 보너스 포함: 칩 버튼 → 실제 스위치 토글 (상태/힌트 음성 안내)
  - [x] 공용 컴포넌트(Components.swift): GradientButton/SectionHeader/ProgressBar/DateRangeLabel/DDayLabel
  - [x] PreferencesView: 기간/계절/활동 버튼 선택상태(.voSelected) + 라벨
  - [x] HolidayManagementView: 연도칩, 섹션헤더, 빈토글 라벨, 행 결합, 삭제버튼 라벨
  - [x] LeaveHistoryView: 연도/필터칩 선택상태, 통계카드 결합, 기록행 결합+힌트
  - [x] CalendarView: 과거일정 토글 펼침/접힘 음성, 선택날짜 카드 장식아이콘 숨김
  - [x] SettingsView: 아바타 숨김, 이름수정 버튼 라벨, 보너스행 결합, 요약/통계행 값 음성
  - [x] AddLeaveView: 보너스 선택 버튼 선택상태/라벨, 빠른선택 칩, 스테퍼 라벨
  - [x] OnboardingView: 월 선택 그리드 선택상태(.voSelected)
  - [x] RecommendationsView: 남은연차 카드 결합(원형그래프 숨김) — 주요 카드는 기존에 적용됨 확인
  - 신규 VoiceOver 문자열(4개 언어): 보너스 힌트, 공휴일 표시 힌트, 추천 표식, 수정 힌트, 펼침/접힘, 이름수정, D-Day
- [x] ModelContainer 크래시 수정
  - 원인: try!로 강제 언래핑하여 스키마 변경/저장소 손상 시 크래시
  - 해결: 에러 핸들링 추가, 저장소 삭제 후 재시도, 인메모리 fallback
- [x] 온보딩 반복 표시 버그 수정
  - 원인: UserDefaults(hasCompletedOnboarding)와 SwiftData(profile) 동기화 안 됨
  - 해결: hasCompletedOnboarding이 true인데 profile이 없으면 기본 profile 자동 생성
- [x] 온보딩 국가 선택 페이지 제거
  - 기기 언어 설정에 따라 자동으로 국가/언어 설정
- [x] 앱 리뷰 기능 추가
  - 설정 > 앱 정보에 "앱 평가하기" 버튼 추가
  - StoreKit requestReview() 사용
