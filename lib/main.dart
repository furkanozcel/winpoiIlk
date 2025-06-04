import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:winpoi/core/navigation/navigator_page.dart';
import 'package:winpoi/core/providers/provider_manager.dart';
import 'package:winpoi/core/services/firebase_notification_service.dart';
import 'package:winpoi/core/theme/app_theme.dart';
import 'package:winpoi/features/admin/presentation/pages/competition_management_page.dart';
import 'package:winpoi/features/auth/presentation/pages/login_page.dart';
import 'package:winpoi/features/auth/presentation/pages/register_page.dart';
import 'package:winpoi/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:winpoi/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'core/errors/async_error_handler.dart';

void main() async {
  // Widget binding'i başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handling'i başlat
  GlobalErrorHandler.initialize();

  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase Cloud Messaging background handler'ını ayarla
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // SharedPreferences'ı başlat
  final prefs = await SharedPreferences.getInstance();
  final hasRegistered = prefs.getBool('hasRegistered') ?? false;

  // Eğer kullanıcı kayıtlı değilse onboarding'i göster
  // Eğer kullanıcı giriş yapmışsa HomePage'e yönlendir
  final showOnboarding = !hasRegistered;
  final isLoggedIn = FirebaseAuth.instance.currentUser != null;

  runApp(ProviderManager(
    child: MyApp(
      showOnboarding: showOnboarding,
      isLoggedIn: isLoggedIn,
    ),
  ));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.showOnboarding,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Winpoi',
      theme: AppTheme.theme,
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const NavigatorPage(),
        '/admin/competitions': (context) => const CompetitionManagementPage(),
        '/notification-settings': (context) => const NotificationSettingsPage(),
      },
      home: SplashScreen(
        showOnboarding: showOnboarding,
        isLoggedIn: isLoggedIn,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final bool showOnboarding;
  final bool isLoggedIn;

  const SplashScreen({
    super.key,
    required this.showOnboarding,
    required this.isLoggedIn,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => widget.showOnboarding
              ? const OnboardingPage()
              : widget.isLoggedIn
                  ? const NavigatorPage()
                  : const LoginPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'lib/assets/images/app_icon.png',
              width: 350,
              height: 350,
            ),
            const SizedBox(height: 30),
            // Uygulama adı
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF4ECDC4), // Turkuaz
                  Color(0xFFFF6B6B), // Turuncu
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'WIN',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: 'POI',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Yükleniyor göstergesi
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF4ECDC4), // Turkuaz renk
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
