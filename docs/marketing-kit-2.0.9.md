# Goldweek 2.0.9 마케팅 킷

버전 2.0.9 출시에 맞춰 바로 복사-붙여넣기 할 수 있는 실행 패키지.
간판 기능: **사진으로 휴가 가져오기** (회사 시스템 휴가 내역 화면을 찍으면 OCR로 자동 인식) + **가족과 일정 공유**.

이번 릴리즈 포함 사항:
- 사진에서 휴가 가져오기 — 사내 ERP 휴가 신청 내역을 촬영/스크린샷하면 날짜·유형·차감 일수를 자동 인식, 대체휴가는 연차 차감 없이 등록
- 일정 공유 (CloudKit CKShare) + 가족 탭 — 공유받은 가족·팀원의 일정을 멤버별로 표시
- 타임머신 — 데이터가 바뀔 때마다 자동 스냅샷 저장, 원하는 시점으로 복원
- 백업 암호화 개인 키 전환, 데이터 보호 체계 강화(저장소 격리·자동 복구)

---

## 1. App Store 릴리즈 노트 (What's New) — 이모지 없음

### 한국어
```
[새로운 기능]

사진으로 휴가 가져오기
회사 시스템의 휴가 신청 내역 화면을 찍거나 스크린샷을 선택하면 날짜, 유형, 차감 일수를 자동으로 인식해 한 번에 등록할 수 있어요. 대체휴가처럼 연차를 차감하지 않는 휴가도 정확하게 구분합니다.

가족과 일정 공유
내 휴가 일정을 가족이나 팀원과 공유해보세요. 공유받은 일정은 새로운 가족 탭에서 멤버별로 확인할 수 있어요.

타임머신
데이터가 바뀔 때마다 자동으로 스냅샷이 저장돼요. 실수로 데이터를 지웠어도 설정의 타임머신에서 원하는 시점으로 되돌릴 수 있습니다.

[개선 사항]

- 백업 암호화를 기기별 개인 키로 강화했어요. 기존 백업도 그대로 복원됩니다.
- 데이터 보호 체계를 전면 강화했어요. 어떤 경우에도 데이터를 삭제하지 않고 자동으로 복구를 시도합니다.
- 앱 시작 안정성을 개선했어요.
```

### English
```
[What's New]

Import Leaves from a Photo
Snap a photo (or pick a screenshot) of your company's leave request history and Goldweek recognizes the dates, types, and deducted days automatically. Compensatory days off that don't consume your annual leave are classified correctly.

Share Your Schedule with Family
Share your leave schedule with family or teammates. Shared schedules appear in the new Family tab, organized by member.

Time Machine
A snapshot is saved automatically whenever your data changes. If anything is ever lost or deleted by mistake, restore any point in time from Settings.

[Improvements]

- Backup encryption upgraded to a per-device private key. Existing backups still restore.
- Data protection overhauled: your data is never deleted, and recovery is attempted automatically.
- Improved app launch stability.
```

### 日本語
```
[新機能]

写真から休暇を取り込み
会社システムの休暇申請履歴画面を撮影(またはスクリーンショットを選択)すると、日付・種類・控除日数を自動で認識してまとめて登録できます。代替休暇のように有給を消費しない休暇も正確に区別します。

家族と予定を共有
休暇の予定を家族やチームメンバーと共有できます。共有された予定は新しい「家族」タブでメンバー別に確認できます。

タイムマシン
データが変更されるたびにスナップショットを自動保存。誤って削除しても、設定のタイムマシンから任意の時点に復元できます。

[改善点]

- バックアップの暗号化を端末ごとの秘密鍵に強化しました。既存のバックアップもそのまま復元できます。
- データ保護を全面強化。いかなる場合もデータを削除せず、自動的に復旧を試みます。
- アプリ起動の安定性を改善しました。
```

### 简体中文
```
[新功能]

从照片导入休假
拍摄(或选择截图)公司系统的休假申请记录页面,即可自动识别日期、类型和扣除天数并一键登记。调休等不扣年假的休假也能准确区分。

与家人共享日程
将您的休假日程与家人或同事共享。共享的日程会在全新的"家人"标签页中按成员显示。

时光机
每当数据发生变化时都会自动保存快照。即使误删数据,也可以在设置的时光机中恢复到任意时间点。

[改进]

- 备份加密升级为设备专属私钥,现有备份仍可正常恢复。
- 全面强化数据保护:任何情况下都不会删除数据,并自动尝试恢复。
- 改进了应用启动稳定性。
```

---

## 2. Promotional Text 갱신 (심사 없이 교체 가능, ≤170자)

> App Store Connect → 각 로컬라이제이션의 Promotional Text에 붙여넣기.
> 색인은 안 되지만 스토어 첫인상 전환에 중요. 시즌마다 갱신 권장.

**한국어 (ko):**
```
NEW: 회사 휴가 내역을 사진으로 찍으면 자동 등록! 대체휴가까지 정확하게 구분해요. 남은 연차는 황금연휴로 — 최적의 연차 조합을 Goldweek이 계산합니다.
```

**English (en-US):**
```
NEW: Snap a photo of your leave history and Goldweek imports it automatically — even comp days that don't use PTO. Turn your remaining days into the longest break.
```

**日本語 (ja):**
```
NEW: 休暇申請履歴を写真に撮るだけで自動登録。代替休暇も正確に区別します。残りの有給を最長の連休に変える最適な組み合わせをGoldweekが計算します。
```

