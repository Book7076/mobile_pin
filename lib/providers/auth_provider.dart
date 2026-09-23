import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../core/mock_data.dart';
import '../models/user_model.dart';

class AuthStateNotifier extends StateNotifier<UserModel?> {
  AuthStateNotifier() : super(MockData.demoUser) {
    _initSession();
  }

  void _initSession() {
    try {
      final session = supabase.auth.currentSession;
      if (session != null) {
        // If supabase session exists, try to load
        _loadSupabaseUser(session.user.id, session.user.email ?? '');
      }
    } catch (_) {
      // Offline fallback: keep default demo user
    }
  }

  Future<void> _loadSupabaseUser(String id, String email) async {
    try {
      final response = await supabase.from('users').select().eq('id', id).single();
      state = UserModel.fromJson(response);
    } catch (_) {
      state = UserModel(
        id: id,
        email: email,
        name: email.split('@').first,
        role: 'customer',
        swipeCount: 0,
      );
    }
  }

  // Switch demo account to test different roles (user, owner, admin)
  void switchDemoRole(String role) {
    if (role == 'owner') {
      state = MockData.demoOwner;
    } else if (role == 'admin') {
      state = MockData.demoAdmin;
    } else {
      state = MockData.demoUser;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('กรุณากรอกอีเมลและรหัสผ่าน');
    }

    // Check demo accounts
    if (email.contains('admin')) {
      state = MockData.demoAdmin;
      return true;
    } else if (email.contains('owner')) {
      state = MockData.demoOwner;
      return true;
    }

    try {
      final res = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (res.user != null) {
        await _loadSupabaseUser(res.user!.id, res.user!.email ?? email);
        return true;
      }
    } catch (_) {
      // If error or offline, fallback to login simulation
      if (password.length < 6) {
        throw Exception('อีเมลหรือรหัสผ่านไม่ถูกต้อง');
      }
      state = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@').first,
        role: email.contains('owner') ? 'owner' : (email.contains('admin') ? 'admin' : 'customer'),
      );
      return true;
    }
    return true;
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role, // 'user' or 'owner'
  }) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('กรุณากรอกข้อมูลให้ครบถ้วน');
    }

    try {
      final res = await supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );
      if (res.user != null) {
        final newUser = UserModel(
          id: res.user!.id,
          email: email,
          name: name,
          phone: phone,
          role: role,
        );
        state = newUser;
        return true;
      }
    } catch (_) {
      // Local demo fallback
      state = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        phone: phone,
        role: role,
      );
      return true;
    }
    return true;
  }

  // Update profile
  void updateProfile({
    required String name,
    required String phone,
    required List<String> dietaryPreferences,
  }) {
    if (state != null) {
      state = state!.copyWith(
        name: name,
        phone: phone,
        dietaryPreferences: dietaryPreferences,
      );
    }
  }

  // Increment swipe count
  void incrementSwipeCount() {
    if (state != null) {
      state = state!.copyWith(swipeCount: state!.swipeCount + 1);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (_) {}
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthStateNotifier, UserModel?>((ref) {
  return AuthStateNotifier();
});

// Backward compatibility alias
final authUserProvider = FutureProvider<UserModel?>((ref) async {
  return ref.watch(authProvider);
});
