#!/bin/bash
# App Review 가 요구하는 화면 녹화를 **이 맥에서** 찍는다(Mac 앱 심사용).
# 앱을 켜는 순간부터: 달력·연차 현황 → 날짜 골라 휴가 등록 → 추천 일정 → 설정 ▸ 업그레이드(요금제 화면).
#   → ~/Desktop/골드위크-심사/Goldweek-macOS-review.mp4 (창 영역만, 약 1분 10초)
#
# 사용법:  scripts/record_mac_review.sh        (도는 2분 동안 마우스·키보드를 건드리지 말 것)
#
# ⚠️ 클릭을 직접 보낸다(창 기준 좌표, 창 1024×768pt 기준). 화면 배치를 바꾸면 아래 좌표도 고칠 것.
#    날짜 좌표는 찍는 달의 달력 모양에 따라 달라진다(2026-11 기준: 24일 → 25일, 다음 달 두 번 → 2027-01 추천).
# ⚠️ 터미널에 화면 기록·손쉬운 사용 권한이 있어야 한다.
# ⚠️ 데모 모드(-screenshotMode)는 이 맥의 골드위크 데이터를 데모 데이터로 덮어쓴다(take_mac_screenshots.sh 와 같다).
# `-isPro NO`: 무료 사용자 화면 — 가격과 구매 버튼이 보인다.
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"; cd "$ROOT"
W="$ROOT/build/review"; mkdir -p "$W"
DD="$ROOT/build/mac-screenshots-dd"
APP="$DD/Build/Products/Debug-maccatalyst/Goldweek.app"
OUT_DIR="$HOME/Desktop/골드위크-심사"; OUT="$OUT_DIR/Goldweek-macOS-review.mp4"; mkdir -p "$OUT_DIR"
LEN=78          # 녹화 길이(초)
HEAD="${HEAD:-4.0}"   # 앞에서 잘라 낼 길이 — 창이 뜨기 전에는 뒤에 있던 다른 창이 찍힌다

echo "🔨 DEBUG Catalyst 빌드"
xcodebuild -project Goldweek.xcodeproj -scheme Goldweek -configuration Debug \
  -destination 'platform=macOS,variant=Mac Catalyst' -derivedDataPath "$DD" -allowProvisioningUpdates build -quiet 2>&1 \
  | grep -E ' error|BUILD FAILED' || true
[[ -d "$APP" ]] || { echo "❌ 빌드 실패"; exit 1; }
for t in click scroll front trim; do swiftc -O "scripts/app_review/$t.swift" -o "$W/$t" 2>/dev/null; done

launch() {
  pkill -f Debug-maccatalyst/Goldweek.app 2>/dev/null || true; sleep 1
  open -n "$APP" --args -screenshotMode YES -screenshotTab 0 -isPro NO -appLanguage en -AppleLanguages "(en)" -AppleLocale en_US
}
# 맨 앞 창이 이 앱일 때만 누른다 — 아니면 다른 앱을 누르게 된다.
front() {
  local f; f="$("$W/front")"
  if [[ "$f" != Goldweek* ]]; then open "$APP"; sleep 0.8; f="$("$W/front")"; fi
  [[ "$f" == Goldweek* ]] || { echo "❌ 앱이 맨 앞이 아니다: $f"; exit 1; }
  IFS=, read -r X Y _ _ <<<"${f#Goldweek }"
}
c()  { front; "$W/click"  $((X+$1)) $((Y+$2)) ${3:-} >/dev/null; }
sc() { front; "$W/scroll" $((X+$1)) $((Y+$2)) "$3"; }

# 창 자리를 먼저 정한다(맥은 창 자리를 기억한다). 화면 가장자리의 떠 있는 창·알림을 피한 자리.
launch; sleep 6
PID="$(pgrep -f Debug-maccatalyst/Goldweek.app | head -1)"
osascript -e "tell application \"System Events\" to tell (first process whose unix id is $PID) to set position of window 1 to {140, 120}" >/dev/null
sleep 1; front; RECT="$("$W/front")"; RECT="${RECT#Goldweek }"
pkill -f Debug-maccatalyst/Goldweek.app; sleep 1.5

echo "🎬 녹화 시작 — 손을 떼고 기다릴 것 ($RECT)"
rm -f "$W/raw.mov"
screencapture -x -v -V "$LEN" -R "$RECT" "$W/raw.mov" & SP=$!
sleep 2
launch; sleep 8               # 달력 · 연차 현황 · 다가오는 휴가
c 512 485; sleep 2.5          # (감사 인사가 뜨면) 확인 — 안 뜨면 20일 언저리를 누를 뿐이다
c 262 343; sleep 2.5          # 24일
c 358 560; sleep 3.5          # 이 날짜에 휴가 추가 → 등록 시트
c 512 473; sleep 3            # 25일까지
c 594 614; sleep 4            # 저장 → 6일 연휴
c 512 425; sleep 3.5          # 확인 — 남은 연차가 줄었다
c 685 93;  sleep 2            # 다음 달
c 685 93;  sleep 2.5          # 2027년 1월 — 추천 일정
sc 360 450 -420; sleep 5      # 추천 카드
sc 360 450 -340; sleep 4      # 다음 추천
c 998 48;  sleep 3.5          # 설정
c 512 270; sleep 5            # 업그레이드 → 요금제 화면(Pro)
c 413 196; sleep 4            # Plus
c 586 196; sleep 3            # Pro
sc 512 450 -260; sleep 3.5    # 월간 · 연간 · 평생
sc 512 450 -400; sleep 4      # 구매 복원 · 약관 · 개인정보
wait $SP; pkill -f Debug-maccatalyst/Goldweek.app || true

"$W/trim" "$W/raw.mov" "$OUT" "$HEAD" "$LEN"
echo "✅ $OUT — 올리기 전에 처음 몇 초에 다른 창이 비치지 않는지 눈으로 확인할 것"
