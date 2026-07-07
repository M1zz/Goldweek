# Goldweek 2.0.9 마케팅 킷

버전 2.0.9 출시에 맞춰 바로 복사-붙여넣기 할 수 있는 실행 패키지.
간판 기능: **캘린더 휴가 자동 감지 + 가져오기** (반차/연차/병가 유형 자동 인식).

---

## 1. App Store 릴리즈 노트 (What's New)

### 🇰🇷 한국어
```
✨ 캘린더에서 휴가 가져오기
캘린더에 적어둔 "연차", "반차", "휴가" 일정을 자동으로 찾아 확인 후 한 번에 등록할 수 있어요. 반차는 0.5일, 반반차는 0.25일로 정확하게 계산됩니다.

⚡ Pro: 자동 감지
앱을 열 때마다 새 휴가 일정을 자동으로 찾아 알려드려요.

📤 연차 플랜 공유
남은 연차와 다가오는 휴가를 예쁜 이미지로 공유해보세요.

그 외 저장 실패 알림, 백업 안정성, 접근성 등 30여 가지가 개선됐어요.
```

### 🇺🇸 English
```
✨ Import Leaves from Calendar
Goldweek now finds leave events ("vacation", "PTO", "day off"...) in your calendar and adds them in one tap after your review. Half days are counted precisely as 0.5 days.

⚡ Pro: Auto-Detect
Pro automatically spots new leave events every time you open the app.

📤 Share Your Leave Plan
Share your remaining days and upcoming leaves as a beautiful image.

Plus 30+ improvements to reliability, backup, and accessibility.
```

### 🇯🇵 日本語
```
✨ カレンダーから休暇を取り込み
カレンダーの「有給」「半休」「休暇」予定を自動で見つけて、確認後まとめて登録できます。半休は0.5日として正確に計算されます。

⚡ Pro: 自動検出
アプリを開くたびに新しい休暇予定を自動でお知らせします。

📤 休暇プランを共有
残りの有給と今後の休暇をきれいな画像で共有できます。

その他、保存エラー通知・バックアップの安定性・アクセシビリティなど30以上の改善。
```

### 🇨🇳 简体中文
```
✨ 从日历导入休假
自动查找日历中的"年假""请假""休假"日程,确认后一键登记。半天假精确按0.5天计算。

⚡ Pro: 自动检测
每次打开应用时自动发现新的休假日程。

📤 分享休假计划
将剩余年假和即将到来的休假生成精美图片分享。

另有30多项稳定性、备份与无障碍改进。
```

---

## 2. Promotional Text 갱신 (심사 없이 교체 가능, ≤170자)

> App Store Connect → 각 로컬라이제이션의 Promotional Text에 붙여넣기.
> 색인은 안 되지만 스토어 첫인상 전환에 중요. 시즌마다 갱신 권장.

**🇰🇷:**
```
NEW: 캘린더 속 "연차·반차" 일정을 자동으로 찾아 등록해드려요. 남은 연차는 황금연휴로 — 최적의 연차 조합을 Goldweek이 계산합니다.
```

**🇺🇸:**
```
NEW: Goldweek finds "PTO" and "vacation" events in your calendar and imports them automatically. Turn your remaining days into the longest possible break.
```

**🇯🇵:**
```
NEW: カレンダーの「有給・半休」予定を自動で見つけて登録。残りの有給を最長の連休に変える最適な組み合わせをGoldweekが計算します。
```

**🇩🇪:**
```
NEU: Goldweek erkennt „Urlaub"-Termine in deinem Kalender automatisch. Verwandle deine Resturlaubstage in die längste Auszeit des Jahres 2026.
```

**🇫🇷:**
```
NOUVEAU : Goldweek détecte vos « congés » dans votre calendrier et les importe automatiquement. Transformez vos jours restants en ponts maximisés.
```

---

## 3. App Review 노트 (심사 제출 시)

```
This update adds calendar import: with the user's permission (NSCalendarsFullAccessUsageDescription), the app scans the user's calendar for all-day events whose titles contain leave-related keywords (e.g., "vacation", "PTO", "연차"), and shows them as suggestions. Nothing is added without explicit user confirmation. Calendar data never leaves the device.

The one-time "Pro" in-app purchase (com.Ysoup.LeaveWise.pro) unlocks bonus-leave management, calendar sync, and automatic leave detection.
```

