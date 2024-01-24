import 'dart:math';

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

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  List<Dot> dots = [];
  int numberOfDots = 20; // Replace 10 with the desired number of dots

  Curve getRandomCurve() {
    Random random = Random();
    return Cubic(
      random.nextDouble(),
      random.nextDouble(),
      random.nextDouble(),
      random.nextDouble(),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize multiple dots here
    for (int i = 0; i < numberOfDots; i++) {
      var duration = Duration(
          milliseconds: ((Random().nextDouble() + 20) * 1000)
              .toInt()); // Example duration
      var dot = Dot(
        color: getRandomColor(),
        loopDuration: duration,
        curve: getRandomCurve(),
      );
      dot.initializeController(this);
      dots.add(dot);
    }
  }

  @override
  void dispose() {
    for (var dot in dots) {
      dot.controller.dispose();
    }
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
          child: Stack(
            children: dots.map((dot) {
              return AnimatedBuilder(
                animation: dot.controller,
                builder: (context, child) {
                  return CustomPaint(
                    size: trackSize,
                    painter: TrackAndDotPainter(dots: dots),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
