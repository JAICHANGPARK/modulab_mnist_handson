import 'package:flutter/material.dart';

class Constants {
  static double canvasSize = 300;
  static double borderSize = 2;

  static double imageSize = 300;
  static int mnistImageSize = 28;

  static double strokeWidth = 8;
}

final Paint drawingPaint = Paint()
  ..strokeCap = StrokeCap.square
  ..isAntiAlias = kIsAntiAlias
  ..color = kBlackBrushColor
  ..strokeWidth = kStrokeWidth;

final canvasCullRect = Rect.fromPoints(
  const Offset(0, 0),
  Offset(Constants.imageSize, Constants.imageSize),
);

final whitePaint = Paint()
  ..strokeCap = StrokeCap.round
  ..color = Colors.white
  ..strokeWidth = Constants.strokeWidth;

final bgPaint = Paint()..color = Colors.black;

const double kCanvasSize = 200.0;

const Color kBlackBrushColor = Colors.black;

const bool kIsAntiAlias = true;

const double kStrokeWidth = 12.0;

const int kModelInputSize = 28;

const double kCanvasInnerOffset = 40.0;

const Color kBrushBlack = Colors.black;

const Color kBrushWhite = Colors.white;

final Paint kDrawingPaint = Paint()
  ..strokeCap = StrokeCap.square
  ..isAntiAlias = kIsAntiAlias
  ..color = kBrushBlack
  ..strokeWidth = kStrokeWidth;

final Paint kWhitePaint = Paint()
  ..strokeCap = StrokeCap.square
  ..isAntiAlias = kIsAntiAlias
  ..color = kBrushWhite
  ..strokeWidth = kStrokeWidth;

final kBackgroundPaint = Paint()..color = kBrushBlack;

const Color kBarColor = Colors.blue;

const Color kBarBackgroundColor = Colors.transparent;

const double kChartBarWidth = 22;

const String kWaitingForInputHeaderString =
    'Please draw a number in the box below';

const String kWaitingForInputFooterString = 'Let me guess...';

const String kGuessingInputString = 'You drew a number ';
