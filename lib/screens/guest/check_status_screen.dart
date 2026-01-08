import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/app_provider.dart';
import '../../models/application.dart';
import '../../models/interview.dart';
import '../../models/job.dart'; // Added this import
import '../../widgets/status_badge.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/skeleton_loader.dart';
import '../../config/theme.dart';

class CheckStatusScreen extends StatefulWidget {
  const CheckStatusScreen({super.key});

  @override
  State<CheckStatusScreen> createState() => _CheckStatusScreenState();
}

class _CheckStatusScreenState extends State<CheckStatusScreen> {
  final _emailController = TextEditingController();
  List<Application>? _applications;
  Map<String, Interview?> _interviews = {};
  Map<String, Job> _jobs = {};
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _saveEmail = false;

  static const String _emailKey = 'saved_email';
  static const String _saveEmailKey = 'save_email_toggle';

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_emailKey);
    final shouldSave = prefs.getBool(_saveEmailKey) ?? false;
    
    if (savedEmail != null && savedEmail.isNotEmpty && shouldSave) {
      setState(() {
        _emailController.text = savedEmail;
        _saveEmail = shouldSave;
      });
      // Auto-search if email was saved
      _searchApplications();
    } else {
      setState(() => _saveEmail = shouldSave);
    }
  }

  Future<void> _saveEmailToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_saveEmail) {
      await prefs.setString(_emailKey, _emailController.text.trim());
    } else {
      await prefs.remove(_emailKey);
    }
    await prefs.setBool(_saveEmailKey, _saveEmail);
  }

  Color _getJobColor(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      Colors.teal,
      Colors.indigo,
      Colors.orange.shade800,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _searchApplications() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan email Anda')),
      );
      return;
    }

    // Save email if toggle is on
    await _saveEmailToPrefs();

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _jobs = {}; // Reset jobs
    });

    try {
      final provider = context.read<AppProvider>();
      final applications = await provider.getApplicationsByEmail(email);
      
      // Get interviews and jobs for each application
      final interviews = <String, Interview?>{};
      final jobs = <String, Job>{};

      for (final app in applications) {
        // Get interview
        final interview = await provider.getInterviewByApplicationId(app.id);
        interviews[app.id] = interview;

        // Get job details if not already loaded
        if (!jobs.containsKey(app.jobId)) {
          final job = await provider.getJobById(app.jobId);
          if (job != null) {
            jobs[app.jobId] = job;
          }
        }
      }

      setState(() {
        _applications = applications;
        _interviews = interviews;
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _confirmInterview(String interviewId) async {
    final provider = context.read<AppProvider>();
    final success = await provider.confirmInterview(interviewId);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kehadiran berhasil dikonfirmasi!'),
            backgroundColor: AppTheme.acceptedColor,
          ),
        );
        _searchApplications(); // Refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Gagal mengkonfirmasi'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
          // Gradient Header
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.darkGradient,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cek Status Lamaran',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Lacak progress lamaranmu',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Curved transition
          SliverToBoxAdapter(
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              transform: Matrix4.translationValues(0, -24, 0),
            ),
          ),
          // Search Input
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'contoh@email.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _searchApplications,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Email save toggle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      value: _saveEmail,
                      onChanged: (value) {
                        setState(() => _saveEmail = value);
                        _saveEmailToPrefs();
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    'Ingat email saya',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.subtitleColor,
                    ),
                  ),
                  const Spacer(),
                  if (_saveEmail && _emailController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 14, color: AppTheme.successColor),
                          const SizedBox(width: 4),
                          Text(
                            'Tersimpan',
                            style: TextStyle(
                              color: AppTheme.successColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Show skeleton loading when loading
          if (_isLoading)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: StatusCardSkeleton(),
                  ),
                  childCount: 2, // Show 2 skeleton cards
                ),
              ),
            )
          else if (_hasSearched)
            _applications == null || _applications!.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search_off_rounded,
                              size: 56,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Tidak ditemukan',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada lamaran dengan email tersebut',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final app = _applications![index];
                          final interview = _interviews[app.id];
                          return _buildApplicationCard(app, interview);
                        },
                        childCount: _applications!.length,
                      ),
                    ),
                  ),
        ],
      ),
    ),
  );
}

  Widget _buildApplicationCard(Application app, Interview? interview) {
    // Get job from loaded map, fallback if not found
    final job = _jobs[app.jobId];
    final index = _applications?.indexOf(app) ?? 0;
    final color = _getJobColor(index);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Visual Distinction: Colored Strip
            Container(width: 6, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job Header Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job?.title ?? 'Posisi tidak ditemukan',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dilamar: ${DateFormat('dd MMM yyyy').format(app.createdAt)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(status: app.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Status timeline
                    _buildStatusTimeline(app.status),

                    // Interview info if available
                    if (interview != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.event,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Jadwal Interview',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppTheme.primaryColor,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInterviewInfo(
                              Icons.calendar_today,
                              DateFormat('EEEE, dd MMMM yyyy', 'id')
                                  .format(interview.scheduledAt),
                            ),
                            const SizedBox(height: 8),
                            _buildInterviewInfo(
                              Icons.access_time,
                              DateFormat('HH:mm').format(interview.scheduledAt) +
                                  ' WIB',
                            ),
                            const SizedBox(height: 8),
                            _buildInterviewInfo(
                                Icons.location_on, interview.location),
                            if (interview.notes != null &&
                                interview.notes!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildInterviewInfo(Icons.note, interview.notes!),
                            ],
                            const SizedBox(height: 16),
                            if (interview.isConfirmed)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.acceptedColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppTheme.acceptedColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Kehadiran telah dikonfirmasi',
                                      style: TextStyle(
                                        color: AppTheme.acceptedColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _confirmInterview(interview.id),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Konfirmasi Kehadiran'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],

                    // Celebration card for accepted status
                    if (app.status == ApplicationStatus.accepted) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.acceptedColor,
                              AppTheme.acceptedColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.acceptedColor.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.celebration,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '🎉 Selamat! 🎉',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Anda diterima sebagai ${job?.title ?? 'posisi ini'}!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Tim HR akan segera menghubungi Anda',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Supportive card for rejected status
                    if (app.status == ApplicationStatus.rejected) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.sentiment_neutral_rounded,
                                color: Colors.grey.shade600,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Terima Kasih Telah Melamar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sayangnya, Anda belum berhasil dalam seleksi ${job?.title ?? 'posisi ini'} kali ini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Jangan menyerah! Tetap semangat dan coba lamar posisi lainnya',
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.subtitleColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(ApplicationStatus currentStatus) {
    final statuses = [
      ('Menunggu', ApplicationStatus.pending),
      ('Ditinjau', ApplicationStatus.review),
      ('Keputusan', ApplicationStatus.accepted),
    ];

    int currentIndex = 0;
    if (currentStatus == ApplicationStatus.review) {
      currentIndex = 1;
    } else if (currentStatus == ApplicationStatus.accepted ||
        currentStatus == ApplicationStatus.rejected) {
      currentIndex = 2;
    }

    return Row(
      children: List.generate(statuses.length * 2 - 1, (index) {
        if (index.isEven) {
          final statusIndex = index ~/ 2;
          final isCompleted = statusIndex < currentIndex;
          final isCurrent = statusIndex == currentIndex;
          final isRejected = currentStatus == ApplicationStatus.rejected && statusIndex == 2;

          return Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRejected
                      ? AppTheme.rejectedColor
                      : (isCompleted || isCurrent)
                          ? AppTheme.acceptedColor
                          : Colors.grey.shade300,
                ),
                child: Icon(
                  isRejected
                      ? Icons.close
                      : (isCompleted || isCurrent)
                          ? Icons.check
                          : Icons.circle,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusIndex == 2
                    ? (isRejected
                        ? 'Ditolak'
                        : (currentStatus == ApplicationStatus.accepted
                            ? 'Diterima'
                            : statuses[statusIndex].$1))
                    : statuses[statusIndex].$1,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: isCurrent
                      ? (isRejected ? AppTheme.rejectedColor : AppTheme.acceptedColor)
                      : AppTheme.subtitleColor,
                ),
              ),
            ],
          );
        } else {
          final prevIndex = index ~/ 2;
          final isCompleted = prevIndex < currentIndex;

          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.only(bottom: 20),
              color: isCompleted ? AppTheme.acceptedColor : Colors.grey.shade300,
            ),
          );
        }
      }),
    );
  }
}
