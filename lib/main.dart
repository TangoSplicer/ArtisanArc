import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart'; // Added Provider
import 'core/di/di.dart';
import 'core/utils/hive_adapters.dart';
import 'core/utils/storage_keys.dart';
import 'core/theme/app_theme.dart';
import 'core/services/theme_service.dart';
import 'presentation/routes/app_router.dart';
// import 'presentation/screens/splash_screen.dart'; // Removed splash screen
import 'presentation/onboarding/onboarding_screen.dart'; // Corrected import path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  registerHiveAdapters();

  final storage = getIt<FlutterSecureStorage>(); // Using GetIt for storage
  final seenOnboarding = await storage.read(key: StorageKeys.onboardingComplete) == 'true';

  // ThemeService will be initialized and its theme loaded via ChangeNotifierProvider
  final themeService = ThemeService();
  await themeService.loadThemeMode(); // Load initial theme

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeService,
      child: ArtisanArcApp(
        seenOnboarding: seenOnboarding,
      ),
    ),
  );
}

class ArtisanArcApp extends StatefulWidget { // Changed to StatefulWidget
  final bool seenOnboarding;

  const ArtisanArcApp({
    super.key,
    required this.seenOnboarding,
  });

  @override
  State<ArtisanArcApp> createState() => _ArtisanArcAppState();
}

class _ArtisanArcAppState extends State<ArtisanArcApp> { // State class for ArtisanArcApp
  @override
  Widget build(BuildContext context) {
    // Listen to ThemeService changes
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp.router(
      title: 'ArtisanArc',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.currentThemeMode, // Consuming themeMode from ThemeService
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

  // Assuming AppRouter.createFallbackRouter is a static method you might have
  // If not, this part needs to be adjusted based on your actual AppRouter implementation
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