import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning/services/cloud/cloud_note.dart';
import 'package:learning/services/cloud/cloud_storage_constants.dart';
import 'package:learning/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection("notes");

Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fetchedNote=await document.get();
    return CloudNote(documentId: fetchedNote.id, ownerUserId: ownerUserId, text: '');
  }

  Future<Iterable<CloudNote>> getNote({required String ownerUserId}) async {
    try {
      return await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
          .then(
            (value) => value.docs.map(
              (doc) {
                return CloudNote(
                  documentId: doc.id,
                  ownerUserId: doc.data()[ownerUserId] as String,
                  text: doc.data()[textFieldName] as String,
                );
              },
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNote({required String ownerUserId}) => 
    notes.snapshots().map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc))
    .where((note) => note.ownerUserId == ownerUserId));

  Future<void> updateNote({required String documentId,required String text}) async{
    try{
      await notes.doc(documentId).update({textFieldName:text});
    }
    catch(e){
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try{
      await notes.doc(documentId).delete();
    }
    catch(e){
      throw CouldNotDeleteNoteException();
    }
  }


  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
