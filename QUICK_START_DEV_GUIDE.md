# 🚀 QUICK START - Гайд для разработчиков

## 📋 Оглавление
1. [Предварительные требования](#предварительные-требования)
2. [Настройка проекта](#настройка-проекта)
3. [Получение API ключей](#получение-api-ключей)
4. [Firebase настройка](#firebase-настройка)
5. [Запуск приложения](#запуск-приложения)
6. [Структура проекта](#структура-проекта)
7. [Типичные проблемы](#типичные-проблемы)

---

## ⚙️ Предварительные требования

### Обязательно:
- ✅ Flutter SDK 3.16 или выше
- ✅ Dart SDK 3.2 или выше
- ✅ Android Studio / Xcode
- ✅ Git
- ✅ VS Code (рекомендуется) или Android Studio

### Проверка установки:
```bash
flutter --version
dart --version
flutter doctor
```

### IDE Extensions (VS Code):
- Flutter
- Dart
- GitLens
- Error Lens
- Todo Tree

---

## 🔧 Настройка проекта

### 1. Клонирование репозитория
```bash
git clone https://github.com/yourusername/sova.git
cd sova
```

### 2. Установка зависимостей
```bash
flutter pub get
```

### 3. Генерация кода (Freezed, JSON Serializable)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Проверка зависимостей
```bash
flutter doctor -v
```

---

## 🔑 Получение API ключей

### 1. OpenAI API Key
**Для AI чата**

1. Зарегистрируйтесь на https://platform.openai.com/
2. Перейдите в API Keys: https://platform.openai.com/api-keys
3. Создайте новый ключ → "Create new secret key"
4. Скопируйте ключ (начинается с `sk-...`)
5. **ВАЖНО:** Ключ показывается только один раз!

**Pricing:**
- GPT-3.5-turbo: ~$0.002 за 1K tokens
- GPT-4: ~$0.03 за 1K tokens
- Новым пользователям дается $5 бесплатных кредитов

**Альтернатива (для разработки):**
Можно использовать Demo режим без ключа. AI будет работать с базовыми правилами.

---

### 2. Currency API Key
**Для курсов валют**

1. Зарегистрируйтесь на https://www.exchangerate-api.com/
2. Подтвердите email
3. Скопируйте API key из dashboard
4. Free план: 1,500 requests/month

**Альтернативы:**
- https://fixer.io/ (Free plan)
- https://openexchangerates.org/ (Free plan)
- https://currencyapi.com/ (Free plan)

---

### 3. Google Maps API (опционально)
**Для геолокации транзакций**

1. Перейдите в Google Cloud Console: https://console.cloud.google.com/
2. Создайте новый проект
3. Enable APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
4. Создайте API key в Credentials
5. Ограничьте ключ (по IP/домену/приложению)

---

## 🔥 Firebase настройка

### Шаг 1: Создание проекта Firebase

1. Откройте Firebase Console: https://console.firebase.google.com/
2. Нажмите "Add project"
3. Введите название: `sova-finance` (или своё)
4. Отключите Google Analytics (можно включить позже)
5. Нажмите "Create project"

---

### Шаг 2: Установка Firebase CLI

```bash
# Установка Firebase CLI
npm install -g firebase-tools

# Логин
firebase login

# Установка FlutterFire CLI
dart pub global activate flutterfire_cli
```

Добавьте в PATH (если нужно):
```bash
# macOS/Linux
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Windows (PowerShell)
$env:Path += ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin"
```

---

### Шаг 3: Настройка Firebase для Flutter

```bash
# В корне проекта
flutterfire configure
```

**Что делает эта команда:**
- Автоматически создает `firebase_options.dart`
- Настраивает Android и iOS конфигурацию
- Связывает приложение с Firebase проектом

**Выберите:**
- [x] Android
- [x] iOS (если разрабатываете на Mac)
- Проект: `sova-finance` (ваш проект)
- Bundle ID iOS: `com.yourdomain.sova`
- Package name Android: `com.yourdomain.sova`

---

### Шаг 4: Включение сервисов в Firebase Console

#### Authentication:
1. Firebase Console → Authentication → Get started
2. Enable Sign-in methods:
   - [x] Email/Password
   - [x] Google
   - [x] Phone (опционально)

#### Cloud Firestore:
1. Firebase Console → Firestore Database → Create database
2. Start in **test mode** (для разработки)
3. Location: выберите ближайший (например, `europe-west1`)

**⚠️ ВАЖНО:** Перед production измените rules!

**Базовые Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Accounts collection
    match /accounts/{accountId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Transactions collection
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

#### Cloud Messaging (Push Notifications):
1. Firebase Console → Cloud Messaging
2. Автоматически включен

**iOS:** Понадобится:
- Apple Developer account
- Push Notification certificate (`.p12`)
- Загрузить в Firebase Console → Settings → Cloud Messaging → iOS app

**Android:** Работает автоматически

#### Analytics (опционально):
1. Firebase Console → Analytics → Enable
2. Автоматически включится после первого запуска

---

### Шаг 5: Настройка iOS (если разрабатываете на Mac)

```bash
cd ios
pod install
cd ..
```

**Добавьте в `ios/Runner/Info.plist`:**
```xml
<key>NSFaceIDUsageDescription</key>
<string>Используется для безопасного входа в приложение</string>
<key>NSCameraUsageDescription</key>
<string>Используется для сканирования чеков</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Используется для загрузки чеков из галереи</string>
```

---

### Шаг 6: Настройка Android

**Добавьте в `android/app/build.gradle`:**
```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Минимум для Firebase
        targetSdkVersion 34
    }
}
```

**Добавьте в `android/app/src/main/AndroidManifest.xml`:**
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

---

## 🔐 Environment Variables

### Создайте `.env` файл в корне проекта:

```env
# OpenAI API
OPENAI_API_KEY=sk-...your-key-here

# Currency API
CURRENCY_API_KEY=your-currency-api-key

# Firebase (опционально, уже в firebase_options.dart)
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_PROJECT_ID=sova-finance

# Google Maps (если используется)
GOOGLE_MAPS_API_KEY=your-google-maps-key
```

### Создайте `.env.example` (для других разработчиков):

```env
# OpenAI API (https://platform.openai.com/api-keys)
OPENAI_API_KEY=sk-...

# Currency API (https://www.exchangerate-api.com/)
CURRENCY_API_KEY=...

# Firebase
FIREBASE_API_KEY=...
FIREBASE_PROJECT_ID=...

# Google Maps (optional)
GOOGLE_MAPS_API_KEY=...
```

### Добавьте в `.gitignore`:

```gitignore
# Environment
.env
.env.local
.env.*.local

# Firebase (если не используете flutterfire configure)
firebase_options.dart

# Secrets
*.key
*.p12
*.jks
google-services.json
GoogleService-Info.plist
```

---

## ▶️ Запуск приложения

### Development Mode

```bash
# iOS (Mac only)
flutter run -d ios --dart-define-from-file=.env

# Android
flutter run -d android --dart-define-from-file=.env

# Web (для быстрого тестирования UI)
flutter run -d chrome
```

**Без .env файла (Demo режим):**
```bash
flutter run
# AI будет работать в Demo режиме
# Курсы валют будут mock данные
```

---

### Debug на реальном устройстве

#### Android:
1. Включите "Developer Options" на телефоне
2. Включите "USB Debugging"
3. Подключите USB кабель
4. Разрешите отладку на телефоне
5. `flutter devices` - проверьте подключение
6. `flutter run`

#### iOS (Mac only):
1. Подключите iPhone/iPad
2. Откройте Xcode → Preferences → Accounts
3. Добавьте Apple ID
4. Откройте `ios/Runner.xcworkspace` в Xcode
5. Signing & Capabilities → Team → выберите свой Team
6. `flutter run`

---

### Hot Reload / Hot Restart

```bash
# Во время работы flutter run:
r  # Hot reload (быстрая перезагрузка)
R  # Hot restart (полный перезапуск)
q  # Quit
```

---

## 📁 Структура проекта

```
lib/
├── core/                      # Ядро приложения
│   ├── config/               # Конфигурация (env_config.dart)
│   ├── constants/            # Константы (colors, styles)
│   ├── router/               # Навигация (GoRouter)
│   ├── services/             # Сервисы (AI, Security, Storage)
│   ├── theme/                # Темы
│   └── utils/                # Утилиты
│
├── data/                      # Слой данных
│   ├── datasources/          # Источники данных (Remote, Local)
│   ├── models/               # Модели (JSON)
│   └── repositories/         # Репозитории (impl)
│
├── domain/                    # Бизнес-логика
│   ├── entities/             # Сущности (Freezed)
│   ├── repositories/         # Интерфейсы
│   └── usecases/             # Use cases
│
├── presentation/              # UI слой
│   ├── providers/            # Riverpod providers
│   ├── screens/              # Экраны
│   │   ├── home/            # Главный экран
│   │   │   └── tabs/        # Табы (dashboard, accounts, chat, analytics, profile)
│   │   ├── auth/            # Авторизация
│   │   ├── transactions/    # Транзакции
│   │   ├── goals/           # Цели
│   │   └── ...
│   └── widgets/              # Переиспользуемые виджеты
│
└── main.dart                  # Entry point
```

---

## 🎨 Ключевые технологии

| Технология | Назначение | Документация |
|------------|-----------|--------------|
| **Riverpod** | State Management | https://riverpod.dev |
| **Hive** | Local Database | https://docs.hivedb.dev |
| **Freezed** | Immutable Models | https://pub.dev/packages/freezed |
| **GoRouter** | Navigation | https://pub.dev/packages/go_router |
| **Firebase** | Backend as a Service | https://firebase.google.com/docs |
| **FL Chart** | Charts & Graphs | https://pub.dev/packages/fl_chart |
| **Dio** | HTTP Client | https://pub.dev/packages/dio |

---

## 🧪 Тестирование

### Запуск тестов:

```bash
# Все тесты
flutter test

# Конкретный файл
flutter test test/core/services/security_service_test.dart

# С coverage
flutter test --coverage

# Просмотр coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Integration тесты:

```bash
flutter test integration_test/app_test.dart
```

---

## 🐛 Debug инструменты

### Flutter DevTools

```bash
# Запустить DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Или просто
flutter run
# Откроется URL с DevTools
```

**Возможности:**
- Inspector (UI дерево)
- Performance (60fps мониторинг)
- Memory (утечки памяти)
- Network (HTTP запросы)
- Logging

---

### Логирование

**В коде используйте:**
```dart
import 'package:logger/logger.dart';

final logger = Logger();

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

**Просмотр логов:**
```bash
# Android
adb logcat | grep flutter

# iOS
flutter logs
```

---

## 🎯 Первые шаги после установки

### 1. Проверьте, что все работает:
```bash
flutter doctor -v
flutter pub get
flutter pub run build_runner build
flutter run
```

### 2. Создайте первого пользователя:
- Откройте приложение
- Установите PIN (4-6 цифр)
- Зайдите в приложение

### 3. Добавьте тестовые данные:
- Добавьте счет (Optima Bank, 10000 сом)
- Добавьте транзакцию (расход 500 сом на продукты)
- Проверьте аналитику

### 4. Протестируйте AI чат:
- Перейдите в AI таб
- Спросите: "Сколько я потратил?"
- Должен показать статистику

---

## ❗ Типичные проблемы

### Проблема: Build Runner ошибки
```bash
# Решение:
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Проблема: Firebase не инициализируется
```
[ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: 
[core/no-app] No Firebase App '[DEFAULT]' has been created
```

**Решение:**
1. Проверьте, что `firebase_options.dart` существует
2. Убедитесь, что `Firebase.initializeApp()` вызывается в `main()`
3. Проверьте `google-services.json` (Android) и `GoogleService-Info.plist` (iOS)

### Проблема: OpenAI API не работает
```
⚠️ Using DEMO AI mode (OpenAI not configured)
```

**Решение:**
1. Создайте `.env` файл
2. Добавьте `OPENAI_API_KEY=sk-...`
3. Перезапустите приложение

### Проблема: iOS Pod install failed
```bash
# Решение:
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

### Проблема: Android Gradle build failed
```bash
# Решение:
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Проблема: Hive box already open
```
HiveError: Box has already been opened
```

**Решение:**
Добавьте проверку:
```dart
if (!Hive.isBoxOpen('boxName')) {
  box = await Hive.openBox('boxName');
}
```

---

## 🔥 Hot Tips

### 1. Быстрая перезагрузка Hive данных:
```bash
# Android
adb shell run-as com.yourdomain.sova rm -rf /data/data/com.yourdomain.sova/app_flutter/

# iOS
flutter clean
```

### 2. Просмотр Hive данных:
Используйте Flutter DevTools → Inspector → Tree

### 3. Отладка провайдеров (Riverpod):
```dart
class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('Provider: ${provider.name ?? provider.runtimeType}');
    print('Previous: $previousValue');
    print('New: $newValue');
  }
}

// В main.dart:
runApp(
  ProviderScope(
    observers: [ProviderLogger()],
    child: MyApp(),
  ),
);
```

### 4. Быстрое тестирование экранов:
Создайте отдельный `main_debug.dart`:
```dart
void main() {
  runApp(MaterialApp(
    home: YourScreenToTest(),
  ));
}
```

Запуск:
```bash
flutter run -t lib/main_debug.dart
```

---

## 📚 Полезные команды

```bash
# Обновить зависимости
flutter pub upgrade

# Проверить устаревшие пакеты
flutter pub outdated

# Анализ кода
flutter analyze

# Форматирование кода
dart format lib/

# Генерация иконки приложения
flutter pub run flutter_launcher_icons

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Build iOS
flutter build ios --release

# Размер APK
flutter build apk --analyze-size --target-platform android-arm64
```

---

## 🎓 Дальнейшее обучение

### Документация:
- [Flutter Docs](https://docs.flutter.dev/)
- [Riverpod Docs](https://riverpod.dev/)
- [Firebase Flutter](https://firebase.google.com/docs/flutter/setup)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Видео курсы:
- Flutter & Firebase Course (YouTube)
- Riverpod State Management (ResoCoder)
- Clean Architecture in Flutter (Reso Coder)

---

## 💬 Помощь и поддержка

### Если возникли проблемы:
1. Проверьте `DETAILED_ANALYSIS_REPORT.md` - известные проблемы
2. Проверьте `TODO_DETAILED.md` - возможно это еще не реализовано
3. Создайте Issue на GitHub
4. Свяжитесь с командой

### Полезные ссылки:
- GitHub Issues: https://github.com/yourusername/sova/issues
- Документация: `docs/` папка
- Telegram группа: @sova_devs (если есть)

---

## ✅ Чеклист первого запуска

- [ ] Flutter SDK установлен и обновлен
- [ ] VS Code + Extensions установлены
- [ ] Проект склонирован
- [ ] `flutter pub get` выполнен
- [ ] `build_runner` отработал успешно
- [ ] Firebase проект создан
- [ ] `flutterfire configure` выполнен
- [ ] `.env` файл создан (или работает Demo режим)
- [ ] API ключи получены (OpenAI, Currency)
- [ ] Приложение запускается на эмуляторе/устройстве
- [ ] Можно создать PIN и войти
- [ ] Можно добавить счет и транзакцию
- [ ] AI чат отвечает (Demo или real)
- [ ] Firebase работает (если настроен)

---

**Готово к разработке! 🎉**

Если все пункты чеклиста выполнены - можно приступать к работе над проектом.

**Следующий шаг:** Откройте `TODO_DETAILED.md` и выберите задачу из Sprint 1.

---

**Последнее обновление:** 3 декабря 2025  
**Версия гайда:** 1.0
