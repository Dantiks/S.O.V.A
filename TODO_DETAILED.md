# 📝 ДЕТАЛЬНЫЙ СПИСОК ЗАДАЧ (TODO)

## 🔴 КРИТИЧЕСКИЙ ПРИОРИТЕТ (Немедленно)

### 1. Environment Configuration
**Файлы:** `.env`, `lib/core/config/env_config.dart`

- [ ] Создать `.env` файл в корне проекта
- [ ] Добавить `.env.example` с примерами
- [ ] Настроить `flutter_dotenv` пакет
- [ ] Добавить валидацию API ключей при старте
- [ ] Создать документ `API_SETUP.md`

**Пример `.env`:**
```env
OPENAI_API_KEY=sk-...
CURRENCY_API_KEY=...
FIREBASE_API_KEY=...
```

---

### 2. Firebase Integration
**Файлы:** `lib/firebase_options_stub.dart`, Firebase config

- [ ] Настроить Firebase Auth
  - [ ] Email/Password authentication
  - [ ] Google Sign-In
  - [ ] Phone authentication
- [ ] Настроить Cloud Firestore
  - [ ] Users collection
  - [ ] Accounts collection  
  - [ ] Transactions collection
  - [ ] Security rules
- [ ] Настроить Firebase Analytics
- [ ] Настроить Crashlytics
- [ ] Реализовать offline-first sync (Hive + Firestore)
- [ ] Добавить conflict resolution при sync

---

### 3. Authentication Fix
**Файл:** `lib/presentation/screens/auth/auth_screen.dart:405`

```dart
// TODO: Реализовать реальную аутентификацию
```

- [ ] Удалить mock авторизацию
- [ ] Интегрировать Firebase Auth
- [ ] Добавить error handling
- [ ] Реализовать forgot password
- [ ] Добавить email verification
- [ ] Реализовать session management
- [ ] Добавить auto-logout при неактивности

---

### 4. Bank Integration
**Файл:** `lib/data/datasources/bank_remote_datasource.dart`

```dart
// TODO: Implement actual API call
```

- [ ] Исследовать банковские API в Кыргызстане
- [ ] Выбрать Open Banking агрегатор (если есть)
- [ ] Реализовать OAuth 2.0 flow для банков
- [ ] Добавить secure token storage
- [ ] Реализовать auto-sync транзакций
- [ ] Добавить webhook endpoints
- [ ] Реализовать error handling и retry logic
- [ ] Добавить rate limiting
- [ ] Тестирование с sandbox API

**Банки для интеграции:**
- Optima Bank
- KICB (Kyrgyz Investment and Credit Bank)
- DemirBank
- DosCredoBank
- Halyk Bank
- Bai Tushum Bank
- Keremet Bank
- MBank
- Kapital Bank
- eLCARD

---

### 5. Push Notifications
**Файл:** `lib/core/services/notification_service.dart`

- [ ] Раскомментировать пакеты в `pubspec.yaml`:
  ```yaml
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
  ```
- [ ] Реализовать NotificationService полностью
- [ ] Настроить FCM в Firebase Console
- [ ] Добавить iOS Push certificates
- [ ] Реализовать local notifications
- [ ] Добавить notification channels (Android)
- [ ] Реализовать notification handling
  - [ ] Foreground
  - [ ] Background
  - [ ] Terminated
- [ ] Добавить UI для настроек уведомлений
- [ ] Реализовать scheduled notifications
  - [ ] Напоминание о бюджете
  - [ ] Предстоящие платежи
  - [ ] Цели накоплений

---

## 🟠 ВЫСОКИЙ ПРИОРИТЕТ (1-2 недели)

### 6. Завершить UI TODO
**Файл:** `lib/presentation/screens/home/tabs/dashboard_tab.dart`

#### 6.1. Кнопка уведомлений (строка 89)
```dart
// TODO: Открыть уведомления
```
- [ ] Создать экран уведомлений
- [ ] Добавить список уведомлений
- [ ] Реализовать mark as read
- [ ] Добавить filter (все/непрочитанные)

