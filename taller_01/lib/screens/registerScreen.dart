import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();
  final idController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    idController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleRegister(BuildContext context) async {
    final name = nameController.text.trim();
    final lastName = lastNameController.text.trim();
    final age = ageController.text.trim();
    final id = idController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if ([name, lastName, age, id, email, password].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final ref = FirebaseDatabase.instance.ref();
      await ref.child('personas').child(uid).set({
        'name': name,
        'lastname': lastName,
        'age': int.tryParse(age),
        'cedula': id,
        'email': email,
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Registro exitoso'),
          content: const Text('Tu cuenta ha sido creada correctamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Error al registrar';
      if (e.code == 'email-already-in-use') {
        errorMsg = 'El correo ya está registrado';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Correo no válido';
      } else if (e.code == 'weak-password') {
        errorMsg = 'La contraseña es muy débil';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombres')),
              const SizedBox(height: 8),
              TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Apellidos')),
              const SizedBox(height: 8),
              TextField(controller: ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Edad')),
              const SizedBox(height: 8),
              TextField(controller: idController, decoration: const InputDecoration(labelText: 'Cédula')),
              const SizedBox(height: 8),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Correo')),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => handleRegister(context),
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
