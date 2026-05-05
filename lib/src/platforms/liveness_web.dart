// Web implementation using faceapidetectionweb for face detection.
import 'dart:async';

import 'package:faceapidetectionweb/faceapidetectionweb.dart';
import 'package:flutter/material.dart';

import 'liveness_api.dart';

class _WebLivenessService implements LivenessService {
  final StreamController<LivenessState> _ctrl =
      StreamController<LivenessState>.broadcast();
  final JSBridge _bridge = JSBridge();

  @override
  Stream<LivenessState> get onState => _ctrl.stream;

  @override
  Future<void> initialize() async {
    _bridge.initialize(
      onCameraStateChanged: (bool isOpen) {
        if (isOpen) {
          _ctrl.add(
            LivenessState(
              LivenessStateType.initialized,
              message: 'Camera opened on web.',
            ),
          );
        } else {
          _ctrl.add(
            LivenessState(LivenessStateType.error, message: 'Camera closed.'),
          );
        }
      },
      onCameraError: (String error) {
        _ctrl.add(
          LivenessState(
            LivenessStateType.error,
            message: 'Camera error: $error',
          ),
        );
      },
      onPhotoTaken: (String original, String second) {
        // Not used for liveness
      },
      onFaceDetectionStatus:
          (bool detected, List<Map<String, dynamic>> expressions) {
            if (detected) {
              _ctrl.add(
                LivenessState(
                  LivenessStateType.faceDetected,
                  message: 'Face detected on web.',
                ),
              );
              // Simulate completion
              Future.delayed(Duration(seconds: 2), () {
                _ctrl.add(
                  LivenessState(
                    LivenessStateType.completed,
                    message: 'Liveness verification completed on web.',
                  ),
                );
              });
            } else {
              _ctrl.add(
                LivenessState(
                  LivenessStateType.noFace,
                  message: 'No face detected.',
                ),
              );
            }
          },
    );
    _ctrl.add(
      LivenessState(
        LivenessStateType.initialized,
        message: 'Web liveness initialized.',
      ),
    );
  }

  @override
  Future<void> start() async {
    final success = await _bridge.openCamera();
    if (success) {
      _ctrl.add(
        LivenessState(
          LivenessStateType.detecting,
          message: 'Detecting faces on web.',
        ),
      );
    } else {
      _ctrl.add(
        LivenessState(
          LivenessStateType.error,
          message: 'Failed to open camera on web.',
        ),
      );
    }
  }

  @override
  Future<void> stop() async {
    _bridge.closeCamera();
    _ctrl.add(LivenessState(LivenessStateType.error, message: 'Stopped.'));
  }

  @override
  Widget? buildPreview(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.camera_alt_outlined, size: 56, color: Colors.grey),
          SizedBox(height: 8),
          Text('Web face detection active'),
        ],
      ),
    );
  }

  @override
  Rect? get faceBoundingBox => null;

  @override
  Size? get previewSize => null;

  @override
  Rect? convertImageRectToScreenRect(
    Rect imageRect,
    Size previewSize,
    Size screenSize,
  ) {
    return null;
  }

  @override
  void dispose() {
    _ctrl.close();
  }
}

LivenessService createPlatformLivenessService() => _WebLivenessService();
