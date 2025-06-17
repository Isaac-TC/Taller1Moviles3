import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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

  @override
  void initState() {
    super.initState();
    ref = FirebaseDatabase.instance.ref('personas/${user.uid}');

    nameController = TextEditingController(text: widget.datos['name']);
    lastNameController = TextEditingController(text: widget.datos['lastname']);
    cedulaController = TextEditingController(text: widget.datos['cedula']);
    emailController = TextEditingController(text: widget.datos['email']);
    edad = widget.datos['age'].toString();
  }

  void guardarCambios() async {
    if ([nameController.text, lastNameController.text, cedulaController.text, emailController.text]
        .any((e) => e.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Todos los campos son obligatorios')),
      );
      return;
    }

    await ref.update({
      'name': nameController.text.trim(),
      'lastname': lastNameController.text.trim(),
      'cedula': cedulaController.text.trim(),
      'email': emailController.text.trim(),
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Cambios guardados')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white70),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white30)),
          focusedBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar perfil'),
          backgroundColor: Colors.black87,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
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
                    backgroundColor: Colors.blueAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
