import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/dimensions.dart';
import '../utils/strings.dart';
import '../widgets/custom_button.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLogin) {
        await ref.read(authProvider.notifier).signInWithEmailAndPassword(email, password);
      } else {
        await ref.read(authProvider.notifier).signUpWithEmailAndPassword(email, password);
      }

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _getErrorMessage(error.toString()),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email o password non corretti';
    } else if (error.contains('Email not confirmed')) {
      return 'Controlla la tua email per confermare l\'account';
    } else if (error.contains('User already registered')) {
      return 'Utente già registrato';
    } else if (error.contains('Password should be at least 6 characters')) {
      return 'La password deve contenere almeno 6 caratteri';
    } else {
      return 'Si è verificato un errore. Riprova.';
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<dynamic>>(authProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null && mounted) {
            context.go('/dashboard');
          }
        },
        loading: () {},
        error: (error, stackTrace) {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/landing'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.paddingLarge),
                  
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.ctaGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'E',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingLarge),
                  
                  Text(
                    _isLogin ? AppStrings.login : AppStrings.register,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingExtraLarge),
                  
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: AppStrings.email,
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.subtleGray),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci la tua email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Inserisci un\'email valida';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingMedium),
                  
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: AppStrings.password,
                      prefixIcon: Icon(Icons.lock_outline, color: AppColors.subtleGray),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci la tua password';
                      }
                      if (value.length < 6) {
                        return 'La password deve contenere almeno 6 caratteri';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingLarge),
                  
                  CustomButton(
                    text: _isLogin ? AppStrings.login : AppStrings.register,
                    onPressed: _handleAuth,
                    isLoading: _isLoading,
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingMedium),
                  
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'Non hai un account? Registrati'
                          : 'Hai già un account? Accedi',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}