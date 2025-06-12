import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PeliculasMirar extends StatelessWidget {
  const PeliculasMirar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Películas para ver"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Películas Recomendadas",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(child: ListarPelicula(context)),
          ],
        ),
      ),
    );
  }
}

Future<List> PeliculasMostrar(context) async {
  String jsomString = await DefaultAssetBundle.of(context).loadString("assets/Data/Peliculas.json");
  final jsonMap = json.decode(jsomString);
  return jsonMap["peliculas"]; // extrae solo la lista
}


Widget ListarPelicula(context) {
  return FutureBuilder(
    future: PeliculasMostrar(context),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasData) {
        final data = snapshot.data!;

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["titulo"],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item["enlaces"]["image"],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${item["anio"]} · ${item["detalles"]["duracion"]} · Dir: ${item["detalles"]["director"]}",
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item["descripcion"],
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: -8,
                      children: (item["genero"] as List<dynamic>)
                          .map((g) => Chip(
                                label: Text(g),
                                backgroundColor: Colors.deepPurple.shade100,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.link, size: 18, color: Colors.deepPurple),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse(item["enlaces"]["url"]));
                          },
                          child: const Text(
                            "IMDb",
                            style: TextStyle(
                              color: Colors.deepPurple,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.play_circle_fill,
                            size: 18, color: Colors.deepPurple),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse(item["enlaces"]["trailer"]));
                          },
                          child: const Text(
                            "Tráiler",
                            style: TextStyle(
                              color: Colors.deepPurple,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        return const Center(child: Text("Error al cargar los datos"));
      }
    },
  );
}
