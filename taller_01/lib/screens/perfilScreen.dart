import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Perfilscreen extends StatelessWidget {
  const Perfilscreen({super.key});

  Future<Map<String, dynamic>> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final ref = FirebaseDatabase.instance.ref().child('personas/$uid');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    } else {
      return {'error': 'No se encontraron datos'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};
          if (data.containsKey('error')) {
            return Center(child: Text(data['error']));
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: ${data['name']}', style: const TextStyle(fontSize: 18)),
                Text('Apellido: ${data['lastname']}', style: const TextStyle(fontSize: 18)),
                Text('Edad: ${data['age']}', style: const TextStyle(fontSize: 18)),
                Text('Cédula: ${data['cedula']}', style: const TextStyle(fontSize: 18)),
                Text('Correo: ${data['email']}', style: const TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );
  }
}
