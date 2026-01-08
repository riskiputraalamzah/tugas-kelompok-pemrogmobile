import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/application.dart';
import '../../models/interview.dart';
import '../../models/job.dart';
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
  Job? _job;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<AppProvider>();
    final interview = await provider.getInterviewByApplicationId(widget.application.id);
    final job = await provider.getJobById(widget.application.jobId);
    if (mounted) {
      setState(() {
        _interview = interview;
        _job = job;
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

  Future<void> _updateInterviewStatus(InterviewStatus status) async {
    if (_interview == null) return;
    
    final updatedInterview = _interview!.copyWith(status: status);
    final provider = context.read<AppProvider>();
    final success = await provider.updateInterview(updatedInterview);
    
    if (mounted && success) {
      setState(() {
        _interview = updatedInterview;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status interview: ${status.displayName}'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  Future<void> _updateInterviewResult(InterviewResult result) async {
    if (_interview == null) return;
    
    final updatedInterview = _interview!.copyWith(
      status: InterviewStatus.completed,
      result: result,
    );
    final provider = context.read<AppProvider>();
    final success = await provider.updateInterview(updatedInterview);
    
    if (mounted && success) {
      setState(() {
        _interview = updatedInterview;
      });
      
      // Auto-update application status based on result
      if (result == InterviewResult.passed) {
        // Optionally suggest to accept application
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
            content: Text('Interview Lulus. Anda dapat menerima pelamar ini.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
            content: Text('Interview Tidak Lulus.'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
      }
    }
  }

  void _showScheduleDialog() {
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    bool isChecking = false;
    bool hasConflict = false;
    String? conflictMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Function to check conflict when date/time changes
          Future<void> checkConflict() async {
            if (selectedDate == null || selectedTime == null) return;

            setDialogState(() {
              isChecking = true;
              hasConflict = false;
              conflictMessage = null;
            });

            final scheduledAt = DateTime(
              selectedDate!.year,
              selectedDate!.month,
              selectedDate!.day,
              selectedTime!.hour,
              selectedTime!.minute,
            );

            final provider = context.read<AppProvider>();
            final conflict = await provider.hasInterviewConflict(scheduledAt);

            setDialogState(() {
              isChecking = false;
              hasConflict = conflict;
              if (conflict) {
                conflictMessage =
                    'Sudah ada interview lain dalam rentang 1 jam dari waktu ini. '
                    'Pilih waktu minimal 1 jam sebelum atau sesudah jadwal yang ada.';
              }
            });
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Text('Jadwalkan Interview'),
              ],
            ),
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
                          dateController.text =
                              DateFormat('EEEE, dd MMMM yyyy', 'id').format(date);
                        });
                        await checkConflict();
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
                          timeController.text = '${time.format(context)} WIB';
                        });
                        await checkConflict();
                      }
                    },
                  ),

                  // Conflict warning
                  if (isChecking) ...[
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Mengecek jadwal...', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                  if (hasConflict && !isChecking) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber,
                              color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              conflictMessage!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!hasConflict &&
                      !isChecking &&
                      selectedDate != null &&
                      selectedTime != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Jadwal tersedia',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

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
                      hintText: 'Link Zoom/Meet atau info tambahan',
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
                onPressed: hasConflict || isChecking
                    ? null
                    : () async {
                        if (selectedDate == null ||
                            selectedTime == null ||
                            locationController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Lengkapi tanggal, waktu, dan lokasi'),
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
                        final success =
                            await provider.scheduleInterview(interview);

                        if (context.mounted) {
                          Navigator.pop(context);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Interview berhasil dijadwalkan'),
                                backgroundColor: AppTheme.acceptedColor,
                              ),
                            );
                            _loadData();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text(provider.error ?? 'Gagal menjadwalkan'),
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelamar'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job info header - shows which position they applied for
                  if (_job != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.work_rounded,
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
                                  'Melamar untuk posisi',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _job!.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  _job!.location,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

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
                                  'Info Interview',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
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
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                              ],
                            ),
                            const Divider(height: 24),
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
                            
                            const SizedBox(height: 16),
                            const Text('Status Interview:', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            
                            // Status Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<InterviewStatus>(
                                  value: _interview!.status,
                                  isExpanded: true,
                                  items: InterviewStatus.values.map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(status.displayName),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) _updateInterviewStatus(val);
                                  },
                                ),
                              ),
                            ),
                            
                            // Result Section (only if completed)
                            if (_interview!.status == InterviewStatus.completed) ...[
                              const SizedBox(height: 16),
                              const Text('Hasil Interview:', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              
                              if (_interview!.result == null)
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _updateInterviewResult(InterviewResult.failed),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.errorColor,
                                          side: const BorderSide(color: AppTheme.errorColor),
                                        ),
                                        child: const Text('Tidak Lulus'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _updateInterviewResult(InterviewResult.passed),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.successColor,
                                        ),
                                        child: const Text('Lulus'),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _interview!.result == InterviewResult.passed
                                        ? AppTheme.successColor.withValues(alpha: 0.1)
                                        : AppTheme.errorColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _interview!.result == InterviewResult.passed
                                          ? AppTheme.successColor
                                          : AppTheme.errorColor,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _interview!.result == InterviewResult.passed
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: _interview!.result == InterviewResult.passed
                                            ? AppTheme.successColor
                                            : AppTheme.errorColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _interview!.result!.displayName,
                                        style: TextStyle(
                                          color: _interview!.result == InterviewResult.passed
                                              ? AppTheme.successColor
                                              : AppTheme.errorColor,
                                          fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 16),
                  ],

                  // Details sections
                  _buildSection('Pendidikan', Icons.school, widget.application.education),
                  _buildSection('Pengalaman', Icons.work, widget.application.experience),
                  _buildSection('Keahlian', Icons.psychology, widget.application.skills),
                  _buildSection('Motivasi', Icons.edit_document, widget.application.coverLetter),
                  
                  const SizedBox(height: 24),
                  
                  // Prominent CTA Buttons
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.touch_app, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Aksi',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Schedule Interview button (if no interview yet)
                        if (_interview == null && 
                            (widget.application.status == ApplicationStatus.pending ||
                             widget.application.status == ApplicationStatus.review))
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ElevatedButton.icon(
                              onPressed: _showScheduleDialog,
                              icon: const Icon(Icons.event_available),
                              label: const Text('Jadwalkan Interview'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        
                        // Accept / Reject buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _updateStatus(ApplicationStatus.rejected),
                                icon: const Icon(Icons.cancel_outlined, color: AppTheme.rejectedColor),
                                label: const Text('Tolak'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.rejectedColor,
                                  side: const BorderSide(color: AppTheme.rejectedColor),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateStatus(ApplicationStatus.accepted),
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Terima'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.acceptedColor,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Review button
                        if (widget.application.status == ApplicationStatus.pending)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _updateStatus(ApplicationStatus.review),
                              icon: const Icon(Icons.visibility_outlined),
                              label: const Text('Tandai Sedang Ditinjau'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
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
