import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import 'auth_provider.dart';

final profileProvider = FutureProvider<Profile?>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  final res = await supabase
      .from('profiles')
      .select('id, full_name, phone, is_admin, created_at')
      .eq('id', user.id)
      .maybeSingle();

  if (res == null) return null;
  return Profile.fromJson(res as Map<String, dynamic>);
});