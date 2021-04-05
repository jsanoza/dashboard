import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_try/utils/samplemodel.dart';

class FirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Productx>> getPosts() {
    return _db.collection('news').snapshots().map((snapshot) => snapshot.docs.map((document) => Productx.fromMap(document.data())).toList());
  }
}
