import 'package:flutter/material.dart';

class BottomNavBarWidget extends StatelessWidget {
  final int selectedIndex; // ← 追加！
  final ValueChanged<int> onItemTapped; // ← 追加！

  const BottomNavBarWidget({
    super.key,
    required this.selectedIndex, // ← 追加！
    required this.onItemTapped, // ← 追加！
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex, // ← 追加！
      onTap: onItemTapped, // ← 追加！
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.access_alarm, size: 30),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.supervised_user_circle, size: 30),
          label: 'Friends',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle, size: 30),
          label: 'Settings',
        ),
      ],
    );
  }
}
