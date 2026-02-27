import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String? id; // Document ID ใน Firestore
  final String userId;
  final String authorName;
  final String title;
  final String difficulty; // Easy, Medium, Hard
  final int timeMins;
  final List<String> tags; // e.g., ['Thai', 'Dinner']
  final List<Map<String, String>>
  ingredients; // e.g., [{'qty': '1 cup', 'name': 'Sugar'}]
  final String instructions;
  final String imageUrl;
  final List<String> likes; // เก็บ UserID ของคนที่กดหัวใจ
  final DateTime? createdAt;

  Recipe({
    this.id,
    required this.userId,
    required this.authorName,
    required this.title,
    required this.difficulty,
    required this.timeMins,
    required this.tags,
    required this.ingredients,
    required this.instructions,
    required this.imageUrl,
    required this.likes,
    this.createdAt,
  });

  // ฟังก์ชันแปลงข้อมูลจาก Firestore (Map) มาเป็น Object ในแอป
  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
    return Recipe(
      id: id,
      userId: map['userId'] ?? '',
      authorName: map['authorName'] ?? 'Unknown Chef',
      title: map['title'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      timeMins: map['timeMins'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      ingredients: List<Map<String, String>>.from(
        (map['ingredients'] ?? []).map(
          (item) => Map<String, String>.from(item),
        ),
      ),
      instructions: map['instructions'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // ฟังก์ชันแปลง Object กลับเป็น Map เพื่อส่งขึ้นไปเซฟบน Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'authorName': authorName,
      'title': title,
      'difficulty': difficulty,
      'timeMins': timeMins,
      'tags': tags,
      'ingredients': ingredients,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'likes': likes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
