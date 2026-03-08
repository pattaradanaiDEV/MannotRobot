import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // คืนค่า User ปัจจุบัน (ถ้ามี)
  User? get currentUser => _auth.currentUser;

  // ตรวจจับสถานะว่า Login หรือ Logout อยู่แบบ Real-time
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ฟังก์ชัน: เข้าสู่ระบบ (Login)
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

  // ฟังก์ชัน: สมัครสมาชิก (Register) พร้อมตั้งชื่อ Display Name
  // ในไฟล์ auth_service.dart

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

  // ฟังก์ชัน: ออกจากระบบ (Logout)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ฟังก์ชัน: ส่งอีเมลรีเซ็ตรหัสผ่าน (Forgot Password)
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}
