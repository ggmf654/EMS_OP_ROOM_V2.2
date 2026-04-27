// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/holographic_container.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../dispatcher/presentation/screens/dispatcher_screen.dart';
import '../../../wireless/presentation/screens/wireless_screen.dart';
import '../../../operations/presentation/screens/operations_dashboard_screen.dart';
import '../../../admin/presentation/screens/station_manager_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class ControlPanelScreen extends StatelessWidget {
  final User user;

  const ControlPanelScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 900;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: AppColors.primaryRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Control Panel'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                context.read<ThemeCubit>().toggleTheme();
              },
              tooltip: 'Toggle Theme',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(user: user),
                  ),
                );
              },
              tooltip: 'Settings',
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              offset: const Offset(0, 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryRed.withOpacity(0.2),
                      child: Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isTablet)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            _getRoleDisplayName(user.role),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                          ),
                        ],
                      ),
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, size: 20),
                      const SizedBox(width: 12),
                      Text('Profile'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: AppColors.primaryRed),
                      const SizedBox(width: 12),
                      Text('Logout',
                          style: TextStyle(color: AppColors.primaryRed)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') {
                  context.read<AuthBloc>().add(LogoutRequested());
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                HolographicContainer(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                            ),
                            Text(
                              user.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getRoleDisplayName(user.role),
                                style: const TextStyle(
                                  color: AppColors.primaryRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          size: 48,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Stats
                Text(
                  'Quick Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 900
                        ? 4
                        : constraints.maxWidth > 600
                            ? 2
                            : 2;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.3,
                      children: [
                        MetricCard(
                          title: 'Active Missions',
                          value: '12',
                          icon: Icons.emergency,
                          color: AppColors.triageRed,
                        ),
                        MetricCard(
                          title: 'Waiting Tasks',
                          value: '5',
                          icon: Icons.pending_actions,
                          color: AppColors.triageYellow,
                        ),
                        MetricCard(
                          title: 'Available Teams',
                          value: '8',
                          icon: Icons.groups,
                          color: AppColors.triageGreen,
                        ),
                        MetricCard(
                          title: 'Completed Today',
                          value: '24',
                          icon: Icons.check_circle,
                          color: AppColors.holographicGradient1,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Navigation Cards
                Text(
                  'Modules',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                _buildModuleGrid(context, isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleGrid(BuildContext context, bool isTablet) {
    final modules = _getModulesForRole(user.role);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
                ? 2
                : 1;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isTablet ? 2.0 : 2.5,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final module = modules[index];
            return _ModuleCard(
              title: module['title'] as String,
              description: module['description'] as String,
              icon: module['icon'] as IconData,
              color: module['color'] as Color,
              onTap: () => _navigateToModule(context, module['route'] as String),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getModulesForRole(UserRole role) {
    final List<Map<String, dynamic>> allModules = [
      {
        'title': 'Emergency Dispatch',
        'description': 'Record new emergency calls and patient information',
        'icon': Icons.add_call,
        'color': AppColors.triageRed,
        'route': 'dispatcher',
        'roles': [
          UserRole.dispatcher,
          UserRole.operationsChief,
          UserRole.admin
        ],
      },
      {
        'title': 'Wireless Operations',
        'description': 'Track mission milestones and ambulance status',
        'icon': Icons.radio,
        'color': AppColors.holographicGradient1,
        'route': 'wireless',
        'roles': [UserRole.wireless, UserRole.operationsChief, UserRole.admin],
      },
      {
        'title': 'Operations Dashboard',
        'description': 'Monitor all active missions and assign teams',
        'icon': Icons.dashboard,
        'color': AppColors.holographicGradient2,
        'route': 'operations',
        'roles': [UserRole.operationsChief, UserRole.admin],
      },
      {
        'title': 'Station Management',
        'description': 'Manage shifts, fuel, and paramedic schedules',
        'icon': Icons.business,
        'color': AppColors.triageYellow,
        'route': 'station',
        'roles': [UserRole.stationManager, UserRole.admin],
      },
      {
        'title': 'Mission Search',
        'description': 'Search and filter past missions',
        'icon': Icons.search,
        'color': AppColors.triageGreen,
        'route': 'search',
        'roles': [
          UserRole.operationsChief,
          UserRole.stationManager,
          UserRole.admin
        ],
      },
      {
        'title': 'Settings',
        'description': 'App preferences and account settings',
        'icon': Icons.settings,
        'color': AppColors.textSecondaryDark,
        'route': 'settings',
        'roles': UserRole.values,
      },
    ];

    return allModules
        .where((module) => (module['roles'] as List<UserRole>).contains(role))
        .toList();
  }

  void _navigateToModule(BuildContext context, String route) {
    Widget screen;
    switch (route) {
      case 'dispatcher':
        screen = const DispatcherScreen();
        break;
      case 'wireless':
        screen = const WirelessScreen();
        break;
      case 'operations':
        screen = const OperationsDashboardScreen();
        break;
      case 'station':
        screen = const StationManagerScreen();
        break;
      case 'settings':
        screen = SettingsScreen(user: user);
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.dispatcher:
        return 'Emergency Dispatcher';
      case UserRole.wireless:
        return 'Wireless Operator';
      case UserRole.operationsChief:
        return 'Operations Chief';
      case UserRole.stationManager:
        return 'Station Manager';
      case UserRole.admin:
        return 'System Administrator';
    }
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
