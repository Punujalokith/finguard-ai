import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/local_db.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/settings_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/transactions/providers/transaction_provider.dart';
import 'features/goals/providers/goal_provider.dart';
import 'features/digital_twin/providers/digital_twin_provider.dart';
import 'features/ai_assistant/providers/ai_assistant_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'core/widgets/main_shell.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind system bars so the nav-bar doesn't block content
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  await LocalDb.init();
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;
  runApp(FinGuardApp(onboardingDone: onboardingDone));
}

class FinGuardApp extends StatelessWidget {
  final bool onboardingDone;
  const FinGuardApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => DigitalTwinProvider()),
        ChangeNotifierProvider(create: (_) => AiAssistantProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (_, theme, auth, __) => MaterialApp(
          title: 'FinGuard AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: theme.themeMode,
          home: _resolveHome(auth),
          routes: {
            '/onboarding': (_) => const OnboardingScreen(),
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/home': (_) => const MainShell(),
          },
        ),
      ),
    );
  }

  Widget _resolveHome(AuthProvider auth) {
    if (!onboardingDone) return const OnboardingScreen();
    switch (auth.status) {
      case AuthStatus.authenticated:
        return const MainShell();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginScreen();
      default:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }
}
