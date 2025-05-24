import 'package:alarm/main.dart';
import 'package:alarm/page/sign_up_page.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showMessage('ユーザー名とパスワードを入力してください');
      return;
    }

    try {
      final email = await _getEmailFromUsername(username);
      if (email == null) {
        _showMessage('このユーザー名は存在しません');
        return;
      }

      final userCredential = await _authService.signInWithEmail(
        email,
        password,
      );
      _showMessage('ログイン成功: ${userCredential.user?.displayName}');
      _navigateToHome();
    } catch (e) {
      _showMessage('ログイン失敗: $e');
    }
  }

  Future<String?> _getEmailFromUsername(String username) async {
    final firestore = FirebaseFirestore.instance;

    final userQuery =
        await firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

    if (userQuery.docs.isNotEmpty) {
      return userQuery.docs.first['email'] as String?;
    }
    return null;
  }

  void _loginWithGoogle() async {
    try {
      final userCredential = await _authService.signInWithGoogle();
      _showMessage('Googleログイン成功: ${userCredential.user?.displayName}');
      _navigateToHome();
    } catch (e) {
      _showMessage('Googleログイン失敗: $e');
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'ユーザー名'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'パスワード'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('ログイン')),
            const SizedBox(height: 10),
            SignInButton(Buttons.google, onPressed: _loginWithGoogle),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text('アカウントを作成する'),
            ),
          ],
        ),
      ),
    );
  }
}
