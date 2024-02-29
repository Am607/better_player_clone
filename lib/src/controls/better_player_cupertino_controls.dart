import 'dart:async';
import 'package:better_player/src/configuration/better_player_controls_configuration.dart';
import 'package:better_player/src/controls/better_player_controls_state.dart';
import 'package:better_player/src/controls/better_player_cupertino_progress_bar.dart';
import 'package:better_player/src/controls/better_player_multiple_gesture_detector.dart';
import 'package:better_player/src/controls/better_player_progress_colors.dart';
import 'package:better_player/src/core/better_player_controller.dart';
import 'package:better_player/src/core/better_player_utils.dart';
import 'package:better_player/src/core/images.dart';
import 'package:better_player/src/video_player/video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BetterPlayerCupertinoControls extends StatefulWidget {
  ///Callback used to send information if player bar is hidden or not
  final Function(bool visbility) onControlsVisibilityChanged;

  ///Controls config
  final BetterPlayerControlsConfiguration controlsConfiguration;

  const BetterPlayerCupertinoControls({
    required this.onControlsVisibilityChanged,
    required this.controlsConfiguration,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BetterPlayerCupertinoControlsState();
  }
}

class _BetterPlayerCupertinoControlsState
    extends BetterPlayerControlsState<BetterPlayerCupertinoControls> {
  final marginSize = 5.0;
  VideoPlayerValue? _latestValue;
  double? _latestVolume;
  Timer? _hideTimer;
  Timer? _expandCollapseTimer;
  Timer? _initTimer;
  bool _wasLoading = false;

  VideoPlayerController? _controller;
  BetterPlayerController? _betterPlayerController;
  StreamSubscription? _controlsVisibilityStreamSubscription;

  BetterPlayerControlsConfiguration get _controlsConfiguration =>
      widget.controlsConfiguration;

  @override
  VideoPlayerValue? get latestValue => _latestValue;

  @override
  BetterPlayerController? get betterPlayerController => _betterPlayerController;

  @override
  BetterPlayerControlsConfiguration get betterPlayerControlsConfiguration =>
      _controlsConfiguration;

  @override
  Widget build(BuildContext context) {
    return buildLTRDirectionality(_buildMainWidget());
  }

  ///Builds main widget of the controls.
  Widget _buildMainWidget() {
    _betterPlayerController = BetterPlayerController.of(context);

    if (_latestValue?.hasError == true) {
      return Container(
        color: Colors.black,
        child: _buildErrorWidget(),
      );
    }

    _betterPlayerController = BetterPlayerController.of(context);
    _controller = _betterPlayerController!.videoPlayerController;
    final backgroundColor = _controlsConfiguration.controlBarColor;
    final iconColor = _controlsConfiguration.iconsColor;
    final orientation = MediaQuery.of(context).orientation;
    final barHeight = orientation == Orientation.portrait
        ? _controlsConfiguration.controlBarHeight
        : _controlsConfiguration.controlBarHeight + 10;
    const buttonPadding = 10.0;
    final isFullScreen = _betterPlayerController?.isFullScreen == true;

    _wasLoading = isLoading(_latestValue);
    final controlsColumn = Stack(
      children: [
        if (!controlsNotVisible) //!controller visible
          AnimatedContainer(
            width: double.infinity,
            height: double.infinity,
            // height: 350,
            duration: const Duration(milliseconds: 300),
            // color: _controller.value.isControlsVisible ? Colors.black.withAlpha(150) : Colors.transparent,
            // color: Colors.black.withAlpha(120)
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(colors: [
            //     Color(0xff000000),
            //     Color(0xff000000).withOpacity(0),
            //     Color(0xff000000),
            //   ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            // ),
            decoration: BoxDecoration(color: Colors.black.withOpacity(.4)
                // gradient: LinearGradient(
                //   begin: Alignment(-0.00, -1.00),
                //   end: Alignment(0, 1),
                //   colors: [
                //     Colors.black,
                //     Colors.black.withOpacity(0.20000000298023224),
                //     Colors.black
                //   ],
                // ),
                ),
            // color: Colors.red,
          )
        else
          SizedBox(),
        Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              _buildTopBar(
                backgroundColor,
                iconColor,
                barHeight,
                buttonPadding,
              ),
              // Spacer(),

              if (_wasLoading)
                Expanded(child: Center(child: _buildLoadingWidget()))
              else
                Stack(
                  children: [
                    _buildHitArea(),
                    if (!controlsNotVisible)
                      _buildCenterWidget()
                    else
                      SizedBox()
                  ],
                ),
              // _buildNextVideoWidget(),
              // Spacer(),
              _buildBottomBar(
                backgroundColor,
                iconColor,
                barHeight,
              ),
            ]),
      ],
    );
    return GestureDetector(
      onTap: () {
        if (BetterPlayerMultipleGestureDetector.of(context) != null) {
          BetterPlayerMultipleGestureDetector.of(context)!.onTap?.call();
        }
        controlsNotVisible
            ? cancelAndRestartTimer()
            : changePlayerControlsNotVisible(true);
      },
      onDoubleTap: () {
        if (BetterPlayerMultipleGestureDetector.of(context) != null) {
          BetterPlayerMultipleGestureDetector.of(context)!.onDoubleTap?.call();
        }
        cancelAndRestartTimer();
        _onPlayPause();
      },
      onLongPress: () {
        if (BetterPlayerMultipleGestureDetector.of(context) != null) {
          BetterPlayerMultipleGestureDetector.of(context)!.onLongPress?.call();
        }
      },
      child: AbsorbPointer(
          absorbing: controlsNotVisible,
          child:
              isFullScreen ? SafeArea(child: controlsColumn) : controlsColumn),
    );
  }

  Row _buildCenterWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_controlsConfiguration.enableSkips)
          _buildSkipBack()
        else
          const SizedBox(),
        SizedBox(
          width: 40,
        ),
        if (_controlsConfiguration.enablePlayPause)
          _buildPlayPause(_controller!)
        else
          const SizedBox(),
        SizedBox(
          width: 40,
        ),
        if (_controlsConfiguration.enableSkips)
          _buildSkipForward()
        else
          const SizedBox(),
      ],
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    _controller!.removeListener(_updateState);
    _hideTimer?.cancel();
    _expandCollapseTimer?.cancel();
    _initTimer?.cancel();
    _controlsVisibilityStreamSubscription?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = _betterPlayerController;
    _betterPlayerController = BetterPlayerController.of(context);
    _controller = _betterPlayerController!.videoPlayerController;

    if (_oldController != _betterPlayerController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  Widget _buildBottomBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
  ) {
    if (!betterPlayerController!.controlsEnabled) {
      return const SizedBox();
    }
    return AnimatedOpacity(
      opacity: controlsNotVisible ? 0.0 : 1.0,
      duration: _controlsConfiguration.controlsHideTime,
      onEnd: _onPlayerHide,
      child: Container(
        alignment: Alignment.bottomCenter,
        margin: EdgeInsets.all(marginSize),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: barHeight,
            // decoration: BoxDecoration(
            //   color: backgroundColor,
            // ),
            child: _betterPlayerController!.isLiveStream()
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const SizedBox(width: 8),
                      if (_controlsConfiguration.enablePlayPause)
                        _buildPlayPause(
                          _controller!,
                        )
                      else
                        const SizedBox(),
                      const SizedBox(width: 8),
                      _buildLiveWidget(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 10),
                      if (_controlsConfiguration.enableProgressText)
                        _buildPosition()
                      else
                        const SizedBox(),
                      if (_controlsConfiguration.enableProgressBar)
                        _buildProgressBar()
                      else
                        const SizedBox(),
                      if (_controlsConfiguration.enableProgressText)
                        _buildRemaining()
                      else
                        const SizedBox(),
                      _buildFullScreenToogle(),
                      SizedBox(width: 10),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveWidget() {
    return Expanded(
      child: Text(
        _betterPlayerController!.translations.controlsLive,
        style: TextStyle(
            color: _controlsConfiguration.liveTextColor,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  GestureDetector _buildExpandButton(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double iconSize,
    double buttonPadding,
  ) {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: controlsNotVisible ? 0.0 : 1.0,
        duration: _controlsConfiguration.controlsHideTime,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: barHeight,
            padding: EdgeInsets.symmetric(
              horizontal: buttonPadding,
            ),
            // decoration: BoxDecoration(color: backgroundColor),
            child: Center(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0x33263047),
                    // color: Colors.white.withOpacity(.8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildFullScreenToogle(
      // Color backgroundColor,

      ) {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: controlsNotVisible ? 0.0 : 1.0,
        duration: _controlsConfiguration.controlsHideTime,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Center(
              child: SvgPicture.asset(
            _betterPlayerController!.isFullScreen
                ? PlayerImages.exitFullScreen
                : PlayerImages.fullScreen,
            width: 24,
            height: 24,
          )),
        ),
      ),
    );
  }

  Widget _buildHitArea() {
    return GestureDetector(
      onTap: _latestValue != null && _latestValue!.isPlaying
          ? () {
              if (controlsNotVisible == true) {
                cancelAndRestartTimer();
              } else {
                _hideTimer?.cancel();
                changePlayerControlsNotVisible(true);
              }
            }
          : () {
              _hideTimer?.cancel();
              changePlayerControlsNotVisible(false);
            },
      child: Container(
        color: Colors.transparent,
      ),
    );
  }

  GestureDetector _buildQualityChangeButton(
    VideoPlayerController? controller,
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double iconSize,
    double buttonPadding,
  ) {
    return GestureDetector(
      onTap: () {
        onQualityButtonClicked();
      },
      child: AnimatedOpacity(
        opacity: controlsNotVisible ? 0.0 : 1.0,
        duration: _controlsConfiguration.controlsHideTime,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            // decoration: BoxDecoration(
            //   color: backgroundColor,
            // ),
            child: Container(
              height: barHeight,
              padding: EdgeInsets.symmetric(
                horizontal: buttonPadding,
              ),
              child: Row(
                children: [
                  SvgPicture.asset(PlayerImages.quality),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    getName(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String getName() {
    if (betterPlayerController?.betterPlayerAsmsTrack?.height == 0 &&
        betterPlayerController?.betterPlayerAsmsTrack?.width == 0 &&
        betterPlayerController?.betterPlayerAsmsTrack?.bitrate == 0) {
      return betterPlayerController!.translations.qualityAuto;
    } else {
      if (betterPlayerController?.betterPlayerAsmsTrack?.height == null) {
        return 'Auto';
      }
      return '${betterPlayerController?.betterPlayerAsmsTrack?.height}p';
    }
  }

  GestureDetector _buildSpeedChangeButton(
    VideoPlayerController? controller,
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double iconSize,
    double buttonPadding,
  ) {
    return GestureDetector(
      onTap: () {
        cancelAndRestartTimer();

        onSpeedChooseClicked();

        // if (_latestValue!.volume == 0) {
        //   controller!.setVolume(_latestVolume ?? 0.5);
        // } else {
        //   _latestVolume = controller!.value.volume;
        //   controller.setVolume(0.0);
        // }
      },
      child: AnimatedOpacity(
        opacity: controlsNotVisible ? 0.0 : 1.0,
        duration: _controlsConfiguration.controlsHideTime,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            // decoration: BoxDecoration(
            //   color: backgroundColor,
            // ),
            child: Container(
              height: barHeight,
              padding: EdgeInsets.symmetric(
                horizontal: buttonPadding,
              ),
              child: Row(
                children: [
                  SvgPicture.asset(PlayerImages.speed),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    '${betterPlayerController!.videoPlayerController!.value.speed}x',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),

              // Icon(
              //   (_latestValue != null && _latestValue!.volume > 0)
              //       ? _controlsConfiguration.muteIcon
              //       : _controlsConfiguration.unMuteIcon,
              //   color: iconColor,
              //   size: iconSize,
              // ),
            ),
          ),
        ),
      ),
    );
  }

  InkWell _buildPlayPause(
    VideoPlayerController controller,
  ) {
    return InkWell(
      onTap: _onPlayPause,
      child: SizedBox(
        width: 82,
        height: 82,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x33263047),
            // color: Colors.white.withOpacity(.8),
          ),
          padding: controller.value.isPlaying
              ? EdgeInsets.fromLTRB(11, 11, 11, 11)
              : EdgeInsets.fromLTRB(11, 11, 7, 11),
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: SvgPicture.asset(
            controller.value.isPlaying ? PlayerImages.pause : PlayerImages.play,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildPosition() {
    final position =
        _latestValue != null ? _latestValue!.position : const Duration();

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        BetterPlayerUtils.formatDuration(position),
        style: TextStyle(
          color: _controlsConfiguration.textColor,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _buildRemaining() {
    final position = _latestValue != null && _latestValue!.duration != null
        ? _latestValue!.duration! - _latestValue!.position
        : const Duration();

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        '-${BetterPlayerUtils.formatDuration(position)}',
        style:
            TextStyle(color: _controlsConfiguration.textColor, fontSize: 12.0),
      ),
    );
  }

  GestureDetector _buildSkipBack() {
    return GestureDetector(
      onTap: skipBack,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x33263047),
          // color: Colors.white.withOpacity(.8),
        ),
        padding: EdgeInsets.fromLTRB(9, 6, 9, 9),
        // margin: const EdgeInsets.only(left: 10.0),
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: SvgPicture.asset(
          PlayerImages.seekBack,
          width: 24,
          height: 24,
        ),
      ),
    );
  }

  GestureDetector _buildSkipForward() {
    return GestureDetector(
      onTap: skipForward,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x33263047),
          // color: Colors.white.withOpacity(.8),
        ),
        padding: EdgeInsets.fromLTRB(9, 6, 9, 9),
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: SvgPicture.asset(
          PlayerImages.seekFront,
          width: 24,
          height: 24,
        ),
      ),
    );
  }

  Widget _buildTopBar(
    Color backgroundColor,
    Color iconColor,
    double topBarHeight,
    double buttonPadding,
  ) {
    if (!betterPlayerController!.controlsEnabled) {
      return const SizedBox();
    }
    final barHeight = topBarHeight * 0.8;
    final iconSize = topBarHeight * 0.4;
    return Container(
      height: barHeight,
      margin: EdgeInsets.only(
        top: marginSize,
        right: marginSize,
        left: marginSize,
      ),
      child: Row(
        children: <Widget>[
          if (_controlsConfiguration.enableFullscreen)
            _buildExpandButton(
              backgroundColor,
              iconColor,
              barHeight,
              iconSize,
              buttonPadding,
            )
          else
            const SizedBox(),
          const SizedBox(
            width: 4,
          ),
          if (_controlsConfiguration.enablePip)
            _buildPipButton(
              backgroundColor,
              iconColor,
              barHeight,
              iconSize,
              buttonPadding,
            )
          else
            const SizedBox(),
          const Spacer(),
          _buildSpeedChangeButton(
            _controller,
            backgroundColor,
            iconColor,
            barHeight,
            iconSize,
            buttonPadding,
          ),
          const SizedBox(
            width: 1,
          ),
          _buildQualityChangeButton(
            _controller,
            backgroundColor,
            iconColor,
            barHeight,
            iconSize,
            buttonPadding,
          ),
          const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildNextVideoWidget() {
    return StreamBuilder<int?>(
      stream: _betterPlayerController!.nextVideoTimeStream,
      builder: (context, snapshot) {
        final time = snapshot.data;
        if (time != null && time > 0) {
          return InkWell(
            onTap: () {
              _betterPlayerController!.playNextVideo();
            },
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.only(bottom: 4, right: 8),
                decoration: BoxDecoration(
                  color: _controlsConfiguration.controlBarColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "${_betterPlayerController!.translations.controlsNextVideoIn} $time ...",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  @override
  void cancelAndRestartTimer() {
    _hideTimer?.cancel();
    changePlayerControlsNotVisible(false);
    _startHideTimer();
  }

  Future<void> _initialize() async {
    _controller!.addListener(_updateState);

    _updateState();

    if ((_controller!.value.isPlaying) ||
        _betterPlayerController!.betterPlayerConfiguration.autoPlay) {
      _startHideTimer();
    }

    if (_controlsConfiguration.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        changePlayerControlsNotVisible(false);
      });
    }
    _controlsVisibilityStreamSubscription =
        _betterPlayerController!.controlsVisibilityStream.listen((state) {
      changePlayerControlsNotVisible(!state);

      if (!controlsNotVisible) {
        cancelAndRestartTimer();
      }
    });
  }

  void _onExpandCollapse() {
    changePlayerControlsNotVisible(true);
    _betterPlayerController!.toggleFullScreen();
    _expandCollapseTimer = Timer(_controlsConfiguration.controlsHideTime, () {
      setState(() {
        cancelAndRestartTimer();
      });
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: BetterPlayerCupertinoVideoProgressBar(
          _controller,
          _betterPlayerController,
          onDragStart: () {
            _hideTimer?.cancel();
          },
          onDragEnd: () {
            _startHideTimer();
          },
          onTapDown: () {
            cancelAndRestartTimer();
          },
          colors: BetterPlayerProgressColors(
              // playedColor: _controlsConfiguration.progressBarPlayedColor,
              // handleColor: _controlsConfiguration.progressBarHandleColor,
              // bufferedColor: _controlsConfiguration.progressBarBufferedColor,
              // backgroundColor: _controlsConfiguration.progressBarBackgroundColor,
              ),
        ),
      ),
    );
  }

  void _onPlayPause() {
    bool isFinished = false;

    if (_latestValue?.position != null && _latestValue?.duration != null) {
      isFinished = _latestValue!.position >= _latestValue!.duration!;
    }

    if (_controller!.value.isPlaying) {
      changePlayerControlsNotVisible(false);
      _hideTimer?.cancel();
      _betterPlayerController!.pause();
    } else {
      cancelAndRestartTimer();

      if (!_controller!.value.initialized) {
        if (_betterPlayerController!.betterPlayerDataSource?.liveStream ==
            true) {
          _betterPlayerController!.play();
          _betterPlayerController!.cancelNextVideoTimer();
        }
      } else {
        if (isFinished) {
          _betterPlayerController!.seekTo(const Duration());
        }
        _betterPlayerController!.play();
        _betterPlayerController!.cancelNextVideoTimer();
      }
    }
  }

  void _startHideTimer() {
    if (_betterPlayerController!.controlsAlwaysVisible) {
      return;
    }
    _hideTimer = Timer(const Duration(seconds: 3), () {
      changePlayerControlsNotVisible(true);
    });
  }

  void _updateState() {
    if (mounted) {
      if (!controlsNotVisible ||
          isVideoFinished(_controller!.value) ||
          _wasLoading ||
          isLoading(_controller!.value)) {
        setState(() {
          _latestValue = _controller!.value;
          if (isVideoFinished(_latestValue)) {
            changePlayerControlsNotVisible(false);
          }
        });
      }
    }
  }

  void _onPlayerHide() {
    _betterPlayerController!.toggleControlsVisibility(!controlsNotVisible);
    widget.onControlsVisibilityChanged(!controlsNotVisible);
  }

  Widget _buildErrorWidget() {
    final errorBuilder =
        _betterPlayerController!.betterPlayerConfiguration.errorBuilder;
    if (errorBuilder != null) {
      return errorBuilder(
          context,
          _betterPlayerController!
              .videoPlayerController!.value.errorDescription);
    } else {
      final textStyle = TextStyle(color: _controlsConfiguration.textColor);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: _controlsConfiguration.iconsColor,
              size: 42,
            ),
            Text(
              _betterPlayerController!.translations.generalDefaultError,
              style: textStyle,
            ),
            if (_controlsConfiguration.enableRetry)
              TextButton(
                onPressed: () {
                  _betterPlayerController!.retryDataSource();
                },
                child: Text(
                  _betterPlayerController!.translations.generalRetry,
                  style: textStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              )
          ],
        ),
      );
    }
  }

  Widget? _buildLoadingWidget() {
    if (_controlsConfiguration.loadingWidget != null) {
      return _controlsConfiguration.loadingWidget;
    }

    return CircularProgressIndicator(
      valueColor:
          AlwaysStoppedAnimation<Color>(_controlsConfiguration.loadingColor),
    );
  }

  Widget _buildPipButton(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double iconSize,
    double buttonPadding,
  ) {
    return FutureBuilder<bool>(
      future: _betterPlayerController!.isPictureInPictureSupported(),
      builder: (context, snapshot) {
        final isPipSupported = snapshot.data ?? false;
        if (isPipSupported &&
            _betterPlayerController!.betterPlayerGlobalKey != null) {
          return GestureDetector(
            onTap: () {
              betterPlayerController!.enablePictureInPicture(
                  betterPlayerController!.betterPlayerGlobalKey!);
            },
            child: AnimatedOpacity(
              opacity: controlsNotVisible ? 0.0 : 1.0,
              duration: _controlsConfiguration.controlsHideTime,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: barHeight,
                  padding: EdgeInsets.only(
                    left: buttonPadding,
                    right: buttonPadding,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Icon(
                      _controlsConfiguration.pipMenuIcon,
                      color: iconColor,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}


// ! Dropped own progress bar 
// chance to get latency in current duration stream // not checked with the controllers

// class VideoPositionSeeker extends StatelessWidget {
//   ///
//   const VideoPositionSeeker({super.key});
//   @override
//   Widget build(BuildContext context) {
//     var value = 0.0;
//     return StreamBuilder<YoutubeVideoState>(
//       stream: context.ytController.videoStateStream,
//       initialData: const YoutubeVideoState(),
//       builder: (context, snapshot) {
//         final position = snapshot.data?.position.inSeconds ?? 0;
//         final duration = context.ytController.metadata.duration.inSeconds;
//         value = position == 0 || duration == 0 ? 0 : position / duration;
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return SliderTheme(
//               data: const SliderThemeData(
//                   trackHeight: 6,
//                   thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8, disabledThumbRadius: 5)),
//               child: Slider(
//                 thumbColor: const Color(0xffFF6028),
//                 // overlayColor: Colors.accents,
//                 secondaryActiveColor: Colors.black,

//                 activeColor: const Color(0xffFF6028),
//                 inactiveColor: const Color(0xffF4F1FF).withOpacity(.5),
//                 value: value <= 1 ? value : 1,
//                 onChanged: (positionFraction) {
//                   value = positionFraction;
//                   setState(() {});
//                   context.ytController.seekTo(
//                     seconds: (value * duration).toDouble(),
//                     allowSeekAhead: true,
//                   );
//                 },
//                 min: 0,
//                 max: 1,
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
