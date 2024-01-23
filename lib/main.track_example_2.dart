import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const MyApp());

class Dot {
  final Color color; // The color of the dot
  final Duration loopDuration; // The time taken for a full loop

  Dot({required this.color, required this.loopDuration});
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Dot dot;

  @override
  void initState() {
    super.initState();
    // Initialize the Dot with a random color and loop duration
    dot = Dot(
      color: getRandomColor(),
      loopDuration: const Duration(seconds: 30),
    );

    _controller = AnimationController(
      vsync: this,
      duration: dot.loopDuration,
    )..repeat();//..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Obtain the screen size
    Size screenSize = MediaQuery.of(context).size;

    // Define the starting width and height ratio
    double startingWidthRatio = 0.9; // 90% of screen width
    double startingHeightRatio = 0.3; // 30% of screen height

    // Calculate the track size
    Size trackSize = Size(
      screenSize.width * startingWidthRatio,
      screenSize.height * startingHeightRatio,
    );

    return MaterialApp(
      title: 'Flutter Animation Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Animating Dot on Track'),
        ),
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              return CustomPaint(
                size: trackSize, // The size of the track
                painter: TrackAndDotPainter(
                  progress: _controller.value,
                  dot: dot,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class TrackAndDotPainter extends CustomPainter {
  final double progress;
  final Dot dot;

  TrackAndDotPainter({required this.progress, required this.dot});

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the track outline
    final trackOutlinePaint = Paint()
      ..color = Colors.brown // Brown color for the outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40.0; // Adjust the width of the outline as needed

    // Paint for the track fill
    final trackFillPaint = Paint()
      ..color = Colors.green[800]! // Grass green color for the fill
      ..style = PaintingStyle.fill;

    // Define the track path
    final trackPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(size.height / 2), // Rounded corners for the pill shape
      ));

    // Draw the filled track
    canvas.drawPath(trackPath, trackFillPaint);

    // Draw the track outline
    canvas.drawPath(trackPath, trackOutlinePaint);

    // Draw the animated dot with a white outline
    final dotPaint = Paint()..color = dot.color;
    final outlinePaint = Paint()..color = Colors.white; // Paint for the outline
    const dotRadius = 10.0; // The radius of the dot
    const outlineWidth = 4.0; // Width of the outline
    final pathMetrics = trackPath.computeMetrics();
    final metric = pathMetrics.first; // Assuming there's only one path

    // Calculate the position of the dot based on the progress of the animation
    final dotPath = metric.extractPath(
      0.0,
      metric.length * progress,
    );
    final dotPosition = dotPath.computeMetrics().first.getTangentForOffset(dotPath.computeMetrics().first.length)?.position ?? Offset.zero;
    
    // Draw the outline
    canvas.drawCircle(dotPosition, dotRadius + outlineWidth, outlinePaint);
    
    // Draw the dot
    canvas.drawCircle(dotPosition, dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant TrackAndDotPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dot != dot;
  }
}

/// Returns a random color
Color getRandomColor() {
  Random random = Random();
  int r, g, b;

  do {
    r = random.nextInt(256);
    g = random.nextInt(256);
    b = random.nextInt(256);
  } while ((r > 100 && g > 100 && b < 50) || // Avoid brown (loosely defined as high red & green, low blue)
           (g > 150 && r < 100 && b < 100)); // Avoid green (high green, low red & blue)

  return Color.fromRGBO(r, g, b, 1);
}