// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/holographic_container.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../bloc/admin_bloc.dart';

class StationManagerScreen extends StatefulWidget {
  const StationManagerScreen({super.key});

  @override
  State<StationManagerScreen> createState() => _StationManagerScreenState();
}

class _StationManagerScreenState extends State<StationManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<AdminBloc>().add(LoadAdminData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Station Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminBloc>().add(LoadAdminData());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard, size: 20)),
            Tab(text: 'Fuel Tracking', icon: Icon(Icons.local_gas_station, size: 20)),
            Tab(text: 'Shift Schedule', icon: Icon(Icons.schedule, size: 20)),
            Tab(text: 'Mission Search', icon: Icon(Icons.search, size: 20)),
          ],
        ),
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, state),
                _buildFuelTrackingTab(context, state),
                _buildShiftScheduleTab(context, state),
                _buildMissionSearchTab(context, state),
              ],
            );
          }

          return const Center(child: Text('Pull to refresh'));
        },
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, AdminLoaded state) {
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
                    title: 'Total Missions',
                    value: '${state.stats['totalMissions']}',
                    icon: Icons.assignment,
                    color: AppColors.holographicGradient1,
                  ),
                  MetricCard(
                    title: 'Total Paramedics',
                    value: '${state.stats['totalParamedics']}',
                    icon: Icons.people,
                    color: AppColors.holographicGradient2,
                  ),
                  MetricCard(
                    title: 'Active Centers',
                    value: '${state.stats['totalCenters']}',
                    icon: Icons.business,
                    color: AppColors.triageGreen,
                  ),
                  MetricCard(
                    title: 'Avg Response Time',
                    value: '${state.stats['avgResponseTime']}',
                    icon: Icons.timer,
                    color: AppColors.triageYellow,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Triage Distribution
          Text(
            'Triage Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTriageStatCard(context, 'Red', state.stats['redCases'], AppColors.triageRed),
              const SizedBox(width: 12),
              _buildTriageStatCard(context, 'Yellow', state.stats['yellowCases'], AppColors.triageYellow),
              const SizedBox(width: 12),
              _buildTriageStatCard(context, 'Green', state.stats['greenCases'], AppColors.triageGreen),
            ],
          ),
          const SizedBox(height: 24),

          // Top Paramedics
          Text(
            'Top Paramedics by Missions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ...(state.paramedics
              .toList()
              ..sort((a, b) => b.missionsCompleted.compareTo(a.missionsCompleted)))
              .take(5)
              .map((p) => _buildParamedicCard(context, p)),
        ],
      ),
    );
  }

  Widget _buildTriageStatCard(BuildContext context, String label, int count, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Icon(Icons.circle, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParamedicCard(BuildContext context, Paramedic paramedic) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryRed.withOpacity(0.2),
              child: Text(
                paramedic.name.substring(0, 1),
                style: const TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paramedic.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '${paramedic.shiftsAttended} shifts attended',
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
                Text(
                  '${paramedic.missionsCompleted}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.triageGreen,
                      ),
                ),
                Text(
                  'missions',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelTrackingTab(BuildContext context, AdminLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.centers.length,
      itemBuilder: (context, index) {
        final center = state.centers[index];
        return _FuelCard(
          center: center,
          onUpdateFuel: (newLevel) {
            context.read<AdminBloc>().add(
                  UpdateFuelLevel(centerId: center.id, newLevel: newLevel),
                );
          },
        );
      },
    );
  }

  Widget _buildShiftScheduleTab(BuildContext context, AdminLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Date
          HolographicContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primaryRed),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Shift Cards
          ...state.shifts.map((shift) => _buildShiftCard(context, shift, state)),
        ],
      ),
    );
  }

  Widget _buildShiftCard(BuildContext context, Shift shift, AdminLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAssignments = shift.centerTeamAssignments.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                    color: AppColors.holographicGradient1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: AppColors.holographicGradient1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shift.shiftType,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        hasAssignments
                            ? '${_getTotalAssigned(shift)} paramedics assigned'
                            : 'No assignments yet',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showShiftEditorDialog(context, shift, state),
                ),
              ],
            ),
            if (hasAssignments) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ...state.centers.map((center) {
                final assigned = shift.centerTeamAssignments[center.id] ?? [];
                if (assigned.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          center.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: assigned.map((pId) {
                            final paramedic = state.paramedics.firstWhere(
                              (p) => p.id == pId,
                              orElse: () => Paramedic(id: pId, name: pId),
                            );
                            return Chip(
                              label: Text(
                                paramedic.name,
                                style: const TextStyle(fontSize: 10),
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  int _getTotalAssigned(Shift shift) {
    return shift.centerTeamAssignments.values
        .fold<int>(0, (sum, list) => sum + list.length);
  }

  void _showShiftEditorDialog(BuildContext context, Shift shift, AdminLoaded state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${shift.shiftType}'),
        content: const SizedBox(
          width: 400,
          child: Text(
            'Shift scheduling editor would allow drag-and-drop assignment of paramedics to centers and teams.\n\n'
            'Structure: 4 centers, 2 teams per center, 4 members per team.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSearchTab(BuildContext context, AdminLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search & Filters
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, address, or ID...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<AdminBloc>().add(LoadAdminData());
                    },
                  ),
                ),
                onChanged: (value) {
                  context.read<AdminBloc>().add(SearchMissions(query: value));
                },
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      'All',
                      null,
                      () => context.read<AdminBloc>().add(LoadAdminData()),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'Red',
                      AppColors.triageRed,
                      () => context.read<AdminBloc>().add(
                            const SearchMissions(triageCode: TriageCode.red),
                          ),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'Yellow',
                      AppColors.triageYellow,
                      () => context.read<AdminBloc>().add(
                            const SearchMissions(triageCode: TriageCode.yellow),
                          ),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'Green',
                      AppColors.triageGreen,
                      () => context.read<AdminBloc>().add(
                            const SearchMissions(triageCode: TriageCode.green),
                          ),
                    ),
                    const SizedBox(width: 8),
                    ...MedicalCondition.values.take(5).map((condition) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(
                          context,
                          _getConditionName(condition),
                          null,
                          () => context.read<AdminBloc>().add(
                                SearchMissions(condition: condition),
                              ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Results
        Expanded(
          child: state.missionHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No missions found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.missionHistory.length,
                  itemBuilder: (context, index) {
                    final mission = state.missionHistory[index];
                    return _buildMissionHistoryCard(context, mission, state);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    Color? color,
    VoidCallback onTap,
  ) {
    return ActionChip(
      label: Text(label),
      avatar: color != null
          ? Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onPressed: onTap,
    );
  }

  Widget _buildMissionHistoryCard(
    BuildContext context,
    Emergency mission,
    AdminLoaded state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final center = state.centers.firstWhere(
      (c) => c.id == mission.assignedCenterId,
      orElse: () => state.centers.first,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: mission.triageCode == TriageCode.red
                    ? AppColors.triageRed
                    : mission.triageCode == TriageCode.yellow
                        ? AppColors.triageYellow
                        : AppColors.triageGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        mission.callerName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(triageCode: mission.triageCode),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${mission.location.address} | ${center.name}',
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
                Text(
                  DateFormat('MM/dd').format(mission.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  DateFormat('HH:mm').format(mission.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ],
        ),
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

class _FuelCard extends StatelessWidget {
  final Station center;
  final Function(double) onUpdateFuel;

  const _FuelCard({
    required this.center,
    required this.onUpdateFuel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fuelColor = center.fuelLevel > 50
        ? AppColors.triageGreen
        : center.fuelLevel > 25
            ? AppColors.triageYellow
            : AppColors.triageRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: fuelColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_gas_station,
                    color: fuelColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
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
                    Text(
                      '${center.fuelLevel.toInt()}%',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: fuelColor,
                          ),
                    ),
                    Text(
                      'Fuel Level',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Fuel Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: center.fuelLevel / 100,
                backgroundColor: fuelColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(fuelColor),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final newLevel = (center.fuelLevel - 10).clamp(0.0, 100.0);
                      onUpdateFuel(newLevel);
                    },
                    icon: const Icon(Icons.remove, size: 18),
                    label: const Text('-10%'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final newLevel = (center.fuelLevel + 10).clamp(0.0, 100.0);
                      onUpdateFuel(newLevel);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('+10%'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => onUpdateFuel(100.0),
                  icon: const Icon(Icons.battery_charging_full),
                  tooltip: 'Fill Tank',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.triageGreen.withOpacity(0.1),
                    foregroundColor: AppColors.triageGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
