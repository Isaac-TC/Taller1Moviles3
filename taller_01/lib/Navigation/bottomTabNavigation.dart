import 'package:flutter/material.dart';
import 'package:taller_01/screens/BuscarScreen.dart';
import 'package:taller_01/screens/PeliculaSceen.dart';
import 'package:taller_01/screens/UsuarioScreen.dart';
import 'package:taller_01/screens/filtroScreen.dart';

class BottomTab extends StatelessWidget {
  const BottomTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Cuerpo();
  }
}
class Cuerpo extends StatefulWidget {
  const Cuerpo({super.key});
  @override
  State<Cuerpo> createState() => _CuerpoState();
}
class _CuerpoState extends State<Cuerpo> {
  int indice = 0;
  final List<Widget> paginas = [
    PeliculasMirar(),     
    BuscarPelicula(),     
    GuardadosScreen(),    
    PerfilUser()         
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bottom Tab"),
        backgroundColor: const Color.fromRGBO(255, 196, 0, 1),
      ),
      
      body: IndexedStack(
        index: indice,
        children: paginas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indice,
        onTap: (value) {
          setState(() {
            indice = value;
          });
        },
        selectedItemColor: const Color.fromRGBO(255, 3, 3, 1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_movies_outlined),
            label: "Películas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Buscar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Guardado",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}