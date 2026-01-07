import 'package:flutter/material.dart';
import '../config/theme.dart';

class ScoreIndicator extends StatelessWidget {
  final double score;
  final String? label;
  final double size;

  const ScoreIndicator({
    super.key,
    required this.score,
    this.label,
    this.size = 60,
  });

  Color get _scoreColor {
    if (score >= 70) return AppTheme.acceptedColor;
    if (score >= 50) return AppTheme.primaryColor;
    if (score >= 30) return AppTheme.warningColor;
    return AppTheme.rejectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
                ),
              ),
              Text(
                score.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.bold,
                  color: _scoreColor,
                ),
              ),
            ],
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _scoreColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _scoreColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
