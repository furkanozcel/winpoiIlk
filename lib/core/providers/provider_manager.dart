import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winpoi/core/providers/auth_provider.dart';
import 'package:winpoi/core/providers/firestore_provider.dart';
import 'package:winpoi/core/providers/leaderboard_provider.dart';
import 'package:winpoi/core/providers/user_provider.dart';

class ProviderManager extends StatelessWidget {
  final Widget child;

  const ProviderManager({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, FirestoreProvider>(
          create: (context) => FirestoreProvider(
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, authProvider, previous) =>
              FirestoreProvider(authProvider: authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, authProvider, previous) =>
              UserProvider(authProvider: authProvider),
        ),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
      ],
      child: child,
    );
  }
}
