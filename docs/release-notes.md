# Release Notes

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
