/*
 * File: auth_service.dart
 * Description: จัดการการยืนยันตัวตนผ่าน Firebase Auth
 * Responsibilities:
 * - จัดการการเข้าสู่ระบบ สมัครสมาชิก และออกจากระบบ
 * - บันทึกข้อมูลโปรไฟล์เริ่มต้นของผู้ใช้ใหม่ลง Firestore
 * Author: Purich Saenasang
 */
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// จัดการการยืนยันตัวตนของผู้ใช้ผ่าน Firebase.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ดึงข้อมูลผู้ใช้ปัจจุบันที่ล็อกอินอยู่.
  ///
  /// คืนค่าเป็น `null` หากยังไม่ได้ล็อกอิน.
  User? get currentUser => _auth.currentUser;

  /// สตรีมตรวจสอบสถานะการเข้าสู่ระบบแบบเรียลไทม์.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// ดำเนินการเข้าสู่ระบบด้วยอีเมลและรหัสผ่าน.
  ///
  /// Throws Exception หากการเข้าสู่ระบบล้มเหลว.
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow; // โยน Error กลับไปให้หน้า UI จัดการแสดงแจ้งเตือน
    }
  }

  /// ดำเนินการสมัครสมาชิกใหม่ด้วยอีเมล รหัสผ่าน และตั้งชื่อแสดงผล.
  ///
  /// Throws Exception หากการสมัครสมาชิกล้มเหลว
  ///
  /// Side effects:
  /// สร้างเอกสารโปรไฟล์ใหม่ของผู้ใช้ในคอลเลกชัน `users` บน Firestore.
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      // 1. สร้างบัญชีใน Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user?.updateDisplayName(fullName);

      // 2. สร้างข้อมูล Profile ใน Firestore Database (Collection: users)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'email': email,
            'fullName': fullName,
            'photoUrl':
                'https://i.pravatar.cc/150?img=11', // ใส่รูป Default ไว้ก่อน
            'savedRecipes': [], // เตรียม Array ว่างไว้เก็บของที่เซฟ
            'savedJobs': [],
            'createdAt': FieldValue.serverTimestamp(),
          });

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // ฟังก์ชัน: ออกจากระบบ.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
