// ignore_for_file: constant_identifier_names
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:taller_01/screens/ver_pelicula.dart';
import 'package:taller_01/screens/FiltroScreen.dart'
    show FavoritosService; // servicio de “Mi lista”

class PeliculasMirar extends StatelessWidget {
  const PeliculasMirar({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: const Padding(
          padding: EdgeInsets.all(12),
          child: _Contenido(),
        ),
      );
}

class _Contenido extends StatefulWidget {
  const _Contenido();

  @override
  State<_Contenido> createState() => _ContenidoState();
}

class _ContenidoState extends State<_Contenido> {
  final _pageCtrl = PageController(viewportFraction: .85);
  int _paginaActual = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _obtenerPeliculas(context),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pelis = snap.data!; 

          final pelis = snap.data!; // lista filtrada
          if (pelis.isEmpty) {
            return const Center(
              child: Text(
                'No hay contenido disponible',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          // Agrupar por género
          final Map<String, List<Map>> porGenero = {};
          for (final p in pelis) {
            for (final g in (p['genero'] as List)) {
              porGenero.putIfAbsent(g, () => []).add(p);
            }
          }
          final generos = porGenero.keys.toList()..sort();

          return ListView(
            children: [
              // ─────────── Carrusel principal ───────────
              SizedBox(
                height: 330,
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _paginaActual = i),
                  itemCount: pelis.length,
                  itemBuilder: (_, i) => _cardCarrusel(context, pelis[i]),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pelis.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 6,
                    width: _paginaActual == i ? 18 : 6,
                    decoration: BoxDecoration(
                      color:
                          _paginaActual == i ? Colors.redAccent : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─────────── Listas por género ───────────
              ...generos.map((g) {
                final lista = porGenero[g]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 210,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: lista.length,
                        itemBuilder: (_, i) => _miniCard(context, lista[i]),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }),
            ],
          );
        },
      );

  // ────────────────────  LECTURA Y FILTRO  ────────────────────
  Future<List<Map<String, dynamic>>> _obtenerPeliculas(
      BuildContext ctx) async {
    // 1. Lee todas las pelis
    final str =
        await DefaultAssetBundle.of(ctx).loadString('assets/Data/Peliculas.json');
    final todas =
        (json.decode(str)['peliculas'] as List).cast<Map<String, dynamic>>();

    // 2. Obtiene la edad del usuario
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap =
        await FirebaseDatabase.instance.ref('personas/$uid/age').get();
    final edad = (snap.value ?? 99) as int; // por defecto 99

    // 3. Filtra si es menor
    if (edad < 18) {
      return todas
          .where((p) => (p['restriccion_edad'] as String) != '+18')
          .toList();
    }
    return todas;
  }

  // ─────────────────────  WIDGETS  ─────────────────────
  Widget _cardCarrusel(BuildContext ctx, Map peli) => Card(
        color: Colors.grey[900],
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                peli['enlaces']['image'],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(peli['titulo'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        onPressed: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => VerPelicula(
                              url: peli['enlaces']['trailer'],
                              title: peli['titulo'],
                            ),
                          ),
                        ),
                        child: const Text('Ver película'),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent)),
                        onPressed: () => _mostrarModal(ctx, peli),
                        child: const Text('Descripción'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _miniCard(BuildContext ctx, Map peli) => GestureDetector(
        onTap: () => _mostrarModal(ctx, peli),
        child: Container(
          width: 140,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(peli['enlaces']['image']),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );

  // ──────────────────  MODAL DETALLE  ──────────────────
  void _mostrarModal(BuildContext ctx, Map peli) => showDialog(
        context: ctx,
        barrierDismissible: true,
        builder: (_) => Dialog(
          backgroundColor: Colors.grey[900],
          insetPadding: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      peli['enlaces']['image'],
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(peli['titulo'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('${peli["anio"]}  •  ${peli["detalles"]["duracion"]}',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Text(peli['descripcion'],
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar a la lista'),
                        onPressed: () async {
                          await FavoritosService.add(peli['id']);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Añadida a tu lista')),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Ver película'),
                        onPressed: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => VerPelicula(
                              url: peli['enlaces']['trailer'],
                              title: peli['titulo'],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
