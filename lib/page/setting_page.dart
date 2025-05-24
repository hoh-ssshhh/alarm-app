import 'package:alarm/page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  String username = '';
  File? _profileImage;
  String? profileImageUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          username = data['username'] ?? '';
          profileImageUrl = data['profileImageUrl'];
        });
      }
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final ref = FirebaseStorage.instance.ref().child(
        'profile_images/${user.uid}.jpg',
      );
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('画像アップロード失敗: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('写真へのアクセス権限が必要です')));
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      setState(() {
        _profileImage = file;
      });

      final url = await _uploadImage(file);
      if (url != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'profileImageUrl': url});
          setState(() {
            profileImageUrl = url;
          });
        }
      }
    }
  }

  Future<void> _updateUserName(String newName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'username': newName,
    });

    setState(() {
      username = newName;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 【ここを修正】親のGestureDetectorを削除してRowだけに
          Row(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      _profileImage != null
                          ? FileImage(_profileImage!)
                          : (profileImageUrl != null
                                  ? NetworkImage(profileImageUrl!)
                                  : const AssetImage(
                                    'assets/images/profile.jpg',
                                  ))
                              as ImageProvider,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ユーザー名',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const DividerWithText(title: 'プロフィール'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('ユーザー名'),
            subtitle: Text(username),
            trailing: const Icon(Icons.edit),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EditUserNamePage(
                        currentUserName: username,
                        onSave: _updateUserName,
                      ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('プロフィール画像を変更'),
            onTap: _pickImage,
          ),
          const SizedBox(height: 24),
          const DividerWithText(title: 'その他'),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('通知設定'),
            onTap: () async {
              await openAppSettings();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('このアプリについて'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('アプリについて'),
                    content: const Text(
                      'このアプリケーションはアラームを共有できるアプリケーションです。\n'
                      '待ち合わせ時間に寝坊などで遅刻する友達とアラームを共有しましょう。',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('閉じる'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'ログアウト',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}

// タイトル付き区切り線
class DividerWithText extends StatelessWidget {
  final String title;

  const DividerWithText({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
      ],
    );
  }
}

// ユーザー名編集ページ
class EditUserNamePage extends StatefulWidget {
  final String currentUserName;
  final ValueChanged<String> onSave;

  const EditUserNamePage({
    super.key,
    required this.currentUserName,
    required this.onSave,
  });

  @override
  EditUserNamePageState createState() => EditUserNamePageState();
}

class EditUserNamePageState extends State<EditUserNamePage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUserName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveUserName() {
    String newName = _controller.text.trim();
    if (newName.isNotEmpty) {
      widget.onSave(newName);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ユーザー名を入力してください')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー名を編集'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveUserName),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: '新しいユーザー名',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
