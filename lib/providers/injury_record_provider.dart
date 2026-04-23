import 'package:flutter/foundation.dart';

import '../core/database/database_helper.dart';
import '../core/enums/injury_type.dart';
import '../models/injury_record_model.dart';

class InjuryRecordView {
  InjuryRecordView({required this.record, required this.injuryTypeKey});

  final InjuryRecordModel record;
  final String injuryTypeKey;
}

class InjuryRecordProvider extends ChangeNotifier {
  List<InjuryRecordView> _views = [];

  List<InjuryRecordView> get recordViews => List.unmodifiable(_views);

  List<InjuryRecordModel> get records =>
      _views.map((e) => e.record).toList();

  Future<void> loadRecordsForUser(String militaryId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery(
      '''
SELECT ir.*, r.injury_type AS inj_t FROM injury_records ir
INNER JOIN reports r ON r.id = ir.report_id
WHERE ir.military_id = ? AND r.status = ?
ORDER BY ir.created_at DESC
''',
      [militaryId, 'closed'],
    );
    _views = rows.map((row) {
      final m = Map<String, Object?>.from(row);
      final injKey = m.remove('inj_t') as String? ?? 'other';
      final rec = InjuryRecordModel.fromMap(m);
      return InjuryRecordView(record: rec, injuryTypeKey: injKey);
    }).toList();
    notifyListeners();
  }

  Future<bool> createInjuryRecord(InjuryRecordModel record) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('injury_records', record.toMap()..remove('id'));
      await loadRecordsForUser(record.militaryId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('createInjuryRecord: $e');
      }
      return false;
    }
  }

  Future<InjuryRecordModel?> getRecordByReportId(int reportId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'injury_records',
      where: 'report_id = ?',
      whereArgs: [reportId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return InjuryRecordModel.fromMap(rows.first);
  }

  static String injuryLabel(String key) {
    return injuryTypeFromString(key)?.displayName ?? key;
  }
}
