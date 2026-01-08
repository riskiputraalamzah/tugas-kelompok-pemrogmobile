import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../config/theme.dart';
import 'job_management_screen.dart';
import 'applicant_list_screen.dart';
import 'interview_schedule_screen.dart';
import 'broadcast_management_screen.dart';
import '../guest/home_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadAllData();
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppProvider>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AppProvider>().loadAllData();
        },
        color: AppTheme.primaryColor,
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              slivers: [
                // Gradient Header
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.darkGradient,
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row with back and logout
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.admin_panel_settings_rounded,
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
                                        'Admin Panel',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'Kelola rekrutmen',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: _logout,
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.logout_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 28),
                            
                            // Welcome text
                            Text(
                              'Halo, ${provider.currentAdmin?.fullName ?? 'Admin'}! 👋',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pantau dan kelola rekrutmen dari sini',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Curved transition
                SliverToBoxAdapter(
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    transform: Matrix4.translationValues(0, -24, 0),
                  ),
                ),

                // Statistics Section
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Statistik',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stat cards grid - responsive
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive: 4 cols on desktop, 2 on mobile
                      final crossAxisCount = constraints.crossAxisExtent > 900 ? 4 : 2;
                      final childAspectRatio = constraints.crossAxisExtent > 900 ? 1.8 : 1.5;
                      
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: childAspectRatio,
                        ),
                        delegate: SliverChildListDelegate([
                          _buildStatCard(
                            context,
                            'Total Lowongan',
                            '${provider.totalJobs}',
                            Icons.work_rounded,
                            AppTheme.primaryColor,
                          ),
                          _buildStatCard(
                            context,
                            'Lowongan Aktif',
                            '${provider.openJobsCount}',
                            Icons.visibility_rounded,
                            AppTheme.successColor,
                          ),
                          _buildStatCard(
                            context,
                            'Total Lamaran',
                            '${provider.totalApplications}',
                            Icons.people_rounded,
                            AppTheme.secondaryColor,
                          ),
                          _buildStatCard(
                            context,
                            'Perlu Ditinjau',
                            '${provider.pendingApplications}',
                            Icons.pending_actions_rounded,
                            AppTheme.warningColor,
                          ),
                        ]),
                      );
                    },
                  ),
                ),

                // Menu Section
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Menu',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Menu items
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildMenuCard(
                        context,
                        'Kelola Lowongan',
                        'Tambah, edit, atau tutup lowongan',
                        Icons.work_outline_rounded,
                        AppTheme.primaryColor,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const JobManagementScreen()),
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        'Daftar Pelamar',
                        'Lihat dan kelola lamaran masuk',
                        Icons.people_outline_rounded,
                        AppTheme.secondaryColor,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ApplicantListScreen()),
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        'Jadwal Interview',
                        'Kelola jadwal wawancara',
                        Icons.calendar_today_outlined,
                        AppTheme.warningColor,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InterviewScheduleScreen()),
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        'Kelola Info',
                        'Tambah atau edit pengumuman',
                        Icons.campaign_outlined,
                        AppTheme.accentColor,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BroadcastManagementScreen()),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.2),
                        color.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
