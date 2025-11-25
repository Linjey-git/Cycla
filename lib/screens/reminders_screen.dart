import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/theme.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../main.dart' show flutterLocalNotificationsPlugin;

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Map<String, dynamic>> reminders = [];

  @override
  void initState() {
    super.initState();
    // _loadReminders();

    Future.microtask(() async {
      await _loadReminders();
    });
  }

  Future<void> _loadReminders() async {
    final data = await DatabaseService.instance.getAllReminders();
    setState(() {
      reminders = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Нагадування')),
      body: reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Немає нагадувань',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Натисніть + щоб додати',
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return _buildReminderCard(reminder);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Додати'),
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    final isActive = reminder['is_active'] == 1;
    final time = DateTime.parse(reminder['time'] as String);
    final title = reminder['title'] as String;
    final description = reminder['description'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.alarm,
            color: isActive ? AppTheme.primaryColor : Colors.grey,
            size: 30,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black87 : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: isActive ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: isActive ? AppTheme.primaryColor : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('HH:mm').format(time),
                  style: TextStyle(
                    color: isActive ? AppTheme.primaryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: isActive,
              activeColor: AppTheme.primaryColor,
              onChanged: (value) async {
                await DatabaseService.instance.updateReminder(
                  reminder['id'] as int,
                  {...reminder, 'is_active': value ? 1 : 0},
                );

                if (value) {
                  // Планування нотифікації
                  await NotificationService.scheduleNotification(
                    id: reminder['id'] as int,
                    title: title,
                    body: description ?? 'Час прийняти ліки',
                    scheduledTime: time,
                    fln: flutterLocalNotificationsPlugin,
                  );
                } else {
                  // Скасування нотифікації
                  await NotificationService.cancelNotification(
                    reminder['id'] as int,
                    flutterLocalNotificationsPlugin,
                  );
                }

                await _loadReminders();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteDialog(reminder['id'] as int),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Нове нагадування'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Назва*',
                    hintText: 'Наприклад: Прийняти вітаміни',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Опис (необов\'язково)',
                    hintText: 'Додаткова інформація',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: const Text('Час'),
                  trailing: TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setDialogState(() {
                          selectedTime = time;
                        });
                      }
                    },
                    child: Text(
                      selectedTime.format(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Скасувати'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Будь ласка, введіть назву')),
                  );
                  return;
                }

                final now = DateTime.now();
                final scheduledTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                final id = await DatabaseService.instance.saveReminder({
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'time': scheduledTime.toIso8601String(),
                  'is_active': 1,
                });

                // Планування нотифікації
                await NotificationService.scheduleNotification(
                  id: id,
                  title: titleController.text,
                  body: descriptionController.text.isEmpty
                      ? 'Час прийняти ліки'
                      : descriptionController.text,
                  scheduledTime: scheduledTime,
                  fln: flutterLocalNotificationsPlugin,
                );

                // КЛЮЧ: оновлюємо локальний список ПЕРЕД закриттям форми
                setState(() {
                  reminders.add({
                    'id': id,
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'time': scheduledTime.toIso8601String(),
                    'is_active': 1,
                  });
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Нагадування додано'),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );

                // Асинхронно оновити повний список з БД (для синхронізації)
                _loadReminders();
              },
              child: const Text('Додати'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити нагадування?'),
        content: const Text('Це нагадування буде видалено назавжди.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseService.instance.deleteReminder(id);
              await NotificationService.cancelNotification(
                id,
                flutterLocalNotificationsPlugin,
              );
              await _loadReminders();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Нагадування видалено')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }
}
