import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  Future<void> _onCreate(Database db, int version) async {  //runs only when first created
    await db.execute('''
    id TEXT PRIMARY KEY,
    amount REAL NOT NULL,
    category TEXT NOT NULL,
    note TEXT,
    date TEXT NOT NULL,
    isIncome INTEGER NOT NULL,
    isSafing INTEGER NOT NULL     
    ''');
    //Add all of the table creations (first time) SQL above ^
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    //for future migrations
    if (oldV < newV) {
      //example migration
      // await db.execute('ALTER TABLE notes ADD COLUMN newColumn TEXT');
    }
  }
}


