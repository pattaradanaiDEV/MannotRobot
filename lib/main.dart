import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'firebase_options.dart';
import 'app_state.dart'; // ไฟล์จัดการสถานะ Login ของคุณ
import 'screens/layout/main_layout.dart'; // หน้าหลัก UI ของเรา
import 'login.dart'; // ดึงหน้า Login เดิมของคุณมาใช้

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialized Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. ครอบแอปด้วย Provider เพื่อให้ทุกหน้าเช็กสถานะ Login ได้
  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: ((context, child) => const MyApp()),
    ),
  );
}

// 3. ตั้งค่า GoRouter เพื่อจัดการเส้นทางและบังคับ Login
final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // ดึงสถานะจาก app_state.dart
    final appState = Provider.of<ApplicationState>(context, listen: false);
    final bool loggedIn = appState.loggedIn;
    final bool isLoggingIn = state.matchedLocation == '/login';

    // ถ้ายังไม่ Login และไม่ได้อยู่หน้า Login -> เด้งไปหน้า Login
    if (!loggedIn && !isLoggingIn) return '/login';
    // ถ้า Login แล้ว แต่เผลอไปกดเข้าหน้า Login -> เด้งกลับมาหน้า Home
    if (loggedIn && isLoggingIn) return '/';

    return null; // ปล่อยผ่าน
  },
  routes: [
    // หน้าหลัก
    GoRoute(path: '/', builder: (context, state) => const MainLayout()),

    // หน้า Login (แก้ให้เรียกใช้ Custom UI ของเรา)
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. เปลี่ยนมาใช้ MaterialApp.router เพื่อใช้ GoRouter
    return MaterialApp.router(
      title: 'Culinary Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFF97316),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      routerConfig: _router, // เรียกใช้ Router ที่เราสร้างไว้
    );
  }
}
