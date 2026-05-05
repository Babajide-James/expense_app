// Stub implementation for non-web platforms.
// This file is intentionally lightweight; real registration happens on web.
void registerWebViewFactory(String viewType, dynamic Function(int) factory) {
  // No-op on non-web platforms.
}
