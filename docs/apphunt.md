# r/apphunt — Goldweek 소개 포스트

> Reddit r/apphunt 서브레딧 등록용 초안입니다. `[채울 부분: ...]` 으로 표시된 곳을 직접 채워 넣으세요.
> Reddit은 AppHunt 같은 큐레이션 플랫폼과 달리 **짧고, 솔직하고, self-promotion 티 안 나는** 톤이 잘 먹힙니다.

---

## 1. 포스트 제목 (Title)

r/apphunt의 일반적인 제목 포맷: `[iOS] App name — one-line description`

**추천 제목**:

```
[iOS] Goldweek — turn 1 vacation day into a 5-day break by auto-suggesting the best PTO combos around holidays
```

**대안 후보**:

```
[iOS] Goldweek — smart PTO planner that finds the longest holidays from your remaining leave days
```

```
[iOS] I built a PTO tracker that tells you exactly which days to take off for the longest break
```

```
[채울 부분: 직접 쓰고 싶은 제목이 있다면]
```

> 💡 Reddit Tip: 제목에 "I built", "I made"가 들어가면 메이커 포스트로 보여서 호응이 좋지만, self-promo 룰을 사전에 꼭 확인하세요 (서브레딧마다 다름).

---

## 2. 본문 (Body)

### 영문 버전 (r/apphunt 권장)

```markdown
Hey r/apphunt 👋

I'm `[채울 부분: 본인 이름 또는 닉네임]`, the maker of **Goldweek** — an iOS app that helps you plan PTO around public holidays so you get the longest possible break with the fewest days off.

**The problem I had:**
Every year I'd open the calendar, count holidays on my fingers, and try to figure out "if I take *this* day off, can I get a 9-day break?" It was annoying enough that I built an app for it.

**What it does:**
- 📊 Tracks your total / used / remaining PTO (supports half-days and quarter-days)
- ✨ **Algorithmic optimizer** finds the longest possible breaks using a knapsack-style DP over your holidays + weekends — not random suggestions
- 🇩🇪 🇫🇷 🇰🇷 🇯🇵 🇨🇳 🇺🇸 6-country public holidays out of the box (Brückentag / faire-le-pont / 황금연휴 / Golden Week all supported)
- 🎁 Manages bonus leave (compensatory, refresh, reward) with expiry alerts
- 📱 Home screen widget — see remaining PTO without opening the app
- ☁️ iCloud backup
- 🏢 Custom fiscal year (Jan / Apr / Jul / etc.) for company-specific cycles

**How it's different from other PTO/bridge-day apps:**
- 💎 **One-time purchase, no subscription** — most planners are subscriptions or shady free + ads. Goldweek is a single lifetime unlock
- 🧠 **Real algorithm, not just a calendar overlay** — uses weighted interval scheduling + 0/1 knapsack DP to find provably optimal day combinations
- 🔒 **Fully local** — your leave data lives only on your device + your private iCloud. No third-party servers, no account

**Pricing:** Free with all core features (incl. per-leave travel ideas, multi-country holidays). **Pro adds the Optimal Annual Planner** — feed it your remaining PTO and it solves the whole year's optimal placement instantly. Plus: bonus-leave management, multi-year recommendations, iCloud backup, system Calendar sync. **One-time payment, lifetime access — no subscription** at `[채울 부분: 가격 — 예: $4.99 lifetime]`.

**Tech stack** (in case anyone's curious): SwiftUI + SwiftData + WidgetKit + CloudKit + StoreKit 2. Solo-built.

App Store: https://apps.apple.com/app/id6739899592
Landing: https://m1zz.github.io/Goldweek/

Happy to answer any questions in the comments — feedback very welcome 🙏

`[채울 부분: 메이커가 직접 한 줄 — 예: "Currently working on Android version" / "Next up: Apple Watch complication" 등 다음 계획이 있으면 한 줄]`
```

---

### 한글 버전 (한국 서브레딧이거나 한국어 포스트일 경우)

```markdown
안녕하세요 r/apphunt 👋

iOS 연차 관리 앱 **Goldweek**(골드위크) 만든 `[채울 부분: 본인 이름/닉네임]`입니다.

**왜 만들었냐면:**
연차 수당으로 받으면 그만이라고들 하지만, **돈 받느니 진짜로 쉬는 게 백배 낫다**는 게 본인 경험이었어요. 매년 달력 펴서 "여기 연차 끼면 며칠 쉴 수 있지" 손가락 세는 게 짜증나서 알고리즘으로 풀었습니다.

**뭐 하는 앱이냐면:**
- 📊 총/사용/남은 연차 한눈에 (반차·반반차 지원)
- ✨ **공휴일·주말 분석해서 최소 연차로 최대 연휴 만드는 조합을 알고리즘으로 자동 계산** (DP 기반, 추천 아닌 최적해)
- 🇰🇷 🇯🇵 🇨🇳 🇺🇸 🇩🇪 🇫🇷 6개국 공휴일 데이터 내장 (2024~2030)
- 🎁 대체휴무·포상휴가 만료 알림
- 📱 홈 위젯, ☁️ iCloud 백업
- 🏢 회계연도 커스터마이징 (1월/4월/7월 등)

**다른 연차 앱과 차별점:**
- 💎 **구독 없음, 1회성 평생결제**. 점심값으로 사면 영원히 내 것
- 🧠 **진짜 알고리즘** — DP/knapsack으로 최적해 계산. 추천 아닌 수학
- 🔒 **데이터 100% 로컬 + 내 iCloud**. 외부 서버 0, 계정 가입 0

**가격:** 핵심 기능 무료(휴가별 여행 큐레이션 + 6개국 공휴일 포함). **Pro는 최적 연간 휴가 플래너** — 남은 연차 N일로 만들 수 있는 최장 연휴 조합을 한 번에 계산해 일괄 등록. 보너스 연차 관리 + 다년도 추천 + iCloud 백업 + 시스템 캘린더 연동. **구독 아닌 1회성 결제, 평생 사용** — `[채울 부분: 가격]`.

**스택:** SwiftUI + SwiftData + WidgetKit + CloudKit + StoreKit 2 (1인 개발).

App Store: https://apps.apple.com/app/id6739899592
랜딩: https://m1zz.github.io/Goldweek/

피드백 환영합니다 🙏 댓글로 질문 주시면 답변 드릴게요.

`[채울 부분: 다음 계획 한 줄 — 예: "안드 버전 작업 중", "워치 컴플리케이션 추가 예정" 등]`
```

