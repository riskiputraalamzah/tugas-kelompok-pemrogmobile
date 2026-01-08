import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/job.dart';
import '../../providers/app_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../config/theme.dart';

class JobFormScreen extends StatefulWidget {
  final Job? job;

  const JobFormScreen({super.key, this.job});

  @override
  State<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends State<JobFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _requirementsController;
  late final TextEditingController _locationController;
  late final TextEditingController _salaryController;
  String _employmentType = 'Full-time';
  bool _isOpen = true;
  bool _isLoading = false;

  bool get _isEditing => widget.job != null;

  final List<String> _employmentTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
    'Remote',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job?.title ?? '');
    _descriptionController = TextEditingController(text: widget.job?.description ?? '');
    _requirementsController = TextEditingController(text: widget.job?.requirements ?? '');
    _locationController = TextEditingController(text: widget.job?.location ?? '');
    _salaryController = TextEditingController(text: widget.job?.salaryRange ?? '');
    _employmentType = widget.job?.employmentType ?? 'Full-time';
    _isOpen = widget.job?.isOpen ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final job = Job(
      id: widget.job?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      requirements: _requirementsController.text.trim(),
      location: _locationController.text.trim(),
      salaryRange: _salaryController.text.trim(),
      employmentType: _employmentType,
      isOpen: _isOpen,
      createdAt: widget.job?.createdAt ?? DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
    );

    final provider = context.read<AppProvider>();
    final success = _isEditing
        ? await provider.updateJob(job)
        : await provider.createJob(job);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Lowongan berhasil diperbarui'
                : 'Lowongan berhasil dibuat'),
            backgroundColor: AppTheme.acceptedColor,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Gagal menyimpan'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        provider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Lowongan' : 'Tambah Lowongan'),
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Judul Posisi',
                hint: 'Contoh: Software Engineer',
                prefixIcon: Icons.work,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Deskripsi Pekerjaan',
                hint: 'Jelaskan tentang posisi ini...',
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _requirementsController,
                label: 'Persyaratan',
                hint: '• Pengalaman minimal 2 tahun\n• Menguasai Flutter',
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Persyaratan harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _locationController,
                label: 'Lokasi',
                hint: 'Contoh: Jakarta, Indonesia',
                prefixIcon: Icons.location_on,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lokasi harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _salaryController,
                label: 'Range Gaji',
                hint: 'Contoh: Rp 8.000.000 - Rp 15.000.000',
                prefixIcon: Icons.payments,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Range gaji harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Tipe Pekerjaan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _employmentTypes.map((type) {
                  final isSelected = _employmentType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _employmentType = type;
                        });
                      }
                    },
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.subtitleColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Lowongan Aktif'),
                subtitle: const Text('Aktifkan agar lowongan terlihat oleh pelamar'),
                value: _isOpen,
                onChanged: (value) {
                  setState(() {
                    _isOpen = value;
                  });
                },
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveJob,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                      : Text(_isEditing ? 'Simpan Perubahan' : 'Buat Lowongan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
