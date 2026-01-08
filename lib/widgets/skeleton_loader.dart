import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Skeleton loading widget with shimmer animation
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
    this.isCircle = false,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircle
                ? null
                : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                AppTheme.dividerColor,
                AppTheme.shimmerColor.withOpacity(0.5),
                AppTheme.dividerColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton card for job listing
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppTheme.dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon skeleton
              const SkeletonLoader(
                width: 56,
                height: 56,
                borderRadius: 14,
              ),
              const SizedBox(width: 16),
              // Title and location skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(height: 20, width: 180),
                    const SizedBox(height: 8),
                    SkeletonLoader(height: 14, width: 120),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Divider skeleton
          const SkeletonLoader(height: 2),
          const SizedBox(height: 16),
          // Tags skeleton
          Row(
            children: [
              const SkeletonLoader(width: 100, height: 36, borderRadius: 12),
              const SizedBox(width: 10),
              const SkeletonLoader(width: 150, height: 36, borderRadius: 12),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton for application status card
class StatusCardSkeleton extends StatelessWidget {
  const StatusCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonLoader(width: 48, height: 48, borderRadius: 12),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(height: 18, width: 160),
                    const SizedBox(height: 6),
                    SkeletonLoader(height: 14, width: 100),
                  ],
                ),
              ),
              const SkeletonLoader(width: 80, height: 32, borderRadius: 20),
            ],
          ),
          const SizedBox(height: 20),
          // Progress skeleton
          const SkeletonLoader(height: 8, borderRadius: 4),
          const SizedBox(height: 20),
          // Interview card skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.dividerColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(height: 16, width: 120),
                const SizedBox(height: 12),
                const SkeletonLoader(height: 14),
                const SizedBox(height: 8),
                const SkeletonLoader(height: 14, width: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic skeleton list
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const SkeletonList({
    super.key,
    this.itemCount = 3,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
