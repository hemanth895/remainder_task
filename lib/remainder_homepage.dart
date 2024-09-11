import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remainder/remainder_model.dart';
import 'package:remainder/remainders_provider.dart';
import 'package:remainder/selected_day_provider.dart';
import 'package:remainder/time_provider.dart';
import 'package:remainder/activity_provider.dart';
import 'package:remainder/notification_plugin_provider.dart';

class ReminderHomePage extends ConsumerStatefulWidget {
  const ReminderHomePage({Key? key}) : super(key: key);

  @override
  _ReminderHomePageState createState() => _ReminderHomePageState();
}

class _ReminderHomePageState extends ConsumerState<ReminderHomePage> {
  @override
  void initState() {
    super.initState();
    initializeNotifications();
    ref
        .read(remindersProvider.notifier)
        .loadReminders(); // Load reminders when the app starts
  }

  Future<void> initializeNotifications() async {
    final notificationsPlugin = ref.read(notificationsPluginProvider);

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title ?? 'Notification'),
        content: Text(body ?? 'No content'),
        actions: [
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> onSelectNotification(NotificationResponse response) async {
    String? payload = response.payload;
    if (payload != null) {
      print('Notification payload: $payload');
    }
  }

  Future<void> scheduleNotification(TimeOfDay time, String activity) async {
    final DateTime now = DateTime.now();
    final DateTime scheduleDate =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    if (scheduleDate.isAfter(now)) {
      final notificationsPlugin = ref.read(notificationsPluginProvider);
      notificationsPlugin.schedule(
        0,
        'Reminder',
        'Time for $activity!',
        scheduleDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  Future<void> showAddReminderDialog(BuildContext context) async {
    final selectedDay = ref.read(selectedDayProvider);
    final selectedTime = ref.read(selectedTimeProvider);
    final selectedActivity = ref.read(selectedActivityProvider);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedDay,
              onChanged: (String? newValue) {
                ref.read(selectedDayProvider.notifier).state = newValue!;
              },
              items: [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (pickedTime != null) {
                  ref.read(selectedTimeProvider.notifier).state = pickedTime;
                }
              },
              child: Text('Select Time: ${selectedTime.format(context)}'),
            ),
            DropdownButton<String>(
              value: selectedActivity,
              onChanged: (String? newValue) {
                ref.read(selectedActivityProvider.notifier).state = newValue!;
              },
              items: [
                'Wake up',
                'Go to gym',
                'Breakfast',
                'Meetings',
                'Lunch',
                'Quick nap',
                'Go to library',
                'Dinner',
                'Go to sleep',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final reminder = Reminder(
                ref.read(selectedDayProvider),
                ref.read(selectedTimeProvider),
                ref.read(selectedActivityProvider),
              );
              ref.read(remindersProvider.notifier).addReminder(reminder);
              scheduleNotification(
                ref.read(selectedTimeProvider),
                ref.read(selectedActivityProvider),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder App'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return ListTile(
                  title: Text('${reminder.activity} on ${reminder.day}'),
                  subtitle: Text('At ${reminder.time.format(context)}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddReminderDialog(context),
        tooltip: "Add Reminder",
        child: const Icon(Icons.add),
      ),
    );
  }
}
