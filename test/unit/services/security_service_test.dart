import 'package:flutter_test/flutter_test.dart';
import 'package:finer/core/services/security_service.dart';

void main() {
  group('SecurityService', () {
    late SecurityService securityService;

    setUp(() {
      securityService = SecurityService();
    });

    group('PIN Validation', () {
      test('should validate correct PIN length', () {
        expect(securityService.isValidPinLength('1234'), true);
        expect(securityService.isValidPinLength('123456'), true);
        expect(securityService.isValidPinLength('12345'), true);
      });

      test('should reject invalid PIN length', () {
        expect(securityService.isValidPinLength('123'), false);
        expect(securityService.isValidPinLength('1234567'), false);
        expect(securityService.isValidPinLength(''), false);
      });

      test('should reject non-numeric PIN', () {
        expect(securityService.isValidPinLength('abcd'), false);
        expect(securityService.isValidPinLength('12a4'), false);
      });
    });

    group('PIN Hashing', () {
      test('should hash PIN consistently', () {
        final pin = '1234';
        final hash1 = securityService.hashPin(pin);
        final hash2 = securityService.hashPin(pin);
        
        expect(hash1, equals(hash2));
      });

      test('should produce different hashes for different PINs', () {
        final hash1 = securityService.hashPin('1234');
        final hash2 = securityService.hashPin('5678');
        
        expect(hash1, isNot(equals(hash2)));
      });

      test('should produce 64-character SHA-256 hash', () {
        final hash = securityService.hashPin('1234');
        expect(hash.length, equals(64));
      });
    });

    group('Encryption', () {
      test('should encrypt and decrypt data correctly', () {
        const originalData = 'Sensitive financial data';
        const key = 'my-secret-key-32-characters-long';
        
        final encrypted = securityService.encrypt(originalData, key);
        final decrypted = securityService.decrypt(encrypted, key);
        
        expect(decrypted, equals(originalData));
      });

      test('should produce different ciphertext for same plaintext', () {
        const data = 'Test data';
        const key = 'my-secret-key-32-characters-long';
        
        final encrypted1 = securityService.encrypt(data, key);
        final encrypted2 = securityService.encrypt(data, key);
        
        // Should be different due to IV
        expect(encrypted1, isNot(equals(encrypted2)));
      });

      test('should fail decryption with wrong key', () {
        const data = 'Secret';
        const key1 = 'key1-32-characters-long-string!!';
        const key2 = 'key2-32-characters-long-string!!';
        
        final encrypted = securityService.encrypt(data, key1);
        
        expect(
          () => securityService.decrypt(encrypted, key2),
          throwsException,
        );
      });
    });

    group('Biometric Authentication', () {
      test('should check biometric availability', () async {
        final isAvailable = await securityService.isBiometricAvailable();
        expect(isAvailable, isA<bool>());
      });

      test('should get available biometric types', () async {
        final types = await securityService.getAvailableBiometrics();
        expect(types, isA<List>());
      });
    });

    group('Session Management', () {
      test('should track failed login attempts', () {
        securityService.recordFailedAttempt();
        expect(securityService.failedAttempts, equals(1));
        
        securityService.recordFailedAttempt();
        expect(securityService.failedAttempts, equals(2));
      });

      test('should reset failed attempts on success', () {
        securityService.recordFailedAttempt();
        securityService.recordFailedAttempt();
        securityService.resetFailedAttempts();
        
        expect(securityService.failedAttempts, equals(0));
      });

      test('should lock account after max attempts', () {
        for (int i = 0; i < 5; i++) {
          securityService.recordFailedAttempt();
        }
        
        expect(securityService.isAccountLocked(), true);
      });

      test('should not lock before max attempts', () {
        for (int i = 0; i < 4; i++) {
          securityService.recordFailedAttempt();
        }
        
        expect(securityService.isAccountLocked(), false);
      });
    });
  });
}
