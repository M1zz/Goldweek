# Release Notes

## v2.1.2 — 읽기 쉬운 화면, 어디서 봐도 같은 숫자

> 이전 출시: v2.1.1
> 핵심: 앱 전체 글자를 본문 크기 이상으로 키우고, 홈·휴가 사용 내역·설정이 서로 다른 "사용 완료" 일수를 보여주던 문제를 잡았습니다. 다가오는 휴가에 공휴일이 함께 뜨고, 사용법 안내를 언제든 다시 볼 수 있습니다.

---

### App Store "이번 버전의 새로운 기능" (붙여넣기용)

#### 🇰🇷 한국어
```
글자가 커지고, 어디서 봐도 숫자가 같아졌어요.

• 앱 전체 글자를 본문 크기 이상으로 키웠어요
• 홈과 휴가 사용 내역의 "사용 완료" 일수가 서로 다르던 문제를 바로잡았어요
• 다가오는 휴가에 공휴일도 함께 보여줘요 (설정에서 끌 수 있어요)
• 캘린더에서 날짜를 누르면 그 날 휴가를 바로 수정하거나 지울 수 있어요
• 캘린더 아래쪽을 추천 휴가 일정으로 바꿨어요 — 노란 표시를 목록에서 바로 등록하세요
• 연차 현황을 공유할 때 어떤 이미지가 나가는지 먼저 보여드려요
• 사용법 안내를 새로 넣었어요 — 설정 > 도움말에서 언제든 다시 볼 수 있어요
• 설정 > 지원에서 피드백을 바로 보낼 수 있어요
• 영어·일본어·중국어 화면에 한국어가 섞여 나오던 문구를 정리했어요
• Google 애널리틱스를 완전히 걷어냈어요. 앱 개선용 익명 통계는 개발자 본인의 iCloud에만 저장돼요
```

#### 🇺🇸 English
```
Bigger text, and the same numbers everywhere.

• Text across the app is now at body size or larger
• Fixed "days used" showing different totals on Home and in Leave History
• Upcoming Leave now lists public holidays too (you can turn this off in Settings)
• Tap a date on the calendar to edit or delete that day's leave right there
• The calendar now ends with suggested breaks — add one straight from the list
• Sharing your leave status shows a preview of the image first
• A new how-to guide — reopen it any time from Settings > Help
• Send feedback directly from Settings > Support
• Cleaned up Korean text that leaked into English, Japanese and Chinese screens
• Google Analytics is gone. Anonymous usage stats stay in the developer's own iCloud
```

#### 🇯🇵 日本語
```
文字が大きくなり、どの画面でも同じ数字に。

• アプリ全体の文字を本文サイズ以上に大きくしました
• ホームと休暇の履歴で「使用済み」日数が食い違う問題を修正しました
• 「今後の休暇」に祝日も表示します（設定でオフにできます）
• カレンダーで日付をタップすると、その日の休暇をその場で編集・削除できます
• カレンダー下部をおすすめの連休一覧に変更しました — その場で登録できます
• 有給の状況を共有するとき、送る画像を先に確認できます
• 使い方ガイドを追加しました — 設定 > ヘルプからいつでも見られます
• 設定 > サポートからフィードバックを送れます
• 英語・日本語・中国語の画面に韓国語が混ざっていた文言を整理しました
• Google アナリティクスを完全に削除しました。匿名の利用統計は開発者本人のiCloudにのみ保存されます
```

#### 🇨🇳 中文(简体)
```
字更大了，各处数字也一致了。

• 全应用文字提升到正文大小以上
• 修复了首页与休假记录中"已使用"天数不一致的问题
• "即将到来的假期"现在也会显示节假日（可在设置中关闭）
• 在日历上点击日期，即可就地编辑或删除当天的休假
• 日历下方改为推荐连休列表 — 可直接登记
• 分享年假状况时，会先让你预览要发送的图片
• 新增使用指南 — 可随时从"设置 > 帮助"重新打开
• 可在"设置 > 支持"中直接发送反馈
• 整理了英文、日文、中文界面中混入的韩文文案
• 已彻底移除 Google Analytics。用于改进应用的匿名统计仅保存在开发者本人的 iCloud 中
```

