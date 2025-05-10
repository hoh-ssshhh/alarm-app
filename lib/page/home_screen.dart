import 'package:flutter/material.dart';
import '../widgets/clock/analog_clock.dart';
import '../widgets/alarm_clock_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> alarms = [];

  // アラーム追加時のコールバック
  void _addAlarm(Map<String, dynamic> newAlarm) {
    setState(() {
      alarms.add(newAlarm);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('共有アラーム')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 200, height: 200, child: AnalogClock()),
              const SizedBox(height: 24),
              AlarmClockWidget(onAlarmAdded: _addAlarm), // ← コールバックを渡す
              const SizedBox(height: 24),
              // アラームリストの表示
              alarms.isNotEmpty
                  ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: alarms.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: ListTile(
                          title: Text('アラーム: ${alarms[index]["time"] ?? "不明"}'),
                          subtitle: Text(
                            'スヌーズ回数: ${alarms[index]["snoozeCount"] ?? "0"}',
                          ),
                        ),
                      );
                    },
                  )
                  : const Text('アラームがまだありません'),
            ],
          ),
        ),
      ),
    );
  }
}
