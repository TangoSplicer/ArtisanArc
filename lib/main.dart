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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArtisanArcAppLoader());
}

class ArtisanArcAppLoader extends StatefulWidget {
  const ArtisanArcAppLoader({super.key});

  @override
  State<ArtisanArcAppLoader> createState() => _ArtisanArcAppLoaderState();
}

class _ArtisanArcAppLoaderState extends State<ArtisanArcAppLoader> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeApp();
  }

  Future<void> _initializeApp() async {
    await configureDependencies();
    registerHiveAdapters();
    final themeService = getIt<ThemeService>();
    await themeService.loadThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const ArtisanArcApp();
        }
        return const SplashScreen();
      },
    );
  }
}

class ArtisanArcApp extends StatelessWidget {
  const ArtisanArcApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = getIt<FlutterSecureStorage>();
    final seenOnboarding = storage.read(key: StorageKeys.onboardingComplete) == 'true';

    return ChangeNotifierProvider(
      create: (_) => getIt<ThemeService>(),
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp.router(
            title: 'ArtisanArc',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.currentThemeMode,
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
        },
      ),
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