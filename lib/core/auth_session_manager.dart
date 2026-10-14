import '../main.dart';

/// Manages and detects authentication provider states across the application.
/// Supports Supabase Auth detection as well as mock/preview state for testing.
class AuthSessionManager {
  static String? _overrideProvider;
  static String? _overrideSocialName;
  static bool _pendingSocialRegistration = false;
  static String? _pendingSocialProvider;

  /// Sets an explicit provider and name (used after social login or during testing)
  static void setProvider(String provider, {String? socialName}) {
    _overrideProvider = provider.toLowerCase();
    if (socialName != null) {
      _overrideSocialName = socialName;
    }
  }

  /// Clears manual override and falls back to Supabase session
  static void clearOverride() {
    _overrideProvider = null;
    _overrideSocialName = null;
  }

  /// Flag indicating user clicked register from account not found dialog
  static bool get isPendingSocialRegistration => _pendingSocialRegistration;
  static String? get pendingSocialProvider => _pendingSocialProvider;

  static void setPendingSocialRegistration(bool value, [String? provider]) {
    _pendingSocialRegistration = value;
    _pendingSocialProvider = provider;
  }

  static void clearPendingSocialRegistration() {
    _pendingSocialRegistration = false;
    _pendingSocialProvider = null;
  }

  /// Returns current active login provider: 'facebook', 'google', or 'email'
  static String get currentProvider {
    if (_overrideProvider != null && _overrideProvider!.isNotEmpty) {
      return _overrideProvider!;
    }

    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        // 1. Check appMetadata['provider']
        final appMeta = user.appMetadata;
        final provider = appMeta['provider']?.toString().toLowerCase();
        if (provider != null) {
          if (provider.contains('facebook')) return 'facebook';
          if (provider.contains('google')) return 'google';
          if (provider == 'email') return 'email';
        }

        // 2. Check appMetadata['providers'] list
        final providers = appMeta['providers'] as List<dynamic>?;
        if (providers != null) {
          for (final p in providers) {
            final str = p.toString().toLowerCase();
            if (str.contains('facebook')) return 'facebook';
            if (str.contains('google')) return 'google';
          }
        }

        // 3. Check identities list
        final identities = user.identities;
        if (identities != null) {
          for (final identity in identities) {
            final idProvider = identity.provider.toLowerCase();
            if (idProvider.contains('facebook')) return 'facebook';
            if (idProvider.contains('google')) return 'google';
          }
        }

        // 4. Check userMetadata
        final userMeta = user.userMetadata;
        if (userMeta != null) {
          final p = (userMeta['provider'] ?? userMeta['iss'])?.toString().toLowerCase();
          if (p != null) {
            if (p.contains('facebook')) return 'facebook';
            if (p.contains('google')) return 'google';
          }
        }
      }
    } catch (_) {
      // Supabase not ready or in mock mode
    }

    // Default fallback
    return 'email';
  }

  /// Returns user's social profile display name if available
  static String get socialUserName {
    if (_overrideSocialName != null && _overrideSocialName!.isNotEmpty) {
      return _overrideSocialName!;
    }

    try {
      final user = supabase.auth.currentUser;
      if (user != null && user.userMetadata != null) {
        final meta = user.userMetadata!;
        final fullName = meta['full_name'] ?? meta['name'] ?? meta['user_name'];
        if (fullName != null && fullName.toString().isNotEmpty) {
          return fullName.toString();
        }
      }
    } catch (_) {}

    return 'Emma Carter';
  }
}
