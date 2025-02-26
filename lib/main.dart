import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:winpoi/core/navigation/navigator_page.dart';
import 'package:winpoi/core/theme/app_theme.dart';
import 'package:winpoi/features/admin/presentation/pages/competition_management_page.dart';
import 'package:winpoi/features/auth/presentation/pages/login_page.dart';
import 'package:winpoi/features/auth/presentation/pages/register_page.dart';
import 'package:winpoi/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  // Widget binding'i başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase ve SharedPreferences'ı başlat
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final hasRegistered = prefs.getBool('hasRegistered') ?? false;

  // Eğer kullanıcı kayıtlı değilse veya oturum açık değilse onboarding'i göster
  final showOnboarding =
      !hasRegistered || FirebaseAuth.instance.currentUser == null;

  runApp(MyApp(showOnboarding: showOnboarding));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({
    super.key,
    required this.showOnboarding,
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
      home: showOnboarding ? const OnboardingPage() : const LoginPage(),
    );
  }
}
