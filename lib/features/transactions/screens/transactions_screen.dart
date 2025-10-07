import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../widgets/add_transaction_sheet.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _search = '';

  void _showAdd() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AddTransactionSheet(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TransactionProvider>(
        builder: (_, tp, __) {
          final filtered = tp.transactions
              .where((t) => t.isExpense &&
                  (_search.isEmpty ||
                      t.title.toLowerCase().contains(_search.toLowerCase()) ||
                      t.category.toLowerCase().contains(_search.toLowerCase())))
              .toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 0,
                title: const Text('Expense Tracking'),
                actions: [
                  IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: () {}),
                ],
              ),
              SliverToBoxAdapter(child: _buildHeader(tp)),
              SliverToBoxAdapter(child: _buildDonutChart(tp)),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: const Text('Recent Transactions',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey.shade500),
                        const SizedBox(height: 12),
                        const Text('No expenses yet'),
                        Text('Tap + to add', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _TxCard(t: filtered[i]),
                    childCount: filtered.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAdd,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }

  Widget _buildHeader(TransactionProvider tp) => Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFF8B7FF5)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total Expenses (This Month)',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 6),
            Text(Formatters.currency(tp.totalExpense),
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => showModalBottomSheet(
                  context: context, isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AddTransactionSheet(),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Transaction'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(0, 42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildDonutChart(TransactionProvider tp) {
    final cats = tp.expenseByCategory;
    if (cats.isEmpty) return const SizedBox.shrink();

    final sorted = cats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = cats.values.fold(0.0, (s, v) => s + v);
    final colors = sorted.map((e) => AppColors.categoryColor(e.key)).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category Breakdown',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: sorted.asMap().entries.map((e) {
                    return PieChartSectionData(
                      value: e.value.value,
                      color: colors[e.key],
                      radius: 40,
                      title: '',
                    );
                  }).toList(),
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sorted.take(6).toList().asMap().entries.map((e) {
                    final pct = (e.value.value / total * 100).toStringAsFixed(0);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 10, height: 10,
                            decoration: BoxDecoration(color: colors[e.key], shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(e.value.key.split(' ').first,
                            style: const TextStyle(fontSize: 11)),
                        const SizedBox(width: 2),
                        Text('$pct%',
                            style: TextStyle(fontSize: 11,
                                color: Theme.of(context).textTheme.bodyMedium?.color)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: TextField(
          onChanged: (v) => setState(() => _search = v),
          decoration: InputDecoration(
            hintText: 'Search transactions...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: const Icon(Icons.tune_rounded, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
        ),
      );
}

class _TxCard extends StatelessWidget {
  final TransactionModel t;
  const _TxCard({required this.t});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(t.category);
    final icon = AppColors.categoryIcon(t.category);

    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withAlpha(20),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (_) => context.read<TransactionProvider>().deleteTransaction(t.id),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(Formatters.date(t.date),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withAlpha(15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(t.category,
                            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '-${Formatters.currency(t.amount)}',
              style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
