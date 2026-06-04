import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:streaming_app/shared/theme/colors.dart';

class CustomDatePicker extends FormField<DateTime> {
  final String hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateSelected;

  CustomDatePicker({
    super.key,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    super.initialValue,
    super.validator,
    super.onSaved,
  }) : super(
          builder: (FormFieldState<DateTime> state) {
            final context = state.context;
            final hasDate = state.value != null;
            final hasError = state.hasError;

            Future<void> pickDate() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: state.value ?? DateTime(now.year - 18, now.month, now.day),
                firstDate: firstDate ?? DateTime(1900),
                lastDate: lastDate ?? now,
                builder: (context, child) {
                  return Theme(
                    data: AppColors.darkTheme.copyWith(
                      datePickerTheme: DatePickerThemeData(
                        backgroundColor: AppColors.blackElevated,
                        surfaceTintColor: Colors.transparent,
                        headerBackgroundColor: AppColors.grey900,
                        headerForegroundColor: AppColors.white,
                        dayForegroundColor: const WidgetStatePropertyAll(AppColors.white),
                        yearForegroundColor: const WidgetStatePropertyAll(AppColors.white),
                        todayForegroundColor: const WidgetStatePropertyAll(AppColors.white),
                        todayBorder: const BorderSide(color: AppColors.grey500),
                        dayOverlayColor: const WidgetStatePropertyAll(AppColors.grey700),
                        confirmButtonStyle: TextButton.styleFrom(
                          foregroundColor: AppColors.white,
                        ),
                        cancelButtonStyle: TextButton.styleFrom(
                          foregroundColor: AppColors.grey400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (picked != null) {
                state.didChange(picked);
                if (onDateSelected != null) {
                  onDateSelected(picked);
                }
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (labelText != null) ...[
                  Text(
                    labelText,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                GestureDetector(
                  onTap: pickDate,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasError
                            ? AppColors.grey500 // Match custom text field error outline
                            : (hasDate ? AppColors.grey500 : AppColors.borderSubtle),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (prefixIcon != null) ...[
                          IconTheme(
                            data: IconThemeData(
                              color: hasDate ? AppColors.white : AppColors.grey500,
                              size: 20,
                            ),
                            child: prefixIcon,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            hasDate
                                ? DateFormat('yyyy.MM.dd').format(state.value!)
                                : hintText,
                            style: TextStyle(
                              color: hasDate
                                  ? AppColors.textPrimary
                                  : AppColors.textPlaceholder,
                              fontSize: 15,
                              fontWeight: hasDate ? FontWeight.w400 : FontWeight.w300,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: hasDate ? AppColors.grey300 : AppColors.grey500,
                        ),
                      ],
                    ),
                  ),
                ),
                if (hasError) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(
                        color: AppColors.grey400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        );
}
