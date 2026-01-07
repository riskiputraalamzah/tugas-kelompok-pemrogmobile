import '../models/application.dart';
import '../services/supabase_service.dart';
import '../services/ai_ranking_service.dart';

class ApplicationRepository {
  /// Gets all applications
  Future<List<Application>> getAllApplications() async {
    final response = await SupabaseService.client
        .from('applications')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((map) => Application.fromMap(map))
        .toList();
  }

  /// Gets applications by job ID
  Future<List<Application>> getApplicationsByJobId(String jobId) async {
    final response = await SupabaseService.client
        .from('applications')
        .select()
        .eq('job_id', jobId)
        .order('ai_score', ascending: false);
    
    return (response as List)
        .map((map) => Application.fromMap(map))
        .toList();
  }

  /// Gets application by ID
  Future<Application?> getApplicationById(String id) async {
    final response = await SupabaseService.client
        .from('applications')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return Application.fromMap(response);
  }

  /// Gets applications by email
  Future<List<Application>> getApplicationsByEmail(String email) async {
    final response = await SupabaseService.client
        .from('applications')
        .select()
        .eq('email', email)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((map) => Application.fromMap(map))
        .toList();
  }

  /// Checks if email already applied for a job
  Future<bool> hasApplied(String jobId, String email) async {
    final response = await SupabaseService.client
        .from('applications')
        .select()
        .eq('job_id', jobId)
        .eq('email', email)
        .maybeSingle();
    
    return response != null;
  }

  /// Creates a new application
  Future<void> insertApplication(Application application) async {
    await SupabaseService.client
        .from('applications')
        .insert(application.toMap());
  }

  /// Updates an existing application
  Future<void> updateApplication(Application application) async {
    final data = application.copyWith(updatedAt: DateTime.now()).toMap();
    await SupabaseService.client
        .from('applications')
        .update(data)
        .eq('id', application.id);
  }

  /// Updates application status
  Future<void> updateStatus(String id, ApplicationStatus status) async {
    await SupabaseService.client
        .from('applications')
        .update({
          'status': status.dbValue,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  /// Updates AI score and label
  Future<void> updateAIScore(String id, double score, String label) async {
    await SupabaseService.client
        .from('applications')
        .update({
          'ai_score': score,
          'ai_label': label,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  /// Process AI ranking for all applications of a job
  Future<void> processAIRankingForJob(String jobId) async {
    final applications = await getApplicationsByJobId(jobId);
    
    for (final app in applications) {
      final result = await AIRankingService.analyzeApplication(app);
      await updateAIScore(
        app.id,
        result['score'] as double,
        result['label'] as String,
      );
    }
  }

  /// Deletes an application
  Future<void> deleteApplication(String id) async {
    await SupabaseService.client
        .from('applications')
        .delete()
        .eq('id', id);
  }

  /// Gets total application count
  Future<int> getApplicationCount() async {
    final response = await SupabaseService.client
        .from('applications')
        .select();
    
    return (response as List).length;
  }

  /// Gets pending application count
  Future<int> getPendingApplicationCount() async {
    final response = await SupabaseService.client
        .from('applications')
        .select()
        .eq('status', 'pending');
    
    return (response as List).length;
  }
}
