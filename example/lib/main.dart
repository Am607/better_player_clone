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
        home:kIsWeb?WebPlayer(): WelcomePage(),
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
    betterPlayerController =BetterPlayerController(BetterPlayerConfiguration(),betterPlayerDataSource: BetterPlayerDataSource.network('http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  BetterPlayer(controller: betterPlayerController);
  }
}