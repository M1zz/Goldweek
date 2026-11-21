#!/bin/bash
# Goldweek Mac App Store 스크린샷 자동 촬영 — 언어별 2장 (캘린더 · 추천, 둘 다 현황 대시보드와 두 칸)
#
# Mac Catalyst Debug 빌드를 스크린샷 모드(데모 데이터)로 띄우고 창을 16:10 으로 맞춘 뒤 캡처해
# 2560×1600(Mac App Store 허용 규격)으로 저장한다.
# 결과: 원본 docs/screenshots/raw-mac/<로케일>/ · 제출본 docs/screenshots/marketing/<로케일>/2N-mac-*.png
#       (DeployBar 는 픽셀 크기로 Mac 자리를 알아본다)
#
# ⚠️ 스크린샷 모드는 이 Mac 의 Goldweek 데이터(샌드박스 컨테이너)를 데모 데이터로 덮어쓴다.
# ⚠️ 창 크기 조절에 손쉬운 사용(Accessibility) 권한이 필요하다 — 터미널에 권한을 준다.
#
# 사용법: scripts/take_mac_screenshots.sh [언어...]   (기본: 스토어 25개 언어)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED="${DERIVED:-$ROOT/build/mac-screenshots-dd}"
RAW="$ROOT/docs/screenshots/raw-mac"
MKT="$ROOT/docs/screenshots/marketing"
LANGS=("$@"); [ ${#LANGS[@]} -eq 0 ] && LANGS=(ko en en-GB ja zh de fr es it pt zh-Hant ru id nl sv nb da fi pl cs el tr th vi ar)
# 탭:이름:스크롤 — take_screenshots.sh 의 iPad 두 칸과 같은 화면
SHOTS=("1:calendar:nextYear" "1:recommend:recommendations")

# 언어 코드 규칙은 take_screenshots.sh 와 같다
apple_lang() { case "$1" in zh) echo "zh-Hans" ;; pt) echo "pt-BR" ;; *) echo "$1" ;; esac; }
app_lang()   { case "$1" in en-GB) echo "en" ;; *) echo "$1" ;; esac; }
apple_locale() {
  case "$1" in
    ko) echo "ko_KR" ;; en) echo "en_US" ;; en-GB) echo "en_GB" ;; ja) echo "ja_JP" ;; zh) echo "zh_CN" ;;
    de) echo "de_DE" ;; fr) echo "fr_FR" ;; es) echo "es_ES" ;; it) echo "it_IT" ;;
    pt) echo "pt_BR" ;; zh-Hant) echo "zh_TW" ;; ru) echo "ru_RU" ;; id) echo "id_ID" ;;
    nl) echo "nl_NL" ;; sv) echo "sv_SE" ;; nb) echo "nb_NO" ;; da) echo "da_DK" ;; fi) echo "fi_FI" ;;
    pl) echo "pl_PL" ;; cs) echo "cs_CZ" ;; el) echo "el_GR" ;; tr) echo "tr_TR" ;;
    th) echo "th_TH" ;; vi) echo "vi_VN" ;; ar) echo "ar_SA" ;; *) echo "$1" ;;
  esac
}

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

for lang in "${LANGS[@]}"; do
  dir=$(apple_lang "$lang"); sys=$dir; loc=$(apple_locale "$lang")
  mkdir -p "$RAW/$dir" "$MKT/$dir"
  i=1
  for shot in "${SHOTS[@]}"; do
    IFS=: read -r tab name scroll <<< "$shot"
    pkill -f "Debug-maccatalyst/Goldweek.app" 2>/dev/null || true
    sleep 1
    "$APP/Contents/MacOS/Goldweek" -screenshotMode YES -screenshotTab "$tab" -screenshotScroll "$scroll" -isPro YES \
      -appLanguage "$(app_lang "$lang")" -AppleLanguages "($sys)" -AppleLocale "$loc" >/dev/null 2>&1 &
    pid=$!
    sleep "${WAIT:-7}"
    # 화면이 작으면 창이 요청보다 작아진다 — 실제 폭을 읽어 16:10 으로 맞춘 뒤 2560×1600 으로 저장
    se="tell application \"System Events\" to tell (first process whose unix id is $pid)"
    osascript -e "$se to set position of window 1 to {20, 40}" -e "$se to set size of window 1 to {1440, 900}" >/dev/null
    w=$(osascript -e "$se to get item 1 of (get size of window 1)")
    osascript -e "$se to set size of window 1 to {$w, $(( w * 10 / 16 ))}" >/dev/null
    sleep 3
    wid=$(swift "$WID_SWIFT" "$pid")
    file="$RAW/$dir/0$i-$name.png"
    screencapture -x -o -l"$wid" "$file"
    sips -z 1600 2560 "$file" >/dev/null
    cp "$file" "$MKT/$dir/2$i-mac-$name.png"
    echo "  ✓ $dir/0$i-$name.png"
    kill "$pid" 2>/dev/null || true
    i=$((i + 1))
  done
done
rm -f "$WID_SWIFT"
echo "완료 → $MKT/<로케일>/2N-mac-*.png"
