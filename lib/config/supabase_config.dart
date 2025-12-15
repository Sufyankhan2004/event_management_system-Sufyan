import 'package:supabase_flutter/supabase_flutter.dart';

// ================================
// SUPABASE CONFIGURATION
// ================================

const String supabaseUrl = 'https://xygfvujsofwqyhiltere.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5Z2Z2dWpzb2Z3cXloaWx0ZXJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzMDE1NDIsImV4cCI6MjA4MDg3NzU0Mn0.GZZ-L_dkTyEifum5DErnHLzvOQ1wsEOmIR0aWg4W3rU';

final supabase = Supabase.instance.client;
