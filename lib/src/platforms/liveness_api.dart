import 'package:flutter/material.dart';

enum LivenessStateType {
  initialized,
  detecting,
  noFace,
  faceDetected,
  positioning,
  positioned,
  challengeInProgress,
  challengeCompleted,
  completed,
  error,
}

class LivenessState {
  final LivenessStateType type;
  final String? message;
  final String? challenge;

  LivenessState(this.type, {this.challenge, this.message});
}

abstract class LivenessService {
  /// Initialize platform resources (request permissions on mobile, etc.).
  Future<void> initialize();

  Future<void> start();
  Future<void> stop();
  Stream<LivenessState> get onState;

  /// Widget used as the camera/preview surface when available.
  Widget? buildPreview(BuildContext context);

  /// Bounding box for the detected face in image coordinates (if available).
  Rect? get faceBoundingBox;

  /// The camera preview image size used for coordinate mapping.
  Size? get previewSize;

  /// Convert an image-space bounding rect to screen coordinates.
  Rect? convertImageRectToScreenRect(
    Rect imageRect,
    Size previewSize,
    Size screenSize,
  );

  void dispose();
}
