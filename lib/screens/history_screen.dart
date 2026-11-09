import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/common.dart';
import '../models/transaction.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _query = '';
  int _filter = 0; // 0 all, 1 income, 2 expense

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    final list = p.items.where((t) {
      final okType = _filter == 0 || (_filter == 1) == t.isIncome;
      final q = _query.toLowerCase();
      final okQuery = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.category.label.toLowerCase().contains(q);
      return okType && okQuery;
    }).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(children: [
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Search by title or category',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            for (final e in const ['All', 'Income', 'Expense'].asMap().entries)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(e.value),
                  selected: _filter == e.key,
                  onSelected: (_) => setState(() => _filter = e.key),
                ),
              ),
          ]),
        ]),
      ),
      Expanded(
        child: list.isEmpty
            ? const Center(child: Text('No matching transactions'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final t = list[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Dismissible(
                      key: ValueKey(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        final prov = context.read<ExpenseProvider>();
                        prov.remove(t.id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Deleted "${t.title}"'),
                          action: SnackBarAction(
                              label: 'UNDO', onPressed: () => prov.add(t)),
                        ));
                      },
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: TxTile(tx: t),
                      ),
                    ),
                  );
                },
              ),
      ),
    ]);
  }
}
