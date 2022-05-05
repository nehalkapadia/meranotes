// database exceptions
class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentDirectoryException implements Exception {}

class DatabaseIsNotOpenException implements Exception {}

// user exceptions
class UserCannotBeDeletedException implements Exception {}

class UserAlreadyExistsException implements Exception {}

// Notes exceptions
class NoUsersException implements Exception {}

class NoNotesException implements Exception {}

class NoteCannotBeDeletedException implements Exception {}

class CouldNoteUpdateNote implements Exception {}
