import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for caching data locally
class CacheService {
  static const String _cacheBoxName = 'app_cache';
  static const String _transactionsCacheKey = 'cached_transactions';
  static const String _accountsCacheKey = 'cached_accounts';
  static const String _analyticsCacheKey = 'cached_analytics';
  static const String _lastSyncKey = 'last_sync_time';
  
  Box? _cacheBox;

  /// Initialize cache service
  Future<void> init() async {
    _cacheBox = await Hive.openBox(_cacheBoxName);
  }

  /// Cache transactions
  Future<void> cacheTransactions(List<Map<String, dynamic>> transactions) async {
    await _ensureInitialized();
    await _cacheBox!.put(_transactionsCacheKey, jsonEncode(transactions));
    await _updateLastSync();
  }

  /// Get cached transactions
  Future<List<Map<String, dynamic>>?> getCachedTransactions() async {
    await _ensureInitialized();
    final cached = _cacheBox!.get(_transactionsCacheKey);
    if (cached == null) return null;
    
    final List<dynamic> decoded = jsonDecode(cached);
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Cache bank accounts
  Future<void> cacheAccounts(List<Map<String, dynamic>> accounts) async {
    await _ensureInitialized();
    await _cacheBox!.put(_accountsCacheKey, jsonEncode(accounts));
    await _updateLastSync();
  }

  /// Get cached accounts
  Future<List<Map<String, dynamic>>?> getCachedAccounts() async {
    await _ensureInitialized();
    final cached = _cacheBox!.get(_accountsCacheKey);
    if (cached == null) return null;
    
    final List<dynamic> decoded = jsonDecode(cached);
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Cache analytics data
  Future<void> cacheAnalytics(Map<String, dynamic> analytics) async {
    await _ensureInitialized();
    await _cacheBox!.put(_analyticsCacheKey, jsonEncode(analytics));
    await _updateLastSync();
  }

  /// Get cached analytics
  Future<Map<String, dynamic>?> getCachedAnalytics() async {
    await _ensureInitialized();
    final cached = _cacheBox!.get(_analyticsCacheKey);
    if (cached == null) return null;
    
    return jsonDecode(cached);
  }

  /// Cache any data with custom key
  Future<void> cacheData(String key, dynamic data) async {
    await _ensureInitialized();
    if (data is String) {
      await _cacheBox!.put(key, data);
    } else {
      await _cacheBox!.put(key, jsonEncode(data));
    }
  }

  /// Get cached data by key
  Future<dynamic> getCachedData(String key) async {
    await _ensureInitialized();
    return _cacheBox!.get(key);
  }

  /// Check if cache exists for key
  Future<bool> hasCachedData(String key) async {
    await _ensureInitialized();
    return _cacheBox!.containsKey(key);
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    await _ensureInitialized();
    final timestamp = _cacheBox!.get(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.parse(timestamp);
  }

  /// Check if cache is stale (older than specified duration)
  Future<bool> isCacheStale(Duration maxAge) async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;
    
    final age = DateTime.now().difference(lastSync);
    return age > maxAge;
  }

  /// Clear specific cache
  Future<void> clearCache(String key) async {
    await _ensureInitialized();
    await _cacheBox!.delete(key);
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    await _ensureInitialized();
    await _cacheBox!.clear();
  }

  /// Update last sync timestamp
  Future<void> _updateLastSync() async {
    await _cacheBox!.put(_lastSyncKey, DateTime.now().toIso8601String());
  }

  /// Ensure cache box is initialized
  Future<void> _ensureInitialized() async {
    if (_cacheBox == null || !_cacheBox!.isOpen) {
      await init();
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    await _ensureInitialized();
    int totalSize = 0;
    for (var key in _cacheBox!.keys) {
      final value = _cacheBox!.get(key);
      if (value is String) {
        totalSize += value.length;
      }
    }
    return totalSize;
  }

  /// Dispose cache service
  Future<void> dispose() async {
    await _cacheBox?.close();
  }
}

/// Provider for cache service
final cacheServiceProvider = Provider<CacheService>((ref) {
  final service = CacheService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for cache initialization
final cacheInitProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(cacheServiceProvider);
  await service.init();
});
