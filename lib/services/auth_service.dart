import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_app/constants/navigation_constants.dart';
import 'package:task_app/view/auth_screen_view.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult =
            await auth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          await _updateUserData(user);
        }

        return user;
      }
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<void> _updateUserData(User user) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    saveUserDataLocally(user);
    return userRef.set({
      'uid': user.uid,
      'displayName': user.displayName,
      'email': user.email,
      'photoUrl': user.photoURL,
    }, SetOptions(merge: true));
  }

  Future<void> saveUserDataLocally(User user) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("isUserLoggedIn", true);
      prefs.setString("uid", user.uid);
      prefs.setString("userName", user.displayName!);
      prefs.setString("setEmail", user.email!);
      prefs.setString("profilePhoto", user.photoURL!);
    } catch (error) {
      print(error);
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await auth.signOut();
      await googleSignIn.disconnect();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      nextScreenAndRemoveCurrent(context, AuthScreen());
    } catch (error) {
      print(error);
    }
  }
}
