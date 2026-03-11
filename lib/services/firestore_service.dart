import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // โหลด API Key
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe.dart';
import '../models/job.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================
  // --- ส่วนจัดการไฟล์ (อัปโหลดรูปผ่าน ImgBB) ---
  // ==========================================
  Future<String?> uploadImage(File imageFile) async {
    // ดึง API Key จากไฟล์ .env
    final String imgbbApiKey = dotenv.env['IMGBB_API_KEY'] ?? '';
    if (imgbbApiKey.isEmpty) {
      print("Error: ไม่พบ IMGBB_API_KEY ในไฟล์ .env");
      return null;
    }

    final Uri apiUrl = Uri.parse(
      'https://api.imgbb.com/1/upload?key=$imgbbApiKey',
    );

    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      var response = await http.post(apiUrl, body: {'image': base64Image});

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse['data']['url']; // ได้ URL รูปของจริงมาแล้ว!
      } else {
        print('Upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // ==========================================
  // --- ส่วนของ Recipes ---
  // ==========================================

  Future<void> addRecipe(Recipe recipe) async {
    await _db.collection('recipes').add(recipe.toMap());
  }

  Stream<QuerySnapshot> getRecipes() {
    return _db
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

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

  Stream<QuerySnapshot> getRecipeReviews(String recipeId) {
    return _db
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getTrendingRecipes() {
    return _db
        .collection('recipes')
        .orderBy('rating', descending: true) // เรียงจาก rating สูงสุดไปต่ำสุด
        .limit(5) // จำกัดแค่ 5 อันดับแรก
        .snapshots();
  }

  Future<void> addRecipeReview(
    String recipeId,
    double rating,
    String comment,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('กรุณาเข้าสู่ระบบก่อนรีวิว');

    QuerySnapshot existingReview = await _db
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .where('userId', isEqualTo: user.uid)
        .get();

    if (existingReview.docs.isNotEmpty) {
      throw Exception('คุณได้รีวิวเมนูนี้ไปแล้วครับ');
    }

    final reviewData = {
      'userId': user.uid,
      'userName': user.displayName ?? user.email ?? 'Anonymous',
      'userPhoto': user.photoURL ?? '',
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _db
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .add(reviewData);

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

      await _db.collection('recipes').doc(recipeId).update({
        'rating': double.parse(averageRating.toStringAsFixed(1)),
      });
    }
  }

  // ==========================================
  // --- ส่วนของ Jobs ---
  // ==========================================

  Future<void> addJob(Job job) async {
    await _db.collection('jobs').add(job.toMap());
  }

  Stream<QuerySnapshot> getJobs() {
    return _db
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