---

### 변경 사항 (내부 체인지로그)

**수정 — 화면마다 다르던 "사용 완료" 일수 (핵심)**
- 같은 계산이 홈·내역·설정·휴가 등록·추천·캘린더 6~7곳에 복사돼 있었고 필터가 조금씩 달랐다
  (홈은 연차 차감분만, 내역은 출장·병가까지 합산, 일부는 회계연도 범위조차 안 봄)
- `LeaveUsageCalculator` 신설 — 회계연도 소속·"사용 완료"(지난 예정 포함)·취소 제외·
  연차 차감분 vs 전체 유형 합계·보너스 연도 스코프를 한 곳에 정의하고 모든 화면이 이것만 읽는다
- 보너스 잔여는 **만료분 제외**로 통일(`expiredBonus`로 차이를 드러냄), 보너스 포함 토글도 같은 값 사용
- 테스트 헬퍼가 화면 공식을 복제하던 문제도 정리 — 이제 테스트가 실제 계산기를 호출한다

**신규 — 사용법 튜토리얼 · 도움말**
- `TutorialView` 6장(등록 → 사진 가져오기 → 추천 → 보너스 → 공유 → 위젯). 온보딩 직후 1회 자동, 이후 설정에서
- 설정 > 도움말: 사용법 다시 보기 / 처음 안내 다시 보기 / 기능 팁 다시 보기
- 온보딩 재실행 시 프로필이 복제되던 버그 수정(기존 프로필 갱신)
- TipKit 팁 4종 추가(추천 연휴·현황 공유·보너스 연차·사용 내역), 총 8종

**신규 — 사용 통계·피드백·안정성 허브 (LeeoKit 3.2.0)**
- Firebase 제거로 비어 있던 분석 경로를 개발자 본인 CloudKit(FeedbackHub)으로 대체. 새 외부 SDK 0개
- 사용자: 설정 > 지원에서 피드백 보내기 · 만족도 프롬프트(아쉬우면 피드백으로 유도)
- 개발자(버전 7탭 마스터 모드): 사용 통계 · 접수된 피드백 · 안정성(MetricKit)
- 원격 킬스위치(GoldweekFlag)로 수집을 심사 없이 중단 가능

**UI**
- 다가오는 휴가에 공휴일 병합(연휴는 한 줄로 묶고 최대 3개) + 설정 토글
- 캘린더: "나의 연차 일정" → 추천 휴가 일정(가까운 3개, 추천 화면과 같은 카드·같은 무료 한도)
- 캘린더: 날짜 탭 → 그 날 휴가 수정·삭제 (내역 화면과 같은 편집 시트·같은 삭제 규칙)
- 연차 현황 공유: 미리보기 후 공유 (렌더를 시트 안으로 옮겨 실패해도 버튼이 죽지 않음)
- 휴가 페이스: "올해 진행"을 회색 막대로 채움 / 쉬어가는 흐름의 연결선을 끊기지 않는 트랙으로 재구성
- 보너스 표기를 "1.5/3일" 분수 하나로 (문장형은 VoiceOver 낭독용으로 유지)

**타이포그래피 · 다국어**
- 화면 코드 339줄의 caption/caption2/footnote/subheadline·소형 고정 크기를 .body 이상으로 상향
  (예외: 안정성 화면의 콜스택 원문 — 붙여넣기용 로그)
