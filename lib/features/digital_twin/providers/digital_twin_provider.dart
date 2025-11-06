import 'package:flutter/material.dart';
import 'dart:math';

class MonthProjection {
  final DateTime month;
  final double projectedIncome;
  final double projectedExpense;
  final double projectedBalance;
  final double projectedSavings;

  MonthProjection({
    required this.month,
    required this.projectedIncome,
    required this.projectedExpense,
    required this.projectedBalance,
    required this.projectedSavings,
  });
}

class LifeEventSimulation {
  final String eventName;
  final double eventCost;
  final int monthsToAfford;
  final double requiredMonthlySaving;
  final bool isFeasible;

  LifeEventSimulation({
    required this.eventName,
    required this.eventCost,
    required this.monthsToAfford,
    required this.requiredMonthlySaving,
    required this.isFeasible,
  });
}

class DigitalTwinProvider extends ChangeNotifier {
  double _avgMonthlyIncome = 0;
  double _avgMonthlyExpense = 0;
  double _currentBalance = 0;
  double _incomeGrowthRate = 0.02;
  double _expenseGrowthRate = 0.03;
  List<MonthProjection> _projections = [];

  List<MonthProjection> get projections => _projections;
  double get avgMonthlyIncome => _avgMonthlyIncome;
  double get avgMonthlyExpense => _avgMonthlyExpense;
  double get avgMonthlySavings => _avgMonthlyIncome - _avgMonthlyExpense;
  double get projectedAnnualSavings => avgMonthlySavings * 12;

  String get financialHealthStatus {
    final rate = _avgMonthlyIncome > 0
        ? (_avgMonthlyIncome - _avgMonthlyExpense) / _avgMonthlyIncome
        : 0.0;
    if (rate >= 0.3) return 'Excellent';
    if (rate >= 0.15) return 'Good';
    if (rate >= 0.05) return 'Fair';
    return 'At Risk';
  }

  Color get healthColor {
    switch (financialHealthStatus) {
      case 'Excellent':
        return const Color(0xFF4CAF50);
      case 'Good':
        return const Color(0xFF2196F3);
      case 'Fair':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFFE53935);
    }
  }

  void updateFromTransactions({
    required double totalIncome,
    required double totalExpense,
    required double balance,
    int monthsOfData = 1,
  }) {
    _avgMonthlyIncome = totalIncome / monthsOfData;
    _avgMonthlyExpense = totalExpense / monthsOfData;
    _currentBalance = balance;
    _generateProjections(12);
    notifyListeners();
  }

  void _generateProjections(int months) {
    _projections = [];
    double runningBalance = _currentBalance;
    final now = DateTime.now();

    for (int i = 1; i <= months; i++) {
      // Apply growth rates with slight Monte Carlo noise
      final noise = 1 + (Random().nextDouble() - 0.5) * 0.05;
      final income = _avgMonthlyIncome * pow(1 + _incomeGrowthRate, i / 12) * noise;
      final expense = _avgMonthlyExpense * pow(1 + _expenseGrowthRate, i / 12) * noise;
      final savings = income - expense;
      runningBalance += savings;

      _projections.add(MonthProjection(
        month: DateTime(now.year, now.month + i),
        projectedIncome: income,
        projectedExpense: expense,
        projectedBalance: runningBalance,
        projectedSavings: savings,
      ));
    }
  }

  LifeEventSimulation simulateLifeEvent(String eventName, double eventCost) {
    final availableMonthlySaving = avgMonthlySavings * 0.5;
    if (availableMonthlySaving <= 0) {
      return LifeEventSimulation(
        eventName: eventName,
        eventCost: eventCost,
        monthsToAfford: 999,
        requiredMonthlySaving: eventCost,
        isFeasible: false,
      );
    }
    final months = (eventCost / availableMonthlySaving).ceil();
    return LifeEventSimulation(
      eventName: eventName,
      eventCost: eventCost,
      monthsToAfford: months,
      requiredMonthlySaving: availableMonthlySaving,
      isFeasible: months <= 60,
    );
  }

  void setGrowthRates(double incomeGrowth, double expenseGrowth) {
    _incomeGrowthRate = incomeGrowth;
    _expenseGrowthRate = expenseGrowth;
    _generateProjections(12);
    notifyListeners();
  }
}
