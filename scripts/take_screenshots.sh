#!/bin/bash
# Goldweek App Store 스크린샷 자동 촬영 — 언어 × 탭
#
# DEBUG 빌드의 스크린샷 모드(Goldweek/Utilities/ScreenshotMode.swift)로 언어별 데모 데이터를 채운 뒤
# 탭마다 시뮬레이터 화면을 캡처한다. 결과: docs/screenshots/raw/<로케일>/<번호>-<화면>.png (원본 — 스토어에 안 올라감)
# 제출본은 scripts/make_marketing_screenshots.py 가 이 원본으로 docs/screenshots/marketing/<로케일>/ 에 만든다.
#
# 사용법: scripts/take_screenshots.sh [언어...]   (기본: en ko ja zh de fr es it pt zh-Hant ru id)
#         IPAD=1 scripts/take_screenshots.sh …   iPad 13" (2064×2752) — 원본은 raw/ipad/<로케일>/

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [ -n "${IPAD:-}" ]; then
  DEVICE="${DEVICE:-iPad Pro 13-inch (M5)}"   # 13" — App Store iPad 필수 규격 (2064×2752)
else
  DEVICE="${DEVICE:-iPhone 18 Pro Max}"   # 6.9" — App Store 필수 규격 (1320×2868)
fi
BUNDLE_ID="com.Ysoup.LeaveWise"
DERIVED="${DERIVED:-$ROOT/build/screenshots-dd}"
OUT="${OUT:-$ROOT/docs/screenshots/raw${IPAD:+/ipad}}"
LANGS=("$@"); [ ${#LANGS[@]} -eq 0 ] && LANGS=(en ko ja zh de fr es it pt zh-Hant ru id)

# 탭 번호:이름[:스크롤 위치] (MainTabView 의 tag, ScreenshotMode.scrollTarget)
SHOTS=("0:home" "1:recommend:recommendations" "1:calendar:nextYear" "3:settings")
# iPad 은 탭 없이 "캘린더 + 현황" 두 칸 — 홈과 캘린더가 한 화면이고, 설정은 시트로 연다
[ -n "${IPAD:-}" ] && SHOTS=("1:calendar:nextYear" "1:recommend:recommendations" "3:settings")

apple_lang() {   # 앱 언어 코드 → 시스템 언어 코드
  case "$1" in zh) echo "zh-Hans" ;; pt) echo "pt-BR" ;; *) echo "$1" ;; esac
}

apple_locale() {   # 앱 언어 코드 → 지역 (국가 판별이 지역을 보므로 데모 국가와 맞춘다)
  case "$1" in
    ko) echo "ko_KR" ;; en) echo "en_US" ;; ja) echo "ja_JP" ;; zh) echo "zh_CN" ;;
    de) echo "de_DE" ;; fr) echo "fr_FR" ;; es) echo "es_ES" ;; it) echo "it_IT" ;;
    pt) echo "pt_BR" ;; zh-Hant) echo "zh_TW" ;; ru) echo "ru_RU" ;; id) echo "id_ID" ;; *) echo "$1" ;;
  esac
}

out_dir() {   # 저장 폴더 = App Store 로케일 이름
  case "$1" in zh) echo "zh-Hans" ;; pt) echo "pt-BR" ;; *) echo "$1" ;; esac
}

echo "▶ 시뮬레이터 준비: $DEVICE"
xcrun simctl boot "$DEVICE" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE" -b >/dev/null
xcrun simctl status_bar "$DEVICE" override --time "9:41" --batteryState charged --batteryLevel 100 \
  --cellularMode active --cellularBars 4 --wifiBars 3 --dataNetwork wifi

DEST="platform=iOS Simulator,name=$DEVICE"
[[ "$DEVICE" =~ ^[0-9A-F-]{36}$ ]] && DEST="platform=iOS Simulator,id=$DEVICE"

# iPad 상태 막대엔 날짜가 나온다 — 그 언어로 보이게 시뮬레이터 언어를 바꾸고 다시 켠다
set_system_language() {
  [ -n "${IPAD:-}" ] || return 0
  xcrun simctl spawn "$DEVICE" defaults write "Apple Global Domain" AppleLanguages -array "$1"
  xcrun simctl spawn "$DEVICE" defaults write "Apple Global Domain" AppleLocale -string "$2"
  xcrun simctl shutdown "$DEVICE"
  xcrun simctl boot "$DEVICE"
  xcrun simctl bootstatus "$DEVICE" -b >/dev/null
  xcrun simctl status_bar "$DEVICE" override --time "9:41" --batteryState charged --batteryLevel 100 \
    --cellularMode active --cellularBars 4 --wifiBars 3 --dataNetwork wifi
  xcrun simctl launch "$DEVICE" "$BUNDLE_ID" -screenshotMode YES >/dev/null
  sleep 8
}

echo "▶ 빌드 (Debug)"
xcodebuild -project "$ROOT/Goldweek.xcodeproj" -scheme Goldweek -configuration Debug \
  -destination "$DEST" -derivedDataPath "$DERIVED" build -quiet
APP="$DERIVED/Build/Products/Debug-iphonesimulator/Goldweek.app"
xcrun simctl install "$DEVICE" "$APP"

# 첫 실행은 초기화가 길어 빈 화면이 찍힌다 — 한 번 띄워 두고 시작
xcrun simctl launch "$DEVICE" "$BUNDLE_ID" -screenshotMode YES >/dev/null
sleep 8

for lang in "${LANGS[@]}"; do
  dir="$OUT/$(out_dir "$lang")"
  mkdir -p "$dir"
  sys=$(apple_lang "$lang")
  loc=$(apple_locale "$lang")
  set_system_language "$sys" "$loc"
  i=1
  for shot in "${SHOTS[@]}"; do
    IFS=: read -r tab name scroll <<< "$shot"
    xcrun simctl terminate "$DEVICE" "$BUNDLE_ID" 2>/dev/null || true
    xcrun simctl launch "$DEVICE" "$BUNDLE_ID" \
      -screenshotMode YES -screenshotTab "$tab" -screenshotScroll "${scroll:-none}" -isPro YES \
      -appLanguage "$lang" -AppleLanguages "($sys)" -AppleLocale "$loc" >/dev/null
    sleep "${WAIT:-6}"
    file="$dir/0$i-$name.png"
    # 레포 경로에 한글이 있으면 pwd 가 자모 분리형(NFD)으로 돌려주는데, simctl 은 그 경로에 쓰지 못한다
    # → 임시 파일로 찍고 옮긴다
    tmp="$(mktemp -t goldweek-shot).png"
    xcrun simctl io "$DEVICE" screenshot "$tmp" >/dev/null 2>&1
    mv "$tmp" "$file"
    echo "  ✓ $file"
    i=$((i + 1))
  done
done

xcrun simctl status_bar "$DEVICE" clear
echo "완료 → $OUT"
