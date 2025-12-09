import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finer/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> signInWithGoogle();
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Stream<User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign In was cancelled');
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to sign in');
      }

      // Create or update user in Firestore
      final userEntity = UserEntity(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL,
        phoneNumber: user.phoneNumber,
        emailVerified: user.emailVerified,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _saveUserToFirestore(userEntity);

      return userEntity;
    } catch (e) {
      throw Exception('Google Sign In failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) return null;

      return UserEntity.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> _saveUserToFirestore(UserEntity user) async {
    await _firestore.collection('users').doc(user.id).set(
          user.toJson(),
          SetOptions(merge: true),
        );
  }
}
