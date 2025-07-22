import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  runApp(const SplashScreen()); // Show splash screen initially

  await configureDependencies();
  registerHiveAdapters();

  final storage = getIt<FlutterSecureStorage>();
  final seenOnboarding = await storage.read(key: StorageKeys.onboardingComplete) == 'true';

  final themeService = ThemeService();
  await themeService.loadThemeMode();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeService,
      child: ArtisanArcApp(
        seenOnboarding: seenOnboarding,
      ),
    ),
  );
}

class ArtisanArcApp extends StatefulWidget {
  final bool seenOnboarding;

  const ArtisanArcApp({
    super.key,
    required this.seenOnboarding,
  });

  @override
  State<ArtisanArcApp> createState() => _ArtisanArcAppState();
}

class _ArtisanArcAppState extends State<ArtisanArcApp> {
  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp.router(
      title: 'ArtisanArc',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.currentThemeMode,
      routerConfig: widget.seenOnboarding ? AppRouter.router : _onboardingFallbackRouter,
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

  static final GoRouter _onboardingFallbackRouter = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
    initialLocation: '/',
  );
}