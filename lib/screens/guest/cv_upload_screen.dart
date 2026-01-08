import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import '../../config/theme.dart';
import '../../models/job.dart';
import 'application_form_screen.dart';

class CVUploadScreen extends StatefulWidget {
  final Job job;

  const CVUploadScreen({super.key, required this.job});

  @override
  State<CVUploadScreen> createState() => _CVUploadScreenState();
}

class _CVUploadScreenState extends State<CVUploadScreen> {
  bool _isAnalyzing = false;
  bool _isDragging = false;
  String? _fileName;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      _processFile(result.files.single.name);
    }
  }

  Future<void> _processFile(String fileName) async {
    setState(() {
      _fileName = fileName;
      _isAnalyzing = true;
    });

    // Simulate AI Analysis
    await Future.delayed(const Duration(seconds: 3));

    // Mock parsed data with "AI" logic
    String cleanName = fileName.split('.').first.replaceAll(RegExp(r'[-_]'), ' ');
    // Capitalize first letters
    cleanName = cleanName.split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : '').join(' ');

    final mockData = {
      'fullName': cleanName,
      'email': '${cleanName.replaceAll(' ', '').toLowerCase()}@email.com',
      'phone': '0812${(10000000 + DateTime.now().millisecond).toString()}',
      'education': 'S1 Teknik Informatika',
      'experience': '2 Tahun pengalaman relevan',
      'skills': 'Communication, Problem Solving, Teamwork',
    };

    if (mounted) {
      setState(() => _isAnalyzing = false);
      
      if (cleanName.toLowerCase().contains('profile') || cleanName.toLowerCase().contains('linkedin')) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Tips: Ganti nama file menjadi "Nama_Anda.pdf" agar terdeteksi.'),
             backgroundColor: Colors.orange,
           ),
         );
         mockData['fullName'] = '';
      }
      _showSuccessDialog(mockData);
    }
  }

  void _showSuccessDialog(Map<String, String> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
            SizedBox(width: 10),
            Text('Analisis AI Selesai'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI telah berhasil membaca CV Anda. Silakan verifikasi data yang telah diekstrak.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama: ${data['fullName']!.isNotEmpty ? data['fullName'] : "(Tidak terdeteksi)"}'),
                  Text('Email: ${data['email']!.isNotEmpty ? data['email'] : "(Tidak terdeteksi)"}'),
                  Text('Skills: ${data['skills']}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ApplicationFormScreen(
                    job: widget.job,
                    initialData: data,
                  ),
                ),
              );
            },
            child: const Text('Lanjut ke Form'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload CV')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Ensure it centers in the middle
            children: [
              if (_isAnalyzing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                'AI sedang membaca CV Anda...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ] else ...[
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_upload_outlined,
                          size: 64,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Tap untuk upload CV (PDF/DOC)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI akan otomatis mengisi formulir untuk Anda',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildLinkedInTutorial(),
            ],
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildLinkedInTutorial() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tips_and_updates, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Tips Akurasi AI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('1. Gunakan CV hasil export LinkedIn agar mudah dibaca.'),
          const SizedBox(height: 4),
          const Text('2. Ganti nama file menjadi "Nama_Lengkap.pdf" (Contoh: Riski_Alamzah.pdf).'),
          const Divider(height: 24),
          const Text(
            'Cara export dari LinkedIn:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Buka Profil Anda > Klik "More" (...) > Pilih "Save to PDF"',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
