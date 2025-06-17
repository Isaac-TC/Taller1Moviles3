import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PeliculasMirar extends StatelessWidget {
  const PeliculasMirar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
  String jsomString =
      await DefaultAssetBundle.of(context).loadString("assets/Data/Peliculas.json");
  final jsonMap = json.decode(jsomString);
  return jsonMap["peliculas"];
}

Widget ListarPelicula(context) {
  return FutureBuilder(
    future: PeliculasMostrar(context),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasData) {
        final data = snapshot.data!;

        return Column(
          children: [
            // Carrusel principal
            SizedBox(
              height: 280,
              child: PageView.builder(
                itemCount: data.length,
                controller: PageController(viewportFraction: 0.9),
                itemBuilder: (context, index) {
                  final item = data[index];
                  return Card(
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            item["enlaces"]["image"],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            item["titulo"],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Lista horizontal inferior
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return Container(
                    width: 220,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item["enlaces"]["image"],
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item["titulo"],
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${item["anio"]} • ${item["detalles"]["duracion"]}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white70),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Icon(Icons.play_circle, size: 18, color: Colors.deepPurple),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => launchUrl(Uri.parse(item["enlaces"]["trailer"])),
                                  child: const Text(
                                    "Tráiler",
                                    style: TextStyle(
                                        color: Colors.deepPurple,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      } else {
        return const Center(child: Text("Error al cargar los datos", style: TextStyle(color: Colors.white)));
      }
    },
  );
}
