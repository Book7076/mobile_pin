import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOverviewStats {
  final int approvedRestaurants;
  final int rejectedRestaurants;
  final int pendingRestaurants;
  final int totalUsers;

  const AdminOverviewStats({
    required this.approvedRestaurants,
    required this.rejectedRestaurants,
    required this.pendingRestaurants,
    required this.totalUsers,
  });
}

class AdminOverviewService {
  final SupabaseClient _client;

  const AdminOverviewService(this._client);

  Future<AdminOverviewStats> fetchStats() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser != null) {
        final profile = await _client
            .from('users')
            .select('role, user_type')
            .eq('id', currentUser.id)
            .maybeSingle();

        if (profile != null) {
          final role = (profile['user_type'] ?? profile['role'])
              ?.toString()
              .toLowerCase();
          if (role != 'admin' &&
              profile['role']?.toString().toLowerCase() != 'admin') {
            throw StateError('The current user does not have admin access');
          }
        }
      }

      final counts = await Future.wait<int>([
        _client.from('restaurants').count().eq('status', 'approved'),
        _client.from('restaurants').count().eq('status', 'rejected'),
        _client.from('restaurants').count().eq('status', 'pending'),
        _client.from('users').count(),
      ]);

      return AdminOverviewStats(
        approvedRestaurants: counts[0],
        rejectedRestaurants: counts[1],
        pendingRestaurants: counts[2],
        totalUsers: counts[3],
      );
    } catch (e, st) {
      debugPrint('AdminOverviewService.fetchStats error: $e\n$st');
      rethrow;
    }
  }
}

final adminOverviewStatsProvider =
    FutureProvider.autoDispose<AdminOverviewStats>(
      (ref) => AdminOverviewService(Supabase.instance.client).fetchStats(),
    );
