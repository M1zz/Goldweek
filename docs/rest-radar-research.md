# Rest Radar — "지금 쉬어야 한다"를 판단하는 근거 (조사 + 기능 설계)

> 핵심 통찰: **징검다리 연차 계산은 "귀찮은" 것이지 "못 하는" 것이 아니다.**
> 누구나 달력 보고 할 수 있으므로 방어력이 약하고, 캘린더 앱의 한 기능으로 복제될 수 있다.
>
> 진짜 방어 가능한(못 푸는) 가치 = **내 연차 이력으로만 계산되는 나만의 번아웃 주기와 다가올 번아웃 예측.**
> 데이터가 쌓일수록 정확해지고, 그래서 이탈할수록 손해(data moat) → 리텐션 문제의 정공법.

---

## 1. 근거 조사 (휴식·번아웃 과학)

### A. 휴가 효과는 빠르게 사라진다 (fade-out)
- 건강·웰빙은 휴가 중 ~8일째 정점, **복귀 후 1주 내** 휴가 전 수준으로 회귀.
- 번아웃은 복귀 3일 후 일부 회귀, **3~4주 후 완전히 원위치**.
- 휴가 *기간*을 늘려도 효과 총량은 크게 안 늘어남(기간은 효과를 moderate 하지 않음).
- → **함의: 1년에 긴 휴가 1번은 한 해 대부분을 "무방비"로 둔다.** 타이밍이 기간보다 중요.
- 출처: de Bloom 메타분석(European Psychologist 2023), Journal of Happiness Studies 2012.

### B. 빈도 > 기간 (frequency beats duration)
- 짧고 잦은 휴가가 한 번의 긴 휴가보다 웰빙을 더 잘 유지.
- 권고: **약 2개월(≈60일)마다 짧은 휴식** → 스트레스 누적 구간 최소화.
- → **함의: 이 앱의 기존 `applyBurnoutSpacing` 60일 임계값은 과학적으로 정확하다.**
  (RecommendationEngine.swift: gap≥60 가산, gap<21 감산 — 근거 기반이었음)
- 출처: "Maximizing Recovery: The Superiority of Frequent Vacations" (PMC12334972, 2025).

### C. 번아웃의 선행 지표 (predictors)
- 3년 후 번아웃을 가장 강하게 예측한 신호: **수면 장애, 불안성 긴장, 위장 문제.**
- 초기 경고: 지속적 피로, 집중력 저하, 수면질 저하, 과민/냉소, 결근·지각.
- 수면 장애는 번아웃의 *원인*이자 *유지 요인* 양쪽으로 작용.
- 출처: Frontiers in Psychology 2025 (scoping review), PMC12590339.

### D. 미사용 연차 = 번아웃 위험
- 미국 근로자 연 평균 **6~9.5일 연차 미사용**, 1인당 ~$3,000 손실.
- 미사용 사유: 업무 적체 걱정, 죄책감, 쉬는 걸 막는 문화.
- 휴가 안 쓴 사람이 보너스·승진도 **덜** 받음(쉬는 게 손해가 아님).
- → **함의: "연말 소멸 임박 + 미사용" 은 강한 행동 유발 신호.**
- 출처: Clarify Capital 리포트, Deloitte Insights, PubMed 22804501.

### E. 물어봐서 넣는 신호 — 검증된 단문 측정
- **단일문항 번아웃 척도(SIB)**: "요즘 얼마나 지쳤나요?" 0~10.
- 정서적 소진에 대해 **특이도 0.95**(높음) — 스크리닝 도구로 타당. 마찰 거의 0.
- 단, 탈인격화 차원은 약하게 포착 → 보조 문항 1개 정도만 추가 권장.
- → **함의: 가끔 1문항만 물어 모델을 주관 상태로 보정.** 길게 묻지 말 것.
- 출처: medRxiv 2023, JGIM 2020, BAT4 초단축판(PMC10889892).

