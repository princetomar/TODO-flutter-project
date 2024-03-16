import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/viewmodels/auth_view_model.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await authViewModel.signInWithGoogle(context);
          },
          child: Text('Sign In with Google'),
        ),
      ),
    );
  }
}
