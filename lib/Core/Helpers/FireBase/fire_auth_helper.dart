import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireBaseHelper {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<dynamic> signInWithEmailAndPassword(
    String email,
    String password,
    String expectedRole,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        print('User ID: $uid');

        final doc = await _firestore.collection('users').doc(uid).get();

        if (doc.exists) {
          final actualRole = doc.data()?['role'];

          if (actualRole == expectedRole) {
            return userCredential.user;
          } else {
            await _auth.signOut();
            return 'This account is not registered as a $expectedRole.';
          }
        } else {
          await _auth.signOut();
          return 'User data not found in Firestore.';
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is badly formatted.';
      } else if (e.code == 'too-many-requests') {
        return 'Too many requests. Try again later.';
      } else {
        return 'Login failed: ${e.message}';
      }
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
