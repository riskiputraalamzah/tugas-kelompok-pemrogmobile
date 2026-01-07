import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://fxdljmnxceyaqjiutbhj.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_lOBn_Np6JjeuOWjrQ_G93w_1fM06LHu';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
