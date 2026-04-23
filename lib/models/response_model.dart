class ResponseModel {
  const ResponseModel({
    this.id,
    required this.reportId,
    required this.responderId,
    required this.responderName,
    required this.actionType,
    this.notes,
    required this.actionTime,
  });

  final int? id;
  final int reportId;
  final String responderId;
  final String responderName;
  final String actionType;
  final String? notes;
  final String actionTime;

  ResponseModel copyWith({
    int? id,
    int? reportId,
    String? responderId,
    String? responderName,
    String? actionType,
    String? notes,
    String? actionTime,
  }) {
    return ResponseModel(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      responderId: responderId ?? this.responderId,
      responderName: responderName ?? this.responderName,
      actionType: actionType ?? this.actionType,
      notes: notes ?? this.notes,
      actionTime: actionTime ?? this.actionTime,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'report_id': reportId,
      'responder_id': responderId,
      'responder_name': responderName,
      'action_type': actionType,
      'notes': notes,
      'action_time': actionTime,
    };
  }

  static ResponseModel fromMap(Map<String, Object?> map) {
    return ResponseModel(
      id: map['id'] as int?,
      reportId: map['report_id'] as int,
      responderId: map['responder_id'] as String,
      responderName: map['responder_name'] as String,
      actionType: map['action_type'] as String,
      notes: map['notes'] as String?,
      actionTime: map['action_time'] as String,
    );
  }
}
