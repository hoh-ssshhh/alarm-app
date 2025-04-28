import 'package:flutter/material.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final List<String> friendRequests = ['tomo123', 'tomomi123', 'tomohiro123'];
  final List<String> friendList = ['nana_48', 'ryota_dev'];

  void approveFriend(String name) {
    setState(() {
      friendRequests.remove(name);
      friendList.add(name);
    });
  }

  void rejectFriend(String name) {
    setState(() {
      friendRequests.remove(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('フレンド')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // フレンド検索欄
              TextField(
                decoration: InputDecoration(
                  labelText: 'フレンドを検索',
                  hintText: 'ユーザー名を入力',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  // 検索処理（あとで実装）
                },
              ),

              const SizedBox(height: 24),

              // 区切り線：フレンドリクエスト
              const DividerWithText(title: 'フレンドリクエスト'),

              // フレンドリクエスト一覧
              ...friendRequests.map((name) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(name),
                    subtitle: const Text('からのフレンド申請'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => approveFriend(name),
                          child: const Text('承認'),
                        ),
                        TextButton(
                          onPressed: () => rejectFriend(name),
                          child: const Text('拒否'),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // 区切り線：フレンドリスト
              const DividerWithText(title: 'フレンドリスト'),

              // フレンド一覧
              ...friendList.map((name) {
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(name),
                  trailing: IconButton(
                    onPressed: () {
                      // チャット画面へ遷移（あとで実装）
                    },
                    icon: const Icon(Icons.chat),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// 横線とタイトルを一緒に表示するウィジェット
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
