import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/job_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../config/theme.dart';
import 'job_detail_screen.dart';
import 'check_status_screen.dart';
import 'broadcast_screen.dart';
import '../admin/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadOpenJobs();
      context.read<AppProvider>().loadBroadcasts();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabSelected(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: [
          _JobListView(
            onNavigateToStatus: () => _onTabSelected(1),
          ),
          const CheckStatusScreen(),
          const BroadcastScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          elevation: 0,
          backgroundColor: Colors.transparent,
          indicatorColor: AppTheme.primaryColor.withOpacity(0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 300),
          onDestinationSelected: _onTabSelected,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.work_outline_rounded, color: AppTheme.subtitleColor),
              selectedIcon: Icon(Icons.work_rounded, color: AppTheme.primaryColor),
              label: 'Lowongan',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_rounded, color: AppTheme.subtitleColor),
              selectedIcon: Icon(Icons.search_rounded, color: AppTheme.primaryColor),
              label: 'Cek Status',
            ),
            NavigationDestination(
              icon: Icon(Icons.campaign_outlined, color: AppTheme.subtitleColor),
              selectedIcon: Icon(Icons.campaign_rounded, color: AppTheme.primaryColor),
              label: 'Info',
            ),
          ],
        ),
      ),
    );
  }
}

class _JobListView extends StatelessWidget {
  final VoidCallback? onNavigateToStatus;
  
  const _JobListView({this.onNavigateToStatus});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AppProvider>().loadOpenJobs();
      },
      color: AppTheme.primaryColor,
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final jobs = provider.openJobs;

          // Show skeleton loading during initial load or refresh
          final isLoading = provider.isLoading;

          return CustomScrollView(
            slivers: [
              // Modern App Bar with Gradient
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.darkGradient,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row
                          Row(
                            children: [
                              // Logo with secret admin access (long-press)
                              GestureDetector(
                                onLongPress: () {
                                  // Show snackbar with admin access option
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.admin_panel_settings, color: Colors.white),
                                          const SizedBox(width: 12),
                                          const Expanded(child: Text('Mode Admin tersedia')),
                                        ],
                                      ),
                                      backgroundColor: AppTheme.primaryColor,
                                      duration: const Duration(seconds: 5),
                                      action: SnackBarAction(
                                        label: 'MASUK',
                                        textColor: Colors.white,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.accentGradient,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentColor.withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.work_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'JobTracker',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Text(
                                      'Temukan Karirmu ✨',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Notification icon - navigate to status
                              Material(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: onNavigateToStatus,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.notifications_outlined,
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
                            'Selamat Datang! 👋',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Jelajahi peluang karir terbaik dan wujudkan impianmu bersama kami.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Stats cards with skeleton loading
                          Row(
                            children: [
                              if (isLoading) ...[
                                // Skeleton for stats
                                Expanded(
                                  child: _buildStatCardSkeleton(),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCardSkeleton(),
                                ),
                              ] else ...[
                                _buildStatCard(
                                  context,
                                  icon: Icons.work_rounded,
                                  value: '${jobs.length}',
                                  label: 'Lowongan',
                                  color: AppTheme.accentColor,
                                ),
                                const SizedBox(width: 12),
                                _buildStatCard(
                                  context,
                                  icon: Icons.campaign_rounded,
                                  value: '${provider.activeBroadcasts.length}',
                                  label: 'Info',
                                  color: AppTheme.secondaryColor,
                                ),
                              ],
                            ],
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

              // Jobs section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
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
                        'Lowongan Terbaru',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${jobs.length} tersedia',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Show skeleton during initial loading
              if (isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const JobCardSkeleton(),
                      childCount: 3, // Show 3 skeleton cards
                    ),
                  ),
                )
              else if (jobs.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.work_off_outlined,
                            size: 56,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Belum ada lowongan',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cek kembali nanti untuk update terbaru',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final job = jobs[index];
                        return JobCard(
                          job: job,
                          showStatus: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobDetailScreen(job: job),
                              ),
                            );
                          },
                        );
                      },
                      childCount: jobs.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 60,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
