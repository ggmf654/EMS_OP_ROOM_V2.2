// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_import, unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/holographic_container.dart';
import '../../../../core/widgets/patient_vital_input.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../bloc/dispatcher_bloc.dart';

class DispatcherScreen extends StatefulWidget {
  const DispatcherScreen({super.key});

  @override
  State<DispatcherScreen> createState() => _DispatcherScreenState();
}

class _DispatcherScreenState extends State<DispatcherScreen> {
  final _formKey = GlobalKey<FormState>();

  // Caller Info
  final _callerNameController = TextEditingController();
  final _callerPhoneController = TextEditingController();

  // Patient Info
  final _patientAgeController = TextEditingController();
  final _patientWeightController = TextEditingController();

  // Patient Vitals
  final _bloodSugarController = TextEditingController();
  final _systolicBPController = TextEditingController();
  final _diastolicBPController = TextEditingController();
  final _pulseController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _gcsController = TextEditingController();

  // Medical Info
  final _medicalHistoryController = TextEditingController();
  final _supervisingDoctorController = TextEditingController();
  final _notesController = TextEditingController();

  // Location
  final _addressController = TextEditingController();
  final _floorController = TextEditingController();
  final _roomController = TextEditingController();

  // Destination Hospital
  final _hospitalNameController = TextEditingController();
  final _hospitalDoctorController = TextEditingController();
  final _hospitalPhoneController = TextEditingController();
  final _hospitalFloorController = TextEditingController();

  // Selection
  TriageCode _selectedTriageCode = TriageCode.yellow;
  MedicalCondition _selectedCondition = MedicalCondition.other;

