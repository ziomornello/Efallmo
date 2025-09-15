import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../branding/efallmo_logo.dart';

class HeaderNav extends ConsumerWidget {
  final bool showNavItems;
  final void Function(String section)? onNavigateTo;

  const HeaderNav({
    super.key,
    this.showNavItems = false,
    this.onNavigateTo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompact = MediaQuery.of(context).size.width < 760;
    final user = ref.watch(authProvider).value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            const EfallmoLogo(horizontal: true, height: 32),

            if (showNavItems && !isCompact) ...[
              const SizedBox(width: 20),
              _NavLink(label: 'Home', onTap: () => _jump('top')),
              _NavLink(label: 'Come funziona', onTap: () => _jump('steps')),
              _NavLink(label: 'Bonus', onTap: () => _jump('partners')),
              _NavLink(label: 'Testimonianze', onTap: () => _jump('testimonials')),
              _NavLink(label: 'FAQ', onTap: () => _jump('faq')),
            ],

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                if (user != null) {
                  context.go('/dashboard');
                } else {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: Text(user != null ? 'Vai alla Dashboard' : 'Accedi o Registrati'),
            ),
          ],
        ),
      ),
    );
  }

  void _jump(String key) {
    if (onNavigateTo != null) {
      onNavigateTo!(key);
    }
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}