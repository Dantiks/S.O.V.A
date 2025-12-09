import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

/// Сервис для работы с Firebase Authentication
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

  /// Текущий пользователь
  User? get currentUser => _auth.currentUser;

  /// Stream изменений состояния аутентификации
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Stream изменений пользователя
  Stream<User?> get userChanges => _auth.userChanges();

  /// Регистрация с email и паролем
  Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _logger.i('✅ User registered: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      _logger.e('❌ Sign up error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('❌ Unexpected sign up error', error: e);
      rethrow;
    }
  }

  /// Вход с email и паролем
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _logger.i('✅ User signed in: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      _logger.e('❌ Sign in error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('❌ Unexpected sign in error', error: e);
      rethrow;
    }
  }

  /// Вход через Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _logger.w('⚠️ Google sign in cancelled');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      _logger.i('✅ User signed in with Google: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.e('❌ Google sign in error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('❌ Unexpected Google sign in error', error: e);
      rethrow;
    }
  }

  /// Выход из аккаунта
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      _logger.i('✅ User signed out');
    } catch (e) {
      _logger.e('❌ Sign out error', error: e);
      rethrow;
    }
  }

  /// Сброс пароля
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _logger.i('✅ Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      _logger.e('❌ Password reset error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('❌ Unexpected password reset error', error: e);
      rethrow;
    }
  }

  /// Обновление email
  Future<void> updateEmail(String newEmail) async {
    try {
      await currentUser?.updateEmail(newEmail);
      _logger.i('✅ Email updated to: $newEmail');
    } on FirebaseAuthException catch (e) {
      _logger.e('❌ Update email error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('❌ Unexpected update email error', error: e);
      rethrow;
    }
  }

  /// Обновление пароля
  Future<void> updatePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
      _logger.i('✅ Password updated');
    } on FirebaseAuthException catch (e) {
      _logger.e('❌ Update password error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('❌ Unexpected update password error', error: e);
      rethrow;
    }
  }

  /// Отправка письма для верификации email
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
      _logger.i('✅ Verification email sent');
    } on FirebaseAuthException catch (e) {
      _logger.e('❌ Send verification error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('❌ Unexpected verification error', error: e);
      rethrow;
    }
  }

  /// Удаление аккаунта
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
      _logger.i('✅ Account deleted');
    } on FirebaseAuthException catch (e) {
      _logger.e('❌ Delete account error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('❌ Unexpected delete account error', error: e);
      rethrow;
    }
  }

  /// Проверка, вошел ли пользователь
  bool get isSignedIn => currentUser != null;

  /// Проверка, верифицирован ли email
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Обработка исключений Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'email-already-in-use':
        return 'Email уже используется';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'weak-password':
        return 'Слишком слабый пароль';
      case 'operation-not-allowed':
        return 'Операция не разрешена';
      case 'user-disabled':
        return 'Аккаунт отключен';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение';
      case 'requires-recent-login':
        return 'Требуется повторный вход';
      default:
        return e.message ?? 'Произошла ошибка аутентификации';
    }
  }

  /// Повторная аутентификация пользователя
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw Exception('Пользователь не авторизован');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      _logger.i('✅ User reauthenticated');
    } on FirebaseAuthException catch (e) {
      _logger.e('❌ Reauthenticate error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('❌ Unexpected reauthenticate error', error: e);
      rethrow;
    }
  }

  /// Получение ID токена пользователя
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await currentUser?.getIdToken(forceRefresh);
    } catch (e) {
      _logger.e('❌ Get ID token error', error: e);
      return null;
    }
  }

  /// Обновление профиля пользователя
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.updatePhotoURL(photoURL);
      await currentUser?.reload();
      _logger.i('✅ Profile updated');
    } catch (e) {
      _logger.e('❌ Update profile error', error: e);
      rethrow;
    }
  }
}
