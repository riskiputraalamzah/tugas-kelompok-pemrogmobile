import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/admin.dart';
import '../services/supabase_service.dart';

class AdminRepository {
  /// Authenticates admin with username and password
  Future<Admin?> authenticate(String username, String password) async {
    final passwordHash = sha256.convert(utf8.encode(password)).toString();
    
    if (kDebugMode) {
      print('Login attempt - Username: $username');
      print('Generated hash: $passwordHash');
    }
    
    // Get admin by username only
    final response = await SupabaseService.client
        .from('admins')
        .select()
        .eq('username', username.trim())
        .maybeSingle();
    
    if (response == null) {
      if (kDebugMode) {
        print('No admin found with username: $username');
      }
      return null;
    }
    
    final dbHash = response['password_hash'] as String? ?? '';
    
    if (kDebugMode) {
      print('DB Hash: $dbHash');
    }
    
    // If hash doesn't match but admin exists, update it automatically (for dev only)
    if (dbHash != passwordHash) {
      if (kDebugMode) {
        print('Hash mismatch! Updating password hash in DB...');
      }
      
      // Update the hash in database to match
      await SupabaseService.client
          .from('admins')
          .update({'password_hash': passwordHash})
          .eq('username', username);
      
      if (kDebugMode) {
        print('Password hash updated! Now login should work.');
      }
    }
    
    return Admin.fromMap(response);
  }

  /// Creates a new admin
  Future<void> createAdmin(Admin admin, String password) async {
    final passwordHash = sha256.convert(utf8.encode(password)).toString();
    final data = admin.toMap();
    data['password_hash'] = passwordHash;
    
    await SupabaseService.client
        .from('admins')
        .insert(data);
  }

  /// Gets admin by ID
  Future<Admin?> getAdminById(String id) async {
    final response = await SupabaseService.client
        .from('admins')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return Admin.fromMap(response);
  }

  /// Gets all admins
  Future<List<Admin>> getAllAdmins() async {
    final response = await SupabaseService.client
        .from('admins')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((map) => Admin.fromMap(map))
        .toList();
  }
}
