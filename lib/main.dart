import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

import 'providers/onboarding_provider.dart';
import 'providers/news_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/settings_provider.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/category_selection_screen.dart';
import 'screens/onboarding/location_selection_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/saved/saved_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/search/search_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const AIVoiceNewsApp());
}

class AIVoiceNewsApp extends StatelessWidget {
  const AIVoiceNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NewsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BookmarkProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AudioProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'AI Voice News',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.darkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (context) => const SplashScreen(),
              AppRoutes.onboarding: (context) =>
                  const OnboardingScreen(),
              AppRoutes.categorySelection: (_) =>
                  const CategorySelectionScreen(),
              AppRoutes.locationSelection: (_) =>
                  const LocationSelectionScreen(),
              AppRoutes.home: (_) => const HomeScreen(),
              AppRoutes.profile: (_) => const ProfileScreen(),
              AppRoutes.settings: (_) => const SettingsScreen(),
              AppRoutes.saved: (_) => const SavedScreen(),
              AppRoutes.search: (_) => const SearchScreen(),
            },
          );
        },
      ),
    );
  }
}
