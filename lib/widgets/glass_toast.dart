import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'glass_container.dart';

void showGlassToast(
  BuildContext context, {
  required String message,
  IconData icon = Icons.check_circle_rounded,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) {
      final topPadding = MediaQuery.of(ctx).padding.top;
      return Positioned(
        top: topPadding + 16,
        left: 16,
        right: 16,
        child: _GlassToast(
          message: message,
          icon: icon,
          onClose: () {
            try {
              entry.remove();
            } catch (_) {}
          },
          duration: duration,
        ),
      );
    },
  );

  overlay.insert(entry);
}

class _GlassToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final Duration duration;
  final VoidCallback onClose;

  const _GlassToast({
    required this.message,
    required this.icon,
    required this.duration,
    required this.onClose,
  });

  @override
  State<_GlassToast> createState() => _GlassToastState();
}

class _GlassToastState extends State<_GlassToast> with SingleTickerProviderStateMixin {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // enter
    Future.microtask(() => setState(() => _visible = true));
    // auto close
    _timer = Timer(widget.duration, () {
      if (mounted) setState(() => _visible = false);
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted) widget.onClose();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 180),
      child: GlassContainer(
        borderRadius: 16,
        blur: 18,
        borderGradient: const LinearGradient(
          colors: [AppColors.brandOrange, AppColors.brandBlue],
        ),
        backgroundColor: Colors.black.withOpacity(0.35),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}