import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/stations_provider.dart';
import 'providers/preferences_provider.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait (optional — remove for tablet landscape support)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Init preferences
  final prefs = PreferencesProvider();
  await prefs.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PreferencesProvider>.value(value: prefs),
        ChangeNotifierProvider<StationsProvider>(
          create: (_) => StationsProvider(),
        ),
      ],
      child: const FuelScoutApp(),
    ),
  );
}

class FuelScoutApp extends StatelessWidget {
  const FuelScoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FuelScout',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const OnboardingScreen(),
      builder: (context, child) {
        // Global font scaling guard — prevents OS font size from breaking layout
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.textScalerOf(context).scale(1).clamp(0.85, 1.3),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