---

## 3. Flair / Tag

r/apphunt에서 일반적으로 사용되는 flair:

- [ ] `iOS`
- [ ] `Free` 또는 `Freemium`
- [ ] `Productivity`
- [ ] `[채울 부분: 서브레딧에서 제공하는 정확한 flair 확인 후 선택]`

---

## 4. 첨부 이미지 / 미디어

Reddit 포스트는 **이미지 1장 또는 짧은 GIF**가 클릭률을 크게 좌우합니다.

추천 첨부물 (우선순위 순):

1. ⭐ **30초 이하 데모 GIF** — 황금연휴 추천 → 캘린더 등록까지 보여주기
2. **메인 스크린샷 1장** — `docs/images/screenshot-3.png` (추천 화면이 가장 임팩트 있음)
3. **위젯 in-context 컷** — 홈 화면에서 위젯이 동작하는 모습

> 💡 Reddit은 자체 호스팅 이미지(i.redd.it)가 외부 링크보다 노출이 잘 됩니다. imgur보다 직접 업로드 권장.

`[채울 부분: 데모 GIF 제작 — Kap, GIPHY Capture, 또는 시뮬레이터 녹화 후 변환]`

---

## 5. 댓글 응대 준비 (FAQ 답변 미리 작성)

Reddit 포스트는 **댓글 응대가 거의 본문만큼 중요**합니다. 자주 나올 질문 미리 준비:

**Q: Android version?**
> A: `[채울 부분: 계획 있으면 ETA, 없으면 솔직하게 — 예: "iOS-only for now, considering it based on demand"]`

**Q: Why not just use Calendar / Notion?**
> A: Calendar tells you holidays. Goldweek tells you *which day to take off* to maximize the break — that's the part calendars don't do.

**Q: Does it work outside Korea?**
> A: Yes — supports KR / JP / CN / US holidays out of the box. UI in 4 languages. `[채울 부분: 다른 국가 추가 계획이 있으면]`

**Q: Open source?**
> A: `[채울 부분: 예/아니오 — 일부 GitHub repo가 public이므로 정확하게 답변]`

**Q: How does the recommendation algorithm work?**
> A: `[채울 부분: 간단히 — 예: "It scans public holidays + weekends in your region, then computes the smallest set of PTO days needed to bridge them into the longest contiguous breaks. Filters by your preferred season/duration."]`

**Q: Privacy / data?**
> A: All data stays on-device + your private iCloud. No third-party servers for your leave data. `[채울 부분: 정확한 정책 — Firebase Analytics는 사용 중이므로 명시 권장]`

**Q: Pro vs Free difference?**
> A: **Free** = all core leave tracking (status / register / calendar / AI holiday suggestions for the current year) + per-leave travel ideas. **Pro** = AI annual planner (drafts your whole year of leave from your prefs/constraints), bonus leave management (compensatory / refresh), next-year recommendations, iCloud backup, and iOS Calendar sync.

---

## 6. 등록 전 체크리스트

- [ ] **서브레딧 룰 확인** — r/apphunt의 self-promotion 규정 (대부분 OK지만 격주 1회 제한 등 있을 수 있음)
- [ ] **Account karma / age** 확인 — 신규 계정은 자동 필터링될 수 있음
- [ ] 제목 후보 1개로 확정
- [ ] 본문에서 `[채울 부분]` 모두 교체
- [ ] 데모 GIF 또는 메인 스크린샷 1개 준비
- [ ] App Store 링크 동작 확인
- [ ] 댓글 응대 가능한 시간대에 포스트 (북미 기준 평일 오전 EST 권장 → 한국 기준 밤 9~11시)
- [ ] 첫 1~2시간 내 댓글에 즉시 응답 — Reddit 알고리즘에 큰 영향
- [ ] **다른 관련 서브레딧 동시 고려**:
  - r/iOSProgramming (메이커 관점 강조 시)
  - r/SideProject (1인 개발 톤)
  - r/productivity (사용자 관점)
  - r/SwiftUI (기술 스택 관점)
  - r/iosapps
  - `[채울 부분: 추가 타겟 서브레딧]`

---

## 7. 참고: r/apphunt 톤 매뉴얼

- ❌ 마케팅 카피 ("Revolutionary!", "Game-changer!") 금지
- ❌ 모든 기능 나열하지 말기 (3~5개 핵심만)
- ✅ "I had this problem → I built this" 구조
- ✅ 솔직한 한계 인정 (예: "iOS only", "no sync between users")
- ✅ 댓글에 빠르게 반응
- ✅ 메이커 본인이 쓴 티 (말투, 1인칭) 유지
