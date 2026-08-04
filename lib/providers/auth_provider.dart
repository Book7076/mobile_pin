import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../models/user_model.dart';

final authUserProvider = FutureProvider<UserModel?>((ref) async {
  final session = supabase.auth.currentSession;
  if (session == null) return null;

  try {
    final response = await supabase
        .from('users')
        .select()
        .eq('id', session.user.id)
        .single();
    
    return UserModel.fromJson(response);
  } catch (e) {
    return null;
  }
});
