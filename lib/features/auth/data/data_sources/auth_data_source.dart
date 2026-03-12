import '../models/auth_model.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/framework/failure.dart';

abstract class AuthDataSource {
  Future<AuthModel?> getCurrentUser();

  Future<AuthModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> sendEmailVerification();

  Future<void> saveUserProfile({required UserModel user});

  Future<UserModel?> getUserProfile({required String uid});

  Future<void> markProfileComplete({required String uid});

  Future<void> updateUserPresence({
    required String uid,
    required bool isOnline,
  });

  Future<void> deleteAccount({required String uid});

  Stream<AuthModel?> get authStateChanges;
}

@LazySingleton(as: AuthDataSource)
class AuthDataSourceImpl implements AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  const AuthDataSourceImpl(this._firebaseAuth, this._firestore);

  AuthModel _mapFirebaseUser(User user, {bool isProfileComplete = false}) {
    return AuthModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      emailVerified: user.emailVerified,
      isProfileComplete: isProfileComplete,
      createdAt: user.metadata.creationTime,
      lastSignInAt: user.metadata.lastSignInTime,
    );
  }

  Future<bool> _fetchIsProfileComplete(String uid) async {
    try {
      final doc = await _firestore
          .collection(_Collections.users)
          .doc(uid)
          .get();
      if (!doc.exists) return false;
      return doc.data()?[_UserFields.isProfileComplete] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AuthModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final isProfileComplete = await _fetchIsProfileComplete(user.uid);
      return _mapFirebaseUser(user, isProfileComplete: isProfileComplete);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  @override
  Future<AuthModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      await user.sendEmailVerification();

      return _mapFirebaseUser(user, isProfileComplete: false);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  @override
  Future<AuthModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;
      final isProfileComplete = await _fetchIsProfileComplete(user.uid);

      return _mapFirebaseUser(user, isProfileComplete: isProfileComplete);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;

      if (uid != null) {
        await updateUserPresence(uid: uid, isOnline: false);
      }

      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Failure(401, 'No user is signed in.');
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  @override
  Future<void> saveUserProfile({required UserModel user}) async {
    try {
      await _firestore
          .collection(_Collections.users)
          .doc(user.uid)
          .set(user.toFirestore(), SetOptions(merge: true));

      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(user.fullName);
        if (user.photoUrl != null) {
          await firebaseUser.updatePhotoURL(user.photoUrl);
        }
      }
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to save user profile.');
    }
  }

  @override
  Future<UserModel?> getUserProfile({required String uid}) async {
    try {
      final doc = await _firestore
          .collection(_Collections.users)
          .doc(uid)
          .get();

      if (!doc.exists || doc.data() == null) return null;

      return UserModel.fromFirestore(doc.data()!, uid);
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to fetch user profile.');
    }
  }

  @override
  Future<void> markProfileComplete({required String uid}) async {
    try {
      await _firestore.collection(_Collections.users).doc(uid).update({
        _UserFields.isProfileComplete: true,
      });
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to mark profile complete.');
    }
  }

  @override
  Future<void> updateUserPresence({
    required String uid,
    required bool isOnline,
  }) async {
    try {
      await _firestore.collection(_Collections.users).doc(uid).update({
        _UserFields.isOnline: isOnline,
        _UserFields.lastSeen: DateTime.now().millisecondsSinceEpoch,
      });
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to update presence.');
    }
  }

  @override
  Future<void> deleteAccount({required String uid}) async {
    try {
      await _firestore.collection(_Collections.users).doc(uid).delete();

      final user = _firebaseAuth.currentUser;
      if (user != null) await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on FirebaseException catch (e) {
      throw Failure(500, e.message ?? 'Failed to delete account.');
    }
  }

  @override
  Stream<AuthModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final isProfileComplete = await _fetchIsProfileComplete(user.uid);
      return _mapFirebaseUser(user, isProfileComplete: isProfileComplete);
    });
  }

  Failure _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Failure(401, 'This email is already registered.');
      case 'invalid-email':
        return Failure(401, 'The email address is not valid.');
      case 'weak-password':
        return Failure(401, 'The password is too weak.');
      case 'user-not-found':
        return Failure(401, 'No account found with this email.');
      case 'wrong-password':
        return Failure(401, 'Incorrect password. Please try again.');
      case 'user-disabled':
        return Failure(401, 'This account has been disabled.');
      case 'too-many-requests':
        return Failure(401, 'Too many attempts. Please try again later.');
      case 'network-request-failed':
        return Failure(401, 'Network error. Check your connection.');
      case 'requires-recent-login':
        return Failure(401, 'Please sign in again to continue.');
      default:
        return Failure(401, e.message ?? 'An unexpected error occurred.');
    }
  }
}



class _Collections {
  static const String users = 'users';
}

class _UserFields {
  static const String isProfileComplete = 'isProfileComplete';
  static const String isOnline = 'isOnline';
  static const String lastSeen = 'lastSeen';
}
