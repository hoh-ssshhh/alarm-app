import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

// 設定ページ
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  String userName = 'taro_123'; // 初期のユーザー名
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        _profileImage != null
                            ? FileImage(_profileImage!)
                            : const AssetImage('assets/images/profile.jpg')
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
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const DividerWithText(title: 'プロフィール'),

          // ユーザー名編集タイル
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('ユーザー名'),
            subtitle: Text(userName),
            trailing: const Icon(Icons.edit),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EditUserNamePage(
                        currentUserName: userName,
                        onSave: (newName) {
                          setState(() {
                            userName = newName;
                          });
                        },
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
              // 通知の権限設定画面に飛ばす
              await openAppSettings(); // アプリの設定画面に飛ばす
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
                      'このアプリケーションはアラームを共有できるアプリケーションです。'
                      '待ち合わせ時間に寝坊などで遅刻する友達とアラームを共有しましょう。',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
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
            onTap: () {},
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
