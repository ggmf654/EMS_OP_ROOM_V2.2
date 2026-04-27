// ignore_for_file: prefer_final_fields, prefer_const_literals_to_create_immutables

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';

// Events
abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminData extends AdminEvent {}

class UpdateFuelLevel extends AdminEvent {
  final String centerId;
  final double newLevel;

  const UpdateFuelLevel({required this.centerId, required this.newLevel});

  @override
  List<Object?> get props => [centerId, newLevel];
}

class UpdateShiftAssignment extends AdminEvent {
  final String shiftId;
  final Map<String, List<String>> assignments;

  const UpdateShiftAssignment({
    required this.shiftId,
    required this.assignments,
  });

  @override
  List<Object?> get props => [shiftId, assignments];
}

class SearchMissions extends AdminEvent {
  final String? query;
  final TriageCode? triageCode;
  final MedicalCondition? condition;
  final String? centerId;
  final DateTimeRange? dateRange;

  const SearchMissions({
    this.query,
    this.triageCode,
    this.condition,
    this.centerId,
    this.dateRange,
  });

  @override
  List<Object?> get props => [query, triageCode, condition, centerId, dateRange];
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});
}

// States
abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<Station> centers;
  final List<Paramedic> paramedics;
  final List<Shift> shifts;
  final List<Emergency> missionHistory;
  final Map<String, dynamic> stats;

  const AdminLoaded({
    required this.centers,
    required this.paramedics,
    required this.shifts,
    required this.missionHistory,
    required this.stats,
  });

  @override
  List<Object?> get props => [centers, paramedics, shifts, missionHistory, stats];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  List<Station> _centers = [
    const Station(
      id: 'center_1',
      name: 'North Station',
      location: Location(address: 'Northern Ring Road'),
      teams: [
        Team(id: 'team_1a', name: 'Alpha', centerId: 'center_1', members: []),
        Team(id: 'team_1b', name: 'Bravo', centerId: 'center_1', members: []),
      ],
      fuelLevel: 75.0,
    ),
    const Station(
      id: 'center_2',
      name: 'South Station',
      location: Location(address: 'Southern Ring Road'),
      teams: [
        Team(id: 'team_2a', name: 'Charlie', centerId: 'center_2', members: []),
        Team(id: 'team_2b', name: 'Delta', centerId: 'center_2', members: []),
      ],
      fuelLevel: 90.0,
    ),
    const Station(
      id: 'center_3',
      name: 'East Station',
      location: Location(address: 'Khurais Road'),
      teams: [
        Team(id: 'team_3a', name: 'Echo', centerId: 'center_3', members: []),
        Team(id: 'team_3b', name: 'Foxtrot', centerId: 'center_3', members: []),
      ],
      fuelLevel: 60.0,
    ),
    const Station(
      id: 'center_4',
      name: 'West Station',
      location: Location(address: 'Makkah Road'),
      teams: [
        Team(id: 'team_4a', name: 'Golf', centerId: 'center_4', members: []),
        Team(id: 'team_4b', name: 'Hotel', centerId: 'center_4', members: []),
      ],
      fuelLevel: 85.0,
    ),
  ];

  final List<Paramedic> _paramedics = List.generate(
    32,
    (i) => Paramedic(
      id: 'p${i + 1}',
      name: 'Paramedic ${i + 1}',
      shiftsAttended: (i * 3) % 20 + 5,
      missionsCompleted: (i * 7) % 50 + 10,
    ),
  );

  final List<Shift> _shifts = [
    Shift(
      id: 'shift_morning',
      date: DateTime.now(),
      shiftType: 'Morning (6AM-2PM)',
      centerTeamAssignments: {
        'center_1': ['p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8'],
        'center_2': ['p9', 'p10', 'p11', 'p12', 'p13', 'p14', 'p15', 'p16'],
        'center_3': ['p17', 'p18', 'p19', 'p20', 'p21', 'p22', 'p23', 'p24'],
        'center_4': ['p25', 'p26', 'p27', 'p28', 'p29', 'p30', 'p31', 'p32'],
      },
    ),
    Shift(
      id: 'shift_evening',
      date: DateTime.now(),
      shiftType: 'Evening (2PM-10PM)',
      centerTeamAssignments: {},
    ),
    Shift(
      id: 'shift_night',
      date: DateTime.now(),
      shiftType: 'Night (10PM-6AM)',
      centerTeamAssignments: {},
    ),
  ];

  final List<Emergency> _missionHistory = List.generate(
    50,
    (i) => Emergency(
      id: 'hist_${i + 1}'.padLeft(10, '0'),
      callerName: 'Patient ${i + 1}',
      callerPhone: '+96650${1000000 + i}',
      vitals: const PatientVitals(pulse: 80, spo2: 97),
      triageCode: TriageCode.values[i % 3],
      condition: MedicalCondition.values[i % MedicalCondition.values.length],
      location: Location(address: 'Address ${i + 1}, Riyadh'),
      status: MissionStatus.backToBase,
      createdAt: DateTime.now().subtract(Duration(days: i, hours: i % 24)),
      assignedCenterId: 'center_${(i % 4) + 1}',
    ),
  );

  AdminBloc() : super(AdminInitial()) {
    on<LoadAdminData>(_onLoadAdminData);
    on<UpdateFuelLevel>(_onUpdateFuelLevel);
    on<UpdateShiftAssignment>(_onUpdateShiftAssignment);
    on<SearchMissions>(_onSearchMissions);
  }

  Future<void> _onLoadAdminData(
    LoadAdminData event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final stats = {
      'totalMissions': _missionHistory.length,
      'totalParamedics': _paramedics.length,
      'totalCenters': _centers.length,
      'avgResponseTime': '8.5 min',
      'redCases': _missionHistory.where((m) => m.triageCode == TriageCode.red).length,
      'yellowCases': _missionHistory.where((m) => m.triageCode == TriageCode.yellow).length,
      'greenCases': _missionHistory.where((m) => m.triageCode == TriageCode.green).length,
    };

    emit(AdminLoaded(
      centers: _centers,
      paramedics: _paramedics,
      shifts: _shifts,
      missionHistory: _missionHistory,
      stats: stats,
    ));
  }

  Future<void> _onUpdateFuelLevel(
    UpdateFuelLevel event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _centers.indexWhere((c) => c.id == event.centerId);
    if (index != -1) {
      _centers[index] = Station(
        id: _centers[index].id,
        name: _centers[index].name,
        location: _centers[index].location,
        teams: _centers[index].teams,
        fuelLevel: event.newLevel,
      );
    }

    add(LoadAdminData());
  }

  Future<void> _onUpdateShiftAssignment(
    UpdateShiftAssignment event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    add(LoadAdminData());
  }

  Future<void> _onSearchMissions(
    SearchMissions event,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminLoaded) return;

    final currentState = state as AdminLoaded;
    var filtered = List<Emergency>.from(_missionHistory);

    if (event.query != null && event.query!.isNotEmpty) {
      final query = event.query!.toLowerCase();
      filtered = filtered.where((m) =>
        m.callerName.toLowerCase().contains(query) ||
        m.location.address.toLowerCase().contains(query) ||
        m.id.toLowerCase().contains(query)
      ).toList();
    }
    if (event.triageCode != null) {
      filtered = filtered.where((m) => m.triageCode == event.triageCode).toList();
    }
    if (event.condition != null) {
      filtered = filtered.where((m) => m.condition == event.condition).toList();
    }
    if (event.centerId != null) {
      filtered = filtered.where((m) => m.assignedCenterId == event.centerId).toList();
    }
    if (event.dateRange != null) {
      filtered = filtered.where((m) =>
        m.createdAt.isAfter(event.dateRange!.start) &&
        m.createdAt.isBefore(event.dateRange!.end)
      ).toList();
    }

    emit(AdminLoaded(
      centers: currentState.centers,
      paramedics: currentState.paramedics,
      shifts: currentState.shifts,
      missionHistory: filtered,
      stats: currentState.stats,
    ));
  }
}
