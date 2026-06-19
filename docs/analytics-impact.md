# Goldweek 임팩트 측정 설계

> 목적: "작은 불편(연차 최적 배분)"을 푸는 이 앱이 실제로 사용자에게
> 얼마나 큰 가치를 만드는지를 **숫자로** 증명한다.
> 북극성 = **연차당 만들어 준 휴식 배수(efficiency)** × **그 추천을 실제로 채택한 비율**.

---

## 1. 이벤트 사전 (현재 배선 기준)

| 이벤트 | 파라미터 | 발화 지점 | 용도 |
|---|---|---|---|
| `onboarding_complete` | country, total_leave | 온보딩 끝 | 활성화 분모 |
| `recommendation_shown` | count, avg_efficiency, source(`list`/`calendar`) | 추천 생성 시 (신규) | **채택률 분모** |
| `recommendation_added` | days, efficiency | 추천 수락 시 | **핵심 가치 실현(aha)** |
| `leave_added` | type, days, is_recommended | 휴가 등록 | 추천 vs 수동 분리 |
| `leave_deleted` | type | 휴가 삭제 | 후회/이탈 신호 |
| `paywall_view` / `paywall_purchase` | source / success, product_id | 결제 퍼널 | 수익화 |

> `recommendation_shown`은 재렌더링으로 중복 발화될 수 있다.
> 집계 시 반드시 **(user_id, event_date) 단위로 dedupe**하거나 세션으로 묶을 것.

---

## 2. 4대 핵심 지표 (KPI)

### ① 추천 채택률 (Adoption Rate) — 엔진 신뢰도
```
adoption_rate = COUNT(recommendation_added) / COUNT(distinct shown impressions)
```
- 목표: > 15% (한 번이라도 추천 본 유저 중 수락 비율은 별도 user 단위로도 계산)
- 낮으면 → 추천 품질 또는 노출 위치 문제

### ② 평균 효율 배수 (Avg Efficiency) — 가치의 크기
```
avg_adopted_efficiency = AVG(recommendation_added.efficiency)
```
- "사용자가 실제로 받은 연차당 휴식 배수." 2.5~3.0이면 알고리즘 목표 달성.
- `avg_efficiency`(shown) vs `efficiency`(added)를 비교하면
  **사용자가 효율 높은 걸 골라 채택하는지**(선택 안목)까지 보인다.

### ③ 추천 기여율 (Recommendation Attribution) — 앱이 만든 행동
```
attribution = SUM(leave_added.days WHERE is_recommended=1)
            / SUM(leave_added.days)
```
- 핵심 질문: "이 휴가, 앱 없이도 잡았을까?" 에 대한 답.
- 높을수록 앱이 단순 기록장이 아니라 **의사결정 도구**임을 증명.

### ④ 휴식 규칙성 / 번아웃 간격 — 웰빙 임팩트
```
median_gap = 사용자별 인접 leave_added 시작일 간격의 중앙값 (코호트 전후 비교)
```
- `applyBurnoutSpacing` 로직의 실제 효과 검증.
- 앱 사용 후 긴 공백(60일+)의 비율이 줄면 = 더 규칙적으로 쉬게 됨.

---

## 3. 파생/보조 지표

| 지표 | 정의 | 신호 |
|---|---|---|
| 연차 소진율 | 연말 시점 used/total | 1.0 근접 = 연차 낭비 방지 성공 |
| 추천→삭제율 | added 후 deleted | 후회율, 추천 정확도 역지표 |
| source별 채택률 | list vs calendar | 어느 노출 위치가 더 효과적인가 |
| 효율 분포 | shown efficiency 히스토그램 | 1.5~2.0 저효율 추천 비중 점검 |

---

## 4. 대시보드 레이아웃 (Firebase / BigQuery export)

```
┌─ 임팩트 (북극성) ─────────────────────────────┐
│  평균 채택 효율 [ 2.8× ]   추천 기여율 [ 41% ] │
│  채택률 [ 18% ]            연차 소진율 [ 0.86 ] │
├─ 가치 퍼널 ───────────────────────────────────┤
│  onboarding → shown → added → leave_added      │
│   100%   →   72%  →  18% →  (그중 추천 41%)    │
├─ 품질 진단 ───────────────────────────────────┤
│  효율 분포 히스토그램 / source별 채택률         │
│  추천→삭제율 / 번아웃 간격 중앙값 추이          │
└────────────────────────────────────────────────┘
```

### 핵심 BigQuery 스케치 (events_* 테이블)
```sql
-- 채택률 + 채택 효율 (일자별)
WITH shown AS (
  SELECT user_pseudo_id, event_date,
         MAX((SELECT value.int_value FROM UNNEST(event_params)
              WHERE key='count')) AS shown_count
  FROM `events_*`
  WHERE event_name='recommendation_shown'
  GROUP BY 1,2                      -- ← 중복 발화 dedupe
),
added AS (
  SELECT user_pseudo_id, event_date,
         COUNT(*) AS added_count,
         AVG((SELECT value.double_value FROM UNNEST(event_params)
              WHERE key='efficiency')) AS avg_eff
  FROM `events_*`
  WHERE event_name='recommendation_added'
  GROUP BY 1,2
)
SELECT s.event_date,
       SUM(a.added_count) / NULLIF(SUM(s.shown_count),0) AS adoption_rate,
       AVG(a.avg_eff) AS avg_adopted_efficiency
FROM shown s LEFT JOIN added a USING(user_pseudo_id, event_date)
GROUP BY 1 ORDER BY 1;
```

---

## 5. 아직 측정 못 하는 것 (다음 배선 후보)

- **추천 카드 탭→상세 진입** (관심은 있으나 미채택 구간) — `recommendation_tap`
- **위젯 조회 빈도 / 위젯→앱 진입** — 리텐션 핵심인데 이벤트 없음
- **연말 소멸 연차 0 달성** — `year_end_leave_remaining` 스냅샷
- **알림 반응률** — 번아웃/만료 알림이 행동으로 이어지는지
