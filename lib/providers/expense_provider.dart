import 'dart:convert';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class ExpenseProvider extends ChangeNotifier {
  static const _kTx = 'transactions';
  static const _kName = 'name';
  static const _kBudget = 'budget';

  final List<TransactionItem> _items = [];
  String userName = '';
  double budget = 30000;

  List<TransactionItem> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString(_kName) ?? '';
    budget = prefs.getDouble(_kBudget) ?? 30000;
    final raw = prefs.getString(_kTx);
    _items.clear();
    if (raw == null) {
      _items.addAll(_seed());
    } else {
      _items.addAll((jsonDecode(raw) as List)
          .map((e) => TransactionItem.fromJson(e as Map<String, dynamic>)));
    }
    _sort();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, userName);
    await prefs.setDouble(_kBudget, budget);
    await prefs.setString(
        _kTx, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  void _sort() => _items.sort((a, b) => b.date.compareTo(a.date));

  void _changed() {
    _sort();
    notifyListeners();
    _save();
  }

  void add(TransactionItem t) {
    _items.add(t);
    _changed();
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
    _changed();
  }

  void setUser(String name) {
    userName = name.trim();
    _changed();
  }

  void setBudget(double v) {
    budget = v;
    _changed();
  }

  void signOut() {
    userName = '';
    _changed();
  }

  void resetDemoData() {
    _items
      ..clear()
      ..addAll(_seed());
    _changed();
  }

  Iterable<TransactionItem> get _thisMonth {
    final now = DateTime.now();
    return _items
        .where((e) => e.date.year == now.year && e.date.month == now.month);
  }

  double get totalIncome =>
      _items.where((e) => e.isIncome).fold(0.0, (s, e) => s + e.amount);
  double get totalExpense =>
      _items.where((e) => !e.isIncome).fold(0.0, (s, e) => s + e.amount);
  double get balance => totalIncome - totalExpense;

  double get monthIncome =>
      _thisMonth.where((e) => e.isIncome).fold(0.0, (s, e) => s + e.amount);
  double get monthExpense =>
      _thisMonth.where((e) => !e.isIncome).fold(0.0, (s, e) => s + e.amount);

  Map<Category, double> get monthByCategory {
    final m = <Category, double>{};
    for (final e in _thisMonth.where((e) => !e.isIncome)) {
      m[e.category] = (m[e.category] ?? 0) + e.amount;
    }
    return m;
  }

  /// Spending for the last 7 days, oldest first.
  List<double> get last7Days {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return _items
          .where((e) =>
              !e.isIncome &&
              e.date.year == d.year &&
              e.date.month == d.month &&
              e.date.day == d.day)
          .fold(0.0, (s, e) => s + e.amount);
    });
  }

  List<TransactionItem> _seed() {
    final now = DateTime.now();
    TransactionItem t(String id, String title, double amt, bool inc,
            Category c, int daysAgo) =>
        TransactionItem(
          id: id,
          title: title,
          amount: amt,
          isIncome: inc,
          category: c,
          date: now.subtract(Duration(days: daysAgo)),
        );
    return [
      t('s1', 'Monthly stipend', 42000, true, Category.salary, 0),
      t('s2', 'Groceries', 2450, false, Category.food, 0),
      t('s3', 'Metro card recharge', 800, false, Category.travel, 1),
      t('s4', 'Online course', 3999, false, Category.learning, 2),
      t('s5', 'Electricity bill', 1850, false, Category.bills, 3),
      t('s6', 'Headphones', 2999, false, Category.shopping, 4),
      t('s7', 'Pharmacy', 640, false, Category.health, 5),
      t('s8', 'Lunch with friends', 920, false, Category.food, 6),
    ];
  }
}
