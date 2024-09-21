import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthHelper {
  AuthHelper._();

  static final AuthHelper authHelper = AuthHelper._();

  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static GoogleSignIn googleSignIn = GoogleSignIn();

  // Sign in as a guest user (anonymous)
  Future<Map<String, dynamic>> signInAsGuestUser() async {
    Map<String, dynamic> res = {};

    try {
      UserCredential userCredential = await firebaseAuth.signInAnonymously();
      User? user = userCredential.user;
      res['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e) {
        case "Network-request-failed":
          res['error'] = "NO Internet available";
          break;
        case "Operation-not-allowed":
          res['error'] = "This is displayed by admin";
          break;
        default:
          res['error'] = "${e.code}";
      }
    }
    return res;
  }

  // Sign up with email & password
  Future<Map<String, dynamic>> signUpUserWithEmailAndPassword(
      {required String email, required String password}) async {
    Map<String, dynamic> res = {};

    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      res['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e) {
        case "Network-request-failed":
          res['error'] = "NO Internet available";
          break;
        case "Operation-not-allowed":
          res['error'] = "This is displayed by admin";
          break;
        case "Weak-Password":
          res['error'] = "password must be greater than 6 letters..";
          break;
        case "email-already-in-use":
          res['error'] = "This email is already  exixts...";
          break;
        default:
          res['error'] = "${e.code}";
      }
    }
    return res;
  }

//signInWithEmailAndPassword
  Future<Map<String, dynamic>> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    Map<String, dynamic> res = {};

    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      res['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e) {
        case "Network-request-failed":
          res['error'] = "NO Internet available";
          break;
        case "Operation-not-allowed":
          res['error'] = "This is displayed by admin";
          break;
        case "Weak-Password":
          res['error'] = "password must be greater than 6 letters..";
          break;
        case "email-already-in-use":
          res['error'] = "This email is already  exixts...";
          break;
        default:
          res['error'] = "${e.code}";
      }
    }
    return res;
  }

  // Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    Map<String, dynamic> res = {};
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);

      User? user = userCredential.user;
      res['user'] = user;
    } catch (e) {
      res['error'] = "${e}";
    }
    return res;
  }

  Future<User?> updateUsername(String editUserName) async {
    User? user = firebaseAuth.currentUser;

    if (user != null) {
      await user.updateProfile(displayName: editUserName);
      await user.reload();
      user = firebaseAuth.currentUser;
      return user;
    }
    return null;
  }

  //updatePassword
  Future<Map<String, dynamic>> updatePassword(String editPassword) async {
    User? user = firebaseAuth.currentUser;
    Map<String, dynamic> res = {};
    if (user != null) {
      try {
        await user.updatePassword(editPassword);
        await user.reload();
        user = firebaseAuth.currentUser;
        res['val'] = true;
      } on FirebaseAuthException catch (e) {
        print("=========================");
        print("Failed to update password: ${e.code}");
        print("=========================");

        res['error'] = e.code;
      }
    } else {
      print("No user is signed in");
      res['error'] = false;
    }
    return res;
  }

  // Sign out
  Future<void> signOutUser() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }
}
