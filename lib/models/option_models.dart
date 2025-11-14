/// Helper function to safely convert dynamic values to double
double _safeToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

/// Unit price list model for products (matches new API structure)
class UnitPriceListModel {
  final int unitFkId;
  final double price;
  final String unitName;
  final String otherLang;
  final bool isMainUnit;

  const UnitPriceListModel({
    required this.unitFkId,
    required this.price,
    required this.unitName,
    required this.otherLang,
    required this.isMainUnit,
  });

  /// Create from JSON
  factory UnitPriceListModel.fromJson(Map<String, dynamic> json) {
    return UnitPriceListModel(
      unitFkId: json['unit_fk_id'] ?? 0,
      price: _safeToDouble(json['price']),
      unitName: json['unit_name'] ?? '',
      otherLang: json['other_lang'] ?? '',
      isMainUnit: json['is_main_unit'] ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'unit_fk_id': unitFkId,
      'price': price,
      'unit_name': unitName,
      'other_lang': otherLang,
      'is_main_unit': isMainUnit,
    };
  }

  /// Create a copy with updated properties
  UnitPriceListModel copyWith({
    int? unitFkId,
    double? price,
    String? unitName,
    String? otherLang,
    bool? isMainUnit,
  }) {
    return UnitPriceListModel(
      unitFkId: unitFkId ?? this.unitFkId,
      price: price ?? this.price,
      unitName: unitName ?? this.unitName,
      otherLang: otherLang ?? this.otherLang,
      isMainUnit: isMainUnit ?? this.isMainUnit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnitPriceListModel &&
           other.unitFkId == unitFkId &&
           other.unitName == unitName &&
           other.price == price;
  }

  @override
  int get hashCode => unitFkId.hashCode ^ unitName.hashCode ^ price.hashCode;

  @override
  String toString() {
    return 'UnitPriceListModel(unitFkId: $unitFkId, unitName: $unitName, price: $price)';
  }
}

/// Size option model for menu items (legacy support)
class SizeOption {
  final String label;
  final double extraPrice;

  const SizeOption({
    required this.label,
    this.extraPrice = 0.0,
  });

  /// Create a copy with updated properties
  SizeOption copyWith({
    String? label,
    double? extraPrice,
  }) {
    return SizeOption(
      label: label ?? this.label,
      extraPrice: extraPrice ?? this.extraPrice,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SizeOption &&
           other.label == label &&
           other.extraPrice == extraPrice;
  }

  @override
  int get hashCode => label.hashCode ^ extraPrice.hashCode;

  @override
  String toString() {
    return 'SizeOption(label: $label, extraPrice: $extraPrice)';
  }
}

/// Modifier model for products (matches new API structure)
class ModifierModel {
  final int id;
  final String modifier;
  final String rate;
  final String date;
  final int userID;
  final String descriptionOl;
  final int isUploaded;
  final int cid;
  final String otherLang;

  const ModifierModel({
    required this.id,
    required this.modifier,
    required this.rate,
    required this.date,
    required this.userID,
    required this.descriptionOl,
    required this.isUploaded,
    required this.cid,
    required this.otherLang,
  });

  /// Create from JSON
  factory ModifierModel.fromJson(Map<String, dynamic> json) {
    return ModifierModel(
      id: json['ID'] ?? 0,
      modifier: json['Modifier'] ?? '',
      rate: json['Rate'] ?? '0',
      date: json['Date'] ?? '',
      userID: json['UserID'] ?? 0,
      descriptionOl: json['DescriptionOl'] ?? '',
      isUploaded: json['isUploaded'] ?? 0,
      cid: json['CID'] ?? 0,
      otherLang: json['other_lang'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Modifier': modifier,
      'Rate': rate,
      'Date': date,
      'UserID': userID,
      'DescriptionOl': descriptionOl,
      'isUploaded': isUploaded,
      'CID': cid,
      'other_lang': otherLang,
    };
  }

  /// Get modifier price as double
  double get price => double.tryParse(rate) ?? 0.0;

  /// Create a copy with updated properties
  ModifierModel copyWith({
    int? id,
    String? modifier,
    String? rate,
    String? date,
    int? userID,
    String? descriptionOl,
    int? isUploaded,
    int? cid,
    String? otherLang,
  }) {
    return ModifierModel(
      id: id ?? this.id,
      modifier: modifier ?? this.modifier,
      rate: rate ?? this.rate,
      date: date ?? this.date,
      userID: userID ?? this.userID,
      descriptionOl: descriptionOl ?? this.descriptionOl,
      isUploaded: isUploaded ?? this.isUploaded,
      cid: cid ?? this.cid,
      otherLang: otherLang ?? this.otherLang,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModifierModel &&
           other.id == id &&
           other.modifier == modifier &&
           other.rate == rate;
  }

  @override
  int get hashCode => id.hashCode ^ modifier.hashCode ^ rate.hashCode;

  @override
  String toString() {
    return 'ModifierModel(id: $id, modifier: $modifier, rate: $rate)';
  }
}

/// Addon option model for menu items (legacy support)
class AddonOption {
  final String id;
  final String title;
  final double price;
  final String imageUrl;

  const AddonOption({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  /// Create a copy with updated properties
  AddonOption copyWith({
    String? id,
    String? title,
    double? price,
    String? imageUrl,
  }) {
    return AddonOption(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddonOption &&
           other.id == id &&
           other.title == title &&
           other.price == price &&
           other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ price.hashCode ^ imageUrl.hashCode;

  @override
  String toString() {
    return 'AddonOption(id: $id, title: $title, price: $price, imageUrl: $imageUrl)';
  }
}