---

## 4. 커뮤니티 게시글 초안

### 블라인드 (한국) — "직장인 꿀팁" 톤, 광고 티 최소화
```
제목: 연차 쓸 때 캘린더에만 적어두는 사람 개꿀팁

연차 쓰면 회사 캘린더/구글캘린더에만 "연차"라고 적어두고
정작 내가 올해 몇 개 썼는지 모르는 사람 많지?

Goldweek이라는 앱 쓰는데 캘린더에서 "연차/반차" 일정을 알아서
긁어와서 잔여 연차 자동 계산해줌. 반차는 0.5개로 계산됨.
공휴일 끼워서 연차 최소로 쓰고 길게 쉬는 조합도 알려줘서
10월에 연차 2개로 9일 쉬는 각 나옴.

무료로 쓸 수 있고 앱스토어에서 골드위크 검색.
```

### 인스타그램/스레드 (한국) — 캐러셀·릴스용 카피
```
슬라이드 1: 올해 연차, 몇 개 남았는지 바로 말할 수 있나요?
슬라이드 2: 캘린더에 적어둔 "연차" 일정, 자동으로 찾아드립니다
슬라이드 3: 반차는 0.5일, 반반차는 0.25일까지 정확하게
슬라이드 4: 공휴일에 연차를 붙이면? 연차 2개 = 9일 연휴
슬라이드 5: 남은 연차를 황금연휴로, Goldweek 🏖
해시태그: #연차 #연차관리 #황금연휴 #직장인 #연차계산 #휴가계획
```

### X/Twitter (일본) — 有給消化 문화 공략
```
有給、何日残ってるかすぐ答えられますか?

カレンダーに書いた「有給」「半休」を自動で見つけて集計してくれるアプリを作りました。
祝日と組み合わせて「有給2日で9連休」みたいな最適プランも提案します。

Goldweek(ゴールデンウィーク)、App Storeで無料です🏖
#有給 #有給消化 #連休
```

### Reddit r/germany, r/france (영어) — 담백한 tool-share 톤
```
Title: I built an app that finds the optimal "bridge days" (Brückentage/ponts) for your vacation days

It reads public holidays for DE/FR/KR/JP/US, calculates which leave-day
combinations give you the longest continuous break, and can now import
existing "vacation" events from your calendar automatically.
Free on iOS, one-time purchase for pro features (no subscription).
Happy to answer questions / take feature requests.
```

---

## 5. 시즌 콘텐츠 캘린더 (연간 반복 실행)

| 시기 | 액션 | 채널 |
|---|---|---|
| 12월 말~1월 초 | "내년 황금연휴 캘린더" 콘텐츠 (최대 바이럴 시즌) | 블라인드, 인스타, X |
| 정부 공휴일/대체휴일 발표 직후 | 발표 당일 "이 날 연차 쓰면 N연휴" 속보형 포스트 | 전 채널 |
| 4월 말 | 5월 황금연휴 직전 리마인드 + MRT 여행 카드 강조 | 인스타/스레드 |
| 8~9월 | 추석 연휴 조합 콘텐츠 (한국), シルバーウィーク (일본) | 블라인드, X(일) |
| 10~11월 | "연차 소진 시즌" — 남은 연차 계산 유도 | 전 채널 |

**공유 기능 연계**: 앱 내 "연차 플랜 공유" 이미지에 브랜딩 푸터가 들어가므로,
사용자가 플랜을 공유할 때마다 오가닉 노출 발생. 커뮤니티 포스트에서
"내 플랜 공유해보기"를 CTA로 쓰면 루프가 돌기 시작함.

---

## 6. 측정 (이번 릴리즈에 추가된 이벤트)

Firebase에서 볼 것:
- `mrt_card_impression` / `mrt_card_tap` → **MRT 카드 CTR** (category별: flight/stay/tour)
- `auto_detect_banner` → 자동 감지 배너 노출 (is_pro 구분)
- `paywall_view` (source: `auto_detect_setting`) → 자동 감지發 페이월 유입
- `paywall_purchase` → 전환. **자동 감지 소스의 전환율이 기존 배너보다 높은지**가 이번 실험의 핵심 질문
- `plan_shared` → 공유 기능 사용량 (바이럴 루프 선행 지표)
