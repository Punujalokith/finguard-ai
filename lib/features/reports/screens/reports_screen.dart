import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/models/transaction_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

enum _Period { daily, monthly, yearly }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  _Period _period = _Period.monthly;

  // Daily state
  DateTime _selectedDay = DateTime.now();

  // Monthly state
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // Yearly state
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) return;
      setState(() {
        switch (_tabCtrl.index) {
          case 0: _period = _Period.daily; break;
          case 1: _period = _Period.monthly; break;
          case 2: _period = _Period.yearly; break;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<TransactionModel> _getTransactions(TransactionProvider tp) {
    switch (_period) {
      case _Period.daily:
        return tp.getForDay(_selectedDay);
      case _Period.monthly:
        return tp.getForMonth(_selectedMonth.year, _selectedMonth.month);
      case _Period.yearly:
        return tp.getForYear(_selectedYear);
    }
  }

  String get _periodLabel {
    switch (_period) {
      case _Period.daily:
        return Formatters.date(_selectedDay);
      case _Period.monthly:
        return Formatters.monthYear(_selectedMonth);
      case _Period.yearly:
        return '$_selectedYear';
    }
  }

  void _previous() {
    setState(() {
      switch (_period) {
        case _Period.daily:
          _selectedDay = _selectedDay.subtract(const Duration(days: 1));
          break;
        case _Period.monthly:
          _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
          break;
        case _Period.yearly:
          _selectedYear--;
          break;
      }
    });
  }

  void _next() {
    setState(() {
      switch (_period) {
        case _Period.daily:
          if (_selectedDay.isBefore(DateTime.now())) {
            _selectedDay = _selectedDay.add(const Duration(days: 1));
          }
          break;
        case _Period.monthly:
          final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
          if (!next.isAfter(DateTime.now())) _selectedMonth = next;
          break;
        case _Period.yearly:
          if (_selectedYear < DateTime.now().year) _selectedYear++;
          break;
      }
    });
  }

  void _pickDate(BuildContext context) async {
    if (_period == _Period.daily) {
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDay,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null) setState(() => _selectedDay = picked);
    }
  }

  void _shareReport(List<TransactionModel> txns, double income, double expense) {
    final buffer = StringBuffer();
    buffer.writeln('FinGuard AI — Financial Report');
    buffer.writeln('Period: $_periodLabel');
    buffer.writeln('Generated: ${DateTime.now().toString().substring(0, 16)}');
    buffer.writeln('');
    buffer.writeln('SUMMARY');
    buffer.writeln('Total Income:  RM ${income.toStringAsFixed(2)}');
    buffer.writeln('Total Expense: RM ${expense.toStringAsFixed(2)}');
    buffer.writeln('Net Balance:   RM ${(income - expense).toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('TRANSACTIONS (${txns.length})');
    buffer.writeln(
        'Date,Title,Category,Type,Amount (RM)');
    for (final t in txns) {
      final d = t.date.toLocal().toString().substring(0, 10);
      final type = t.isIncome ? 'Income' : 'Expense';
      buffer.writeln('$d,${t.title},${t.category},$type,${t.amount.toStringAsFixed(2)}');
    }
    Share.share(buffer.toString(),
        subject: 'FinGuard AI – $_periodLabel Report');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TransactionProvider>(
        builder: (_, tp, __) {
          final txns = _getTransactions(tp);
          final income = tp.incomeFor(txns);
          final expense = tp.expenseFor(txns);
          final net = income - expense;
          final cats = tp.categoriesFor(txns);

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(child: _buildHeader(context, income, expense, net, txns)),
              // Period navigator
              SliverToBoxAdapter(child: _buildPeriodNav(context)),
              // Summary cards
              SliverToBoxAdapter(child: _buildSummaryCards(context, income, expense, net)),
              // Category breakdown
              if (cats.isNotEmpty)
                SliverToBoxAdapter(child: _buildCategoryBreakdown(context, cats, expense)),
              // Transaction list header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    children: [
                      Text('Transactions (${txns.length})',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const Spacer(),
                      if (txns.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _shareReport(txns, income, expense),
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: const Text('Export CSV'),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary),
                        ),
                    ],
                  ),
                ),
              ),
              // Transaction list
              if (txns.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 52, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('No transactions for this period',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _TxRow(t: txns[i]),
                    childCount: txns.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double income, double expense,
      double net, List<TransactionModel> txns) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF00B894)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text('Financial Reports',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ),
              if (txns.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.share_rounded, color: Colors.white70),
                  onPressed: () => _shareReport(txns, income, expense),
                )
              else
                const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabCtrl,
              tabs: const [
                Tab(text: 'Daily'),
                Tab(text: 'Monthly'),
                Tab(text: 'Yearly'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              dividerColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodNav(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: _previous,
            icon: const Icon(Icons.chevron_left_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 16,
                        color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(_periodLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _next,
            icon: const Icon(Icons.chevron_right_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
      BuildContext context, double income, double expense, double net) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'Income',
              amount: income,
              icon: Icons.arrow_upward_rounded,
              color: AppColors.income,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              label: 'Expenses',
              amount: expense,
              icon: Icons.arrow_downward_rounded,
              color: AppColors.expense,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              label: 'Net',
              amount: net,
              icon: Icons.account_balance_wallet_rounded,
              color: net >= 0 ? AppColors.teal : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
      BuildContext context, Map<String, double> cats, double total) {
    final sorted = cats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Expense by Category',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 14),
          ...sorted.take(6).map((e) {
            final pct = total > 0 ? e.value / total : 0.0;
            final color = AppColors.categoryColor(e.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(e.key,
                              style: const TextStyle(fontSize: 13))),
                      Text(Formatters.currency(e.value),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Text('${(pct * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Theme.of(context).dividerColor,
                      color: color,
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  const _SummaryCard(
      {required this.label,
      required this.amount,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            Formatters.currencyCompact(amount.abs()),
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final TransactionModel t;
  const _TxRow({required this.t});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(t.category);
    final icon = AppColors.categoryIcon(t.category);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration:
                BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(Formatters.dateShort(t.date),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 11)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(t.category,
                          style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${t.isIncome ? '+' : '-'}${Formatters.currency(t.amount)}',
            style: TextStyle(
              color: t.isIncome ? AppColors.income : AppColors.expense,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
