import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/core/services/cache_service.dart';
import 'package:finer/core/services/connectivity_service.dart';

/// Queue item for offline operations
class SyncQueueItem {
  final String id;
  final String type; // 'transaction', 'account', 'update', etc.
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  SyncQueueItem({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'retryCount': retryCount,
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) => SyncQueueItem(
        id: json['id'],
        type: json['type'],
        data: json['data'],
        timestamp: DateTime.parse(json['timestamp']),
        retryCount: json['retryCount'] ?? 0,
      );

  SyncQueueItem copyWith({int? retryCount}) => SyncQueueItem(
        id: id,
        type: type,
        data: data,
        timestamp: timestamp,
        retryCount: retryCount ?? this.retryCount,
      );
}

/// Service for syncing data between local and remote
class SyncService {
  static const String _syncQueueKey = 'sync_queue';
  static const int _maxRetries = 3;
  static const Duration _cacheMaxAge = Duration(hours: 24);

  final CacheService _cacheService;
  final ConnectivityService _connectivityService;

  SyncService(this._cacheService, this._connectivityService);

  /// Add operation to sync queue
  Future<void> addToSyncQueue(SyncQueueItem item) async {
    final queue = await getSyncQueue();
    queue.add(item);
    await _saveSyncQueue(queue);
  }

  /// Get current sync queue
  Future<List<SyncQueueItem>> getSyncQueue() async {
    final cached = await _cacheService.getCachedData(_syncQueueKey);
    if (cached == null) return [];

    final List<dynamic> items = cached is String 
        ? [] 
        : cached as List<dynamic>;
    
    return items
        .map((item) => SyncQueueItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Process sync queue
  Future<SyncResult> processSyncQueue() async {
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      return SyncResult(
        success: false,
        message: 'Нет подключения к интернету',
        itemsProcessed: 0,
      );
    }

    final queue = await getSyncQueue();
    if (queue.isEmpty) {
      return SyncResult(
        success: true,
        message: 'Очередь синхронизации пуста',
        itemsProcessed: 0,
      );
    }

    int processed = 0;
    int failed = 0;
    final List<SyncQueueItem> remainingItems = [];

    for (final item in queue) {
      try {
        // Process item based on type
        await _processQueueItem(item);
        processed++;
      } catch (e) {
        if (item.retryCount < _maxRetries) {
          // Add back to queue with incremented retry count
          remainingItems.add(item.copyWith(retryCount: item.retryCount + 1));
        }
        failed++;
      }
    }

    // Save remaining items
    await _saveSyncQueue(remainingItems);

    return SyncResult(
      success: failed == 0,
      message: 'Синхронизировано: $processed, Ошибок: $failed',
      itemsProcessed: processed,
      itemsFailed: failed,
    );
  }

  /// Process individual queue item
  Future<void> _processQueueItem(SyncQueueItem item) async {
    // This would call your actual API endpoints
    // For now, it's a placeholder
    switch (item.type) {
      case 'transaction':
        // await _apiService.createTransaction(item.data);
        break;
      case 'account':
        // await _apiService.updateAccount(item.data);
        break;
      case 'update':
        // await _apiService.updateData(item.data);
        break;
      default:
        throw Exception('Unknown sync item type: ${item.type}');
    }
  }

  /// Sync transactions from server
  Future<void> syncTransactions() async {
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      // Return cached data
      return;
    }

    try {
      // Fetch from API
      // final transactions = await _apiService.getTransactions();
      
      // Cache the data
      // await _cacheService.cacheTransactions(transactions);
    } catch (e) {
      // If sync fails, cached data will be used
      rethrow;
    }
  }

  /// Sync bank accounts from server
  Future<void> syncAccounts() async {
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) return;

    try {
      // Fetch from API
      // final accounts = await _apiService.getAccounts();
      
      // Cache the data
      // await _cacheService.cacheAccounts(accounts);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if data needs refresh
  Future<bool> needsRefresh() async {
    return await _cacheService.isCacheStale(_cacheMaxAge);
  }

  /// Force refresh all data
  Future<void> forceRefresh() async {
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('Нет подключения к интернету');
    }

    await Future.wait([
      syncTransactions(),
      syncAccounts(),
    ]);
  }

  /// Clear sync queue
  Future<void> clearSyncQueue() async {
    await _saveSyncQueue([]);
  }

  /// Save sync queue
  Future<void> _saveSyncQueue(List<SyncQueueItem> queue) async {
    final data = queue.map((item) => item.toJson()).toList();
    await _cacheService.cacheData(_syncQueueKey, data);
  }

  /// Get sync queue size
  Future<int> getSyncQueueSize() async {
    final queue = await getSyncQueue();
    return queue.length;
  }
}

/// Result of sync operation
class SyncResult {
  final bool success;
  final String message;
  final int itemsProcessed;
  final int itemsFailed;

  SyncResult({
    required this.success,
    required this.message,
    required this.itemsProcessed,
    this.itemsFailed = 0,
  });
}

/// Provider for sync service
final syncServiceProvider = Provider<SyncService>((ref) {
  final cacheService = ref.watch(cacheServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  return SyncService(cacheService, connectivityService);
});

/// Provider for sync queue size
final syncQueueSizeProvider = FutureProvider<int>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  return await syncService.getSyncQueueSize();
});
