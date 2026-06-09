import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

class PublishingProgressView extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const PublishingProgressView({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.white,
                  backgroundColor: AppColors.borderSubtle,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Өгөгдлийн санд шинэ бичилт хийж байна',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Display transactions steps progress
            ...List.generate(steps.length, (index) {
              final isDone = index < currentStep;
              final isCurrent = index == currentStep;
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : isCurrent
                              ? Icons.sync_rounded
                              : Icons.radio_button_unchecked_rounded,
                      color: isDone || isCurrent ? AppColors.white : AppColors.grey700,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        steps[index],
                        style: TextStyle(
                          color: isDone || isCurrent ? AppColors.textPrimary : AppColors.textTertiary,
                          fontSize: 13,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
