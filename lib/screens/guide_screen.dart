import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import '../models/bonus.dart';
import '../utils/constants.dart';
import '../providers/activity_provider.dart';
import '../providers/bonus_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_toast.dart';

class GuideScreen extends ConsumerStatefulWidget {
  final Bonus bonus;

  const GuideScreen({
    super.key,
    required this.bonus,
  });

  @override
  ConsumerState<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends ConsumerState<GuideScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.darkBackground)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _loadError = 'Impossibile caricare il contenuto (${error.errorCode}).';
              });
            }
          },
        ),
      );

    final raw = widget.bonus.embedUrl.trim();
    final uri = Uri.tryParse(raw);
    final isValid = uri != null && (uri.scheme == 'https' || uri.scheme == 'http');

    if (isValid) {
      _controller.loadRequest(uri);
    } else {
      setState(() {
        _isLoading = false;
        _loadError = 'Link non valido o mancante.';
      });
    }
  }

  Future<void> _copyReferralCode() async {
    final val = widget.bonus.referralCodeOrLink?.trim();
    if (val == null || val.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: val));
    if (!mounted) return;
    showGlassToast(
      context,
      message: 'Hai copiato il codice invito "$val"',
      icon: Icons.content_copy,
    );
  }

  Future<void> _openReferralLink() async {
    final val = widget.bonus.referralCodeOrLink?.trim();
    if (val == null || val.isEmpty) return;
    final uri = Uri.tryParse(val);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await _copyReferralCode();
    }
  }

  Future<bool> _promptSaveProgress() async {
    final progressMap = ref.read(userBonusProgressProvider).value ?? {};
    final current = progressMap[widget.bonus.id];
    final stepCtrl = TextEditingController(text: '');
    bool completed = current?.completed ?? false;
    bool stepTouched = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: GlassContainer(
                borderRadius: 20,
                blur: 18,
                backgroundColor: Colors.black.withOpacity(0.35),
                borderGradient: const LinearGradient(
                  colors: [AppColors.brandOrange, AppColors.brandBlue],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Salva il tuo progresso',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stepCtrl,
                      onTap: () {
                        if (!stepTouched) {
                          stepTouched = true;
                          stepCtrl.clear();
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'A che step ti sei fermato?',
                        hintText: 'Suggerito: ${current?.currentStep ?? 0}',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: completed,
                          onChanged: (v) => setStateDialog(() => completed = v ?? false),
                        ),
                        const Text('Ho completato il bonus'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Annulla'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Salva & Torna'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == true) {
      final maxSteps = widget.bonus.totalSteps > 0 ? widget.bonus.totalSteps : 50;
      int parsed = int.tryParse(stepCtrl.text.trim()) ?? (current?.currentStep ?? 0);
      if (completed) parsed = maxSteps;
      final bounded = parsed.clamp(0, maxSteps);

      await ref.read(activityProvider.notifier).saveProgress(
            bonus: widget.bonus,
            step: bounded,
            completed: completed,
          );

      // Avoid fetching progress here to prevent using disposed notifiers after navigation.
      return true;
    }
    return false;
  }

  Future<void> _onExit() async {
    await _promptSaveProgress();
    if (!mounted) return;
    context.go('/dashboard');
  }

  Widget _buildFloatingActionsBar() {
    final val = widget.bonus.referralCodeOrLink?.trim() ?? '';
    if (val.isEmpty) return const SizedBox.shrink();

    final isLink = val.startsWith('http');

    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: GlassContainer(
        borderRadius: 14,
        blur: 16,
        backgroundColor: Colors.black.withOpacity(0.25),
        borderGradient: const LinearGradient(
          colors: [AppColors.brandOrange, AppColors.brandBlue],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLink)
              Flexible(
                child: ElevatedButton.icon(
                  onPressed: _openReferralLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Vai al link'),
                ),
              ),
            if (isLink) const SizedBox(width: 8),
            Flexible(
              child: OutlinedButton.icon(
                onPressed: _copyReferralCode,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
                icon: const Icon(Icons.content_copy),
                label: Text(
                  val,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebContent() {
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.subtleGray, size: 48),
              const SizedBox(height: 16),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.subtleGray),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _onExit,
                child: const Text('Torna alla Dashboard'),
              ),
            ],
          ),
        ),
      );
    }
    return WebViewWidget(controller: _controller);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _onExit();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.bonus.title,
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onExit,
            tooltip: 'Torna alla Dashboard',
          ),
        ),
        body: Stack(
          children: [
            // WebView fills the body
            Positioned.fill(child: _buildWebContent()),
            // Loading bar at top (inside body)
            if (_isLoading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandBlue),
                  backgroundColor: AppColors.lightDarkBackground,
                ),
              ),
            // Floating overlay actions (doesn't take layout space)
            _buildFloatingActionsBar(),
          ],
        ),
      ),
    );
  }
}