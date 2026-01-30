# LeaveWise TODO

## 진행 중

## 완료
- [x] 온보딩 반복 표시 버그 수정
  - 원인: UserDefaults(hasCompletedOnboarding)와 SwiftData(profile) 동기화 안 됨
  - 해결: profile 존재 여부만으로 온보딩 표시 결정하도록 변경
