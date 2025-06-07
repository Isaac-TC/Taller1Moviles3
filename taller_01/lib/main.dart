import 'package:flutter/material.dart';
import 'package:taller_01/screens/homeScreen.dart';
import 'package:taller_01/screens/loginScreen.dart';
import 'package:taller_01/screens/registerScreen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => LoginScreen(),
      '/register': (context) => RegisterScreen(),
      '/home': (context) => HomeScreen(),
    },
  ));
}
