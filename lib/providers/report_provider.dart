import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/database/database_helper.dart';
import '../core/enums/injury_type.dart';
import '../core/enums/report_status.dart';
import '../core/services/notification_service.dart';
import '../core/utils/date_formatter.dart';
import '../models/report_model.dart';

class ReportProvider extends ChangeNotifier {
  List<ReportModel> _reports = [];
  bool _isLoading = false;
  String? _filterMilitaryId;

  List<ReportModel> get reports => List.unmodifiable(_reports);
  List<ReportModel> get activeReports =>
      _reports.where((r) => r.status != ReportStatus.closed.value).toList();
  bool get isLoading => _isLoading;

  Future<void> loadReports({String? militaryId}) async {
    _isLoading = true;
    _filterMilitaryId = militaryId;
    notifyListeners();
    try {
      final db = await DatabaseHelper.instance.database;
      List<Map<String, Object?>> rows;
      if (militaryId != null && militaryId.isNotEmpty) {
        rows = await db.query(
          'reports',
          where: 'military_id = ?',
          whereArgs: [militaryId],
          orderBy: 'created_at DESC',
        );
      } else {
        rows = await db.query('reports', orderBy: 'created_at DESC');
      }
      _reports = rows.map(ReportModel.fromMap).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReport(ReportModel report) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final connected = await _hasConnection();
      final toSave = report.copyWith(
        isSynced: connected,
        updatedAt: DateFormatter.nowIso(),
      );
      final id = await db.insert('reports', toSave.toMap()..remove('id'));
      final inserted = toSave.copyWith(id: id);
      _reports = [inserted, ..._reports];
      if (connected) {
        await NotificationService.showNewReportAlert(
          reportId: inserted.reportUuid,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('createReport: $e');
      }
      return false;
    }
  }

  Future<bool> createSOSReport({
    required String militaryId,
    required String name,
    double? lat,
    double? lng,
  }) async {
    final uuid = const Uuid().v4();
    final now = DateFormatter.nowIso();
    final connected = await _hasConnection();
    final report = ReportModel(
      reportUuid: uuid,
      militaryId: militaryId,
      reporterName: name,
      injuryType: InjuryType.other.value,
      injuryDescription: 'بلاغ طوارئ',
      locationLat: lat,
      locationLng: lng,
      locationName: null,
      mediaPath: null,
      status: ReportStatus.open.value,
      isSos: true,
      isSynced: connected,
      createdAt: now,
      updatedAt: now,
    );
    return createReport(report);
  }

  Future<void> refreshReports() async {
    await loadReports(militaryId: _filterMilitaryId);
  }

  Future<ReportModel?> getReportById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ReportModel.fromMap(rows.first);
  }

  Future<void> updateReport(ReportModel r) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'reports',
      r.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [r.id],
    );
    final idx = _reports.indexWhere((e) => e.id == r.id);
    if (idx >= 0) {
      _reports[idx] = r;
    }
    notifyListeners();
  }

  static Future<bool> _hasConnection() async {
    final r = await Connectivity().checkConnectivity();
    if (r.isEmpty) return false;
    return r.any((e) => e != ConnectivityResult.none);
  }
}
