import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Map<String, dynamic> datos;
  const EditarPerfilScreen({super.key, required this.datos});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  late final DatabaseReference ref;

  late final TextEditingController nameController;
  late final TextEditingController lastNameController;
  late final TextEditingController cedulaController;
  late final TextEditingController emailController;
  late final TextEditingController edadController;

  String? imagenUrl;
  XFile?  nuevaImagen;

  @override
  void initState() {
    super.initState();
    ref = FirebaseDatabase.instance.ref('personas/${user.uid}');

    nameController     = TextEditingController(text: widget.datos['name']);
    lastNameController = TextEditingController(text: widget.datos['lastname']);
    cedulaController   = TextEditingController(text: widget.datos['cedula']);
    emailController    = TextEditingController(text: widget.datos['email']);
    edadController     = TextEditingController(text: widget.datos['age'].toString());
    imagenUrl          = widget.datos['avatar'];
  }

  // ─────────── IMAGEN ───────────
  Future<void> seleccionarImagen() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.redAccent),
              title: const Text('Seleccionar de galería'),
              onTap: () async {
                Navigator.pop(context);
                final sel = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (sel != null) setState(() => nuevaImagen = sel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text('Tomar una foto'),
              onTap: () async {
                Navigator.pop(context);
                final sel = await ImagePicker().pickImage(source: ImageSource.camera);
                if (sel != null) setState(() => nuevaImagen = sel);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> subirImagenASupabase(String uid) async {
    if (nuevaImagen == null) return null;
    try {
      final storage = Supabase.instance.client.storage.from('personajes');
      final path    = 'users/$uid.jpg';

      await storage.upload(path, File(nuevaImagen!.path),
          fileOptions: const FileOptions(upsert: true));

      return '${storage.getPublicUrl(path)}?${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('Error al subir imagen: $e');
      return null;
    }
  }

  // ─────────── GUARDAR ───────────
  Future<void> guardarCambios() async {
    if ([nameController.text, lastNameController.text].any((e) => e.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son obligatorios')),
      );
      return;
    }

    var url = imagenUrl;
    if (nuevaImagen != null) url = await subirImagenASupabase(user.uid);

    await ref.update({
      'name':     nameController.text.trim(),
      'lastname': lastNameController.text.trim(),
      'avatar':   url ?? '',
    });

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cambios guardados')));
    }
  }

  // ─────────── UI ───────────
  @override
  Widget build(BuildContext context) {
    final imgProvider = nuevaImagen != null
        ? FileImage(File(nuevaImagen!.path))
        : (imagenUrl != null && imagenUrl!.isNotEmpty
            ? NetworkImage(imagenUrl!)
            : null);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white70),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
          focusedBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
        ),
      ),
      child: Scaffold(
        appBar: _appBar(),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      backgroundImage: imgProvider as ImageProvider?,
                      child: imgProvider == null
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton.small(
                        backgroundColor: Colors.redAccent,
                        onPressed: seleccionarImagen,
                        child: const Icon(Icons.edit, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Campos
              _campo(nameController, 'Nombre'),
              const SizedBox(height: 12),
              _campo(lastNameController, 'Apellido'),
              const SizedBox(height: 12),
              _campo(edadController, 'Edad', enabled: false),
              const SizedBox(height: 12),
              _campo(cedulaController, 'Cédula', enabled: false),
              const SizedBox(height: 12),
              _campo(emailController, 'Correo', enabled: false),

              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: guardarCambios,
                icon: const Icon(Icons.save),
                label: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────── WIDGETS AUX ───────────
  PreferredSizeWidget _appBar() => AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Editar perfil',
            style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      );

  Widget _campo(TextEditingController c, String label,
      {bool enabled = true}) {
    return TextField(
      controller: c,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label),
    );
  }
}
