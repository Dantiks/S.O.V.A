import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// Background message handler для Firebase Cloud Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger().i('Background message received: ${message.messageId}');
}

/// Сервис управления уведомлениями
/// Поддерживает Firebase Cloud Messaging и локальные уведомления
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  bool _isInitialized = false;
  String? _fcmToken;

  /// Callback для обработки уведомлений при тапе
  Function(String?)? onNotificationTapped;

  /// Инициализация сервиса уведомлений
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.w('NotificationService already initialized');
      return;
    }

    try {
      // 1. Запрос разрешений
      await _requestPermissions();

      // 2. Настройка Firebase Cloud Messaging
      await _setupFirebaseMessaging();

      // 3. Настройка локальных уведомлений
      await _setupLocalNotifications();

      // 4. Настройка обработчиков сообщений
      await _setupMessageHandlers();

      _isInitialized = true;
      _logger.i('✅ NotificationService initialized successfully');
    } catch (e, stack) {
      _logger.e('❌ Failed to initialize NotificationService', error: e, stackTrace: stack);
    }
  }

  /// Запрос разрешений на уведомления
  Future<bool> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    _logger.i('Notification permission status: ${settings.authorizationStatus}');
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Настройка Firebase Cloud Messaging
  Future<void> _setupFirebaseMessaging() async {
    // Регистрация background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Получение FCM токена
    _fcmToken = await _firebaseMessaging.getToken();
    _logger.i('FCM Token: $_fcmToken');

    // Сохранение токена
    if (_fcmToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', _fcmToken!);
    }

    // Слушаем обновления токена
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      _logger.i('FCM Token refreshed: $newToken');
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('fcm_token', newToken);
      });
    });
  }

  /// Настройка локальных уведомлений
  Future<void> _setupLocalNotifications() async {
    // Android настройки
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS настройки (если потребуется в будущем)
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _logger.i('Local notification tapped: ${response.payload}');
        onNotificationTapped?.call(response.payload);
      },
    );

    // Создание notification channel для Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Создание каналов уведомлений для Android
  Future<void> _createNotificationChannels() async {
    const defaultChannel = AndroidNotificationChannel(
      'default_channel',
      'Общие уведомления',
      description: 'Общие уведомления приложения',
      importance: Importance.high,
      playSound: true,
    );

    const transactionChannel = AndroidNotificationChannel(
      'transaction_channel',
      'Транзакции',
      description: 'Уведомления о транзакциях',
      importance: Importance.high,
      playSound: true,
    );

    const budgetChannel = AndroidNotificationChannel(
      'budget_channel',
      'Бюджеты',
      description: 'Уведомления о бюджетах',
      importance: Importance.high,
      playSound: true,
    );

    const recurringChannel = AndroidNotificationChannel(
      'recurring_channel',
      'Регулярные платежи',
      description: 'Напоминания о регулярных платежах',
      importance: Importance.high,
      playSound: true,
    );

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(defaultChannel);
      await androidPlugin.createNotificationChannel(transactionChannel);
      await androidPlugin.createNotificationChannel(budgetChannel);
      await androidPlugin.createNotificationChannel(recurringChannel);
      _logger.i('✅ Notification channels created');
    }
  }

  /// Настройка обработчиков сообщений
  Future<void> _setupMessageHandlers() async {
    // Foreground messages (когда приложение открыто)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i('Foreground message received: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Background messages (когда приложение в фоне, но открыто)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.i('Notification opened from background: ${message.messageId}');
      _handleNotificationTap(message);
    });

    // Проверка, было ли приложение открыто через уведомление
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _logger.i('App opened from terminated state via notification');
      _handleNotificationTap(initialMessage);
    }
  }

  /// Показ локального уведомления
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null) return;

    // Определяем канал по типу уведомления
    String channelId = 'default_channel';
    if (message.data.containsKey('type')) {
      switch (message.data['type']) {
        case 'transaction':
          channelId = 'transaction_channel';
          break;
        case 'budget':
          channelId = 'budget_channel';
          break;
        case 'recurring':
          channelId = 'recurring_channel';
          break;
      }
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'default_channel' ? 'Общие уведомления' : 
        channelId == 'transaction_channel' ? 'Транзакции' :
        channelId == 'budget_channel' ? 'Бюджеты' : 'Регулярные платежи',
      importance: Importance.high,
      priority: Priority.high,
      icon: android?.smallIcon ?? '@mipmap/ic_launcher',
      playSound: true,
    );

    final details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data['route'],
    );
  }

  /// Обработка тапа по уведомлению
  void _handleNotificationTap(RemoteMessage message) {
    final route = message.data['route'] as String?;
    if (route != null) {
      onNotificationTapped?.call(route);
    }
  }

  /// Получение FCM токена
  Future<String?> getToken() async {
    return _fcmToken ?? await _firebaseMessaging.getToken();
  }

  /// Подписка на топик
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      _logger.i('Subscribed to topic: $topic');
    } catch (e) {
      _logger.e('Failed to subscribe to topic: $topic', error: e);
    }
  }

  /// Отписка от топика
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logger.i('Unsubscribed from topic: $topic');
    } catch (e) {
      _logger.e('Failed to unsubscribe from topic: $topic', error: e);
    }
  }

  /// Показ локального уведомления вручную
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'default_channel',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'default_channel' ? 'Общие уведомления' : 
        channelId == 'transaction_channel' ? 'Транзакции' :
        channelId == 'budget_channel' ? 'Бюджеты' : 'Регулярные платежи',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    final details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  /// Запланировать уведомление
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = 'default_channel',
  }) async {
    // Для Android 13+ требуется разрешение на уведомления
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
    }

    // Здесь можно добавить логику для scheduled notifications
    // Требует дополнительную настройку timezone
    _logger.w('Scheduled notifications not fully implemented yet');
  }

  /// Отмена уведомления
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Отмена всех уведомлений
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Проверка, разрешены ли уведомления
  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Удаление FCM токена (при выходе из аккаунта)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      _logger.i('FCM token deleted');
    } catch (e) {
      _logger.e('Failed to delete FCM token', error: e);
    }
  }
}
