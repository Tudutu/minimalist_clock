import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:quiver/strings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Use temp variable to only update color when press dialog 'submit' button
  ColorSwatch _mainColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    final headline2 = Theme.of(context).textTheme.headline2;
    final textStyle = GoogleFonts.comfortaa(textStyle: headline2);

    final clockSize = const Size.square(300);

    final time = DateTime.now();
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: _mainColor[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox.fromSize(
                    size: clockSize,
                    child: AnalogueClock(
                      key: ValueKey(time.millisecond),
                      startTime: time,
                      size: clockSize,
                      swatch: _mainColor,
                      numberStyle: textStyle.copyWith(
                        fontSize: 22.0,
                        color: ThemeData.estimateBrightnessForColor(
                                    _mainColor[500]) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  DigitalClock(
                    key: ValueKey(time.millisecond),
                    startTime: time,
                    style: textStyle.copyWith(
                      color:
                          ThemeData.estimateBrightnessForColor(_mainColor[300]) ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 8.0,
          right: 8.0,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: Icon(Icons.settings, color: Colors.black26,),
                onPressed: () {
                  _openMainColorPicker();
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  void _openDialog(String title, Widget content) {

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: content,
        );
      },
    );
  }

  void _openMainColorPicker() async {
    _openDialog(
      "Clock Color",
      MaterialColorPicker(
        shrinkWrap: true,
        selectedColor: _mainColor,
        allowShades: false,
        onMainColorChange: (color) {
          Navigator.of(context).pop();
          setState(() => _mainColor = color);
        },
      ),
    );
  }
}

class DigitalClock extends StatefulWidget {
  DigitalClock({
    Key key,
    @required this.startTime,
    this.style,
  })  : assert(startTime != null),
        super(key: key);

  final TextStyle style;
  final DateTime startTime;

  @override
  DigitalClockState createState() => DigitalClockState();
}

class DigitalClockState extends State<DigitalClock>
    with SingleTickerProviderStateMixin {
  DateTime _startTime;
  DateTime _currentTime;
  Ticker _ticker;
  final format = DateFormat.Hms();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _startTime = widget.startTime;
    _currentTime = _startTime;

    start();
  }

  void start() {
    _ticker.start();
  }

  void stop() {
    _ticker.stop();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.startTime != widget.startTime) {
      _startTime = widget.startTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = format.format(_currentTime);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      ...displayText.characters.map((c) {
        return Flexible(
          flex: isDigit(c.runes.first) ? 1 : 0,
          child: Text(c, style: widget.style),
        );
      }).toList(),
    ]);
  }

  void _onTick(Duration elapsed) {
    setState(() {
      _currentTime = _startTime.add(elapsed);
    });
  }
}

class AnalogueClock extends StatefulWidget {
  AnalogueClock({
    Key key,
    @required this.startTime,
    @required this.size,
    @required this.swatch,
    @required this.numberStyle,
  })  : assert(startTime != null),
        assert(size != null),
        assert(swatch != null),
        super(key: key);

  final DateTime startTime;

  final Size size;

  final ColorSwatch<int> swatch;

  final TextStyle numberStyle;

  @override
  _AnalogueClockState createState() => _AnalogueClockState();
}

class _AnalogueClockState extends State<AnalogueClock>
    with SingleTickerProviderStateMixin {
  DateTime _currentTime;
  Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _currentTime = widget.startTime;
    start();
  }

  void start() {
    _ticker.start();
  }

  void stop() {
    _ticker.stop();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: AnalogueClockPainter(
          time: _currentTime,
          backgroundColor: widget.swatch,
          borderColor: widget.swatch[600],
          hourMarkerColor: widget.swatch[700],
          hourMarkerWidth: 8.0,
          hourMarkerFractionalLength: 0.2,
          minuteMarkerColor: widget.swatch[600],
          minuteMarkerWidth: 4.0,
          minuteMarkerFractionalLength: 0.08,
          numberStyle: widget.numberStyle,
          numberFractionalCenterPosition: .35,
          textScaleFactor: MediaQuery.of(context).textScaleFactor,
          hourHandColor: widget.swatch[900],
          hourHandWidth: 8.0,
          hourHandFractionalLength: 0.5,
          minuteHandColor: widget.swatch[900],
          minuteHandWidth: 8.0,
          secondHandColor: widget.swatch[800],
          secondHandWidth: 4.0,
          secondHandFractionalLength: .9),
    );
  }

  void _onTick(Duration elapsed) {
    setState(() {
      _currentTime = widget.startTime.add(elapsed);
    });
  }
}

