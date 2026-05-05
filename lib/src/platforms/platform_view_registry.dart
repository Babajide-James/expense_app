// Conditional export to pick the correct platform view registry implementation.
export 'platform_view_registry_stub.dart'
    if (dart.library.html) 'platform_view_registry_web.dart';
