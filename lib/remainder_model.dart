// Model for storing reminders
import 'package:flutter/material.dart';

//class Reminder {
//  final String day;
//  final TimeOfDay time;
//  final String activity;

//  Reminder(this.day, this.time, this.activity);
//}


class Reminder {
  final String day;
  final TimeOfDay time;
  final String activity;

  Reminder(this.day, this.time, this.activity);

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'time': '${time.hour}:${time.minute}',
      'activity': activity,
    };
  }

  static Reminder fromJson(Map<String, dynamic> json) {
    final timeParts = json['time'].split(':');
    return Reminder(
      json['day'],
      TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
      json['activity'],
    );
  }
}
