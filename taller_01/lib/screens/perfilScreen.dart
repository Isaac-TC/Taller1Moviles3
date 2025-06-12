import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:taller_01/screens/editarPerfilScreen.dart';

class PerfilUser extends StatefulWidget {
  const PerfilUser({super.key});

  @override
  State<PerfilUser> createState() => _PerfilUserState();
}

class _PerfilUserState extends State<PerfilUser> {
  final user = FirebaseAuth.instance.currentUser!;
  Map<String, dynamic>? datosUsuario;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() async {
    final ref = FirebaseDatabase.instance.ref().child('personas').child(user.uid);
    final snapshot = await ref.get();

    if (snapshot.exists) {
      setState(() {
        datosUsuario = Map<String, dynamic>.from(snapshot.value as Map);
      });
    } else {
      // Opcional: mostrar mensaje si no hay datos
      setState(() {
        datosUsuario = {'error': 'No se encontraron datos'};
      });
    }
  }

 @override
Widget build(BuildContext context) {
  if (datosUsuario == null) {
    return const Center(child: CircularProgressIndicator());
  }

  if (datosUsuario!.containsKey('error')) {
    return Center(child: Text(datosUsuario!['error']));
  }

  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("👤 Nombre: ${datosUsuario!['name']}"),
        Text("👤 Apellido: ${datosUsuario!['lastname']}"),
        Text("🎂 Edad: ${datosUsuario!['age']}"),
        Text("🆔 Cédula: ${datosUsuario!['cedula']}"),
        Text("📧 Correo: ${datosUsuario!['email']}"),
        const SizedBox(height: 30),
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Editar perfil'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarPerfilScreen(
                    datos: datosUsuario!,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
}