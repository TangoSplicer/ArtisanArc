import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/di/di.dart';
import 'core/utils/hive_adapters.dart';
import 'core/utils/storage_keys.dart';
import 'core/theme/app_theme.dart';
import 'core/services/theme_service.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  registerHiveAdapters();
  final themeService = getIt<ThemeService>();
  await themeService.loadThemeMode();
  final storage = getIt<FlutterSecureStorage>();
  final seenOnboarding = await storage.read(key: StorageKeys.onboardingComplete) == 'true';

  runApp(ArtisanArcApp(
    themeService: themeService,
    seenOnboarding: seenOnboarding,
  ));
}

class ArtisanArcApp extends StatelessWidget {
  final ThemeService themeService;
  final bool seenOnboarding;

  const ArtisanArcApp({
    super.key,
    required this.themeService,
    required this.seenOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeService,
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp.router(
            title: 'ArtisanArc',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.currentThemeMode,
            routerConfig: AppRouter.router,
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
        },
      ),
    );
  }
}
