import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/job_card.dart';
import '../../config/theme.dart';
import 'job_form_screen.dart';

class JobManagementScreen extends StatefulWidget {
  const JobManagementScreen({super.key});

  @override
  State<JobManagementScreen> createState() => _JobManagementScreenState();
}

class _JobManagementScreenState extends State<JobManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadJobs();
    });
  }

  void _deleteJob(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Lowongan'),
        content: const Text('Apakah Anda yakin ingin menghapus lowongan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<AppProvider>().deleteJob(id);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lowongan berhasil dihapus'),
                    backgroundColor: AppTheme.acceptedColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Lowongan'),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AppProvider>().loadJobs();
        },
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final jobs = provider.jobs;

            if (provider.isLoading && jobs.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (jobs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work_off_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada lowongan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.subtitleColor,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const JobFormScreen()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Lowongan'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      JobCard(
                        job: job,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobFormScreen(job: job),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await provider.toggleJobStatus(job.id, !job.isOpen);
                                },
                                icon: Icon(
                                  job.isOpen ? Icons.visibility_off : Icons.visibility,
                                  size: 18,
                                ),
                                label: Text(job.isOpen ? 'Tutup' : 'Buka'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      job.isOpen ? AppTheme.warningColor : AppTheme.acceptedColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _deleteJob(job.id),
                                icon: const Icon(Icons.delete_outline, size: 18),
                                label: const Text('Hapus'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.errorColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JobFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}
