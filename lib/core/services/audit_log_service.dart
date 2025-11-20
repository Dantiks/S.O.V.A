import 'package:hive_flutter/hive_flutter.dart';

enum AuditEventType {
  login,
  logout,
  pinChange,
  settingsChange,
  accountAdded,
  accountRemoved,
  transactionCreated,
  transactionDeleted,
  dataExport,
}

class AuditLogEntry {
  final String id;
  final String userId;
  final AuditEventType eventType;
  final String description;
  final DateTime timestamp;
  final String? ipAddress;
  final String? deviceInfo;
  final Map<String, dynamic> metadata;

  AuditLogEntry({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.description,
    required this.timestamp,
    this.ipAddress,
    this.deviceInfo,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'eventType': eventType.name,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'ipAddress': ipAddress,
        'deviceInfo': deviceInfo,
        'metadata': metadata,
      };

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) => AuditLogEntry(
        id: json['id'],
        userId: json['userId'],
        eventType: AuditEventType.values.firstWhere((e) => e.name == json['eventType']),
        description: json['description'],
        timestamp: DateTime.parse(json['timestamp']),
        ipAddress: json['ipAddress'],
        deviceInfo: json['deviceInfo'],
        metadata: json['metadata'] ?? {},
      );
}

class AuditLogService {
  static const String _boxName = 'audit_logs';
  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  Future<void> log({
    required String userId,
    required AuditEventType eventType,
    required String description,
    String? ipAddress,
    String? deviceInfo,
    Map<String, dynamic>? metadata,
  }) async {
    await _ensureInitialized();

    final entry = AuditLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      eventType: eventType,
      description: description,
      timestamp: DateTime.now(),
      ipAddress: ipAddress,
      deviceInfo: deviceInfo,
      metadata: metadata ?? {},
    );

    await _box!.add(entry.toJson());
  }

  Future<List<AuditLogEntry>> getLogs({
    String? userId,
    AuditEventType? eventType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _ensureInitialized();

    final allLogs = _box!.values
        .map((json) => AuditLogEntry.fromJson(Map<String, dynamic>.from(json)))
        .toList();

    return allLogs.where((log) {
      if (userId != null && log.userId != userId) return false;
      if (eventType != null && log.eventType != eventType) return false;
      if (startDate != null && log.timestamp.isBefore(startDate)) return false;
      if (endDate != null && log.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> clearOldLogs({int daysToKeep = 90}) async {
    await _ensureInitialized();
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    
    final keysToDelete = <dynamic>[];
    for (var key in _box!.keys) {
      final log = AuditLogEntry.fromJson(Map<String, dynamic>.from(_box!.get(key)));
      if (log.timestamp.isBefore(cutoffDate)) {
        keysToDelete.add(key);
      }
    }
    
    await _box!.deleteAll(keysToDelete);
  }

  Future<void> _ensureInitialized() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
  }

  Future<void> dispose() async {
    await _box?.close();
  }
}
