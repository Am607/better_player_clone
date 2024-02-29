// Flutter imports:
import 'package:flutter/rendering.dart';

///Representation of colors used in progress bar.
class BetterPlayerProgressColors {
  BetterPlayerProgressColors({
    Color playedColor = const Color(0xffFF6028),
    Color bufferedColor = const Color.fromARGB(154, 241, 112, 103),
    Color handleColor = const Color(0xffFF6028),
    Color backgroundColor = const Color(0xff8D8380),
  })  : playedPaint = Paint()..color = playedColor,
        bufferedPaint = Paint()..color = bufferedColor,
        handlePaint = Paint()..color = handleColor,
        backgroundPaint = Paint()..color = backgroundColor;

  final Paint playedPaint;
  final Paint bufferedPaint;
  final Paint handlePaint;
  final Paint backgroundPaint;
}
