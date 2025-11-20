import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sova/core/utils/result.dart';
import 'package:sova/data/datasources/auth_remote_datasource.dart';
import 'package:sova/data/repositories/auth_repository_impl.dart';
import 'package:sova/domain/entities/user_entity.dart';
import 'package:sova/domain/repositories/auth_repository.dart';

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthRemoteDataSourceImpl());
});

// Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

// Current User Provider
final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  final result = await repository.getCurrentUser();
  return result.dataOrNull;
});

// Auth Controller
class AuthController extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.loading()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    state = const AsyncValue.loading();
    final result = await _repository.getCurrentUser();
    
    result.when(
      success: (user) => state = AsyncValue.data(user),
      failure: (message, code) => state = AsyncValue.error(
        message,
        StackTrace.current,
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    
    final result = await _repository.signInWithGoogle();
    
    result.when(
      success: (user) => state = AsyncValue.data(user),
      failure: (message, code) => state = AsyncValue.error(
        message,
        StackTrace.current,
      ),
    );
  }

  Future<void> signOut() async {
    final result = await _repository.signOut();
    
    result.when(
      success: (_) => state = const AsyncValue.data(null),
      failure: (message, code) => state = AsyncValue.error(
        message,
        StackTrace.current,
      ),
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserEntity?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});
