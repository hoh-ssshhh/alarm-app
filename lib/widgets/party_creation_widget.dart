import 'package:flutter/material.dart';

class PartyCreationWidget extends StatelessWidget {
  const PartyCreationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "アラーム設定",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text("・アラーム時間：07:00\n・スヌーズ：3回"),
            SizedBox(height: 16),
            Divider(),
            Text(
              "パーティ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text("・参加メンバー：taro_123, hana_456"),
          ],
        ),
      ),
    );
  }
}
