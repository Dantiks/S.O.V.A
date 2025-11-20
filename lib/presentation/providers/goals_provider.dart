import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sova/domain/entities/savings_goal_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sova/presentation/providers/transaction_provider.dart';

/// Провайдер для управления целями накоплений
class GoalsNotifier extends StateNotifier<List<SavingsGoalEntity>> {
  final FirebaseFirestore _firestore;
  final String userId;

  GoalsNotifier(this._firestore, this.userId) : super([]) {
    loadGoals();
  }

  /// Загрузка целей
  Future<void> loadGoals() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .get();

      state = snapshot.docs
          .map((doc) => SavingsGoalEntity.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Ошибка загрузки целей: $e');
    }
  }

  /// Добавление цели
  Future<void> addGoal(SavingsGoalEntity goal) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .add(goal.toJson());

      final newGoal = goal.copyWith(id: docRef.id);
      state = [...state, newGoal];
    } catch (e) {
      print('Ошибка добавления цели: $e');
      rethrow;
    }
  }

  /// Обновление цели
  Future<void> updateGoal(SavingsGoalEntity goal) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(goal.id)
          .update(goal.toJson());

      state = state.map((g) => g.id == goal.id ? goal : g).toList();
    } catch (e) {
      print('Ошибка обновления цели: $e');
      rethrow;
    }
  }

  /// Удаление цели
  Future<void> deleteGoal(String goalId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(goalId)
          .delete();

      state = state.where((g) => g.id != goalId).toList();
    } catch (e) {
      print('Ошибка удаления цели: $e');
      rethrow;
    }
  }

  /// Добавление средств к цели
  Future<void> addToGoal(String goalId, double amount) async {
    final goal = state.firstWhere((g) => g.id == goalId);
    final updatedGoal = goal.copyWith(
      currentAmount: goal.currentAmount + amount,
    );
    await updateGoal(updatedGoal);
  }

  /// Получение активных целей
  List<SavingsGoalEntity> getActiveGoals() {
    return state.where((g) => !g.isCompleted).toList();
  }

  /// Получение завершенных целей
  List<SavingsGoalEntity> getCompletedGoals() {
    return state.where((g) => g.isCompleted).toList();
  }
}

final goalsProvider =
    StateNotifierProvider<GoalsNotifier, List<SavingsGoalEntity>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return GoalsNotifier(FirebaseFirestore.instance, userId);
});
