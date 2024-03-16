// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:js' as js;
import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:better_player/better_player.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/video_player/video_player_platform_interface.dart';

/// The web implementation of [VideoPlayerPlatform].
///
/// This class implements the `package:video_player` functionality for the web.
class BetterPlayerPlugin extends VideoPlayerPlatform {
  /// Registers this class as the default instance of [VideoPlayerPlatform].
  static void registerWith(Registrar registrar) {
    log('called reg with----->');
    VideoPlayerPlatform.instance = BetterPlayerPlugin();
  }

  // Map of textureId -> VideoPlayer instances
  final Map<int, VideoPlayer> _videoPlayers = <int, VideoPlayer>{};

  // Simulate the native "textureId".
  int _textureCounter = 1;

  @override
  Future<void> init() async {
    log('init player called ====>');
    // js.context.callMethod('initPlayer');
  }

  @override
  Future<int?> create(
      {BetterPlayerBufferingConfiguration? bufferingConfiguration}) async {
    log('create called');
    int textureId = _textureCounter++;

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('video_$textureId', (int id) {
      final html.Element htmlElement = html.DivElement()
        ..id = "divId"
        ..style.width = '100%'
        ..style.height = '100%'
        ..children = [
          html.VideoElement()
            ..id = 'my-player'
            ..style.minHeight = "100%"
            ..style.minHeight = "100%"
            ..style.width = "100%"
            ..controls = true
            ..className = 'video-js vjs-theme-city'
            
        ];
      return htmlElement;
    });

    log('123---> video_$textureId');
    return 0;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int? textureId) {
    // TODO: implement videoEventsFor
    log('event handler called----->');
    return Stream.empty();
  }

  @override
  Future<void> setDataSource(int? textureId, DataSource dataSource) async {
    log('set data source called--->${dataSource.formatHint}');

    js.context.callMethod(
        'setSrc', <String>[ dataSource.uri??'',dataSource.formatHint==VideoFormat.hls? "application/x-mpegURL":'']);
  }

  @override
  Future<void> setLooping(int? textureId, bool looping) async {

  }

  @override
  Future<void> setVolume(int? textureId, double volume) async {

  }

  @override
  Future<void> play(int? textureId)async {
        js.context.callMethod('play');
  }


  @override
  Future<void> pause(int? textureId)async {
   js.context.callMethod('pause');
  }

  @override
  Future<Duration> getPosition(int? textureId)async {
 
       double ? result = 
       double.tryParse(js.context.callMethod('getPosition').toString()) ;

         return Duration(seconds: (result??0).toInt());
  }

  @override
  Future<DateTime?> getAbsolutePosition(int? textureId) async{

     int  milliseconds = 
       ((double.tryParse(js.context.callMethod('getTotalDuration').toString())??0) *1000).toInt();

    // Sometimes the media server returns a absolute position far greater than
    // the datetime instance can handle. This caps the value to the maximum the datetime
    // can use.
    if (milliseconds > 8640000000000000 || milliseconds < -8640000000000000)
      return null;

    if (milliseconds <= 0) return null;

    return DateTime.fromMillisecondsSinceEpoch(milliseconds);

 
  }







}
