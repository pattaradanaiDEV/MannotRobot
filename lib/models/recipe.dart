/*
 * File: recipe.dart
 * Description: โมเดลข้อมูลสำหรับสูตรอาหาร
 * Responsibilities:
 * - กำหนดโครงสร้าง Attribute ของสูตรอาหาร
 * - จัดการการแปลงข้อมูลกับ Firestore
 * Author: Pattaradanai Chaitan
 */
import 'package:cloud_firestore/cloud_firestore.dart';

/// ตัวแทนออบเจกต์ของ Recipe ในระบบ.
///
/// ใช้สำหรับจัดเก็บและส่งผ่านข้อมูลสูตรอาหารระหว่างเลเยอร์ข้อมูลและ UI.
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

  final List<String> instructions;
  final String imageUrl;
  final List<String> likes; // เก็บ UserID ของคนที่กดหัวใจ
  final DateTime? createdAt;

  /// สร้าง [Recipe] ออบเจกต์.
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

  /// สร้างออบเจกต์ [Recipe] จาก [Map] ที่ได้มาจาก Firestore.
  ///
  /// รับค่า [id] ของเอกสาร และ [map] ซึ่งเป็นข้อมูล JSON แบบ Key-Value.
  /// มีฟังก์ชันภายในเพื่อรองรับโครงสร้างข้อมูลแบบเก่าสำหรับช่องวิธีทำ.
  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
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
      'instructions': instructions,
      'imageUrl': imageUrl,
      'likes': likes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
