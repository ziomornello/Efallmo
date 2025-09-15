import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier(this._supabase) : super(const AsyncValue.loading()) {
    _init();
  }

  final SupabaseClient _supabase;

  void _init() {
    state = AsyncValue.data(_supabase.auth.currentUser);
    _supabase.auth.onAuthStateChange.listen((data) {
      state = AsyncValue.data(data.session?.user);
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await _supabase.auth.signInWithPassword(email: email, password: password);
      // lo stream onAuthStateChange aggiornerà lo state
    } catch (error) {
      // mantieni uno state stabile per non far esplodere il build con AsyncError
      state = AsyncValue.data(_supabase.auth.currentUser);
      rethrow;
    }
  }

  // Compatibilità retro
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    await signUpWithProfile(email, password);
  }

  // Nuovo: signup con metadata e upsert su public.profiles
  Future<void> signUpWithProfile(
    String email,
    String password, {
    String? fullName,
    String? phone,
  }) async {
    try {
      state = const AsyncValue.loading();
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null && fullName.trim().isNotEmpty) 'full_name': fullName.trim(),
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        },
        emailRedirectTo: AppLinks.authCallback,
      );

      final user = res.user;
      if (user != null) {
        // Garantisce la riga del profilo (se RLS/trigger già gestisce, ignora errori)
        try {
          await _supabase.from('profiles').upsert({
            'id': user.id,
            if (fullName != null) 'full_name': fullName,
            if (phone != null) 'phone': phone,
          });
        } catch (_) {}
      }

      state = AsyncValue.data(_supabase.auth.currentUser);
    } catch (error) {
      state = AsyncValue.data(_supabase.auth.currentUser);
      rethrow;
    }
  }

  // Resend conferma email (deep link mobile)
  Future<void> resendConfirmationEmail(String email) async {
    await _supabase.auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: AppLinks.authCallback,
    );
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthNotifier(supabase);
});