---

## 2. 판단 근거 신호 카탈로그 (3계층)

### Tier A — 기존 데이터로 즉시 계산 가능 (손으로 못 푸는 핵심)
앱이 이미 가진 `LeaveRecord` 이력 + `OptimalLeavePlan` + 공휴일로 계산. 새 권한·입력 불필요.

| 신호 | 정의 | 손으로 풀 수 있나 |
|---|---|---|
| **마지막 휴식 후 경과일** | today − 직전 휴식 종료일 | 가능(쉬움) |
| **나의 휴식 주기** | 과거 휴식 간 간격의 중앙값/평균 | **불가** — 이력 통계 |
| **회복 잔량(recovery reserve)** | 각 휴식이 준 회복을 fade-out 곡선(8일 정점→~30일 소멸)으로 적분한 현재 잔량 | **불가** — 시계열 적분 |
| **번아웃 예측일** | 현재 잔량이 임계선 아래로 내려갈 미래 시점 (현 주기 + 다가올 공휴일 반영) | **불가** — 외삽 예측 |
| **소멸 위험 연차** | 잔여 연차 ÷ 회계연도 종료까지 남은 날 | 가능(귀찮음) |
| **다음 저비용 휴식 창** | OptimalLeavePlan과 교차 → "12일 뒤 연차 1일로 4일 가능" | 가능(매우 귀찮음) |
| **워크로드 프록시** | EventKit 캘린더의 향후 N주 일정 밀도 (이미 연동됨) | 부분 가능 |

### Tier B — 사용자에게 물어서 보정 (저마찰, 검증된 문항)
- 가끔(예: 2~3주에 1회) **단일문항 번아웃 0~10** + 선택적 보조 1문항.
- 1회성 컨텍스트: 최근 야근/큰 프로젝트 종료, 수면질(3단계) — D의 예측 지표에 매핑.
- 원칙: 묻는 건 최소화, 답하면 모델 가중치를 즉시 반영(투명하게 "왜 이 추천인지" 표시).

### Tier C — 패시브/연동 (옵트인, 로드맵)
- **HealthKit**(미연동): 수면 시간·규칙성, HRV, 활동량 추세 → C의 검증된 번아웃 상관 신호.
- **EventKit 일정 밀도**(연동됨): 회의·업무 일정 폭증 = 워크로드 급등 경보.

---

## 3. 기능 설계 — "Rest Radar (휴식 레이더)"

### 출력 (UX)
1. **회복 잔량 게이지** — 홈의 기존 "휴가 페이스" 카드를 확장.
   "회복 잔량 38% · 마지막 휴식 후 67일 · 당신의 평소 주기는 52일"
2. **번아웃 예측 타임라인** — "현 속도면 7/하순 번아웃 위험 구간 진입 예상."
3. **선제 알림(핵심 리텐션 훅, 신규 로컬 알림 필요)**:
   > "지금 쉬어갈 때예요. 마지막 휴식 후 67일(평소 주기 52일 초과).
   >  2주 뒤 ○○공휴일에 연차 1일이면 4일 휴식 — 지금 잡아둘까요?"
   - 과학(주기 초과) + 알고리즘(저비용 기회)을 한 문장에 결합.
   - **계획 시즌 밖에서도 앱을 열게 만드는 트리거** = 빈도 약점의 정공법.

### 점수 모델 (구현 스케치)
```
recovery_reserve(today) = Σ_over_past_rests  rest_length × decay(today − rest_end)
   decay(d) = max(0, 1 − d/30)        # 8일 정점 단순화 시 선형, ~30일 소멸 (근거 A)
personal_cycle = median(인접 휴식 간격)   # 이력 부족 시 60일 기본값 (근거 B)
overdue_ratio  = days_since_last_rest / personal_cycle
burnout_risk   = w1·(1 − reserve) + w2·max(0, overdue_ratio − 1)
                 + w3·expiry_risk + w4·subjective_SIB(있으면) + w5·workload
"지금 쉬어라" 트리거: burnout_risk ≥ θ  AND  14일 내 저비용 휴식 창 존재
```
- 기존 `applyBurnoutSpacing`의 60/40/21일 임계값을 이 모델의 사전확률로 재사용.
- 가중치는 측정(analytics-impact.md) 후 채택률로 튜닝.

