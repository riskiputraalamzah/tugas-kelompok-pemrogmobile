import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/job.dart';
import '../../models/application.dart';
import '../../providers/app_provider.dart';
import '../../widgets/step_indicator.dart';
import '../../widgets/custom_text_field.dart';
import '../../config/theme.dart';

class ApplicationFormScreen extends StatefulWidget {
  final Job job;
  final String? initialCoverLetter;
  final Map<String, String>? initialData;

  const ApplicationFormScreen({
    super.key, 
    required this.job,
    this.initialCoverLetter,
    this.initialData,
  });

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _skillsController = TextEditingController();
  final _coverLetterController = TextEditingController();

  final List<String> _stepLabels = [
    'Data Diri',
    'Pendidikan',
    'Pengalaman',
    'Keahlian',
    'Motivasi',
    'Konfirmasi',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCoverLetter != null) {
      _coverLetterController.text = widget.initialCoverLetter!;
    }
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['fullName'] ?? '';
      _emailController.text = widget.initialData!['email'] ?? '';
      _phoneController.text = widget.initialData!['phone'] ?? '';
      _educationController.text = widget.initialData!['education'] ?? '';
      _experienceController.text = widget.initialData!['experience'] ?? '';
      _skillsController.text = widget.initialData!['skills'] ?? '';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _submitApplication() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final application = Application(
      id: const Uuid().v4(),
      jobId: widget.job.id,
      email: _emailController.text.trim(),
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      education: _educationController.text.trim(),
      experience: _experienceController.text.trim(),
      skills: _skillsController.text.trim(),
      coverLetter: _coverLetterController.text.trim(),
      createdAt: DateTime.now(),
    );

    final provider = context.read<AppProvider>();
    final success = await provider.submitApplication(application);

    setState(() {
      _isSubmitting = false;
    });

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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.acceptedColor.withValues(alpha: 0.1),
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
              'Lamaran Anda telah berhasil dikirim. Anda dapat melacak status lamaran menggunakan email yang didaftarkan.',
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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
      appBar: AppBar(
        title: const Text('Form Lamaran'),
      ),
      body: Column(
        children: [
          // Step Indicator
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: StepIndicator(
              currentStep: _currentStep,
              totalSteps: 6,
              stepLabels: _stepLabels,
            ),
          ),
          
          // Form Pages
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPersonalInfoStep(),
                  _buildEducationStep(),
                  _buildExperienceStep(),
                  _buildSkillsStep(),
                  _buildCoverLetterStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
          ),
          
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('Kembali'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: _currentStep == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              if (_currentStep < 5) {
                                _nextStep();
                              } else {
                                _submitApplication();
                              }
                            },
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_currentStep < 5 ? 'Lanjutkan' : 'Kirim Lamaran'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContainer({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return _buildStepContainer(
      title: 'Data Diri',
      subtitle: 'Masukkan informasi pribadi Anda',
      icon: Icons.person_outline,
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            label: 'Nama Lengkap',
            hint: 'Masukkan nama lengkap Anda',
            prefixIcon: Icons.person,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'contoh@email.com',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email harus diisi';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            label: 'Nomor Telepon',
            hint: '08xxxxxxxxxx',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor telepon harus diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEducationStep() {
    return _buildStepContainer(
      title: 'Riwayat Pendidikan',
      subtitle: 'Ceritakan latar belakang pendidikan Anda',
      icon: Icons.school_outlined,
      child: CustomTextField(
        controller: _educationController,
        label: 'Pendidikan Terakhir',
        hint: 'Contoh: S1 Teknik Informatika - Universitas Indonesia (2020-2024)',
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Riwayat pendidikan harus diisi';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildExperienceStep() {
    return _buildStepContainer(
      title: 'Pengalaman Kerja',
      subtitle: 'Jelaskan pengalaman kerja yang relevan',
      icon: Icons.work_outline,
      child: CustomTextField(
        controller: _experienceController,
        label: 'Pengalaman Kerja',
        hint: 'Contoh: Software Developer di PT ABC (2022-2024)\n- Mengembangkan aplikasi mobile\n- Kolaborasi tim agile',
        maxLines: 8,
        textCapitalization: TextCapitalization.sentences,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Pengalaman kerja harus diisi (atau tulis "Fresh Graduate" jika belum ada)';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSkillsStep() {
    return _buildStepContainer(
      title: 'Keahlian',
      subtitle: 'Tuliskan keahlian yang Anda miliki',
      icon: Icons.psychology_outlined,
      child: CustomTextField(
        controller: _skillsController,
        label: 'Keahlian Teknis & Soft Skill',
        hint: 'Contoh: Flutter, Dart, Python, SQL, Problem Solving, Team Work, Communication',
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Keahlian harus diisi';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCoverLetterStep() {
    return _buildStepContainer(
      title: 'Surat Motivasi',
      subtitle: 'Ceritakan mengapa Anda tertarik dengan posisi ini',
      icon: Icons.edit_document,
      child: CustomTextField(
        controller: _coverLetterController,
        label: 'Cover Letter',
        hint: 'Tuliskan motivasi dan alasan Anda melamar posisi ini...',
        maxLines: 10,
        textCapitalization: TextCapitalization.sentences,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Surat motivasi harus diisi';
          }
          if (value.length < 50) {
            return 'Surat motivasi minimal 50 karakter';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.acceptedColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fact_check_outlined, color: AppTheme.acceptedColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konfirmasi Data',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Periksa kembali data Anda sebelum mengirim',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Job Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.work, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Melamar untuk posisi:',
                          style: TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
                      Text(
                        widget.job.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          _buildReviewItem('Nama Lengkap', _nameController.text),
          _buildReviewItem('Email', _emailController.text),
          _buildReviewItem('Telepon', _phoneController.text),
          _buildReviewItem('Pendidikan', _educationController.text),
          _buildReviewItem('Pengalaman', _experienceController.text),
          _buildReviewItem('Keahlian', _skillsController.text),
          _buildReviewItem('Motivasi', _coverLetterController.text),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : '-',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
