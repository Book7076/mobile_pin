import 'auth_session_manager.dart';

/// Manages social account connections (Facebook and Google) for the current user.
/// Strictly enforces that only one social account (either Facebook or Google)
/// can be linked to an account at any given time.
class SocialLinkManager {
  static String? _linkedProvider;
  static String? _linkedName;
  static String? _linkedEmail;

  /// Returns current linked provider: 'facebook', 'google', or null (if neither is linked)
  static String? get linkedProvider {
    if (_linkedProvider != null) {
      return _linkedProvider == 'none' ? null : _linkedProvider;
    }
    // Fallback: If user originally signed in via social login, that provider is linked
    final session = AuthSessionManager.currentProvider;
    if (session == 'facebook' || session == 'google') {
      return session;
    }
    return null;
  }

  static String get linkedName {
    if (_linkedName != null && _linkedName!.isNotEmpty) {
      return _linkedName!;
    }
    return AuthSessionManager.socialUserName;
  }

  static String get linkedEmail {
    if (_linkedEmail != null && _linkedEmail!.isNotEmpty) {
      return _linkedEmail!;
    }
    return 'Emma.carter@gmail.com';
  }

  static bool get isFacebookLinked => linkedProvider == 'facebook';
  static bool get isGoogleLinked => linkedProvider == 'google';
  static bool get hasAnyLinked => linkedProvider != null;

  /// Returns true if the given provider is allowed to be linked
  static bool canLink(String provider) {
    final current = linkedProvider;
    if (current == null) return true;
    return current.toLowerCase() == provider.toLowerCase();
  }

  /// Links a provider ('facebook' or 'google').
  /// Returns false if another provider is already linked.
  static bool linkProvider(String provider, {String? name, String? email}) {
    final p = provider.toLowerCase();
    final current = linkedProvider;
    if (current != null && current != p) {
      // Cannot link because another provider is already linked!
      return false;
    }
    _linkedProvider = p;
    if (name != null) _linkedName = name;
    if (email != null) _linkedEmail = email;
    return true;
  }

  /// Unlinks the current provider
  static void unlinkProvider() {
    _linkedProvider = 'none';
    _linkedName = null;
    _linkedEmail = null;
  }

  /// Resets state (primarily for tests)
  static void reset() {
    _linkedProvider = null;
    _linkedName = null;
    _linkedEmail = null;
  }
}
