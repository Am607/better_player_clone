// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
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
    log('init called------>');
  }

  @override
  Future<int?> create(
      {BetterPlayerBufferingConfiguration? bufferingConfiguration}) async {
    log('create called');
    int textureId = _textureCounter++;
  

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory('video_$textureId', (int id) {

           final html.Element htmlElement = html.DivElement()
          ..id = "divId"
          ..style.width = '100%'
          ..style.height = '100%'
          ..children = [
            html.VideoElement()
              ..id = textureId.toString()
              ..style.minHeight = "100%"
              ..style.minHeight = "100%"
              ..style.width = "100%"
              ..src ='https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
          
              
            
          
          ];
        return htmlElement;
        });
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
    log('set data source called--->');
  }

  @override
  Future<void> setLooping(int? textureId, bool looping) async {
    log('called set looping----->');
  }

  @override
  Future<void> setVolume(int? textureId, double volume) async {
    log('called set volume----->');
  }

//   @override
//   Future<void> init() async {
//     return _disposeAllPlayers();
//   }

//   @override
//   Future<void> dispose(int? textureId) async {
//     // _player(textureId).dispose();
//     _videoPlayers.remove(textureId);
//     return;
//   }

//   void _disposeAllPlayers() {
//     // for (final VideoPlayer videoPlayer in _videoPlayers.values) {
//     //   // videoPlayer.dispose();
//     // }
//     // _videoPlayers.clear();
//   }

// @override
//   Future<int?> create({BetterPlayerBufferingConfiguration? bufferingConfiguration}) {
//  final int textureId = _textureCounter++;

//     late String uri;
//     switch (bufferingConfiguration) {
//       case DataSourceType.network:
//         // Do NOT modify the incoming uri, it can be a Blob, and Safari doesn't
//         // like blobs that have changed.
//         uri = dataSource.uri ?? '';
//       case DataSourceType.asset:
//         String assetUrl = dataSource.asset!;
//         if (dataSource.package != null && dataSource.package!.isNotEmpty) {
//           assetUrl = 'packages/${dataSource.package}/$assetUrl';
//         }
//         assetUrl = ui_web.assetManager.getAssetUrl(assetUrl);
//         uri = assetUrl;
//       case DataSourceType.file:
//         return Future<int>.error(UnimplementedError(
//             'web implementation of video_player cannot play local files'));
//       case DataSourceType.contentUri:
//         return Future<int>.error(UnimplementedError(
//             'web implementation of video_player cannot play content uri'));
//     }

//     final web.HTMLVideoElement videoElement = web.HTMLVideoElement()
//       ..id = 'videoElement-$textureId'
//       ..style.border = 'none'
//       ..style.height = '100%'
//       ..style.width = '100%';

//     // TODO(hterkelsen): Use initialization parameters once they are available
//     ui_web.platformViewRegistry.registerViewFactory(
//         'videoPlayer-$textureId', (int viewId) => videoElement);

//     final VideoPlayer player = VideoPlayer(videoElement: videoElement)
//       ..initialize(
//         src: uri,
//       );

//     _videoPlayers[textureId] = player;

//     return textureId;
//   }

//   @override
//   Future<void> setLooping(int textureId, bool looping) async {
//     return _player(textureId).setLooping(looping);
//   }

//   @override
//   Future<void> play(int textureId) async {
//     return _player(textureId).play();
//   }

//   @override
//   Future<void> pause(int textureId) async {
//     return _player(textureId).pause();
//   }

//   @override
//   Future<void> setVolume(int textureId, double volume) async {
//     return _player(textureId).setVolume(volume);
//   }

//   @override
//   Future<void> setPlaybackSpeed(int textureId, double speed) async {
//     return _player(textureId).setPlaybackSpeed(speed);
//   }

//   @override
//   Future<void> seekTo(int textureId, Duration position) async {
//     return _player(textureId).seekTo(position);
//   }

//   @override
//   Future<Duration> getPosition(int textureId) async {
//     return _player(textureId).getPosition();
//   }

//   @override
//   Stream<VideoEvent> videoEventsFor(int ? textureId) {
//     // return _player(textureId).events;
//   }

//   @override
//   Future<void> setWebOptions(int textureId, VideoPlayerWebOptions options) {
//     return _player(textureId).setOptions(options);
//   }

//   // Retrieves a [VideoPlayer] by its internal `id`.
//   // It must have been created earlier from the [create] method.
//   VideoPlayer _player(int id) {
//     return _videoPlayers[id]!;
//   }

//   @override
//   Widget buildView(int textureId) {
//     return HtmlElementView(viewType: 'videoPlayer-$textureId');
//   }

//   /// Sets the audio mode to mix with other sources (ignored)
//   @override
//   Future<void> setMixWithOthers(bool mixWithOthers) => Future<void>.value();
}
