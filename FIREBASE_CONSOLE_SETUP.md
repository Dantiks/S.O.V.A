# 🔥 Quick Setup: Firebase Console

## 🚀 Быстрая настройка через Firebase Console

**Firebase проект:** `sova-166a6`  
**URL:** https://console.firebase.google.com/project/sova-166a6

---

## ⚡ Шаги настройки (5-10 минут)

### 1. ✅ Authentication Setup

#### Откройте: Authentication → Sign-in method

**Email/Password:**
- [x] Нажмите на **Email/Password**
- [x] **Enable** → включить
- [x] **Save**

**Google Sign-In:**
- [x] Нажмите на **Google**
- [x] **Enable** → включить
- [x] **Project support email** → выберите email
- [x] **Save**

**Результат:** Пользователи смогут регистрироваться через email или Google

---

### 2. ✅ Firestore Security Rules

#### Откройте: Firestore Database → Rules

**Скопируйте и вставьте:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    match /users/{userId} {
      allow read, write: if isOwner(userId);
    }
    
    match /accounts/{accountId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isOwner(request.resource.data.userId);
    }
    
    match /transactions/{transactionId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isOwner(request.resource.data.userId);
    }
    
    match /goals/{goalId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isOwner(request.resource.data.userId);
    }
    
    match /budgets/{budgetId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isOwner(request.resource.data.userId);
    }
    
    match /recurring/{recurringId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isOwner(request.resource.data.userId);
    }
    
    match /categories/{categoryId} {
      allow read: if isSignedIn();
      allow write: if false;
    }
  }
}
```

**Нажмите:** Publish

**Результат:** Пользователи могут читать/писать только свои данные

---

### 3. ✅ Cloud Messaging (FCM)

#### Откройте: Cloud Messaging

**Проверьте:**
- [x] Cloud Messaging API включен
- [x] Server key существует (для backend)

**Для тестирования:**
1. Получите FCM Token из приложения
2. Нажмите **Send your first message**
3. Заполните title, body
4. **Target:** Single device → вставьте token
5. **Send**

**Результат:** Push уведомления работают

---

### 4. ✅ Firestore Database

#### Откройте: Firestore Database → Data

**Создайте коллекции (опционально для тестирования):**

1. **users** - профили пользователей
2. **accounts** - банковские счета
3. **transactions** - транзакции
4. **goals** - цели накоплений
5. **budgets** - бюджеты
6. **recurring** - регулярные платежи
7. **categories** - категории

**Результат:** Структура БД готова

---

### 5. ✅ Analytics (опционально)

#### Откройте: Analytics → Events

**Включите:**
- [x] Google Analytics
- [x] DebugView (для тестирования)

**Результат:** Аналитика событий включена

---

### 6. ✅ Crashlytics (опционально)

#### Откройте: Crashlytics

**Включите:**
- [x] Enable Crashlytics

**Результат:** Отслеживание ошибок включено

---

## 🔐 Google Sign-In: SHA-1 Setup

### Для работы Google Sign-In нужен SHA-1 fingerprint:

**1. Получите SHA-1:**
```bash
cd android
./gradlew signingReport
```

**2. Скопируйте SHA-1** из вывода:
```
SHA1: XX:XX:XX:XX:...
```

**3. Добавьте в Firebase:**
- Console → Project Settings
- Your apps → Android app
- Add fingerprint
- Вставьте SHA-1
- Save

**4. Скачайте новый google-services.json:**
- Download google-services.json
- Замените в `/android/app/google-services.json`

**5. Rebuild приложение:**
```bash
flutter clean
flutter run
```

---

## 📋 Проверка настройки

### После настройки проверьте:

**1. Authentication:**
```
✅ Email/Password включен
✅ Google включен
✅ Support email настроен
```

**2. Firestore:**
```
✅ Database создана
✅ Security Rules опубликованы
✅ Режим: Production
```

**3. Cloud Messaging:**
```
✅ FCM включен
✅ Можно отправить тестовое уведомление
```

**4. Analytics:**
```
✅ Google Analytics включен
✅ События логируются
```

---

## 🧪 Тестирование

### 1. Тест Authentication:

**Запустите приложение:**
```bash
flutter run
```

**В приложении:**
1. Откройте экран регистрации
2. Создайте аккаунт с email/password
3. Проверьте в Firebase Console → Authentication → Users

**Результат:** Пользователь появился в списке ✅

---

### 2. Тест Firestore:

**В приложении:**
1. Создайте транзакцию
2. Создайте цель накоплений

**В Firebase Console:**
1. Firestore → Data
2. Проверьте коллекции `transactions`, `goals`

**Результат:** Данные синхронизированы ✅

---

### 3. Тест Push Notifications:

**В приложении:**
1. Профиль → Настройки → Уведомления
2. Нажмите "Показать FCM Token"
3. Скопируйте токен

**В Firebase Console:**
1. Cloud Messaging → Send test message
2. Target: Single device
3. Вставьте token
4. Send

**Результат:** Уведомление получено ✅

---

## ⚠️ Важные настройки

### Production Security Rules:

**Для production используйте более строгие правила:**

```javascript
// Пример: ограничение размера документа
match /transactions/{id} {
  allow write: if isOwner(request.resource.data.userId)
    && request.resource.data.size() < 100000;  // макс 100KB
}

// Пример: валидация полей
match /accounts/{id} {
  allow write: if isOwner(request.resource.data.userId)
    && request.resource.data.keys().hasAll(['name', 'balance', 'currency'])
    && request.resource.data.balance is number;
}
```

### Rate Limiting:

```javascript
// Ограничение частоты записи
match /transactions/{id} {
  allow write: if isOwner(request.resource.data.userId)
    && request.time > resource.data.lastUpdate + duration.value(1, 's');
}
```

---

## 🎯 Checklist

После выполнения всех шагов убедитесь:

- [ ] Authentication methods включены
- [ ] Firestore Security Rules опубликованы
- [ ] Cloud Messaging настроен
- [ ] SHA-1 добавлен (для Google Sign-In)
- [ ] google-services.json обновлен
- [ ] Приложение протестировано
- [ ] Пользователь может регистрироваться
- [ ] Данные синхронизируются с Firestore
- [ ] Push уведомления приходят

---

## 📞 Поддержка

**Проблемы?**

1. Проверьте [Firebase Status](https://status.firebase.google.com)
2. Смотрите логи в Android Studio / Xcode
3. Проверьте [FlutterFire Docs](https://firebase.flutter.dev)

**Полная документация:** См. `FIREBASE_SETUP.md`

---

**⏱ Время настройки:** 5-10 минут  
**Сложность:** ⭐⭐ Легко  
**Статус:** ✅ Готово
