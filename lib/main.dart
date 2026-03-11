import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 🔴 1. เพิ่ม Import สำหรับ dotenv

import 'firebase_options.dart';
import 'app_state.dart'; // ไฟล์จัดการสถานะ Login ของคุณ
import 'screens/layout/main_layout.dart'; // หน้าหลัก UI ของเรา
import 'login.dart'; // ดึงหน้า Login เดิมของคุณมาใช้

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔴 2. สั่งให้แอปโหลด API Key จากไฟล์ .env ก่อนเริ่มทำอย่างอื่น
  await dotenv.load(fileName: ".env");

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
    final appState = Provider.of<ApplicationState>(context, listen: false);
    final bool loggedIn = appState.loggedIn;
    final bool isLoggingIn = state.matchedLocation == '/login';

    if (!loggedIn && !isLoggingIn) return '/login';
    if (loggedIn && isLoggingIn) return '/';

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MainLayout()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Culinary Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFF97316),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
