import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winpoi/core/providers/auth_provider.dart' as app_provider;
import '../../../../core/errors/error_widgets.dart';
import '../../../../core/errors/app_exception.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Renk sabitleri
  static const Color primaryColor = Color(0xFF4ECDC4); // Turkuaz
  static const Color secondaryColor = Color(0xFF845EC2); // Mor
  static const Color accentColor = Color(0xFF7EDFD9); // Açık turkuaz

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<app_provider.AuthProvider>();
      final result = await authProvider.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (authProvider.hasError && mounted) {
        ErrorSnackBar.show(
          context,
          authProvider.error!,
          onRetry: () => _retryLogin(),
        );
      }
    }
  }

  Future<void> _retryLogin() async {
    final authProvider = context.read<app_provider.AuthProvider>();
    final result = await authProvider.signInWithEmailRetry(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      maxRetries: 2,
    );

    if (result != null && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = context.read<app_provider.AuthProvider>();
    final result = await authProvider.signInWithGoogle();

    if (result != null && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (authProvider.hasError && mounted) {
      ErrorSnackBar.show(context, authProvider.error!);
    }
  }

  Future<void> _resetPassword() async {
    final emailController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Şifre Sıfırlama',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Şifre sıfırlama bağlantısı e-posta adresinize gönderilecektir.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'E-posta',
                        hintText: 'ornek@email.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: primaryColor, width: 1.2),
                        ),
                        prefixIcon: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [primaryColor, secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Icon(Icons.email_outlined,
                              color: Colors.white),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              primaryColor,
                              secondaryColor,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (emailController.text.isEmpty) {
                                    ErrorSnackBar.show(
                                      context,
                                      const ValidationException(
                                        message:
                                            'Lütfen e-posta adresinizi girin',
                                        code: 'email_required',
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => isLoading = true);

                                  final authProvider =
                                      context.read<app_provider.AuthProvider>();
                                  await authProvider.sendPasswordResetEmail(
                                    email: emailController.text.trim(),
                                  );

                                  setState(() => isLoading = false);

                                  if (authProvider.hasError) {
                                    if (mounted) {
                                      ErrorSnackBar.show(
                                          context, authProvider.error!);
                                    }
                                  } else {
                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Gönder',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 24, color: Colors.grey),
                  splashRadius: 20,
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Kapat',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_provider.AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              primaryColor,
              secondaryColor,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            'Hesabına Giriş Yap',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.8,
              height: 1.2,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 0.0, left: 24.0, right: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 0),
                  // Logo
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      'lib/assets/images/app_icon.png',
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Email field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.5),
                          secondaryColor.withOpacity(0.5),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-posta',
                        hintText: 'ornek@email.com',
                        labelStyle: TextStyle(color: Colors.grey.shade700),
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [primaryColor, secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Icon(Icons.email_outlined,
                              color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'E-posta adresi gerekli';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Geçerli bir e-posta adresi girin';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.5),
                          secondaryColor.withOpacity(0.5),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        hintText: '********',
                        labelStyle: TextStyle(color: Colors.grey.shade700),
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [primaryColor, secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Icon(Icons.lock_outline,
                              color: Colors.white),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Şifre gerekli';
                        }
                        if (value.length < 6) {
                          return 'Şifre en az 6 karakter olmalı';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      style: TextButton.styleFrom(
                        foregroundColor: secondaryColor,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Şifremi Unuttum',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFE28B33),
                          decorationThickness: 1.5,
                          color: Color(0xFFE28B33),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Login button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [
                          primaryColor,
                          secondaryColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Giriş Yap',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // OR divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade300,
                                Colors.grey.shade200,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'veya',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade300,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Google sign in button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: OutlinedButton.icon(
                      onPressed:
                          authProvider.isLoading ? null : _signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: Image.asset(
                        'lib/features/auth/assets/images/google_logo.png',
                        height: 24,
                      ),
                      label: Text(
                        'Google ile Giriş Yap',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Register text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hesabın yok mu?',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/register');
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          foregroundColor: secondaryColor,
                        ),
                        child: const Text(
                          'Kayıt Ol',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFE28B33),
                            decorationThickness: 1.5,
                            color: Color(0xFFE28B33),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
