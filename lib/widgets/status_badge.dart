import 'package:flutter/material.dart';
import '../models/application.dart';
import '../config/theme.dart';

class StatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  final bool large;

  const StatusBadge({
    super.key,
    required this.status,
    this.large = false,
  });

  Color get _backgroundColor {
    switch (status) {
      case ApplicationStatus.pending:
        return AppTheme.pendingColor.withValues(alpha: 0.15);
      case ApplicationStatus.review:
        return AppTheme.reviewColor.withValues(alpha: 0.15);
      case ApplicationStatus.accepted:
        return AppTheme.acceptedColor.withValues(alpha: 0.15);
      case ApplicationStatus.rejected:
        return AppTheme.rejectedColor.withValues(alpha: 0.15);
    }
  }

  Color get _textColor {
    switch (status) {
      case ApplicationStatus.pending:
        return AppTheme.pendingColor;
      case ApplicationStatus.review:
        return AppTheme.reviewColor;
      case ApplicationStatus.accepted:
        return AppTheme.acceptedColor;
      case ApplicationStatus.rejected:
        return AppTheme.rejectedColor;
    }
  }

  IconData get _icon {
    switch (status) {
      case ApplicationStatus.pending:
        return Icons.access_time;
      case ApplicationStatus.review:
        return Icons.visibility;
      case ApplicationStatus.accepted:
        return Icons.check_circle;
      case ApplicationStatus.rejected:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 12,
        vertical: large ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: large ? 18 : 14,
            color: _textColor,
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: large ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}
