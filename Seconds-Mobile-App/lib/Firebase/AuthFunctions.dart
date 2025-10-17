import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _googleSignIn = GoogleSignIn.instance;
final _firestore = FirebaseFirestore.instance;

class GoogleAuthService {
  bool _isGoogleSignInInitialized = false;

  GoogleAuthService() {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      print('Failed to initialize Google Sign-In: $e');
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  Future<dynamic> signInWithGoogleFirebase(String role, String organizationName) async {
    try {
      await _ensureGoogleSignInInitialized();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );

      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email']);

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      print(userCredential.user!.uid);

      dynamic result = await createOrSignInUser(userCredential.user!.uid, role, organizationName);

      return result;
    } on PlatformException catch (err) {
      if (err.code == 'sign_in_canceled') {
        return "Sign in cancelled";
      } else {
        return "Error signing in";
      }
    } catch (e) {
      return "Error signing in";
    }
  }
}

class EmailAuthService {
  Future<dynamic> registerUserEmailPassword(String email, String password) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return cred;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

Future<void> signOutUser() async {
  await _firebaseAuth.signOut();
  await _googleSignIn.signOut();
}

Future<dynamic> createOrSignInUser(
  String userId,
  String role,
  String organizationName,
) async {
  try {
    final userDocRef = _firestore.collection('users').doc(userId);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) {

      if (role != "" && role != null) {

        final userData = {
          'userId': userId,
          'role': role,
          'organizationName': organizationName,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await userDocRef.set(userData);
        print('Created new user document for $userId with role $role');

        return userData;
      }

      return "Create Account Instead"; 
    } else {
      print('User document already exists for $userId');
      return userDoc.data() as Map<String, dynamic>;
    }
  } catch (e) {
    print('Error in createOrSignInUser: $e');
    rethrow;
  }
}