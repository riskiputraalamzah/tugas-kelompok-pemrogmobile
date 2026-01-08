import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../models/job.dart';
import '../../models/application.dart';
import '../../providers/app_provider.dart';

class VoiceConfirmationScreen extends StatefulWidget {
  final Job job;
  final Map<String, String> answers;

  const VoiceConfirmationScreen({
    super.key,
    required this.job,
    required this.answers,
  });

  @override
  State<VoiceConfirmationScreen> createState() =>
      _VoiceConfirmationScreenState();
}

class _VoiceConfirmationScreenState extends State<VoiceConfirmationScreen> {
  late Map<String, TextEditingController> _controllers;
  bool _isSubmitting = false;
  String? _editingField;

  // Field definitions for display
  final List<_FieldInfo> _fields = const [
    _FieldInfo(
      key: 'fullName',
      label: 'Nama Lengkap',
      icon: Icons.person,
      isRequired: true,
    ),
    _FieldInfo(
      key: 'email',
      label: 'Email',
      icon: Icons.email,
      isRequired: true,
    ),
    _FieldInfo(
      key: 'phone',
      label: 'Nomor Telepon',
      icon: Icons.phone,
      isRequired: true,
    ),
    _FieldInfo(
      key: 'education',
      label: 'Riwayat Pendidikan',
      icon: Icons.school,
      isRequired: true,
    ),
    _FieldInfo(
      key: 'experience',
      label: 'Pengalaman Kerja',
      icon: Icons.work,
      isRequired: false,
    ),
    _FieldInfo(
      key: 'skills',
      label: 'Keahlian',
      icon: Icons.psychology,
      isRequired: true,
    ),
    _FieldInfo(
      key: 'coverLetter',
      label: 'Motivasi / Cover Letter',
      icon: Icons.edit_document,
      isRequired: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _controllers = {};
    for (var field in _fields) {
      _controllers[field.key] = TextEditingController(
        text: widget.answers[field.key] ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isFormValid {
    for (var field in _fields) {
      if (field.isRequired) {
        final value = _controllers[field.key]?.text.trim() ?? '';
        if (value.isEmpty) return false;
      }
    }
    return true;
  }

  List<String> get _emptyRequiredFields {
    return _fields
        .where((f) =>
            f.isRequired &&
            (_controllers[f.key]?.text.trim().isEmpty ?? true))
        .map((f) => f.label)
        .toList();
  }

  void _toggleEdit(String key) {
    setState(() {
      if (_editingField == key) {
        _editingField = null;
      } else {
        _editingField = key;
      }
    });
  }

  Future<void> _submitApplication() async {
    // Validate required fields
    final emptyFields = _emptyRequiredFields;
    if (emptyFields.isNotEmpty) {
      _showValidationError(emptyFields);
      return;
    }

    setState(() => _isSubmitting = true);

    final application = Application(
      id: const Uuid().v4(),
      jobId: widget.job.id,
      fullName: _controllers['fullName']!.text.trim(),
      email: _controllers['email']!.text.trim(),
      phone: _controllers['phone']!.text.trim(),
      education: _controllers['education']!.text.trim(),
      experience: _controllers['experience']!.text.trim(),
      skills: _controllers['skills']!.text.trim(),
      coverLetter: _controllers['coverLetter']!.text.trim(),
      createdAt: DateTime.now(),
    );

    final provider = context.read<AppProvider>();
    final success = await provider.submitApplication(application);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Gagal mengirim lamaran'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        provider.clearError();
      }
    }
  }

  void _showValidationError(List<String> emptyFields) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('Data Belum Lengkap'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mohon lengkapi field berikut:'),
            const SizedBox(height: 12),
            ...emptyFields.map(
              (field) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(field),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.acceptedColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.acceptedColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Lamaran Terkirim!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Lamaran Anda telah berhasil dikirim via Voice Input. '
              'Anda dapat melacak status lamaran menggunakan email yang didaftarkan.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.subtitleColor,
                  ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Pop all screens back to job detail or home
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Kembali ke Beranda'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Konfirmasi Data'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Job info header
          _buildJobHeader(),

          // Fields list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _fields.length,
              itemBuilder: (context, index) {
                final field = _fields[index];
                return _buildFieldCard(field);
              },
            ),
          ),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildJobHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Melamar via Voice Input',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.job.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(_FieldInfo field) {
    final controller = _controllers[field.key]!;
    final isEditing = _editingField == field.key;
    final isEmpty = controller.text.trim().isEmpty;
    final hasError = field.isRequired && isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError
              ? Colors.red.withOpacity(0.5)
              : isEditing
                  ? AppTheme.primaryColor
                  : Colors.grey.shade200,
          width: isEditing ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => _toggleEdit(field.key),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasError
                          ? Colors.red.withOpacity(0.1)
                          : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      field.icon,
                      color: hasError ? Colors.red : AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              field.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (field.isRequired)
                              const Text(
                                ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                        if (!isEditing) ...[
                          const SizedBox(height: 4),
                          Text(
                            isEmpty ? '(Belum diisi)' : controller.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isEmpty
                                  ? Colors.red.shade300
                                  : Colors.grey.shade600,
                              fontSize: 13,
                              fontStyle:
                                  isEmpty ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    isEditing ? Icons.check_circle : Icons.edit,
                    color: isEditing
                        ? AppTheme.acceptedColor
                        : Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Edit field
          if (isEditing)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: controller,
                maxLines: field.key == 'coverLetter' ? 5 : 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  hintText: 'Masukkan ${field.label.toLowerCase()}...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isFormValid)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ketuk field untuk mengedit jika ada yang perlu diperbaiki',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text(
                            'Kirim Lamaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class for field information
class _FieldInfo {
  final String key;
  final String label;
  final IconData icon;
  final bool isRequired;

  const _FieldInfo({
    required this.key,
    required this.label,
    required this.icon,
    this.isRequired = true,
  });
}
