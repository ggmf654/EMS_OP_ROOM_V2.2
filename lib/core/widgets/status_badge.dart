// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class StatusBadge extends StatelessWidget {
  final TriageCode? triageCode;
  final MissionStatus? missionStatus;
  final String? customLabel;
  final Color? customColor;

  const StatusBadge({
    super.key,
    this.triageCode,
    this.missionStatus,
    this.customLabel,
    this.customColor,
  });

  Color get _backgroundColor {
    if (customColor != null) return customColor!;
    if (triageCode != null) {
      switch (triageCode!) {
        case TriageCode.red:
          return AppColors.triageRed;
        case TriageCode.yellow:
          return AppColors.triageYellow;
        case TriageCode.green:
          return AppColors.triageGreen;
      }
    }
    if (missionStatus != null) {
      switch (missionStatus!) {
        case MissionStatus.waiting:
          return AppColors.triageYellow;
        case MissionStatus.dispatched:
        case MissionStatus.arrivedAtScene:
        case MissionStatus.headingToHospital:
          return AppColors.holographicGradient1;
        case MissionStatus.arrivedAtHospital:
        case MissionStatus.missionEnd:
        case MissionStatus.backToBase:
          return AppColors.triageGreen;
        case MissionStatus.cancelled:
          return AppColors.textSecondaryDark;
      }
    }
    return AppColors.textSecondaryDark;
  }

  String get _label {
    if (customLabel != null) return customLabel!;
    if (triageCode != null) {
      switch (triageCode!) {
        case TriageCode.red:
          return 'RED';
        case TriageCode.yellow:
          return 'YELLOW';
        case TriageCode.green:
          return 'GREEN';
      }
    }
    if (missionStatus != null) {
      switch (missionStatus!) {
        case MissionStatus.waiting:
          return 'Waiting';
        case MissionStatus.dispatched:
          return 'Dispatched';
        case MissionStatus.arrivedAtScene:
          return 'At Scene';
        case MissionStatus.headingToHospital:
          return 'En Route';
        case MissionStatus.arrivedAtHospital:
          return 'At Hospital';
        case MissionStatus.missionEnd:
          return 'Completed';
        case MissionStatus.backToBase:
          return 'Back to Base';
        case MissionStatus.cancelled:
          return 'Cancelled';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _backgroundColor, width: 1.5),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _backgroundColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
