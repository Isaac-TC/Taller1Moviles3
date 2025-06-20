import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_01/screens/splash_screen.dart';
import 'package:taller_01/screens/loginScreen.dart';
import 'package:taller_01/screens/registerScreen.dart';
import 'package:taller_01/screens/homeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp();

  // Inicializa Supabase
  await Supabase.initialize(
    url: 'https://bytkeraqgtcfberoksnn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5dGtlcmFxZ3RjZmJlcm9rc25uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2ODM2OTMsImV4cCI6MjA2NTI1OTY5M30.hZUJ95AA-0SQfo_de3t9XWAQlyc-hX6Hi_zdLkKEBmI',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Registro',
      debugShowCheckedModeBanner: false,
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
      initialRoute: '/',
      routes: {
        '/':         (_) => const SplashScreen(),
        '/login':    (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home':     (_) => const HomeScreen(),
      },
    );
  }
}