**Deutsch (de-DE):**
```
NEU: Fotografiere deine Urlaubsübersicht und Goldweek importiert sie automatisch. Verwandle deine Resturlaubstage in die längste Auszeit des Jahres.
```

**Français (fr-FR):**
```
NOUVEAU : Photographiez votre historique de congés et Goldweek l'importe automatiquement. Transformez vos jours restants en ponts maximisés.
```

---

## 3. App Review 노트 (심사 제출 시)

```
1) Photo import: with the user's action, the app performs ON-DEVICE text recognition (Apple Vision framework) on a photo the user takes (NSCameraUsageDescription) or picks via the system PhotosPicker (no library permission required). It extracts leave dates/types from the photo and shows them as suggestions; nothing is added without explicit user confirmation. Photos and recognized text never leave the device and are not stored.

2) Schedule sharing: uses CloudKit CKShare. The owner explicitly creates a share link via the system share sheet; participants see the owner's leave schedule in a read-only "Family" tab. Testing requires two devices signed into different Apple IDs (CKShare acceptance is not supported in the simulator).

3) The one-time "Pro" in-app purchase (com.Ysoup.LeaveWise.pro) unlocks bonus-leave management, calendar sync, and automatic leave detection.
```

체크리스트 (제출 전):
- CloudKit Console에서 스키마 **Production 배포** 확인 (미배포 시 공유 기능 전멸)
- 실기기 2대(서로 다른 Apple ID)로 공유 수락 플로우 최종 확인

---

## 4. 커뮤니티 게시글 초안

### 블라인드 (한국) — "직장인 꿀팁" 톤, 광고 티 최소화
```
제목: 회사 휴가내역 정리 귀찮은 사람 개꿀팁

인사시스템에서 휴가 신청은 하는데
정작 내가 올해 연차 몇 개 썼는지는 모르는 사람 많지?

Goldweek이라는 앱 쓰는데 인사시스템 휴가내역 화면을
폰으로 찍기만 하면 날짜/반차/반반차 다 알아서 인식해서 등록됨.
대체휴가는 연차 차감 안 되는 것까지 구분함.

공휴일 끼워서 연차 최소로 쓰고 길게 쉬는 조합도 알려줘서
10월에 연차 2개로 9일 쉬는 각 나옴.

무료로 쓸 수 있고 앱스토어에서 골드위크 검색.
```

### 인스타그램/스레드 (한국) — 캐러셀·릴스용 카피
```
슬라이드 1: 올해 쓴 연차, 손으로 하나하나 입력하고 있나요?
슬라이드 2: 회사 휴가내역 화면을 찰칵 — 자동으로 전부 등록
슬라이드 3: 반차 0.5일, 반반차 0.25일, 대체휴가는 차감 없이. 정확하게
슬라이드 4: 가족 탭에서 우리 가족 휴가 일정도 한눈에
슬라이드 5: 남은 연차를 황금연휴로, Goldweek 🏖
해시태그: #연차 #연차관리 #황금연휴 #직장인 #연차계산 #휴가계획
```

### X/Twitter (일본) — 有給消化 문화 공략
```
会社の休暇申請履歴、写真に撮るだけで全部登録できたら?

勤怠システムの画面を撮影すると「有給・半休・代休」を
自動で認識して集計してくれる機能を追加しました。
代休は有給を消費しない扱いまで正確に区別します。

Goldweek(ゴールデンウィーク)、App Storeで無料です🏖
#有給 #有給消化 #連休
```

### Reddit r/germany, r/france (영어) — 담백한 tool-share 톤
```
Title: My bridge-days app can now import your leave history from a photo

Goldweek finds the optimal "bridge days" (Brückentage/ponts) for your
vacation days. New in 2.0.9: take a photo of your company's leave
history screen and it imports everything via on-device OCR — dates,
half days, even comp days that don't consume PTO. You can also share
your schedule with family via iCloud.
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
| 7~8월 | "상반기 휴가 정산" — 사진 가져오기로 밀린 기록 한 번에 (신규 훅) | 블라인드, 인스타 |
| 8~9월 | 추석 연휴 조합 콘텐츠 (한국), シルバーウィーク (일본) | 블라인드, X(일) |
| 10~11월 | "연차 소진 시즌" — 남은 연차 계산 유도 | 전 채널 |

**공유 기능 연계**: 일정 공유(CKShare) 초대 링크가 자연스러운 바이럴 루프.
"가족이랑 휴가 일정 맞춰보세요"를 CTA로 쓰면 초대받은 가족이 앱을 설치하는
구조가 만들어짐. 앱 내 "연차 플랜 공유" 이미지 브랜딩 푸터와 병행.

---

## 6. 측정 (이번 릴리즈에서 볼 것)

Firebase에서 볼 것:
- `leave_added` (type: `photo_import`) → **사진 가져오기 사용량과 건당 등록 수**. 이번 릴리즈의 핵심 지표
- `leave_added` (type: `calendar_import`) 대비 photo_import 비중 → 어느 가져오기 경로가 주력인지
- `plan_shared` → 공유 기능 사용량 (바이럴 루프 선행 지표)
- `paywall_view` / `paywall_purchase` → 전환 추이 유지 확인
- Crashlytics: 앱 시작 크래시 제로 확인 (2.0.9에서 ModelContainer 초기화 수정)
```
