import "package:flutter/material.dart";

/// And extended Offset class for use with track generation
class TrackOffset extends Offset {
  /// The id of this track offset (index in the list of track offsets)
  final int id;

  /// Returns true if this is the start of the track
  bool get isStart => id == 0;

  /// Returns true if this is the start of a turn
  bool isTurnStart = false;

  /// Returns true if this is the end of a turn
  bool isTurnEnd = false;
  
  /// Constructor
  TrackOffset({required this.id, required double dx, required double dy}) : super(dx, dy);

  /// Constructor for a zero offset
  TrackOffset.zero() : id = 0, super(0, 0);

  /// Create a list of track offsets from a list of offsets
  static List<TrackOffset> createList(List<Offset> offsets) {
    final List<TrackOffset> list = [];
    for (int i = 0; i < offsets.length; i++) {
      list.add(create(offsets[i], i));
    }
    return list;
  }

  /// Create a track offset from an offset
  static TrackOffset create(Offset offset, int id) {
    return TrackOffset(id: id, dx: offset.dx, dy: offset.dy);
  }
}