import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meranotes/services/crud/crud_exceptions.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;

  final _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      return await getUser(email: email);
    } on NoUsersException {
      return await createUser(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cachedNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
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

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSynced: true,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final deleteCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deleteCount != 1) {
      throw NoteCannotBeDeletedException();
    }
    _notes.removeWhere((note) => note.id == id);
    _notesStreamController.add(_notes);
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final totalDeletions = await db.delete(notesTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return totalDeletions;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
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

    final notes = DatabaseNote.fromRow(note.first);

    _notes.removeWhere((note) => note.id == id);
    _notes.add(notes);
    _notesStreamController.add(_notes);

    return notes;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final notes = await db.query(notesTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // check if note exists
    await getNote(id: note.id);

    // update note
    final updatedNote = db.update(notesTable, {
      textColumn: text,
      isSyncedColumn: 0,
    });

    if (updatedNote == 0) {
      throw CouldNoteUpdateNote();
    }

    final updatedNotes = await getNote(id: note.id);
    _notes.removeWhere((note) => note.id == updatedNotes.id);
    _notes.add(updatedNotes);
    _notesStreamController.add(_notes);

    return updatedNotes;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
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
    await _ensureDbIsOpen();
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
    await _ensureDbIsOpen();
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

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      throw DatabaseAlreadyOpenException();
    }
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

      await _cachedNotes();
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

@immutable
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
