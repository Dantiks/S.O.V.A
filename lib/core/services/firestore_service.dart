import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

/// Сервис для работы с Cloud Firestore
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  /// Названия коллекций
  static const String usersCollection = 'users';
  static const String accountsCollection = 'accounts';
  static const String transactionsCollection = 'transactions';
  static const String goalsCollection = 'goals';
  static const String budgetsCollection = 'budgets';
  static const String recurringCollection = 'recurring';
  static const String categoriesCollection = 'categories';

  // ==================== CRUD операции ====================

  /// Создание документа
  Future<String> createDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      DocumentReference docRef;
      
      if (documentId != null) {
        docRef = _firestore.collection(collection).doc(documentId);
        await docRef.set(data);
      } else {
        docRef = await _firestore.collection(collection).add(data);
      }
      
      _logger.i('✅ Document created in $collection: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger.e('❌ Create document error in $collection', error: e);
      rethrow;
    }
  }

  /// Чтение документа
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      
      if (!doc.exists) {
        _logger.w('⚠️ Document not found: $collection/$documentId');
        return null;
      }
      
      return doc.data();
    } catch (e) {
      _logger.e('❌ Get document error: $collection/$documentId', error: e);
      rethrow;
    }
  }

  /// Обновление документа
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
      _logger.i('✅ Document updated: $collection/$documentId');
    } catch (e) {
      _logger.e('❌ Update document error: $collection/$documentId', error: e);
      rethrow;
    }
  }

  /// Удаление документа
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
      _logger.i('✅ Document deleted: $collection/$documentId');
    } catch (e) {
      _logger.e('❌ Delete document error: $collection/$documentId', error: e);
      rethrow;
    }
  }

  /// Получение всех документов коллекции
  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      _logger.e('❌ Get collection error: $collection', error: e);
      rethrow;
    }
  }

  /// Получение документов с фильтром
  Future<List<Map<String, dynamic>>> queryCollection({
    required String collection,
    String? field,
    dynamic isEqualTo,
    dynamic isGreaterThan,
    dynamic isLessThan,
    List<dynamic>? whereIn,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (field != null) {
        if (isEqualTo != null) {
          query = query.where(field, isEqualTo: isEqualTo);
        }
        if (isGreaterThan != null) {
          query = query.where(field, isGreaterThan: isGreaterThan);
        }
        if (isLessThan != null) {
          query = query.where(field, isLessThan: isLessThan);
        }
        if (whereIn != null) {
          query = query.where(field, whereIn: whereIn);
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      _logger.e('❌ Query collection error: $collection', error: e);
      rethrow;
    }
  }

  // ==================== Пользователи ====================

  /// Создание/обновление профиля пользователя
  Future<void> saveUserProfile({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .set(userData, SetOptions(merge: true));
      
      _logger.i('✅ User profile saved: $userId');
    } catch (e) {
      _logger.e('❌ Save user profile error', error: e);
      rethrow;
    }
  }

  /// Получение профиля пользователя
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    return getDocument(
      collection: usersCollection,
      documentId: userId,
    );
  }

  // ==================== Счета ====================

  /// Получение счетов пользователя
  Future<List<Map<String, dynamic>>> getUserAccounts(String userId) async {
    return queryCollection(
      collection: accountsCollection,
      field: 'userId',
      isEqualTo: userId,
    );
  }

  /// Синхронизация счетов
  Future<void> syncAccounts({
    required String userId,
    required List<Map<String, dynamic>> accounts,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final account in accounts) {
        final docRef = _firestore
            .collection(accountsCollection)
            .doc(account['id'] as String?);
        
        batch.set(docRef, {
          ...account,
          'userId': userId,
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      _logger.i('✅ Accounts synced: ${accounts.length} accounts');
    } catch (e) {
      _logger.e('❌ Sync accounts error', error: e);
      rethrow;
    }
  }

  // ==================== Транзакции ====================

  /// Получение транзакций пользователя
  Future<List<Map<String, dynamic>>> getUserTransactions({
    required String userId,
    int? limit,
  }) async {
    return queryCollection(
      collection: transactionsCollection,
      field: 'userId',
      isEqualTo: userId,
      orderBy: 'date',
      descending: true,
      limit: limit,
    );
  }

  /// Синхронизация транзакций
  Future<void> syncTransactions({
    required String userId,
    required List<Map<String, dynamic>> transactions,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final transaction in transactions) {
        final docRef = _firestore
            .collection(transactionsCollection)
            .doc(transaction['id'] as String?);
        
        batch.set(docRef, {
          ...transaction,
          'userId': userId,
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      _logger.i('✅ Transactions synced: ${transactions.length} transactions');
    } catch (e) {
      _logger.e('❌ Sync transactions error', error: e);
      rethrow;
    }
  }

  // ==================== Стримы (real-time) ====================

  /// Stream счетов пользователя
  Stream<List<Map<String, dynamic>>> watchUserAccounts(String userId) {
    return _firestore
        .collection(accountsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Stream транзакций пользователя
  Stream<List<Map<String, dynamic>>> watchUserTransactions(String userId) {
    return _firestore
        .collection(transactionsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ==================== Batch операции ====================

  /// Выполнение batch операций
  Future<void> executeBatch(
    void Function(WriteBatch batch) operations,
  ) async {
    try {
      final batch = _firestore.batch();
      operations(batch);
      await batch.commit();
      _logger.i('✅ Batch operations completed');
    } catch (e) {
      _logger.e('❌ Batch operations error', error: e);
      rethrow;
    }
  }

  // ==================== Утилиты ====================

  /// Проверка существования документа
  Future<bool> documentExists({
    required String collection,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      return doc.exists;
    } catch (e) {
      _logger.e('❌ Check document exists error', error: e);
      return false;
    }
  }

  /// Получение timestamp сервера
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Включение offline persistence (только для мобильных)
  Future<void> enablePersistence() async {
    try {
      await _firestore.settings.persistenceEnabled;
      _logger.i('✅ Firestore persistence enabled');
    } catch (e) {
      _logger.e('❌ Enable persistence error', error: e);
    }
  }

  /// Очистка кеша
  Future<void> clearPersistence() async {
    try {
      await _firestore.clearPersistence();
      _logger.i('✅ Firestore cache cleared');
    } catch (e) {
      _logger.e('❌ Clear persistence error', error: e);
    }
  }
}
