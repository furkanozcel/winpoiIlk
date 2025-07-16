import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:winpoi/core/providers/auth_provider.dart' as app_provider;
import 'package:winpoi/core/providers/firestore_provider.dart';
import 'package:winpoi/core/errors/error_widgets.dart';
import 'package:winpoi/core/errors/app_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  bool _acceptedTerms = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Renk sabitleri
  static const Color primaryColor = Color(0xFF4ECDC4); // Turkuaz
  static const Color secondaryColor = Color(0xFF845EC2); // Mor
  static const Color accentColor = Color(0xFF4ECDC4); // Turkuaz

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Animasyonları başlat
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanım koşullarını kabul etmelisiniz.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final authProvider = context.read<app_provider.AuthProvider>();

      // Google ile oturum aç (yeni kullanıcı ise kayıt, mevcut kullanıcı ise giriş)
      final result = await authProvider.signInWithGoogle();

      if (result != null && mounted) {
        // Kullanıcının daha önce kaydolup kaydolmadığını kontrol et
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

          // Eğer kullanıcı daha önce kaydolmamışsa, Firestore'a kaydet
          if (!userDoc.exists) {
            await context.read<FirestoreProvider>().updateUserProfile(
              userId: currentUser.uid,
              data: {
                'name': currentUser.displayName ?? '',
                'email': currentUser.email ?? '',
                'username': '',
                'poiBalance': 0,
                'totalPrizeCount': 0,
                'totalGames': 0,
                'successPoints': 0,
                'createdAt': FieldValue.serverTimestamp(),
                'role': 'user', // Varsayılan kullanıcı rolü
              },
            );

            // İlk kayıt olduğunu SharedPreferences'a kaydet
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('hasRegistered', true);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Hoş geldiniz! Hesabınız başarıyla oluşturuldu.'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            // Mevcut kullanıcı giriş yaptı
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tekrar hoş geldiniz!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }

          // Ana sayfaya yönlendir
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      // Hata ayrıntılarını konsola yazdır
      print('Google sign-in detailed error: $e');

      // Kullanıcıya daha anlaşılır bir hata mesajı göster
      String errorMessage = 'Google ile giriş yapılamadı.';

      if (e.toString().contains('PlatformException')) {
        errorMessage =
            'Google servislerine bağlanılamadı. Lütfen internet bağlantınızı kontrol edin.';
      } else if (e.toString().contains('network_error')) {
        errorMessage = 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
      } else if (e.toString().contains('credential')) {
        errorMessage = 'Kimlik doğrulama hatası. Lütfen tekrar deneyin.';
      } else if (e.toString().contains('cancelled')) {
        errorMessage = 'Google ile giriş işlemi iptal edildi.';
      }

      // Hata mesajı göster
      if (mounted) {
        ErrorSnackBar.show(
          context,
          AuthException(message: errorMessage, code: 'google_signin_error'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_provider.AuthProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4ECDC4).withOpacity(0.3), // Soft Turkuaz
              const Color(0xFF845EC2).withOpacity(0.2), // Soft Mor
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Ana içerik
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: screenHeight * 0.05),
                          // Logo ve başlık bölümü
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Column(
                              children: [
                                // Logo
                                Image.asset(
                                  'lib/assets/images/app_icon.png',
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.06),
                          // Hoş geldin mesajı
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "WinPoi'ye hoş geldin",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                    height: 1.2,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Ödül avına başlamak için Google hesabınızla giriş yapın',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          // Google giriş butonu
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: authProvider.isLoading
                                    ? null
                                    : _signInWithGoogle,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (authProvider.isLoading)
                                        const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Color(0xFF4ECDC4),
                                            ),
                                          ),
                                        )
                                      else ...[
                                        Image.asset(
                                          'lib/features/auth/assets/images/google_logo.png',
                                          height: 28,
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'Google ile Devam Et',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 18,
                                            color: Colors.grey.shade800,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          // Kullanım koşulları
                          Row(
                            children: [
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: _acceptedTerms
                                      ? Colors.grey.shade700
                                      : Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _acceptedTerms
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                ),
                                child: Checkbox(
                                  value: _acceptedTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _acceptedTerms = value ?? false;
                                    });
                                  },
                                  activeColor: Colors.transparent,
                                  checkColor: Colors.white,
                                  side: BorderSide.none,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Kullanım Koşulları',
                                    style: GoogleFonts.quicksand(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Navigate to terms & conditions
                                      },
                                    children: [
                                      TextSpan(
                                        text: ' ve ',
                                        style: GoogleFonts.quicksand(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Gizlilik Politikası',
                                        style: GoogleFonts.quicksand(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // Navigate to privacy policy
                                          },
                                      ),
                                      TextSpan(
                                        text: "'nı kabul ediyorum.",
                                        style: GoogleFonts.quicksand(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          // Bilgi kutusu
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.security_rounded,
                                    color: Colors.grey.shade700,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Güvenli ve hızlı giriş. Yeni kullanıcılar otomatik olarak kayıt olur.',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
