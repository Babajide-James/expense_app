import 'dart:async';

import 'package:camera/camera.dart';
import 'package:facial_liveness_verification/facial_liveness_verification.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../state/app_scope.dart';
import '../widgets/common_widgets.dart';
import 'verification_success_screen.dart';

class BiometricLivenessScreen extends StatefulWidget {
  const BiometricLivenessScreen({super.key});

  @override
  State<BiometricLivenessScreen> createState() =>
      _BiometricLivenessScreenState();
}

class _BiometricLivenessScreenState extends State<BiometricLivenessScreen> {
  late final LivenessDetector _detector;
  StreamSubscription<LivenessState>? _subscription;
  LivenessStateType? _stateType;
  String _status = 'Initializing camera...';
  String _challenge = 'Position your face inside the guide';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _detector = LivenessDetector(
      const LivenessConfig(
        challenges: [
          ChallengeType.smile,
          ChallengeType.blink,
          ChallengeType.turnLeft,
        ],
        enableAntiSpoofing: true,
        challengeTimeout: Duration(seconds: 15),
      ),
    );
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Request camera permission first
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error =
              'Camera permission is required for facial verification. '
              'Please enable it in app settings.';
        });
        return;
      }

      _subscription = _detector.stateStream.listen(_handleState);
      await _detector.initialize();
      await _detector.start();
      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (error) {
      // Cancel subscription if initialization fails to prevent memory leaks
      await _subscription?.cancel();
      _subscription = null;

      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _handleState(LivenessState state) {
    if (!mounted) return;

    setState(() {
      _stateType = state.type;
      _status = _messageForState(state);
      _challenge =
          state.currentChallenge?.instruction ??
          'Keep your face steady and follow the next instruction';
      _error = state.type == LivenessStateType.error
          ? state.error?.message ?? 'Verification failed'
          : null;
    });

    if (state.type == LivenessStateType.completed) {
      AppScope.of(context).markBiometricVerified(true);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const VerificationSuccessScreen(
            title: 'Verification Successful',
            message: 'Biometric login is now enabled for this device.',
            buttonLabel: 'Go to Settings',
          ),
        ),
      );
    }
  }

  String _messageForState(LivenessState state) {
    switch (state.type) {
      case LivenessStateType.initialized:
        return 'Camera ready';
      case LivenessStateType.detecting:
        return 'Looking for a face';
      case LivenessStateType.noFace:
        return 'No face detected';
      case LivenessStateType.faceDetected:
        return 'Face detected';
      case LivenessStateType.positioning:
        return 'Move closer and center your face';
      case LivenessStateType.positioned:
        return 'Face aligned correctly';
      case LivenessStateType.challengeInProgress:
        return 'Challenge in progress';
      case LivenessStateType.challengeCompleted:
        return 'Challenge completed';
      case LivenessStateType.completed:
        return 'Verification complete';
      case LivenessStateType.error:
        return state.error?.message ?? 'Verification error';
    }
  }

  void _handleRetry() {
    _disposeCameraResources();
    setState(() {
      _loading = true;
      _error = null;
      _stateType = null;
      _status = 'Initializing camera...';
      _challenge = 'Position your face inside the guide';
    });
    _initialize();
  }

  void _disposeCameraResources() {
    _subscription?.cancel();
    _detector.dispose();
  }

  @override
  void dispose() {
    _disposeCameraResources();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final overlayRect = _buildFaceOverlayRect(context);
    final preview = _detector.cameraController != null
        ? CameraPreview(_detector.cameraController!)
        : const ColoredBox(color: Colors.black);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: preview),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Facial Recognition',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: SizedBox(
                      height: 320,
                      width: 260,
                      child: CustomPaint(
                        painter: _FaceGuidePainter(
                          faceRect: overlayRect,
                          screenSize: screenSize,
                          isError: _error != null,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  WhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _status,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F254B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error ?? _challenge,
                          style: TextStyle(
                            color: _error != null
                                ? const Color(0xFFD92D20) // Red for error
                                : const Color(0xFF667085),
                            height: 1.45,
                            fontWeight: _error != null
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: ElevatedButton.icon(
                              onPressed: _handleRetry,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry Verification'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2962E8),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(height: 14),
                        LinearProgressIndicator(
                          minHeight: 7,
                          value: _progressForState(_stateType),
                          color: const Color(0xFF2962E8),
                          backgroundColor: const Color(0xFFD9E3F3),
                        ),
                        const SizedBox(height: 14),
                        if (_loading)
                          const Text(
                            'Preparing detector...',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          )
                        else
                          Text(
                            'Current state: ${_stateType?.name ?? 'starting'}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Rect? _buildFaceOverlayRect(BuildContext context) {
    final faceBox = _detector.faceBoundingBox;
    final previewSize = _detector.cameraController?.value.previewSize;
    if (faceBox == null || previewSize == null) return null;

    return CoordinateUtils.convertImageRectToScreenRect(
      faceBox,
      previewSize,
      MediaQuery.sizeOf(context),
    );
  }

  double _progressForState(LivenessStateType? state) {
    switch (state) {
      case LivenessStateType.initialized:
        return 0.1;
      case LivenessStateType.detecting:
      case LivenessStateType.noFace:
        return 0.2;
      case LivenessStateType.faceDetected:
      case LivenessStateType.positioning:
        return 0.4;
      case LivenessStateType.positioned:
        return 0.55;
      case LivenessStateType.challengeInProgress:
        return 0.75;
      case LivenessStateType.challengeCompleted:
        return 0.9;
      case LivenessStateType.completed:
        return 1;
      case LivenessStateType.error:
      case null:
        return 0;
    }
  }
}

class _FaceGuidePainter extends CustomPainter {
  const _FaceGuidePainter({
    required this.faceRect,
    required this.screenSize,
    required this.isError,
  });

  final Rect? faceRect;
  final Size screenSize;
  final bool isError;

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = isError ? const Color(0xFFF97066) : const Color(0xFF5B8CFF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final target = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.85,
      height: size.height * 0.82,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(target, const Radius.circular(180)),
      guidePaint,
    );

    if (faceRect != null) {
      final scaleX = size.width / screenSize.width;
      final scaleY = size.height / screenSize.height;
      final mapped = Rect.fromLTRB(
        faceRect!.left * scaleX,
        faceRect!.top * scaleY,
        faceRect!.right * scaleX,
        faceRect!.bottom * scaleY,
      );
      final facePaint = Paint()
        ..color = const Color(0xFF12B76A)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(
        RRect.fromRectAndRadius(mapped, const Radius.circular(120)),
        facePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FaceGuidePainter oldDelegate) {
    return oldDelegate.faceRect != faceRect ||
        oldDelegate.isError != isError ||
        oldDelegate.screenSize != screenSize;
  }
}
