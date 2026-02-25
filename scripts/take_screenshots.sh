#!/bin/bash
# LeaveWise 스크린샷 촬영 스크립트
# 시뮬레이터에서 앱이 실행 중이어야 합니다

DEVICE="iPhone 17"
OUTPUT_DIR="/Users/leeo/Documents/workspace/code/LeaveWise/docs/images"

echo "📸 LeaveWise 스크린샷 촬영"
echo "================================"
echo ""
echo "각 화면에서 Enter를 누르면 스크린샷을 찍습니다."
echo "시뮬레이터에서 원하는 화면으로 이동한 후 Enter를 누르세요."
echo ""

# 홈 화면
echo "1️⃣  홈 화면으로 이동하세요 (첫 번째 탭)"
read -p "   준비되면 Enter..."
xcrun simctl io "$DEVICE" screenshot "$OUTPUT_DIR/screenshot-1.png"
echo "   ✅ screenshot-1.png 저장됨"
echo ""

# 캘린더
echo "2️⃣  캘린더 화면으로 이동하세요 (두 번째 탭)"
read -p "   준비되면 Enter..."
xcrun simctl io "$DEVICE" screenshot "$OUTPUT_DIR/screenshot-2.png"
echo "   ✅ screenshot-2.png 저장됨"
echo ""

# 추천
echo "3️⃣  추천 화면으로 이동하세요 (네 번째 탭)"
read -p "   준비되면 Enter..."
xcrun simctl io "$DEVICE" screenshot "$OUTPUT_DIR/screenshot-3.png"
echo "   ✅ screenshot-3.png 저장됨"
echo ""

# 등록
echo "4️⃣  등록 화면으로 이동하세요 (세 번째 탭)"
read -p "   준비되면 Enter..."
xcrun simctl io "$DEVICE" screenshot "$OUTPUT_DIR/screenshot-4.png"
echo "   ✅ screenshot-4.png 저장됨"
echo ""

# 설정
echo "5️⃣  설정 화면으로 이동하세요 (다섯 번째 탭)"
read -p "   준비되면 Enter..."
xcrun simctl io "$DEVICE" screenshot "$OUTPUT_DIR/screenshot-5.png"
echo "   ✅ screenshot-5.png 저장됨"
echo ""

# 히어로 이미지 (홈 화면 다시)
echo "6️⃣  히어로 이미지용 - 홈 화면 (데이터가 있는 상태)"
read -p "   준비되면 Enter..."
xcrun simctl io "$DEVICE" screenshot "$OUTPUT_DIR/hero-mockup.png"
echo "   ✅ hero-mockup.png 저장됨"
echo ""

echo "================================"
echo "🎉 완료! 모든 스크린샷이 저장되었습니다."
echo "📁 저장 위치: $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"
