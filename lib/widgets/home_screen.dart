// lib/widgets/home_screen.dart
import 'package:flutter/material.dart';
import 'analog_clock.dart';
import 'party_creation_widget.dart'; // ← さっき作ったやつを使う

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          SizedBox(
            width: 200,
            height: 200,
            child: AnalogClock(), // ← アナログ時計
          ),
          SizedBox(height: 24),
          PartyCreationWidget(), // ← カード型ウィジェット（アラーム設定＋パーティ作成）
        ],
      ),
    );
  }
}
