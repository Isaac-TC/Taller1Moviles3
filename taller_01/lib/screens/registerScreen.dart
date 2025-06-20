import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ─────────── CONTROLLERS ───────────
  final nameController      = TextEditingController();
  final lastNameController  = TextEditingController();
  final ageController       = TextEditingController();
  final idController        = TextEditingController();
  final emailController     = TextEditingController();
  final passwordController  = TextEditingController();

  XFile? imagen;

  void cambiarImagen(XFile nueva) => setState(() => imagen = nueva);

  Future<void> abrirGaleria() async {
    final sel = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (sel != null) cambiarImagen(sel);
  }

  Future<void> abrirCamara() async {
    final sel = await ImagePicker().pickImage(source: ImageSource.camera);
    if (sel != null) cambiarImagen(sel);
  }

  // ─────────── SUBIR AVATAR ───────────
  Future<String?> subirImagenASupabase(String uid) async {
    if (imagen == null) return null;
    try {
      final supabase = Supabase.instance.client;
      final storage  = supabase.storage.from('personajes');
      final path     = 'users/$uid.jpg';

      await storage.upload(
        path,
        File(imagen!.path),
        fileOptions: const FileOptions(upsert: true),
      );
      return storage.getPublicUrl(path);
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      return null;
    }
  }

  // ─────────── REGISTRO ───────────
  Future<void> handleRegister(BuildContext ctx) async {
    final name     = nameController.text.trim();
    final lastName = lastNameController.text.trim();
    final age      = ageController.text.trim();
    final ced      = idController.text.trim();
    final email    = emailController.text.trim();
    final pass     = passwordController.text.trim();

    if ([name, lastName, age, ced, email, pass].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }
    if (imagen == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Selecciona una imagen de perfil')),
      );
      return;
    }

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      final uid       = cred.user!.uid;
      final avatarUrl = await subirImagenASupabase(uid);

      await FirebaseDatabase.instance
          .ref('personas/$uid')
          .set({
            'name': name,
            'lastname': lastName,
            'age': int.tryParse(age),
            'cedula': ced,
            'email': email,
            'avatar': avatarUrl ?? '',
          });

      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Registro completado')),
      );
      if (mounted) Navigator.pushReplacementNamed(ctx, '/');
    } on FirebaseAuthException catch (e) {
      var msg = 'Error al registrar';
      if (e.code == 'email-already-in-use') msg = 'El correo ya está registrado';
      if (e.code == 'invalid-email')        msg = 'Correo no válido';
      if (e.code == 'weak-password')        msg = 'Contraseña muy débil';
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // ─────────── UI ───────────
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Registro', style: TextStyle(color: Colors.white)),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.redAccent, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(90),
                  child: imagen == null
                      ? Container(
                          width: 180,
                          height: 180,
                          color: Colors.grey[800],
                          child: const Icon(Icons.person,
                              size: 100, color: Colors.white54),
                        )
                      : Image.file(File(imagen!.path),
                          width: 180, height: 180, fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_library,
                          color: Colors.redAccent),
                      onPressed: abrirGaleria,
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.redAccent),
                      onPressed: abrirCamara,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Campos
                _campo(nameController, 'Nombres'),
                const SizedBox(height: 10),
                _campo(lastNameController, 'Apellidos'),
                const SizedBox(height: 10),
                _campo(ageController, 'Edad', tipo: TextInputType.number),
                const SizedBox(height: 10),
                _campo(idController, 'Cédula'),
                const SizedBox(height: 10),
                _campo(emailController, 'Correo'),
                const SizedBox(height: 10),
                _campo(passwordController, 'Contraseña',
                    isPassword: true),

                const SizedBox(height: 28),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () => handleRegister(context),
                  child: const Text('Registrarse'),
                ),
              ],
            ),
          ),
        ),
      );

  // ─────────── HELPER INPUT ───────────
  Widget _campo(TextEditingController c, String h,
      {TextInputType tipo = TextInputType.text, bool isPassword = false}) {
    return TextField(
      controller: c,
      keyboardType: tipo,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.redAccent,
      decoration: InputDecoration(
        labelText: h,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey[900],
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
