import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../../../core/services/local_db.dart';

class GoalProvider extends ChangeNotifier {
  List<GoalModel> _goals = [];

  List<GoalModel> get goals => _goals;
  List<GoalModel> get activeGoals => _goals.where((g) => !g.isCompleted).toList();
  List<GoalModel> get completedGoals => _goals.where((g) => g.isCompleted).toList();

  void load() {
    final raw = LocalDb.goals.get('all') as List?;
    if (raw == null) {
      _goals = [];
    } else {
      _goals = raw
          .map((m) => GoalModel.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList();
    }
    notifyListeners();
  }

  Future<void> addGoal(GoalModel g) async {
    _goals.add(g);
    await _save();
  }

  Future<void> updateGoal(GoalModel g) async {
    final idx = _goals.indexWhere((x) => x.id == g.id);
    if (idx != -1) {
      _goals[idx] = g;
      await _save();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _save();
  }

  Future<void> addSavingsToGoal(String goalId, double amount) async {
    final goal = _goals.firstWhere((g) => g.id == goalId);
    goal.savedAmount =
        (goal.savedAmount + amount).clamp(0, goal.targetAmount);
    await _save();
  }

  Future<void> _save() async {
    await LocalDb.goals.put(
      'all',
      _goals.map((g) => g.toMap()).toList(),
    );
    notifyListeners();
  }
}
