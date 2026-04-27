import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class PatientVitalInput extends StatelessWidget {
  final String label;
  final String? unit;
  final String? hint;
  final TextEditingController controller;
  final IconData? icon;
  final double? min;
  final double? max;
  final bool isDecimal;
  final String? Function(String?)? validator;

  const PatientVitalInput({
    super.key,
    required this.label,
    this.unit,
    this.hint,
    required this.controller,
    this.icon,
    this.min,
    this.max,
    this.isDecimal = false,
    this.validator,
  });

  Color _getStatusColor(String? value) {
    if (value == null || value.isEmpty) return Colors.grey;
    final numValue = double.tryParse(value);
    if (numValue == null) return Colors.grey;

    // Simple status indication based on normal ranges
    if (label.toLowerCase().contains('sugar')) {
      if (numValue < 70 || numValue > 180) return AppColors.triageRed;
      if (numValue < 100 && numValue >= 70) return AppColors.triageGreen;
      return AppColors.triageYellow;
    }
    if (label.toLowerCase().contains('spo2')) {
      if (numValue >= 95) return AppColors.triageGreen;
      if ( ) return AppColors.triageYellow;
      return AppColors.triageRed;
    }
    if (label.toLowerCase().contains('pulse')) {
      if (numValue >= 60 && numValue <= 100) return AppColors.triageGreen;
      if (numValue >= 50 && numValue <= 120) return AppColors.triageYellow;
      return AppColors.triageRed;
    }
    if (label.toLowerCase().contains('gcs')) {
      if (numValue >= 13) return AppColors.triageGreen;
      if (numValue >= 9) return AppColors.triageYellow;
      return AppColors.triageRed;
    }

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (unit != null) ...[
              const SizedBox(width: 4),
              Text(
                '($unit)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
          inputFormatters: [
            if (isDecimal)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            else
              FilteringTextInputFormatter.digitsOnly,
          ],
          validator: validator ??
              (value) {
                if (value == null || value.isEmpty) return null;
                final numValue = double.tryParse(value);
                if (numValue == null) return 'Invalid number';
                if (min != null && numValue < min!) {
                  return 'Minimum value is $min';
                }
                if (max != null && numValue > max!) {
                  return 'Maximum value is $max';
                }
                return null;
              },
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $label',
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                final statusColor = _getStatusColor(value.text);
                if (value.text.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    statusColor == AppColors.triageGreen
                        ? Icons.check_circle
                        : statusColor == AppColors.triageYellow
                            ? Icons.warning
                            : Icons.error,
                    color: statusColor,
                    size: 20,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class BloodPressureInput extends StatelessWidget {
  final TextEditingController systolicController;
  final TextEditingController diastolicController;

  const BloodPressureInput({
    super.key,
    required this.systolicController,
    required this.diastolicController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.favorite,
              size: 18,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 8),
            Text(
              'Blood Pressure',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(width: 4),
            Text(
              '(mmHg)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: systolicController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: 'Systolic',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '/',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: diastolicController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: 'Diastolic',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
