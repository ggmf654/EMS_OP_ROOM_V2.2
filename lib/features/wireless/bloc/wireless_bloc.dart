// ignore_for_file: prefer_final_fields, override_on_non_overriding_member

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';

// Events
abstract class WirelessEvent extends Equatable {
  const WirelessEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveMissions extends WirelessEvent {}

class UpdateMissionStatus extends WirelessEvent {
  final String missionId;
  final MissionStatus newStatus;
  final String? hospitalName;
  final String? notes;

  const UpdateMissionStatus({
    required this.missionId,
    required this.newStatus,
    this.hospitalName,
    this.notes,
  });

  @override
  List<Object?> get props => [missionId, newStatus, hospitalName, notes];
}

class CancelMission extends WirelessEvent {
  final String missionId;
  final String reason;

  const CancelMission({
    required this.missionId,
    required this.reason,
  });

  @override
  List<Object?> get props => [missionId, reason];
}

// States
abstract class WirelessState extends Equatable {
  const WirelessState();

  @override
  List<Object?> get props => [];
}

class WirelessInitial extends WirelessState {}

class WirelessLoading extends WirelessState {}

class WirelessLoaded extends WirelessState {
  final List<Emergency> activeMissions;

  const WirelessLoaded(this.activeMissions);

  @override
  List<Object?> get props => [activeMissions];
}

class MissionUpdated extends WirelessState {
  final Emergency mission;

  const MissionUpdated(this.mission);

  @override
  List<Object?> get props => [mission];
}

class WirelessError extends WirelessState {
  final String message;

  const WirelessError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class WirelessBloc extends Bloc<WirelessEvent, WirelessState> {
  // Demo data
  List<Emergency> _activeMissions = [
    Emergency(
      id: 'em_001',
      callerName: 'Fatima Ahmed',
      callerPhone: '+966501234567',
      vitals: const PatientVitals(
        bloodSugar: 145,
        systolicBP: 140,
        diastolicBP: 90,
        pulse: 88,
        spo2: 96,
        gcs: 15,
      ),
      medicalHistory: 'Hypertension',
      triageCode: TriageCode.yellow,
      condition: MedicalCondition.cardiac,
      location: const Location(
        address: '123 King Fahd Road, Riyadh',
        floor: '3',
        room: '305',
      ),
      supervisingDoctor: 'Dr. Abdullah',
      status: MissionStatus.dispatched,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      assignedCenterId: 'center_1',
      assignedTeamId: 'team_1a',
      milestones: [
        MissionMilestone(
          status: MissionStatus.waiting,
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
        MissionMilestone(
          status: MissionStatus.dispatched,
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ],
    ),
    Emergency(
      id: 'em_002',
      callerName: 'Mohammed Hassan',
      callerPhone: '+966509876543',
      vitals: const PatientVitals(
        bloodSugar: 45,
        systolicBP: 100,
        diastolicBP: 60,
        pulse: 110,
        spo2: 94,
        gcs: 13,
      ),
      medicalHistory: 'Type 1 Diabetes',
      triageCode: TriageCode.red,
      condition: MedicalCondition.diabetic,
      location: const Location(
        address: '456 Olaya Street, Riyadh',
        floor: '1',
      ),
      status: MissionStatus.arrivedAtScene,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      assignedCenterId: 'center_2',
      assignedTeamId: 'team_2a',
      milestones: [
        MissionMilestone(
          status: MissionStatus.waiting,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        MissionMilestone(
          status: MissionStatus.dispatched,
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
        MissionMilestone(
          status: MissionStatus.arrivedAtScene,
          timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
        ),
      ],
    ),
    Emergency(
      id: 'em_003',
      callerName: 'Sara Khalid',
      callerPhone: '+966505551234',
      vitals: const PatientVitals(
        pulse: 72,
        spo2: 98,
        gcs: 15,
      ),
      triageCode: TriageCode.green,
      condition: MedicalCondition.fracture,
      location: const Location(
        address: '789 Prince Sultan Road',
        floor: 'Ground',
        room: 'Parking',
      ),
      status: MissionStatus.headingToHospital,
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      assignedCenterId: 'center_1',
      assignedTeamId: 'team_1b',
      milestones: [
        MissionMilestone(
          status: MissionStatus.waiting,
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        MissionMilestone(
          status: MissionStatus.dispatched,
          timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
        ),
        MissionMilestone(
          status: MissionStatus.arrivedAtScene,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        MissionMilestone(
          status: MissionStatus.headingToHospital,
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          hospitalName: 'King Faisal Hospital',
        ),
      ],
    ),
  ];

  WirelessBloc() : super(WirelessInitial()) {
    on<LoadActiveMissions>(_onLoadActiveMissions);
    on<UpdateMissionStatus>(_onUpdateMissionStatus);
    on<CancelMission>(_onCancelMission);
  }

  Future<void> _onLoadActiveMissions(
    LoadActiveMissions event,
    Emitter<WirelessState> emit,
  ) async {
    emit(WirelessLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(WirelessLoaded(_activeMissions));
  }

  Future<void> _onUpdateMissionStatus(
    UpdateMissionStatus event,
    Emitter<WirelessState> emit,
  ) async {
    emit(WirelessLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index =
          _activeMissions.indexWhere((m) => m.id == event.missionId);
      if (index == -1) {
        emit(const WirelessError('Mission not found'));
        return;
      }

      final mission = _activeMissions[index];
      final newMilestone = MissionMilestone(
        status: event.newStatus,
        timestamp: DateTime.now(),
        hospitalName: event.hospitalName,
        notes: event.notes,
      );

      final updatedMission = mission.copyWith(
        status: event.newStatus,
        milestones: [...mission.milestones, newMilestone],
      );

      _activeMissions[index] = updatedMission;
      emit(MissionUpdated(updatedMission));
    } catch (e) {
      emit(WirelessError('Failed to update mission: ${e.toString()}'));
    }
  }

  Future<void> _onCancelMission(
    CancelMission event,
    Emitter<WirelessState> emit,
  ) async {
    emit(WirelessLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index =
          _activeMissions.indexWhere((m) => m.id == event.missionId);
      if (index == -1) {
        emit(const WirelessError('Mission not found'));
        return;
      }

      final mission = _activeMissions[index];
      final updatedMission = mission.copyWith(
        status: MissionStatus.cancelled,
        cancellationReason: event.reason,
      );

      _activeMissions[index] = updatedMission;
      emit(MissionUpdated(updatedMission));
    } catch (e) {
      emit(WirelessError('Failed to cancel mission: ${e.toString()}'));
    }
  }
}