### 데이터 해자(moat)가 생기는 이유
- 휴식을 기록할수록 `personal_cycle`·예측이 정교해짐 → 떠나면 정확도 리셋.
- "내 번아웃 주기를 아는 앱"은 캘린더 앱이 복제 불가(개인 이력 + 모델 필요).
- 단순 연차계산기(복제 쉬움) → 개인 휴식 주치의(복제 어려움)로 포지션 이동.

---

## 4. 구현 현황 (2026-06 기준)

| 항목 | 현황 |
|---|---|
| 번아웃 엔진 (잔량·주기·예측) | ✅ `BurnoutEngine` + 11개 단위 테스트 |
| 로컬 알림 (UNUserNotification) | ✅ `NotificationService` — 권한/스누즈/쿨다운/4개국어 |
| 알림 델리게이트 (포그라운드 표시·탭·스누즈 액션) | ✅ `RestRadarNotificationDelegate`, 앱 시작 시 등록 |
| 홈 카드 (잔량 게이지·예측 라인·개인 주기) | ✅ `BurnoutPaceCard` 엔진 기반 격상 |
| 저비용 휴식 창 | ✅ `LeavePlanner.optimalPlan` 재사용 (`bestRestWindow`) |
| 주관 보정 (단일문항 SIB) | ✅ `FatigueCheckIn` + `FatigueCheckInView` 모달 |
| 설정 on/off | ✅ SettingsView 휴식 레이더 토글 |
| 측정 | ✅ recommendation_shown/added, rest_radar_shown/opened/snoozed |
| 워크로드 신호 (EventKit 일정 밀도) | ◻️ 로드맵 — `CalendarService` 연동됨, 읽기 추가 필요 |
| 패시브 생체신호 (HealthKit 수면·HRV) | ◻️ 옵트인 로드맵 — 미연동 |
| 가중치/임계값 튜닝 | ◻️ 실데이터 수집 후 `BurnoutEngine.Config` 보정 |

---

## 5. 출처
- de Bloom et al., *We Continue to Recover Through Vacation! Meta-Analysis of Vacation Effects and Fade-Out*, European Psychologist 28(4), 2023. https://econtent.hogrefe.com/doi/10.1027/1016-9040/a000518
- *Maximizing Recovery: The Superiority of Frequent Vacations for Well-Being and Performance*, 2025. https://pmc.ncbi.nlm.nih.gov/articles/PMC12334972/
- *Vacation (after-) effects on employee health and well-being*, J. Happiness Studies, 2012. https://link.springer.com/article/10.1007/s10902-012-9345-3
- *Chronic stress in relation to clinical burnout: scoping review*, Frontiers in Psychology, 2025. https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2025.1712340/full
- *Mental and Somatic Ill-Health as Long-Term Predictors of Burnout*, PMC12590339. https://pmc.ncbi.nlm.nih.gov/articles/PMC12590339/
- *The single item burnout measure is reliable and valid*, medRxiv 2023. https://www.medrxiv.org/content/10.1101/2023.03.06.23286842.full.pdf
- *BAT4 ultra-short Burnout Assessment Tool*, PMC10889892. https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10889892/
- *The impact of vacation and job stress on burnout and absenteeism*, PubMed 22804501. https://pubmed.ncbi.nlm.nih.gov/22804501/
- Deloitte Insights, *The disconnect disconnect (vacation policy & burnout)*. https://www.deloitte.com/us/en/insights/topics/talent/culture-vacation-policy-trends-employee-burnout.html
