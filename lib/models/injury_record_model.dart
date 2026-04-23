class InjuryRecordModel {
  const InjuryRecordModel({
    this.id,
    required this.reportId,
    required this.militaryId,
    required this.injurySummary,
    this.hospitalName,
    this.medicalReport,
    this.treatmentDetails,
    this.doctorName,
    this.admissionDate,
    this.dischargeDate,
    required this.legalStatus,
    required this.createdAt,
  });

  final int? id;
  final int reportId;
  final String militaryId;
  final String injurySummary;
  final String? hospitalName;
  final String? medicalReport;
  final String? treatmentDetails;
  final String? doctorName;
  final String? admissionDate;
  final String? dischargeDate;
  final String legalStatus;
  final String createdAt;

  InjuryRecordModel copyWith({
    int? id,
    int? reportId,
    String? militaryId,
    String? injurySummary,
    String? hospitalName,
    String? medicalReport,
    String? treatmentDetails,
    String? doctorName,
    String? admissionDate,
    String? dischargeDate,
    String? legalStatus,
    String? createdAt,
  }) {
    return InjuryRecordModel(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      militaryId: militaryId ?? this.militaryId,
      injurySummary: injurySummary ?? this.injurySummary,
      hospitalName: hospitalName ?? this.hospitalName,
      medicalReport: medicalReport ?? this.medicalReport,
      treatmentDetails: treatmentDetails ?? this.treatmentDetails,
      doctorName: doctorName ?? this.doctorName,
      admissionDate: admissionDate ?? this.admissionDate,
      dischargeDate: dischargeDate ?? this.dischargeDate,
      legalStatus: legalStatus ?? this.legalStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'report_id': reportId,
      'military_id': militaryId,
      'injury_summary': injurySummary,
      'hospital_name': hospitalName,
      'medical_report': medicalReport,
      'treatment_details': treatmentDetails,
      'doctor_name': doctorName,
      'admission_date': admissionDate,
      'discharge_date': dischargeDate,
      'legal_status': legalStatus,
      'created_at': createdAt,
    };
  }

  static InjuryRecordModel fromMap(Map<String, Object?> map) {
    return InjuryRecordModel(
      id: map['id'] as int?,
      reportId: map['report_id'] as int,
      militaryId: map['military_id'] as String,
      injurySummary: map['injury_summary'] as String,
      hospitalName: map['hospital_name'] as String?,
      medicalReport: map['medical_report'] as String?,
      treatmentDetails: map['treatment_details'] as String?,
      doctorName: map['doctor_name'] as String?,
      admissionDate: map['admission_date'] as String?,
      dischargeDate: map['discharge_date'] as String?,
      legalStatus: map['legal_status'] as String? ?? 'pending',
      createdAt: map['created_at'] as String,
    );
  }
}
