import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../config/theme.dart';

class BroadcastScreen extends StatelessWidget {
  const BroadcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AppProvider>().loadBroadcasts();
      },
      color: AppTheme.primaryColor,
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final broadcasts = provider.activeBroadcasts;

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
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.campaign_rounded,
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
                                  'Pengumuman',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Info terbaru dari perusahaan',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Broadcast count badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${broadcasts.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
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

              // Empty state or list
              if (broadcasts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.campaign_outlined,
                            size: 56,
                            color: AppTheme.warningColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Belum ada pengumuman',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pantau terus untuk info terbaru',
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
                        final broadcast = broadcasts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.warningColor.withValues(alpha: 0.2),
                                            AppTheme.warningColor.withValues(alpha: 0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.campaign_rounded,
                                        color: AppTheme.warningColor,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            broadcast.title,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.schedule_rounded,
                                                size: 14,
                                                color: AppTheme.subtitleColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                DateFormat('dd MMM yyyy, HH:mm').format(broadcast.createdAt),
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  height: 1,
                                  color: AppTheme.dividerColor,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  broadcast.content,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.subtitleColor,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: broadcasts.length,
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
}
