import 'dart:developer';

import 'package:better_player/better_player.dart';
import 'package:better_player_example/pages/welcome_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Better player demo',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('pl', 'PL'),
        ],
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: kIsWeb ? WebPlayer() : WelcomePage(),
      ),
    );
  }
}

class WebPlayer extends StatefulWidget {
  const WebPlayer({Key? key}) : super(key: key);

  @override
  State<WebPlayer> createState() => _WebPlayerState();
}

class _WebPlayerState extends State<WebPlayer> {
  late BetterPlayerController betterPlayerController;
  @override
  void initState() {
    // TODO: implement initState
    betterPlayerController = BetterPlayerController(BetterPlayerConfiguration(),
        betterPlayerDataSource: BetterPlayerDataSource.network(
            'http://sample.vodobox.net/skate_phantom_flex_4k/skate_phantom_flex_4k.m3u8',
            videoFormat: BetterPlayerVideoFormat.hls));

    // betterPlayerController.setupDataSource(BetterPlayerDataSource.network('http://sample.vodobox.net/skate_phantom_flex_4k/skate_phantom_flex_4k.m3u8'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   
    return Column(
      children: [
        Flexible(child: BetterPlayer(controller: betterPlayerController)),
        SizedBox(
          height: 15,
        ),
        IgnorePointer(
          ignoring: betterPlayerController.isWebFullScreen(),
          child: Wrap(
            children: [
              ElevatedButton(
                  onPressed: () async {

                    if(betterPlayerController.isWebFullScreen()){
                      
                    }
                    if (betterPlayerController.isPlaying() == true) {
                      await betterPlayerController.pause();
                    } else {
                      await betterPlayerController.play();
                    }
                  },
                  child: Text('Play/pause')),
              ElevatedButton(
                  onPressed: () async {
                    final result =
                        await betterPlayerController.getCheckPointsCount();
                    log('check points is $result');
                  },
                  child: Text('get checkpoints ')),
              ElevatedButton(
                  onPressed: () async {
                    final position = await betterPlayerController
                        .videoPlayerController?.value.position;
                    log('1234 position is $position');
                  },
                  child: Text('get duration ')),
              ElevatedButton(
                  onPressed: () async {
                    final position = await betterPlayerController
                        .videoPlayerController?.value.duration;
                    final isInitialized = await betterPlayerController
                        .videoPlayerController?.value.initialized;
                    log('456 is initialized  $isInitialized and duration is $position');
                  },
                  child: Text('Total Duration ')),
              ElevatedButton(
                  onPressed: () async {
                    betterPlayerController.dispose();
                  },
                  child: Text('dispose player ')),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
