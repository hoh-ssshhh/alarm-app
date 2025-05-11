import 'package:flutter/material.dart';
import 'package:alarm/services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _emailSent = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text;

    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        username: username,
      );

      setState(() {
        _emailSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('確認メールを送信しました。メールを確認してください。')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('サインアップ失敗: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('サインアップ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _emailSent
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('確認メールを送信しました。\nメールを確認してください。'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final isVerified = await _authService.isEmailVerified();
                        if (isVerified) {
                          try {
                            // Firebase 側で自動ログイン済みと仮定
                            if (!mounted) return;
                            Navigator.pushReplacementNamed(context, '/home');
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ログインエラー: $e')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('まだ確認されていません。メールを確認してください。'),
                            ),
                          );
                        }
                      },
                      child: const Text('確認済みです'),
                    ),
                  ],
                )
                : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'ユーザー名'),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'ユーザー名を入力してください'
                                    : null,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'メールアドレス'),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'メールアドレスを入力してください'
                                    : null,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'パスワード'),
                        obscureText: true,
                        validator:
                            (value) =>
                                value == null || value.length < 6
                                    ? '6文字以上のパスワードを入力してください'
                                    : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signUp,
                        child: const Text('登録して確認メール送信'),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
