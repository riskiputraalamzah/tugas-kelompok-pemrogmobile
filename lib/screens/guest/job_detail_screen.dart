import 'package:flutter/material.dart';
import '../../models/job.dart';
import '../../config/theme.dart';
import 'application_form_screen.dart';
import 'voice_apply_screen.dart';
import 'cv_upload_screen.dart';

class JobDetailScreen extends StatelessWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Lowongan'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.work,
                          color: AppTheme.primaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: AppTheme.subtitleColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  job.location,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.subtitleColor,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag(context, Icons.work_outline, job.employmentType),
                      _buildTag(context, Icons.payments_outlined, job.salaryRange),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: job.isOpen
                              ? AppTheme.acceptedColor.withValues(alpha: 0.1)
                              : AppTheme.rejectedColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              job.isOpen ? Icons.check_circle : Icons.cancel,
                              size: 16,
                              color: job.isOpen ? AppTheme.acceptedColor : AppTheme.rejectedColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              job.isOpen ? 'Lowongan Aktif' : 'Lowongan Ditutup',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: job.isOpen ? AppTheme.acceptedColor : AppTheme.rejectedColor,
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
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    'Deskripsi Pekerjaan',
                    Icons.description_outlined,
                    job.description,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Persyaratan',
                    Icons.checklist_outlined,
                    job.requirements,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: job.isOpen
                ? () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Pilih Metode Pelamaran',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            
                            // Manual Input
                            _buildModeOption(
                              context,
                              icon: Icons.edit_document,
                              title: 'Isi Manual',
                              subtitle: 'Isi formulir lamaran secara manual',
                              color: AppTheme.primaryColor,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ApplicationFormScreen(job: job),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            
                            // Voice Input
                            _buildModeOption(
                              context,
                              icon: Icons.mic,
                              title: 'Voice Input',
                              subtitle: 'Isi formulir dengan suara (Beta)',
                              color: AppTheme.secondaryColor,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VoiceApplyScreen(job: job),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            
                            // Upload CV
                            _buildModeOption(
                              context,
                              icon: Icons.upload_file,
                              title: 'Upload CV',
                              subtitle: 'Otomatis isi data dari CV (PDF)',
                              color: AppTheme.accentColor,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CVUploadScreen(job: job),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Lamar Sekarang'),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.subtitleColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    String content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ),
        ),
      ],
    );
  }
  Widget _buildModeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
