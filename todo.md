# Goldweek TODO

## 진행 중

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
