import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For RawKeyboardListener
import 'dart:math';
import 'models/dot.dart';
import 'widgets/game_painter.dart'; 
import 'utils/utils_colors.dart'; 
import 'resources/configurations.dart';
import 'package:horse_track_drawing/resources/kentucky_derby_winners.dart'; 
import 'package:horse_track_drawing/models/dot_combo.dart'; 
import 'package:horse_track_drawing/models/driver.dart';
import 'package:horse_track_drawing/utils/utils_track_generation.dart'; 

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with TickerProviderStateMixin {
  List<DotCombo> dots = [];
  int numberOfDots = Configurations.numberOfDots; // Replace 10 with the desired number of dots
  final FocusNode _focusNode = FocusNode();
  bool trackGenerated = false;
  Path trackPath = Path();

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // Copy the list of names
    var names = List<String>.from(KENTUCKY_DERBY_WINNERS); 
    
    // Initialize multiple dots here
    for (int i = 0; i < numberOfDots; i++) {
      var duration = Duration(seconds: 10 + i); // Example duration
      int randomIndex = Random().nextInt(names.length);
      String randomName = names.removeAt(randomIndex);

      // Initialize a dot
      var dot = Dot(
        name: randomName,
        color: getRandomColor(),
        loopDuration: duration,
      );

      // Initialize a driver
      var driver = Driver(
        name: randomName,
        control: Random().nextDouble(),
        aggression: Random().nextDouble(),
        consistency: Random().nextDouble(),
        experience: Random().nextDouble(),
      );

      // Initialize the controller
      dot.initializeController(this);

      // Initialize the dot combo
      var dotCombo = DotCombo(
        dot: dot,
        driver: driver,
      );

      // Add the dot to the list
      dots.add(dotCombo);
    }

    // Add a listener to each controller
    for (var dotCombo in dots) {
      var dot = dotCombo.dot;
      dot.controller.addListener(() {
        setState(() {
          // Update the progress of each dot
          dot.updateProgress();

          // Sort the dots based on progress
          dots.sort((a, b) => b.progress.compareTo(a.progress)); // Sort based on progress
        });
      });
    }
  }

  @override
  void dispose() {
    for (var dotCombo in dots) {
      dotCombo.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double trackWidthRatio = 0.8; // 80% of screen width for the track
    double listWidthRatio = 0.2; // 20% of screen width for the list
    Size trackSize = Size(
      screenSize.width * trackWidthRatio,
      screenSize.height * 0.8, // Same as before
    );
    Offset trackCenter = Offset(trackSize.width / 2, trackSize.height / 2);


    if (!trackGenerated) {
      trackGenerated = true;
      // trackPath = generateRacetrackUsingGenerator(trackSize, 8, 500, 5, 5);
      trackPath = generateTrackPathStandardOval(trackCenter, trackSize, Configurations.trackOutlinePaint);
    }

    return MaterialApp(
      title: 'Horse Track Animation',
      home: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: _handleKeyPress,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Horse Track Animation'),
          ),
          body: Row( // Use Row for horizontal alignment
            children: [
              // Track
              CustomPaint(
                size: trackSize,
                painter: GamePainter(trackPath: trackPath, dots: dots),
              ),
              // Dot List
              Container(
                width: screenSize.width * listWidthRatio,
                color: Colors.white.withOpacity(0.8),
                child: ListView.builder(
                  itemCount: dots.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.circle, color: dots[index].color),
                      title: Text(dots[index].name),
                      trailing: Text("${(dots[index].progress * 100).toStringAsFixed(0)}%"),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Check if a specific key is pressed, e.g., Spacebar
      if (event.logicalKey == LogicalKeyboardKey.space) {
        // Code to handle spacebar press
        // For example, zoom in on a dot or perform any other action
        for (var dotCombo in dots) {
          var dot = dotCombo.dot;
          dot.toggle();
        }
      }
    }
  }
}
