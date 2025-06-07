import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void handleRegister(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Registro exitoso! Inicia sesión.')),
      );
      Navigator.pop(context); // Vuelve al login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Completa todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'Correo')),
              SizedBox(height: 16),
              TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Contraseña'), obscureText: true),
              SizedBox(height: 32),
              ElevatedButton(onPressed: () => handleRegister(context), child: Text('Registrarse')),
            ],
          ),
        ),
      ),
    );
  }
}
