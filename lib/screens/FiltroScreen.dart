import 'package:flutter/material.dart';
import 'package:taller_01/Navigation/bottomTabNavigation.dart';
class FiltroPelicula extends StatelessWidget {
  const FiltroPelicula({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pantalla1"),),
      body: Center(child: Text("Screen 1")),
      bottomNavigationBar: BottomTab(),
    );
  }
}