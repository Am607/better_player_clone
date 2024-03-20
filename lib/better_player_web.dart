// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
library videojs;

import 'dart:async';
import 'dart:developer';



import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:better_player/better_player.dart';
import 'package:better_player/web/interop.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/video_player/video_player_platform_interface.dart';

import 'stub/js_stub.dart' if (dart.library.js) 'package:js/js.dart' as js;

@js.JS()
// @js.anonymous
class Options {
  // Must have an unnamed factory constructor with named arguments.
  external factory Options({List<double> playbackRates, Plugins plugins});
}

@js.JS()
// @js.anonymous
class Plugins {
  // Must have an unnamed factory constructor with named arguments.
  external factory Plugins({Hotkeys hotkeys});
}

@js.JS()
// @js.anonymous
class Hotkeys {
  // Must have an unnamed factory constructor with named arguments.
  external factory Hotkeys(
      {double volumeStep, int seekStep, bool enableModifiersForNumbers});
}

@js.JS()
class videojs {
  external factory videojs(String id, Options options);

  external static videojs? getPlayer(String id);
  external void src(
    String src,
    String type,
  );
  external void play();
  external void pause();

  external double duration();
  external bool isDisposed();
  external bool isFullscreen();

  external void playbackRates(List<double> rates);

  external double? currentTime([int? time]);

  external void on(String event, Function onEvent);

  external void dispose();

  external void httpSourceSelector();

  external bool paused();
}

/// The web implementation of [VideoPlayerPlatform].
///
/// This class implements the `package:video_player` functionality for the web.
class BetterPlayerPlugin extends VideoPlayerPlatform {
  /// Registers this class as the default instance of [VideoPlayerPlatform].
  static void registerWith(Registrar registrar) {
    VideoPlayerPlatform.instance = BetterPlayerPlugin();
  }

  // Map of textureId -> VideoPlayer instances
  final Map<int, VideoPlayer> _videoPlayers = <int, VideoPlayer>{};

  // Simulate the native "textureId".
  int _textureCounter = 1;
  late StreamController<VideoEvent> eventController;
  @override
  Future<void> init() async {
    eventController = StreamController();
    log('init web player-->');
  }

  @override
  Future<void> dispose(int? textureId) async {
    log('dispose web player-->');
    var player = videojs.getPlayer(playerId(textureId));

    player?.pause();

    player?.dispose();
    await eventController.close();
  }

  @override
  Future<int?> create(
      {BetterPlayerBufferingConfiguration? bufferingConfiguration}) async {
    log('create web player-->');
    int textureId = _textureCounter++;

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('video-$textureId', (int id) {
      final html.Element htmlElement = html.DivElement()
        ..id = "divId"
        ..style.width = '100%'
        ..style.height = '100%'
        ..children = [
          html.VideoElement()
            ..id = 'player-$textureId'
            ..style.minHeight = "100%"
            ..style.minHeight = "100%"
            ..style.width = "100%"
            ..controls = true
            ..className = 'video-js  '
        ];
      return htmlElement;
    });

    return textureId;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int? textureId) {
    return eventController.stream;
  }

  @override
  Future<void> setDataSource(int? textureId, DataSource dataSource) async {
    log('set data source web player-->');
    final player = videojs.getPlayer(playerId(textureId));
    player?.src(
        dataSource.uri ?? '',
        dataSource.formatHint == VideoFormat.hls
            ? "application/x-mpegURL"
            : '');

    player?.on('loadeddata', js.allowInterop((a, b) async {
      eventController.add(VideoEvent(
          eventType: VideoEventType.initialized,
          key: '',
          duration: Duration(seconds: totalDuration(textureId))));
    }));

    // player?.on('play', allowInterop((a, b) async {
    //   eventController.add(VideoEvent(
    //     eventType: VideoEventType.play,
    //     key: '',
    //   ));
    // }));
    // player?.on('pause', allowInterop((a, b) async {
    //   if (eventController.isClosed) {
    //     return;
    //   }
    //   eventController.add(VideoEvent(
    //     eventType: VideoEventType.pause,
    //     key: '',
    //   ));
    // }));
  }

  String playerId(int? textureID) {
    return 'player-$textureID';
  }

  int totalDuration(int? textureID) {
    final player = videojs.getPlayer(playerId(textureID));
    double duration = (player?.duration() ?? 0);
    log('duration is $duration');

    return (duration.isNaN || duration.isInfinite) ? 0 : duration.toInt();
  }

  @override
  Future<void> setTrackParameters(
      int? textureId, int? width, int? height, int? bitrate) async {}
  @override
  Future<void> setLooping(int? textureId, bool looping) async {}

  @override
  Future<void> seekTo(int? textureId, Duration? position) async {
    final player = videojs.getPlayer(playerId(textureId));

    player?.currentTime(position?.inSeconds ?? 0);
  }

  @override
  Future<bool> isWebFullScreen() async {
    final player = videojs.getPlayer(playerId(1));
    return player?.isFullscreen() ?? false;
  }

  @override
  Future<void> setVolume(int? textureId, double volume) async {}

  @override
  Future<void> play(int? textureId) async {
    final player = videojs.getPlayer(playerId(textureId));
    // final player = videojs.getPlayer('my-player');
    if (player?.paused() == true) {
      player?.play();
    }
  }

  @override
  Future<void> pause(int? textureId) async {
    final player = videojs.getPlayer(playerId(textureId));
    player?.pause();
  }

  @override
  Future<Duration> getPosition(int? textureId) async {
    final player = videojs.getPlayer(playerId(textureId));

    double? currentTime = player?.currentTime();

    int duration = (currentTime ?? 0).toInt();

    return Duration(seconds: duration.isNaN ? 0 : duration);
  }

  @override
  Future<DateTime?> getAbsolutePosition(int? textureId) async {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
