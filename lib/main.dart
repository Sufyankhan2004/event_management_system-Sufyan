// ================================
// EVENT MANAGEMENT SYSTEM - MAIN ENTRY POINT
// ================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'screens/auth/splash_screen.dart';

// ================================
// MAIN FUNCTION
// ================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  runApp(const EventManagementApp());
}

// ================================
// ROOT APP
// ================================

class EventManagementApp extends StatelessWidget {
  const EventManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
