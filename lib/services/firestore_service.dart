import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ดึงข้อมูลสูตรอาหาร (ใช้ Mock ไปก่อนถ้ายังไม่มีข้อมูลใน Firebase)
  Stream<QuerySnapshot> getRecipes() {
    return _db
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ดึงข้อมูลงาน
  Stream<QuerySnapshot> getJobs() {
    return _db
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