- 커진 글자로 깨진 레이아웃 보정: 캘린더 범례 흐름 배치, 쉬어가는 흐름 칸 폭, 월별 미리보기 축소 허용
- 위젯 문자열 21개 미번역 → en/ja/zh-Hans 채움 ("연차 현황"만 한국어로 남던 원인)
- 공유·가족 화면의 enum rawValue 직접 표시 3곳, 날짜 18곳(기기 언어 → 앱 언어), 기본 이름("사용자") 정리
- 설정 > 지원 섹션을 직접 그려 앱 언어를 따르게 + 언어 변경 시 `AppleLanguages` 동기화
- 영어 "1 days" 복수형 오류 정리(`Strings.dayCount`)

**안정성 · 개인정보**
- Firebase / Google Analytics 완전 제거 (SDK·plist·호출부 전부)
- 총 연차 등 프로필 편집을 변경 즉시 저장 (자동 저장은 시점을 보장하지 않는다)
- 개인정보 처리방침 4개 언어 갱신 — 익명 통계·크래시 진단 수집을 정확히 고지

---

### 빌드 체크리스트
- [x] MARKETING_VERSION 2.1.1 → 2.1.2 (모든 타깃: Goldweek, widgetExtension, GoldweekTests)
- [x] CURRENT_PROJECT_VERSION 1 (빌드 산출물 Info.plist에서 앱·위젯 모두 2.1.2 (1) 확인)
- [x] 단위 테스트 그린
- [ ] 아카이브 빌드 확인
- [ ] **CloudKit 배포 선행** — Developer 포털에 `iCloud.com.Ysoup.FeedbackHub` 컨테이너 추가 +
      Dashboard 스키마(Feedback·UsageSnapshot·UsageEvent·CrashReport) Production 배포.
      ⚠️ 이걸 안 하면 "피드백 보내기"가 전송에 실패한다 — 릴리즈 노트에 적은 기능이므로 **출시 전 필수**
- [ ] App Store Connect 개인정보 설문 갱신 (Product Interaction / Contact Info / Crash Data)

---

## v2.1.1 — 휴가 종류 × 길이 조합, 보너스 사용 현황

> 이전 출시: v2.1.0
> 핵심: 어떤 휴가든(특별휴가·자녀돌봄·병가 등) 종일/반차/반반차를 골라 쓸 수 있고, 사진으로 가져온 "자녀돌봄(1/2)" 같은 반일 휴가도 0.5일로 정확히 잡힙니다. 보너스 연차 사용 현황도 홈에서 한눈에 볼 수 있습니다.

---

### App Store "이번 버전의 새로운 기능" (붙여넣기용)

#### 🇰🇷 한국어
```
휴가 종류와 길이를 따로 고를 수 있어요.

• 이제 특별휴가·자녀돌봄·병가 등 어떤 휴가든 종일/반차/반반차를 조합해 등록할 수 있어요
• 사진 가져오기: "자녀돌봄(1/2)"처럼 반일 표기가 있는 휴가를 0.5일로 정확히 인식해요
• 예전에 하루로 잘못 저장된 반일 휴가는 앱을 열면 자동으로 바로잡아 드려요
• 보너스 연차에서 차감되는 반차·반반차도 그대로 반영돼요
• 홈 현황에 보너스 연차 사용 현황(부여 대비 사용량·진행률·잔여)을 추가했어요

소소한 버그 수정과 안정성 개선도 함께 했습니다.
```

#### 🇺🇸 English
```
Pick leave type and length independently.

• Any leave — special, child-care, sick, and more — can now be logged as full, half, or quarter day
• Photo import now reads half-day notations like "child-care (1/2)" correctly as 0.5 days
• Half-day leaves that were previously saved as a full day are fixed automatically when you open the app
• Half/quarter days deducted from bonus leave are reflected accurately too
• The home summary now shows bonus-leave usage — used vs. granted, a progress bar, and days remaining

Plus minor bug fixes and stability improvements.
```

