// ignore_for_file: override_on_non_overriding_member

import 'package:equatable/equatable.dart';

enum UserRole { dispatcher, wireless, operationsChief, stationManager, admin }

enum TriageCode { red, yellow, green }

enum MissionStatus {
  waiting,
  dispatched,
  arrivedAtScene,
  headingToHospital,
  arrivedAtHospital,
  missionEnd,
  backToBase,
  cancelled
}

enum MedicalCondition {
  respiratory,
  cardiac,
  fracture,
  burns,
  stroke,
  trauma,
  diabetic,
  allergic,
  obstetric,
  psychiatric,
  other
}

class User extends Equatable {
  final String id;
  final String username;
  final String name;
  final UserRole role;
  final String? centerId;

  const User({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    this.centerId,
  });

  @override
  List<Object?> get props => [id, username, name, role, centerId];
}

class PatientVitals extends Equatable {
  final double? bloodSugar;
  final int? systolicBP;
  final int? diastolicBP;
  final int? pulse;
  final int? spo2;
  final int? gcs;

  const PatientVitals({
    this.bloodSugar,
    this.systolicBP,
    this.diastolicBP,
    this.pulse,
    this.spo2,
    this.gcs,
  });

  @override
  List<Object?> get props => [bloodSugar, systolicBP, diastolicBP, pulse, spo2, gcs];
}

class Location extends Equatable {
  final String address;
  final String? floor;
  final String? room;
  final double? latitude;
  final double? longitude;

  const Location({
    required this.address,
    this.floor,
    this.room,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [address, floor, room, latitude, longitude];
}

class Emergency extends Equatable {
  final String id;
  final String callerName;
  final String callerPhone;
  final PatientVitals vitals;
  final String? medicalHistory;
  final TriageCode triageCode;
  final MedicalCondition condition;
  final Location location;
  final String? supervisingDoctor;
  final MissionStatus status;
  final DateTime createdAt;
  final String? assignedCenterId;
  final String? assignedTeamId;
  final List<MissionMilestone> milestones;
  final String? cancellationReason;

  const Emergency({
    required this.id,
    required this.callerName,
    required this.callerPhone,
    required this.vitals,
    this.medicalHistory,
    required this.triageCode,
    required this.condition,
    required this.location,
    this.supervisingDoctor,
    required this.status,
    required this.createdAt,
    this.assignedCenterId,
    this.assignedTeamId,
    this.milestones = const [],
    this.cancellationReason,
  });

  Emergency copyWith({
    String? id,
    String? callerName,
    String? callerPhone,
    PatientVitals? vitals,
    String? medicalHistory,
    TriageCode? triageCode,
    MedicalCondition? condition,
    Location? location,
    String? supervisingDoctor,
    MissionStatus? status,
    DateTime? createdAt,
    String? assignedCenterId,
    String? assignedTeamId,
    List<MissionMilestone>? milestones,
    String? cancellationReason,
  }) {
    return Emergency(
      id: id ?? this.id,
      callerName: callerName ?? this.callerName,
      callerPhone: callerPhone ?? this.callerPhone,
      vitals: vitals ?? this.vitals,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      triageCode: triageCode ?? this.triageCode,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      supervisingDoctor: supervisingDoctor ?? this.supervisingDoctor,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      assignedCenterId: assignedCenterId ?? this.assignedCenterId,
      assignedTeamId: assignedTeamId ?? this.assignedTeamId,
      milestones: milestones ?? this.milestones,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        callerName,
        callerPhone,
        vitals,
        medicalHistory,
        triageCode,
        condition,
        location,
        supervisingDoctor,
        status,
        createdAt,
        assignedCenterId,
        assignedTeamId,
        milestones,
        cancellationReason,
      ];
}

class MissionMilestone extends Equatable {
  final MissionStatus status;
  final DateTime timestamp;
  final String? hospitalName;
  final String? notes;

  const MissionMilestone({
    required this.status,
    required this.timestamp,
    this.hospitalName,
    this.notes,
  });

  @override
  List<Object?> get props => [status, timestamp, hospitalName, notes];
}

class Station extends Equatable {
  final String id;
  final String name;
  final Location location;
  final List<Team> teams;
  final double fuelLevel;

  const Station({
    required this.id,
    required this.name,
    required this.location,
    required this.teams,
    this.fuelLevel = 100.0,
  });

  @override
  List<Object?> get props => [id, name, location, teams, fuelLevel];
}

class Team extends Equatable {
  final String id;
  final String name;
  final String centerId;
  final List<Paramedic> members;
  final bool isAvailable;
  final double? currentLatitude;
  final double? currentLongitude;

  const Team({
    required this.id,
    required this.name,
    required this.centerId,
    required this.members,
    this.isAvailable = true,
    this.currentLatitude,
    this.currentLongitude,
  });

  @override
  List<Object?> get props => [id, name, centerId, members, isAvailable, currentLatitude, currentLongitude];
}

class Paramedic extends Equatable {
  final String id;
  final String name;
  final String? teamId;
  final int shiftsAttended;
  final int missionsCompleted;

  const Paramedic({
    required this.id,
    required this.name,
    this.teamId,
    this.shiftsAttended = 0,
    this.missionsCompleted = 0,
  });

  @override
  List<Object?> get props => [id, name, teamId, shiftsAttended, missionsCompleted];
}

class Shift extends Equatable {
  final String id;
  final DateTime date;
  final String shiftType; // morning, evening, night
  final Map<String, List<String>> centerTeamAssignments; // centerId -> list of paramedicIds

  const Shift({
    required this.id,
    required this.date,
    required this.shiftType,
    required this.centerTeamAssignments,
  });

  @override
  List<Object?> get props => [id, date, shiftType, centerTeamAssignments];
}
