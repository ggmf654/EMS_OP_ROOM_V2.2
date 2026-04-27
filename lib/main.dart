// ignore_for_file: unused_import, override_on_non_overriding_member

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/dashboard/presentation/screens/control_panel_screen.dart';
import 'features/dispatcher/bloc/dispatcher_bloc.dart';
import 'features/wireless/bloc/wireless_bloc.dart';
import 'features/operations/bloc/operations_bloc.dart';
import 'features/admin/bloc/admin_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EmergencyManagementApp());
}

class EmergencyManagementApp extends StatelessWidget {
  const EmergencyManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => DispatcherBloc()),
        BlocProvider(create: (_) => WirelessBloc()),
        BlocProvider(create: (_) => OperationsBloc()),
        BlocProvider(create: (_) => AdminBloc()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Emergency Management System',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
