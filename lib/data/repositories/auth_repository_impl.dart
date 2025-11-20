import 'package:sova/core/utils/result.dart';
import 'package:sova/data/datasources/auth_remote_datasource.dart';
import 'package:sova/domain/entities/user_entity.dart';
import 'package:sova/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<UserEntity>> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
      return Result.success(user);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Result.success(user);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Stream<User?> get authStateChanges => _remoteDataSource.authStateChanges;
}
