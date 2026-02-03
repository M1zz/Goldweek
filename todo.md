# LeaveWise TODO

## 진행 중

## 완료
- [x] ModelContainer 크래시 수정
  - 원인: try!로 강제 언래핑하여 스키마 변경/저장소 손상 시 크래시
  - 해결: 에러 핸들링 추가, 저장소 삭제 후 재시도, 인메모리 fallback
- [x] 온보딩 반복 표시 버그 수정
  - 원인: UserDefaults(hasCompletedOnboarding)와 SwiftData(profile) 동기화 안 됨
  - 해결: hasCompletedOnboarding이 true인데 profile이 없으면 기본 profile 자동 생성
- [x] 온보딩 국가 선택 페이지 제거
  - 기기 언어 설정에 따라 자동으로 국가/언어 설정
- [x] 앱 리뷰 기능 추가
  - 설정 > 앱 정보에 "앱 평가하기" 버튼 추가
  - StoreKit requestReview() 사용
