import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/application.dart';
import '../../models/interview.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_text_field.dart';
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
  bool _isLoading = false;
  bool _hasSearched = false;

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

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final provider = context.read<AppProvider>();
      final applications = await provider.getApplicationsByEmail(email);
      
      // Get interviews for each application
      final interviews = <String, Interview?>{};
      for (final app in applications) {
        final interview = await provider.getInterviewByApplicationId(app.id);
        interviews[app.id] = interview;
      }

      setState(() {
        _applications = applications;
        _interviews = interviews;
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cek Status Lamaran',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masukkan email yang digunakan saat melamar',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.subtitleColor,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'contoh@email.com',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _searchApplications,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_hasSearched)
            _applications == null || _applications!.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ditemukan',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.subtitleColor,
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
    );
  }

  Widget _buildApplicationCard(Application app, Interview? interview) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder(
                    future: context.read<AppProvider>().getJobById(app.jobId),
                    builder: (context, snapshot) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data?.title ?? 'Loading...',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Dilamar: ${DateFormat('dd MMM yyyy').format(app.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      );
                    },
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
                      DateFormat('EEEE, dd MMMM yyyy', 'id').format(interview.scheduledAt),
                    ),
                    const SizedBox(height: 8),
                    _buildInterviewInfo(
                      Icons.access_time,
                      DateFormat('HH:mm').format(interview.scheduledAt) + ' WIB',
                    ),
                    const SizedBox(height: 8),
                    _buildInterviewInfo(Icons.location_on, interview.location),
                    if (interview.notes != null && interview.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildInterviewInfo(Icons.note, interview.notes!),
                    ],
                    const SizedBox(height: 16),
                    if (interview.isConfirmed)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.acceptedColor.withValues(alpha: 0.1),
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
                          onPressed: () => _confirmInterview(interview.id),
                          icon: const Icon(Icons.check),
                          label: const Text('Konfirmasi Kehadiran'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
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
                isRejected ? 'Ditolak' : statuses[statusIndex].$1,
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
