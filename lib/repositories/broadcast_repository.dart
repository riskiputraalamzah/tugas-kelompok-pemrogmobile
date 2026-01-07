import '../models/broadcast.dart';
import '../services/supabase_service.dart';

class BroadcastRepository {
  /// Gets all broadcasts
  Future<List<Broadcast>> getAllBroadcasts() async {
    final response = await SupabaseService.client
        .from('broadcasts')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((map) => Broadcast.fromMap(map))
        .toList();
  }

  /// Gets active broadcasts only
  Future<List<Broadcast>> getActiveBroadcasts() async {
    final response = await SupabaseService.client
        .from('broadcasts')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((map) => Broadcast.fromMap(map))
        .toList();
  }

  /// Gets broadcast by ID
  Future<Broadcast?> getBroadcastById(String id) async {
    final response = await SupabaseService.client
        .from('broadcasts')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return Broadcast.fromMap(response);
  }

  /// Creates a new broadcast
  Future<void> insertBroadcast(Broadcast broadcast) async {
    await SupabaseService.client
        .from('broadcasts')
        .insert(broadcast.toMap());
  }

  /// Updates an existing broadcast
  Future<void> updateBroadcast(Broadcast broadcast) async {
    final data = broadcast.copyWith(updatedAt: DateTime.now()).toMap();
    await SupabaseService.client
        .from('broadcasts')
        .update(data)
        .eq('id', broadcast.id);
  }

  /// Deletes a broadcast
  Future<void> deleteBroadcast(String id) async {
    await SupabaseService.client
        .from('broadcasts')
        .delete()
        .eq('id', id);
  }

  /// Toggles broadcast active status
  Future<void> toggleActiveStatus(String id, bool isActive) async {
    await SupabaseService.client
        .from('broadcasts')
        .update({
          'is_active': isActive,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }
}
