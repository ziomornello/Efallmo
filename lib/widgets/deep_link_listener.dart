import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import '../widgets/glass_toast.dart';

class DeepLinkListener extends StatefulWidget {
  final Widget child;
  const DeepLinkListener({super.key, required this.child});

  @override
  State<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends State<DeepLinkListener> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;
  bool _handledInitial = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Initial link (cold start)
    if (!_handledInitial) {
      try {
        final initial = await _appLinks.getInitialLink();
        if (initial != null) {
          await _handleUri(initial);
        }
      } catch (_) {
        // ignore parsing errors
      }
      _handledInitial = true;
    }

    // Stream links (foreground/background)
    _sub?.cancel();
    _sub = _appLinks.uriLinkStream.listen((uri) async {
      if (uri != null) {
        await _handleUri(uri);
      }
    }, onError: (_) {});
  }

  Future<void> _handleUri(Uri uri) async {
    // Expecting: efallmo://auth-callback?type=signup... or with fragment tokens
    if (uri.scheme != 'efallmo') return;
    if (!(uri.host == 'auth-callback')) return;

    try {
      final auth = Supabase.instance.client.auth;

      // Try OAuth/code first if present
      final code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        await auth.exchangeCodeForSession(code);
      } else {
        // Let SDK parse tokens from full URI (handles fragments)
        await auth.getSessionFromUrl(uri);
      }

      if (!mounted) return;
      showGlassToast(
        context,
        message: 'Email confermata! Accesso effettuato',
        icon: Icons.mark_email_read_rounded,
      );
      GoRouter.of(context).go('/dashboard');
    } catch (_) {
      if (!mounted) return;
      showGlassToast(
        context,
        message: 'Email confermata! Ora puoi accedere',
        icon: Icons.info_outline_rounded,
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}