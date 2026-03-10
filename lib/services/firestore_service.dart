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

  Stream<QuerySnapshot> getRecipeReviews(String recipeId) {
    return _db
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .orderBy(
          'createdAt',
          descending: true,
        ) // เรียงจากคอมเมนต์ใหม่สุดไปเก่าสุด
        .snapshots();
  }

  // 2. เพิ่มรีวิวใหม่ และอัปเดตคะแนนเฉลี่ยของสูตรอาหาร
  Future<void> addRecipeReview(
    String recipeId,
    double rating,
    String comment,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('กรุณาเข้าสู่ระบบก่อนรีวิว');

    // 🔴 เพิ่มกฎ: เช็กว่าผู้ใช้คนนี้เคยรีวิวสูตรอาหารนี้ไปแล้วหรือยัง
    QuerySnapshot existingReview = await _db
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .where('userId', isEqualTo: user.uid) // ค้นหาด้วย UID ของผู้ใช้
        .get();

    // ถ้ามีข้อมูลกลับมา แปลว่าเคยรีวิวแล้ว ให้เตะออกและโยน Error กลับไป
    if (existingReview.docs.isNotEmpty) {
      throw Exception('คุณได้รีวิวเมนูนี้ไปแล้วครับ');
    }

    // ข้อมูลรีวิวที่จะบันทึก
    final reviewData = {
      'userId': user.uid,
      'userName': user.displayName ?? user.email ?? 'Anonymous',
      'userPhoto': user.photoURL ?? '',
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // บันทึกลงใน Subcollection 'reviews' ของสูตรอาหารนี้
    await _db
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .add(reviewData);

    // --- อัปเดตคะแนนเฉลี่ย (Average Rating) ของสูตรอาหาร ---
    // ดึงรีวิวทั้งหมดมาคำนวณหาค่าเฉลี่ยใหม่
    QuerySnapshot reviewsSnapshot = await _db
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .get();

    if (reviewsSnapshot.docs.isNotEmpty) {
      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        totalRating += (doc.data() as Map<String, dynamic>)['rating'] ?? 0;
      }
      double averageRating = totalRating / reviewsSnapshot.docs.length;

      // อัปเดตฟิลด์ rating ในสูตรอาหารหลัก (ปัดทศนิยม 1 ตำแหน่ง)
      await _db.collection('recipes').doc(recipeId).update({
        'rating': double.parse(averageRating.toStringAsFixed(1)),
      });
    }
  }
}
