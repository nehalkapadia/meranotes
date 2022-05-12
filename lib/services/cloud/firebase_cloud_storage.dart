import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meranotes/services/cloud/cloud_note.dart';
import 'package:meranotes/services/cloud/cloud_storage_constants.dart';
import 'package:meranotes/services/crud/crud_exceptions.dart';

class FirebaseCloudStorage {
  final allNotes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      await allNotes.doc(documentId).delete();
    } catch (e) {
      throw NoteCannotBeDeletedException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await allNotes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNoteUpdateNote();
    }
  }

  Stream<Iterable<CloudNote>> getAllNotes({required String ownerUserId}) =>
      allNotes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await allNotes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (notes) => notes.docs.map(
              (doc) {
                return CloudNote(
                  documentId: doc.id,
                  ownerUserId: doc.data()[ownerUserIdFieldName] as String,
                  text: doc.data()[textFieldName] as String,
                );
              },
            ),
          );
    } catch (e) {
      throw NoNotesException();
    }
  }

  void createNewNote({required String ownerUserId}) async {
    await allNotes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  static final FirebaseCloudStorage _firebaseCloudStorage =
      FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();

  factory FirebaseCloudStorage() => _firebaseCloudStorage;
}