#### 6.2. Показать все транзакции (строка 138)
```dart
// TODO: Открыть все транзакции
```
- [ ] Навигация к экрану всех транзакций
- [ ] Добавить pagination
- [ ] Реализовать infinite scroll

#### 6.3. Диалог добавления транзакции (строка 521)
```dart
'Функция в разработке...'
```
- [ ] Удалить заглушку
- [ ] Подключить AddTransactionScreen
- [ ] Добавить pre-fill type если передан

---

### 7. Navigation Refactoring
**Файл:** `lib/core/router/app_router.dart`, `lib/main.dart`

- [ ] Мигрировать с MaterialPageRoute на GoRouter полностью
- [ ] Удалить старую навигацию из `main.dart`
- [ ] Добавить все роуты в GoRouter
- [ ] Реализовать auth guard
- [ ] Настроить deep linking
- [ ] Добавить redirect logic
- [ ] Обработка unknown routes

**Роуты для добавления:**
```dart
/splash
/onboarding
/auth/login
/auth/register
/auth/forgot-password
/pin/setup
/pin/enter
/home
/home/dashboard
/home/accounts
/home/chat
/home/analytics
/home/profile
/accounts/add
/accounts/:id
/transactions/add
/transactions/:id
/goals
/goals/add
/settings
/notifications
```

---

### 8. Testing
**Папка:** `test/`

#### 8.1. Unit Tests
- [ ] `test/core/services/`
  - [ ] openai_service_test.dart
  - [ ] demo_ai_service_test.dart
  - [ ] security_service_test.dart
  - [ ] currency_service_test.dart
  - [ ] storage_service_test.dart
- [ ] `test/data/repositories/`
  - [ ] account_repository_test.dart
  - [ ] transaction_repository_test.dart
- [ ] `test/domain/usecases/`
  - [ ] (создать usecases если нужно)

#### 8.2. Widget Tests
- [ ] `test/presentation/screens/`
  - [ ] dashboard_tab_test.dart
  - [ ] accounts_tab_test.dart
  - [ ] chat_tab_test.dart
  - [ ] analytics_tab_test.dart
- [ ] `test/presentation/widgets/`
  - [ ] (тестировать переиспользуемые виджеты)

#### 8.3. Integration Tests
- [ ] `integration_test/`
  - [ ] app_test.dart (полный flow)
  - [ ] auth_flow_test.dart
  - [ ] transaction_flow_test.dart

**Цель:** Coverage >70%

---

### 9. OCR Service
**Файл:** `lib/core/services/ocr_service.dart`

- [ ] Раскомментировать пакеты:
  ```yaml
  google_mlkit_text_recognition: ^0.11.0
  image_picker: ^1.0.7
  ```
- [ ] Реализовать scanReceipt()
- [ ] Реализовать scanReceiptFromGallery()
- [ ] Добавить ML модель для парсинга
- [ ] Создать UI для сканирования
  - [ ] Camera preview
  - [ ] Capture button
  - [ ] Gallery import
- [ ] Извлекать данные из чека:
  - [ ] Сумма
  - [ ] Дата
  - [ ] Торговая точка
  - [ ] Категория (определить автоматически)
- [ ] Автосоздание транзакции
- [ ] Добавить preview перед сохранением

---

### 10. Speech Services
**Файл:** `lib/core/services/speech_service.dart`

- [ ] Раскомментировать пакеты:
  ```yaml
  speech_to_text: ^6.5.1
  flutter_tts: ^4.0.2
  ```
- [ ] Интегрировать в ChatTab
- [ ] Добавить кнопку микрофона
- [ ] Реализовать визуализацию записи
- [ ] Добавить голосовые ответы AI
- [ ] Реализовать голосовые команды:
  - "Сколько я потратил?"
  - "Покажи мой баланс"
  - "Добавь расход 500 сом на продукты"
- [ ] Добавить настройки голоса в профиле
- [ ] Поддержка русского и кыргызского

---

## 🟡 СРЕДНИЙ ПРИОРИТЕТ (2-4 недели)

