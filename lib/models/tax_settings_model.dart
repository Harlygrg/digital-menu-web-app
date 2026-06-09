/// Models for the getTaxSettings API response.
///
/// Parsing is defensive: unknown shapes must not throw.

double _taxSafeDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _taxSafeInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _taxSafeString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

bool _taxSafeBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final s = value.toLowerCase();
    return s == 'true' || s == '1';
  }
  return false;
}

/// One tax line as returned by the backend (active-only list; do not re-filter).
class TaxItemModel {
  final int id;
  final String taxType;
  final String taxName;
  final double taxPercentage;
  final bool gstSplit;
  final int userId;
  final String date;
  final int modifiedBy;
  final String mDate;
  final int active;
  final int isUploaded;
  final int cid;

  const TaxItemModel({
    required this.id,
    required this.taxType,
    required this.taxName,
    required this.taxPercentage,
    required this.gstSplit,
    required this.userId,
    required this.date,
    required this.modifiedBy,
    required this.mDate,
    required this.active,
    required this.isUploaded,
    required this.cid,
  });

  bool get isInclusive => taxType.toLowerCase() == 'inclusive';

  factory TaxItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TaxItemModel(
        id: 0,
        taxType: '',
        taxName: '',
        taxPercentage: 0,
        gstSplit: false,
        userId: 0,
        date: '',
        modifiedBy: 0,
        mDate: '',
        active: 0,
        isUploaded: 0,
        cid: 0,
      );
    }
    return TaxItemModel(
      id: _taxSafeInt(json['ID'] ?? json['id']),
      taxType: _taxSafeString(json['TaxType'] ?? json['tax_type']),
      taxName: _taxSafeString(json['TaxName'] ?? json['tax_name']),
      taxPercentage: _taxSafeDouble(
        json['TaxPercentage'] ?? json['tax_percentage'],
      ),
      gstSplit: _taxSafeBool(json['gstsplit'] ?? json['gstSplit']),
      userId: _taxSafeInt(json['UserID'] ?? json['user_id'] ?? json['userId']),
      date: _taxSafeString(json['Date'] ?? json['date']),
      modifiedBy: _taxSafeInt(
        json['ModifiedBy'] ?? json['modified_by'] ?? json['modifiedBy'],
      ),
      mDate: _taxSafeString(json['MDate'] ?? json['m_date'] ?? json['mDate']),
      active: _taxSafeInt(json['active']),
      isUploaded: _taxSafeInt(json['isUploaded'] ?? json['is_uploaded']),
      cid: _taxSafeInt(json['CID'] ?? json['cid']),
    );
  }
}

/// `data` object from getTaxSettings.
class TaxSettingsData {
  final int branchId;
  final bool taxEnabled;
  final List<TaxItemModel> taxes;

  const TaxSettingsData({
    required this.branchId,
    required this.taxEnabled,
    required this.taxes,
  });

  factory TaxSettingsData.fromJson(dynamic raw) {
    if (raw is! Map) {
      return const TaxSettingsData(branchId: 0, taxEnabled: false, taxes: []);
    }
    final json = Map<String, dynamic>.from(raw);
    final taxesRaw = json['taxes'];
    final taxes = <TaxItemModel>[];
    if (taxesRaw is List) {
      for (final e in taxesRaw) {
        if (e is Map<String, dynamic>) {
          taxes.add(TaxItemModel.fromJson(e));
        } else if (e is Map) {
          taxes.add(
            TaxItemModel.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    return TaxSettingsData(
      branchId: _taxSafeInt(json['branch_id'] ?? json['branchId']),
      taxEnabled: _taxSafeBool(json['tax_enabled'] ?? json['taxEnabled']),
      taxes: taxes,
    );
  }
}

/// Full getTaxSettings response wrapper.
class TaxSettingsResponse {
  final bool success;
  final String message;
  final TaxSettingsData? data;

  const TaxSettingsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory TaxSettingsResponse.fromJson(dynamic raw) {
    try {
      if (raw is! Map) {
        return const TaxSettingsResponse(
          success: false,
          message: 'Invalid response',
          data: null,
        );
      }
      final json = Map<String, dynamic>.from(raw);
      final dataRaw = json['data'];
      return TaxSettingsResponse(
        success: _taxSafeBool(json['success']),
        message: _taxSafeString(json['message']),
        data: dataRaw is Map ? TaxSettingsData.fromJson(dataRaw) : null,
      );
    } catch (_) {
      return const TaxSettingsResponse(
        success: false,
        message: 'Parse error',
        data: null,
      );
    }
  }
}
