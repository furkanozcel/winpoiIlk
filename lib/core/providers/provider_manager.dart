import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winpoi/core/providers/auth_provider.dart';
import 'package:winpoi/core/providers/firestore_provider.dart';
import 'package:winpoi/core/providers/leaderboard_provider.dart';
import 'package:winpoi/core/providers/user_provider.dart';
import 'package:winpoi/core/providers/notification_provider.dart';

class ProviderManager extends StatelessWidget {
  final Widget child;

  const ProviderManager({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProxyProvider<AuthProvider, FirestoreProvider>(
          create: (context) => FirestoreProvider(
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, authProvider, previous) =>
              previous ?? FirestoreProvider(authProvider: authProvider)
                ..updateAuthProvider(authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, authProvider, previous) =>
              previous ?? UserProvider(authProvider: authProvider)
                ..updateAuthProvider(authProvider),
        ),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
      ],
      child: child,
    );
  }
}
