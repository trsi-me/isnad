import 'package:connectivity_plus/connectivity_plus.dart';

import '../../models/report_model.dart';
import '../database/database_helper.dart';
import '../utils/date_formatter.dart';

class SyncService {
  SyncService._();

  static final Connectivity _connectivity = Connectivity();

  static Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((r) {
      if (r.isEmpty) return false;
      return r.any((e) => e != ConnectivityResult.none);
    });
  }

  static Future<void> syncPendingReports() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'reports',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    for (final m in rows) {
      final r = ReportModel.fromMap(m);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final now = DateFormatter.nowIso();
      await db.update(
        'reports',
        {
          'is_synced': 1,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [r.id],
      );
    }
  }
}
