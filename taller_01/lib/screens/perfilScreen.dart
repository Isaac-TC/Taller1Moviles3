// =================== PERFIL USER SCREEN ===================
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

  Future<void> cargarDatos() async {
    final ref =
        FirebaseDatabase.instance.ref().child('personas').child(user.uid);
    final snap = await ref.get();

    if (snap.exists) {
      setState(() =>
          datosUsuario = Map<String, dynamic>.from(snap.value as Map));
    } else {
      setState(() => datosUsuario = {'error': 'No se encontraron datos'});
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Colors.redAccent;
    const valueStyle = TextStyle(fontSize: 18, color: Colors.white);
    const labelStyle =
        TextStyle(fontWeight: FontWeight.bold, color: accent);

    // 1. Cargando…
    if (datosUsuario == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Sin datos
    if (datosUsuario!.containsKey('error')) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body:
            Center(child: Text('No se encontraron datos', style: valueStyle)),
      );
    }

    final avatarUrl = datosUsuario!['avatar'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,

      // 🔸 SIN AppBar (se usa el encabezado global)

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            avatarUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(
                        '$avatarUrl?t=${DateTime.now().millisecondsSinceEpoch}'),
                    backgroundColor: Colors.grey[800],
                  )
                : const CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey,
                    child:
                        Icon(Icons.person, size: 70, color: Colors.white),
                  ),

            const SizedBox(height: 30),

            // Tarjeta de datos
            Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.grey[900],
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    infoRow('Nombre',   datosUsuario!['name'], labelStyle, valueStyle),
                    infoRow('Apellido', datosUsuario!['lastname'], labelStyle, valueStyle),
                    infoRow('Edad',     '${datosUsuario!['age']}', labelStyle, valueStyle),
                    infoRow('Cédula',   datosUsuario!['cedula'], labelStyle, valueStyle),
                    infoRow('Correo',   datosUsuario!['email'], labelStyle, valueStyle),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Botón editar
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditarPerfilScreen(datos: datosUsuario!),
                  ),
                );
                cargarDatos(); // refresca
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar Perfil'),
            ),
          ],
        ),
      ),
    );
  }

  // Fila de info
  Widget infoRow(
          String label, String value, TextStyle lStyle, TextStyle vStyle) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text('$label:', style: lStyle)),
            Expanded(child: Text(value, style: vStyle)),
          ],
        ),
      );
}
