// Web implementation using faceapidetectionweb for face detection.
import 'dart:async';

import 'package:faceapidetectionweb/faceapidetectionweb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'liveness_api.dart';

class _WebLivenessService implements LivenessService {
  final StreamController<LivenessState> _ctrl =
      StreamController<LivenessState>.broadcast();
  late JSBridge _bridge;
  bool _faceDetectedAndCompleted = false;

  @override
  Stream<LivenessState> get onState => _ctrl.stream;

  @override
  Future<void> initialize() async {
    try {
      _bridge = JSBridge();
      // Don't call initialize yet - wait for start()
      _ctrl.add(
        LivenessState(
          LivenessStateType.initialized,
          message: 'Web liveness initialized. Please allow camera access.',
        ),
      );
    } on MissingPluginException catch (e) {
      _ctrl.add(
        LivenessState(
          LivenessStateType.error,
          message:
              'Camera plugin not available on web. Ensure camera_web is installed. $e',
        ),
      );
    } catch (e) {
      _ctrl.add(
        LivenessState(
          LivenessStateType.error,
          message: 'Web camera initialization error: $e',
        ),
      );
    }
  }

  Future<void> _initializeCamera() async {
    // Set up all callbacks before initializing
    _bridge.initialize(
      onCameraStateChanged: (bool isOpen) {
        if (isOpen) {
          _ctrl.add(
            LivenessState(
              LivenessStateType.detecting,
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
            message: 'Camera error on web: $error',
          ),
        );
      },
      onPhotoTaken: (String original, String second) {
        // Not used for liveness
      },
      onFaceDetectionStatus:
          (bool detected, List<Map<String, dynamic>> expressions) {
            if (detected && !_faceDetectedAndCompleted) {
              _faceDetectedAndCompleted = true;
              _ctrl.add(
                LivenessState(
                  LivenessStateType.faceDetected,
                  message: 'Face detected on web.',
                ),
              );
              // Complete immediately on face detection (match desktop/mobile behavior)
              _ctrl.add(
                LivenessState(
                  LivenessStateType.completed,
                  message: 'Liveness verification completed on web.',
                ),
              );
            } else if (!detected) {
              _faceDetectedAndCompleted = false;
              _ctrl.add(
                LivenessState(
                  LivenessStateType.noFace,
                  message: 'No face detected.',
                ),
              );
            }
          },
    );
    // Give the bridge time to initialize
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> start() async {
    try {
      final permissionStatus = await Permission.camera.request();
      if (permissionStatus != PermissionStatus.granted) {
        _ctrl.add(
          LivenessState(
            LivenessStateType.error,
            message:
                'Camera permission denied. Please allow camera access in your browser settings.',
          ),
        );
        return;
      }

      // Initialize the bridge callbacks right before opening camera
      await _initializeCamera();

      // Add a retry mechanism for camera access
      int retries = 0;
      bool success = false;

      while (retries < 3 && !success) {
        try {
          success = await _bridge.openCamera();
          if (success) {
            break;
          }
        } catch (e) {
          // Catch any JS errors and retry
          print('Camera open attempt ${retries + 1} failed: $e');
        }

        if (!success) {
          retries++;
          if (retries < 3) {
            await Future.delayed(Duration(milliseconds: 500 * retries));
          }
        }
      }

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
            message:
                'Failed to access camera. Please check:\n1. Browser permissions\n2. Camera is available\n3. Try allowing camera access when prompted',
          ),
        );
      }
    } catch (e) {
      _ctrl.add(
        LivenessState(
          LivenessStateType.error,
          message: 'Error starting camera on web: $e',
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
