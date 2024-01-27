import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Horse Track Shape'),
        ),
        body: Center(
          child: CustomPaint(
            size: const Size(1200, 600), // You can adjust the size as needed
            painter: TrackShapePainter(),
          ),
        ),
      ),
    );
  }
}

class TrackShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint trackPaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 80.0;

    // Create the outer path which is pill-shaped
    Path trackPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(size.height / 2), // This makes the ends rounded like a pill
      ));

    // Draw the track
    canvas.drawPath(trackPath, trackPaint);

    // Optionally, you can add lines to represent lanes in the track
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
