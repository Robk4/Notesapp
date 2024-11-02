import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:notesapp/extensions/list/filter.dart';
import 'package:notesapp/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// Primary service to work with DataBase

class NotesService {
  Database? _db;
  DatabaseUser? _user;

//Making NotesService a singleton(only one in the entire app)
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _shared;

//Caching the notes
  List<DatabaseNote> _notes = [];
  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserNotSetBeforeReadingNotesException();
        }
      });

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on UserDoesntExistsException {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    }
  }

//Function that gets dataBase or throws an exception
  Database _getDatabeOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> openDb() async {
    //Check if the database exists
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    //Syncing with our _db
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      //Execution of the userDataTable
      await db.execute(createUserTable);

      //Execution of the noteDataTable
      await db.execute(createNoteTable);
      //Caching the notes
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> closeDb() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      await db.close();
      _db = null; // Reseting the database after closing
    }
  }

  Future<void> _ensureDbOpened() async {
    try {
      await openDb();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbOpened();
    final db = _getDatabeOrThrow();

    final dbUser = await getUser(email: owner.email);

    //If statement using the equals operator to check if the dbUser is actually the owner in database
    if (dbUser != owner) {
      throw UserDoesntExistsException();
    }

    //Creating the notes
    final notesId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: '',
      cloudSyncingColumn: 1,
    });

    final note = DatabaseNote(
      id: notesId,
      userId: owner.id,
      text: '',
      cloudSyncing: true,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbOpened();
    final db = _getDatabeOrThrow();
    final results = await db.query(
      noteTable,
      limit: 1,
      where: 'id=?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      throw NoteDoestExitsException();
    } else {
      final note = DatabaseNote.fromRow(results.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbOpened();
    final db = _getDatabeOrThrow();
    final notes = await db.query(
      noteTable,
    );

    final result = notes.map((noteRow) => DatabaseNote.fromRow(noteRow));

    if (notes.isEmpty) {
      throw NoteDoestExitsException();
    } else {
      return result;
    }
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    await _ensureDbOpened();
    final db = _getDatabeOrThrow();

    //Making sure note exists
    await getNote(id: note.id);

    //Updating the database
    final updateCount = await db.update(
      noteTable,
      {
        textColumn: text,
        cloudSyncingColumn: 0,
      },
      where: 'id =?',
      whereArgs: [note.id],
    );

    if (updateCount == 0) {
      throw CouldNotDeleteNoteException();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      return updatedNote;
    }
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbOpened();
    final db = _getDatabeOrThrow();
    final deleteCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deleteCount == 0) {
      throw CouldNotDeleteNoteException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes({required int id}) async {
    await _ensureDbOpened();
    final db = _getDatabeOrThrow();
    final deletionCount = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return deletionCount; // returns the value of deleted rows
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbOpened();
    final db = _getDatabeOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    final userId = await db.insert(
      userTable,
      {emailColumn: email.toLowerCase()},
    );

    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbOpened();
    final db = _getDatabeOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw UserDoesntExistsException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbOpened();
    final db = _getDatabeOrThrow();
    final deleteCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteCount != 1) {
      throw CouldNotDeleteUserException();
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
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool cloudSyncing;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.cloudSyncing,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        cloudSyncing = (map[cloudSyncingColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, cloudSyncing=$cloudSyncing, text=$text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const cloudSyncingColumn = 'cloud_syncing';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS"note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "cloud_syncing"	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("user_id") REFERENCES "user"("id")
        );''';
