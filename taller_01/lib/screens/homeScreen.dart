import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ───── PANTALLAS ─────
import 'package:taller_01/screens/PeliculaSceen.dart';
import 'package:taller_01/screens/BuscarScreen.dart';  // ← aquí vive abrirBusquedaSimple
import 'package:taller_01/screens/FiltroScreen.dart';
import 'package:taller_01/screens/perfilScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int indice = 0;

  final List<Widget> paginas = const [
    PeliculasMirar(),
    BuscarPelicula(),
    FiltroPelicula(),
    PerfilUser(),
  ];

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // ─────────── APP BAR ───────────
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 72,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Play Top',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _gradientText(
                  switch (indice) {
                    0 => 'Películas',
                    1 => 'Buscar',
                    2 => 'Guardado',
                    _ => 'Perfil',
                  },
                  key: ValueKey(indice),
                ),
              ),
            ],
          ),
          actions: indice == 0
              ? [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => abrirBusquedaSimple(context), // <-- aquí
                  )
                ]
              : null,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.redAccent, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
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
                title:
                    const Text('Inicio', style: TextStyle(color: Colors.white70)),
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

        // ─────────── BOTTOM NAV ───────────
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: indice,
          onTap: (i) => setState(() => indice = i),
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

/// Helper para subtítulo con degradado rojo→blanco
Widget _gradientText(String text, {Key? key}) {
  const grad = LinearGradient(colors: [Colors.redAccent, Colors.white]);
  return Text(
    text,
    key: key,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      foreground: Paint()..shader = grad.createShader(const Rect.fromLTWH(0, 0, 200, 0)),
      shadows: const [Shadow(blurRadius: 2, color: Colors.black26)],
    ),
  );
}
