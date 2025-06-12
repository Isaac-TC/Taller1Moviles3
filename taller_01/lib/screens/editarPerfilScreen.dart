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
  late TextEditingController ageController;
  late TextEditingController cedulaController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    ref = FirebaseDatabase.instance.ref('personas/${user.uid}');

    nameController = TextEditingController(text: widget.datos['name']);
    lastNameController = TextEditingController(text: widget.datos['lastname']);
    ageController = TextEditingController(text: widget.datos['age'].toString());
    cedulaController = TextEditingController(text: widget.datos['cedula']);
    emailController = TextEditingController(text: widget.datos['email']);
  }

  void guardarCambios() async {
    if ([nameController.text, lastNameController.text, ageController.text, cedulaController.text, emailController.text].any((e) => e.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Todos los campos son obligatorios')),
      );
      return;
    }

    final edad = int.tryParse(ageController.text.trim());
    if (edad == null || edad < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Edad inválida')),
      );
      return;
    }

    await ref.update({
      'name': nameController.text.trim(),
      'lastname': lastNameController.text.trim(),
      'age': edad,
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
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Apellido')),
            TextField(controller: ageController, decoration: const InputDecoration(labelText: 'Edad'), keyboardType: TextInputType.number),
            TextField(controller: cedulaController, decoration: const InputDecoration(labelText: 'Cédula')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Correo')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: guardarCambios, child: const Text('Guardar'))
          ],
        ),
      ),
    );
  }
}
