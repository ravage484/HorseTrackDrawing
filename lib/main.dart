import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For RawKeyboardListener
import 'package:horse_track_drawing/models/track/track.dart';
import 'package:horse_track_drawing/models/track/track_segment.dart';
import 'package:horse_track_drawing/utils/utils_other.dart';
import 'dart:math';
import 'models/vehicle.dart';
import 'widgets/game_painter.dart'; 
import 'utils/utils_colors.dart'; 
import 'resources/configurations.dart';
import 'package:horse_track_drawing/resources/kentucky_derby_winners.dart'; 
import 'package:horse_track_drawing/models/race_entity.dart'; 
import 'package:horse_track_drawing/models/driver.dart';
import 'package:horse_track_drawing/utils/utils_track_generation.dart'; 

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with TickerProviderStateMixin {
  // Initialize the race entities
  List<RaceEntity> raceEntities = [];
  int numberOfRaceEntities = Configurations.numberOfRaceEntities; // Replace 10 with the desired number of dots
  final FocusNode _focusNode = FocusNode();

  // Initialize the game empty track
  Track track = Track(); //Track(trackSegments: trackSegments);
  Size trackSize = const Size(1000, 800);
  bool trackGenerated = false;

  Timer? raceTimer;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // Generate the track path with a standard size, independent of the screen size
    // track = generateTrackPathStandardOval(trackSize);
    // track = generateTrackPathUsingGenerator(trackSize, 9, 500, 5, 5);
    // trackGenerated = true;

    TrackGenerator tg = TrackGenerator(
      area: trackSize,
      numberOfPoints: 9,
      displacement: 500,
      minDistance: 5,
      minAngle: 5,
    );
    track = tg.generateTrack();

    // Copy the list of names
    var names = List<String>.from(KENTUCKY_DERBY_WINNERS); 
    
    // Initialize multiple dots here
    for (int i = 0; i < numberOfRaceEntities; i++) {
      int randomIndex = Random().nextInt(names.length);
      String randomName = names.removeAt(randomIndex);

      // Initialize a dot
      var vehicle = Vehicle(
        name: randomName,
        color: getRandomColor(),
      );

      // Initialize a driver
      Driver driver = generateRandomDriver(randomName);

      // Initialize the dot combo
      var raceEntity = RaceEntity(
        track: track,
        vehicle: vehicle,
        driver: driver,
      );

      // Initialize the controller
      raceEntity.initializeController(this);

      // Adjust the animation duration based on the performance score
      raceEntity.adjustLoopDuration(); 
      
      // Add the dot to the list
      raceEntities.add(raceEntity);
    }

    // Add a listener to each controller
    for (var re in raceEntities) {
      re.controller.addListener(() {
        setState(() {
          // Update the progress of each dot
          re.updateProgress();

          // Sort the dots based on progress
          raceEntities.sort((a, b) => b.progress.compareTo(a.progress)); // Sort based on progress
        });
      });
    }
    startRace();
  }
  void startRace() {
    // Assuming you have a timer or an equivalent mechanism to update your race logic
    raceTimer = Timer.periodic(Duration(milliseconds: 100), (timer) { // Adjust the interval as needed
      for (var re in raceEntities) {
        // Update progress and adjust speed for turn without calling setState
        re.updateProgress();
        re.adjustSpeedForTurn();
      }

      // Now, call setState to reflect any changes in the UI
      setState(() {
        // Sort the dots based on progress, or update any other UI-related state
        raceEntities.sort((a, b) => b.progress.compareTo(a.progress));
      });
    });
  }
  @override
  void dispose() {
    raceTimer?.cancel();
    for (var dotCombo in raceEntities) {
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

    if (!trackGenerated) {
      trackGenerated = true;
      // // track = generateTrackPathUsingGenerator(trackSize,9, 500, 5, 5);
      // TrackGenerator tg = TrackGenerator(
      //   area: trackSize,
      //   numberOfPoints: 9,
      //   displacement: 500,
      //   minDistance: 5,
      //   minAngle: 5,
      // );
      // track = tg.generateTrack();
    }

    return MaterialApp(
      title: 'Race Track Simulation',
      home: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: _handleKeyPress,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Race Track Simulation'),
          ),
          body: Row( // Use Row for horizontal alignment
            children: [
              // Track
              CustomPaint(
                size: trackSize,
                painter: GamePainter(track: track, raceEntities: raceEntities),
              ),
              // Dot List
              Container(
                width: screenSize.width * listWidthRatio,
                color: Colors.white.withOpacity(0.8),
                child: ListView.builder(
                  itemCount: raceEntities.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.circle, color: raceEntities[index].color),
                      title: Text(raceEntities[index].name),
                      trailing: Text("${(raceEntities[index].progress * 100).toStringAsFixed(0)}%"),
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
        for (var re in raceEntities) {
          re.toggle();
        }
      }
    }
  }
}
