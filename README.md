# ChatWithRider

배달 플랫폼 애플리케이션으로, 손님과 배달원(라이더) 간의 매칭 및 소통을 위한 Flutter 기반 모바일 앱입니다.

## 기능

- 구글 계정을 이용한 로그인/회원가입
- 손님과 배달원 역할 전환 기능
- 주문 생성 및 관리
- 실시간 채팅 기능
- 사용자 정보 관리

## 사용 기술

- **프레임워크**: Flutter
- **상태 관리**: Stateful 위젯
- **인증**: Firebase Authentication, Google Sign-In
- **데이터베이스**: Cloud Firestore
- **실시간 통신**: WebSocket

## 시작하기

### 요구 사항

- Flutter SDK (최신 버전)
- Dart SDK (최신 버전)
- Firebase 프로젝트

### 설치 및 설정

1. 저장소 클론
   ```
   git clone https://github.com/DONALDSUK/ChatWIthRider.git
   cd ChatWithRider
   ```

2. 의존성 설치
   ```
   flutter pub get
   ```

3. Firebase 설정
   - [Firebase 콘솔](https://console.firebase.google.com/)에서 새 프로젝트 생성
   - FlutterFire CLI를 사용하여 앱 설정:
     ```
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
   - 또는 다음 파일들을 수동으로 추가:
     - `lib/firebase_options.dart`
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

4. WebSocket 서버 주소 설정
   - `lib/screens/chat_screen.dart` 파일에서 WebSocket URL 설정

5. 앱 실행
   ```
   flutter run
   ```

## 프로젝트 구조

- **lib/screens/** - 주요 화면 UI
  - `login_screen.dart` - 로그인 화면
  - `signup_screen.dart` - 회원가입 화면
  - `home_screen.dart` - 메인 홈 화면
  - `chat_screen.dart` - 채팅 화면
  - `orderlist_screen.dart` - 주문 목록 화면

## 개발자

- [DONALDSUK](https://github.com/DONALDSUK)

## 라이센스

이 프로젝트는 MIT 라이센스에 따라 라이센스가 부여됩니다.