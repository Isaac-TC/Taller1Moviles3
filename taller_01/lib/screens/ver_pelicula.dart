import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

enum _Tipo { youtube, video, web }

class VerPelicula extends StatefulWidget {
  final String url;   // trailer, mp4, hls…
  final String title;
  const VerPelicula({super.key, required this.url, required this.title});

  @override
  State<VerPelicula> createState() => _VerPeliculaState();
}

class _VerPeliculaState extends State<VerPelicula> {
  late final _Tipo tipo;

  YoutubePlayerController? yt;
  VideoPlayerController?   vp;
  ChewieController?        chewie;

  @override
  void initState() {
    super.initState();

    final u = widget.url;

    // ────────────── 1. Enlace YouTube ──────────────
    if (u.contains('youtu')) {
      tipo = _Tipo.youtube;

      yt = YoutubePlayerController.fromVideoId(
        videoId: YoutubePlayerController.convertUrlToId(u)!,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      );

    // ────────────── 2. Archivo / HLS ──────────────
    } else if (u.endsWith('.mp4') || u.contains('.m3u8')) {
      tipo = _Tipo.video;
      vp = VideoPlayerController.networkUrl(Uri.parse(u))
        ..initialize().then((_) {
          chewie = ChewieController(
            videoPlayerController: vp!,
            autoPlay: true,
            looping: false,
            allowMuting: true,
            allowPlaybackSpeedChanging: true,
          );
          setState(() {});
        });

    // ────────────── 3. Cualquier otro enlace ──────────────
    } else {
      tipo = _Tipo.web;
    }
  }

  @override
  void dispose() {
    yt?.close();
    chewie?.dispose();
    vp?.dispose();
    super.dispose();
  }

  Widget _player() {
    switch (tipo) {
      case _Tipo.youtube:
        return YoutubePlayer(controller: yt!);
      case _Tipo.video:
        return chewie == null
            ? const Center(child: CircularProgressIndicator())
            : Chewie(controller: chewie!);
      case _Tipo.web:
        return WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(widget.url)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        // Contenedor del reproductor
        final content = isLandscape
            ? SizedBox.expand(child: _player())
            : Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _player(),
                ),
              );

        return Scaffold(
          backgroundColor: Colors.black,

          // ──────────  APP BAR con gradiente ──────────
          appBar: isLandscape
              ? null
              : AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: Text(
                    widget.title,
                    style: const TextStyle(color: Colors.white),
                  ),
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

          body: content,
        );
      },
    );
  }
}
