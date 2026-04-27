// ignore_for_file: unused_local_variable, unnecessary_null_comparison, dead_code, override_on_non_overriding_member

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/holographic_container.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../bloc/wireless_bloc.dart';

class WirelessScreen extends StatefulWidget {
  const WirelessScreen({super.key});

  @override
  State<WirelessScreen> createState() => _WirelessScreenState();
}

class _WirelessScreenState extends State<WirelessScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WirelessBloc>().add(LoadActiveMissions());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wireless Operations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WirelessBloc>().add(LoadActiveMissions());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<WirelessBloc, WirelessState>(
        listener: (context, state) {
          if (state is MissionUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Mission updated: ${_getStatusName(state.mission.status)}'),
                backgroundColor: AppColors.triageGreen,
              ),
            );
            context.read<WirelessBloc>().add(LoadActiveMissions());
          } else if (state is WirelessError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.triageRed,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WirelessLoading && state is! WirelessLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WirelessLoaded || state is MissionUpdated) {
            final missions = state is WirelessLoaded
                ? state.activeMissions
                : (state as MissionUpdated).mission != null
                    ? [state.mission]
                    : <Emergency>[];

            // Re-fetch to get the list
            if (state is MissionUpdated) {
              return const Center(child: CircularProgressIndicator());
            }

            final activeMissions = (state as WirelessLoaded).activeMissions;

            if (activeMissions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.radio_button_off,
                      size: 64,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No active missions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activeMissions.length,
              itemBuilder: (context, index) {
                final mission = activeMissions[index];
                return _MissionCard(
                  mission: mission,
                  onUpdateStatus: (status, hospital, notes) {
                    context.read<WirelessBloc>().add(
                          UpdateMissionStatus(
                            missionId: mission.id,
                            newStatus: status,
                            hospitalName: hospital,
                            notes: notes,
                          ),
                        );
                  },
                  onCancel: (reason) {
                    context.read<WirelessBloc>().add(
                          CancelMission(
                            missionId: mission.id,
                            reason: reason,
                          ),
                        );
                  },
                );
              },
            );
          }

          return const Center(child: Text('Pull to refresh'));
        },
      ),
    );
  }

  String _getStatusName(MissionStatus status) {
    switch (status) {
      case MissionStatus.waiting:
        return 'Waiting';
      case MissionStatus.dispatched:
        return 'Dispatched';
      case MissionStatus.arrivedAtScene:
        return 'Arrived at Scene';
      case MissionStatus.headingToHospital:
        return 'Heading to Hospital';
      case MissionStatus.arrivedAtHospital:
        return 'Arrived at Hospital';
      case MissionStatus.missionEnd:
        return 'Mission End';
      case MissionStatus.backToBase:
        return 'Back to Base';
      case MissionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class _MissionCard extends StatelessWidget {
  final Emergency mission;
  final Function(MissionStatus, String?, String?) onUpdateStatus;
  final Function(String) onCancel;

  const _MissionCard({
    required this.mission,
    required this.onUpdateStatus,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('HH:mm');

    return GlassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              StatusBadge(triageCode: mission.triageCode),
              const SizedBox(width: 8),
              StatusBadge(missionStatus: mission.status),
              const Spacer(),
              Text(
                'ID: ${mission.id.substring(0, 8)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Patient Info
          Row(
            children: [
              const Icon(Icons.person, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mission.callerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mission.location.address,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timeline Stepper
          _buildTimeline(context, mission.milestones),
          const SizedBox(height: 16),

          // Actions
          if (mission.status != MissionStatus.backToBase &&
              mission.status != MissionStatus.cancelled)
            _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, List<MissionMilestone> milestones) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allStatuses = [
      MissionStatus.dispatched,
      MissionStatus.arrivedAtScene,
      MissionStatus.headingToHospital,
      MissionStatus.arrivedAtHospital,
      MissionStatus.missionEnd,
      MissionStatus.backToBase,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mission Timeline',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: Row(
            children: allStatuses.asMap().entries.map((entry) {
              final index = entry.key;
              final status = entry.value;
              final milestone =
                  milestones.where((m) => m.status == status).firstOrNull;
              final isCompleted = milestone != null;
              final isCurrent = mission.status == status;
              final isLast = index == allStatuses.length - 1;

              Color statusColor;
              if (isCompleted) {
                statusColor = AppColors.triageGreen;
              } else if (isCurrent) {
                statusColor = AppColors.holographicGradient1;
              } else {
                statusColor = isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder;
              }

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isCompleted || isCurrent
                                  ? statusColor
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: statusColor,
                                width: 2,
                              ),
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : isCurrent
                                    ? const Icon(
                                        Icons.radio_button_checked,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getShortStatusName(status),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                      fontWeight: isCompleted || isCurrent
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isCompleted || isCurrent
                                          ? (isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight)
                                          : (isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondaryLight),
                                    ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (milestone != null)
                            Text(
                              DateFormat('HH:mm').format(milestone.timestamp),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 9,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 32),
                          color: isCompleted
                              ? AppColors.triageGreen
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final nextStatus = _getNextStatus(mission.status);
    if (nextStatus == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showCancelDialog(context),
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.triageRed,
              side: const BorderSide(color: AppColors.triageRed),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              if (nextStatus == MissionStatus.headingToHospital) {
                _showHospitalDialog(context, nextStatus);
              } else {
                onUpdateStatus(nextStatus, null, null);
              }
            },
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: Text(_getStatusActionName(nextStatus)),
          ),
        ),
      ],
    );
  }

  MissionStatus? _getNextStatus(MissionStatus current) {
    switch (current) {
      case MissionStatus.waiting:
        return MissionStatus.dispatched;
      case MissionStatus.dispatched:
        return MissionStatus.arrivedAtScene;
      case MissionStatus.arrivedAtScene:
        return MissionStatus.headingToHospital;
      case MissionStatus.headingToHospital:
        return MissionStatus.arrivedAtHospital;
      case MissionStatus.arrivedAtHospital:
        return MissionStatus.missionEnd;
      case MissionStatus.missionEnd:
        return MissionStatus.backToBase;
      case MissionStatus.backToBase:
      case MissionStatus.cancelled:
        return null;
    }
  }

  String _getShortStatusName(MissionStatus status) {
    switch (status) {
      case MissionStatus.waiting:
        return 'Wait';
      case MissionStatus.dispatched:
        return 'Dispatch';
      case MissionStatus.arrivedAtScene:
        return 'At Scene';
      case MissionStatus.headingToHospital:
        return 'En Route';
      case MissionStatus.arrivedAtHospital:
        return 'Hospital';
      case MissionStatus.missionEnd:
        return 'End';
      case MissionStatus.backToBase:
        return 'Base';
      case MissionStatus.cancelled:
        return 'Cancel';
    }
  }

  String _getStatusActionName(MissionStatus status) {
    switch (status) {
      case MissionStatus.dispatched:
        return 'Mark Dispatched';
      case MissionStatus.arrivedAtScene:
        return 'Arrived at Scene';
      case MissionStatus.headingToHospital:
        return 'Heading to Hospital';
      case MissionStatus.arrivedAtHospital:
        return 'At Hospital';
      case MissionStatus.missionEnd:
        return 'End Mission';
      case MissionStatus.backToBase:
        return 'Back to Base';
      default:
        return 'Next';
    }
  }

  void _showCancelDialog(BuildContext context) {
    final reasons = [
      'Patient Refused Transport',
      'False Alarm',
      'Patient Deceased on Scene',
      'Another Unit Responded',
      'Patient Left Scene',
      'Other',
    ];
    String? selectedReason;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Mission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select reason for cancellation:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Reason',
              ),
              items: reasons
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (value) => selectedReason = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedReason != null) {
                Navigator.pop(context);
                onCancel(selectedReason!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.triageRed,
            ),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  void _showHospitalDialog(BuildContext context, MissionStatus nextStatus) {
    final hospitals = [
      'King Faisal Hospital',
      'King Khalid Hospital',
      'Prince Sultan Medical City',
      'Al-Noor Hospital',
      'Security Forces Hospital',
    ];
    String? selectedHospital;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Hospital'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select destination hospital:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Hospital',
              ),
              items: hospitals
                  .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                  .toList(),
              onChanged: (value) => selectedHospital = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedHospital != null) {
                Navigator.pop(context);
                onUpdateStatus(nextStatus, selectedHospital, null);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
