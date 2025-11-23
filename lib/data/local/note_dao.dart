import 'app_database.dart';

class NoteDao {
  Future<int> insertNote(Map<String, Object?> note) async {
    final db = await AppDatabase.instance.database;
    return db.insert('notes', note);
  }

  Future<List<Map<String, Object?>>> getAllNotes() async {
    final db = await AppDatabase.instance.database;
    return db.query('notes', orderBy: 'createdAt DESC');
  }

  Future<int> updateNote(int id, Map<String, Object?> note) async {
    final db = await AppDatabase.instance.database;
    return db.update('notes', note, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteNote(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}


