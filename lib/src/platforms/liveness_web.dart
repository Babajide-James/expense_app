// Web implementation using faceapidetectionweb for face detection.
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;
// 'dart:ui' is not required here; view registry is handled via
// `platform_view_registry.dart` which conditionally exports a web shim.

import 'package:faceapidetectionweb/faceapidetectionweb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'liveness_api.dart';
import 'platform_view_registry.dart';

class _WebLivenessService implements LivenessService {
  final StreamController<LivenessState> _ctrl =
      StreamController<LivenessState>.broadcast();
  late JSBridge _bridge;
  bool _faceDetectedAndCompleted = false;
  bool _challengeInProgress = false;

  // Html video element and registered view id for embedding in Flutter web
  html.VideoElement? _videoElement;
  String? _viewType;
  bool _viewRegistered = false;

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
    // Register the Html video element so Flutter can render it with HtmlElementView
    _ensureVideoElementRegistered();

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
        // When JS returns a photo data URL, emit it as part of a state update
        try {
          _ctrl.add(
            LivenessState(
              LivenessStateType.completed,
              message: 'Photo captured',
              photo: original,
            ),
          );
        } catch (_) {}
      },
      onFaceDetectionStatus: (bool detected, List<Map<String, dynamic>> expressions) {
        if (!detected) {
          // Reset challenge state when no face
          _faceDetectedAndCompleted = false;
          _challengeInProgress = false;
          _ctrl.add(
            LivenessState(
              LivenessStateType.noFace,
              message: 'No face detected.',
            ),
          );
          return;
        }

        // At least one face detected
        if (!_challengeInProgress) {
          _challengeInProgress = true;
          _ctrl.add(
            LivenessState(
              LivenessStateType.faceDetected,
              message: 'Face detected on web.',
            ),
          );
          // Prompt user for a simple smile challenge (mirrors mobile behavior)
          _ctrl.add(
            LivenessState(
              LivenessStateType.challengeInProgress,
              challenge: 'Please smile for the camera',
            ),
          );
          return;
        }

        // If challenge is in progress, inspect expressions to see if smile/happy detected
        if (expressions.isNotEmpty) {
          final first = expressions.first;
          double happyScore = 0.0;
          try {
            final val =
                first['happy'] ?? first['smile'] ?? first['happiness'] ?? 0;
            if (val is num) happyScore = val.toDouble();
          } catch (_) {}

          if (happyScore >= 0.6 && !_faceDetectedAndCompleted) {
            _faceDetectedAndCompleted = true;
            _ctrl.add(
              LivenessState(
                LivenessStateType.challengeCompleted,
                message: 'Smile detected',
              ),
            );
            // Trigger a photo capture when challenge is completed.
            try {
              _bridge.takePhoto();
            } catch (_) {}
            // Give a short delay then complete
            Future.delayed(const Duration(milliseconds: 300), () {
              _ctrl.add(
                LivenessState(
                  LivenessStateType.completed,
                  message: 'Liveness verification completed on web.',
                ),
              );
            });
            return;
          } else {
            // Update challenge message to encourage a smile
            _ctrl.add(
              LivenessState(
                LivenessStateType.challengeInProgress,
                challenge: 'Please smile more',
              ),
            );
          }
        }
      },
    );
    // Give the bridge time to initialize
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _ensureVideoElementRegistered() {
    if (_viewRegistered) return;

    _viewType = 'web-camera-${DateTime.now().millisecondsSinceEpoch}';
    _videoElement = html.VideoElement()
      ..id = 'flutter-web-camera-video'
      ..autoplay = true
      ..muted = true
      ..setAttribute('playsinline', 'true');
    // Make the video element responsive inside the HtmlElementView
    try {
      _videoElement!.style.width = '100%';
      _videoElement!.style.height = '100%';
      _videoElement!.style.objectFit = 'cover';
    } catch (_) {}

    // Register the view factory so Flutter's HtmlElementView can render the element
    registerWebViewFactory(_viewType!, (int viewId) => _videoElement!);
    try {
      // Expose the element to JS so the JS bridge can find the same element
      js.context['flutterWebCameraVideo'] = _videoElement;
    } catch (_) {}
    _viewRegistered = true;
    // Notify listeners so the UI can rebuild and show the HtmlElementView preview
    try {
      _ctrl.add(
        LivenessState(
          LivenessStateType.initialized,
          message: 'Video element ready.',
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> start() async {
    try {
      // On web, the browser handles camera permission through getUserMedia.
      // If available, query permission state first so we can show a helpful
      // error when the user has previously denied access.
      String perm = 'unknown';
      try {
        final q = js.context['queryCameraPermission'];
        if (q != null) {
          final res = await js_util.promiseToFuture(
            js.context.callMethod('queryCameraPermission'),
          );
          if (res is String) perm = res;
        }
      } catch (_) {}

      if (perm == 'denied') {
        _ctrl.add(
          LivenessState(
            LivenessStateType.error,
            message:
                'Camera permission is denied for this site. Please enable camera access in your browser site settings and reload the page.',
          ),
        );
        return;
      }

      // Prepare video element and bridge; openCamera() will prompt when needed.
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
    try {
      _bridge.closeCamera();
    } catch (_) {}

    // Clear video srcObject if we created it
    try {
      _videoElement?.pause();
      _videoElement?.srcObject = null;
    } catch (_) {}

    _ctrl.add(LivenessState(LivenessStateType.error, message: 'Stopped.'));
  }

  @override
  Widget? buildPreview(BuildContext context) {
    if (_viewRegistered && _viewType != null) {
      // Render the Html video element inside the Flutter widget tree
      return HtmlElementView(viewType: _viewType!);
    }

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
