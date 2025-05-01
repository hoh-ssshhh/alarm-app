import 'package:flutter/material.dart';

class AlarmClockWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onAlarmAdded;

  const AlarmClockWidget({super.key, required this.onAlarmAdded});

  @override
  State<AlarmClockWidget> createState() => _AlarmClockWidgetState();
}

class _AlarmClockWidgetState extends State<AlarmClockWidget> {
  List<Map<String, dynamic>> alarms = [];
  List<String> friendList = ['nana_48', 'ryota_dev', 'miki_chan'];
  List<String> selectedFriends = [];
  void showCustomNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).snackBarTheme.backgroundColor ??
                      Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    message,
                    style:
                        Theme.of(context).snackBarTheme.contentTextStyle ??
                        const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Future<void> _showFriendSelectorDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('フレンドを招待'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: friendList.length,
                  itemBuilder: (context, index) {
                    final name = friendList[index];
                    final isInvited = selectedFriends.contains(name);

                    return CheckboxListTile(
                      title: Text(name),
                      value: isInvited,
                      onChanged: (checked) {
                        setStateDialog(() {
                          if (checked == true) {
                            selectedFriends.add(name);
                          } else {
                            selectedFriends.remove(name);
                          }
                        });
                      },
                      secondary: const Icon(Icons.person),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('完了'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedFriends.isNotEmpty) {
      Future.delayed(Duration.zero, () {
        showCustomNotification(
          context,
          '${selectedFriends.join(", ")} を招待しました',
        );
      });
    }
  }

  Future<void> _showAddAlarmDialog() async {
    String title = '';
    DateTime? alarmDate;
    TimeOfDay? alarmTime;
    int snoozeInterval = 5;
    TimeOfDay? meetingTime;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('アラームを追加'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'タイトル（任意）'),
                      onChanged: (value) => title = value,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: dialogContext,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        );
                        if (pickedDate != null) {
                          setState(() => alarmDate = pickedDate);
                        }
                      },
                      child: Text(
                        alarmDate == null
                            ? '日付を選択'
                            : '${alarmDate!.year}/${alarmDate!.month}/${alarmDate!.day}',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedTime = await showTimePicker(
                          context: dialogContext,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() => alarmTime = pickedTime);
                        }
                      },
                      child: Text(
                        alarmTime == null
                            ? 'アラーム時間を選択'
                            : alarmTime!.format(context),
                      ),
                    ),
                    Row(
                      children: [
                        const Text('スヌーズ間隔：'),
                        Expanded(
                          child: Slider(
                            min: 1,
                            max: 30,
                            divisions: 29,
                            label: '$snoozeInterval 分',
                            value: snoozeInterval.toDouble(),
                            onChanged: (value) {
                              setState(() => snoozeInterval = value.toInt());
                            },
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedMeetingTime = await showTimePicker(
                          context: dialogContext,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedMeetingTime != null) {
                          setState(() => meetingTime = pickedMeetingTime);
                        }
                      },
                      child: Text(
                        meetingTime == null
                            ? '集合時間を選択（任意）'
                            : meetingTime!.format(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _showFriendSelectorDialog,
                      icon: const Icon(Icons.group_add),
                      label: const Text('友達を招待'),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (alarmDate != null && alarmTime != null) {
                      String finalTitle = title;

                      if (finalTitle.isEmpty) {
                        // 既存のアラームタイトル一覧を取得
                        final existingTitles =
                            alarms
                                .map((alarm) => alarm['title'] as String)
                                .toSet();

                        int counter = 1;
                        while (true) {
                          final generatedTitle = 'アラーム$counter';
                          if (!existingTitles.contains(generatedTitle)) {
                            finalTitle = generatedTitle;
                            break;
                          }
                          counter++;
                        }
                      }

                      final newAlarm = {
                        'title': finalTitle,
                        'date': alarmDate,
                        'time': alarmTime,
                        'snooze': snoozeInterval,
                        'meeting': meetingTime,
                        'friends': List<String>.from(selectedFriends),
                      };

                      widget.onAlarmAdded(newAlarm);
                      Navigator.pop(dialogContext);

                      Future.delayed(Duration.zero, () {
                        showCustomNotification(context, 'アラームが追加されました');
                      });
                    } else {
                      // ❌ ダイアログは閉じず、警告だけ表示
                      showCustomNotification(context, '必須項目をすべて入力してください');
                    }
                  },

                  child: const Text('追加'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _showAddAlarmDialog,
          child: const Text('アラームを追加'),
        ),
        const SizedBox(height: 16),
        ...alarms.map(
          (alarm) => Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: ListTile(
              title: Text(alarm['title']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '日付: ${alarm['date'].year}/${alarm['date'].month}/${alarm['date'].day}',
                  ),
                  Text('アラーム時間: ${alarm['time'].format(context)}'),
                  Text('スヌーズ間隔: ${alarm['snooze']}分'),
                  if (alarm['meeting'] != null)
                    Text('集合時間: ${alarm['meeting'].format(context)}'),
                  if (alarm['friends'] != null && alarm['friends'].isNotEmpty)
                    Text('招待したフレンド: ${alarm['friends'].join(', ')}'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
