#!/bin/bash

# 1. 먼저 1024x1024 PNG를 준비하세요
# 2. pubspec.yaml에 추가:
#    dev_dependencies:
#      flutter_launcher_icons: ^0.13.1

# 3. 아이콘 생성 실행
flutter pub get
flutter pub run flutter_launcher_icons

echo "✅ 앱 아이콘 생성 완료!"
echo "📁 생성된 위치:"
echo "  - Android: android/app/src/main/res/"
echo "  - iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/"