import 'package:firebase_auth/firebase_auth.dart';

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
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // อัปเดตชื่อผู้ใช้
      await userCredential.user?.updateDisplayName(fullName);

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
