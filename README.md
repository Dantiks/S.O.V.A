# S.O.V.A - AI-Powered Financial Assistant

<div align="center">
  <img src="assets/images/logo.png" alt="S.O.V.A Logo" width="200"/>
  
  **Ваш персональный финансовый ассистент с искусственным интеллектом**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?logo=dart)](https://dart.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

---

## 📱 О приложении

**S.O.V.A** — это революционное финансовое приложение для пользователей Кыргызстана, которое объединяет все ваши банковские счета в одном месте и использует искусственный интеллект для анализа финансов и предоставления персональных рекомендаций.

### ✨ Ключевые возможности

- 🤖 **AI-Ассистент** - Умный помощник с поддержкой голосового ввода (STT) и озвучивания (TTS)
- 🏦 **Мультибанкинг** - Управление счетами всех банков Кыргызстана
- 📊 **Аналитика** - Детальная статистика расходов и доходов с визуализацией
- 💡 **Умные советы** - Персональные рекомендации по оптимизации бюджета
- 🔒 **Банковская безопасность** - Face ID, Touch ID, PIN-код, AES-256 шифрование
- 🎨 **Кастомизация** - Полная настройка интерфейса под себя
- 📱 **Виджеты** - Быстрый доступ к балансу с домашнего экрана
- 🌙 **Темная/Светлая тема** - Адаптивный дизайн

---

## 🏗️ Архитектура

Приложение построено на **Clean Architecture + MVVM** с использованием современных практик разработки:

```
lib/
├── core/                      # Ядро приложения
│   ├── constants/            # Константы (цвета, стили, конфиги)
│   ├── router/               # Навигация (GoRouter)
│   ├── services/             # Сервисы (AI, Security, Storage, Speech)
│   ├── theme/                # Темы приложения
│   └── utils/                # Утилиты и хелперы
│
├── data/                      # Слой данных
│   ├── datasources/          # Источники данных (Remote, Local)
│   ├── models/               # Модели данных (JSON serialization)
│   └── repositories/         # Реализация репозиториев
│
├── domain/                    # Бизнес-логика
│   ├── entities/             # Сущности (Freezed models)
│   ├── repositories/         # Интерфейсы репозиториев
│   └── usecases/             # Use cases
│
└── presentation/              # UI слой
    ├── providers/            # State management (Riverpod)
    ├── screens/              # Экраны приложения
    └── widgets/              # Переиспользуемые виджеты
```

### 🔧 Технологический стек

#### Core
- **Flutter 3.16+** - UI фреймворк
- **Dart 3.2+** - Язык программирования
- **Riverpod 2.4+** - State management
- **GoRouter** - Навигация

#### Data & Storage
- **Hive** - Локальная база данных (encrypted)
- **Flutter Secure Storage** - Безопасное хранилище
- **Shared Preferences** - Настройки приложения

#### Backend & Cloud
- **Firebase Auth** - Аутентификация
- **Cloud Firestore** - Облачная база данных
- **Firebase Analytics** - Аналитика

#### AI & ML
- **Google Generative AI (Gemini Pro)** - AI-ассистент
- **Speech to Text** - Распознавание речи
- **Flutter TTS** - Синтез речи

#### Security
- **Local Auth** - Биометрическая аутентификация
- **Encrypt** - AES-256 шифрование
- **Crypto** - Хеширование

#### UI & Animation
- **Flutter Animate** - Анимации
- **Lottie** - Векторные анимации
- **Rive** - Интерактивные анимации
- **FL Chart** - Графики и диаграммы
- **Glassmorphism** - Эффект матового стекла

#### Code Generation
- **Freezed** - Immutable models
- **JSON Serializable** - JSON сериализация
- **Riverpod Generator** - Генерация providers

---

## 🚀 Установка и запуск

### Требования

- Flutter SDK 3.16 или выше
- Dart SDK 3.2 или выше
- Xcode 15+ (для iOS)
- Android Studio / VS Code
- Firebase проект

### Шаги установки

1. **Клонируйте репозиторий**
```bash
git clone https://github.com/yourusername/sova.git
cd sova
```

2. **Установите зависимости**
```bash
flutter pub get
```

3. **Настройте Firebase**
```bash
# Установите Firebase CLI
npm install -g firebase-tools

# Войдите в Firebase
firebase login

# Настройте проект
flutterfire configure
```

4. **Создайте файл .env**
```env
GEMINI_API_KEY=your_gemini_api_key_here
```

5. **Сгенерируйте код**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

6. **Запустите приложение**
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

---

## 🔐 Настройка безопасности

### iOS (Info.plist)
```xml
<key>NSFaceIDUsageDescription</key>
<string>Используется для безопасного входа в приложение</string>
<key>NSMicrophoneUsageDescription</key>
<string>Используется для голосового ввода</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Используется для распознавания речи</string>
```

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## 🏦 Поддерживаемые банки Кыргызстана

- ✅ Optima Bank
- ✅ KICB (Kyrgyz Investment and Credit Bank)
- ✅ DemirBank
- ✅ DosCredoBank
- ✅ Halyk Bank
- ✅ Bai Tushum Bank
- ✅ Keremet Bank
- ✅ MBank
- ✅ Kapital Bank
- ✅ eLCARD

---

## 📊 Функциональность

### 1. AI-Ассистент
- Ответы на любые вопросы
- Анализ финансовых данных
- Персональные рекомендации
- Голосовой ввод и вывод
- Контекстный диалог

### 2. Управление счетами
- Добавление банковских счетов
- Синхронизация балансов
- История транзакций
- Категоризация операций

### 3. Аналитика
- Графики доходов и расходов
- Статистика по категориям
- Прогнозы бюджета
- Выявление аномалий

### 4. Безопасность
- Face ID / Touch ID
- PIN-код (4-6 цифр)
- AES-256 шифрование
- Защищенное хранилище
- TLS pinning

### 5. Кастомизация
- Темная/Светлая/Системная тема
- Выбор цвета акцента
- Настройка виджетов
- Персонализация интерфейса

---

## 🧪 Тестирование

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# Coverage
flutter test --coverage
```

---

## 📦 Сборка для production

### 🚀 Автоматическая сборка APK в Downloads

**Быстрая сборка** (1 команда):
```bash
./quick_build.sh
```

**С версией и описанием**:
```bash
./build_and_save_apk.sh "1.0.1" "My-Feature"
```

APK автоматически сохраняется в `~/Downloads/` с датой и временем.

📖 **Подробнее**: См. [APK_BUILD_GUIDE.md](./APK_BUILD_GUIDE.md)

---

### Android (Ручная сборка)
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

---

## 🤝 Вклад в проект

Мы приветствуем вклад в развитие проекта! Пожалуйста:

1. Форкните репозиторий
2. Создайте ветку для фичи (`git checkout -b feature/AmazingFeature`)
3. Закоммитьте изменения (`git commit -m 'Add some AmazingFeature'`)
4. Запушьте в ветку (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

---

## 📄 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE)

---

## 👥 Команда

- **Product Owner** - Ваше имя
- **Lead Developer** - Ваше имя
- **UI/UX Designer** - Ваше имя

---

## 📞 Контакты

- **Email**: support@sova.kg
- **Website**: https://sova.kg
- **Telegram**: @sova_support

---

## 🙏 Благодарности

- Flutter Team за отличный фреймворк
- Google за Gemini AI
- Сообщество Flutter разработчиков

---

<div align="center">
  Made with ❤️ in Kyrgyzstan
  
  **S.O.V.A** © 2024
</div>
