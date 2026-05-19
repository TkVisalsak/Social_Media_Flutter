/// Central server configuration.
///
/// To switch between local dev and production, change [useLocalServer].
/// To update your machine's WiFi IP, change [_localIp].
class AppConfig {
  AppConfig._();

  /// true  → local backend (device must be on the same WiFi as your machine)
  /// false → deployed production backend on Render
  static const bool useLocalServer = true;

  // ── Local dev ──────────────────────────────────────────────────────────────
  // Your machine's LAN IP: run `hostname -I | awk '{print $1}'` to get it.
  static const String _localIp   = 'localhost';
  static const String _localPort = '5001';

  // ── Production ─────────────────────────────────────────────────────────────
  static const String _prodBase = 'https://social-media-uav6.onrender.com';

  // ── Resolved ───────────────────────────────────────────────────────────────
  static String get apiBaseUrl =>
      useLocalServer ? 'http://$_localIp:$_localPort/api' : '$_prodBase/api';

  static String get socketUrl =>
      useLocalServer ? 'http://$_localIp:$_localPort' : _prodBase;
}
