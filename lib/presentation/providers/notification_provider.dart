import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/domain/entities/notification_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Провайдер для управления уведомлениями с Hive
class NotificationNotifier extends StateNotifier<List<NotificationEntity>> {
  static const String _boxName = 'notifications';
  late Box<Map> _box;

  NotificationNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox<Map>(_boxName);
      await loadNotifications();
    } catch (e) {
      print('Ошибка инициализации уведомлений: $e');
    }
  }

  /// Загрузка уведомлений из Hive
  Future<void> loadNotifications() async {
    try {
      final notifications = _box.values
          .map((data) => NotificationEntity.fromJson(Map<String, dynamic>.from(data)))
          .toList();
      
      // Сортируем по дате (новые сверху)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = notifications;
    } catch (e) {
      print('Ошибка загрузки уведомлений: $e');
      state = [];
    }
  }

  /// Добавление нового уведомления
  Future<void> addNotification(NotificationEntity notification) async {
    try {
      final id = notification.id.isEmpty ? _uuid.v4() : notification.id;
      final newNotification = notification.copyWith(id: id);
      
      await _box.put(id, newNotification.toJson());
      state = [newNotification, ...state];
    } catch (e) {
      print('Ошибка добавления уведомления: $e');
      rethrow;
    }
  }

  /// Отметить уведомление как прочитанное
  Future<void> markAsRead(String notificationId) async {
    try {
      final notification = state.firstWhere((n) => n.id == notificationId);
      final updated = notification.copyWith(isRead: true);
      
      await _box.put(notificationId, updated.toJson());
      state = state.map((n) => n.id == notificationId ? updated : n).toList();
    } catch (e) {
      print('Ошибка отметки уведомления: $e');
      rethrow;
    }
  }

  /// Отметить все как прочитанные
  Future<void> markAllAsRead() async {
    try {
      for (final notification in state) {
        if (!notification.isRead) {
          final updated = notification.copyWith(isRead: true);
          await _box.put(notification.id, updated.toJson());
        }
      }
      state = state.map((n) => n.copyWith(isRead: true)).toList();
    } catch (e) {
      print('Ошибка отметки всех уведомлений: $e');
      rethrow;
    }
  }

  /// Удалить уведомление
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _box.delete(notificationId);
      state = state.where((n) => n.id != notificationId).toList();
    } catch (e) {
      print('Ошибка удаления уведомления: $e');
      rethrow;
    }
  }

  /// Очистить все прочитанные
  Future<void> clearRead() async {
    try {
      final readIds = state.where((n) => n.isRead).map((n) => n.id).toList();
      for (final id in readIds) {
        await _box.delete(id);
      }
      state = state.where((n) => !n.isRead).toList();
    } catch (e) {
      print('Ошибка очистки прочитанных: $e');
      rethrow;
    }
  }

  /// Получить количество непрочитанных
  int getUnreadCount() {
    return state.where((n) => !n.isRead).length;
  }

  /// Получить уведомления по типу
  List<NotificationEntity> getByType(NotificationType type) {
    return state.where((n) => n.type == type).toList();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationEntity>>((ref) {
  return NotificationNotifier();
});

/// Провайдер для количества непрочитанных уведомлений
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider);
  return notifications.where((n) => !n.isRead).length;
});
