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

  @override
  void initState() {
    super.initState();
    // Initialize multiple dots here
    for (int i = 0; i < numberOfDots; i++) {
      var duration = Duration(seconds: 10 + i); // Example duration
      var dot = Dot(
        color: getRandomColor(),
        loopDuration: duration,
      );
      dot.initializeController(this);
      dots.add(dot);
    }// Start an animation status listener to update the UI

    for (var dot in dots) {
      dot.controller.addListener(() {
        setState(() {
          dot.updateProgress();
          dots.sort((a, b) => b.progress.compareTo(a.progress)); // Sort based on progress
        });
      });
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
    double startingWidthRatio = 0.7;
    double startingHeightRatio = 0.1;
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
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                size: trackSize,
                painter: TrackAndDotPainter(dots: dots),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: screenSize.width * .2, // Adjust the width as needed
                color: Colors.white.withOpacity(0.8), // Semi-transparent background
                child: ListView.builder(
                  itemCount: dots.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.circle, color: dots[index].color),
                      title: Text("${index + 1}"),
                      trailing: Text("${(dots[index].progress * 100).toStringAsFixed(0)}%"),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}