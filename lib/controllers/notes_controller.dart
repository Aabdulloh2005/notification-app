import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practice/services/note_firestore_service.dart';

class NotesController {
  final _notesFirestore = NoteFirestoreService();

  Stream<QuerySnapshot> getNotes() {
    return _notesFirestore.getNotes();
  }

  void upadteNote(String id, bool isDone,
      {String? title, Timestamp? date}) async {
    _notesFirestore.upadteNote(id, isDone, title: title, date: date);
  }

  void deleteNote(String id) {
    _notesFirestore.deleteNote(id);
  }
}
