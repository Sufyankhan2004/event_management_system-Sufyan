import 'package:supabase_flutter/supabase_flutter.dart';

// ================================
// SUPABASE CONFIGURATION
// ================================

const String supabaseUrl = 'https://wftwgjueaummssyqkcmc.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmdHdnanVlYXVtbXNzeXFrY21jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4MDkyMTIsImV4cCI6MjA4MTM4NTIxMn0.AQ5x3O9sljTDEDZd9dgQEC1ATkhaWREBBDCg2XHxDnE';

final supabase = Supabase.instance.client;
