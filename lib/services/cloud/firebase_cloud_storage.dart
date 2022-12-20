import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qnotes/services/cloud/cloud_storage_constants.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  void createNewNote({required String ownerUserId}) async {
    notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }
}
