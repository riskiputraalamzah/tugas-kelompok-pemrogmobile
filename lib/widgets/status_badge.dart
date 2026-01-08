import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/application.dart';

class StatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  final bool large;

  const StatusBadge({
    super.key,
    required this.status,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 12,
        vertical: large ? 10 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config.color.withValues(alpha: 0.15),
            config.color.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(large ? 12 : 20),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: large ? 18 : 14,
            color: config.color,
          ),
          SizedBox(width: large ? 8 : 6),
          Text(
            config.label,
            style: TextStyle(
              fontSize: large ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    switch (status) {
      case ApplicationStatus.pending:
        return _StatusConfig(
          color: AppTheme.pendingColor,
          label: 'Menunggu',
          icon: Icons.schedule_rounded,
        );
      case ApplicationStatus.review:
        return _StatusConfig(
          color: AppTheme.reviewColor,
          label: 'Direview',
          icon: Icons.visibility_rounded,
        );
      case ApplicationStatus.accepted:
        return _StatusConfig(
          color: AppTheme.acceptedColor,
          label: 'Diterima',
          icon: Icons.check_circle_rounded,
        );
      case ApplicationStatus.rejected:
        return _StatusConfig(
          color: AppTheme.rejectedColor,
          label: 'Ditolak',
          icon: Icons.cancel_rounded,
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final String label;
  final IconData icon;

  _StatusConfig({
    required this.color,
    required this.label,
    required this.icon,
  });
}
