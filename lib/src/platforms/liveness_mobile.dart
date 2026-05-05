import 'dart:async';

import 'package:camera/camera.dart' as cam;
import 'package:facial_liveness_verification/facial_liveness_verification.dart'
    as plugin;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'liveness_api.dart';

class _MobileLivenessService implements LivenessService {
  final plugin.LivenessDetector _detector;
  final StreamController<LivenessState> _ctrl =
      StreamController<LivenessState>.broadcast();
  StreamSubscription<dynamic>? _sub;

  _MobileLivenessService()
    : _detector = plugin.LivenessDetector(
        const plugin.LivenessConfig(
          challenges: [
            plugin.ChallengeType.blink,
            plugin.ChallengeType.smile,
            plugin.ChallengeType.turnLeft,
          ],
          enableAntiSpoofing: true,
          challengeTimeout: Duration(seconds: 15),
        ),
      );

  @override
  Stream<LivenessState> get onState => _ctrl.stream;

  LivenessState _mapPluginState(dynamic s) {
    try {
      final pluginType = s.type as plugin.LivenessStateType?;
      LivenessStateType mapped;
      switch (pluginType) {
        case plugin.LivenessStateType.initialized:
          mapped = LivenessStateType.initialized;
          break;
        case plugin.LivenessStateType.detecting:
          mapped = LivenessStateType.detecting;
          break;
        case plugin.LivenessStateType.noFace:
          mapped = LivenessStateType.noFace;
          break;
        case plugin.LivenessStateType.faceDetected:
          mapped = LivenessStateType.faceDetected;
          break;
        case plugin.LivenessStateType.positioning:
          mapped = LivenessStateType.positioning;
          break;
        case plugin.LivenessStateType.positioned:
          mapped = LivenessStateType.positioned;
          break;
        case plugin.LivenessStateType.challengeInProgress:
          mapped = LivenessStateType.challengeInProgress;
          break;
        case plugin.LivenessStateType.challengeCompleted:
          mapped = LivenessStateType.challengeCompleted;
          break;
        case plugin.LivenessStateType.completed:
          mapped = LivenessStateType.completed;
          break;
        case plugin.LivenessStateType.error:
        default:
          mapped = LivenessStateType.error;
      }

      return LivenessState(
        mapped,
        message: s.error?.message ?? pluginType?.toString(),
        challenge: s.currentChallenge?.instruction,
      );
    } catch (e) {
      return LivenessState(
        LivenessStateType.error,
        message: 'Plugin mapping error: $e',
      );
    }
  }

  @override
  Future<void> initialize() async {
    // Request camera permission on mobile before initializing detector
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _ctrl.add(
        LivenessState(
          LivenessStateType.error,
          message: 'Camera permission is required for facial verification.',
        ),
      );
      return;
    }

    _sub = _detector.stateStream.listen((s) {
      _ctrl.add(_mapPluginState(s));
    });

    await _detector.initialize();
  }

  @override
  Future<void> start() => _detector.start();

  @override
  Future<void> stop() => _detector.stop();

  @override
  Widget? buildPreview(BuildContext context) {
    final controller = _detector.cameraController;
    if (controller == null) return const ColoredBox(color: Colors.black);
    return cam.CameraPreview(controller);
  }

  @override
  Rect? get faceBoundingBox => _detector.faceBoundingBox;

  @override
  Size? get previewSize => _detector.cameraController?.value.previewSize;

  @override
  Rect? convertImageRectToScreenRect(
    Rect imageRect,
    Size previewSize,
    Size screenSize,
  ) {
    try {
      return plugin.CoordinateUtils.convertImageRectToScreenRect(
        imageRect,
        previewSize,
        screenSize,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _detector.dispose();
    _ctrl.close();
  }
}

LivenessService createPlatformLivenessService() => _MobileLivenessService();
