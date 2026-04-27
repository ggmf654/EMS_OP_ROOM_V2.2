import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';

// Events
abstract class OperationsEvent extends Equatable {
  const OperationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends OperationsEvent {}

class AssignCenter extends OperationsEvent {
  final String emergencyId;
  final String centerId;
  final String teamId;

  const AssignCenter({
    required this.emergencyId,
    required this.centerId,
    required this.teamId,
  });

  @override
  List<Object?> get props => [emergencyId, centerId, teamId];
}

// أحداث جديدة لإدارة المناوبات
class LoadShiftData extends OperationsEvent {
  final ShiftType shiftType;

  const LoadShiftData({required this.shiftType});

  @override
  List<Object?> get props => [shiftType];
}

class AssignTeamToCenter extends OperationsEvent {
  final String centerId;
  final String teamId;
  final ShiftType shiftType;

  const AssignTeamToCenter({
    required this.centerId,
    required this.teamId,
    required this.shiftType,
  });

  @override
  List<Object?> get props => [centerId, teamId, shiftType];
}

class RequestLeave extends OperationsEvent {
  final String paramedicId;
  final String replacementId;
  final ShiftType shiftType;

  const RequestLeave({
    required this.paramedicId,
    required this.replacementId,
    required this.shiftType,
  });

  @override
  List<Object?> get props => [paramedicId, replacementId, shiftType];
}

class ApproveLeaveRequest extends OperationsEvent {
  final String requestId;

