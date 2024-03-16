import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:task_app/view/splash_screen_view.dart';
import 'package:task_app/viewmodels/auth_view_model.dart';
import 'package:task_app/viewmodels/task_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await
      // Platform.isAndroid
      //     ?
      Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBheg5fQqKWFWwyatyVVQjRtA37IpSJmo4",
      appId: "1:494221319134:android:c17b17fa7f1324da465b4f",
      messagingSenderId: "494221319134",
      projectId: "todo-application-52dbd",
    ),
  );
  // Firebase.initializeApp();
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
