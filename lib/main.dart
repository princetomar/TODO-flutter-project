import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:task_app/constants/project_constants.dart';
import 'package:task_app/view/splash_screen_view.dart';
import 'package:task_app/viewmodels/auth_view_model.dart';
import 'package:task_app/viewmodels/task_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: PROJECT_CONSTANTS.apiKey,
      appId: PROJECT_CONSTANTS.appId,
      messagingSenderId: PROJECT_CONSTANTS.messagingSenderId,
      projectId: PROJECT_CONSTANTS.projectId,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoViewModel()),
        ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProvider(
        create: (context) => TodoViewModel(),
        child: SplashScreen(),
      ),
    );
  }
}
