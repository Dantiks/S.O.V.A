import 'package:hive_flutter/hive_flutter.dart';
import 'package:sova/core/constants/app_constants.dart';
import 'package:sova/core/services/security_service.dart';

class StorageService {
  final SecurityService _securityService;
  
  StorageService(this._securityService);

  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Initialize encrypted boxes
    final encryptionKey = await _getEncryptionKey();
    
    await Hive.openBox(
      AppConstants.userBox,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    
    await Hive.openBox(
      AppConstants.accountsBox,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    
    await Hive.openBox(
      AppConstants.transactionsBox,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    
    await Hive.openBox(
      AppConstants.categoriesBox,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    
    await Hive.openBox(
      AppConstants.settingsBox,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    
    await Hive.openBox(
      AppConstants.chatHistoryBox,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Future<List<int>> _getEncryptionKey() async {
    final keyString = await _securityService.readSecure('hive_encryption_key');
    
    if (keyString != null) {
      return keyString.codeUnits;
    }
    
    // Generate new key
    final newKey = Hive.generateSecureKey();
    await _securityService.writeSecure(
      'hive_encryption_key',
      String.fromCharCodes(newKey),
    );
    return newKey;
  }

  Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  Future<void> clearAll() async {
    await Hive.box(AppConstants.userBox).clear();
    await Hive.box(AppConstants.accountsBox).clear();
    await Hive.box(AppConstants.transactionsBox).clear();
    await Hive.box(AppConstants.categoriesBox).clear();
    await Hive.box(AppConstants.chatHistoryBox).clear();
    // Keep settings box
  }

  Future<void> close() async {
    await Hive.close();
  }
}
