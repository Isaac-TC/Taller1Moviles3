import 'package:flutter/material.dart';
import 'package:taller_01/screens/ver_pelicula.dart';

// Servicio interno para manejar la lista guardada en memoria
class FavoritosService {
  static final List<Map<String, dynamic>> _pelisGuardadas = [];

  static void add(Map<String, dynamic> peli) {
    if (!_pelisGuardadas.any((p) => p['titulo'] == peli['titulo'])) {
      _pelisGuardadas.add(peli);
    }
  }

  static void remove(Map<String, dynamic> peli) {
    _pelisGuardadas.removeWhere((p) => p['titulo'] == peli['titulo']);
  }

  static List<Map<String, dynamic>> get all => List.unmodifiable(_pelisGuardadas);
}

class GuardadosScreen extends StatefulWidget {
  const GuardadosScreen({super.key});

  @override
  State<GuardadosScreen> createState() => _GuardadosScreenState();
}

class _GuardadosScreenState extends State<GuardadosScreen> {
  final _pageCtrl = PageController(viewportFraction: .85);
  int _paginaActual = 0;

  @override
  Widget build(BuildContext context) {
    final pelis = FavoritosService.all;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Mi lista'),
        backgroundColor: Colors.redAccent,
      ),
      ///////////////////////
      body: pelis.isEmpty
          ? const Center(
              child: Text(
                'Aún no hay películas guardadas',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : PageView.builder(
              controller: _pageCtrl,
              itemCount: pelis.length,
              onPageChanged: (i) => setState(() => _paginaActual = i),
              itemBuilder: (ctx, i) => _cardCarrusel(ctx, pelis[i]),
            ),
    );
  }

  Widget _cardCarrusel(BuildContext ctx, Map peli) {
    return Card(
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
                Text(
                  peli['titulo'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () {
                        Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => VerPelicula(
                              url: peli['enlaces']['trailer'],
                              title: peli['titulo'],
                            ),
                          ),
                        );
                      },
                      child: const Text('Ver película'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                      onPressed: () => _mostrarModal2(ctx, peli),
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
  }

  void _mostrarModal2(BuildContext ctx, Map peli) {
    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.grey[900],
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Stack(
          children: [
            Padding(
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
                    Text(
                      peli['titulo'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${peli["anio"]}  •  ${peli["detalles"]["duracion"]}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      peli['descripcion'],
                      style: const TextStyle(color: Colors.white70),
                    ),
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
                          onPressed: () {
                            FavoritosService.remove(peli as Map<String, dynamic>);
                            Navigator.pop(ctx);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Película eliminada')),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Ver película'),
                          onPressed: () {
                            Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                builder: (_) => VerPelicula(
                                  url: peli['enlaces']['trailer'],
                                  title: peli['titulo'],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 4,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
