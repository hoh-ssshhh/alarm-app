import 'package:flutter/material.dart';

class AlarmClockWidget extends StatefulWidget {
  const AlarmClockWidget({super.key});

  @override
  State<AlarmClockWidget> createState() => _AlarmClockWidgetState();
}

class _AlarmClockWidgetState extends State<AlarmClockWidget> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  int _selectedSnooze = 5;

  TimeOfDay? _savedTime;
  int? _savedSnooze;

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveSettings() {
    setState(() {
      _savedTime = _selectedTime;
      _savedSnooze = _selectedSnooze;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('アラーム設定を保存しました')));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'アラーム設定',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('アラーム時間を選択'),
              subtitle: Text('${_selectedTime.format(context)}'),
              onTap: _pickTime,
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.snooze),
              title: const Text('スヌーズ間隔'),
              trailing: DropdownButton<int>(
                value: _selectedSnooze,
                items:
                    [5, 10, 15, 20]
                        .map(
                          (val) => DropdownMenuItem(
                            value: val,
                            child: Text('$val 分'),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedSnooze = val;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('保存する'),
                onPressed: _saveSettings,
              ),
            ),
            const SizedBox(height: 16),
            if (_savedTime != null && _savedSnooze != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text(
                    '⏰ 保存された設定：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('・アラーム時間：${_savedTime!.format(context)}'),
                  Text('・スヌーズ：$_savedSnooze 分'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
