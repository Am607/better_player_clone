import 'dart:developer';

import 'package:better_player/better_player.dart';
import 'package:better_player_example/constants.dart';
import 'package:flutter/material.dart';

class HlsTracksPage extends StatefulWidget {
  @override
  _HlsTracksPageState createState() => _HlsTracksPageState();
}

class _HlsTracksPageState extends State<HlsTracksPage> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      Constants.hlsTestStreamUrl,
      useAsmsSubtitles: true,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    log('9048 crossed checkpoints ---> ${_betterPlayerController.getCheckPointsCount()}');
    _betterPlayerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HLS tracks"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Player with HLS stream which loads tracks from HLS."
              " You can choose tracks by using overflow menu (3 dots in right corner).",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Flexible(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer(controller: _betterPlayerController),
            ),
          ),
        ],
      ),
    );
  }
}
