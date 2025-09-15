import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/branding/efallmo_logo.dart';
import '../widgets/custom_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).signUpWithProfile(
            _email.text.trim(),
            _password.text.trim(),
            fullName: _fullName.text.trim(),
            phone: _phone.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registrazione effettuata! Controlla la tua email per confermare l’account.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/login');
    } catch (e) {
      final err = e.toString();
      if (!mounted) return;

      if (err.toLowerCase().contains('already')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Utente già registrato. Procedi con l’accesso.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
          ),
        );
        context.go('/login');
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registrazione non riuscita: ${_friendly(err)}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendly(String err) {
    if (err.contains('User already registered')) return 'Utente già registrato';
    if (err.contains('at least 6 characters')) return 'Password troppo corta';
    return 'Riprova più tardi';
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 520;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
            ),
          ),
          Positioned(top: -60, right: -40, child: _blob(240, const Color(0x33FF9C40))),
          Positioned(bottom: -50, left: -30, child: _blob(260, const Color(0x330F638C))),
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
                            'Registrati',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crea il tuo account in pochi secondi.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _fullName,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nome e cognome',
                              prefixIcon: Icon(Icons.person_outline, color: AppColors.subtleGray),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Inserisci il tuo nome';
                              if (v.trim().length < 2) return 'Nome troppo corto';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Numero di telefono',
                              prefixIcon: Icon(Icons.phone_outlined, color: AppColors.subtleGray),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Inserisci il tuo numero';
                              if (v.trim().length < 6) return 'Numero non valido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
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
                              if (v == null || v.isEmpty) return 'Inserisci una password';
                              if (v.length < 6) return 'Minimo 6 caratteri';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirm,
                            obscureText: !_showPassword,
                            decoration: const InputDecoration(
                              labelText: 'Conferma password',
                              prefixIcon: Icon(Icons.lock_outline, color: AppColors.subtleGray),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Conferma la password';
                              if (v != _password.text) return 'Le password non coincidono';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Registrandoti accetti i Termini e la Privacy.',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                child: const Text('Hai già un account? Accedi'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            text: 'Crea account',
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