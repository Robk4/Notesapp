//Exceptions for Cloud related problems

class CloudStorageException implements Exception {
  const CloudStorageException();
}

//C in CRUD
class CouldNotCreateNoteException extends CloudStorageException {}

//R
class CouldNotGetNotesException extends CloudStorageException {}

//U
class CouldNotUpdateNoteException extends CloudStorageException {}

//D
class CouldNotDeleteNotesException extends CloudStorageException {}
