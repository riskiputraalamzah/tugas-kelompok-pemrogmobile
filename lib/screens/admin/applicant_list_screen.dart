import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/job.dart';
import '../../models/application.dart';
import '../../config/theme.dart';
import 'applicant_detail_screen.dart';

class ApplicantListScreen extends StatefulWidget {
  const ApplicantListScreen({super.key});

  @override
  State<ApplicantListScreen> createState() => _ApplicantListScreenState();
}

class _ApplicantListScreenState extends State<ApplicantListScreen> {
  Job? _selectedJob;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      provider.loadJobs();
      provider.loadApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pelamar'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final jobs = provider.jobs;

          return Column(
            children: [
              // Job filter dropdown
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Lowongan',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Job>(
                      value: _selectedJob,
                      decoration: const InputDecoration(
                        hintText: 'Semua Lowongan',
                        prefixIcon: Icon(Icons.filter_list),
                      ),
                      items: [
                        const DropdownMenuItem<Job>(
                          value: null,
                          child: Text('Semua Lowongan'),
                        ),
                        ...jobs.map((job) => DropdownMenuItem(
                              value: job,
                              child: Text(
                                job.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedJob = value;
                        });
                      },
                    ),
                    if (_selectedJob != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: provider.isLoading
                              ? null
                              : () async {
                                  final success = await provider
                                      .processAIRanking(_selectedJob!.id);
                                  if (mounted && success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('AI Ranking selesai!'),
                                        backgroundColor: AppTheme.acceptedColor,
                                      ),
                                    );
                                  }
                                },
                          icon: provider.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: const Text('Trigger AI Ranking'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Applicant list
              Expanded(
                child: _buildApplicantList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildApplicantList(AppProvider provider) {
    final applications = _selectedJob != null
        ? provider.applications
            .where((a) => a.jobId == _selectedJob!.id)
            .toList()
        : provider.applications;

    // Sort by AI score if available
    applications.sort((a, b) {
      if (a.aiScore != null && b.aiScore != null) {
        return b.aiScore!.compareTo(a.aiScore!);
      }
      if (a.aiScore != null) return -1;
      if (b.aiScore != null) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada pelamar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.subtitleColor,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ApplicantDetailScreen(application: app),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar with score
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: Text(
                          app.fullName.isNotEmpty
                              ? app.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      if (app.aiScore != null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _getScoreColor(app.aiScore!),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              '${app.aiScore!.toInt()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                app.fullName,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(app.status.name)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                app.status.displayName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(app.status.name),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          app.email,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (app.aiLabel != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getScoreColor(app.aiScore ?? 0)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 12,
                                  color: _getScoreColor(app.aiScore ?? 0),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  app.aiLabel!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _getScoreColor(app.aiScore ?? 0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  Icon(
                    Icons.chevron_right,
                    color: AppTheme.subtitleColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return AppTheme.acceptedColor;
    if (score >= 50) return AppTheme.primaryColor;
    if (score >= 30) return AppTheme.warningColor;
    return AppTheme.rejectedColor;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.pendingColor;
      case 'review':
        return AppTheme.reviewColor;
      case 'accepted':
        return AppTheme.acceptedColor;
      case 'rejected':
        return AppTheme.rejectedColor;
      default:
        return AppTheme.subtitleColor;
    }
  }
}
