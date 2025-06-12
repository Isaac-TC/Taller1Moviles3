import 'package:flutter/material.dart';
import 'package:taller_01/Navigation/bottomTabNavigation.dart';

class Buscarpelicula extends StatelessWidget {
  const Buscarpelicula({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pantalla1"),),
      body: Center(child: Text("Screen 1")),
      bottomNavigationBar: BottomTab(),
    );
  }
}
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const BottomTab(); // Aquí se muestra el Tab
  }
}