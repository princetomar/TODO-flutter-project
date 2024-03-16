import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_app/constants/navigation_constants.dart';
import 'package:task_app/view/auth_screen_view.dart';
import 'package:task_app/view/task_list_view.dart';
import 'package:task_app/viewmodels/auth_view_model.dart';
import 'package:task_app/viewmodels/task_view_model.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return FutureBuilder<void>(
      future: _checkUserLoggedIn(context, authViewModel),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            ),
          );
        } else {
          if (snapshot.hasError) {
            print("SNAPSHOT HAS ERROR : ${snapshot.error}");
            // Error occurred, navigate to AuthScreen
            return AuthScreen();
          }
          return Container();
        }
      },
    );
  }

  Future<void> _checkUserLoggedIn(
      BuildContext context, AuthViewModel authViewModel) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool? isUserLoggedIn = prefs.getBool("isUserLoggedIn");
      print("IS USER LOGGED IN : $isUserLoggedIn");
      if (isUserLoggedIn == true) {
        final String? userId = prefs.getString("uid");
        if (userId != null) {
          print("USER ID : $userId");
          TodoViewModel todoViewModel = TodoViewModel();
          todoViewModel.setUserId(userId);
          nextScreenAndRemoveCurrent(
              context,
              TodoListView(
                userId: userId,
              ));
        } else {
          // Handle the case where userId is null
          nextScreenAndRemoveCurrent(context, AuthScreen());
        }
      } else {
        nextScreenAndRemoveCurrent(context, AuthScreen());
      }
    } catch (error) {
      print("Error checking user logged in: $error");
      throw error;
    }
  }
}
