import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // (sin usar por ahora)

class PeliculasMirar extends StatelessWidget {
  const PeliculasMirar({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Padding(
          padding: EdgeInsets.all(12),
          child: _Contenido(),
        ),
      );
}

// ───────────────────── CONTENIDO ─────────────────────
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
          final data = snap.data!;

          // duplicamos la lista para mostrar 5 filas
          final listas = List.generate(5, (_) => data);

          return ListView(
            children: [
              // ───────── CARRUSEL ─────────
              SizedBox(
                height: 330,
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _paginaActual = i),
                  itemCount: data.length,
                  itemBuilder: (_, i) => _cardCarrusel(context, data[i]),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  data.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 6,
                    width: _paginaActual == i ? 18 : 6,
                    decoration: BoxDecoration(
                      color: _paginaActual == i
                          ? Colors.redAccent
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ───────── LISTAS HORIZONTALES (5) ─────────
              ...List.generate(listas.length, (fila) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recomendadas ${fila + 1}",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 210,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: listas[fila].length,
                        itemBuilder: (_, i) =>
                            _miniCard(context, listas[fila][i]),
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

  // ───────────────────── JSON ─────────────────────
  Future<List<dynamic>> _obtenerPeliculas(BuildContext ctx) async {
    final str =
        await DefaultAssetBundle.of(ctx).loadString("assets/Data/Peliculas.json");
    return (json.decode(str))["peliculas"];
  }

  // ───────────────────── CARRUSEL CARD ─────────────────────
  Widget _cardCarrusel(BuildContext ctx, Map peli) {
    return Card(
      color: Colors.grey[900],
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Stack(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              peli["enlaces"]["image"],
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Gradiente
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
          // Contenido
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  peli["titulo"],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Ver película (rojo)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      onPressed: () {
                        // TODO: reproducir película
                      },
                      child: const Text("Ver película"),
                    ),
                    const SizedBox(width: 10),
                    // Descripción (abre modal)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent)),
                      onPressed: () => _mostrarModal(ctx, peli),
                      child: const Text("Descripción"),
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

  // ───────────────────── MINI CARD ─────────────────────
  Widget _miniCard(BuildContext ctx, Map peli) {
    return GestureDetector(
      onTap: () => _mostrarModal(ctx, peli),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(peli["enlaces"]["image"]),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // ───────────────────── MODAL ─────────────────────
  void _mostrarModal(BuildContext ctx, Map peli) {
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
                    // Imagen
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        peli["enlaces"]["image"],
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Título
                    Text(
                      peli["titulo"],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    // Año + duración
                    Text(
                      "${peli["anio"]}  •  ${peli["detalles"]["duracion"]}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    // Descripción
                    Text(
                      peli["descripcion"],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    // Botones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            // TODO: agregar a lista / favoritos
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Agregar a la lista"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                          onPressed: () {
                            // TODO: reproducir película
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("Ver película"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Botón cerrar
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
