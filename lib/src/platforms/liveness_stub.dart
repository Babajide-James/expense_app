import 'dart:async';

import 'package:flutter/material.dart';

import 'liveness_api.dart';

class _StubLivenessService implements LivenessService {
  final StreamController<LivenessState> _ctrl =
      StreamController<LivenessState>.broadcast();

  @override
  Stream<LivenessState> get onState => _ctrl.stream;

  @override
  Future<void> initialize() async {
    _ctrl.add(
      LivenessState(
        LivenessStateType.error,
        message: 'Liveness not supported on this platform.',
      ),
    );
  }

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Widget? buildPreview(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.block, size: 56, color: Colors.grey),
        SizedBox(height: 8),
        Text('Liveness unavailable'),
      ],
    ),
  );

  @override
  Rect? get faceBoundingBox => null;

  @override
  Size? get previewSize => null;

  @override
  Rect? convertImageRectToScreenRect(
    Rect imageRect,
    Size previewSize,
    Size screenSize,
  ) => null;

  @override
  void dispose() {
    _ctrl.close();
  }
}

LivenessService createPlatformLivenessService() => _StubLivenessService();
