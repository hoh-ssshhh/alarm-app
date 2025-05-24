import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // 追加

// ページのインポート
import 'page/home_screen.dart';
import 'page/friend_page.dart';
import 'page/setting_page.dart';
import 'page/login_page.dart';
import 'page/welcom_page.dart';
import 'page/sign_up_page.dart';

import 'widgets/bottom_bar.dart';
import 'page/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Firebase初期化前の準備
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase初期化
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/welcome': (context) => const WelcomePage(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginPage(),
      }, // ログイン状態に応じて画面を切り替える
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const MyApp(); // ログイン済みならホーム画面へ
        } else {
          return LoginPage(); // 未ログインならログイン画面へ
        }
      },
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [HomeScreen(), FriendPage(), SettingPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBarWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
