# 🔥 Полная настройка Firebase для S.O.V.A

**Статус:** ✅ Настроено для Android  
**Дата:** 8 декабря 2025

---

## 📋 Что было настроено

### ✅ 1. Firebase Core
- **Firebase проект:** `sova-166a6`
- **Project ID:** `sova-166a6`
- **Project Number:** `800006114552`
- **Storage Bucket:** `sova-166a6.firebasestorage.app`

### ✅ 2. Android Configuration
- ✅ `google-services.json` - установлен в `/android/app/`
- ✅ Google Services plugin добавлен в `settings.gradle.kts`
- ✅ Google Services plugin применен в `app/build.gradle.kts`
- ✅ Package name: `com.example.sova`

### ✅ 3. Firebase Services
Подключенные сервисы:
- ✅ **Firebase Authentication** - авторизация пользователей
- ✅ **Cloud Firestore** - облачная база данных
- ✅ **Firebase Cloud Messaging (FCM)** - push уведомления
- ✅ **Firebase Crashlytics** - отслеживание ошибок
- ✅ **Firebase Analytics** - аналитика

### ✅ 4. Dart Services
Созданные сервисы:
- ✅ `firebase_auth_service.dart` - сервис аутентификации
- ✅ `firestore_service.dart` - сервис Firestore
- ✅ `notification_service.dart` - сервис уведомлений

### ✅ 5. Firebase Options
- ✅ `firebase_options.dart` - конфигурация для Android/iOS

---

## 🎯 Доступные функции

### 1. Firebase Authentication

#### Email/Password аутентификация:
```dart
final authService = FirebaseAuthService();

// Регистрация
await authService.signUpWithEmailPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Вход
await authService.signInWithEmailPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Выход
await authService.signOut();
```

#### Google Sign-In:
```dart
// Вход через Google
await authService.signInWithGoogle();
```

#### Управление профилем:
```dart
// Сброс пароля
await authService.sendPasswordResetEmail('user@example.com');

// Обновление профиля
await authService.updateProfile(
  displayName: 'John Doe',
  photoURL: 'https://example.com/photo.jpg',
);

// Отправка верификации email
await authService.sendEmailVerification();

// Удаление аккаунта
await authService.deleteAccount();
```

#### Проверки:
```dart
// Проверка входа
bool isSignedIn = authService.isSignedIn;

// Проверка верификации email
bool isVerified = authService.isEmailVerified;

// Текущий пользователь
User? user = authService.currentUser;

// Stream изменений
authService.authStateChanges.listen((user) {
  if (user != null) {
    print('User signed in: ${user.uid}');
  } else {
    print('User signed out');
  }
});
```

---

### 2. Cloud Firestore

#### CRUD операции:
```dart
final firestoreService = FirestoreService();

// Создание документа
await firestoreService.createDocument(
  collection: 'users',
  data: {
    'name': 'John Doe',
    'email': 'john@example.com',
    'createdAt': FieldValue.serverTimestamp(),
  },
  documentId: 'user123', // опционально
);

// Чтение документа
Map<String, dynamic>? userData = await firestoreService.getDocument(
  collection: 'users',
  documentId: 'user123',
);

// Обновление документа
await firestoreService.updateDocument(
  collection: 'users',
  documentId: 'user123',
  data: {'name': 'Jane Doe'},
);

// Удаление документа
await firestoreService.deleteDocument(
  collection: 'users',
  documentId: 'user123',
);
```

#### Запросы с фильтрами:
```dart
// Получить транзакции пользователя за последний месяц
final transactions = await firestoreService.queryCollection(
  collection: 'transactions',
  field: 'userId',
  isEqualTo: userId,
  orderBy: 'date',
  descending: true,
  limit: 50,
);

// С несколькими условиями
final expensiveTransactions = await firestoreService.queryCollection(
  collection: 'transactions',
  field: 'amount',
  isGreaterThan: 1000,
  orderBy: 'amount',
  descending: true,
);
```

#### Real-time streams:
```dart
// Слушать изменения счетов
firestoreService.watchUserAccounts(userId).listen((accounts) {
  print('Accounts updated: ${accounts.length}');
});

// Слушать изменения транзакций
firestoreService.watchUserTransactions(userId).listen((transactions) {
  print('Transactions updated: ${transactions.length}');
});
```

