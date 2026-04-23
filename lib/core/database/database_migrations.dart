import 'package:sqflite/sqflite.dart';

class DatabaseMigrations {
  DatabaseMigrations._();

  static const int currentVersion = 1;

  static Future<void> onCreate(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await _createV1(db);
  }

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('PRAGMA foreign_keys = ON');
    if (oldVersion < 1) {
      await _createV1(db);
    }
  }

  static Future<void> _createV1(Database db) async {
    await db.execute('''
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  military_id TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL,
  unit TEXT,
  phone TEXT,
  password_hash TEXT NOT NULL,
  created_at TEXT NOT NULL,
  last_active TEXT
);
''');
    await db.execute('''
CREATE TABLE reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  report_uuid TEXT UNIQUE NOT NULL,
  military_id TEXT NOT NULL,
  reporter_name TEXT NOT NULL,
  injury_type TEXT NOT NULL,
  injury_description TEXT,
  location_lat REAL,
  location_lng REAL,
  location_name TEXT,
  media_path TEXT,
  status TEXT NOT NULL DEFAULT 'open',
  is_sos INTEGER NOT NULL DEFAULT 0,
  is_synced INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
''');
    await db.execute('''
CREATE TABLE responses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  report_id INTEGER NOT NULL,
  responder_id TEXT NOT NULL,
  responder_name TEXT NOT NULL,
  action_type TEXT NOT NULL,
  notes TEXT,
  action_time TEXT NOT NULL,
  FOREIGN KEY (report_id) REFERENCES reports(id)
);
''');
    await db.execute('''
CREATE TABLE injury_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  report_id INTEGER NOT NULL UNIQUE,
  military_id TEXT NOT NULL,
  injury_summary TEXT NOT NULL,
  hospital_name TEXT,
  medical_report TEXT,
  treatment_details TEXT,
  doctor_name TEXT,
  admission_date TEXT,
  discharge_date TEXT,
  legal_status TEXT DEFAULT 'pending',
  created_at TEXT NOT NULL,
  FOREIGN KEY (report_id) REFERENCES reports(id)
);
''');
  }
}
