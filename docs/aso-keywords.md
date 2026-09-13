# App Store ASO — 다국어 메타데이터 패키지

App Store Connect의 "App Information" → "Localizations" 에 그대로 붙여넣기 위한 패키지.
시장 우선순위: **DE > FR > EN > JA > KO > ZH**.

App Store Connect 룰:
- **Name** (앱 이름): 30자 — 가장 중요한 ASO 자산
- **Subtitle**: 30자 — 두 번째로 중요
- **Promotional Text**: 170자 — 자주 갱신 가능, 색인되지 않음
- **Keywords**: 100자 (콤마 구분, 공백 X) — 색인됨
- **Description**: 4000자 — 색인되지 않으나 전환에 중요

---

## 🇩🇪 Deutsch (de-DE) — 1순위 시장

**Name (≤30):**
```
Goldweek — Urlaubsplaner
```

**Subtitle (≤30):**
```
Brückentage clever planen
```

**Promotional Text (≤170):**
```
2026: 8 Urlaubstage = 16 Tage frei. Goldweek findet automatisch die besten Brückentage in Deutschland und kombiniert sie zur längsten Auszeit.
```

**Keywords (≤100, no spaces):**
```
brückentage,urlaubsplaner,feiertage,urlaub,2026,kalender,rechner,brückentag,frei,arbeit,planer
```

---

## 🇫🇷 Français (fr-FR) — 2순위 시장

**Name (≤30):**
```
Goldweek — Congés malins
```

**Subtitle (≤30):**
```
Optimisez les ponts 2026
```

**Promotional Text (≤170):**
```
Mai 2026 : 8 congés = 17 jours de repos. Goldweek calcule automatiquement les meilleurs ponts en France et combine vos congés payés au maximum.
```

**Keywords (≤100):**
```
congés,jours fériés,pont,faire le pont,calendrier,2026,vacances,optimiser,férié,calcul
```

---

## 🇺🇸 English (en-US) — 3순위 시장 (영어권 + 글로벌 폴백)

**Name (≤30):**
```
Goldweek — PTO Planner
```

**Subtitle (≤30):**
```
Maximize holidays, minimize PTO
```

**Promotional Text (≤170):**
```
Turn 3 PTO days into a 9-day break. Goldweek's algorithm finds the optimal PTO placement across 6 countries' public holidays. One-time payment, no subscription.
```

**Keywords (≤100):**
```
pto,vacation,holiday,bridge day,long weekend,planner,calendar,leave,annual,optimizer,2026
```

---

## 🇯🇵 日本語 (ja-JP) — 4순위 시장

**Name (≤30):**
```
Goldweek 有給最適化プランナー
```

**Subtitle (≤30):**
```
GW・連休を最大化
```

**Promotional Text (≤170):**
```
ゴールデンウィークやシルバーウィーク、有給を最も効率よく配置する組み合わせを自動計算。残日数管理と最適化を1つのアプリで。
```

**Keywords (≤100):**
```
有給,休暇,ゴールデンウィーク,GW,シルバーウィーク,連休,祝日,計算,カレンダー,最適化
```

---

## 🇰🇷 한국어 (ko-KR) — 본거지

**Name (≤30):**
```
골드위크 - 연차·황금연휴 플래너
```

**Subtitle (≤30):**
```
최소 연차로 최대 연휴
```

**Promotional Text (≤170):**
```
연차 수당 받지 말고 진짜로 쉬세요. 6개국 공휴일을 분석해 최장 연휴 조합을 알고리즘으로 자동 계산. 1회 결제 후 평생 사용.
```

**Keywords (≤100):**
```
연차,황금연휴,휴가,징검다리,캘린더,공휴일,2026,추천,연차관리,달력
```

---

## 🇨🇳 中文简体 (zh-Hans) — 5순위 시장

**Name (≤30):**
```
Goldweek 年假规划
```

**Subtitle (≤30):**
```
最少年假最长假期
```

**Keywords (≤100):**
```
年假,假期,公假,日历,2026,优化,推荐,休假,假日,长假
```

---

## App Store Description 템플릿 (영문, 4개 언어로 번역해 사용)

```
Plan your PTO like a mathematician.

Goldweek analyzes your country's public holidays + weekends and uses a knapsack-style algorithm to find the absolute optimal placement of your PTO days. Not suggestions — actual provable optimization.

★ ONE-TIME PURCHASE — NO SUBSCRIPTION
Unlike every other PTO planner that locks you into monthly fees, Goldweek Pro is a single lifetime unlock. Buy once, use forever.

★ 6 COUNTRIES SUPPORTED
Germany (Brückentag), France (faire le pont), Korea (황금연휴), Japan (Golden Week), USA, China — full 2024-2030 public holiday data, including movable holidays (Easter Monday, Ascension Day, Whit Monday) calculated correctly.

★ THE OPTIMAL ANNUAL PLANNER (Pro)
Feed it your remaining PTO and it solves the entire year in milliseconds. See exactly which days to take to get the longest possible breaks. One tap to add the whole plan to your calendar.

★ ALSO INCLUDES (Free)
- Total / used / remaining PTO tracker (with half-days and quarter-days)
- Per-leave travel ideas matched to your dates
- Home screen widget
- Custom fiscal year (Jan / Apr / Jul / etc.)
- Bonus leave tracking with expiry alerts

★ PRIVATE BY DESIGN
All your leave data lives on your device + your private iCloud. No accounts, no third-party servers, no tracking of your schedule.

—

Made for people who think "I'll just take the money instead of the vacation" is a tragedy waiting to happen.
```

---

## 게재 체크리스트

- [ ] App Store Connect → My Apps → Goldweek → App Information → **Add Localization** (DE, FR, EN, JA 추가)
- [ ] 각 로컬라이제이션에서 Name/Subtitle/Keywords/Promotional Text 위 값 붙여넣기
- [ ] Screenshots 로컬라이즈 (각 언어 UI 캡처가 이상적이나 시간 부족 시 영문 스크린샷으로 폴백)
- [ ] What's New (이번 릴리스 노트) 4개 언어 작성:
  - "Now supports Germany (Brückentag) and France (faire le pont) public holidays"
  - "New: Optimal Annual Planner (Pro) — algorithmically computes the best PTO placement"
  - "Korean local election holiday June 3, 2026 added"
- [ ] 첫 24시간 모니터링 — 검색 노출량 + 다운로드 변화

---

## 향후 추가 검토

- 🇮🇹 Italiano (이탈리아 — ponte 문화), 🇪🇸 Español (스페인 — puente) 데이터 + 메타데이터 추가
- 🇦🇹 오스트리아 / 🇨🇭 스위스 — 독일과 공휴일 거의 같음, 작은 추가 작업
- 🇳🇱 네덜란드 / 🇵🇱 폴란드 — getbridgeday.com 지원 국가

---

## ASO 모니터링 도구 (선택)

- **Sensor Tower** / **AppFollow** — 키워드 순위 추적 (유료)
- **Appfigures** — 기본 ASO 메트릭 (freemium)
- 또는 단순히 **App Store 본인 앱 검색 → 순위 확인** (수동, 충분)
