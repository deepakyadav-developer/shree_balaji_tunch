import 'package:flutter/gestures.dart';

class CustomGestureRecognizer extends OneSequenceGestureRecognizer {
  double maxScreenOffsetX;
  double edgeMargin = 20;

  CustomGestureRecognizer({required this.maxScreenOffsetX});

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (event.position.dx < edgeMargin ||
        event.position.dx > (maxScreenOffsetX - edgeMargin)) {
      print("CustomGestureRecognizer: At the Edge.");
      return;
    }
    print("CustomGestureRecognizer: Inside Safe Zone");
    startTrackingPointer(event.pointer, event.transform);
    resolve(GestureDisposition.accepted);
    stopTrackingPointer(event.pointer);
  }

  @override
  String get debugDescription => 'CustomGestureRecognizer';

  @override
  void didStopTrackingLastPointer(int pointer) {
    // No additional tracking needed
  }

  @override
  void handleEvent(PointerEvent event) {
    // Event handling is done in addAllowedPointer
  }
}
