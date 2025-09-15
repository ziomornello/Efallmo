import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';
import '../models/bonus.dart';

class ActivityNotifier extends StateNotifier<AsyncValue<void>> {
  ActivityNotifier(this._supabase, this._userId) : super(const AsyncValue.data(null));

  final SupabaseClient _supabase;
  final String? _userId;

  bool get isLoggedIn => _userId != null;

  Future<void> logStart(Bonus bonus) async {
    if (_userId == null) return;
    try {
      state = const AsyncValue.loading();
      await _supabase.from('user_bonus_activity').insert({
        'user_id': _userId,
        'bonus_id': bonus.id,
        'event': 'start',
        'step': 0,
        'completed': false,
      });

      // Ensure a progress row exists
      await _supabase.from('user_bonus_progress').upsert({
        'user_id': _userId,
        'bonus_id': bonus.id,
        'current_step': 0,
        'completed': false,
        'updated_at': DateTime.now().toIso8601String(),
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveProgress({
    required Bonus bonus,
    required int step,
    required bool completed,
  }) async {
    if (_userId == null) return;
    try {
      state = const AsyncValue.loading();

      await _supabase.from('user_bonus_progress').upsert({
        'user_id': _userId,
        'bonus_id': bonus.id,
        'current_step': step,
        'completed': completed,
        'updated_at': DateTime.now().toIso8601String(),
      });

      await _supabase.from('user_bonus_activity').insert({
        'user_id': _userId,
        'bonus_id': bonus.id,
        'event': completed ? 'complete' : 'progress',
        'step': step,
        'completed': completed,
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final activityProvider = StateNotifierProvider<ActivityNotifier, AsyncValue<void>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  // Watch auth state so the provider rebuilds with a valid userId after login
  final authState = ref.watch(authProvider);
  final userId = authState.value?.id;
  return ActivityNotifier(supabase, userId);
});