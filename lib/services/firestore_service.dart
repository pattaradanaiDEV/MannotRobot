import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe.dart';
import '../models/job.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================
  // --- ส่วนของ Recipes ---
  // ==========================================

  // บันทึกสูตรอาหารใหม่
  Future<void> addRecipe(Recipe recipe) async {
    await _db.collection('recipes').add(recipe.toMap());
  }

  // ดึงข้อมูลสูตรอาหารทั้งหมดแบบ Real-time (เรียงจากใหม่ไปเก่า)
  Stream<QuerySnapshot> getRecipes() {
    return _db
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // อัปเดตการกด Like (ใช้ ArrayUnion เพื่อเพิ่ม User ID เข้าไปใน List)
  Future<void> toggleRecipeLike(
    String recipeId,
    String userId,
    bool isLiked,
  ) async {
    DocumentReference doc = _db.collection('recipes').doc(recipeId);
    if (isLiked) {
      await doc.update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    } else {
      await doc.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    }
  }

  // ==========================================
  // --- ส่วนของ Jobs ---
  // ==========================================

  // บันทึกโพสต์งานใหม่
  Future<void> addJob(Job job) async {
    await _db.collection('jobs').add(job.toMap());
  }

  // ดึงข้อมูลงานทั้งหมดแบบ Real-time (เรียงจากใหม่ไปเก่า)
  Stream<QuerySnapshot> getJobs() {
    return _db
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
