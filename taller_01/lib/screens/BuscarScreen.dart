
import 'package:flutter/material.dart';
import 'package:taller_01/screens/ver_pelicula.dart';
import 'dart:convert';


void abrirBusquedaSimple(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ModalWrapper(child: BuscarSimpleScreen()),
  );
}


class _ModalWrapper extends StatelessWidget {
  final Widget child;
  const _ModalWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,          
      builder: (_, controller) => Container(
        margin: const EdgeInsets.only(top: 40),   
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          top: 16,
          left: 12,
          right: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }
}

//
// ────────────────────────────── 1. BÚSQUEDA SIMPLE ─────────────────────────────
//
class BuscarSimpleScreen extends StatefulWidget {
  const BuscarSimpleScreen({super.key});

  @override
  State<BuscarSimpleScreen> createState() => _BuscarSimpleScreenState();
}

class _BuscarSimpleScreenState extends State<BuscarSimpleScreen> {
  final _ctrl = TextEditingController();
  List<Map<String, dynamic>> _peliculas = [];
  List<Map<String, dynamic>> _resultados = [];

  @override
  void initState() {
    super.initState();
    _cargarPeliculas();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _cargarPeliculas() async {
    final str = await DefaultAssetBundle.of(context)
        .loadString('assets/Data/Peliculas.json');
    _peliculas =
        (json.decode(str)['peliculas'] as List).cast<Map<String, dynamic>>();
  }

  void _filtrar(String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _resultados = []);
      return;
    }
    setState(() {
      _resultados = _peliculas.where((p) {
        final titulo  = p['titulo'].toString().toLowerCase();
        final anio    = p['anio'].toString();
        final generos = (p['genero'] as List).join(' ').toLowerCase();
        return titulo.contains(query) ||
            anio.contains(query) ||
            generos.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // BARRA DE BÚSQUEDA
          TextField(
            controller: _ctrl,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.redAccent,
            decoration: InputDecoration(
              hintText: 'Título, género o año',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              suffixIcon: _ctrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () {
                        _ctrl.clear();
                        _filtrar('');
                      },
                    ),
            ),
            onChanged: _filtrar,
          ),
          const SizedBox(height: 16),

          // RESULTADOS
          Expanded(
            child: _resultados.isEmpty
                ? const SizedBox()
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2 / 3,
                    ),
                    itemCount: _resultados.length,
                    itemBuilder: (_, i) =>
                        _miniCard(context, _resultados[i]),
                  ),
          ),
        ],
      );

  // mini-card y modal
  Widget _miniCard(BuildContext ctx, Map peli) => GestureDetector(
        onTap: () => _mostrarModal(ctx, peli),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(peli['enlaces']['image'], fit: BoxFit.cover),
        ),
      );

  void _mostrarModal(BuildContext ctx, Map peli) => showDialog(
        context: ctx,
        builder: (_) => _dialogDetalle(ctx, peli),
      );
}



// ───────────────────────────── 2. BÚSQUEDA AVANZADA ─────────────────────────────

class BuscarPelicula extends StatefulWidget {
  const BuscarPelicula({super.key});

  @override
  State<BuscarPelicula> createState() => _BuscarPeliculaState();
}

class _BuscarPeliculaState extends State<BuscarPelicula> {
  final _tituloCtrl = TextEditingController();
  final _generoCtrl = TextEditingController();
  final _anioCtrl   = TextEditingController();

  List<Map<String, dynamic>> _peliculas = [];
  List<Map<String, dynamic>> _resultados = [];
  bool _mostrado = false; 

  @override
  void initState() {
    super.initState();
    _cargarPeliculas();
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _generoCtrl.dispose();
    _anioCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarPeliculas() async {
    final str = await DefaultAssetBundle.of(context)
        .loadString('assets/Data/Peliculas.json');
    _peliculas =
        (json.decode(str)['peliculas'] as List).cast<Map<String, dynamic>>();
  }

  void _buscar() {
    final t = _tituloCtrl.text.trim().toLowerCase();
    final g = _generoCtrl.text.trim().toLowerCase();
    final a = _anioCtrl.text.trim();

    final match = _peliculas.where((p) {
      final titulo  = p['titulo'].toString().toLowerCase();
      final anio    = p['anio'].toString();
      final generos = (p['genero'] as List).join(' ').toLowerCase();

      final okTitulo = t.isEmpty || titulo.contains(t);
      final okGenero = g.isEmpty || generos.contains(g);
      final okAnio   = a.isEmpty || anio.contains(a);

      return okTitulo && okGenero && okAnio;
    }).toList();

    setState(() {
      _resultados = match;
      _mostrado   = true;
    });

    if (match.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Sin coincidencias',
              style: TextStyle(color: Colors.white)),
          content: const Text(
            'No se encontraron películas que cumplan los filtros.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
       
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _campo(_tituloCtrl, 'Título'),
                  const SizedBox(height: 8),
                  _campo(_generoCtrl, 'Género'),
                  const SizedBox(height: 8),
                  _campo(_anioCtrl, 'Año', tipo: TextInputType.number),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: const Size.fromHeight(40),
                    ),
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar'),
                    onPressed: _buscar,
                  ),
                ],
              ),
            ),
            Expanded(
              child: !_mostrado
                  ? const SizedBox()
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2 / 3,
                      ),
                      itemCount: _resultados.length,
                      itemBuilder: (_, i) =>
                          _miniCard(context, _resultados[i]),
                    ),
            ),
          ],
        ),
      );

  // helpers
  Widget _campo(TextEditingController c, String h,
      {TextInputType tipo = TextInputType.text}) {
    return TextField(
      controller: c,
      keyboardType: tipo,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.redAccent,
      decoration: InputDecoration(
        hintText: h,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _miniCard(BuildContext ctx, Map peli) => GestureDetector(
        onTap: () => _mostrarModal(ctx, peli),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(peli['enlaces']['image'], fit: BoxFit.cover),
        ),
      );

  void _mostrarModal(BuildContext ctx, Map peli) => showDialog(
        context: ctx,
        builder: (_) => _dialogDetalle(ctx, peli),
      );
}

//
// ────────────────────────────── DETALLE COMÚN ──────────────────────────────
//
Dialog _dialogDetalle(BuildContext ctx, Map peli) => Dialog(
      backgroundColor: Colors.grey[900],
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: _detallePelicula(ctx, peli),
      ),
    );

Widget _detallePelicula(BuildContext ctx, Map peli) => SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              peli['enlaces']['image'],
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            peli['titulo'],
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '${peli["anio"]} • ${peli["detalles"]["duracion"]}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Text(
            peli['descripcion'],
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Ver película'),
              onPressed: () {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) =>
                        VerPelicula(url: peli['enlaces']['trailer'], title: peli['titulo']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
