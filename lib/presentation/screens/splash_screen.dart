import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/di/di.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/backup_service.dart';
import '../../core/utils/storage_keys.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _statusMessage = 'Loading your studio...';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.forward();
    _initializeServicesAndNavigate();
  }

  Future<void> _initializeServicesAndNavigate() async {
    bool seenOnboarding = false;

    try {
      // 1. Configure DI container with timeout guard
      setState(() => _statusMessage = 'Preparing studio workspace...');
      await configureDependencies().timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('Dependency configuration timed out; continuing with fallback.');
      });

      // 2. Initialize notifications safely
      setState(() => _statusMessage = 'Setting up reminders...');
      try {
        await NotificationService.initialize().timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Notification init skipped: $e');
      }

      // 3. Load theme mode
      setState(() => _statusMessage = 'Applying theme preferences...');
      try {
        final themeService = Provider.of<ThemeService>(context, listen: false);
        await themeService.loadThemeMode().timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Theme load skipped: $e');
      }

      // 4. Trigger backup snapshot in background
      Future.microtask(() async {
        try {
          await BackupService.createStartupSnapshotIfDue();
        } catch (e) {
          debugPrint('Startup snapshot skipped: $e');
        }
      });

      // 5. Check onboarding status from secure storage
      setState(() => _statusMessage = 'Checking maker profile...');
      try {
        const storage = FlutterSecureStorage();
        final value = await storage.read(key: StorageKeys.onboardingComplete)
            .timeout(const Duration(seconds: 3));
        seenOnboarding = (value == 'true');
      } catch (e) {
        debugPrint('Secure storage read timed out or failed: $e');
        seenOnboarding = false;
      }
    } catch (e) {
      debugPrint('General initialization error: $e');
    }

    // Ensure splash displays for at least 1.5 seconds for visual polish
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      if (seenOnboarding) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.handyman,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'ArtisanArc Personal',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
