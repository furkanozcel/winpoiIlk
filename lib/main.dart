import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:winpoi/core/navigation/navigator_page.dart';
import 'package:winpoi/core/providers/provider_manager.dart';
import 'package:winpoi/core/theme/app_theme.dart';
import 'package:winpoi/features/admin/presentation/pages/competition_management_page.dart';
import 'package:winpoi/features/auth/presentation/pages/login_page.dart';
import 'package:winpoi/features/auth/presentation/pages/register_page.dart';
import 'package:winpoi/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Widget binding'i başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase ve SharedPreferences'ı başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      },
      home: showOnboarding
          ? const OnboardingPage()
          : isLoggedIn
              ? const NavigatorPage()
              : const LoginPage(),
    );
  }
}