### 11. Splash Screen Navigation
**Файл:** `lib/presentation/screens/splash/splash_screen.dart:47`

```dart
// TODO: Navigate to appropriate screen based on auth state
```

- [ ] Проверка auth state из Firebase
- [ ] Навигация в onboarding для новых пользователей
- [ ] Навигация в home для авторизованных
- [ ] Навигация в login для не авторизованных

---

### 12. Локализация
**Новые файлы:** `lib/l10n/`

- [ ] Настроить flutter_localizations
- [ ] Создать arb файлы:
  - [ ] `app_en.arb` (English)
  - [ ] `app_ru.arb` (Russian) 
  - [ ] `app_ky.arb` (Kyrgyz)
- [ ] Вынести все hardcoded strings
- [ ] Добавить language selector в настройках
- [ ] Локализовать:
  - [ ] Названия экранов
  - [ ] Кнопки и labels
  - [ ] Error messages
  - [ ] Валидация messages
  - [ ] Notifications
  - [ ] Tooltips

---

### 13. Бюджеты (полная реализация)
**Файл:** `lib/domain/entities/budget_entity.dart` (готов)

#### Что нужно:
- [ ] Создать `BudgetProvider`
- [ ] Создать экраны:
  - [ ] `BudgetsScreen` (список)
  - [ ] `AddBudgetScreen` (создание)
  - [ ] `BudgetDetailScreen` (детали + прогресс)
- [ ] Реализовать логику:
  - [ ] Отслеживание расходов по бюджету
  - [ ] Уведомления о превышении (80%, 100%)
  - [ ] Категориальные бюджеты
  - [ ] Повторяющиеся бюджеты (ежемесячно)
- [ ] Добавить визуализацию:
  - [ ] Прогресс бары
  - [ ] Графики
  - [ ] Прогноз на конец месяца
- [ ] Интеграция в Dashboard:
  - [ ] Показывать текущий статус
  - [ ] Предупреждения

---

### 14. Регулярные платежи (автоматизация)
**Файл:** `lib/presentation/providers/recurring_provider.dart` (готов частично)

- [ ] Создать UI для управления:
  - [ ] RecurringPaymentsScreen
  - [ ] AddRecurringScreen
  - [ ] EditRecurringScreen
- [ ] Реализовать автоматическое создание транзакций
- [ ] Добавить background task для проверки
- [ ] Уведомления перед платежом (за 1-3 дня)
- [ ] История выполненных платежей
- [ ] Пауза/возобновление подписок
- [ ] Анализ подписок (сколько трачу на подписки)

---

### 15. Export/Import
**Файл:** `lib/core/services/export_service.dart`

#### Export:
- [ ] Раскомментировать пакеты:
  ```yaml
  pdf: ^3.10.7
  printing: ^5.11.1
  ```
- [ ] Реализовать PDF export:
  - [ ] Транзакции
  - [ ] Отчеты
  - [ ] Чеки
- [ ] Excel export:
  - [ ] Добавить `excel` пакет
  - [ ] Форматирование
  - [ ] Графики в Excel
- [ ] Выбор периода экспорта
- [ ] Фильтры (по категориям, счетам)
- [ ] Email отправка отчетов

#### Import:
- [ ] CSV import транзакций
- [ ] Excel import
- [ ] Mapping колонок
- [ ] Preview перед импортом
- [ ] Дедупликация
- [ ] Error handling

---

### 16. Onboarding
**Новая папка:** `lib/presentation/screens/onboarding/`

- [ ] Создать OnboardingScreen
- [ ] 4-5 слайдов с фичами:
  - [ ] Приветствие
  - [ ] Мультибанкинг
  - [ ] AI ассистент
  - [ ] Аналитика
  - [ ] Безопасность
- [ ] Анимации (Rive или Lottie)
- [ ] Skip button
- [ ] Сохранять флаг "показан onboarding"

---

### 17. Widget для главного экрана
**Файл:** `lib/core/services/widget_service.dart` (минимальная реализация)

