  import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

enum _Tipo { youtube, video, web }

class VerPelicula extends StatefulWidget {
  final String url;      // puede ser trailer o mp4
  final String title;
  const VerPelicula({super.key, required this.url, required this.title});

  @override
  State<VerPelicula> createState() => _VerPeliculaState();
}

class _VerPeliculaState extends State<VerPelicula> {
  _Tipo tipo = _Tipo.web;
  YoutubePlayerController? yt;
  VideoPlayerController? vp;
  ChewieController? chewie;

  @override
  void initState() {
    super.initState();

    final u = widget.url;
    if (u.contains('youtu')) {
      tipo = _Tipo.youtube;
      yt = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(u)!,
        flags: const YoutubePlayerFlags(autoPlay: true, controlsVisibleAtStart: true),
      );
    } else if (u.endsWith('.mp4') || u.contains('.m3u8')) {
      tipo = _Tipo.video;
      vp = VideoPlayerController.networkUrl(Uri.parse(u))
        ..initialize().then((_) {
          chewie = ChewieController(
            videoPlayerController: vp!,
            autoPlay: true,
            looping: false,
          );
          setState(() {});
        });
    } else {
      tipo = _Tipo.web;
    }
  }

  @override
  void dispose() {
    yt?.dispose();
    chewie?.dispose();
    vp?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.redAccent,
        ),
        body: switch (tipo) {
          _Tipo.youtube => YoutubePlayer(controller: yt!),
          _Tipo.video   => chewie == null
              ? const Center(child: CircularProgressIndicator())
              : Chewie(controller: chewie!),
          _Tipo.web     => WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse(widget.url)),
            ),
        },
      );
}
