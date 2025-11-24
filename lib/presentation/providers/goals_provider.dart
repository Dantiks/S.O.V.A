import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sova/domain/entities/goal_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Провайдер для управления целями накоплений с Hive
class GoalsNotifier extends StateNotifier<List<GoalEntity>> {
  static const String _boxName = 'goals';
  late Box<Map> _box;

  GoalsNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox<Map>(_boxName);
      await loadGoals();
    } catch (e) {
      print('Ошибка инициализации целей: $e');
    }
  }

  /// Загрузка целей из Hive
  Future<void> loadGoals() async {
    try {
      final goals = _box.values
          .map((data) => GoalEntity.fromJson(Map<String, dynamic>.from(data)))
          .toList();
      state = goals;
    } catch (e) {
      print('Ошибка загрузки целей: $e');
      state = [];
    }
  }

  /// Добавление новой цели
  Future<void> addGoal(GoalEntity goal) async {
    try {
      final id = goal.id.isEmpty ? _uuid.v4() : goal.id;
      final newGoal = goal.copyWith(id: id);
      
      await _box.put(id, newGoal.toJson());
      state = [...state, newGoal];
    } catch (e) {
      print('Ошибка добавления цели: $e');
      rethrow;
    }
  }

  /// Обновление цели
  Future<void> updateGoal(GoalEntity goal) async {
    try {
      await _box.put(goal.id, goal.toJson());
      state = state
          .map((g) => g.id == goal.id ? goal : g)
          .toList();
    } catch (e) {
      print('Ошибка обновления цели: $e');
      rethrow;
    }
  }

  /// Удаление цели
  Future<void> deleteGoal(String goalId) async {
    try {
      await _box.delete(goalId);
      state = state.where((g) => g.id != goalId).toList();
    } catch (e) {
      print('Ошибка удаления цели: $e');
      rethrow;
    }
  }

  /// Добавление средств к цели
  Future<void> addFunds(String goalId, double amount) async {
    final goal = state.firstWhere((g) => g.id == goalId);
    final newAmount = goal.currentAmount + amount;
    final isCompleted = newAmount >= goal.targetAmount;
    
    await updateGoal(goal.copyWith(
      currentAmount: newAmount,
      isCompleted: isCompleted,
    ));
  }

  /// Получение активных целей
  List<GoalEntity> getActiveGoals() {
    return state.where((g) => !g.isCompleted).toList();
  }

  /// Получение завершенных целей
  List<GoalEntity> getCompletedGoals() {
    return state.where((g) => g.isCompleted).toList();
  }

  /// Расчет общего прогресса
  double getTotalProgress() {
    if (state.isEmpty) return 0.0;
    final totalCurrent = state.fold(0.0, (sum, g) => sum + g.currentAmount);
    final totalTarget = state.fold(0.0, (sum, g) => sum + g.targetAmount);
    return totalTarget > 0 ? (totalCurrent / totalTarget) * 100 : 0.0;
  }
}

final goalsProvider =
    StateNotifierProvider<GoalsNotifier, List<GoalEntity>>((ref) {
  return GoalsNotifier();
});
