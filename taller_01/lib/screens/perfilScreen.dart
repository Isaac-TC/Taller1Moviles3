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
      setState(() {
        datosUsuario = {'error': 'No se encontraron datos'};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black87);
    final labelStyle = TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.cyanAccent : Colors.blueGrey);

    if (datosUsuario == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (datosUsuario!.containsKey('error')) {
      return Center(child: Text(datosUsuario!['error'], style: textStyle));
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: isDark ? Colors.grey[850] : Colors.white,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nombre:", style: labelStyle),
                    Text("${datosUsuario!['name']}", style: textStyle),
                    const SizedBox(height: 12),
                    Text("Apellido:", style: labelStyle),
                    Text("${datosUsuario!['lastname']}", style: textStyle),
                    const SizedBox(height: 12),
                    Text("Edad:", style: labelStyle),
                    Text("${datosUsuario!['age']}", style: textStyle),
                    const SizedBox(height: 12),
                    Text("Cédula:", style: labelStyle),
                    Text("${datosUsuario!['cedula']}", style: textStyle),
                    const SizedBox(height: 12),
                    Text("Correo electrónico:", style: labelStyle),
                    Text("${datosUsuario!['email']}", style: textStyle),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Editar perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.cyan : Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
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
      ),
    );
  }
}
