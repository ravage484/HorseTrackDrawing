import 'package:flutter/material.dart';
import 'models/dot.dart'; // Adjust the import path based on your project structure
import 'widgets/track_and_dot_painter.dart'; // Adjust the import path
import 'utils/utils_colors.dart'; // Adjust the import path

void main() => runApp(const MyApp());

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
    dot = Dot(
      id: 1,
      color: getRandomColor(),
      loopDuration: const Duration(seconds: 30),
    );

    _controller = AnimationController(
      vsync: this,
      duration: dot.loopDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double startingWidthRatio = 0.9;
    double startingHeightRatio = 0.3;
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
                size: trackSize,
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
