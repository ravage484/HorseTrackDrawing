import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For RawKeyboardListener
import 'dart:math';
import 'models/dot.dart'; // Adjust the import path based on your project structure
import 'widgets/track_and_dot_painter.dart'; // Adjust the import path
import 'utils/utils_colors.dart'; // Adjust the import path
import 'package:horse_track_drawing/resources/kentucky_derby_winners.dart'; // Adjust the import path

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with TickerProviderStateMixin {
  List<Dot> dots = [];
  int numberOfDots = 20; // Replace 10 with the desired number of dots
  final FocusNode _focusNode = FocusNode();
  
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

      // Initialize the controller
      dot.initializeController(this);

      // Add the dot to the list
      dots.add(dot);
    }

    // Add a listener to each controller
    for (var dot in dots) {
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
    for (var dot in dots) {
      dot.controller.dispose();
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
      screenSize.height * 0.3, // Same as before
    );

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
                painter: TrackAndDotPainter(dots: dots),
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
        for (var dot in dots) {
          dot.controller.toggle();
        }
      }
    }
  }
}
