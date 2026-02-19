import '../models/auth_model.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

abstract class AuthDataSource {
  /// Returns the current signed-in [AuthModel] or null if not authenticated.
  Future<AuthModel?> getCurrentUser();

  /// Signs up a new user with [email] and [password].
  /// Returns the created [AuthModel].
  Future<AuthModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs in an existing user with [email] and [password].
  /// Returns the signed-in [AuthModel].
  Future<AuthModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Sends a password reset email to [email].
  Future<void> sendPasswordResetEmail({required String email});

  /// Sends an email verification to the current user.
  Future<void> sendEmailVerification();

  /// Saves or updates the full user profile in Firestore after FillProfile.
  Future<void> saveUserProfile({required UserModel user});

  /// Fetches the [UserModel] from Firestore by [uid].
  Future<UserModel?> getUserProfile({required String uid});

  /// Marks the current user's profile as complete in both
  /// Firestore and the local [AuthModel].
  Future<void> markProfileComplete({required String uid});

  /// Updates the user's online presence (isOnline + lastSeen) in Firestore.
  Future<void> updateUserPresence({
    required String uid,
    required bool isOnline,
  });

  /// Deletes the current user's account from Firebase Auth and Firestore.
  Future<void> deleteAccount({required String uid});

  /// Stream that emits [AuthModel] whenever auth state changes
  /// (sign in, sign out, token refresh).
  Stream<AuthModel?> get authStateChanges;
}

// ─── Implementation ────────────────────────────────────────────────────────

@LazySingleton(as: AuthDataSource)
class AuthDataSourceImpl implements AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  const AuthDataSourceImpl(this._firebaseAuth, this._firestore);

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Converts a Firebase [User] into an [AuthModel].
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

  /// Fetches [isProfileComplete] flag from Firestore for [uid].
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

  // ─── getCurrentUser ───────────────────────────────────────────────────────

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

  // ─── signUpWithEmailAndPassword ───────────────────────────────────────────

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

      // Send verification email right after signup
      await user.sendEmailVerification();

      return _mapFirebaseUser(user, isProfileComplete: false);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  // ─── signInWithEmailAndPassword ───────────────────────────────────────────

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

  // ─── signOut ──────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;

      // Mark user offline before signing out
      if (uid != null) {
        await updateUserPresence(uid: uid, isOnline: false);
      }

      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  // ─── sendPasswordResetEmail ───────────────────────────────────────────────

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  // ─── sendEmailVerification ────────────────────────────────────────────────

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthException('No user is signed in.');
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  // ─── saveUserProfile ──────────────────────────────────────────────────────

  @override
  Future<void> saveUserProfile({required UserModel user}) async {
    try {
      await _firestore
          .collection(_Collections.users)
          .doc(user.uid)
          .set(user.toFirestore(), SetOptions(merge: true));

      // Also update Firebase Auth display name and photo
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(user.fullName);
        if (user.photoUrl != null) {
          await firebaseUser.updatePhotoURL(user.photoUrl);
        }
      }
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Failed to save user profile.');
    }
  }

  // ─── getUserProfile ───────────────────────────────────────────────────────

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
      throw FirestoreException(e.message ?? 'Failed to fetch user profile.');
    }
  }

  // ─── markProfileComplete ──────────────────────────────────────────────────

  @override
  Future<void> markProfileComplete({required String uid}) async {
    try {
      await _firestore.collection(_Collections.users).doc(uid).update({
        _UserFields.isProfileComplete: true,
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Failed to mark profile complete.');
    }
  }

  // ─── updateUserPresence ───────────────────────────────────────────────────

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
      throw FirestoreException(e.message ?? 'Failed to update presence.');
    }
  }

  // ─── deleteAccount ────────────────────────────────────────────────────────

  @override
  Future<void> deleteAccount({required String uid}) async {
    try {
      // Delete Firestore data first
      await _firestore.collection(_Collections.users).doc(uid).delete();

      // Then delete the Firebase Auth account
      final user = _firebaseAuth.currentUser;
      if (user != null) await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on FirebaseException catch (e) {
      throw FirestoreException(e.message ?? 'Failed to delete account.');
    }
  }

  // ─── authStateChanges ─────────────────────────────────────────────────────

  @override
  Stream<AuthModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final isProfileComplete = await _fetchIsProfileComplete(user.uid);
      return _mapFirebaseUser(user, isProfileComplete: isProfileComplete);
    });
  }

  // ─── Exception Mapper ─────────────────────────────────────────────────────

  AuthException _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const AuthException('This email is already registered.');
      case 'invalid-email':
        return const AuthException('The email address is not valid.');
      case 'weak-password':
        return const AuthException('The password is too weak.');
      case 'user-not-found':
        return const AuthException('No account found with this email.');
      case 'wrong-password':
        return const AuthException('Incorrect password. Please try again.');
      case 'user-disabled':
        return const AuthException('This account has been disabled.');
      case 'too-many-requests':
        return const AuthException(
          'Too many attempts. Please try again later.',
        );
      case 'network-request-failed':
        return const AuthException('Network error. Check your connection.');
      case 'requires-recent-login':
        return const AuthException('Please sign in again to continue.');
      default:
        return AuthException(e.message ?? 'An unexpected error occurred.');
    }
  }
}

// ─── Custom Exceptions ────────────────────────────────────────────────────

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class FirestoreException implements Exception {
  final String message;
  const FirestoreException(this.message);

  @override
  String toString() => 'FirestoreException: $message';
}
// ─── Firestore Collection Keys ─────────────────────────────────────────────

class _Collections {
  static const String users = 'users';
}

class _UserFields {
  static const String isProfileComplete = 'isProfileComplete';
  static const String isOnline = 'isOnline';
  static const String lastSeen = 'lastSeen';
}
