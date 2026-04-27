import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/models.dart';

// Events
abstract class DispatcherEvent extends Equatable {
  const DispatcherEvent();

  @override
  List<Object?> get props => [];
}

class CreateEmergency extends DispatcherEvent {
  final String callerName;
  final String callerPhone;
  final PatientVitals vitals;
  final String? medicalHistory;
  final TriageCode triageCode;
  final MedicalCondition condition;
  final Location location;
  final String? supervisingDoctor;

  const CreateEmergency({
    required this.callerName,
    required this.callerPhone,
    required this.vitals,
    this.medicalHistory,
    required this.triageCode,
    required this.condition,
    required this.location,
    this.supervisingDoctor,
  });

  @override
  List<Object?> get props => [
        callerName,
        callerPhone,
        vitals,
        medicalHistory,
        triageCode,
        condition,
        location,
        supervisingDoctor,
      ];
}

class LoadEmergencies extends DispatcherEvent {}

// States
abstract class DispatcherState extends Equatable {
  const DispatcherState();

  @override
  List<Object?> get props => [];
}

class DispatcherInitial extends DispatcherState {}

class DispatcherLoading extends DispatcherState {}

class DispatcherLoaded extends DispatcherState {
  final List<Emergency> emergencies;

  const DispatcherLoaded(this.emergencies);

  @override
  List<Object?> get props => [emergencies];
}

class EmergencyCreated extends DispatcherState {
  final Emergency emergency;

  const EmergencyCreated(this.emergency);

  @override
  List<Object?> get props => [emergency];
}

class DispatcherError extends DispatcherState {
  final String message;

  const DispatcherError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class DispatcherBloc extends Bloc<DispatcherEvent, DispatcherState> {
  final List<Emergency> _emergencies = [];
  final _uuid = const Uuid();

  DispatcherBloc() : super(DispatcherInitial()) {
    on<CreateEmergency>(_onCreateEmergency);
    on<LoadEmergencies>(_onLoadEmergencies);
  }

  List<Emergency> get emergencies => List.unmodifiable(_emergencies);

  Future<void> _onCreateEmergency(
    CreateEmergency event,
    Emitter<DispatcherState> emit,
  ) async {
    emit(DispatcherLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final emergency = Emergency(
        id: _uuid.v4(),
        callerName: event.callerName,
        callerPhone: event.callerPhone,
        vitals: event.vitals,
        medicalHistory: event.medicalHistory,
        triageCode: event.triageCode,
        condition: event.condition,
        location: event.location,
        supervisingDoctor: event.supervisingDoctor,
        status: MissionStatus.waiting,
        createdAt: DateTime.now(),
      );

      _emergencies.insert(0, emergency);
      emit(EmergencyCreated(emergency));
    } catch (e) {
      emit(DispatcherError('Failed to create emergency: ${e.toString()}'));
    }
  }

  Future<void> _onLoadEmergencies(
    LoadEmergencies event,
    Emitter<DispatcherState> emit,
  ) async {
    emit(DispatcherLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(DispatcherLoaded(_emergencies));
  }
}
