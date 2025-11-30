import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // for databaseFactory in tests
import 'package:flutter/foundation.dart'; // for test visibility (dont use in prod)

class AppDatabase {
  AppDatabase._();  //private connection
  static final AppDatabase instance = AppDatabase._(); //singleton 

  static const _dbName = 'app.db';
  static const _dbVersion = 1;

  Database? _db;  //holds the connection itself

  Future<Database> get database async {  //lazy getter to make sure it opens only once
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase( //connection call
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async { //runs only when first created
    await db.execute('''
    CREATE TABLE payments (
      id TEXT PRIMARY KEY,
      amount REAL NOT NULL,
      category TEXT NOT NULL,
      note TEXT,
      date TEXT NOT NULL,
      isIncome INTEGER NOT NULL,
      isSaving INTEGER NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE monthly_goals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      year INTEGER NOT NULL,
      month INTEGER NOT NULL,
      target_amount REAL NOT NULL
    )
  ''');
    //Add all of the table creations (first time) SQL above ^
  }

  // Test exclusive DB init for unit tests.
  @visibleForTesting
  Future<void> initForTest({bool inMemory = true}) async {
    _db = await databaseFactory.openDatabase(
      inMemory ? inMemoryDatabasePath : 'app_test.db',
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  // close function to avoid brittle tests
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    //for future migrations
    if (oldV < newV) {
      //example migration
      // await db.execute('ALTER TABLE notes ADD COLUMN newColumn TEXT');
    }
  }
}


