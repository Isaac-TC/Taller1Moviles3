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
  late DatabaseReference ref;

  late TextEditingController nameController;
  late TextEditingController lastNameController;
  late TextEditingController cedulaController;
  late TextEditingController emailController;
  late String edad;
  String? imagenUrl;
  XFile? nuevaImagen;

  @override
  void initState() {
    super.initState();
    ref = FirebaseDatabase.instance.ref('personas/${user.uid}');

    nameController = TextEditingController(text: widget.datos['name']);
    lastNameController = TextEditingController(text: widget.datos['lastname']);
    cedulaController = TextEditingController(text: widget.datos['cedula']);
    emailController = TextEditingController(text: widget.datos['email']);
    edad = widget.datos['age'].toString();
    imagenUrl = widget.datos['avatar'];
  }

  Future<void> seleccionarImagen() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.redAccent),
                title: const Text('Seleccionar de galería'),
                onTap: () async {
                  Navigator.pop(context);
                  final seleccion = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (seleccion != null) setState(() => nuevaImagen = seleccion);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
                title: const Text('Tomar una foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final seleccion = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (seleccion != null) setState(() => nuevaImagen = seleccion);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> subirImagenASupabase(String uid) async {
    try {
      final supabase = Supabase.instance.client;
      final storage = supabase.storage.from('personajes');
      final path = 'users/$uid.jpg';

      await storage.upload(
        path,
        File(nuevaImagen!.path),
        fileOptions: const FileOptions(upsert: true),
      );

      final url = storage.getPublicUrl(path);
      return '$url?${DateTime.now().millisecondsSinceEpoch}'; // Evita caché
    } catch (e) {
      debugPrint('❌ Error al subir nueva imagen: $e');
      return null;
    }
  }

  void guardarCambios() async {
    if ([nameController.text, lastNameController.text, cedulaController.text, emailController.text]
        .any((e) => e.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Todos los campos son obligatorios')),
      );
      return;
    }

    String? nuevaUrl = imagenUrl;
    if (nuevaImagen != null) {
      nuevaUrl = await subirImagenASupabase(user.uid);
    }

    await ref.update({
      'name': nameController.text.trim(),
      'lastname': lastNameController.text.trim(),
      'cedula': cedulaController.text.trim(),
      'email': emailController.text.trim(),
      'avatar': nuevaUrl ?? '',
    });

    Navigator.pop(context, true); // Indicamos que hubo actualización
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Cambios guardados')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageToShow = nuevaImagen != null
        ? FileImage(File(nuevaImagen!.path))
        : (imagenUrl != null && imagenUrl!.isNotEmpty ? NetworkImage(imagenUrl!) : null);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white70),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar perfil'),
          backgroundColor: Colors.redAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      backgroundImage: imageToShow as ImageProvider?,
                      child: imageToShow == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton.small(
                        backgroundColor: Colors.redAccent,
                        child: const Icon(Icons.edit, size: 20),
                        onPressed: seleccionarImagen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido'),
              ),
              const SizedBox(height: 10),
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Edad',
                  hintText: edad,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cedulaController,
                decoration: const InputDecoration(labelText: 'Cédula'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: guardarCambios,
                icon: const Icon(Icons.save),
                label: const Text('Guardar cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
