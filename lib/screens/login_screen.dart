import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/branding/efallmo_logo.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).signInWithEmailAndPassword(
            _email.text.trim(),
            _password.text.trim(),
          );
      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      final err = e.toString().toLowerCase();

      if (err.contains('email not confirmed') || err.contains('email_not_confirmed')) {
        await _showEmailNotConfirmedDialog();
      } else if (err.contains('invalid login credentials') || err.contains('invalid_credentials')) {
        _showSnack('Credenziali non valide. Controlla email e password.', Colors.redAccent);
      } else {
        _showSnack('Accesso non riuscito: ${_friendly(e.toString())}', Colors.redAccent);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showEmailNotConfirmedDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightDarkBackground,
        title: const Text('Email non confermata', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Hai già creato l’account ma non hai confermato l’email. Controlla la posta o invia di nuovo il link di conferma.',
          style: TextStyle(color: AppColors.subtleGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Chiudi'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(authProvider.notifier).resendConfirmationEmail(_email.text.trim());
                if (!mounted) return;
                Navigator.of(ctx).pop();
                _showSnack('Email di conferma inviata di nuovo. Controlla la posta.', Colors.green);
              } catch (_) {
                if (!mounted) return;
                Navigator.of(ctx).pop();
                _showSnack('Impossibile inviare l’email di conferma. Riprova più tardi.', Colors.redAccent);
              }
            },
            child: const Text('Invia di nuovo'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: bg,
      ),
    );
  }

  String _friendly(String err) {
    if (err.contains('Invalid login credentials')) {
      return 'Credenziali non valide';
    }
    if (err.toLowerCase().contains('email not confirmed')) {
      return 'Email non confermata';
    }
    return 'Controlla email e password';
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 520;

    final authState = ref.watch(authProvider);
    final user = authState.asData?.value;
    if (user != null) {
      Future.microtask(() {
        if (mounted) context.go('/dashboard');
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
            ),
          ),
          Positioned(top: -60, left: -40, child: _blob(220, const Color(0x33FF9C40))),
          Positioned(bottom: -50, right: -30, child: _blob(260, const Color(0x330F638C))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: GlassContainer(
                    borderRadius: 22,
                    backgroundColor: Colors.black.withOpacity(0.35),
                    blur: 20,
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const EfallmoLogo(horizontal: true, height: 42),
                          const SizedBox(height: 16),
                          const Text(
                            'Accedi',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bentornato! Entra per vedere i tuoi bonus.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined, color: AppColors.subtleGray),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Inserisci la tua email';
                              final re = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!re.hasMatch(v)) return 'Inserisci un’email valida';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.subtleGray),
                              suffixIcon: IconButton(
                                icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _showPassword = !_showPassword),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Inserisci la tua password';
                              if (v.length < 6) return 'Minimo 6 caratteri';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(
                                child: SizedBox.shrink(),
                              ),
                              TextButton(
                                onPressed: () => context.go('/register'),
                                child: const Text('Non hai un account? Registrati'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            text: 'Accedi',
                            onPressed: _submit,
                            isLoading: _loading,
                          ),
                          const SizedBox(height: 10),
                          if (isNarrow)
                            TextButton(
                              onPressed: () => context.go('/landing'),
                              child: const Text('Torna alla Home'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}