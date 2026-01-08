import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/broadcast.dart';
import '../../providers/app_provider.dart';
import '../../config/theme.dart';

class BroadcastManagementScreen extends StatefulWidget {
  const BroadcastManagementScreen({super.key});

  @override
  State<BroadcastManagementScreen> createState() =>
      _BroadcastManagementScreenState();
}

class _BroadcastManagementScreenState extends State<BroadcastManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadAllBroadcasts();
    });
  }

  void _showAddEditDialog({Broadcast? broadcast}) {
    final isEdit = broadcast != null;
    final titleController = TextEditingController(text: broadcast?.title ?? '');
    final contentController =
        TextEditingController(text: broadcast?.content ?? '');
    bool isActive = broadcast?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                isEdit ? Icons.edit : Icons.add_circle,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(isEdit ? 'Edit Info' : 'Tambah Info Baru'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    prefixIcon: Icon(Icons.title),
                    hintText: 'Contoh: Lowongan Baru Tersedia!',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Isi Pengumuman',
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                    hintText: 'Tulis isi pengumuman di sini...',
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Status Aktif'),
                  subtitle: Text(
                    isActive ? 'Tampil di halaman Info' : 'Disembunyikan',
                    style: TextStyle(
                      color: isActive
                          ? AppTheme.acceptedColor
                          : AppTheme.subtitleColor,
                    ),
                  ),
                  value: isActive,
                  activeColor: AppTheme.acceptedColor,
                  onChanged: (value) {
                    setDialogState(() => isActive = value);
                  },
                  contentPadding: EdgeInsets.zero,
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
                if (titleController.text.trim().isEmpty ||
                    contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Judul dan isi tidak boleh kosong'),
                    ),
                  );
                  return;
                }

                final provider = context.read<AppProvider>();
                bool success;

                if (isEdit) {
                  final updated = broadcast!.copyWith(
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    isActive: isActive,
                    updatedAt: DateTime.now(),
                  );
                  success = await provider.updateBroadcast(updated);
                } else {
                  final newBroadcast = Broadcast(
                    id: const Uuid().v4(),
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    isActive: isActive,
                    createdAt: DateTime.now(),
                  );
                  success = await provider.createBroadcast(newBroadcast);
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit
                            ? 'Info berhasil diperbarui'
                            : 'Info berhasil ditambahkan'),
                        backgroundColor: AppTheme.acceptedColor,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            provider.error ?? 'Gagal menyimpan'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                    provider.clearError();
                  }
                }
              },
              child: Text(isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Broadcast broadcast) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red),
            SizedBox(width: 12),
            Text('Hapus Info?'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${broadcast.title}"?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<AppProvider>();
              final success = await provider.deleteBroadcast(broadcast.id);

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Info berhasil dihapus'),
                      backgroundColor: AppTheme.acceptedColor,
                    ),
                  );
                }
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
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
        title: const Text('Kelola Info'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final broadcasts = provider.broadcasts;

          if (broadcasts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.campaign_outlined,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Belum ada info',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan tombol + untuk menambah info baru',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.subtitleColor,
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadAllBroadcasts();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: broadcasts.length,
              itemBuilder: (context, index) {
                final broadcast = broadcasts[index];
                return _buildBroadcastCard(broadcast);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Info', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildBroadcastCard(Broadcast broadcast) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        broadcast.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: AppTheme.subtitleColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm')
                                .format(broadcast.createdAt),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.subtitleColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: broadcast.isActive
                        ? AppTheme.acceptedColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    broadcast.isActive ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: broadcast.isActive
                          ? AppTheme.acceptedColor
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              broadcast.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.subtitleColor,
                  ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showAddEditDialog(broadcast: broadcast),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(broadcast),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text('Hapus',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
