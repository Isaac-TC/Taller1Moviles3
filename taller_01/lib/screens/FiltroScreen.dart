import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:taller_01/screens/ver_pelicula.dart';

/* --------------------  CACHE PELÍCULAS  -------------------- */
class PelisRepo {
  static final Map<String, Map<String, dynamic>> _cache = {};

  static Future<void> _load(BuildContext ctx) async {
    final str =
        await DefaultAssetBundle.of(ctx).loadString('assets/Data/Peliculas.json');
    final list =
        (json.decode(str)['peliculas'] as List).cast<Map<String, dynamic>>();
    for (final p in list) {
      _cache[p['id'].toString()] = p;      // clave String
    }
  }

  static Future<Map<String, Map<String, dynamic>>> getAll(BuildContext ctx) async {
    if (_cache.isEmpty) await _load(ctx);
    return _cache;
  }
}

/* ------------------  FAVORITOS EN FIREBASE  ------------------ */
class FavoritosService {
  static final _auth = FirebaseAuth.instance;

  static DatabaseReference get _ref => FirebaseDatabase.instance
      .ref()
      .child('favoritos')
      .child(_auth.currentUser!.uid);

  static Stream<Set<String>> streamIds() => _ref.onValue.map((e) {
        final data = e.snapshot.value as Map<dynamic, dynamic>? ?? {};
        return data.keys.cast<String>().toSet();
      });

  static Future<void> add(String movieId) => _ref.child(movieId).set(true);
  static Future<void> remove(String movieId) => _ref.child(movieId).remove();
}

/* ------------------  PANTALLA DE GUARDADOS  ------------------ */
class GuardadosScreen extends StatelessWidget {
  const GuardadosScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
       
        body: FutureBuilder(
          future: PelisRepo.getAll(context),
          builder: (_, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final pelisMap = snap.data!; // id -> película

            return StreamBuilder<Set<String>>(
              stream: FavoritosService.streamIds(),
              builder: (_, favSnap) {
                if (!favSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final ids = favSnap.data!;
                if (ids.isEmpty) {
                  return const Center(
                    child: Text('Aún no hay películas guardadas',
                        style: TextStyle(color: Colors.white70)),
                  );
                }

                final pelis = ids
                    .where(pelisMap.containsKey)
                    .map((id) => pelisMap[id]!)
                    .toList();

                final pageCtrl = PageController(viewportFraction: .85);

                return PageView.builder(
                  controller: pageCtrl,
                  itemCount: pelis.length,
                  itemBuilder: (_, i) => _CardGuardado(peli: pelis[i]),
                );
              },
            );
          },
        ),
      );
}

/* ------------------  CARD + MODAL DETALLE  ------------------ */
class _CardGuardado extends StatelessWidget {
  final Map<String, dynamic> peli;
  const _CardGuardado({required this.peli});

  @override
  Widget build(BuildContext context) => Card(
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
                          context,
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
                        onPressed: () => _mostrarModal(context),
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

  void _mostrarModal(BuildContext ctx) => showDialog(
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
                        icon: const Icon(Icons.delete),
                        label: const Text('Eliminar'),
                        onPressed: () async {
                          await FavoritosService.remove(peli['id'].toString());
                          Navigator.pop(ctx);
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
