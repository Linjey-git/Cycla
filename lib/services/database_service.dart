import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cycle_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Збільшуємо версію для міграції
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE cycle_data (
        id $idType,
        last_period_start $textType,
        cycle_length $intType,
        period_length $intType
      )
    ''');

    await db.execute('''
      CREATE TABLE symptoms (
        id $idType,
        date $textType UNIQUE,
        symptoms TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id $idType,
        title $textType,
        description TEXT,
        time $textType,
        is_active INTEGER DEFAULT 1
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Видаляємо стару таблицю
      await db.execute('DROP TABLE IF EXISTS symptoms');

      // Створюємо нову з правильною схемою
      await db.execute('''
        CREATE TABLE symptoms (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT UNIQUE,
          symptoms TEXT,
          description TEXT
        )
      ''');
    }
  }

  // Цикл даних
  Future<Map<String, dynamic>?> getCycleData() async {
    final db = await instance.database;
    final results = await db.query('cycle_data', limit: 1);

    if (results.isEmpty) return null;

    final data = results.first;
    return {
      'lastPeriodStart': DateTime.parse(data['last_period_start'] as String),
      'cycleLength': data['cycle_length'] as int,
      'periodLength': data['period_length'] as int,
    };
  }

  Future<void> saveCycleData(
    DateTime lastPeriodStart,
    int cycleLength,
    int periodLength,
  ) async {
    final db = await instance.database;

    final existing = await db.query('cycle_data');
    final data = {
      'last_period_start': lastPeriodStart.toIso8601String(),
      'cycle_length': cycleLength,
      'period_length': periodLength,
    };

    if (existing.isEmpty) {
      await db.insert('cycle_data', data);
    } else {
      await db.update('cycle_data', data, where: 'id = ?', whereArgs: [1]);
    }
  }

  // Симптоми
  Future<void> saveSymptom(
    DateTime date,
    List<String> symptoms,
    String description,
  ) async {
    final db = await instance.database;
    final dateStr = date.toIso8601String().split('T')[0];

    final data = {
      'date': dateStr,
      'symptoms': symptoms.join(','),
      'description': description,
    };

    final existing = await db.query(
      'symptoms',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (existing.isNotEmpty) {
      await db.update(
        'symptoms',
        data,
        where: 'date = ?',
        whereArgs: [dateStr],
      );
    } else {
      await db.insert('symptoms', data);
    }
  }

  Future<Map<DateTime, List<String>>> getAllSymptoms() async {
    final db = await instance.database;
    final results = await db.query('symptoms');

    Map<DateTime, List<String>> symptoms = {};
    for (var row in results) {
      final date = DateTime.parse(row['date'] as String);
      final symptomsStr = row['symptoms'] as String? ?? '';
      final symptomsList = symptomsStr.isNotEmpty
          ? symptomsStr.split(',')
          : <String>[];

      symptoms[date] = symptomsList;
    }

    return symptoms;
  }

  Future<List<String>> getSymptomsForDate(DateTime date) async {
    final db = await instance.database;
    final dateStr = date.toIso8601String().split('T')[0];

    final results = await db.query(
      'symptoms',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (results.isEmpty) return [];

    final symptomsStr = results.first['symptoms'] as String? ?? '';
    return symptomsStr.isNotEmpty ? symptomsStr.split(',') : <String>[];
  }

  Future<String> getSymptomDescription(DateTime date) async {
    final db = await instance.database;
    final dateStr = date.toIso8601String().split('T')[0];

    final results = await db.query(
      'symptoms',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (results.isEmpty) return '';

    return results.first['description'] as String? ?? '';
  }

  Future<void> deleteSymptom(DateTime date) async {
    final db = await instance.database;
    final dateStr = date.toIso8601String().split('T')[0];

    await db.delete('symptoms', where: 'date = ?', whereArgs: [dateStr]);
  }

  // Нагадування
  Future<int> saveReminder(Map<String, dynamic> reminder) async {
    final db = await instance.database;
    return await db.insert('reminders', reminder);
  }

  Future<List<Map<String, dynamic>>> getAllReminders() async {
    final db = await instance.database;
    return await db.query('reminders', orderBy: 'time ASC');
  }

  Future<void> updateReminder(int id, Map<String, dynamic> reminder) async {
    final db = await instance.database;
    await db.update('reminders', reminder, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteReminder(int id) async {
    final db = await instance.database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
