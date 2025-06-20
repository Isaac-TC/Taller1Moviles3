import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// SUS PANTALLAS --------------------------------------------------------------
import 'package:taller_01/screens/BuscarScreen.dart';
import 'package:taller_01/screens/FiltroScreen.dart';
import 'package:taller_01/screens/PeliculaSceen.dart';
import 'package:taller_01/screens/perfilScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int indice = 0;

  final List<Widget> paginas = [
    const PeliculasMirar(),
    const BuscarPelicula(),
     GuardadosScreen(key: UniqueKey()),
    const PerfilUser(),
  ];

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/'); // redirige al login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─────────── APP BAR ───────────
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),

      // ─────────── DRAWER ───────────
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.redAccent, Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menú',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: Colors.white70),
              title: const Text('Inicio',
                  style: TextStyle(color: Colors.white70)),
              onTap: () {
                Navigator.pop(context);
                setState(() => indice = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: const Text('Cerrar sesión',
                  style: TextStyle(color: Colors.white70)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),

      // ─────────── CUERPO ───────────
      body: IndexedStack(index: indice, children: paginas),

      // ─────────── BOTTOM BAR ───────────
    bottomNavigationBar: BottomNavigationBar(
  currentIndex: indice,
  onTap: (i) {
    setState(() {
      if (i == 2) {
        
        paginas[2] = GuardadosScreen(key: UniqueKey());
      }
      indice = i;
    });
  },
  backgroundColor: Colors.grey[900],
  selectedItemColor: Colors.redAccent,
  unselectedItemColor: Colors.white54,
  type: BottomNavigationBarType.fixed,
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.local_movies_outlined),
      label: 'Películas',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Buscar',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bookmark_outline),
      label: 'Guardado',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      label: 'Perfil',
    ),
  ],
),

      backgroundColor: Colors.black,
    );
  }
}
