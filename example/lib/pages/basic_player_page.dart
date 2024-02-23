import 'package:better_player/better_player.dart';
import 'package:better_player_example/constants.dart';
import 'package:better_player_example/utils.dart';
import 'package:flutter/material.dart';

class BasicPlayerPage extends StatefulWidget {
  @override
  _BasicPlayerPageState createState() => _BasicPlayerPageState();
}

class _BasicPlayerPageState extends State<BasicPlayerPage> {
  BetterPlayerController? _controller;
  late BetterPlayerDataSource _betterPlayerDataSource;

  @override
  void initState() {
    _betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      'https://d357lqen3ahf81.cloudfront.net/transcoded/Af34Dm2h4M5/video.m3u8',
      cacheConfiguration: const BetterPlayerCacheConfiguration(useCache: true),
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(maxBufferMs: 3000, minBufferMs: 1000),
    );

    _controller = BetterPlayerController(BetterPlayerConfiguration(autoPlay: true),
        betterPlayerDataSource: _betterPlayerDataSource);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Basic player"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Basic player created with the simplest factory method. Shows video from URL.",
              style: TextStyle(fontSize: 16),
            ),
          ),
          // AspectRatio(
          //   aspectRatio: 16 / 9,
          //   child: BetterPlayer.network(
          //     Constants.forBiggerBlazesUrl,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Next player shows video from file.",
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: Utils.getFileUrl(Constants.fileTestVideoUrl),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.data != null) {
                return BetterPlayer(
                  controller: _controller!,
                );
              } else {
                return const SizedBox();
              }
            },
          ),

          SizedBox(
            height: 20,
          ),

          AnimatedContainer(
            width: double.infinity,
            height: 350,
            duration: const Duration(milliseconds: 300),
            // color: _controller.value.isControlsVisible ? Colors.black.withAlpha(150) : Colors.transparent,
            // color: Colors.black.withAlpha(120)
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xff000000),
                Color(0xff000000).withOpacity(0),
                Color(0xff000000),
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
            // color: Colors.red,
          ),
        ],
      ),
    );
  }
}
