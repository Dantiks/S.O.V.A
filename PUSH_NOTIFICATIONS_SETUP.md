# 🔔 Настройка Push Уведомлений для S.O.V.A

**Статус:** ✅ Настроено для Android

---

## 📋 Что было сделано

### 1. ✅ Зависимости
- Раскомментированы пакеты в `pubspec.yaml`:
  - `firebase_messaging: ^14.7.9`
  - `firebase_crashlytics: ^3.4.9`
  - `flutter_local_notifications: ^16.3.0`

### 2. ✅ NotificationService
Полностью реализован сервис (`lib/core/services/notification_service.dart`) с поддержкой:
- Firebase Cloud Messaging (FCM)
- Локальные уведомления
- 4 канала уведомлений:
  - `default_channel` - Общие уведомления
  - `transaction_channel` - Транзакции
  - `budget_channel` - Бюджеты
  - `recurring_channel` - Регулярные платежи
- Background message handler
- Foreground notifications
- Notification tapping
- FCM token management

### 3. ✅ Android Configuration
**AndroidManifest.xml:**
- Добавлены permissions:
  - `INTERNET`
  - `POST_NOTIFICATIONS` (Android 13+)
  - `VIBRATE`
  - `RECEIVE_BOOT_COMPLETED`
  - `WAKE_LOCK`
- Настроен Firebase Messaging Service
- Добавлены meta-data для иконки и цвета уведомлений

**colors.xml:**
- Добавлен цвет уведомлений: `#7A3DF2` (фиолетовый - основной цвет приложения)

### 4. ✅ Интеграция в main.dart
- Инициализация Firebase
- Инициализация NotificationService при старте приложения

### 5. ✅ UI для управления уведомлениями
**NotificationSettingsScreen** обновлен с функциями:
- Настройка типов уведомлений (транзакции, цели, бюджеты и т.д.)
- Настройка звука и вибрации
- **Тестирование:**
  - Кнопка "Отправить тестовое уведомление"
  - Кнопка "Показать FCM Token"

---

## 🚀 Как использовать

### Для разработчиков:

1. **Запустите приложение:**
```bash
flutter run
```

2. **Откройте настройки уведомлений:**
   - Профиль → Настройки → Уведомления

3. **Протестируйте уведомления:**
   - Нажмите "Отправить тестовое уведомление"
   - Вы должны увидеть уведомление с текстом "🦉 S.O.V.A - Уведомления работают отлично! 🎉"

4. **Получите FCM Token:**
   - Нажмите "Показать FCM Token"
   - Скопируйте токен для тестирования через Firebase Console

---

## 🔥 Firebase Console - Отправка Push уведомлений

### Через Firebase Console:

1. Откройте [Firebase Console](https://console.firebase.google.com)
2. Выберите проект SOVA
3. Перейдите в **Cloud Messaging**
4. Нажмите **Send your first message**
5. Заполните:
   - **Notification title:** Тестовое уведомление
   - **Notification text:** Привет из Firebase!
6. Выберите Target:
   - **Single device** → вставьте FCM Token из приложения
   - или **Topic** → если настроили подписки
7. **Дополнительные опции:**
   - **Data payload:**
     ```json
     {
       "type": "transaction",
       "route": "/transactions"
     }
     ```
8. Нажмите **Test** или **Publish**

---

## 📱 Тестирование на устройстве

### Android:

1. **Foreground notifications** (приложение открыто):
   - Уведомление появится как локальное
   - Звук + вибрация

2. **Background notifications** (приложение в фоне):
   - Уведомление появится в шторке
   - При тапе откроется приложение

3. **Terminated notifications** (приложение закрыто):
   - Уведомление появится в шторке
   - При тапе приложение откроется

### Разрешения:
- Android 13+ автоматически запросит разрешение на уведомления
- Или вручную: Настройки → Приложения → S.O.V.A → Уведомления

---

## 🛠 API для отправки уведомлений

### Из кода (локальные):

```dart
final notificationService = NotificationService();

// Простое уведомление
await notificationService.showLocalNotification(
  id: 1,
  title: 'Новая транзакция',
  body: 'Списано 500 ₸',
  channelId: 'transaction_channel',
);

// С payload для навигации
await notificationService.showLocalNotification(
  id: 2,
  title: 'Бюджет превышен',
  body: 'Вы потратили 110% бюджета на еду',
  payload: '/budget/food',
  channelId: 'budget_channel',
);
```

### Через FCM API:

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "FCM_TOKEN_HERE",
    "notification": {
      "title": "Новая транзакция",
      "body": "Получено 1000 ₸"
    },
    "data": {
      "type": "transaction",
      "route": "/transactions/123"
    }
  }'