  @override
  void dispose() {
    _callerNameController.dispose();
    _callerPhoneController.dispose();
    _patientAgeController.dispose();
    _patientWeightController.dispose();
    _bloodSugarController.dispose();
    _systolicBPController.dispose();
    _diastolicBPController.dispose();
    _pulseController.dispose();
    _spo2Controller.dispose();
    _gcsController.dispose();
    _medicalHistoryController.dispose();
    _supervisingDoctorController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    _floorController.dispose();
    _roomController.dispose();
    _hospitalNameController.dispose();
    _hospitalDoctorController.dispose();
    _hospitalPhoneController.dispose();
    _hospitalFloorController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final vitals = PatientVitals(
        bloodSugar: double.tryParse(_bloodSugarController.text),
        systolicBP: int.tryParse(_systolicBPController.text),
        diastolicBP: int.tryParse(_diastolicBPController.text),
        pulse: int.tryParse(_pulseController.text),
        spo2: int.tryParse(_spo2Controller.text),
        gcs: int.tryParse(_gcsController.text),
      );

      final location = Location(
        address: _addressController.text,
        floor: _floorController.text.isEmpty ? null : _floorController.text,
        room: _roomController.text.isEmpty ? null : _roomController.text,
      );

      context.read<DispatcherBloc>().add(
            CreateEmergency(
              callerName: _callerNameController.text,
              callerPhone: _callerPhoneController.text,
              vitals: vitals,
              medicalHistory: _medicalHistoryController.text.isEmpty
                  ? null
                  : _medicalHistoryController.text,
              triageCode: _selectedTriageCode,
              condition: _selectedCondition,
              location: location,
              supervisingDoctor: _supervisingDoctorController.text.isEmpty
                  ? null
                  : _supervisingDoctorController.text,
            ),
          );
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _callerNameController.clear();
    _callerPhoneController.clear();
    _patientAgeController.clear();
    _patientWeightController.clear();
    _bloodSugarController.clear();
    _systolicBPController.clear();
    _diastolicBPController.clear();
    _pulseController.clear();
    _spo2Controller.clear();
    _gcsController.clear();
    _medicalHistoryController.clear();
    _supervisingDoctorController.clear();
    _notesController.clear();
    _addressController.clear();
    _floorController.clear();
    _roomController.clear();
    _hospitalNameController.clear();
    _hospitalDoctorController.clear();
    _hospitalPhoneController.clear();
    _hospitalFloorController.clear();
    setState(() {
      _selectedTriageCode = TriageCode.yellow;
      _selectedCondition = MedicalCondition.other;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<DispatcherBloc, DispatcherState>(
      listener: (context, state) {
        if (state is EmergencyCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Emergency created - Status: Waiting'),
                ],
              ),
              backgroundColor: AppColors.triageGreen,
            ),
          );
          _clearForm();
        } else if (state is DispatcherError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.triageRed,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Emergency Dispatch'),
          actions: [
            TextButton.icon(
              onPressed: _clearForm,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear'),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Triage Code Selection
                _buildSectionTitle(context, 'Triage Code', Icons.warning),
                const SizedBox(height: 12),
                _buildTriageCodeSelector(),
                const SizedBox(height: 24),

                // Caller Information
                _buildSectionTitle(context, 'Caller Information', Icons.phone),
                const SizedBox(height: 12),
                GlassmorphicCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _callerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Caller Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _callerPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                // Patient Information
                _buildSectionTitle(context, 'Patient Information', Icons.person),
                const SizedBox(height: 12),
                GlassmorphicCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _patientAgeController,
                              decoration: const InputDecoration(
                                labelText: 'Age',
                                prefixIcon: Icon(Icons.cake),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _patientWeightController,
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                prefixIcon: Icon(Icons.monitor_weight),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Patient Vitals
                _buildSectionTitle(
                    context, 'Patient Vitals', Icons.monitor_heart),
                const SizedBox(height: 12),
                GlassmorphicCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: PatientVitalInput(
                              label: 'Blood Sugar',
                              unit: 'mg/dL',
                              controller: _bloodSugarController,
                              icon: Icons.bloodtype,
                              min: 20,
                              max: 600,
                              isDecimal: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PatientVitalInput(
                              label: 'Pulse',
                              unit: 'bpm',
                              controller: _pulseController,
                              icon: Icons.favorite,
                              min: 20,
                              max: 250,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      BloodPressureInput(
                        systolicController: _systolicBPController,
                        diastolicController: _diastolicBPController,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: PatientVitalInput(
                              label: 'SPO2',
                              unit: '%',
                              controller: _spo2Controller,
                              icon: Icons.air,
                              min: 0,
                              max: 100,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PatientVitalInput(
                              label: 'GCS',
                              unit: '3-15',
                              controller: _gcsController,
                              icon: Icons.psychology,
                              min: 3,
                              max: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Medical Condition
                _buildSectionTitle(
                    context, 'Medical Condition', Icons.medical_information),
                const SizedBox(height: 12),
                GlassmorphicCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<MedicalCondition>(
                        value: _selectedCondition,
                        decoration: const InputDecoration(
                          labelText: 'Primary Condition',
                          prefixIcon: Icon(Icons.local_hospital),
                        ),
                        items: MedicalCondition.values.map((condition) {
                          return DropdownMenuItem(
                            value: condition,
                            child: Text(_getConditionName(condition)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCondition = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _medicalHistoryController,
                        decoration: const InputDecoration(
                          labelText: 'Medical History',
                          prefixIcon: Icon(Icons.history),
                          hintText: 'Previous conditions, allergies, etc.',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _supervisingDoctorController,
                        decoration: const InputDecoration(
                          labelText: 'Supervising Doctor',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          prefixIcon: Icon(Icons.note),
                          hintText: 'Additional observations...',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Location
                _buildSectionTitle(context, 'Location Details', Icons.location_on),
                const SizedBox(height: 12),
                GlassmorphicCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.home),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _floorController,
                              decoration: const InputDecoration(
                                labelText: 'Floor',
                                prefixIcon: Icon(Icons.layers),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _roomController,
                              decoration: const InputDecoration(
                                labelText: 'Room/Apartment',
                                prefixIcon: Icon(Icons.meeting_room),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Destination Hospital
                _buildSectionTitle(context, 'Destination Hospital', Icons.local_hospital),
                const SizedBox(height: 12),
                GlassmorphicCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _hospitalNameController,
                        decoration: const InputDecoration(
                          labelText: 'Hospital Name',
                          prefixIcon: Icon(Icons.business),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _hospitalDoctorController,
                              decoration: const InputDecoration(
                                labelText: 'Doctor Name',
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _hospitalPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _hospitalFloorController,
                        decoration: const InputDecoration(
                          labelText: 'Floor/Ward',
                          prefixIcon: Icon(Icons.layers),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                BlocBuilder<DispatcherBloc, DispatcherState>(
                  builder: (context, state) {
                    final isLoading = state is DispatcherLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.send),
                                  SizedBox(width: 8),
                                  Text(
                                    'Create Emergency',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryRed,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildTriageCodeSelector() {
    return Row(
      children: TriageCode.values.map((code) {
        final isSelected = _selectedTriageCode == code;
        final color = code == TriageCode.red
            ? AppColors.triageRed
            : code == TriageCode.yellow
                ? AppColors.triageYellow
                : AppColors.triageGreen;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: code != TriageCode.green ? 12 : 0,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedTriageCode = code;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.circle,
                        color: isSelected ? Colors.white : color,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        code.name.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
        return 'Diabetic Emergency';
      case MedicalCondition.allergic:
        return 'Allergic Reaction';
      case MedicalCondition.obstetric:
        return 'Obstetric';
      case MedicalCondition.psychiatric:
        return 'Psychiatric';
      case MedicalCondition.other:
        return 'Other';
    }
  }
}
