import 'package:uuid/uuid.dart';

class GoalModel {
  final String id;
  final String title;
  final String emoji;
  final double targetAmount;
  double savedAmount;
  final DateTime targetDate;
  final DateTime createdAt;

  GoalModel({
    String? id,
    required this.title,
    required this.emoji,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.targetDate,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  double get progress =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0;
  double get remaining => (targetAmount - savedAmount).clamp(0, double.infinity);
  bool get isCompleted => savedAmount >= targetAmount;
  int get daysLeft => targetDate.difference(DateTime.now()).inDays;

  double get requiredMonthlySaving {
    final months = daysLeft / 30;
    if (months <= 0) return remaining;
    return remaining / months;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'emoji': emoji,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'targetDate': targetDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory GoalModel.fromMap(Map<String, dynamic> map) => GoalModel(
        id: map['id'] as String,
        title: map['title'] as String,
        emoji: map['emoji'] as String? ?? '🎯',
        targetAmount: (map['targetAmount'] as num).toDouble(),
        savedAmount: (map['savedAmount'] as num).toDouble(),
        targetDate: DateTime.parse(map['targetDate'] as String),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