- [ ] Реализовать home_widget полностью
- [ ] iOS Widget (WidgetKit)
- [ ] Android Widget (App Widget)
- [ ] Показывать:
  - [ ] Общий баланс
  - [ ] Последние транзакции
  - [ ] Расходы за день
- [ ] Deep linking из виджета
- [ ] Обновление данных

---

### 18. Security Enhancements
**Файлы:** `lib/core/services/security_service.dart`

- [ ] Certificate pinning:
  - [ ] Добавить `flutter_ssl_pinning`
  - [ ] Pinning для API endpoints
- [ ] Root/Jailbreak detection:
  - [ ] Добавить `flutter_jailbreak_detection`
  - [ ] Предупреждение пользователя
- [ ] Code obfuscation:
  - [ ] Настроить в build.gradle
  - [ ] Flutter build --obfuscate
- [ ] Session management:
  - [ ] Auto logout (15 мин неактивности)
  - [ ] Session expiry
- [ ] Fraud detection:
  - [ ] Необычные транзакции
  - [ ] Новое устройство
  - [ ] Смена PIN с нового места

---

## 🟢 НИЗКИЙ ПРИОРИТЕТ (будущее)

### 19. Business Features
**Папка:** `lib/presentation/screens/business/`

- [ ] Завершить BusinessDashboardScreen
- [ ] Реализовать EmployeesScreen
- [ ] Создать InvoicesScreen:
  - [ ] Создание инвойсов
  - [ ] Отправка клиентам
  - [ ] Отслеживание оплаты
  - [ ] PDF генерация
- [ ] Отчеты для бизнеса:
  - [ ] P&L (Прибыли и убытки)
  - [ ] Cash Flow
  - [ ] Balance Sheet
- [ ] Налоговые отчеты
- [ ] Inventory management (опционально)

---

### 20. Family Accounts
**Папка:** `lib/presentation/screens/family/`

- [ ] Доработать FamilyAccountScreen
- [ ] Реализовать роли:
  - [ ] Owner (полный доступ)
  - [ ] Admin (управление, кроме удаления)
  - [ ] Member (просмотр + добавление транзакций)
  - [ ] Child (ограниченный доступ)
- [ ] Приглашения участников
- [ ] Совместные бюджеты
- [ ] Activity log (кто что сделал)
- [ ] Лимиты для членов семьи
- [ ] Уведомления о действиях

---

### 21. Advanced Analytics

- [ ] Сравнение с предыдущими периодами
- [ ] Тренды (восходящий/нисходящий)
- [ ] Аномалии в расходах
- [ ] Прогнозирование будущих расходов (ML)
- [ ] Benchmark с другими пользователями (анонимно)
- [ ] Рекомендации по оптимизации
- [ ] Custom reports builder

---

### 22. AI Improvements

- [ ] Персонализация AI под пользователя
- [ ] Обучение на истории диалогов
- [ ] Context awareness (знать текущий экран)
- [ ] Proactive insights:
  - "Вы обычно тратите больше в выходные"
  - "Пора пополнить счет для оплаты аренды"
- [ ] Финансовый коуч режим
- [ ] Categorization suggestions
- [ ] Merchant recognition

---

### 23. Social Features (опционально)

- [ ] Split bill между друзьями
- [ ] P2P переводы
- [ ] Запросы денег
- [ ] Shared expenses tracking
- [ ] Интеграция с Telegram/WhatsApp

---

### 24. Investments Module (будущее)

- [ ] Портфель инвестиций
- [ ] Stocks tracking
- [ ] Crypto tracking
- [ ] Mutual funds
- [ ] Real-time quotes
- [ ] Portfolio analytics

---

## 🛠 ТЕХНИЧЕСКИЕ УЛУЧШЕНИЯ

### 25. Performance

- [ ] Pagination для больших списков
- [ ] Lazy loading
- [ ] Image caching optimization
- [ ] Memory profiling
- [ ] Reduce app size:
  - [ ] Remove unused assets
  - [ ] Compress images
  - [ ] Split APKs
- [ ] Flutter performance profiling
- [ ] 60fps everywhere

---

### 26. Code Quality

