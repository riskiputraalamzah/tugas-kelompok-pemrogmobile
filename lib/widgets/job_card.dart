import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/job.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final bool showStatus;
  final VoidCallback? onTap;
  final VoidCallback? onOpenToggle;
  final VoidCallback? onDelete;

  const JobCard({
    super.key,
    required this.job,
    this.showStatus = true,
    this.onTap,
    this.onOpenToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppTheme.dividerColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and status
                Row(
                  children: [
                    // Company icon container with gradient
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Title and location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  job.location,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Status badge
                    if (showStatus)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: job.isOpen
                                ? [AppTheme.successColor.withValues(alpha: 0.15), AppTheme.successColor.withValues(alpha: 0.08)]
                                : [AppTheme.subtitleColor.withValues(alpha: 0.15), AppTheme.subtitleColor.withValues(alpha: 0.08)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: job.isOpen
                                ? AppTheme.successColor.withValues(alpha: 0.3)
                                : AppTheme.subtitleColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: job.isOpen
                                    ? AppTheme.successColor
                                    : AppTheme.subtitleColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              job.isOpen ? 'Aktif' : 'Tutup',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: job.isOpen
                                    ? AppTheme.successColor
                                    : AppTheme.subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Divider with gradient
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.2),
                        AppTheme.secondaryColor.withValues(alpha: 0.2),
                        AppTheme.dividerColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tags row
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildTag(
                      context,
                      Icons.work_outline_rounded,
                      job.employmentType,
                      AppTheme.primaryColor,
                    ),
                    _buildTag(
                      context,
                      Icons.payments_outlined,
                      job.salaryRange,
                      AppTheme.accentColor,
                    ),
                  ],
                ),
                
                // Admin actions (only shown if callbacks are provided)
                if (onOpenToggle != null || onDelete != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (onOpenToggle != null)
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: job.isOpen ? Icons.pause_circle_outline : Icons.play_circle_outline,
                            label: job.isOpen ? 'Tutup' : 'Buka',
                            color: job.isOpen ? AppTheme.warningColor : AppTheme.successColor,
                            onTap: onOpenToggle,
                          ),
                        ),
                      if (onOpenToggle != null && onDelete != null)
                        const SizedBox(width: 12),
                      if (onDelete != null)
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: Icons.delete_outline_rounded,
                            label: 'Hapus',
                            color: AppTheme.errorColor,
                            onTap: onDelete,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
