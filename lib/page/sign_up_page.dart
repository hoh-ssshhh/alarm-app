import 'package:alarm/page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ← 追加
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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _emailSent = false;
  bool _obscurePassword = true;

  Future<bool> _checkDuplicateEmailOrUsername(
    String email,
    String username,
  ) async {
    final firestore = FirebaseFirestore.instance;

    // メール重複チェック（usersコレクション）
    final emailQuery =
        await firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

    if (emailQuery.docs.isNotEmpty) {
      return true;
    }

    // ユーザー名重複チェック（usersコレクション）
    final usernameQuery =
        await firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .get();

    if (usernameQuery.docs.isNotEmpty) {
      return true;
    }

    // pendingUsersコレクションもチェック（まだ本登録してない人用）
    final pendingEmailQuery =
        await firestore
            .collection('pendingUsers')
            .where('email', isEqualTo: email)
            .get();

    if (pendingEmailQuery.docs.isNotEmpty) {
      return true;
    }

    final pendingUsernameQuery =
        await firestore
            .collection('pendingUsers')
            .where('username', isEqualTo: username)
            .get();

    if (pendingUsernameQuery.docs.isNotEmpty) {
      return true;
    }

    return false;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();

    try {
      // 重複チェック
      final isDuplicate = await _checkDuplicateEmailOrUsername(email, username);
      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('メールアドレスまたはユーザー名は既に使用されています。')),
        );
        return;
      }

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
                        final user = FirebaseAuth.instance.currentUser;
                        await user?.reload();
                        final isVerified = user?.emailVerified ?? false;

                        if (isVerified) {
                          try {
                            await _authService.createUserWithVerifiedEmail();

                            if (!mounted) return;
                            Navigator.pushReplacementNamed(
                              context,
                              '/welcome',
                              arguments: _usernameController.text,
                            );
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
                      child: const Text('確認しました'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ユーザーがログインしていません')),
                          );
                          return;
                        }

                        try {
                          await user.reload();
                          await user.sendEmailVerification();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('確認メールを再送信しました。')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('再送信エラー: $e')));
                        }
                      },
                      child: const Text('もう一度送信'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null && !user.emailVerified) {
                          try {
                            await user.delete();
                          } catch (_) {
                            await FirebaseAuth.instance.signOut();
                          }
                        }
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('キャンセル'),
                    ),
                  ],
                )
                : Form(
                  key: _formKey,
                  child: ListView(
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
                        decoration: InputDecoration(
                          labelText: 'パスワード',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator:
                            (value) =>
                                value == null || value.length < 6
                                    ? '6文字以上のパスワードを入力してください'
                                    : null,
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'パスワード（確認）',
                        ),
                        obscureText: true,
                        validator:
                            (value) =>
                                value != _passwordController.text
                                    ? 'パスワードが一致しません'
                                    : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signUp,
                        child: const Text('登録して確認メール送信'),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          ); // 元画面が存在する場合のみ
                        },
                        child: const Text('キャンセル'),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
