import '../models/cart_item_model.dart';
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

/// Per-line tax payload for create order (item-wise).
class OrderLineTaxPayload {
  final int taxId;
  final double taxAmnt;
  final double taxpercent;
  final String taxtype;
  final String taxname;
  final bool isInclusive;

  const OrderLineTaxPayload({
    required this.taxId,
    required this.taxAmnt,
    required this.taxpercent,
    required this.taxtype,
    required this.taxname,
    required this.isInclusive,
  });
}

/// Input for one order/cart line used in tax calculation.
class TaxableLineInput {
  final int? taxId;
  final double total;

  const TaxableLineInput({
    required this.taxId,
    required this.total,
  });
}

/// Result of applying branch tax rules to a cart / order.
class TaxBreakdown {
  final double cartTotal;
  final double pretaxSubtotal;
  final double totalTax;
  final double netTotal;
  final List<TaxLineDisplay> lines;
  final bool isValid;
  final String? validationError;
  final int taxmode;
  final List<OrderLineTaxPayload?> lineTaxes;
  final TaxItemModel? primaryTax;

  const TaxBreakdown({
    required this.cartTotal,
    required this.pretaxSubtotal,
    required this.totalTax,
    required this.netTotal,
    required this.lines,
    this.isValid = true,
    this.validationError,
    this.taxmode = 0,
    this.lineTaxes = const [],
    this.primaryTax,
  });

  /// Original cart sum before tax adjustments (alias for [cartTotal]).
  double get grossTotal => cartTotal;

  bool get omitHeaderTaxMeta => taxmode == 1;
}

/// Builds [TaxableLineInput]s from cart items (product + modifiers with qty > 0).
List<TaxableLineInput> taxableLinesFromCart(List<CartItemModel> cartItems) {
  final lines = <TaxableLineInput>[];
  for (final cartItem in cartItems) {
    lines.add(
      TaxableLineInput(
        taxId: cartItem.taxId,
        total: cartItem.unitPrice * cartItem.quantity,
      ),
    );
    for (final modifier in cartItem.modifiers) {
      if (modifier.quantity > 0) {
        lines.add(
          TaxableLineInput(
            taxId: modifier.taxId,
            total: modifier.totalPrice,
          ),
        );
      }
    }
  }
  return lines;
}

/// Computes tax from pretax gross using [TaxSettingsData] (bill-wise only).
///
/// Prefer [computeOrderTax] when cart lines / taxmode are available.
TaxBreakdown computeTaxBreakdown({
  required TaxSettingsData? settings,
  required double grossTotal,
}) {
  return computeOrderTax(
    settings: settings,
    lines: [TaxableLineInput(taxId: null, total: grossTotal)],
    forceBillWise: true,
  );
}

/// Unified tax calculation for checkout and create order.
///
/// - `tax_enabled = false` / null settings → zero tax, valid
/// - `taxmode = 0` (or [forceBillWise]) → bill-wise on sum of line totals
/// - `taxmode = 1` → per-line tax via TaxId; invalid if any TaxId missing/unresolvable
TaxBreakdown computeOrderTax({
  required TaxSettingsData? settings,
  required List<TaxableLineInput> lines,
  bool forceBillWise = false,
}) {
  final grosstotal = roundTaxAmount(
    lines.fold<double>(0, (sum, l) => sum + l.total),
  );

  if (settings == null || !settings.taxEnabled || settings.taxes.isEmpty) {
    return TaxBreakdown(
      cartTotal: grosstotal,
      pretaxSubtotal: grosstotal,
      totalTax: 0,
      netTotal: grosstotal,
      lines: const [],
      isValid: true,
      taxmode: settings?.taxmode ?? 0,
      lineTaxes: List<OrderLineTaxPayload?>.filled(lines.length, null),
      primaryTax: null,
    );
  }

  final useItemWise = !forceBillWise && settings.isItemWise;
  if (useItemWise) {
    return _computeItemWise(settings: settings, lines: lines, grosstotal: grosstotal);
  }
  return _computeBillWise(settings: settings, grosstotal: grosstotal, lineCount: lines.length);
}

