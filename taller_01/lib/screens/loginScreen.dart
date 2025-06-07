import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void handleLogin(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text('Iniciar sesión', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 32),
                TextField(controller: emailController, decoration: InputDecoration(labelText: 'Correo')),
                SizedBox(height: 16),
                TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Contraseña'), obscureText: true),
                SizedBox(height: 32),
                ElevatedButton(onPressed: () => handleLogin(context), child: Text('Ingresar')),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('¿Eres nuevo? Regístrate'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