class AnalogueClockPainter extends CustomPainter {
  AnalogueClockPainter({
    @required this.time,
    this.backgroundColor = Colors.white,
    this.minuteHandColor = Colors.black,
    this.hourHandColor = Colors.black,
    this.secondHandColor = Colors.black,
    this.borderColor = Colors.grey,
    this.borderWidth = 10.0,
    this.hourHandWidth = 1.0,
    this.minuteHandWidth = 1.0,
    this.secondHandWidth = 1.0,
    this.hourHandFractionalLength = 0.6,
    this.minuteHandFractionalLength = 0.8,
    this.secondHandFractionalLength = 1.0,
    this.minuteMarkerFractionalLength = 0.12,
    this.hourMarkerFractionalLength = 0.2,
    this.numberFractionalCenterPosition = 0.25,
    this.minuteMarkerColor = Colors.blue,
    this.minuteMarkerWidth = 2.0,
    this.hourMarkerColor = Colors.red,
    this.hourMarkerWidth = 3.0,
    this.textScaleFactor = 1.0,
    this.numberStyle,
    Listenable repaint,
  })  : assert(backgroundColor != null),
        assert(minuteHandColor != null),
        assert(hourHandColor != null),
        assert(time != null),
        backgroundPaint = Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill,
        minuteHandPaint = Paint()
          ..color = minuteHandColor
          ..strokeWidth = minuteHandWidth ?? 3.5
          ..strokeCap = StrokeCap.round
          ..blendMode = BlendMode.multiply,
        secondHandPaint = Paint()
          ..color = secondHandColor
          ..strokeWidth = secondHandWidth ?? 3.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.bevel,
        hourHandPaint = Paint()
          ..color = hourHandColor
          ..strokeWidth = hourHandWidth ?? 5.0
          ..strokeCap = StrokeCap.round
          ..blendMode = BlendMode.multiply,
        borderPaint = Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth ?? 0.0,
        hourMarkerPaint = Paint()
          ..color = hourMarkerColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = hourMarkerWidth ?? 0.0,
        minuteMarkerPaint = Paint()
          ..color = minuteMarkerColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = minuteMarkerWidth ?? 0.0,
        super(repaint: repaint);

  static const fullCircleAngle = 2 * math.pi;

  static const centerTopAngle = -math.pi / 2;

  final DateTime time;

  final Color backgroundColor;

  final Color minuteHandColor;

  final Color secondHandColor;

  final Color hourHandColor;

  final Color hourMarkerColor;

  final Color minuteMarkerColor;

  final Color borderColor;

  final Paint backgroundPaint;

  final Paint minuteHandPaint;

  final Paint secondHandPaint;

  final Paint hourHandPaint;

  final Paint hourMarkerPaint;

  final Paint minuteMarkerPaint;

  final Paint borderPaint;

  final double hourHandWidth;

  final double hourMarkerWidth;

  final double minuteMarkerWidth;

  final double hourHandFractionalLength;

  final double minuteHandWidth;

  final double minuteHandFractionalLength;

  final double secondHandWidth;

  final double secondHandFractionalLength;

  final double minuteMarkerFractionalLength;

  final double hourMarkerFractionalLength;

  final double numberFractionalCenterPosition;

  final double borderWidth;

  final double textScaleFactor;

  final TextStyle numberStyle;

