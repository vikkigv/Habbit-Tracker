import 'dart:convert';
import 'package:flutter/material.dart';
class Habit {
  final String id;
  String name;
  int colorValue;
  String emoji;
  Map<String, bool> checkedDays;
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.emoji,
    Map<String, bool>? checkedDays,
    DateTime? createdAt,
  })  : checkedDays = checkedDays ?? {},
        createdAt = createdAt ?? DateTime.now();

  String get dateKey => _formatDate(DateTime.now());

  bool isCheckedOn(DateTime date) {
    return checkedDays[_formatDate(date)] ?? false;
  }

  void toggleDay(DateTime date) {
    final key = _formatDate(date);
    checkedDays[key] = !(checkedDays[key] ?? false);
  }

  int get currentStreak {
    int streak = 0;
    DateTime day = DateTime.now();
    while (true) {
      if (checkedDays[_formatDate(day)] ?? false) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int get totalDone => checkedDays.values.where((v) => v).length;

  int get thisMonthDone {
    final now = DateTime.now();
    int count = 0;
    for (int d = 1; d <= now.day; d++) {
      final key = _formatDate(DateTime(now.year, now.month, d));
      if (checkedDays[key] ?? false) count++;
    }
    return count;
  }

  double get thisMonthRate {
    final now = DateTime.now();
    if (now.day == 0) return 0;
    return thisMonthDone / now.day;
  }

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'emoji': emoji,
        'checkedDays': checkedDays,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'],
        name: json['name'],
        colorValue: json['colorValue'],
        emoji: json['emoji'] ?? '✅',
        checkedDays: Map<String, bool>.from(json['checkedDays'] ?? {}),
        createdAt: DateTime.parse(json['createdAt']),
      );

  static List<Habit> listFromJson(String jsonStr) {
    final List decoded = jsonDecode(jsonStr);
    return decoded.map((e) => Habit.fromJson(e)).toList();
  }

  static String listToJson(List<Habit> habits) {
    return jsonEncode(habits.map((h) => h.toJson()).toList());
  }
}

const List<Map<String, dynamic>> kHabitColors = [
  {'color': Color(0xFF1D9E75), 'label': 'Teal'},
  {'color': Color(0xFF378ADD), 'label': 'Blue'},
  {'color': Color(0xFFD4537E), 'label': 'Pink'},
  {'color': Color(0xFF7F77DD), 'label': 'Purple'},
  {'color': Color(0xFFD85A30), 'label': 'Coral'},
  {'color': Color(0xFF639922), 'label': 'Green'},
  {'color': Color(0xFFBA7517), 'label': 'Amber'},
  {'color': Color(0xFFE24B4A), 'label': 'Red'},
  {'color': Color(0xFF0F6E56), 'label': 'Forest'},
  {'color': Color(0xFF533AB7), 'label': 'Violet'},
];

const List<String> kHabitEmojis = [
  '💧', '🏃', '📚', '🧘', '💪', '🥗', '😴', '✍️',
  '🎯', '🧠', '🎵', '🌱', '☀️', '🍎', '💊', '🧹',
  '💰', '🙏', '❤️', '⭐',
];

