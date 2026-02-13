import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart'; // new
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // new
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // new

import 'app_state.dart'; // new
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: ((context, child) => const App()),
    ),
  );
}

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
    GoRoute(path: '/', builder: (context, state) => const HomePage()),

    // หน้า Login
    GoRoute(
      path: '/login',
      builder: (context, state) => SignInScreen(
        providers: [EmailAuthProvider()],
        actions: [
          AuthStateChangeAction(((context, state) {
            final user = switch (state) {
              SignedIn state => state.user,
              UserCreated state => state.credential.user,
              _ => null,
            };
            if (user == null) return;

            // ถ้าเป็น User ใหม่ ให้ตั้ง Display Name จาก Email
            if (state is UserCreated) {
              user.updateDisplayName(user.email!.split('@')[0]);
            }

            context.go('/'); // ไปหน้า HomePage
          })),
          ForgotPasswordAction(((context, email) {
            final uri = Uri(
              path: '/forgot-password',
              queryParameters: <String, String?>{'email': email},
            );
            context.push(uri.toString());
          })),
        ],
      ),
    ),

    // หน้าลืมรหัสผ่าน
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) {
        final arguments = state.uri.queryParameters;
        return ForgotPasswordScreen(
          email: arguments['email'],
          headerMaxExtent: 200,
        );
      },
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Firebase Meetup',
      theme: ThemeData(
        buttonTheme: Theme.of(
          context,
        ).buttonTheme.copyWith(highlightColor: Colors.deepPurple),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: _router, // new
    );
  }
}
