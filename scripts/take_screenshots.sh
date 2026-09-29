#!/bin/bash
# Goldweek App Store 스크린샷 자동 촬영 — 언어 × 탭
#
# DEBUG 빌드의 스크린샷 모드(Goldweek/Utilities/ScreenshotMode.swift)로 언어별 데모 데이터를 채운 뒤
# 탭마다 시뮬레이터 화면을 캡처한다. 결과: docs/screenshots/<언어>/<번호>-<화면>.png
#
# 사용법: scripts/take_screenshots.sh [언어...]   (기본: en ko ja zh de fr es it pt zh-Hant)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEVICE="${DEVICE:-iPhone 18 Pro Max}"   # 6.9" — App Store 필수 규격 (1320×2868)
BUNDLE_ID="com.Ysoup.LeaveWise"
DERIVED="${DERIVED:-$ROOT/build/screenshots-dd}"
OUT="$ROOT/docs/screenshots"
LANGS=("$@"); [ ${#LANGS[@]} -eq 0 ] && LANGS=(en ko ja zh de fr es it pt zh-Hant)

# 탭 번호:이름 (MainTabView 의 tag)
SHOTS=("0:home" "1:calendar" "3:settings")

apple_lang() {   # 앱 언어 코드 → 시스템 언어 코드
  case "$1" in zh) echo "zh-Hans" ;; pt) echo "pt-BR" ;; *) echo "$1" ;; esac
}

apple_locale() {   # 앱 언어 코드 → 지역 (국가 판별이 지역을 보므로 데모 국가와 맞춘다)
  case "$1" in
    ko) echo "ko_KR" ;; en) echo "en_US" ;; ja) echo "ja_JP" ;; zh) echo "zh_CN" ;;
    de) echo "de_DE" ;; fr) echo "fr_FR" ;; es) echo "es_ES" ;; it) echo "it_IT" ;;
    pt) echo "pt_BR" ;; zh-Hant) echo "zh_TW" ;; *) echo "$1" ;;
  esac
}

out_dir() {   # 저장 폴더 — 기존 6개 언어는 예전 이름 그대로, 새 언어는 스토어 로케일 이름
  case "$1" in pt) echo "pt-BR" ;; *) echo "$1" ;; esac
}

echo "▶ 시뮬레이터 준비: $DEVICE"
xcrun simctl boot "$DEVICE" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE" -b >/dev/null
xcrun simctl status_bar "$DEVICE" override --time "9:41" --batteryState charged --batteryLevel 100 \
  --cellularMode active --cellularBars 4 --wifiBars 3 --dataNetwork wifi

echo "▶ 빌드 (Debug)"
xcodebuild -project "$ROOT/Goldweek.xcodeproj" -scheme Goldweek -configuration Debug \
  -destination "platform=iOS Simulator,name=$DEVICE" -derivedDataPath "$DERIVED" build -quiet
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
  i=1
  for shot in "${SHOTS[@]}"; do
    tab="${shot%%:*}"; name="${shot##*:}"
    xcrun simctl terminate "$DEVICE" "$BUNDLE_ID" 2>/dev/null || true
    xcrun simctl launch "$DEVICE" "$BUNDLE_ID" \
      -screenshotMode YES -screenshotTab "$tab" -isPro YES \
      -appLanguage "$lang" -AppleLanguages "($sys)" -AppleLocale "$loc" >/dev/null
    sleep "${WAIT:-6}"
    file="$dir/$i-$name.png"
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