#### Batch операции:
```dart
await firestoreService.executeBatch((batch) {
  // Добавить несколько транзакций за один раз
  for (final transaction in transactions) {
    final docRef = FirebaseFirestore.instance
        .collection('transactions')
        .doc(transaction.id);
    batch.set(docRef, transaction.toJson());
  }
});
```

#### Утилиты:
```dart
// Проверить существование документа
bool exists = await firestoreService.documentExists(
  collection: 'users',
  documentId: 'user123',
);

// Включить offline persistence
await firestoreService.enablePersistence();

// Очистить кеш
await firestoreService.clearPersistence();
```

---

### 3. Коллекции Firestore

Предопределенные коллекции:
```dart
FirestoreService.usersCollection          // 'users'
FirestoreService.accountsCollection       // 'accounts'
FirestoreService.transactionsCollection   // 'transactions'
FirestoreService.goalsCollection          // 'goals'
FirestoreService.budgetsCollection        // 'budgets'
FirestoreService.recurringCollection      // 'recurring'
FirestoreService.categoriesCollection     // 'categories'
```

---

## 🔐 Security Rules (Firestore)

### Настройка в Firebase Console:

1. Откройте [Firebase Console](https://console.firebase.google.com)
2. Выберите проект `sova-166a6`
3. Перейдите в **Firestore Database** → **Rules**
4. Вставьте следующие правила:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Функция проверки авторизации
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Функция проверки владельца
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId);
    }
    
    // Accounts collection
    match /accounts/{accountId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isOwner(request.resource.data.userId);
    }
    
    // Transactions collection
    match /transactions/{transactionId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isOwner(request.resource.data.userId);
    }
    
    // Goals collection
    match /goals/{goalId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isOwner(request.resource.data.userId);
    }
    
    // Budgets collection
    match /budgets/{budgetId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isOwner(request.resource.data.userId);
    }
    
    // Recurring payments collection
    match /recurring/{recurringId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isOwner(request.resource.data.userId);
    }
    
    // Categories collection (публичные)
    match /categories/{categoryId} {
      allow read: if isSignedIn();
      allow write: if false; // Только админ через Firebase Console
    }
  }
}
```

5. Нажмите **Publish**

---

## 🔒 Authentication Methods

### Включение методов аутентификации:

1. Откройте [Firebase Console](https://console.firebase.google.com)
2. Выберите проект `sova-166a6`
3. Перейдите в **Authentication** → **Sign-in method**

### Email/Password:
- ✅ Включить **Email/Password**
- ✅ Включить **Email link (passwordless sign-in)** (опционально)

### Google Sign-In:
1. Включить **Google**
2. Указать **Project support email**
3. Сохранить

### Дополнительные методы (опционально):
- Phone (SMS)
- Apple
- Facebook
- Twitter

---

## 📊 Структура данных Firestore

### Users Collection (`users/{userId}`):
```json
{
  "uid": "user123",
  "email": "user@example.com",
  "displayName": "John Doe",
  "photoURL": "https://...",
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "settings": {
    "theme": "dark",
    "currency": "KGS",
    "language": "ru"
  }
}
```

### Accounts Collection (`accounts/{accountId}`):
```json
{
  "id": "acc123",
  "userId": "user123",
  "name": "Optima Bank",
  "type": "debit",
  "balance": 125450.00,
  "currency": "KGS",
  "bankName": "Optima Bank",
  "accountNumber": "**** 1234",
  "syncedAt": Timestamp,
  "createdAt": Timestamp
}
```

### Transactions Collection (`transactions/{transactionId}`):
```json
{
  "id": "txn123",
  "userId": "user123",
  "accountId": "acc123",
  "amount": 500.00,
  "type": "expense",
  "category": "food",
  "description": "Обед в кафе",
  "date": Timestamp,
  "createdAt": Timestamp,
  "currency": "KGS"
}
```

### Goals Collection (`goals/{goalId}`):
```json
{
  "id": "goal123",
  "userId": "user123",
  "name": "Отпуск",
  "targetAmount": 50000.00,
  "currentAmount": 15000.00,
  "deadline": Timestamp,
  "createdAt": Timestamp,
  "isCompleted": false
}
```

---

## 🚀 Тестирование

### 1. Проверка Firebase инициализации:

```bash
flutter run
```

Проверьте логи:
```
✅ Firebase initialized
✅ Notification Service initialized
```

### 2. Тестирование Authentication:

```dart
// В коде или через debug console
final authService = FirebaseAuthService();

