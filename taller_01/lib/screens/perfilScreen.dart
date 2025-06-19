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
    final Color accentColor = Colors.redAccent;

    final textStyle = TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black87);
    final labelStyle = TextStyle(fontWeight: FontWeight.bold, color: accentColor);

    if (datosUsuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (datosUsuario!.containsKey('error')) {
      return Scaffold(
        body: Center(child: Text(datosUsuario!['error'], style: textStyle)),
      );
    }

    final avatarUrl = datosUsuario!['avatar'] ?? '';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: accentColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (avatarUrl.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage('$avatarUrl?t=${DateTime.now().millisecondsSinceEpoch}'),
                radius: 70,
                backgroundColor: Colors.grey[800],
              )
            else
              const CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 70, color: Colors.white),
              ),
            const SizedBox(height: 30),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    infoRow("Nombre", datosUsuario!['name'], labelStyle, textStyle),
                    infoRow("Apellido", datosUsuario!['lastname'], labelStyle, textStyle),
                    infoRow("Edad", datosUsuario!['age'].toString(), labelStyle, textStyle),
                    infoRow("Cédula", datosUsuario!['cedula'], labelStyle, textStyle),
                    infoRow("Correo", datosUsuario!['email'], labelStyle, textStyle),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarPerfilScreen(datos: datosUsuario!),
                  ),
                );
                cargarDatos();
              },
              icon: const Icon(Icons.edit),
              label: const Text("Editar Perfil"),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text('$label:', style: labelStyle)),
          Expanded(child: Text(value, style: valueStyle)),
        ],
      ),
    );
  }
}
