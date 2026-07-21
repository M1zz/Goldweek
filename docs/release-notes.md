# Release Notes

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
