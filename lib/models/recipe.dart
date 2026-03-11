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

  // 🔴 1. เปลี่ยนจาก String เป็น List<String>
  final List<String> instructions;

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
    required this.instructions, // รับค่าเป็น List
    required this.imageUrl,
    required this.likes,
    this.createdAt,
  });

  // ฟังก์ชันแปลงข้อมูลจาก Firestore (Map) มาเป็น Object ในแอป
  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
    // 🔴 2. ฟังก์ชันช่วยเช็กข้อมูล (เผื่อข้อมูลเก่าเป็น String ข้อมูลใหม่เป็น List)
    List<String> parseInstructions(dynamic data) {
      if (data is List) {
        return List<String>.from(data);
      } else if (data is String) {
        // ถ้าเป็น String (ข้อมูลเก่า) ให้แบ่งบรรทัดเอา
        return data.split('\n').where((s) => s.trim().isNotEmpty).toList();
      }
      return [];
    }

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
      // 🔴 3. เรียกใช้ฟังก์ชันแปลงข้อมูล
      instructions: parseInstructions(map['instructions']),
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
      // 🔴 4. ส่งเป็น Array ขึ้น Firestore ได้เลย
      'instructions': instructions,
      'imageUrl': imageUrl,
      'likes': likes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
