import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remainder/remainder_model.dart';

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<Reminder>>((ref) {
  return RemindersNotifier()..loadReminders();
});

class RemindersNotifier extends StateNotifier<List<Reminder>> {
  RemindersNotifier() : super([]);

  Future<void> addReminder(Reminder reminder) async {
    final newList = [...state, reminder];
    state = newList;
    await _saveReminders(newList);
  }

  Future<void> _saveReminders(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson =
        reminders.map((reminder) => reminder.toJson()).toList();
    await prefs.setString('reminders', jsonEncode(remindersJson));
  }

  Future<void> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersString = prefs.getString('reminders');
    if (remindersString != null) {
      final List<dynamic> remindersJson = jsonDecode(remindersString);
      state = remindersJson.map((json) => Reminder.fromJson(json)).toList();
    }
  }
}
