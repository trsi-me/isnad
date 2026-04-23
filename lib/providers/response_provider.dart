import 'package:flutter/foundation.dart';

import '../core/database/database_helper.dart';
import '../core/enums/report_status.dart';
import '../core/utils/date_formatter.dart';
import '../models/response_model.dart';

class ResponseProvider extends ChangeNotifier {
  Future<bool> addResponse(ResponseModel response) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('responses', response.toMap()..remove('id'));
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('addResponse: $e');
      }
      return false;
    }
  }

  Future<bool> updateReportStatus(int reportId, String newStatus) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'reports',
        {
          'status': newStatus,
          'updated_at': DateFormatter.nowIso(),
        },
        where: 'id = ?',
        whereArgs: [reportId],
      );
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('updateReportStatus: $e');
      }
      return false;
    }
  }

  Future<List<ResponseModel>> getResponsesForReport(int reportId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'responses',
      where: 'report_id = ?',
      whereArgs: [reportId],
      orderBy: 'action_time ASC',
    );
    return rows.map(ResponseModel.fromMap).toList();
  }

  static String statusForAction(String actionType) {
    switch (actionType) {
      case 'received':
        return ReportStatus.received.value;
      case 'team_sent':
        return ReportStatus.responding.value;
      case 'arrived':
        return ReportStatus.arrived.value;
      case 'closed':
        return ReportStatus.closed.value;
      default:
        return ReportStatus.open.value;
    }
  }
}
