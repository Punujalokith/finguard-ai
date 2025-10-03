import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../../../core/services/local_db.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  double get totalIncome => _transactions
      .where((t) => t.isIncome).fold(0, (s, t) => s + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.isExpense).fold(0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;

  double get savingsRate =>
      totalIncome > 0 ? ((totalIncome - totalExpense) / totalIncome) * 100 : 0;

  Map<String, double> get expenseByCategory {
    final Map<String, double> map = {};
    for (final t in _transactions.where((t) => t.isExpense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  String get spenderType {
    if (savingsRate >= 30) return 'Goal-Oriented Saver';
    if (savingsRate >= 15) return 'Planned Spender';
    if (savingsRate < 0) return 'Impulsive Spender';
    return 'Seasonal Spender';
  }

  int get healthScore {
    if (totalIncome == 0) return 50;
    int score = 0;
    // Savings rate (max 40pts)
    score += (savingsRate.clamp(0, 40)).toInt();
    // Budget adherence (max 30pts)
    if (totalExpense <= totalIncome) {
      score += 30;
    } else {
      score += ((totalIncome / totalExpense) * 30).toInt().clamp(0, 30);
    }
    // Transaction diversity (max 15pts)
    score += expenseByCategory.length.clamp(0, 5) * 3;
    // Has income (max 15pts)
    if (totalIncome > 0) score += 15;
    return score.clamp(0, 100);
  }

  bool _loaded = false;
  bool get isLoaded => _loaded;

  String get aiInsight {
    if (!_loaded) return 'Loading your financial insights…';

    final cats = expenseByCategory;

    // No data at all
    if (_transactions.isEmpty) {
      return '👋 Welcome! Add your first income or expense transaction to unlock personalized AI insights.';
    }

    // Has income but no expenses yet
    if (cats.isEmpty && totalIncome > 0) {
      return '💰 You\'ve recorded income — now start logging expenses to see how your money is being spent.';
    }

    // Has expenses but no income recorded
    if (cats.isEmpty) {
      return '📊 Add your income transactions so FinGuard AI can calculate your savings rate and health score.';
    }

    final sorted = cats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    final pct = totalExpense > 0
        ? (top.value / totalExpense * 100).toStringAsFixed(0)
        : '0';

    // Overspending
    if (savingsRate < 0) {
      return '⚠️ You\'re spending more than you earn this month. ${top.key} accounts for $pct% of expenses — review this category to get back on track.';
    }

    // Very low savings
    if (savingsRate < 10) {
      return '💡 Your savings rate is ${savingsRate.toStringAsFixed(0)}%. Cutting ${top.key} spending (currently $pct% of budget) could make a big difference.';
    }

    // Moderate savings
    if (savingsRate < 30) {
      final rate = savingsRate.toStringAsFixed(0);
      return '📈 You\'re saving $rate% of your income. Your top expense is ${top.key} at $pct%. Aim for 30%+ to build a solid emergency fund.';
    }

    // Excellent savings
    return '🏆 Excellent! You\'re saving ${savingsRate.toStringAsFixed(0)}% of your income. ${top.key} is your top expense at $pct%. Keep up the great work!';
  }

  List<TransactionModel> get recentTransactions => _transactions.take(10).toList();

  // ── CRUD ─────────────────────────────────────────────────────────────────

  void load() {
    final raw = LocalDb.transactions.get('all') as List?;
    _transactions = raw == null
        ? []
        : raw
            .map((m) => TransactionModel.fromMap(
                Map<String, dynamic>.from(m as Map)))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    _loaded = true;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel t) async {
    _transactions.insert(0, t);
    await _save();
  }

  Future<void> updateTransaction(TransactionModel t) async {
    final idx = _transactions.indexWhere((x) => x.id == t.id);
    if (idx != -1) {
      _transactions[idx] = t;
      await _save();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _save();
  }

  Future<void> _save() async {
    await LocalDb.transactions.put(
        'all', _transactions.map((t) => t.toMap()).toList());
    notifyListeners();
  }

  // ── Period Filtering ──────────────────────────────────────────────────────

  List<TransactionModel> getForDay(DateTime day) => _transactions
      .where((t) =>
          t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day)
      .toList();

  List<TransactionModel> getForMonth(int year, int month) => _transactions
      .where((t) => t.date.year == year && t.date.month == month)
      .toList();

  List<TransactionModel> getForYear(int year) =>
      _transactions.where((t) => t.date.year == year).toList();

  double incomeFor(List<TransactionModel> txns) =>
      txns.where((t) => t.isIncome).fold(0, (s, t) => s + t.amount);

  double expenseFor(List<TransactionModel> txns) =>
      txns.where((t) => t.isExpense).fold(0, (s, t) => s + t.amount);

  Map<String, double> categoriesFor(List<TransactionModel> txns) {
    final Map<String, double> map = {};
    for (final t in txns.where((t) => t.isExpense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  List<int> get transactionYears {
    final years = _transactions.map((t) => t.date.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    if (years.isEmpty) years.add(DateTime.now().year);
    return years;
  }

  // ── Charts ────────────────────────────────────────────────────────────────

  Map<int, double> getMonthlyExpenses(int months) {
    final Map<int, double> result = {};
    final now = DateTime.now();
    for (int i = months - 1; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i);
      result[months - 1 - i] = _transactions
          .where((t) =>
              t.isExpense &&
              t.date.month == m.month &&
              t.date.year == m.year)
          .fold(0.0, (s, t) => s + t.amount);
    }
    return result;
  }

  // ── Fraud ─────────────────────────────────────────────────────────────────

  List<TransactionModel> get fraudAlerts => _transactions
      .where((t) => t.isExpense && t.amount > 500)
      .take(5)
      .toList();
}
