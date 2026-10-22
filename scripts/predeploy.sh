#!/bin/sh
# 배포 전 게이트 — 여기서 실패하면 DeployBar 가 아카이브를 만들지 않는다.
#
# 사용법:
#   sh scripts/predeploy.sh
#
# 다국어(.xcstrings) 검사는 DeployBar 에 내장돼 있으므로 여기서 다시 하지 않는다.
# 이 스크립트는 "이 앱만의" 검사 — 테스트, 금지 패턴 검사 등 — 를 담는다.
#
# ⚠️ CODE_SIGNING_ALLOWED=NO 로 테스트를 빠르게 만들지 말 것.
#    entitlements 가 빠지면 CloudKit 등 실제 배포 경로에서만 터지는 문제를 놓친다.
set -e
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

SCHEME="Goldweek"
PROJECT_FLAG="-project"
PROJECT="Goldweek.xcodeproj"

# 시험 기기는 **이 게이트 전용 시뮬레이터**(Goldweek-predeploy)를 쓴다.
# 여러 앱 배포가 겹칠 때 공용 기기(예: 다른 앱 게이트·DeployBar 가 쓰는 기기)를 같이 잡으면
# 서로 설치·실행이 엉켜 "Invalid device state" 로 죽거나 몇 시간씩 멈춘다.
# 없으면 **가장 최신 iOS 런타임의 iPhone** 기종으로 새로 만든다.
# (`grep iPhone | head -1` 로 고르면 구버전 런타임 기기가 먼저 잡혀 exit 70 으로 죽는다.)
# 특정 기기로 돌리고 싶으면: PREDEPLOY_SIM_ID=<udid> sh scripts/predeploy.sh
SIM_NAME="Goldweek-predeploy"
DEST_ID="${PREDEPLOY_SIM_ID:-}"
if [ -z "$DEST_ID" ]; then
  PICK="$(xcrun simctl list devices available --json | SIM_NAME="$SIM_NAME" python3 -c '
import json, os, re, sys
name = os.environ["SIM_NAME"]
best = None
for runtime, devices in json.load(sys.stdin)["devices"].items():
    m = re.search(r"iOS-(\d+)-(\d+)", runtime)
    if not m:
        continue
    version = (int(m.group(1)), int(m.group(2)))
    phones = [d for d in devices if d.get("isAvailable") and "iPhone" in d.get("name", "")]
    if not phones:
        continue
    if best is None or version > best[0]:
        mine = [d for d in phones if d["name"] == name]
        best = (version, runtime, phones[0].get("deviceTypeIdentifier", ""), mine[0]["udid"] if mine else "")
print(" ".join(best[1:]) if best else "")
')"
  if [ -z "$PICK" ]; then
    echo "❌ 사용 가능한 iPhone 시뮬레이터가 없습니다"
    xcrun simctl list devices available | head -30
    exit 1
  fi
  set -- $PICK
  RUNTIME="$1"; DEVTYPE="$2"; DEST_ID="${3:-}"
  if [ -z "$DEST_ID" ]; then
    echo "📱 게이트 전용 시뮬레이터를 만듭니다 ($SIM_NAME · $DEVTYPE · $RUNTIME)"
    DEST_ID="$(xcrun simctl create "$SIM_NAME" "$DEVTYPE" "$RUNTIME")"
  fi
fi
DEST="platform=iOS Simulator,id=$DEST_ID"

# 시뮬레이터를 미리 켜 두고 다 켜질 때까지 기다린다.
# xcodebuild 는 기기 부팅을 60초만 기다리는데, 여러 앱 배포·스크린샷이 겹쳐 맥이 바쁘면
# 그 안에 못 켜져 "Timed out trying to boot simulator" (exit 65) 로 시험 전에 죽는다.
# 여기서 넉넉히(최대 10분) 기다려 두면 xcodebuild 는 이미 켜진 기기를 그대로 쓴다.
echo "📱 시뮬레이터 준비 ($DEST_ID)"
xcrun simctl boot "$DEST_ID" 2>/dev/null || true
BOOT_OK=0
i=0
while [ $i -lt 120 ]; do
  if xcrun simctl list devices | grep "$DEST_ID" | grep -q "(Booted)"; then
    BOOT_OK=1
    break
  fi
  sleep 5
  i=$((i + 1))
done
if [ "$BOOT_OK" -ne 1 ]; then
  echo "❌ 시뮬레이터가 10분 안에 켜지지 않았습니다 ($DEST_ID)"
  exit 1
fi
# 부팅 표시 뒤에도 SpringBoard 등이 다 뜰 때까지 기다린다 (이미 켜져 있으면 바로 끝난다).
xcrun simctl bootstatus "$DEST_ID" >/dev/null 2>&1 || true

# 단위 시험만 게이트로 돈다. UI 시험(GoldweekUITests)은 실제 앱을 띄워 몇 분 걸리고
# 시뮬레이터 상태에 따라 흔들릴 수 있어 배포를 막는 데 쓰지 않는다 — Xcode 에서 스킴 시험으로 돌린다.
# 병렬 시험을 끈다: 켜 두면 xcodebuild 가 기기 복제본('Clone 1 of …')을 새로 만들어 부팅하는데,
# 그 복제본 부팅이 위와 같은 60초 제한에 걸린다. 시험 내용은 그대로이고 순서대로 돌 뿐이다.
echo "🧪 단위 테스트 실행 ($SCHEME)"
xcodebuild test \
  "$PROJECT_FLAG" "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DEST" \
  -only-testing:GoldweekTests \
  -parallel-testing-enabled NO \
  -quiet

echo ""
echo "✅ 게이트 통과 — 배포 가능"
