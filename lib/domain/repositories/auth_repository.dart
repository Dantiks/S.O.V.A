import 'package:firebase_auth/firebase_auth.dart';
import 'package:sova/core/utils/result.dart';
import 'package:sova/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> signInWithGoogle();
  Future<Result<void>> signOut();
  Future<Result<UserEntity?>> getCurrentUser();
  Stream<User?> get authStateChanges;
}
