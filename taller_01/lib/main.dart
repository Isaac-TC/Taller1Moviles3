import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:taller_01/screens/splash_screen.dart';   // ← NUEVO
import 'package:taller_01/screens/loginScreen.dart';
import 'package:taller_01/screens/registerScreen.dart';
import 'package:taller_01/screens/homeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Registro',                // (sin cambios)
      debugShowCheckedModeBanner: false,
      // mismo tema oscuro pero con rojo como color base
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        scaffoldBackgroundColor: Colors.black,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.redAccent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        ),
      ),

      // rutas (solo se añade Splash y se mueve Login)
      initialRoute: '/',                    // ahora muestra Splash primero
      routes: {
        '/':         (_) => const SplashScreen(), // ← NUEVO
        '/login':    (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home':     (_) => const HomeScreen(),
      },
    );
  }
}
