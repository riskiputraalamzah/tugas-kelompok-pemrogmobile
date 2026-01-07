import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/application.dart';
import '../../models/interview.dart';
import '../../providers/app_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/score_indicator.dart';
import '../../config/theme.dart';

class ApplicantDetailScreen extends StatefulWidget {
  final Application application;

  const ApplicantDetailScreen({super.key, required this.application});

  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  Interview? _interview;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInterview();
  }

  Future<void> _loadInterview() async {
    final provider = context.read<AppProvider>();
    final interview = await provider.getInterviewByApplicationId(widget.application.id);
    if (mounted) {
      setState(() {
        _interview = interview;
        _isLoading = false;
      });
    }
  }

  void _updateStatus(ApplicationStatus status) async {
    final provider = context.read<AppProvider>();
    final success = await provider.updateApplicationStatus(widget.application.id, status);
    
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status diperbarui ke ${status.displayName}'),
          backgroundColor: AppTheme.acceptedColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showScheduleDialog() {
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Jadwalkan Interview'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                        dateController.text = DateFormat('dd MMMM yyyy').format(date);
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: timeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Waktu',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (time != null) {
                      setDialogState(() {
                        selectedTime = time;
                        timeController.text = time.format(context);
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi',
                    prefixIcon: Icon(Icons.location_on),
                    hintText: 'Kantor / Online (Zoom/Meet)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    prefixIcon: Icon(Icons.note),
                    hintText: 'Info tambahan untuk kandidat',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedDate == null || selectedTime == null ||
                    locationController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lengkapi tanggal, waktu, dan lokasi'),
                    ),
                  );
                  return;
                }

                final scheduledAt = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );

                final interview = Interview(
                  id: const Uuid().v4(),
                  applicationId: widget.application.id,
                  scheduledAt: scheduledAt,
                  location: locationController.text.trim(),
                  notes: notesController.text.trim().isNotEmpty
                      ? notesController.text.trim()
                      : null,
                  createdAt: DateTime.now(),
                );

                final provider = context.read<AppProvider>();
                final success = await provider.scheduleInterview(interview);

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Interview berhasil dijadwalkan'),
                        backgroundColor: AppTheme.acceptedColor,
                      ),
                    );
                    _loadInterview();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.error ?? 'Gagal menjadwalkan'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                    provider.clearError();
                  }
                }
              },
              child: const Text('Jadwalkan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelamar'),
        actions: [
          PopupMenuButton<ApplicationStatus>(
            icon: const Icon(Icons.more_vert),
            onSelected: _updateStatus,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ApplicationStatus.review,
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 20),
                    SizedBox(width: 8),
                    Text('Tandai Ditinjau'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ApplicationStatus.accepted,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20, color: AppTheme.acceptedColor),
                    SizedBox(width: 8),
                    Text('Terima'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ApplicationStatus.rejected,
                child: Row(
                  children: [
                    Icon(Icons.cancel, size: 20, color: AppTheme.rejectedColor),
                    SizedBox(width: 8),
                    Text('Tolak'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with score
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: Text(
                              widget.application.fullName.isNotEmpty
                                  ? widget.application.fullName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.application.fullName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.application.email,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.application.phone,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                StatusBadge(status: widget.application.status),
                              ],
                            ),
                          ),
                          if (widget.application.aiScore != null)
                            ScoreIndicator(
                              score: widget.application.aiScore!,
                              label: widget.application.aiLabel,
                              size: 70,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Interview info
                  if (_interview != null) ...[
                    Card(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.event, color: AppTheme.primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Jadwal Interview',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppTheme.primaryColor,
                                      ),
                                ),
                                const Spacer(),
                                if (_interview!.isConfirmed)
                                  const Chip(
                                    label: Text('Dikonfirmasi'),
                                    backgroundColor: AppTheme.acceptedColor,
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.calendar_today,
                              DateFormat('EEEE, dd MMMM yyyy').format(_interview!.scheduledAt),
                            ),
                            _buildInfoRow(
                              Icons.access_time,
                              DateFormat('HH:mm').format(_interview!.scheduledAt) + ' WIB',
                            ),
                            _buildInfoRow(Icons.location_on, _interview!.location),
                            if (_interview!.notes != null)
                              _buildInfoRow(Icons.note, _interview!.notes!),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (widget.application.status == ApplicationStatus.review ||
                      widget.application.status == ApplicationStatus.pending) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showScheduleDialog,
                        icon: const Icon(Icons.event_available),
                        label: const Text('Jadwalkan Interview'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Details sections
                  _buildSection('Pendidikan', Icons.school, widget.application.education),
                  _buildSection('Pengalaman', Icons.work, widget.application.experience),
                  _buildSection('Keahlian', Icons.psychology, widget.application.skills),
                  _buildSection('Motivasi', Icons.edit_document, widget.application.coverLetter),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.subtitleColor),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 16),
      ],
    );
  }
}
