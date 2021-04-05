import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_try/utils/user.dart';
import 'package:dev_try/utils/utils.dart';

class Api {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String path;
  CollectionReference ref;

  Api(this.path) {
    ref = _db.collection(path);
  }

  Future<QuerySnapshot> getDataCollection() {
    return ref.get();
  }

  Stream<QuerySnapshot> streamDataCollection() {
    return ref.snapshots();
  }

  Future<void> removeDocument(String id) {
    return ref.doc(id).delete();
  }

  Future<DocumentReference> addDocument(Map data, String docid) {
    return ref.doc(docid).set(data);
  }

  Future<void> addNote(UserData userData) {
    return ref.add(userData.toMap());
  }

  Future<void> addNews(Product product, String docid) {
    return ref.doc(docid).set(product.toMap());
  }

  Future<void> editNews(Product product, String docid) {
    // return ref.doc(docid).set(product.toMap());
    return ref.doc(docid).update(product.toMap());
  }

  Future<void> updateDocument(Map data, String id) {
    return ref.doc(id).update(data);
  }
}
