import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:learning/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);

    //make sure owner exists in the database with the correct id;
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';

    //create a note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      noteColumn: text,
    });

    final note = DatabaseNote(id: noteId, userId: owner.id, note: text);

    return note;
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount =
        await db.delete(noteTable, where: 'id=?', whereArgs: [id]);

    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes =await db.query(
      noteTable,
      where: 'id=?',
      whereArgs: [id],
    );
    
    if(notes.isEmpty){
      throw CouldNotFindNote();
    }
    else{
      return DatabaseNote.fromRow(notes.first);
    }
  }


  Future<Iterable<DatabaseNote>> getAllNote() async {
    final db = _getDatabaseOrThrow();
    final notes =await db.query(noteTable);

    final result=notes.map((notesRow) => DatabaseNote.fromRow(notesRow));

    return result;
  }

  Future<DatabaseNote> updateNote({required DatabaseNote note,required String text}) async {
    final db=_getDatabaseOrThrow();

    await getNote(id: note.id);

    final updatedCount=await db.update(noteTable, {
      noteColumn:text,
    });

    if(updatedCount==0){
      throw CouldNotUpdateNote();
    }
    else{
      return await getNote(id: note.id);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteTheUserException();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      //create userTable
      await db.execute(createUserTable);

      //create noteTable
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person Id = $id, Email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String note;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.note,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        note = map[noteColumn] as String;

  @override
  String toString() => 'Note, Id = $id, UserId = $userId ';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

//All constants
const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const noteColumn = 'note';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
                                "email"	TEXT NOT NULL UNIQUE,
                                "id"	INTEGER NOT NULL,
                                PRIMARY KEY("id" AUTOINCREMENT),
                                );
      ''';
const createNoteTable = '''CREATE TABLE "notes" (
                        "id"	INTEGER NOT NULL,
                        "user_id"	INTEGER NOT NULL,
                        "note"	TEXT,
                        PRIMARY KEY("id" AUTOINCREMENT),
                        FOREIGN KEY("user_id") REFERENCES "user"("id")
                      ); 
      ''';