#### 🇯🇵 日本語
```
休暇の種類と長さを別々に選べます。

• 特別休暇・子の看護・病気など、どの休暇でも終日/半休/四半休を組み合わせて登録できます
• 写真から取り込み：「子の看護(1/2)」のような半日表記を0.5日として正しく認識します
• 以前に1日として保存された半日休暇は、アプリを開くと自動で修正されます
• ボーナス休暇から差し引く半休・四半休も正確に反映されます
• ホームのサマリーにボーナス休暇の使用状況(付与に対する使用分・進捗・残日数)を追加しました

軽微な不具合修正と安定性の改善も行いました。
```

#### 🇨🇳 中文(简体)
```
休假类型和长度可分开选择。

• 现在特别休假、子女照护、病假等任意休假都能按全天/半天/四分之一天登记
• 照片导入:能将“子女照护(1/2)”这类半天标记正确识别为0.5天
• 之前被误存为一整天的半天休假,打开应用时会自动修正
• 从奖励年假中扣除的半天/四分之一天也会准确反映
• 首页概览新增奖励年假使用情况(已用与已授予、进度条、剩余天数)

同时修复了一些小问题并提升了稳定性。
```

---

### 변경 사항 (내부 체인지로그)

**신규 — 휴가 = 카테고리 × 길이 (직교 구조)**
- LeaveLength(종일 1.0 / 반차 0.5 / 반반차 0.25) 축을 카테고리와 분리 → "특별휴가 반차", "자녀돌봄 반차" 등 n×n 조합 지원
- LeaveRecord에 length(lengthRaw) 추가, effectiveLeaveDays·deductsFromAnnualLeave를 길이·카테고리 기반으로 재정의
- 레거시 반차/반반차 기록은 연차+길이로 자동 흡수 (스키마는 옵셔널 추가라 마이그레이션 불필요)
- LeaveType.categories로 입력 UI용 순수 카테고리 노출

**개선 — 사진 가져오기(OCR) 길이 인식**
- 유형명의 "(1/2)"·"½"·"(1/4)" 분수 표기를 길이로 추론 (자녀돌봄(1/2)=0.5일). 날짜 슬래시 오인 방지(괄호 요구)
- DetectedLeaveCandidate.suggestedLength → LeaveRecord.length 파이프라인 연결

**마이그레이션 — 기존 데이터 보정**
- LeaveRecordMaintenance.backfillLengths: 파서 개선 이전에 1일로 저장된 단일일 기록을 note의 분수 표기로 반차/반반차 보정
- 홈/사용내역 진입 시 길이 보정 → 보너스 usedDays 재산정 순으로 자동 실행

**개선 — 보너스 연차 사용 현황 노출**
- 홈 현황 카드: 부여받은 보너스가 있으면 항상 "N일 중 M일 사용" + 사용 진행률 바 + 잔여 강조 표시 (기존엔 보너스 미포함 설정일 때 잔여만 표시)
- 설정 보너스 연차 행: 사용량 > 0이면 "N일 중 M일 사용" 캡션 추가, VoiceOver 라벨에도 포함
- 휴가 사용 내역 기준으로 보너스 usedDays 재산정 + 미연결 특별휴가 자동 연결(BonusLeaveReconciler)
- 신규 문자열 bonusUsedOfGranted (4개 언어)

**UI**
- AddLeave/편집 화면을 카테고리 + 길이 2축 선택으로 재구성
- 사용 내역 행에 길이 배지(반차/반반차) 표시
- 신규 문자열(길이 이름/섹션 헤더) 4개 언어

**테스트**
- 파서 분수 인식 3개 + 길이 마이그레이션 3개 추가, 전체 그린

---

### 빌드 체크리스트
- [x] MARKETING_VERSION 2.1.0 → 2.1.1 (모든 타깃: Goldweek, widgetExtension)
- [ ] CURRENT_PROJECT_VERSION(빌드 번호) 증가
- [x] 단위 테스트 그린 (LeaveTableParserTests 등)
- [ ] 아카이브 빌드 확인

