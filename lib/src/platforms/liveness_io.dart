import 'dart:io';

import 'liveness_api.dart';
import 'liveness_desktop.dart' as desktop;
import 'liveness_mobile.dart' as mobile;
import 'liveness_stub.dart' as stub;

LivenessService createPlatformLivenessService() {
  if (Platform.isAndroid || Platform.isIOS) {
    return mobile.createPlatformLivenessService();
  } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    return desktop.createPlatformLivenessService();
  }
  return stub.createPlatformLivenessService();
}
