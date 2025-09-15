import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/bonus.dart';
import 'auth_provider.dart';

class BonusNotifier extends StateNotifier<AsyncValue<List<Bonus>>> {
  BonusNotifier(this._supabase) : super(const AsyncValue.loading());

  final SupabaseClient _supabase;

  Future<void> fetchBonuses() async {
    try {
      state = const AsyncValue.loading();

      final response = await _supabase
          .from('bonuses')
          .select()
          .order('created_at', ascending: false);

      final bonuses = (response as List)
          .map((json) => Bonus.fromJson(json))
          .toList();

      state = AsyncValue.data(bonuses);

      // Prefetch/caches images and logos so they don't reload each time.
      unawaited(_prefetchMedia(bonuses));
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> _prefetchMedia(List<Bonus> bonuses) async {
    try {
      final cache = DefaultCacheManager();
      final urls = <String>[];

      for (final b in bonuses) {
        final img = (b.imageUrl ?? '').trim();
        final logo = (b.companyLogoUrl ?? '').trim();
        if (img.isNotEmpty) urls.add(img);
        if (logo.isNotEmpty) urls.add(logo);
      }

      await Future.wait(
        urls.map((u) => cache.getSingleFile(u)).toList(),
        eagerError: false,
      );
    } catch (_) {
      // ignore cache errors
    }
  }
}

final bonusProvider = StateNotifierProvider<BonusNotifier, AsyncValue<List<Bonus>>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return BonusNotifier(supabase);
});

class UserBonusProgressNotifier extends StateNotifier<AsyncValue<Map<String, UserBonusProgress>>> {
  UserBonusProgressNotifier(this._supabase, this._userId) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      fetchUserProgress();
    } else {
      state = const AsyncValue.data({});
    }
  }

  final SupabaseClient _supabase;
  final String? _userId;

  Future<void> fetchUserProgress() async {
    if (_userId == null) {
      state = const AsyncValue.data({});
      return;
    }

    try {
      state = const AsyncValue.loading();

      final response = await _supabase
          .from('user_bonus_progress')
          .select()
          .eq('user_id', _userId!);

      final progressMap = <String, UserBonusProgress>{};
      for (final json in response as List) {
        final progress = UserBonusProgress.fromJson(json);
        progressMap[progress.bonusId] = progress;
      }

      state = AsyncValue.data(progressMap);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> updateProgress(String bonusId, int currentStep, {bool completed = false}) async {
    if (_userId == null) return;

    try {
      await _supabase.from('user_bonus_progress').upsert({
        'user_id': _userId!,
        'bonus_id': bonusId,
        'current_step': currentStep,
        'completed': completed,
        'updated_at': DateTime.now().toIso8601String(),
      });

      await fetchUserProgress();
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}

final userBonusProgressProvider = StateNotifierProvider<UserBonusProgressNotifier, AsyncValue<Map<String, UserBonusProgress>>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final authState = ref.watch(authProvider);
  final userId = authState.value?.id;

  return UserBonusProgressNotifier(supabase, userId);
});

// Public (anonymous) top 3 active bonuses for Landing page
final publicBonusesProvider = FutureProvider<List<Bonus>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase
      .from('bonuses')
      .select()
      .eq('is_active', true)
      .order('created_at', ascending: false)
      .limit(3);

  return (response as List).map((json) => Bonus.fromJson(json)).toList();
});

// Sum of registration-only earnings currently available (active bonuses).
final registrationPotentialProvider = FutureProvider<int>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final rows = await supabase
      .from('bonuses')
      .select('registration_bonus_amount, registration_bonus_type, is_active')
      .eq('is_active', true);

  int sum = 0;
  for (final r in rows as List) {
    final raw = (r['registration_bonus_amount'] ?? '').toString();
    final numeric = RegExp(r'[0-9]+').allMatches(raw).map((m) => m.group(0)).join();
    if (numeric.isNotEmpty) {
      sum += int.tryParse(numeric) ?? 0;
    }
  }
  return sum;
});