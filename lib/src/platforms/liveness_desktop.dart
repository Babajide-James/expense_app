// Desktop implementation using face_detection_tflite for face detection.
import 'dart:async';

import 'package:camera/camera.dart' as cam;
import 'package:face_detection_tflite/face_detection_tflite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'liveness_api.dart';

class _DesktopLivenessService implements LivenessService {
  final StreamController<LivenessState> _ctrl =
      StreamController<LivenessState>.broadcast();
  FaceDetector? _detector;
  cam.CameraController? _cameraController;
  Timer? _detectionTimer;

  @override
  Stream<LivenessState> get onState => _ctrl.stream;

  @override
  Future<void> initialize() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _ctrl.add(
        LivenessState(
          LivenessStateType.error,
          message: 'Camera permission required.',
        ),
      );
      return;
    }

    try {
      final cameras = await cam.availableCameras();
      if (cameras.isEmpty) {
        _ctrl.add(
          LivenessState(
            LivenessStateType.error,
            message: 'No cameras available.',
          ),
        );
        return;
      }

      _cameraController = cam.CameraController(
        cameras.first,
        cam.ResolutionPreset.medium,
      );
      await _cameraController!.initialize();

      _detector = await FaceDetector.create();

      _ctrl.add(
        LivenessState(
          LivenessStateType.initialized,
          message: 'Desktop liveness initialized.',
        ),
      );
    } on MissingPluginException catch (e) {
      _ctrl.add(
        LivenessState(
          LivenessStateType.error,
          message:
              'Camera plugin not registered. Run flutter pub get and rebuild the app. $e',
        ),
      );
    } catch (e) {
      _ctrl.add(
        LivenessState(
          LivenessStateType.error,
          message: 'Desktop camera initialization error: $e',
        ),
      );
    }
  }

  @override
  Future<void> start() async {
    if (_cameraController == null || _detector == null) {
      _ctrl.add(
        LivenessState(LivenessStateType.error, message: 'Not initialized.'),
      );
      return;
    }

    _ctrl.add(
      LivenessState(
        LivenessStateType.detecting,
        message: 'Detecting faces on desktop.',
      ),
    );

    _detectionTimer = Timer.periodic(Duration(milliseconds: 500), (
      timer,
    ) async {
      try {
        final image = await _cameraController!.takePicture();
        final bytes = await image.readAsBytes();
        final faces = await _detector!.detectFaces(bytes);
        if (faces.isNotEmpty) {
          // Complete immediately on face detection (no delay)
          _ctrl.add(
            LivenessState(
              LivenessStateType.faceDetected,
              message: 'Face detected on desktop.',
            ),
          );
          // Stop detection and mark as completed
          timer.cancel();
          _ctrl.add(
            LivenessState(
              LivenessStateType.completed,
              message: 'Liveness verification completed on desktop.',
            ),
          );
        } else {
          _ctrl.add(
            LivenessState(
              LivenessStateType.noFace,
              message: 'No face detected.',
            ),
          );
        }
      } catch (e) {
        _ctrl.add(
          LivenessState(
            LivenessStateType.error,
            message: 'Detection error: $e',
          ),
        );
      }
    });
  }

  @override
  Future<void> stop() async {
    _detectionTimer?.cancel();
    await _cameraController?.dispose();
    await _detector?.dispose();
    _ctrl.add(LivenessState(LivenessStateType.error, message: 'Stopped.'));
  }

  @override
  Widget? buildPreview(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: Text('Camera not initialized'));
    }
    return cam.CameraPreview(_cameraController!);
  }

  @override
  Rect? get faceBoundingBox => null;

  @override
  Size? get previewSize => _cameraController?.value.previewSize;

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
    _detectionTimer?.cancel();
    _cameraController?.dispose();
    _detector?.dispose();
    _ctrl.close();
  }
}

LivenessService createPlatformLivenessService() => _DesktopLivenessService();
