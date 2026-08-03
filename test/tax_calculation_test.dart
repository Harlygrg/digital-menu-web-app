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

  group('TaxSettingsData.taxmode', () {
    test('parses taxmode and taxById lookup', () {
      final settings = TaxSettingsData.fromJson({
        'branch_id': 2,
        'tax_enabled': true,
        'taxmode': 1,
        'taxes': [
          {
            'ID': 1,
            'TaxType': 'exclusive',
            'TaxName': 'VAT 5%',
            'TaxPercentage': 5,
            'gstsplit': false,
            'UserID': 1,
            'Date': '',
            'ModifiedBy': null,
            'MDate': null,
            'active': 1,
            'isUploaded': 0,
            'CID': 2,
          },
          {
            'ID': 2,
            'TaxType': 'inclusive',
            'TaxName': 'GST 12%',
            'TaxPercentage': 12,
            'gstsplit': true,
            'UserID': 1,
            'Date': '',
            'ModifiedBy': null,
            'MDate': null,
            'active': 1,
            'isUploaded': 0,
            'CID': 2,
          },
        ],
      });

      expect(settings.taxmode, 1);
      expect(settings.isItemWise, isTrue);
      expect(settings.taxById(1)?.taxPercentage, 5);
      expect(settings.taxById(2)?.isInclusive, isTrue);
      expect(settings.taxById(99), isNull);
    });
  });

  group('computeOrderTax item-wise', () {
    TaxItemModel exclusiveVat() => const TaxItemModel(
          id: 1,
          taxType: 'exclusive',
          taxName: 'VAT 5%',
          taxPercentage: 5,
          gstSplit: false,
          userId: 0,
          date: '',
          modifiedBy: 0,
          mDate: '',
          active: 1,
          isUploaded: 0,
          cid: 2,
        );

    TaxItemModel inclusiveGst() => const TaxItemModel(
          id: 2,
          taxType: 'inclusive',
          taxName: 'GST 12%',
          taxPercentage: 12,
          gstSplit: true,
          userId: 0,
          date: '',
          modifiedBy: 0,
          mDate: '',
          active: 1,
          isUploaded: 0,
          cid: 2,
        );

    test('exclusive 50 @ 5% → tax 2.50', () {
      final settings = TaxSettingsData(
        branchId: 2,
        taxEnabled: true,
        taxmode: 1,
        taxes: [exclusiveVat(), inclusiveGst()],
      );

      final breakdown = computeOrderTax(
        settings: settings,
        lines: const [TaxableLineInput(taxId: 1, total: 50)],
      );

      expect(breakdown.isValid, isTrue);
      expect(breakdown.lineTaxes.first!.taxAmnt, 2.50);
      expect(breakdown.totalTax, 2.50);
      expect(breakdown.cartTotal, 50);
      expect(breakdown.netTotal, 52.50);
    });

    test('inclusive 60 @ 12% → tax 6.43', () {
      final settings = TaxSettingsData(
        branchId: 2,
        taxEnabled: true,
        taxmode: 1,
        taxes: [exclusiveVat(), inclusiveGst()],
      );

      final breakdown = computeOrderTax(
        settings: settings,
        lines: const [TaxableLineInput(taxId: 2, total: 60)],
      );

      expect(breakdown.isValid, isTrue);
      expect(breakdown.lineTaxes.first!.taxAmnt, 6.43);
      expect(breakdown.totalTax, 6.43);
      expect(breakdown.cartTotal, 60);
      expect(breakdown.netTotal, 60);
    });

    test('combined A=50 exclusive + B=60 inclusive', () {
      final settings = TaxSettingsData(
        branchId: 2,
        taxEnabled: true,
        taxmode: 1,
        taxes: [exclusiveVat(), inclusiveGst()],
      );

      final breakdown = computeOrderTax(
        settings: settings,
        lines: const [
          TaxableLineInput(taxId: 1, total: 50),
          TaxableLineInput(taxId: 2, total: 60),
        ],
      );

      expect(breakdown.isValid, isTrue);
      expect(breakdown.cartTotal, 110);
      expect(breakdown.totalTax, 8.93);
      expect(breakdown.netTotal, 112.50);
      expect(breakdown.pretaxSubtotal, 103.57);
      expect(breakdown.lines, hasLength(1));
      expect(breakdown.lines.first.amount, 8.93);
      expect(breakdown.omitHeaderTaxMeta, isTrue);
    });

    test('missing TaxId is invalid', () {
      final settings = TaxSettingsData(
        branchId: 2,
        taxEnabled: true,
        taxmode: 1,
        taxes: [exclusiveVat()],
      );

      final breakdown = computeOrderTax(
        settings: settings,
        lines: const [TaxableLineInput(taxId: null, total: 50)],
      );

      expect(breakdown.isValid, isFalse);
      expect(breakdown.validationError, isNotNull);
      expect(breakdown.totalTax, 0);
    });

    test('unknown TaxId is invalid', () {
      final settings = TaxSettingsData(
        branchId: 2,
        taxEnabled: true,
        taxmode: 1,
        taxes: [exclusiveVat()],
      );

      final breakdown = computeOrderTax(
        settings: settings,
        lines: const [TaxableLineInput(taxId: 99, total: 50)],
      );

      expect(breakdown.isValid, isFalse);
      expect(breakdown.validationError, isNotNull);
    });
  });
}
