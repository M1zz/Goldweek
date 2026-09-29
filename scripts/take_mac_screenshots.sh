#!/bin/bash
# Goldweek Mac App Store 스크린샷 자동 촬영 — 언어별 1장 (캘린더 + 현황 대시보드)
#
# Mac Catalyst Debug 빌드를 스크린샷 모드(데모 데이터)로 띄우고 창을 16:10 으로 맞춘 뒤 캡처해
# 2560×1600(Mac App Store 허용 규격)으로 저장한다.
# 결과: docs/screenshots-mac/<언어>.png
#
# ⚠️ 스크린샷 모드는 이 Mac 의 Goldweek 데이터(샌드박스 컨테이너)를 데모 데이터로 덮어쓴다.
# ⚠️ 창 크기 조절에 손쉬운 사용(Accessibility) 권한이 필요하다 — 터미널에 권한을 준다.
#
# 사용법: scripts/take_mac_screenshots.sh [언어...]   (기본: en ko ja zh de fr)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED="${DERIVED:-$ROOT/build/mac-screenshots-dd}"
OUT="$ROOT/docs/screenshots-mac"
LANGS=("$@"); [ ${#LANGS[@]} -eq 0 ] && LANGS=(en ko ja zh de fr)

apple_lang() { case "$1" in zh) echo "zh-Hans" ;; *) echo "$1" ;; esac; }

echo "▶ 빌드 (Mac Catalyst, Debug)"
xcodebuild -project "$ROOT/Goldweek.xcodeproj" -scheme Goldweek -configuration Debug \
  -destination "platform=macOS,variant=Mac Catalyst" -derivedDataPath "$DERIVED" \
  -allowProvisioningUpdates build -quiet
APP="$DERIVED/Build/Products/Debug-maccatalyst/Goldweek.app"

# 창 ID 찾기 (CoreGraphics)
WID_SWIFT="$(mktemp -t goldweek-wid).swift"
cat > "$WID_SWIFT" <<'EOF'
import CoreGraphics
let pid = Int(CommandLine.arguments[1])!
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as! [[String: Any]]
for w in list where (w[kCGWindowOwnerPID as String] as? Int) == pid && (w[kCGWindowLayer as String] as? Int) == 0 {
    print(w[kCGWindowNumber as String]!); break
}
EOF

mkdir -p "$OUT"
for lang in "${LANGS[@]}"; do
  sys=$(apple_lang "$lang")
  pkill -f "Debug-maccatalyst/Goldweek.app" 2>/dev/null || true
  sleep 1
  "$APP/Contents/MacOS/Goldweek" -screenshotMode YES -isPro YES \
    -appLanguage "$lang" -AppleLanguages "($sys)" -AppleLocale "$sys" >/dev/null 2>&1 &
  pid=$!
  sleep 6
  # 화면이 작으면 창이 요청보다 작아진다 — 실제 폭을 읽어 16:10 으로 맞춘 뒤 2560×1600 으로 저장
  se="tell application \"System Events\" to tell (first process whose unix id is $pid)"
  osascript -e "$se to set position of window 1 to {20, 40}" -e "$se to set size of window 1 to {1440, 900}" >/dev/null
  w=$(osascript -e "$se to get item 1 of (get size of window 1)")
  osascript -e "$se to set size of window 1 to {$w, $(( w * 10 / 16 ))}" >/dev/null
  sleep 3
  wid=$(swift "$WID_SWIFT" "$pid")
  screencapture -x -o -l"$wid" "$OUT/$lang.png"
  sips -z 1600 2560 "$OUT/$lang.png" >/dev/null
  echo "  ✓ $OUT/$lang.png ($(sips -g pixelWidth -g pixelHeight "$OUT/$lang.png" | awk '/pixel/ {printf "%s ", $2}'))"
  kill "$pid" 2>/dev/null || true
done
rm -f "$WID_SWIFT"
echo "완료 → $OUT"
