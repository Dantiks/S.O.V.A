import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sova/data/repositories/auth_repository_impl.dart';
import 'package:sova/data/datasources/auth_remote_datasource.dart';
import 'package:sova/domain/entities/user_entity.dart';
import 'package:sova/core/utils/failure.dart';

@GenerateMocks([AuthRemoteDataSource])
import 'auth_repository_test.mocks.dart';

void main() {
  group('AuthRepository', () {
    late AuthRepositoryImpl repository;
    late MockAuthRemoteDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockAuthRemoteDataSource();
      repository = AuthRepositoryImpl(mockDataSource);
    });

    group('signInWithGoogle', () {
      test('should return UserEntity on successful sign in', () async {
        // Arrange
        final testUser = UserEntity(
          id: 'test-id',
          email: 'test@example.com',
          displayName: 'Test User',
          photoUrl: 'https://example.com/photo.jpg',
          createdAt: DateTime.now(),
        );

        when(mockDataSource.signInWithGoogle())
            .thenAnswer((_) async => testUser);

        // Act
        final result = await repository.signInWithGoogle();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (user) {
            expect(user.id, equals(testUser.id));
            expect(user.email, equals(testUser.email));
          },
        );
        verify(mockDataSource.signInWithGoogle()).called(1);
      });

      test('should return Failure on error', () async {
        // Arrange
        when(mockDataSource.signInWithGoogle())
            .thenThrow(Exception('Sign in failed'));

        // Act
        final result = await repository.signInWithGoogle();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
          (user) => fail('Should not return user'),
        );
      });
    });

    group('signOut', () {
      test('should complete successfully', () async {
        // Arrange
        when(mockDataSource.signOut()).thenAnswer((_) async => {});

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result.isRight(), true);
        verify(mockDataSource.signOut()).called(1);
      });

      test('should return Failure on error', () async {
        // Arrange
        when(mockDataSource.signOut())
            .thenThrow(Exception('Sign out failed'));

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result.isLeft(), true);
      });
    });

    group('getCurrentUser', () {
      test('should return current user if signed in', () async {
        // Arrange
        final testUser = UserEntity(
          id: 'test-id',
          email: 'test@example.com',
          displayName: 'Test User',
          photoUrl: null,
          createdAt: DateTime.now(),
        );

        when(mockDataSource.getCurrentUser())
            .thenAnswer((_) async => testUser);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (user) => expect(user, isNotNull),
        );
      });

      test('should return null if not signed in', () async {
        // Arrange
        when(mockDataSource.getCurrentUser()).thenAnswer((_) async => null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (user) => expect(user, isNull),
        );
      });
    });
  });
}
