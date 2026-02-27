import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String? id; // Document ID ใน Firestore
  final String userId;
  final String recruiterName;
  final String companyName;
  final String title;
  final String jobType; // Full-time, Part-time, etc.
  final String salaryRange; // e.g., "$60k - $75k"
  final String location;
  final String description;
  final List<String> requirements;
  final String logoUrl;
  final String imageUrl;
  final List<String> likes; // เก็บ UserID ของคนที่กดเซฟงาน
  final DateTime? createdAt;

  Job({
    this.id,
    required this.userId,
    required this.recruiterName,
    required this.companyName,
    required this.title,
    required this.jobType,
    required this.salaryRange,
    required this.location,
    required this.description,
    required this.requirements,
    required this.logoUrl,
    required this.imageUrl,
    required this.likes,
    this.createdAt,
  });

  // แปลงจาก Firestore Map เป็น Object
  factory Job.fromMap(String id, Map<String, dynamic> map) {
    return Job(
      id: id,
      userId: map['userId'] ?? '',
      recruiterName: map['recruiterName'] ?? 'Unknown Recruiter',
      companyName: map['companyName'] ?? 'Unknown Company',
      title: map['title'] ?? '',
      jobType: map['jobType'] ?? 'Full-time',
      salaryRange: map['salaryRange'] ?? 'N/A',
      location: map['location'] ?? 'Remote',
      description: map['description'] ?? '',
      requirements: List<String>.from(map['requirements'] ?? []),
      logoUrl: map['logoUrl'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // แปลง Object เป็น Map เพื่อบันทึกลง Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'recruiterName': recruiterName,
      'companyName': companyName,
      'title': title,
      'jobType': jobType,
      'salaryRange': salaryRange,
      'location': location,
      'description': description,
      'requirements': requirements,
      'logoUrl': logoUrl,
      'imageUrl': imageUrl,
      'likes': likes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
