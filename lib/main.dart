import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/di/di.dart';
import 'core/utils/hive_adapters.dart';
import 'core/utils/storage_keys.dart';
import 'core/theme/app_theme.dart';
import 'core/services/theme_service.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/screens/splash_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  registerHiveAdapters();

  final storage = FlutterSecureStorage();
  final seenOnboarding = await storage.read(key: StorageKeys.onboardingComplete) == 'true';
  final themeMode = await ThemeService().getThemeMode();

  runApp(ArtisanArcApp(
    seenOnboarding: seenOnboarding,
    themeMode: themeMode,
  ));
}

class ArtisanArcApp extends StatelessWidget {
  final bool seenOnboarding;
  final ThemeMode themeMode;

  const ArtisanArcApp({
    super.key,
    required this.seenOnboarding,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ArtisanArc',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: seenOnboarding ? AppRouter.router : _onboardingFallbackRouter,
      supportedLocales: const [
        Locale('en', 'GB'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('en', 'GB'),
    );
  }

  static final _onboardingFallbackRouter = AppRouter.createFallbackRouter(
    const OnboardingScreen(),
  );
}