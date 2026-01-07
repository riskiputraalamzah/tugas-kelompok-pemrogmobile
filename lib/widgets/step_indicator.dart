import 'package:flutter/material.dart';
import '../config/theme.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps * 2 - 1, (index) {
            if (index.isEven) {
              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex < currentStep;
              final isCurrent = stepIndex == currentStep;
              
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted || isCurrent
                      ? AppTheme.primaryColor
                      : Colors.grey.shade300,
                  border: isCurrent
                      ? Border.all(color: AppTheme.primaryColor, width: 2)
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                ),
              );
            } else {
              final prevStep = index ~/ 2;
              final isCompleted = prevStep < currentStep;
              
              return Expanded(
                child: Container(
                  height: 3,
                  color: isCompleted ? AppTheme.primaryColor : Colors.grey.shade300,
                ),
              );
            }
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stepLabels.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isCurrent = index == currentStep;
            
            return SizedBox(
              width: 60,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: isCurrent ? AppTheme.primaryColor : AppTheme.subtitleColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
