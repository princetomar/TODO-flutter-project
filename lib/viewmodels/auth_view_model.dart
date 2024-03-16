import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task_app/constants/navigation_constants.dart';
import 'package:task_app/services/auth_service.dart';
import 'package:task_app/view/task_list_view.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  GoogleSignInAccount? _user;
  late String userId;
  bool _isUserLoggedIn = false;

  GoogleSignInAccount? get user => _user;
  bool get isUserLoggedIn => _isUserLoggedIn;

  Future<void> initialize() async {
    _user = await _authService.googleSignIn.currentUser;
    if (_user != null) {
      userId = _user!.id;
      _isUserLoggedIn = true;
      print("USER ID :  ${_user!.id}");

      notifyListeners();
    }
  }

  Future<bool> isUserAuthenticated() async {
    return _authService.googleSignIn.currentUser != null;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    await _authService.signInWithGoogle();
    await initialize();
    nextScreenAndRemoveCurrent(context,
        TodoListView(userId: _authService.googleSignIn!.currentUser!.id!));
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _authService.signOut(context);
      _user = null;
      userId = '';
      _isUserLoggedIn = false;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
}
