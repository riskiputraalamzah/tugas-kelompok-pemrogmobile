import 'package:flutter/material.dart';
import '../config/theme.dart';

class ScoreIndicator extends StatelessWidget {
  final double score;
  final String? label;
  final bool showLabel;
  final double size;

  const ScoreIndicator({
    super.key,
    required this.score,
    this.label,
    this.showLabel = true,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedScore = score.clamp(0.0, 100.0);
    final color = _getScoreColor(normalizedScore);
    final displayLabel = label ?? _getDefaultLabel(normalizedScore);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 6,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.15)),
                ),
              ),
              // Progress circle
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: normalizedScore / 100,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              // Score text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${normalizedScore.toInt()}',
                    style: TextStyle(
                      fontSize: size * 0.32,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  // Icon based on score
                  Icon(
                    _getScoreIcon(normalizedScore),
                    size: size * 0.2,
                    color: color,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  displayLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return AppTheme.successColor;
    if (score >= 50) return AppTheme.primaryColor;
    if (score >= 30) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  IconData _getScoreIcon(double score) {
    if (score >= 70) return Icons.trending_up_rounded;
    if (score >= 50) return Icons.trending_flat_rounded;
    return Icons.trending_down_rounded;
  }

  String _getDefaultLabel(double score) {
    if (score >= 70) return 'Sangat Bagus';
    if (score >= 50) return 'Bagus';
    if (score >= 30) return 'Cukup';
    return 'Kurang';
  }
}
