import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:winpoi/core/navigation/navigator_page.dart';
import 'package:winpoi/core/theme/app_theme.dart';
import 'package:winpoi/features/auth/presentation/pages/login_page.dart';
import 'package:winpoi/features/auth/presentation/pages/register_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WinPoi',
      theme: AppTheme.theme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const NavigatorPage(),
      },
    );
  }
}
