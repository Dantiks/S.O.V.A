import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finer/core/constants/app_colors.dart';
import 'package:finer/core/router/app_router.dart';
import 'package:finer/core/services/security_service.dart';
import 'package:finer/core/services/storage_service.dart';
import 'package:finer/core/theme/app_theme.dart';
import 'package:finer/presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  try {
    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
  } catch (e) {
    print('SharedPreferences initialization failed: $e');
  }

  try {
    // Initialize Security Service
    final securityService = SecurityService();
    await securityService.initialize();
  } catch (e) {
    print('Security Service initialization failed: $e');
  }

  try {
    // Initialize Storage Service
    final storageService = StorageService(securityService);
    await storageService.initialize();
  } catch (e) {
    print('Storage Service initialization failed: $e');
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const SovaApp(),
    ),
  );
}

class SovaApp extends ConsumerWidget {
  const SovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'S.O.V.A',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.read(themeControllerProvider.notifier).getEffectiveThemeMode(),
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: child!,
        );
      },
    );
  }
}
