import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../widgets/landing/header_nav.dart';
import '../widgets/landing/hero_section.dart';
import '../widgets/landing/feature_card.dart';
import '../widgets/landing/steps_section.dart';
import '../widgets/landing/partners_section.dart';
import '../widgets/landing/testimonials_section.dart';
import '../widgets/landing/faq_section.dart';
import '../widgets/landing/cta_section.dart';
import '../widgets/landing/footer.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scrollController = ScrollController();

  final _topKey = GlobalKey();
  final _stepsKey = GlobalKey();
  final _partnersKey = GlobalKey();
  final _testimonialsKey = GlobalKey();
  final _faqKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.1,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  void _handleNav(String section) {
    switch (section) {
      case 'top':
        _scrollTo(_topKey);
        break;
      case 'steps':
        _scrollTo(_stepsKey);
        break;
      case 'partners':
        _scrollTo(_partnersKey);
        break;
      case 'testimonials':
        _scrollTo(_testimonialsKey);
        break;
      case 'faq':
        _scrollTo(_faqKey);
        break;
      default:
        _scrollTo(_topKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              HeaderNav(showNavItems: true, onNavigateTo: _handleNav),

              KeyedSubtree(
                key: _topKey,
                child: HeroSection(onDiscover: () => _scrollTo(_stepsKey)),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Column(
                  children: const [
                    Text(
                      'Perché le aziende ti pagano?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Trasparenza e semplicità: i brand spostano il budget dagli ads ai premi per te.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.subtleGray),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: const [
                  FeatureCard(
                    icon: Icons.group_add,
                    title: 'Nuovi Utenti',
                    subtitle: 'Sei prezioso per la crescita delle aziende partner.',
                  ),
                  FeatureCard(
                    icon: Icons.verified_user,
                    title: 'Partner Affidabili',
                    subtitle: 'Collaboriamo solo con brand verificati e trasparenti.',
                  ),
                  FeatureCard(
                    icon: Icons.savings,
                    title: 'Marketing Diretto',
                    subtitle: 'Budget spostato dagli ads ai premi per te.',
                  ),
                ],
              ),

              KeyedSubtree(
                key: _stepsKey,
                child: const StepsSection(),
              ),

              KeyedSubtree(
                key: _partnersKey,
                child: const PartnersSection(),
              ),

              KeyedSubtree(
                key: _testimonialsKey,
                child: const TestimonialsSection(),
              ),

              KeyedSubtree(
                key: _faqKey,
                child: const FaqSection(),
              ),

              CtaSection(onPressed: () => context.go('/register')),
              const Footer(),
            ],
          ),
        ),
      ),
    );
  }
}