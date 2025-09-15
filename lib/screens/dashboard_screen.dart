import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/bonus_provider.dart';
import '../providers/activity_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/constants.dart';
import '../utils/dimensions.dart';
import '../utils/date.dart';
import '../utils/strings.dart';
import '../widgets/bonus_detail_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/filters_bar.dart';
import '../widgets/branding/efallmo_logo.dart';
import '../models/bonus.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _search = '';
  Set<BonusFilter> _filters = {BonusFilter.disponibili};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bonusProvider.notifier).fetchBonuses();
      ref.read(userBonusProgressProvider.notifier).fetchUserProgress();
    });
  }

  bool _isExpiredOf(bonus) => AppDate.isExpired(bonus.expiryDateText);

  bool _passesFilters(Bonus bonus, Map<String, UserBonusProgress> progressMap) {
    if (_filters.isEmpty) return true;

    bool ok = true;
    final prog = progressMap[bonus.id];
    final isCompleted = prog?.completed ?? false;

    if (_filters.contains(BonusFilter.disponibili)) {
      ok = ok && (bonus.isActive == true) && !_isExpiredOf(bonus) && !isCompleted;
    }
    if (_filters.contains(BonusFilter.scaduti)) {
      ok = ok && _isExpiredOf(bonus);
    }
    if (_filters.contains(BonusFilter.senzaDeposito)) {
      final dep = (bonus.depositRequired ?? '').trim();
      final depNum = int.tryParse(dep.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      ok = ok && depNum == 0;
    }
    if (_filters.contains(BonusFilter.completati)) {
      ok = ok && isCompleted;
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final bonusesState = ref.watch(bonusProvider);
    final progressState = ref.watch(userBonusProgressProvider);
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const EfallmoLogo(horizontal: true, height: 28),
        actions: [
          profileState.when(
            data: (p) => (p?.isAdmin ?? false)
                ? IconButton(
                    onPressed: () => context.go('/admin'),
                    icon: const Icon(Icons.admin_panel_settings),
                    tooltip: 'Admin',
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          PopupMenuButton<String>(
            tooltip: 'Menu',
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authProvider.notifier).signOut();
                if (mounted) context.go('/landing');
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.brandOrange),
                    SizedBox(width: 8),
                    Text('Esci'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(bonusProvider.notifier).fetchBonuses();
          await ref.read(userBonusProgressProvider.notifier).fetchUserProgress();
        },
        color: AppColors.brandBlue,
        backgroundColor: AppColors.lightDarkBackground,
        child: bonusesState.when(
          data: (bonuses) {
            return progressState.when(
              data: (progressMap) {
                final filtered = bonuses.where((b) {
                  final s = _search.trim().toLowerCase();
                  final matchesSearch = s.isEmpty ||
                      b.title.toLowerCase().contains(s) ||
                      (b.description ?? '').toLowerCase().contains(s);
                  return matchesSearch && _passesFilters(b, progressMap);
                }).toList();

                return ListView(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  children: [
                    FiltersBar(
                      searchText: _search,
                      onSearchChanged: (v) => setState(() => _search = v),
                      selected: _filters,
                      onSelectedChanged: (v) => setState(() => _filters = v),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                          child: Text(
                            'Nessun bonus trovato con i filtri correnti.',
                            style: TextStyle(color: AppColors.subtleGray),
                          ),
                        ),
                      ),
                    ...filtered.map((bonus) {
                      final progress = progressMap[bonus.id];
                      return BonusDetailCard(
                        bonus: bonus,
                        progress: progress,
                        onStart: () async {
                          await ref.read(activityProvider.notifier).logStart(bonus);
                          if (!mounted) return;
                          context.go('/guide', extra: bonus);
                        },
                      );
                    }),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandBlue)),
              error: (error, stack) => const Center(child: Text('Errore nel caricare i progressi')),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandBlue),
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.subtleGray,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                const Text(
                  'Errore nel caricamento dei bonus',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.subtleGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                CustomButton(
                  onPressed: () {
                    ref.read(bonusProvider.notifier).fetchBonuses();
                  },
                  text: 'Riprova',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}