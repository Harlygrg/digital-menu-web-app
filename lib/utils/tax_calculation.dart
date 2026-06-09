import '../models/tax_settings_model.dart';

/// Rounds monetary tax values to 2 decimal places (e.g. 5.325 → 5.33).
double roundTaxAmount(double value) {
  return (value * 100).roundToDouble() / 100;
}

/// One line of tax for display (cart summary).
class TaxLineDisplay {
  final String taxName;
  final double pretaxBase;
  final double amount;
  final bool isInclusive;

  const TaxLineDisplay({
    required this.taxName,
    required this.pretaxBase,
    required this.amount,
    required this.isInclusive,
  });
}

/// Result of applying branch tax rules to a cart total.
class TaxBreakdown {
  final double cartTotal;
  final double pretaxSubtotal;
  final double totalTax;
  final double netTotal;
  final List<TaxLineDisplay> lines;

  const TaxBreakdown({
    required this.cartTotal,
    required this.pretaxSubtotal,
    required this.totalTax,
    required this.netTotal,
    required this.lines,
  });

  /// Original cart sum before tax adjustments (alias for [cartTotal]).
  double get grossTotal => cartTotal;
}

/// Computes tax from cart total using [TaxSettingsData].
///
/// Tax applies only when [TaxSettingsData.taxEnabled] is true and [TaxSettingsData.taxes]
/// is non-empty. Inclusive taxes extract tax from the total; exclusive taxes add on top.
TaxBreakdown computeTaxBreakdown({
  required TaxSettingsData? settings,
  required double grossTotal,
}) {
  final cartTotal = grossTotal;

  if (settings == null || !settings.taxEnabled || settings.taxes.isEmpty) {
    return TaxBreakdown(
      cartTotal: cartTotal,
      pretaxSubtotal: cartTotal,
      totalTax: 0,
      netTotal: cartTotal,
      lines: const [],
    );
  }

  final lines = <TaxLineDisplay>[];
  var totalTax = 0.0;
  var inclusiveTax = 0.0;
  var exclusiveTax = 0.0;

  for (final t in settings.taxes) {
    final rate = t.taxPercentage;
    final double taxAmount;
    final double pretaxBase;

    if (t.isInclusive) {
      taxAmount = roundTaxAmount(cartTotal * rate / (100.0 + rate));
      pretaxBase = roundTaxAmount(cartTotal - taxAmount);
      inclusiveTax += taxAmount;
    } else {
      taxAmount = roundTaxAmount(cartTotal * rate / 100.0);
      pretaxBase = cartTotal;
      exclusiveTax += taxAmount;
    }

    totalTax += taxAmount;
    final baseName = t.taxName.trim().isNotEmpty ? t.taxName : t.taxType;
    lines.add(
      TaxLineDisplay(
        taxName: baseName,
        pretaxBase: pretaxBase,
        amount: taxAmount,
        isInclusive: t.isInclusive,
      ),
    );
  }

  final pretaxSubtotal = roundTaxAmount(cartTotal - inclusiveTax);
  final netTotal = roundTaxAmount(cartTotal + exclusiveTax);
  totalTax = roundTaxAmount(totalTax);

  return TaxBreakdown(
    cartTotal: cartTotal,
    pretaxSubtotal: pretaxSubtotal,
    totalTax: totalTax,
    netTotal: netTotal,
    lines: lines,
  );
}
