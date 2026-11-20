# App Review 정보 — 골드위크(Goldweek)

2026-11-19 Mac 앱 첫 제출(2.4.7 빌드 25)에 Guideline 2.1 "Information Needed" 추가 정보 요청이 왔다.
앱에 문제가 있다는 말이 아니라, 새 플랫폼 첫 제출이라 앱을 설명해 달라는 요청이다. 새 빌드는 필요 없다.

**2026-11-20 답장 보냄** — 회신에 아래 글 + 영상(첨부용으로 줄인 `Goldweek-macOS-review-small.mp4`, 1.9MB)을 붙여 보냈고, Mac 2.4.7 앱 심사 정보 ▸ 메모도 같은 글로 바꿨다.

다음에 같은 요청이 오면 할 일은 셋이다.

1. 화면 녹화를 만든다 — `scripts/record_mac_review.sh` → `~/Desktop/골드위크-심사/Goldweek-macOS-review.mp4`
2. 아래 영어 글을 **App Store Connect ▸ 해당 제출 ▸ 앱 심사에 회신** 에 붙이고 영상을 첨부해 보낸다
3. 같은 글을 **앱 심사 정보 ▸ 메모** 에도 넣는다 (다음 제출 때 같은 질문을 다시 받지 않는다)

## 녹화 (이 맥에서 자동)

    scripts/record_mac_review.sh     # 도는 동안(약 2분) 마우스·키보드를 건드리지 말 것

iMac(Apple M3), macOS 27.0 실기기. 앱이 뜨는 순간부터 요금제 화면까지 창 영역만 찍는다(2048×1536, 1분 14초, 20MB).
2026-11-20 본: `~/Desktop/골드위크-심사/Goldweek-macOS-review.mp4`. 클릭 좌표는 2026-11 달력 기준이라 달이 바뀌면 고쳐야 한다.
DEBUG 빌드를 데모 데이터(`-screenshotMode YES`, 영어, 무료 사용자)로 띄운다 — 가격과 구매 버튼이 보인다.
⚠️ 데모 모드는 이 맥의 골드위크 데이터를 데모 데이터로 덮어쓴다(Mac 스크린샷 찍을 때와 같다).

## 답장 · 메모 (영어, 그대로 붙여 넣기 — 칸 한도 4000자에 맞춘 글)

Hello App Review team,

Thank you for reviewing Goldweek for Mac. A screen recording is attached, captured on a physical Mac (iMac, Apple M3, macOS 27.0). The app has no accounts, registration, or login, so there is no account deletion flow. It has no public user-generated content, so there are no reporting or blocking flows.

1. Screen recording
Attached (1 min 14 s). In order: launching the app, the calendar with public holidays and the leave balance, choosing November 24 and registering two days of leave, the updated balance, January 2027 with the Recommended Schedule, and Settings > Upgrade, which opens the purchase screen with the Pro and Plus plans, their monthly, yearly, and lifetime prices, Restore Purchase, Redeem Offer Code, Terms of Service, and Privacy Policy.

2. Purpose and audience
Goldweek is a paid time off (PTO) tracker and vacation planner. People lose leave days or miss long breaks because they do not notice that one day off next to a public holiday makes a long weekend. Goldweek keeps the leave balance on one screen and shows, for each upcoming public holiday, which days to take off for the longest break with the fewest leave days. It is for employees, part-time and shift workers, teachers, and families planning time off together. The Mac app is the same app as the iPhone and iPad app already on the App Store.

3. Main features (no login or sample files needed)
- First launch: a short setup asks for your country and annual leave days.
- Click a date in the calendar, then "Add leave on this date" to log a full, half, or quarter day.
- The right panel shows Annual Leave (used, planned, left), Upcoming Leaves, and Leave History.
- Below the calendar, Recommended Schedule lists the best days to take off. "Add to Schedule" adds one.
- The gear button opens Settings.
- Paid tiers: Plus (yearly planner, unlimited suggestions, export to Calendar) and Pro (Plus features plus bonus leave, limits per leave type, school calendar import, and planning with family). Each is a monthly or yearly auto-renewable subscription or a one-time lifetime purchase, opened from Settings > Upgrade. Settings also has Restore Purchase, an optional tip, and Send a Gift (a consumable that gives an App Store offer code).
- Leave tracking, holidays, this year's suggestions, widgets, notifications, and iCloud backup are free.

4. External services
No server of our own, no third-party SDKs, no ads, no analytics companies, no AI services. Suggestions are calculated on the device.
- StoreKit (In-App Purchase)
- CloudKit / iCloud (optional backup, optional private schedule sharing with family through an iCloud share link, holiday corrections, the feedback form, anonymous usage counts)
- EventKit (optional, with permission: export to and import from Calendar)
- Vision and PDFKit (on-device text recognition to import leave from a photo or PDF)
- User Notifications and WidgetKit
- MyRealTrip partner API: only when the app language is Korean and the country is South Korea, a suggestion can show an optional "travel ideas" card with public tour, flight, and stay listings from MyRealTrip, a Korean travel service. A listing opens the MyRealTrip website in the browser. No personal data is sent and nothing is sold in the app.

5. Regional differences
Features are the same everywhere, with two content differences: the public holiday calendar follows the country and region the user selects (42 countries built in, others can enter their own), and the MyRealTrip card appears only for Korean-language users in South Korea. Prices follow App Store pricing for each storefront.

6. Regulated industry or third-party material
Not applicable. The app is not in a regulated industry. Public holiday dates are public facts. MyRealTrip listings come from MyRealTrip's partner API with an API key MyRealTrip issued to us, and each links back to the MyRealTrip website. All other artwork and text are our own.

Thank you.
