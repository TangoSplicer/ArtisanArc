import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../data/tax_models.dart';
import '../../business/data/sale_model.dart';
import '../../inventory/data/material_purchase_model.dart';

class TaxService {
  static const String _expenseBoxName = 'businessExpensesBox';
  static const String _configBoxName = 'taxYearConfigsBox';
  static const String _salesBoxName = 'salesBox';
  static const String _purchasesBoxName = 'materialPurchasesBox';

  final _uuid = const Uuid();

  Future<Box<BusinessExpense>> _openExpenseBox() async {
    if (!Hive.isBoxOpen(_expenseBoxName)) {
      return await Hive.openBox<BusinessExpense>(_expenseBoxName);
    }
    return Hive.box<BusinessExpense>(_expenseBoxName);
  }

  Future<Box<TaxYearConfig>> _openConfigBox() async {
    if (!Hive.isBoxOpen(_configBoxName)) {
      return await Hive.openBox<TaxYearConfig>(_configBoxName);
    }
    return Hive.box<TaxYearConfig>(_configBoxName);
  }

  // UK 2026/27 Tax Year Defaults
  TaxYearConfig getUK2026Defaults() {
    return TaxYearConfig(
      id: 'uk-2026-27',
      yearLabel: '2026/27',
      startDate: DateTime(2026, 4, 6),
      endDate: DateTime(2027, 4, 5),
      personalAllowance: 12570.0,
      basicRateThreshold: 37700.0,
      basicRatePercent: 0.20,
      higherRatePercent: 0.40,
    );
  }

  Future<List<BusinessExpense>> getExpenses(
      {DateTime? start, DateTime? end}) async {
    final box = await _openExpenseBox();
    var list = box.values.toList();
    if (start != null)
      list = list
          .where((e) => e.date.isAfter(start) || e.date.isAtSameMomentAs(start))
          .toList();
    if (end != null)
      list = list
          .where((e) => e.date.isBefore(end) || e.date.isAtSameMomentAs(end))
          .toList();
    return list..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveExpense(BusinessExpense expense) async {
    final box = await _openExpenseBox();
    await box.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    final box = await _openExpenseBox();
    await box.delete(id);
  }

  Future<Map<String, double>> estimateUKTax({
    required double totalRevenue,
    required double totalAllowableExpenses,
    required TaxYearConfig config,
  }) async {
    final profit = totalRevenue - totalAllowableExpenses;
    if (profit <= config.personalAllowance) {
      return {'profit': profit, 'tax': 0.0, 'net': profit};
    }

    final taxableIncome = profit - config.personalAllowance;
    double tax = 0.0;

    if (taxableIncome <= config.basicRateThreshold) {
      tax = taxableIncome * config.basicRatePercent;
    } else {
      final basicTax = config.basicRateThreshold * config.basicRatePercent;
      final higherTax = (taxableIncome - config.basicRateThreshold) *
          config.higherRatePercent;
      tax = basicTax + higherTax;
    }

    return {
      'profit': profit,
      'taxableIncome': taxableIncome,
      'tax': tax,
      'net': profit - tax,
    };
  }
}
