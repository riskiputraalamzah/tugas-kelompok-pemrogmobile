import '../models/interview.dart';
import '../services/supabase_service.dart';

class InterviewRepository {
  /// Gets all interviews
  Future<List<Interview>> getAllInterviews() async {
    final response = await SupabaseService.client
        .from('interviews')
        .select()
        .order('scheduled_at', ascending: true);
    
    return (response as List)
        .map((map) => Interview.fromMap(map))
        .toList();
  }

  /// Gets interview by ID
  Future<Interview?> getInterviewById(String id) async {
    final response = await SupabaseService.client
        .from('interviews')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return Interview.fromMap(response);
  }

  /// Gets interview by application ID
  Future<Interview?> getInterviewByApplicationId(String applicationId) async {
    final response = await SupabaseService.client
        .from('interviews')
        .select()
        .eq('application_id', applicationId)
        .maybeSingle();
    
    if (response == null) return null;
    return Interview.fromMap(response);
  }

  /// Creates a new interview
  Future<void> insertInterview(Interview interview) async {
    await SupabaseService.client
        .from('interviews')
        .insert(interview.toMap());
  }

  /// Updates an existing interview
  Future<void> updateInterview(Interview interview) async {
    final data = interview.copyWith(updatedAt: DateTime.now()).toMap();
    await SupabaseService.client
        .from('interviews')
        .update(data)
        .eq('id', interview.id);
  }

  /// Deletes an interview
  Future<void> deleteInterview(String id) async {
    await SupabaseService.client
        .from('interviews')
        .delete()
        .eq('id', id);
  }

  /// Deletes interview by application ID
  Future<void> deleteByApplicationId(String applicationId) async {
    await SupabaseService.client
        .from('interviews')
        .delete()
        .eq('application_id', applicationId);
  }

  /// Confirms interview attendance
  Future<void> confirmAttendance(String id) async {
    await SupabaseService.client
        .from('interviews')
        .update({
          'is_confirmed': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  /// Checks for scheduling conflicts (within 1 hour range)
  Future<bool> hasConflict(DateTime scheduledAt, {String? excludeId}) async {
    final startRange = scheduledAt.subtract(const Duration(hours: 1));
    final endRange = scheduledAt.add(const Duration(hours: 1));
    
    var query = SupabaseService.client
        .from('interviews')
        .select()
        .gte('scheduled_at', startRange.toIso8601String())
        .lte('scheduled_at', endRange.toIso8601String());
    
    if (excludeId != null) {
      query = query.neq('id', excludeId);
    }
    
    final response = await query;
    return (response as List).isNotEmpty;
  }

  /// Gets upcoming interviews
  Future<List<Interview>> getUpcomingInterviews() async {
    final response = await SupabaseService.client
        .from('interviews')
        .select()
        .gte('scheduled_at', DateTime.now().toIso8601String())
        .order('scheduled_at', ascending: true);
    
    return (response as List)
        .map((map) => Interview.fromMap(map))
        .toList();
  }
}
