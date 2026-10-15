# dyve_toy_app

DYVE 웹(https://www.dyve.live) 모바일 화면을 Flutter로 옮긴 토이 앱입니다.
프론트만 있고, 데이터는 `lib/data/dummy_data.dart`의 더미 데이터입니다. 로그인과 결제는 모의 동작입니다.

## 폴더
- `lib/` 앱 코드 (`screens/` 화면, `widgets/` 공통 위젯, `app_state.dart` 앱 상태)
- `docs/` 유스케이스 다이어그램, 서비스 흐름도 (PlantUML)
- `app_screenshot/` 실제 DYVE 모바일 화면 캡처 (화면설계 참고용)

## 실행
필요한 것: [Flutter SDK](https://docs.flutter.dev/get-started/install) 와 Chrome. Xcode는 필요 없습니다.

```bash
git clone https://github.com/JSY929/dyve_toy_app.git
cd dyve_toy_app
flutter pub get
flutter run -d chrome
```

휴대폰 화면 비율로 보려면 Chrome 개발자도구(F12)에서 기기 모드를 켭니다.

### 선택: iPhone 시뮬레이터 (Mac + Xcode 필요)
```bash
open -a Simulator
flutter run -d "iPhone 16"
```
