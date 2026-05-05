import 'liveness_api.dart';

import 'liveness_stub.dart'
    if (dart.library.html) 'liveness_web.dart'
    if (dart.library.io) 'liveness_io.dart';

LivenessService createLivenessService() => createPlatformLivenessService();
