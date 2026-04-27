// ignore_for_file: prefer_const_constructors, unused_import, deprecated_member_use, unused_local_variable, override_on_non_overriding_member

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/holographic_container.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../bloc/operations_bloc.dart';

class OperationsDashboardScreen extends StatefulWidget {
  const OperationsDashboardScreen({super.key});

  @override
  State<OperationsDashboardScreen> createState() =>
      _OperationsDashboardScreenState();
}

class _OperationsDashboardScreenState extends State<OperationsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<OperationsBloc>().add(LoadDashboardData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OperationsBloc>().add(LoadDashboardData());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard, size: 20)),
            Tab(text: 'Waiting', icon: Icon(Icons.pending_actions, size: 20)),
            Tab(text: 'Active', icon: Icon(Icons.local_activity, size: 20)),
          ],
        ),
      ),
      body: BlocBuilder<OperationsBloc, OperationsState>(
        builder: (context, state) {
          if (state is OperationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OperationsLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, state),
                _buildWaitingTasksTab(context, state),
                _buildActiveTasksTab(context, state),
              ],
            );
          }

          return const Center(child: Text('Pull to refresh'));
        },
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, OperationsLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  MetricCard(
                    title: 'Waiting Tasks',
                    value: '${state.stats['waiting']}',
                    icon: Icons.pending_actions,
                    color: AppColors.triageYellow,
                  ),
                  MetricCard(
                    title: 'Active Missions',
                    value: '${state.stats['active']}',
                    icon: Icons.emergency,
                    color: AppColors.triageRed,
                  ),
                  MetricCard(
                    title: 'Available Teams',
                    value: '${state.stats['availableTeams']}',
                    icon: Icons.groups,
                    color: AppColors.triageGreen,
                  ),
                  MetricCard(
                    title: 'Completed Today',
                    value: '${state.stats['completedToday']}',
                    icon: Icons.check_circle,
                    color: AppColors.holographicGradient1,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Centers Overview
          Text(
            'Centers Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ...state.centers.map((center) => _buildCenterCard(context, center)),

          const SizedBox(height: 24),

          // Live Map Placeholder
          Text(
            'Live Map',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          HolographicContainer(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.map,
                  size: 64,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'Map Integration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add Google Maps or Mapbox API key to enable live tracking',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterCard(BuildContext context, Station center) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableTeams = center.teams.where((t) => t.isAvailable).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: AppColors.primaryRed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        center.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        center.location.address,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_gas_station,
                          size: 16,
                          color: center.fuelLevel > 50
                              ? AppColors.triageGreen
                              : center.fuelLevel > 25
                                  ? AppColors.triageYellow
                                  : AppColors.triageRed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${center.fuelLevel.toInt()}%',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$availableTeams/${center.teams.length} available',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: availableTeams > 0
                                ? AppColors.triageGreen
                                : AppColors.triageRed,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: center.teams.map((team) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: team.isAvailable
                        ? AppColors.triageGreen.withOpacity(0.1)
                        : AppColors.triageRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: team.isAvailable
                          ? AppColors.triageGreen
                          : AppColors.triageRed,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        team.isAvailable
                            ? Icons.check_circle
                            : Icons.directions_car,
                        size: 14,
                        color: team.isAvailable
                            ? AppColors.triageGreen
                            : AppColors.triageRed,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Team ${team.name}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: team.isAvailable
                                  ? AppColors.triageGreen
                                  : AppColors.triageRed,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingTasksTab(BuildContext context, OperationsLoaded state) {
    if (state.waitingTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.triageGreen.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No waiting tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'All emergencies have been assigned',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.waitingTasks.length,
      itemBuilder: (context, index) {
        final task = state.waitingTasks[index];
        return _WaitingTaskCard(
          task: task,
          centers: state.centers,
          onAssign: (centerId, teamId) {
            context.read<OperationsBloc>().add(
                  AssignCenter(
                    emergencyId: task.id,
                    centerId: centerId,
                    teamId: teamId,
                  ),
                );
          },
        );
      },
    );
  }

  Widget _buildActiveTasksTab(BuildContext context, OperationsLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.activeMissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
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

    return Column(
      children: [
        // Search and Filter
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search missions...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<OperationsBloc>().add(LoadDashboardData());
                },
              ),
            ),
            onChanged: (value) {
              context
                  .read<OperationsBloc>()
                  .add(FilterMissions(searchQuery: value));
            },
          ),
        ),

        // Active Missions Table
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Patient')),
                  DataColumn(label: Text('Triage')),
                  DataColumn(label: Text('Condition')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Team')),
                  DataColumn(label: Text('Time')),
                ],
                rows: state.activeMissions.map((mission) {
                  final center = state.centers.firstWhere(
                    (c) => c.id == mission.assignedCenterId,
                    orElse: () => state.centers.first,
                  );
                  final team = center.teams.firstWhere(
                    (t) => t.id == mission.assignedTeamId,
                    orElse: () => center.teams.first,
                  );
                  final elapsed =
                      DateTime.now().difference(mission.createdAt).inMinutes;

                  return DataRow(
                    cells: [
                       DataCell(Text(
                         mission.id.length > 8 ? mission.id.substring(0, 8) : mission.id,
                         style: const TextStyle(fontFamily: 'monospace'),
                       )),
                      DataCell(Text(mission.callerName)),
                      DataCell(StatusBadge(triageCode: mission.triageCode)),
                      DataCell(Text(_getConditionName(mission.condition))),
                      DataCell(StatusBadge(missionStatus: mission.status)),
                      DataCell(Text('${center.name} - ${team.name}')),
                      DataCell(Text(
                        '$elapsed min',
                        style: TextStyle(
                          color: elapsed > 30
                              ? AppColors.triageRed
                              : elapsed > 15
                                  ? AppColors.triageYellow
                                  : AppColors.triageGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getConditionName(MedicalCondition condition) {
    switch (condition) {
      case MedicalCondition.respiratory:
        return 'Respiratory';
      case MedicalCondition.cardiac:
        return 'Cardiac';
      case MedicalCondition.fracture:
        return 'Fracture';
      case MedicalCondition.burns:
        return 'Burns';
      case MedicalCondition.stroke:
        return 'Stroke';
      case MedicalCondition.trauma:
        return 'Trauma';
      case MedicalCondition.diabetic:
        return 'Diabetic';
      case MedicalCondition.allergic:
        return 'Allergic';
      case MedicalCondition.obstetric:
        return 'Obstetric';
      case MedicalCondition.psychiatric:
        return 'Psychiatric';
      case MedicalCondition.other:
        return 'Other';
    }
  }
}

class _WaitingTaskCard extends StatelessWidget {
  final Emergency task;
  final List<Station> centers;
  final Function(String centerId, String teamId) onAssign;

  const _WaitingTaskCard({
    required this.task,
    required this.centers,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final waitTime = DateTime.now().difference(task.createdAt).inMinutes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(triageCode: task.triageCode),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: waitTime > 10
                        ? AppColors.triageRed.withOpacity(0.1)
                        : AppColors.triageYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: waitTime > 10
                            ? AppColors.triageRed
                            : AppColors.triageYellow,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$waitTime min waiting',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: waitTime > 10
                              ? AppColors.triageRed
                              : AppColors.triageYellow,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  task.id.length > 8 ? task.id.substring(0, 8) : task.id,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.callerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const Icon(Icons.phone, size: 16),
                const SizedBox(width: 4),
                Text(
                  task.callerPhone,
                  style: Theme.of(context).textTheme.bodySmall,
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
                    task.location.address,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.medical_information, size: 18),
                const SizedBox(width: 8),
                Text(
                  _getConditionName(task.condition),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAssignDialog(context),
                icon: const Icon(Icons.assignment_ind),
                label: const Text('Assign Center'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context) {
    String? selectedCenterId;
    String? selectedTeamId;
    List<Team> availableTeams = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Assign to Center'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Center',
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                  items: centers.map((c) {
                    final available =
                        c.teams.where((t) => t.isAvailable).length;
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.name} ($available teams available)'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCenterId = value;
                      selectedTeamId = null;
                      availableTeams = centers
                          .firstWhere((c) => c.id == value)
                          .teams
                          .where((t) => t.isAvailable)
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (availableTeams.isNotEmpty)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Team',
                      prefixIcon: Icon(Icons.groups),
                    ),
                    items: availableTeams.map((t) {
                      return DropdownMenuItem(
                        value: t.id,
                        child: Text(
                            'Team ${t.name} (${t.members.length} members)'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTeamId = value;
                      });
                    },
                  ),
                if (selectedCenterId != null && availableTeams.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'No available teams at this center',
                      style: TextStyle(color: AppColors.triageRed),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedCenterId != null && selectedTeamId != null
                    ? () {
                        Navigator.pop(context);
                        onAssign(selectedCenterId!, selectedTeamId!);
                      }
                    : null,
                child: const Text('Assign'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getConditionName(MedicalCondition condition) {
    switch (condition) {
      case MedicalCondition.respiratory:
        return 'Respiratory';
      case MedicalCondition.cardiac:
        return 'Cardiac';
      case MedicalCondition.fracture:
        return 'Fracture';
      case MedicalCondition.burns:
        return 'Burns';
      case MedicalCondition.stroke:
        return 'Stroke';
      case MedicalCondition.trauma:
        return 'Trauma';
      case MedicalCondition.diabetic:
        return 'Diabetic';
      case MedicalCondition.allergic:
        return 'Allergic';
      case MedicalCondition.obstetric:
        return 'Obstetric';
      case MedicalCondition.psychiatric:
        return 'Psychiatric';
      case MedicalCondition.other:
        return 'Other';
    }
  }
}
