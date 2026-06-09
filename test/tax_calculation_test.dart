import 'package:digital_menu_order/models/tax_settings_model.dart';
import 'package:digital_menu_order/utils/tax_calculation.dart';
import 'package:flutter_test/flutter_test.dart';

TaxSettingsData _settingsWithTax(TaxItemModel tax) {
  return TaxSettingsData(
    branchId: 1,
    taxEnabled: true,
    taxes: [tax],
  );
}

void main() {
  group('computeTaxBreakdown', () {
    test('inclusive tax extracts tax from cart total', () {
      final settings = _settingsWithTax(
        const TaxItemModel(
          id: 1,
          taxType: 'Inclusive',
          taxName: 'GST',
          taxPercentage: 8,
          gstSplit: false,
          userId: 0,
          date: '',
          modifiedBy: 0,
          mDate: '',
          active: 1,
          isUploaded: 0,
          cid: 1,
        ),
      );

      final breakdown = computeTaxBreakdown(settings: settings, grossTotal: 40);

      expect(breakdown.cartTotal, 40);
      expect(breakdown.totalTax, closeTo(2.96, 0.01));
      expect(breakdown.pretaxSubtotal, closeTo(37.04, 0.01));
      expect(breakdown.netTotal, 40);
      expect(breakdown.lines, hasLength(1));
      expect(breakdown.lines.first.taxName, 'GST');
      expect(breakdown.lines.first.amount, closeTo(2.96, 0.01));
      expect(breakdown.lines.first.pretaxBase, closeTo(37.04, 0.01));
      expect(breakdown.lines.first.isInclusive, isTrue);
    });

    test('tax amounts are rounded to 2 decimal places', () {
      final settings = _settingsWithTax(
        const TaxItemModel(
          id: 1,
          taxType: 'Exclusive',
          taxName: 'GST',
          taxPercentage: 7,
          gstSplit: false,
          userId: 0,
          date: '',
          modifiedBy: 0,
          mDate: '',
          active: 1,
          isUploaded: 0,
          cid: 1,
        ),
      );

      final breakdown = computeTaxBreakdown(settings: settings, grossTotal: 75.99);

      expect(breakdown.totalTax, 5.32);
      expect(breakdown.lines.first.amount, 5.32);
      expect(breakdown.netTotal, 81.31);
    });

    test('exclusive tax adds tax on top of cart total', () {
      final settings = _settingsWithTax(
        const TaxItemModel(
          id: 1,
          taxType: 'Exclusive',
          taxName: 'GST',
          taxPercentage: 8,
          gstSplit: false,
          userId: 0,
          date: '',
          modifiedBy: 0,
          mDate: '',
          active: 1,
          isUploaded: 0,
          cid: 1,
        ),
      );

      final breakdown = computeTaxBreakdown(settings: settings, grossTotal: 40);

      expect(breakdown.cartTotal, 40);
      expect(breakdown.totalTax, closeTo(3.2, 0.01));
      expect(breakdown.pretaxSubtotal, 40);
      expect(breakdown.netTotal, closeTo(43.2, 0.01));
      expect(breakdown.lines, hasLength(1));
      expect(breakdown.lines.first.pretaxBase, 40);
      expect(breakdown.lines.first.amount, closeTo(3.2, 0.01));
      expect(breakdown.lines.first.isInclusive, isFalse);
    });

    test('disabled or empty taxes returns zero tax', () {
      const disabled = TaxSettingsData(
        branchId: 1,
        taxEnabled: false,
        taxes: [],
      );

      final breakdown = computeTaxBreakdown(settings: disabled, grossTotal: 40);

      expect(breakdown.totalTax, 0);
      expect(breakdown.pretaxSubtotal, 40);
      expect(breakdown.netTotal, 40);
      expect(breakdown.lines, isEmpty);
    });

    test('null settings returns zero tax', () {
      final breakdown = computeTaxBreakdown(settings: null, grossTotal: 40);

      expect(breakdown.totalTax, 0);
      expect(breakdown.pretaxSubtotal, 40);
      expect(breakdown.netTotal, 40);
      expect(breakdown.lines, isEmpty);
    });
  });

  group('TaxItemModel.fromJson', () {
    test('parses full API response fields', () {
      final tax = TaxItemModel.fromJson({
        'ID': 2,
        'TaxType': 'Inclusive',
        'TaxName': 'GST 10 %',
        'TaxPercentage': 10,
        'gstsplit': true,
        'UserID': 2,
        'Date': '2023-06-27 18:08:00',
        'ModifiedBy': 2,
        'MDate': '2026-06-06 18:57:00',
        'active': 1,
        'isUploaded': 0,
        'CID': 1,
      });

      expect(tax.id, 2);
      expect(tax.taxType, 'Inclusive');
      expect(tax.taxName, 'GST 10 %');
      expect(tax.taxPercentage, 10);
      expect(tax.gstSplit, isTrue);
      expect(tax.userId, 2);
      expect(tax.date, '2023-06-27 18:08:00');
      expect(tax.modifiedBy, 2);
      expect(tax.mDate, '2026-06-06 18:57:00');
      expect(tax.active, 1);
      expect(tax.isUploaded, 0);
      expect(tax.cid, 1);
      expect(tax.isInclusive, isTrue);
    });
  });
}
