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
        home: kIsWeb ? WebPageMain() : WelcomePage(),
      ),
    );
  }
}

class WebPageMain extends StatelessWidget {
  const WebPageMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => WebPlayer(),
              ));
            },
            child: Text('go')),
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
    betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(webSize: Size(440, 660)),
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
        ColoredBox(
          color: Colors.green,
          child: SizedBox(
            height: 660,
            width: 440,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: ColoredBox(
                  color: Colors.green,
                  child: BetterPlayer(
                    controller: betterPlayerController,
                  ),
                )),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        IgnorePointer(
          ignoring: false,
          child: Wrap(
            children: [
              ElevatedButton(
                  onPressed: () async {
                    // betterPlayerController.isWebFullScreen().then(
                    //   (value) {
                    //     if (value) {
                    //       log('play pause clicked----->');
                    //     } else {
                    //       log('play pause not  clicked----->');
                    //     }
                    //   },
                    // );

                    if (betterPlayerController.isPlaying() == true) {
                      await betterPlayerController.pause();
                    } else {
                      await betterPlayerController.play();
                    }
                  },
                  child: Text('Play/pause')),
              ElevatedButton(
                  onPressed: () async {
                    log('fullscreen Status ${betterPlayerController.isWebFullScreen()}');
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
              ElevatedButton(
                  onPressed: () async {
                    await betterPlayerController.setupDataSource(
                        BetterPlayerDataSource.network(
                            'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
                            videoFormat: BetterPlayerVideoFormat.hls));
                  },
                  child: Text('Change Video ')),
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
