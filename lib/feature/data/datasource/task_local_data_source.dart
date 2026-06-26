import 'package:flutter_hackathon/feature/domain/entities/task_item.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class TaskLocalDataSource {
  static const String _databaseName = 'student_task_manager.db';
  static const String _tableName = 'tasks';

  Database? _database;

  Future<Database> get _db async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, _databaseName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            deadline TEXT NOT NULL,
            status INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );

    return _database!;
  }

  Future<List<TaskItem>> getTasks() async {
    final db = await _db;
    final rows = await db.query(_tableName, orderBy: 'deadline ASC, id DESC');

    return rows.map(TaskItem.fromMap).toList();
  }
}