  final Paint redPaint = Paint()
    ..color = Colors.red
    ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final insideBorderRadius = radius - borderWidth * 2;
    final center = Offset(size.width / 2, size.height / 2);
    final clockBounds = Rect.fromCircle(center: center, radius: radius);

    // Clip the canvas to the size of the bounds to avoid drawing outside
    // of the bounds (can leak to other widgets, for example).
    // canvas.clipRect(clockBounds);

    // Draw the background
    _drawFace(canvas, center, radius, backgroundPaint, true);

    // Draw the hour and minute markers
    _drawMarkers(canvas, center, 60, insideBorderRadius,
        minuteMarkerFractionalLength, minuteMarkerPaint);
    _drawMarkers(canvas, center, 12, insideBorderRadius,
        hourMarkerFractionalLength, hourMarkerPaint);
    _drawNumbers(canvas, center, 12, insideBorderRadius,
        numberFractionalCenterPosition, hourMarkerPaint, numberStyle);

    // Draw the clock border
    _drawFace(canvas, center, radius - (borderWidth / 2), borderPaint);

    // Draw the hands
    _drawHand(canvas, center, _calculateMinuteAngle(time.minute, time.second),
        insideBorderRadius * minuteHandFractionalLength, minuteHandPaint);
    _drawHand(canvas, center, _calculateHourAngle(time.hour, time.minute),
        insideBorderRadius * hourHandFractionalLength, hourHandPaint);
    _drawHand(
        canvas,
        center,
        _calculateSecondAngle(time.second, time.millisecond),
        insideBorderRadius * secondHandFractionalLength,
        secondHandPaint);
    // _drawHand(canvas, center, _calculateAngle(1000, time.millisecond),
    //     radius * secondHandFractionalLength, secondHandPaint);
  }

  void _drawFace(Canvas canvas, Offset center, double radius, Paint paint,
      [bool hasShadow = false]) {
    if (hasShadow) {
      canvas.drawShadow(
          Path()
            ..addOval(Rect.fromCenter(
                center: center, width: radius * 2, height: radius * 2)),
          Colors.black54,
          8.0,
          true);
    }
    canvas.drawCircle(center, radius, paint);
  }

  void _drawHand(Canvas canvas, Offset center, double handAngle, double length,
      Paint paint) {
    canvas.drawLine(
        center,
        center + Offset.fromDirection(centerTopAngle + handAngle, length),
        paint);
  }

  void _drawMarkers(Canvas canvas, Offset center, int number, double radius,
      double fractionalLength, Paint paint) {
    for (var i = 0; i < number; i++) {
      final angle = centerTopAngle + _calculateAngle(number, i);
      canvas.drawLine(
          center + Offset.fromDirection(angle, radius * (1 - fractionalLength)),
          center + Offset.fromDirection(angle, radius),
          paint);
    }
  }

  void _drawNumbers(Canvas canvas, Offset center, int number, double radius,
      double fractionalLength, Paint paint, TextStyle style) {
    for (var i = 1; i <= number; i++) {
      final angle = centerTopAngle + _calculateAngle(number, i);
      final numberPainter = TextPainter(
        text: TextSpan(text: i.toString(), style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textScaleFactor: textScaleFactor,
      );
      numberPainter.layout();
      numberPainter.paint(
          canvas,
          center +
              Offset.fromDirection(angle, radius * (1 - fractionalLength)) -
              numberPainter.size.center(Offset.zero));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double _calculateAngle(int totalDivisions, int currentValue) =>
      fullCircleAngle * currentValue / totalDivisions;

  double _calculateSecondAngle(int second, int millisecond) =>
      _calculateAngle(60, second) + _calculateAngle(60 * 1000, millisecond);

  double _calculateMinuteAngle(int minute, int second) =>
      _calculateAngle(60, minute) + _calculateAngle(60 * 60, second);

  double _calculateHourAngle(int hour, int minute) =>
      _calculateAngle(12, hour) + _calculateAngle(12 * 60, minute);
}