// Создать тестового пользователя
await authService.signUpWithEmailPassword(
  email: 'test@sova.kg',
  password: 'test123456',
);

// Проверить вход
print('Signed in: ${authService.isSignedIn}');
print('User: ${authService.currentUser?.email}');
```

### 3. Тестирование Firestore:

```dart
final firestoreService = FirestoreService();

// Создать тестовый документ
await firestoreService.createDocument(
  collection: 'test',
  data: {'message': 'Hello Firebase!'},
);

// Прочитать
final doc = await firestoreService.getDocument(
  collection: 'test',
  documentId: 'docId',
);
print(doc);
```

---

## 📱 Firebase Console - Мониторинг

### Где смотреть данные:

1. **Authentication:**
   - Console → Authentication → Users
   - Все зарегистрированные пользователи

2. **Firestore:**
   - Console → Firestore Database → Data
   - Все коллекции и документы

3. **Cloud Messaging:**
   - Console → Cloud Messaging
   - История отправленных уведомлений

4. **Crashlytics:**
   - Console → Crashlytics
   - Ошибки и крэши приложения

5. **Analytics:**
   - Console → Analytics → Events
   - События пользователей

---

## 🔧 Troubleshooting

### Проблема: Firebase не инициализируется

**Решение:**
1. Проверьте `google-services.json` в `/android/app/`
2. Проверьте package name в `build.gradle.kts`: `com.example.sova`
3. Убедитесь, что Google Services plugin применен
4. Запустите `flutter clean && flutter pub get`

### Проблема: Authentication не работает

**Решение:**
1. Включите Email/Password в Firebase Console
2. Проверьте package name совпадает с Firebase
3. Для Google Sign-In - настройте SHA-1 fingerprint

### Проблема: Firestore permission denied

**Решение:**
1. Проверьте Security Rules в Firebase Console
2. Убедитесь, что пользователь авторизован
3. Проверьте userId в документах

### Проблема: Google Sign-In не работает

**Решение:**
1. Добавьте SHA-1 fingerprint в Firebase:
```bash
cd android
./gradlew signingReport
```
2. Скопируйте SHA-1 и добавьте в Firebase Console → Project Settings → Your apps
3. Скачайте новый `google-services.json`

---

## 📦 Зависимости

Используемые пакеты:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  google_sign_in: ^6.2.1
  cloud_firestore: ^4.13.6
  firebase_analytics: ^10.7.4
  firebase_messaging: ^14.7.9
  firebase_crashlytics: ^3.4.9
```

---

## 🎯 Next Steps

### Рекомендуемые улучшения:

1. **Синхронизация данных:**
   - Реализовать sync между Hive и Firestore
   - Offline-first architecture
   - Conflict resolution

2. **Advanced Authentication:**
   - Phone authentication
   - Apple Sign-In
   - Biometric + Firebase

3. **Cloud Functions:**
   - Автоматическая обработка транзакций
   - Scheduled tasks
   - Webhooks для банковских API

4. **Firebase Extensions:**
   - Image Resizing
   - Translate Text
   - Trigger Email

5. **Remote Config:**
   - Feature flags
   - A/B testing
   - Dynamic configuration

6. **Performance Monitoring:**
   - Screen traces
   - Network traces
   - Custom traces

---

## 📚 Полезные ссылки

- [Firebase Console](https://console.firebase.google.com/project/sova-166a6)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

---

## ✅ Checklist

- [x] Firebase проект создан
- [x] google-services.json настроен
- [x] Build.gradle настроен
- [x] firebase_options.dart создан
- [x] FirebaseAuthService реализован
- [x] FirestoreService реализован
- [x] Инициализация в main.dart
- [ ] Security Rules настроены (сделайте в Console)
- [ ] Authentication methods включены (сделайте в Console)
- [ ] Тестирование выполнено

---

**🎉 Firebase полностью настроен и готов к использованию!**

**Статус:** ✅ Готово для Android  
**Версия:** 1.0.0  
**Дата:** 8 декабря 2025
