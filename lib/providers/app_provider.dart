import 'package:flutter/material.dart';
import '../models/admin.dart';
import '../models/job.dart';
import '../models/application.dart';
import '../models/interview.dart';
import '../models/broadcast.dart';
import '../repositories/admin_repository.dart';
import '../repositories/job_repository.dart';
import '../repositories/application_repository.dart';
import '../repositories/interview_repository.dart';
import '../repositories/broadcast_repository.dart';

class AppProvider extends ChangeNotifier {
  final AdminRepository _adminRepo = AdminRepository();
  final JobRepository _jobRepo = JobRepository();
  final ApplicationRepository _appRepo = ApplicationRepository();
  final InterviewRepository _interviewRepo = InterviewRepository();
  final BroadcastRepository _broadcastRepo = BroadcastRepository();

  // State
  Admin? _currentAdmin;
  List<Job> _jobs = [];
  List<Application> _applications = [];
  List<Interview> _interviews = [];
  List<Broadcast> _broadcasts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Admin? get currentAdmin => _currentAdmin;
  bool get isLoggedIn => _currentAdmin != null;
  List<Job> get jobs => _jobs;
  List<Job> get openJobs => _jobs.where((j) => j.isOpen).toList();
  List<Application> get applications => _applications;
  List<Interview> get interviews => _interviews;
  List<Broadcast> get broadcasts => _broadcasts;
  List<Broadcast> get activeBroadcasts => _broadcasts.where((b) => b.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Statistics
  int get totalJobs => _jobs.length;
  int get openJobsCount => _jobs.where((j) => j.isOpen).length;
  int get totalApplications => _applications.length;
  int get pendingApplications => _applications.where((a) => a.status == ApplicationStatus.pending).length;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Admin Methods
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final admin = await _adminRepo.authenticate(username, password);
      if (admin != null) {
        _currentAdmin = admin;
        await loadAllData();
        _setLoading(false);
        return true;
      } else {
        _setError('Username atau password salah');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      _setLoading(false);
      return false;
    }
  }

  void logout() {
    _currentAdmin = null;
    notifyListeners();
  }

  // Data Loading
  Future<void> loadAllData() async {
    await Future.wait([
      loadJobs(),
      loadApplications(),
      loadInterviews(),
      loadBroadcasts(),
    ]);
  }

  Future<void> loadJobs() async {
    try {
      _jobs = await _jobRepo.getAllJobs();
      notifyListeners();
    } catch (e) {
      _setError('Gagal memuat lowongan: $e');
    }
  }

  Future<void> loadOpenJobs() async {
    try {
      _jobs = await _jobRepo.getOpenJobs();
      notifyListeners();
    } catch (e) {
      _setError('Gagal memuat lowongan: $e');
    }
  }

  Future<void> loadApplications() async {
    try {
      _applications = await _appRepo.getAllApplications();
      notifyListeners();
    } catch (e) {
      _setError('Gagal memuat lamaran: $e');
    }
  }

  Future<void> loadInterviews() async {
    try {
      _interviews = await _interviewRepo.getAllInterviews();
      notifyListeners();
    } catch (e) {
      _setError('Gagal memuat jadwal: $e');
    }
  }

  Future<void> loadBroadcasts() async {
    try {
      _broadcasts = await _broadcastRepo.getActiveBroadcasts();
      notifyListeners();
    } catch (e) {
      _setError('Gagal memuat broadcast: $e');
    }
  }

  // Job Methods
  Future<Job?> getJobById(String id) async {
    return await _jobRepo.getJobById(id);
  }

  Future<bool> createJob(Job job) async {
    _setLoading(true);
    try {
      await _jobRepo.insertJob(job);
      await loadJobs();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal membuat lowongan: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateJob(Job job) async {
    _setLoading(true);
    try {
      await _jobRepo.updateJob(job);
      await loadJobs();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal memperbarui lowongan: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteJob(String id) async {
    _setLoading(true);
    try {
      await _jobRepo.deleteJob(id);
      await loadJobs();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal menghapus lowongan: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> toggleJobStatus(String id, bool isOpen) async {
    try {
      await _jobRepo.toggleJobStatus(id, isOpen);
      await loadJobs();
      return true;
    } catch (e) {
      _setError('Gagal mengubah status lowongan: $e');
      return false;
    }
  }

  // Application Methods
  Future<List<Application>> getApplicationsByJobId(String jobId) async {
    return await _appRepo.getApplicationsByJobId(jobId);
  }

  Future<List<Application>> getApplicationsByEmail(String email) async {
    return await _appRepo.getApplicationsByEmail(email);
  }

  Future<bool> hasApplied(String jobId, String email) async {
    return await _appRepo.hasApplied(jobId, email);
  }

  Future<bool> submitApplication(Application application) async {
    _setLoading(true);
    try {
      // Check for duplicate
      final hasDuplicate = await _appRepo.hasApplied(application.jobId, application.email);
      if (hasDuplicate) {
        _setError('Anda sudah melamar untuk posisi ini');
        _setLoading(false);
        return false;
      }
      
      await _appRepo.insertApplication(application);
      await loadApplications();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal mengirim lamaran: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateApplicationStatus(String id, ApplicationStatus status) async {
    try {
      await _appRepo.updateStatus(id, status);
      await loadApplications();
      return true;
    } catch (e) {
      _setError('Gagal memperbarui status: $e');
      return false;
    }
  }

  Future<bool> processAIRanking(String jobId) async {
    _setLoading(true);
    try {
      await _appRepo.processAIRankingForJob(jobId);
      await loadApplications();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal memproses AI Ranking: $e');
      _setLoading(false);
      return false;
    }
  }

  // Interview Methods
  Future<Interview?> getInterviewByApplicationId(String applicationId) async {
    return await _interviewRepo.getInterviewByApplicationId(applicationId);
  }

  Future<bool> hasInterviewConflict(DateTime scheduledAt, {String? excludeId}) async {
    return await _interviewRepo.hasConflict(scheduledAt, excludeId: excludeId);
  }

  Future<bool> scheduleInterview(Interview interview) async {
    _setLoading(true);
    try {
      // Check for conflict
      final hasConflict = await _interviewRepo.hasConflict(interview.scheduledAt);
      if (hasConflict) {
        _setError('Jadwal bentrok dengan interview lain');
        _setLoading(false);
        return false;
      }
      
      await _interviewRepo.insertInterview(interview);
      // Update application status to review
      await _appRepo.updateStatus(interview.applicationId, ApplicationStatus.review);
      await loadInterviews();
      await loadApplications();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal menjadwalkan interview: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> confirmInterview(String interviewId) async {
    try {
      await _interviewRepo.confirmAttendance(interviewId);
      await loadInterviews();
      return true;
    } catch (e) {
      _setError('Gagal mengkonfirmasi kehadiran: $e');
      return false;
    }
  }

  // Broadcast Methods
  Future<bool> createBroadcast(Broadcast broadcast) async {
    _setLoading(true);
    try {
      await _broadcastRepo.insertBroadcast(broadcast);
      await loadBroadcasts();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal membuat broadcast: $e');
      _setLoading(false);
      return false;
    }
  }
}