---

## v2.1.0 — 특별휴가와 보너스 연차 자동 연결

> 이전 출시: v2.0.9
> 핵심: 사진으로 가져온 자녀돌봄·포상휴가 같은 특별휴가가 이제 보너스 연차에서 자동으로 차감됩니다.

---

### App Store "이번 버전의 새로운 기능" (붙여넣기용)

#### 🇰🇷 한국어
```
특별휴가도 이제 잔여일수가 정확하게 관리돼요.

• 사진 가져오기: 자녀돌봄, 포상휴가 같은 특별휴가를 등록해 둔 보너스 연차와 자동으로 연결해 잔여일수에서 차감해요
• 가져오기 화면에서 항목별로 어떤 보너스에서 차감할지 직접 선택하거나 해제할 수 있어요
• 보너스 잔여일수가 부족하면 등록 전에 미리 알려드려요

소소한 버그 수정과 안정성 개선도 함께 했습니다.
```

#### 🇺🇸 English
```
Special leave now counts against your balance, correctly.

• Photo import: special leave like child-care or reward days is now automatically matched to your registered bonus leave and deducted from its balance
• Choose (or clear) which bonus each imported item deducts from, right on the import screen
• Get warned before importing if a bonus doesn't have enough days left

Plus minor bug fixes and stability improvements.
```

#### 🇯🇵 日本語
```
特別休暇の残日数も正確に管理できるようになりました。

• 写真から取り込み：子の看護休暇や報奨休暇などの特別休暇を、登録済みのボーナス休暇と自動でひも付けて残日数から差し引きます
• 取り込み画面で項目ごとに、どのボーナスから差し引くかを選択・解除できます
• ボーナスの残日数が足りない場合は登録前にお知らせします

軽微な不具合修正と安定性の改善も行いました。
```

#### 🇨🇳 中文(简体)
```
特别休假的剩余天数现在也能准确管理了。

• 照片导入:子女照护、奖励休假等特别休假会自动匹配你登记的奖励年假,并从其余额中扣除
• 在导入界面可为每个条目选择或取消从哪个奖励年假扣除
• 奖励年假剩余天数不足时,会在登记前提醒你

同时修复了一些小问题并提升了稳定性。
```

---

### 변경 사항 (내부 체인지로그)

**개선 — 사진 가져오기(OCR) × 보너스 연차 연결**
- 자동 매칭: 연차 차감 없는 후보(자녀돌봄, 포상, 리프레시 등)의 유형명을 BonusLeaveType으로 추론해, 유형이 맞고 잔여가 충분한 미사용·미만료 보너스에 자동 연결 (잔여 누적 추적으로 과할당 방지)
- 확인 화면: 후보별 "보너스에서 차감" 메뉴 추가 — 자동 매칭 결과 표시, 행별 변경/해제 가능
- 저장 시 bonusLeaveId 연결 + usedDays 차감, 잔여 부족 시 등록 차단, 저장 실패 시 롤백
- 기록 삭제 시 usedDays 복원은 기존 로직(bonusLeaveId 기반) 그대로 동작
- 신규 문자열 3개 x 4개 언어 (차감 안 함 / 차감 요약 / 잔여 부족)
- 스키마 변경 없음 — 마이그레이션 불필요

---

### 빌드 체크리스트
- [x] MARKETING_VERSION 2.0.9 → 2.1.0 (모든 타깃: Goldweek, widgetExtension)
- [ ] CURRENT_PROJECT_VERSION(빌드 번호) 증가
- [x] 단위 테스트 그린 (LeaveTableParserTests, LeaveCalculationTests, BurnoutEngineTests)
- [ ] 아카이브 빌드 확인

---

## v2.0.7 — 휴식 리듬 & 번아웃 알림

> 이전 출시: v2.0.6
> 핵심: "언제 쉴지"를 내 휴식 이력으로 알려주는 Rest Radar 추가.

