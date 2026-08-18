import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/di/di.dart';
import 'core/utils/hive_adapters.dart';
import 'core/utils/storage_keys.dart';
import 'core/theme/app_theme.dart';
import 'core/services/theme_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/backup_service.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive immediately and register adapters
  await Hive.initFlutter();
  registerHiveAdapters();

  // Launch app immediately to dismiss native splash screen instantly
  runApp(const ArtisanArcRootApp());
}

class ArtisanArcRootApp extends StatelessWidget {
  const ArtisanArcRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp.router(
            title: 'ArtisanArc Personal',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.currentThemeMode,
            routerConfig: AppRouter.router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'GB'),
              Locale('en', 'US'),
            ],
          );
        },
      ),
    );
  }
}
