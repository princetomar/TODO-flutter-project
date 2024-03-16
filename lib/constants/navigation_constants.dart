import 'package:flutter/material.dart';

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenAndRemoveCurrent(context, page) {
  Navigator.pushAndRemoveUntil(
      // ignore: prefer_const_constructors
      context,
      // ignore: prefer_const_constructors
      MaterialPageRoute(builder: (context) => page),
      (route) => false);
}