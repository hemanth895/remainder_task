import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTimeProvider = StateProvider<TimeOfDay>((ref) => TimeOfDay.now());