```

---

## 🎯 Каналы уведомлений

### 1. default_channel (Общие)
- Важность: High
- Звук: ✅
- Использование: Общие уведомления

### 2. transaction_channel (Транзакции)
- Важность: High
- Звук: ✅
- Использование: Новые транзакции, списания, поступления

### 3. budget_channel (Бюджеты)
- Важность: High
- Звук: ✅
- Использование: Превышение бюджета, предупреждения

### 4. recurring_channel (Регулярные платежи)
- Важность: High
- Звук: ✅
- Использование: Напоминания о подписках, регулярных платежах

---

## 📋 Функции NotificationService

### Основные методы:

```dart
// Инициализация (вызывается в main.dart)
await notificationService.initialize();

// Получить FCM токен
String? token = await notificationService.getToken();

// Показать локальное уведомление
await notificationService.showLocalNotification(
  id: 1,
  title: 'Заголовок',
  body: 'Текст',
  channelId: 'default_channel',
);

// Подписаться на топик
await notificationService.subscribeToTopic('all_users');

// Отписаться от топика
await notificationService.unsubscribeFromTopic('all_users');

// Отменить уведомление
await notificationService.cancelNotification(1);

// Отменить все уведомления
await notificationService.cancelAllNotifications();

// Проверить разрешения
bool enabled = await notificationService.areNotificationsEnabled();

// Удалить токен (при выходе)
await notificationService.deleteToken();
```

---

## 🔮 Будущие улучшения

### Запланированные уведомления:
- [ ] Scheduled notifications (требует пакет `timezone`)
- [ ] Напоминания о регулярных платежах
- [ ] Ежедневные/еженедельные сводки

### Advanced features:
- [ ] Rich notifications с изображениями
- [ ] Action buttons (Quick reply)
- [ ] Notification grouping
- [ ] Custom sounds
- [ ] Priority notifications

### iOS Support:
- [ ] Настройка для iOS
- [ ] APNs certificates
- [ ] iOS notification categories

---

## ⚠️ Важные заметки

### Для production:

1. **Firebase Configuration:**
   - Убедитесь, что `google-services.json` актуален
   - Настройте server key в Firebase Console

2. **Permissions:**
   - Android 13+ требует runtime permission
   - Проверяйте разрешения перед отправкой

3. **Rate Limiting:**
   - Не отправляйте слишком много уведомлений
   - Используйте подписки на топики для массовых рассылок

4. **Privacy:**
   - Не отправляйте чувствительные данные в уведомлениях
   - Используйте data payload для деталей

5. **Testing:**
   - Тестируйте на реальных устройствах
   - Проверяйте все сценарии (foreground/background/terminated)

---

## 📞 Troubleshooting

### Уведомления не приходят:

1. Проверьте разрешения:
   ```dart
   bool enabled = await notificationService.areNotificationsEnabled();
   print('Notifications enabled: $enabled');
   ```

2. Проверьте FCM токен:
   ```dart
   String? token = await notificationService.getToken();
   print('FCM Token: $token');
   ```

3. Проверьте Firebase Console:
   - Cloud Messaging настроен?
   - Server key правильный?

4. Проверьте логи:
   ```bash
   flutter logs
   ```

### Ошибки инициализации:

- Убедитесь, что Firebase правильно настроен
- Проверьте `google-services.json`
- Проверьте AndroidManifest.xml permissions

---

## ✅ Checklist

- [x] Пакеты установлены
- [x] NotificationService реализован
- [x] Android permissions настроены
- [x] Firebase initialized в main.dart
- [x] NotificationService initialized в main.dart
- [x] UI для настроек создан
- [x] Тестирование добавлено
- [ ] iOS configuration (будущее)
- [ ] Scheduled notifications (будущее)

---

**Дата создания:** 8 декабря 2025  
**Версия:** 1.0.0  
**Статус:** ✅ Готово для Android