---

### App Store "이번 버전의 새로운 기능" (붙여넣기용)

#### 🇰🇷 한국어
```
이제 Goldweek가 "언제 쉬어야 할지"까지 알려드려요.

• 휴식 리듬: 내 휴가 이력으로 평소 쉬는 주기를 분석해 홈에서 한눈에
• 번아웃 주의 구간: 너무 오래 못 쉬면 캘린더에 주의 구간을 표시
• 휴식 알림: 쉴 때가 되면 가까운 저비용 연휴와 함께 살짝 알려드려요
• 피로 체크인: 가끔 한 번의 답으로 추천이 더 정확해져요
• 설정에서 휴식 알림을 켜고 끌 수 있어요

소소한 버그 수정과 안정성 개선도 함께 했습니다.
```

#### 🇺🇸 English
```
Goldweek now tells you *when* to rest, not just how to plan it.

• Rest rhythm: learns your usual break cycle from your leave history
• Burnout watch: flags a caution window on the calendar when it's been too long
• Rest reminders: a gentle nudge when you're due, paired with a nearby low-cost getaway
• Quick check-in: one tap now and then makes suggestions more accurate
• Toggle rest reminders on/off in Settings

Plus minor bug fixes and stability improvements.
```

#### 🇯🇵 日本語
```
Goldweekが「いつ休むべきか」までお知らせします。

• 休息リズム：休暇履歴からあなたの休む周期を分析しホームに表示
• バーンアウト注意：長く休めていないとカレンダーに注意ゾーンを表示
• 休息リマインダー：休み時に、近くの低コストな連休とともにそっとお知らせ
• 疲労チェックイン：たまの回答で提案がより正確に
• 設定で休息リマインダーのオン/オフが可能

軽微な不具合修正と安定性の改善も行いました。
```

#### 🇨🇳 中文(简体)
```
Goldweek 现在还会告诉你"何时该休息"。

• 休息节奏：根据你的休假记录分析平时的休息周期,在首页一目了然
• 倦怠提醒区:太久没休息时,会在日历上标出注意区间
• 休息提醒:该休息时,结合就近的低成本假期轻轻提醒你
• 疲劳打卡:偶尔一次回答,让建议更准确
• 可在设置中开关休息提醒

同时修复了一些小问题并提升了稳定性。
```

---

### 변경 사항 (내부 체인지로그)

**새 기능 — Rest Radar (번아웃/휴식)**
- 번아웃 엔진: 휴식 이력으로 개인 휴식 주기·회복 상태·번아웃 예측일 계산 (단위 테스트 11종)
- 홈 카드: 휴가 페이스 + 휴식 텀 타임라인으로 휴식 리듬 표시
- 캘린더: 번아웃 "주의 구간"을 주황 점선 링 + 범례로 표시
- 휴식 알림: 쉴 때가 되면 가까운 저비용 연휴를 함께 제안하는 로컬 알림
  (포그라운드 표시, 탭/스누즈 액션, 7일 쿨다운, 4개국어)
- 단일문항 피로 체크인(SIB) 모달 — 추천/알림 정확도 보정
- 설정: 휴식 레이더 on/off 토글

**측정**
- 추천 노출 이벤트(recommendation_shown) 추가 — 채택률 측정 기반
- 휴식 알림 노출/탭/스누즈 이벤트 추가

**개선/수정**
- 피로 체크인 하프 모달 여백·심볼 잘림 정리

---

### 빌드 체크리스트
- [x] MARKETING_VERSION 2.0.6 → 2.0.7 (모든 타깃: Goldweek, widgetExtension)
- [ ] CURRENT_PROJECT_VERSION(빌드 번호) 증가
- [ ] 알림 권한: 로컬 알림이라 Info.plist 사용 설명 불필요 (provisional)
- [ ] 단위 테스트 그린 / 아카이브 빌드 확인
