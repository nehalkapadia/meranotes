import 'package:flutter/foundation.dart';
import 'package:meranotes/services/crud/crud_exceptions.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

class NotesService {
  Database? _db;

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    // check if the owner exists
    final ownerExists = await getUser(email: owner.email);
    if (ownerExists != owner) {
      throw NoNotesException();
    }

    const text = '';

    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedColumn: 1,
    });

    return DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSynced: true,
    );
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final deleteCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deleteCount != 1) {
      throw NoteCannotBeDeletedException();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();

    return await db.delete(notesTable);
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final note = await db.query(
      notesTable,
      limit: 1,
      where: 'id=?',
      whereArgs: [id],
    );

    if (note.isEmpty) {
      throw NoNotesException();
    }

    return DatabaseNote.fromRow(note.first);
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();

    final notes = await db.query(notesTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updatedNote = db.update(notesTable, {
      textColumn: text,
      isSyncedColumn: 0,
    });

    if (updatedNote == 0) {
      throw CouldNoteUpdateNote();
    }

    return await getNote(id: note.id);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final users = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (users.isEmpty) {
      throw NoUsersException();
    }

    return DatabaseUser.fromRow(users.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final userExists = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (userExists.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    final userId = await db.insert(
      userTable,
      {emailColumn: email.toLowerCase()},
    );

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final deleteCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deleteCount != 1) {
      throw UserCannotBeDeletedException();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    }
    return db;
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    }

    await db.close();
    _db = null;
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final documentPath = await getApplicationDocumentsDirectory();
      final dbPath = join(documentPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // creates user table
      await db.execute(createUserTable);

      // create notes table
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryException();
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
  String toString() => 'Person id: $id, email: $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSynced;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSynced,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSynced = (map[isSyncedColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note id: $id, userId: $userId, isSynced: $isSynced, text: $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'meranotes.db';

const notesTable = 'notes';
const userTable = 'user';

const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'email';
const isSyncedColumn = 'is_synced';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
                                    "id"	INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
                                    "email"	TEXT NOT NULL UNIQUE
                                  );''';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "notes" (
                                    "id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                                    "user_id"	INTEGER NOT NULL,
                                    "text"	TEXT,
                                    "is_synced"	INTEGER NOT NULL DEFAULT 0,
                                    FOREIGN KEY("user_id") REFERENCES "user"("id")
                                  );''';
