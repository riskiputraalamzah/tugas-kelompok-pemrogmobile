import '../models/job.dart';
import '../services/supabase_service.dart';

class JobRepository {
  /// Gets all jobs
  Future<List<Job>> getAllJobs() async {
    final response = await SupabaseService.client
        .from('jobs')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((map) => Job.fromMap(map))
        .toList();
  }

  /// Gets all open jobs
  Future<List<Job>> getOpenJobs() async {
    final response = await SupabaseService.client
        .from('jobs')
        .select()
        .eq('is_open', true)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((map) => Job.fromMap(map))
        .toList();
  }

  /// Gets job by ID
  Future<Job?> getJobById(String id) async {
    final response = await SupabaseService.client
        .from('jobs')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return Job.fromMap(response);
  }

  /// Creates a new job
  Future<void> insertJob(Job job) async {
    await SupabaseService.client
        .from('jobs')
        .insert(job.toMap());
  }

  /// Updates an existing job
  Future<void> updateJob(Job job) async {
    final data = job.copyWith(updatedAt: DateTime.now()).toMap();
    await SupabaseService.client
        .from('jobs')
        .update(data)
        .eq('id', job.id);
  }

  /// Deletes a job
  Future<void> deleteJob(String id) async {
    await SupabaseService.client
        .from('jobs')
        .delete()
        .eq('id', id);
  }

  /// Toggles job open/close status
  Future<void> toggleJobStatus(String id, bool isOpen) async {
    await SupabaseService.client
        .from('jobs')
        .update({
          'is_open': isOpen,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  /// Gets count of open jobs
  Future<int> getOpenJobCount() async {
    final response = await SupabaseService.client
        .from('jobs')
        .select()
        .eq('is_open', true);
    
    return (response as List).length;
  }
}