  const ApproveLeaveRequest({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

class RejectLeaveRequest extends OperationsEvent {
  final String requestId;

  const RejectLeaveRequest({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

// أحداث جديدة لإدارة المهمات
class RecordMissionTiming extends OperationsEvent {
  final String missionId;
  final MissionTimingType timingType;
  final DateTime timestamp;

  const RecordMissionTiming({
    required this.missionId,
    required this.timingType,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [missionId, timingType, timestamp];
}

class UpdateTeamLeader extends OperationsEvent {
  final String missionId;
  final String teamLeaderName;

  const UpdateTeamLeader({
    required this.missionId,
    required this.teamLeaderName,
  });

  @override
  List<Object?> get props => [missionId, teamLeaderName];
}

class UpdateVehicleCode extends OperationsEvent {
  final String missionId;
  final String vehicleCode;

  const UpdateVehicleCode({
    required this.missionId,
    required this.vehicleCode,
  });

  @override
  List<Object?> get props => [missionId, vehicleCode];
}

class RecordTransferDestination extends OperationsEvent {
  final String missionId;
  final String destination;

  const RecordTransferDestination({
    required this.missionId,
    required this.destination,
  });

  @override
  List<Object?> get props => [missionId, destination];
}

class RecordNonTransferReason extends OperationsEvent {
  final String missionId;
  final String reason;

  const RecordNonTransferReason({
    required this.missionId,
    required this.reason,
  });

  @override
  List<Object?> get props => [missionId, reason];
}

class FilterMissions extends OperationsEvent {
  final TriageCode? triageCode;
  final MissionStatus? status;
  final MedicalCondition? condition;
  final String? centerId;
  final String? searchQuery;

  const FilterMissions({
    this.triageCode,
    this.status,
    this.condition,
    this.centerId,
    this.searchQuery,
  });

  @override
  List<Object?> get props =>
      [triageCode, status, condition, centerId, searchQuery];
}

// States
abstract class OperationsState extends Equatable {
  const OperationsState();

  @override
  List<Object?> get props => [];
}

class OperationsInitial extends OperationsState {}

class OperationsLoading extends OperationsState {}

class OperationsLoaded extends OperationsState {
  final List<Emergency> waitingTasks;
  final List<Emergency> activeMissions;
  final List<Emergency> allMissions;
  final List<Station> centers;
  final Map<String, int> stats;

  const OperationsLoaded({
    required this.waitingTasks,
    required this.activeMissions,
    required this.allMissions,
    required this.centers,
    required this.stats,
  });

  @override
  List<Object?> get props =>
      [waitingTasks, activeMissions, allMissions, centers, stats];
}

class OperationsError extends OperationsState {
  final String message;

  const OperationsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class OperationsBloc extends Bloc<OperationsEvent, OperationsState> {
  // Demo data
  final List<Emergency> _allMissions = [
    Emergency(
      id: 'em_001',
      callerName: 'Fatima Ahmed',
      callerPhone: '+966501234567',
      vitals: const PatientVitals(pulse: 88, spo2: 96, gcs: 15),
      triageCode: TriageCode.yellow,
      condition: MedicalCondition.cardiac,
      location: const Location(
        address: '123 King Fahd Road',
        latitude: 24.7136,
        longitude: 46.6753,
      ),
      status: MissionStatus.dispatched,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      assignedCenterId: 'center_1',
      assignedTeamId: 'team_1a',
    ),
    Emergency(
      id: 'em_002',
      callerName: 'Mohammed Hassan',
      callerPhone: '+966509876543',
      vitals: const PatientVitals(pulse: 110, spo2: 94, gcs: 13),
      triageCode: TriageCode.red,
      condition: MedicalCondition.diabetic,
      location: const Location(
        address: '456 Olaya Street',
        latitude: 24.6850,
        longitude: 46.7060,
      ),
      status: MissionStatus.arrivedAtScene,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      assignedCenterId: 'center_2',
      assignedTeamId: 'team_2a',
    ),
    // Waiting tasks
    Emergency(
      id: 'em_004',
      callerName: 'Ali Mahmoud',
      callerPhone: '+966507778899',
      vitals: const PatientVitals(pulse: 95, spo2: 97, gcs: 14),
      triageCode: TriageCode.yellow,
      condition: MedicalCondition.respiratory,
      location: const Location(
        address: '321 Al-Malaz District',
        latitude: 24.6600,
        longitude: 46.7400,
      ),
      status: MissionStatus.waiting,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    Emergency(
      id: 'em_005',
      callerName: 'Noura Saleh',
      callerPhone: '+966501112233',
      vitals: const PatientVitals(pulse: 120, spo2: 92, gcs: 12),
      triageCode: TriageCode.red,
      condition: MedicalCondition.stroke,
      location: const Location(
        address: '789 Exit 15, Northern Ring Road',
        latitude: 24.7500,
        longitude: 46.7000,
      ),
      status: MissionStatus.waiting,
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    Emergency(
      id: 'em_006',
      callerName: 'Khalid Omar',
      callerPhone: '+966509998877',
      vitals: const PatientVitals(pulse: 78, spo2: 99),
      triageCode: TriageCode.green,
      condition: MedicalCondition.fracture,
      location: const Location(
        address: '555 King Abdullah Road',
        latitude: 24.7200,
        longitude: 46.6500,
      ),
      status: MissionStatus.waiting,
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
  ];

  final List<Station> _centers = [
    const Station(
      id: 'center_1',
      name: 'North Station',
      location: Location(
        address: 'Northern Ring Road',
        latitude: 24.7500,
        longitude: 46.6800,
      ),
      teams: [
        Team(
          id: 'team_1a',
          name: 'Alpha',
          centerId: 'center_1',
          members: [
            Paramedic(id: 'p1', name: 'Ahmad Ali'),
            Paramedic(id: 'p2', name: 'Fahad Hassan'),
            Paramedic(id: 'p3', name: 'Turki Mohammed'),
            Paramedic(id: 'p4', name: 'Saad Ibrahim'),
          ],
          isAvailable: false,
          currentLatitude: 24.7136,
          currentLongitude: 46.6753,
        ),
        Team(
          id: 'team_1b',
          name: 'Bravo',
          centerId: 'center_1',
          members: [
            Paramedic(id: 'p5', name: 'Nasser Khalid'),
            Paramedic(id: 'p6', name: 'Faisal Omar'),
            Paramedic(id: 'p7', name: 'Abdullah Rashid'),
            Paramedic(id: 'p8', name: 'Rayan Ahmed'),
          ],
          isAvailable: true,
        ),
      ],
      fuelLevel: 75.0,
    ),
    const Station(
      id: 'center_2',
      name: 'South Station',
      location: Location(
        address: 'Exit 14, Southern Ring Road',
        latitude: 24.6200,
        longitude: 46.7200,
      ),
      teams: [
        Team(
          id: 'team_2a',
          name: 'Charlie',
          centerId: 'center_2',
          members: [
            Paramedic(id: 'p9', name: 'Majed Saleh'),
            Paramedic(id: 'p10', name: 'Sultan Nasser'),
            Paramedic(id: 'p11', name: 'Waleed Faisal'),
            Paramedic(id: 'p12', name: 'Omar Tariq'),
          ],
          isAvailable: false,
          currentLatitude: 24.6850,
          currentLongitude: 46.7060,
        ),
        Team(
          id: 'team_2b',
          name: 'Delta',
          centerId: 'center_2',
          members: [
            Paramedic(id: 'p13', name: 'Hamad Ali'),
            Paramedic(id: 'p14', name: 'Yasser Mohammed'),
            Paramedic(id: 'p15', name: 'Nawaf Abdullah'),
            Paramedic(id: 'p16', name: 'Badr Khalid'),
          ],
          isAvailable: true,
        ),
      ],
      fuelLevel: 90.0,
    ),
    const Station(
      id: 'center_3',
      name: 'East Station',
      location: Location(
        address: 'Khurais Road',
        latitude: 24.7100,
        longitude: 46.8000,
      ),
      teams: [
        Team(
          id: 'team_3a',
          name: 'Echo',
          centerId: 'center_3',
          members: [
            Paramedic(id: 'p17', name: 'Abdulrahman Saad'),
            Paramedic(id: 'p18', name: 'Mohammed Fahad'),
            Paramedic(id: 'p19', name: 'Saud Turki'),
            Paramedic(id: 'p20', name: 'Hassan Ali'),
          ],
          isAvailable: true,
        ),
        Team(
          id: 'team_3b',
          name: 'Foxtrot',
          centerId: 'center_3',
          members: [
            Paramedic(id: 'p21', name: 'Khalid Nasser'),
            Paramedic(id: 'p22', name: 'Ibrahim Sultan'),
            Paramedic(id: 'p23', name: 'Saleh Majed'),
            Paramedic(id: 'p24', name: 'Tariq Waleed'),
          ],
          isAvailable: true,
        ),
      ],
      fuelLevel: 60.0,
    ),
    const Station(
      id: 'center_4',
      name: 'West Station',
      location: Location(
        address: 'Makkah Road',
        latitude: 24.7000,
        longitude: 46.6000,
      ),
      teams: [
        Team(
          id: 'team_4a',
          name: 'Golf',
          centerId: 'center_4',
          members: [
            Paramedic(id: 'p25', name: 'Faris Abdullah'),
            Paramedic(id: 'p26', name: 'Rashid Hamad'),
            Paramedic(id: 'p27', name: 'Ahmed Yasser'),
            Paramedic(id: 'p28', name: 'Osama Nawaf'),
          ],
          isAvailable: true,
        ),
        Team(
          id: 'team_4b',
          name: 'Hotel',
          centerId: 'center_4',
          members: [
            Paramedic(id: 'p29', name: 'Zayed Badr'),
            Paramedic(id: 'p30', name: 'Mansour Abdulrahman'),
            Paramedic(id: 'p31', name: 'Rakan Mohammed'),
            Paramedic(id: 'p32', name: 'Talal Saud'),
          ],
          isAvailable: true,
        ),
      ],
      fuelLevel: 85.0,
    ),
  ];

  OperationsBloc() : super(OperationsInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<AssignCenter>(_onAssignCenter);
    on<FilterMissions>(_onFilterMissions);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<OperationsState> emit,
  ) async {
    emit(OperationsLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final waitingTasks =
        _allMissions.where((m) => m.status == MissionStatus.waiting).toList();
    final activeMissions = _allMissions
        .where((m) =>
            m.status != MissionStatus.waiting &&
            m.status != MissionStatus.backToBase &&
            m.status != MissionStatus.cancelled)
        .toList();

    final stats = {
      'waiting': waitingTasks.length,
      'active': activeMissions.length,
      'completedToday': 24,
      'availableTeams': _centers.fold<int>(
          0, (sum, c) => sum + c.teams.where((t) => t.isAvailable).length),
    };

    emit(OperationsLoaded(
      waitingTasks: waitingTasks,
      activeMissions: activeMissions,
      allMissions: _allMissions,
      centers: _centers,
      stats: stats,
    ));
  }

  Future<void> _onAssignCenter(
    AssignCenter event,
    Emitter<OperationsState> emit,
  ) async {
    emit(OperationsLoading());
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _allMissions.indexWhere((m) => m.id == event.emergencyId);
    if (index != -1) {
      _allMissions[index] = _allMissions[index].copyWith(
        assignedCenterId: event.centerId,
        assignedTeamId: event.teamId,
        status: MissionStatus.dispatched,
      );
    }

    add(LoadDashboardData());
  }

  Future<void> _onFilterMissions(
    FilterMissions event,
    Emitter<OperationsState> emit,
  ) async {
    if (state is! OperationsLoaded) return;

    final currentState = state as OperationsLoaded;
    var filtered = List<Emergency>.from(currentState.allMissions);

    if (event.triageCode != null) {
      filtered =
          filtered.where((m) => m.triageCode == event.triageCode).toList();
    }
    if (event.status != null) {
      filtered = filtered.where((m) => m.status == event.status).toList();
    }
    if (event.condition != null) {
      filtered = filtered.where((m) => m.condition == event.condition).toList();
    }
    if (event.centerId != null) {
      filtered = filtered
          .where((m) => m.assignedCenterId == event.centerId)
          .toList();
    }
    if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
      final query = event.searchQuery!.toLowerCase();
      filtered = filtered
          .where((m) =>
              m.callerName.toLowerCase().contains(query) ||
              m.location.address.toLowerCase().contains(query) ||
              m.id.toLowerCase().contains(query))
          .toList();
    }

    emit(OperationsLoaded(
      waitingTasks:
          filtered.where((m) => m.status == MissionStatus.waiting).toList(),
      activeMissions: filtered
          .where((m) =>
              m.status != MissionStatus.waiting &&
              m.status != MissionStatus.backToBase)
          .toList(),
      allMissions: filtered,
      centers: currentState.centers,
      stats: currentState.stats,
    ));
  }
}
