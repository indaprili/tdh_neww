import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'todo_item.dart';

class TodoDatabase {
  TodoDatabase._privateConstructor();
  static final TodoDatabase instance = TodoDatabase._privateConstructor();

  static const _dbName = 'todo_app.db';
  static const _dbVersion = 2;
  static const _tableName = 'todo_items';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        chip TEXT NOT NULL,
        dueDate TEXT NOT NULL,   -- disimpan sebagai ISO String
        done INTEGER NOT NULL,   -- 0 / 1
        chipColor INTEGER NOT NULL, -- Color.value
        isHabit INTEGER NOT NULL    -- 0 / 1
      )
    ''');
  }

  Future<int> insertItem(TodoItem item) async {
    final db = await database;
    return await db.insert(
      _tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TodoItem>> getAllItems() async {
    final db = await database;
    final result = await db.query(
      _tableName,
      orderBy: 'dueDate ASC',
    );
    return result.map((row) => TodoItem.fromMap(row)).toList();
  }

  Future<int> updateItem(TodoItem item) async {
    final db = await database;
    if (item.id == null) {
      throw ArgumentError('updateItem: item.id is null');
    }
    return await db.update(
      _tableName,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