TaxBreakdown _computeBillWise({
  required TaxSettingsData settings,
  required double grosstotal,
  required int lineCount,
}) {
  final displayLines = <TaxLineDisplay>[];
  var totalTax = 0.0;
  var inclusiveTax = 0.0;
  var exclusiveTax = 0.0;

  for (final t in settings.taxes) {
    final rate = t.taxPercentage;
    final double taxAmount;
    final double pretaxBase;

    if (t.isInclusive) {
      taxAmount = roundTaxAmount(grosstotal * rate / (100.0 + rate));
      pretaxBase = roundTaxAmount(grosstotal - taxAmount);
      inclusiveTax += taxAmount;
    } else {
      taxAmount = roundTaxAmount(grosstotal * rate / 100.0);
      pretaxBase = grosstotal;
      exclusiveTax += taxAmount;
    }

    totalTax += taxAmount;
    final baseName = t.taxName.trim().isNotEmpty ? t.taxName : t.taxType;
    displayLines.add(
      TaxLineDisplay(
        taxName: baseName,
        pretaxBase: pretaxBase,
        amount: taxAmount,
        isInclusive: t.isInclusive,
      ),
    );
  }

  return TaxBreakdown(
    cartTotal: grosstotal,
    pretaxSubtotal: roundTaxAmount(grosstotal - inclusiveTax),
    totalTax: roundTaxAmount(totalTax),
    netTotal: roundTaxAmount(grosstotal + exclusiveTax),
    lines: displayLines,
    isValid: true,
    taxmode: 0,
    lineTaxes: List<OrderLineTaxPayload?>.filled(lineCount, null),
    primaryTax: settings.taxes.isNotEmpty ? settings.taxes.first : null,
  );
}

TaxBreakdown _computeItemWise({
  required TaxSettingsData settings,
  required List<TaxableLineInput> lines,
  required double grosstotal,
}) {
  final lineTaxes = <OrderLineTaxPayload?>[];
  var totalTax = 0.0;
  var exclusiveTax = 0.0;
  var pretaxSubtotal = 0.0;

  for (final line in lines) {
    final taxId = line.taxId;
    if (taxId == null || taxId <= 0) {
      return TaxBreakdown(
        cartTotal: grosstotal,
        pretaxSubtotal: grosstotal,
        totalTax: 0,
        netTotal: grosstotal,
        lines: const [],
        isValid: false,
        validationError:
            'Tax is missing for one or more items. Please refresh the menu or remove items without tax.',
        taxmode: 1,
        lineTaxes: List<OrderLineTaxPayload?>.filled(lines.length, null),
      );
    }

    final master = settings.taxById(taxId);
    if (master == null) {
      return TaxBreakdown(
        cartTotal: grosstotal,
        pretaxSubtotal: grosstotal,
        totalTax: 0,
        netTotal: grosstotal,
        lines: const [],
        isValid: false,
        validationError:
            'Tax configuration is invalid for one or more items. Please refresh and try again.',
        taxmode: 1,
        lineTaxes: List<OrderLineTaxPayload?>.filled(lines.length, null),
      );
    }

    final rate = master.taxPercentage;
    final double taxAmount;
    final double pretaxBase;
    if (master.isInclusive) {
      taxAmount = roundTaxAmount(line.total * rate / (100.0 + rate));
      pretaxBase = roundTaxAmount(line.total - taxAmount);
    } else {
      taxAmount = roundTaxAmount(line.total * rate / 100.0);
      pretaxBase = line.total;
      exclusiveTax += taxAmount;
    }

    pretaxSubtotal += pretaxBase;
    totalTax += taxAmount;
    lineTaxes.add(
      OrderLineTaxPayload(
        taxId: master.id,
        taxAmnt: taxAmount,
        taxpercent: master.taxPercentage,
        taxtype: master.taxType,
        taxname: master.taxName,
        isInclusive: master.isInclusive,
      ),
    );
  }

  totalTax = roundTaxAmount(totalTax);
  pretaxSubtotal = roundTaxAmount(pretaxSubtotal);
  final netTotal = roundTaxAmount(grosstotal + exclusiveTax);

  return TaxBreakdown(
    cartTotal: grosstotal,
    pretaxSubtotal: pretaxSubtotal,
    totalTax: totalTax,
    netTotal: netTotal,
    lines: totalTax > 0
        ? [
            TaxLineDisplay(
              taxName: 'Tax',
              pretaxBase: pretaxSubtotal,
              amount: totalTax,
              isInclusive: false,
            ),
          ]
        : const [],
    isValid: true,
    taxmode: 1,
    lineTaxes: lineTaxes,
    primaryTax: null,
  );
}
