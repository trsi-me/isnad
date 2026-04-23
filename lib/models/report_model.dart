import '../core/enums/injury_type.dart';
import '../core/enums/report_status.dart';

class ReportModel {
  const ReportModel({
    this.id,
    required this.reportUuid,
    required this.militaryId,
    required this.reporterName,
    required this.injuryType,
    this.injuryDescription,
    this.locationLat,
    this.locationLng,
    this.locationName,
    this.mediaPath,
    required this.status,
    required this.isSos,
    required this.isSynced,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String reportUuid;
  final String militaryId;
  final String reporterName;
  final String injuryType;
  final String? injuryDescription;
  final double? locationLat;
  final double? locationLng;
  final String? locationName;
  final String? mediaPath;
  final String status;
  final bool isSos;
  final bool isSynced;
  final String createdAt;
  final String updatedAt;

  ReportModel copyWith({
    int? id,
    String? reportUuid,
    String? militaryId,
    String? reporterName,
    String? injuryType,
    String? injuryDescription,
    double? locationLat,
    double? locationLng,
    String? locationName,
    String? mediaPath,
    String? status,
    bool? isSos,
    bool? isSynced,
    String? createdAt,
    String? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reportUuid: reportUuid ?? this.reportUuid,
      militaryId: militaryId ?? this.militaryId,
      reporterName: reporterName ?? this.reporterName,
      injuryType: injuryType ?? this.injuryType,
      injuryDescription: injuryDescription ?? this.injuryDescription,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      locationName: locationName ?? this.locationName,
      mediaPath: mediaPath ?? this.mediaPath,
      status: status ?? this.status,
      isSos: isSos ?? this.isSos,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'report_uuid': reportUuid,
      'military_id': militaryId,
      'reporter_name': reporterName,
      'injury_type': injuryType,
      'injury_description': injuryDescription,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'location_name': locationName,
      'media_path': mediaPath,
      'status': status,
      'is_sos': isSos ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static ReportModel fromMap(Map<String, Object?> map) {
    final inj = map['injury_type'] as String;
    if (injuryTypeFromString(inj) == null) {
      throw ArgumentError('Invalid injury type: $inj');
    }
    final st = map['status'] as String? ?? 'open';
    if (reportStatusFromString(st) == null) {
      throw ArgumentError('Invalid status: $st');
    }
    return ReportModel(
      id: map['id'] as int?,
      reportUuid: map['report_uuid'] as String,
      militaryId: map['military_id'] as String,
      reporterName: map['reporter_name'] as String,
      injuryType: inj,
      injuryDescription: map['injury_description'] as String?,
      locationLat: (map['location_lat'] as num?)?.toDouble(),
      locationLng: (map['location_lng'] as num?)?.toDouble(),
      locationName: map['location_name'] as String?,
      mediaPath: map['media_path'] as String?,
      status: st,
      isSos: (map['is_sos'] as int? ?? 0) != 0,
      isSynced: (map['is_synced'] as int? ?? 0) != 0,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}