- [ ] Linting rules (very_good_analysis используется)
- [ ] Code formatting (dart format)
- [ ] Unused code removal
- [ ] Dead code elimination
- [ ] Extract duplicated code
- [ ] Refactor large files (>500 lines)
- [ ] Add comments и documentation
- [ ] Generate API docs (dartdoc)

---

### 27. DevOps

- [ ] CI/CD setup:
  - [ ] GitHub Actions или Codemagic
  - [ ] Automated tests on PR
  - [ ] Automated builds
  - [ ] Beta distribution
- [ ] Environments:
  - [ ] Development
  - [ ] Staging
  - [ ] Production
- [ ] Secrets management
- [ ] Version bumping automation
- [ ] Changelog generation

---

### 28. Monitoring

- [ ] Crashlytics setup
- [ ] Analytics events:
  - [ ] Screen views
  - [ ] Button clicks
  - [ ] Errors
  - [ ] Feature usage
- [ ] Performance monitoring:
  - [ ] App start time
  - [ ] Screen load time
  - [ ] API response time
- [ ] User feedback система
- [ ] In-app debugging (только dev)

---

## 📄 ДОКУМЕНТАЦИЯ

### 29. Создать документы:

- [ ] **README.md** (обновить)
  - [ ] Описание проекта
  - [ ] Features список
  - [ ] Screenshots
  - [ ] Installation guide
  - [ ] Quick start
  
- [ ] **API_SETUP.md**
  - [ ] Как получить OpenAI key
  - [ ] Как получить Currency API key
  - [ ] Firebase setup guide
  - [ ] Bank API credentials
  
- [ ] **CONTRIBUTING.md**
  - [ ] Code style guide
  - [ ] PR процесс
  - [ ] Branch naming
  - [ ] Commit messages
  
- [ ] **ARCHITECTURE.md**
  - [ ] Clean Architecture объяснение
  - [ ] Folder structure
  - [ ] Data flow
  - [ ] State management
  
- [ ] **TESTING.md**
  - [ ] Как запускать тесты
  - [ ] Coverage reports
  - [ ] E2E testing guide
  
- [ ] **DEPLOYMENT.md**
  - [ ] Build процесс
  - [ ] App Store submission
  - [ ] Google Play submission
  - [ ] CI/CD setup
  
- [ ] **SECURITY.md**
  - [ ] Security policy
  - [ ] Vulnerability reporting
  - [ ] Security best practices
  
- [ ] **CHANGELOG.md**
  - [ ] Version history
  - [ ] Release notes

---

## ⏰ ПРИОРИТИЗАЦИЯ

### Sprint 1 (Неделя 1-2): КРИТИЧНО
- Environment setup
- Firebase integration
- Authentication fix
- Push notifications base

### Sprint 2 (Неделя 3-4): ВЫСОКИЙ
- Bank integration research
- UI TODO fixes
- Navigation refactor
- Testing начало

### Sprint 3 (Неделя 5-6): ВЫСОКИЙ
- OCR implementation
- Speech services
- Localization
- Bank API integration (начало)

### Sprint 4 (Неделя 7-8): СРЕДНИЙ
- Budgets полностью
- Recurring payments automation
- Export/Import
- Onboarding

### Sprint 5+ (Неделя 9+): НИЗКИЙ
- Business features
- Family accounts
- Advanced analytics
- AI improvements

---

## 🎯 SUCCESS CRITERIA

### MVP+ (Минимум для релиза):
- ✅ Все критичные TODO закрыты
- ✅ Firebase интеграция работает
- ✅ Push notifications
- ✅ Bank API integration (хотя бы с 2-3 банками)
- ✅ Тесты coverage >50%
- ✅ Нет критичных багов
- ✅ Performance приемлемый
- ✅ Security базовый уровень

### Full Release:
- ✅ Все высокоприоритетные TODO
- ✅ OCR + Speech
- ✅ Локализация (3 языка)
- ✅ Полная документация
- ✅ Coverage >70%
- ✅ Bank integration со всеми банками
- ✅ Security advanced

---

**Последнее обновление:** 3 декабря 2025  
**Maintainer:** Development Team
