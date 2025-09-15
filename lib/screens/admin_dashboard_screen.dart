import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/constants.dart';
import '../utils/dimensions.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  late final SupabaseClient _supabase;
  List<Map<String, dynamic>> _rows = [];
  Map<String, String> _userNames = {}; // user_id -> full_name
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _supabase = ref.read(supabaseClientProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      setState(() => _loading = true);

      final data = await _supabase
          .from('user_bonus_activity')
          .select('id, event, step, completed, created_at, user_id, bonuses(title, image_url)')
          .order('created_at', ascending: false)
          .limit(200);

      _rows = (data as List).cast<Map<String, dynamic>>();

      final userIds = _rows.map((r) => r['user_id'] as String).toSet().toList();
      if (userIds.isNotEmpty) {
        final profiles = await _supabase
            .from('profiles')
            .select('id, full_name')
            .inFilter('id', userIds);
        for (final p in profiles as List) {
          _userNames[(p['id'] as String)] = (p['full_name'] as String?) ?? 'Utente';
        }
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final isAdmin = profile?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Attività utenti'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: !isAdmin
          ? const Center(
              child: Text(
                'Non autorizzato',
                style: TextStyle(color: AppColors.subtleGray),
              ),
            )
          : _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.brandBlue))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  itemBuilder: (ctx, i) {
                    final r = _rows[i];
                    final bonus = (r['bonuses'] as Map?) ?? {};
                    final title = (bonus['title'] as String?) ?? 'Bonus';
                    final name = _userNames[r['user_id']] ?? r['user_id'];
                    final event = (r['event'] as String).toUpperCase();
                    final step = r['step']?.toString() ?? '0';
                    final completed = r['completed'] == true;
                    final ts = DateTime.tryParse(r['created_at'] as String? ?? '');

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      leading: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.08),
                        child: Text(
                          name.isNotEmpty ? name[0] : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        '$name • $title',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'Evento: $event • Step: $step • Completato: ${completed ? "Sì" : "No"}',
                        style: const TextStyle(color: AppColors.subtleGray),
                      ),
                      trailing: Text(
                        ts != null ? '${ts.day.toString().padLeft(2, '0')}/${ts.month.toString().padLeft(2, '0')}/${ts.year} ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}' : '',
                        style: const TextStyle(color: AppColors.subtleGray, fontSize: 12),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.08)),
                  itemCount: _rows.length,
                ),
    );
  }
}