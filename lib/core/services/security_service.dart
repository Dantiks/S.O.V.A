import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';

class SecurityService {
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;
  late final encrypt.Encrypter _encrypter;
  late final encrypt.IV _iv;

  SecurityService({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication() {
    _initializeEncryption();
  }

  void _initializeEncryption() {
    // Generate a secure key for AES-256 encryption
    final key = encrypt.Key.fromLength(32);
    _iv = encrypt.IV.fromLength(16);
    _encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  }

  // Biometric Authentication
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics({
    String reason = 'Authenticate to access S.O.V.A',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // PIN Code Management
  Future<void> savePinCode(String pin) async {
    try {
      final hashedPin = _hashPin(pin);
      print('Хеш PIN: $hashedPin');
      await _secureStorage.write(key: 'pin_code', value: hashedPin);
      print('PIN записан в secure storage');
    } catch (e) {
      print('Ошибка в savePinCode: $e');
      rethrow;
    }
  }

  Future<bool> verifyPinCode(String pin) async {
    final storedHash = await _secureStorage.read(key: 'pin_code');
    if (storedHash == null) return false;
    return storedHash == _hashPin(pin);
  }

  Future<bool> hasPinCode() async {
    final pin = await _secureStorage.read(key: 'pin_code');
    return pin != null;
  }

  Future<void> deletePinCode() async {
    await _secureStorage.delete(key: 'pin_code');
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Data Encryption/Decryption
  String encryptData(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  String decryptData(String encryptedText) {
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  // Secure Storage Operations
  Future<void> writeSecure(String key, String value) async {
    final encrypted = encryptData(value);
    await _secureStorage.write(key: key, value: encrypted);
  }

  Future<String?> readSecure(String key) async {
    final encrypted = await _secureStorage.read(key: key);
    if (encrypted == null) return null;
    try {
      return decryptData(encrypted);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearAllSecure() async {
    await _secureStorage.deleteAll();
  }

  // Token Management
  Future<void> saveAuthToken(String token) async {
    await writeSecure('auth_token', token);
  }

  Future<String?> getAuthToken() async {
    return await readSecure('auth_token');
  }

  Future<void> deleteAuthToken() async {
    await deleteSecure('auth_token');
  }

  // Session Management
  Future<void> saveSession(Map<String, dynamic> sessionData) async {
    final jsonString = jsonEncode(sessionData);
    await writeSecure('session_data', jsonString);
  }

  Future<Map<String, dynamic>?> getSession() async {
    final jsonString = await readSecure('session_data');
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await deleteSecure('session_data');
    await deleteAuthToken();
  }

  // Security Checks
  bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }

  String generateSecureToken({int length = 32}) {
    final random = encrypt.SecureRandom(length);
    final bytes = random.bytes;
    return base64Url.encode(bytes);
  }

  // Anti-tampering
  Future<bool> verifyAppIntegrity() async {
    // In production, implement certificate pinning and integrity checks
    // This is a placeholder for production implementation
    return true;
  }

  // Failed Login Attempts Management
  static const String _failedAttemptsKey = 'failed_attempts';
  static const String _lockoutTimeKey = 'lockout_time';
  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);

  /// Получить количество неудачных попыток входа
  Future<int> get failedAttempts async {
    final attemptsStr = await _secureStorage.read(key: _failedAttemptsKey);
    return int.tryParse(attemptsStr ?? '0') ?? 0;
  }

  /// Записать неудачную попытку входа
  Future<void> recordFailedAttempt() async {
    final currentAttempts = await failedAttempts;
    final newAttempts = currentAttempts + 1;
    
    await _secureStorage.write(
      key: _failedAttemptsKey,
      value: newAttempts.toString(),
    );

    // Если достигнут лимит, блокируем аккаунт
    if (newAttempts >= _maxFailedAttempts) {
      final lockoutTime = DateTime.now().add(_lockoutDuration);
      await _secureStorage.write(
        key: _lockoutTimeKey,
        value: lockoutTime.toIso8601String(),
      );
    }
  }

  /// Сбросить счетчик неудачных попыток
  Future<void> resetFailedAttempts() async {
    await _secureStorage.delete(key: _failedAttemptsKey);
    await _secureStorage.delete(key: _lockoutTimeKey);
  }

  /// Проверить, заблокирован ли аккаунт
  Future<bool> isAccountLocked() async {
    final lockoutTimeStr = await _secureStorage.read(key: _lockoutTimeKey);
    if (lockoutTimeStr == null) return false;

    try {
      final lockoutTime = DateTime.parse(lockoutTimeStr);
      final now = DateTime.now();

      if (now.isBefore(lockoutTime)) {
        return true;
      } else {
        // Время блокировки истекло, сбрасываем
        await resetFailedAttempts();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Получить оставшееся время блокировки
  Future<Duration?> getRemainingLockoutTime() async {
    final lockoutTimeStr = await _secureStorage.read(key: _lockoutTimeKey);
    if (lockoutTimeStr == null) return null;

    try {
      final lockoutTime = DateTime.parse(lockoutTimeStr);
      final now = DateTime.now();

      if (now.isBefore(lockoutTime)) {
        return lockoutTime.difference(now);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Получить количество оставшихся попыток
  Future<int> getRemainingAttempts() async {
    final attempts = await failedAttempts;
    final remaining = _maxFailedAttempts - attempts;
    return remaining > 0 ? remaining : 0;
  }
}
