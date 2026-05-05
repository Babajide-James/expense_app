// Web implementation that registers a view factory using JS interop.
// Use `dart:js` to call the global `platformViewRegistry.registerViewFactory`
// without referencing `ui.platformViewRegistry` directly (avoids undefined
// symbol on some SDK/toolchain combinations).
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

void registerWebViewFactory(String viewType, dynamic Function(int) factory) {
  try {
    final registry = js.context['platformViewRegistry'];
    if (registry != null) {
      registry.callMethod('registerViewFactory', [
        viewType,
        js.allowInterop(factory),
      ]);
      return;
    }
  } catch (_) {}

  // Fallback common global names used by some engine variants.
  try {
    final alt =
        js.context['flutterPlatformViewRegistry'] ??
        js.context['flutterWebPlatformViewRegistry'];
    if (alt != null) {
      alt.callMethod('registerViewFactory', [
        viewType,
        js.allowInterop(factory),
      ]);
      return;
    }
  } catch (_) {}
}
