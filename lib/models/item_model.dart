import 'package:digital_menu_order/utils/capitalize_first_letter.dart';

import 'option_models.dart';

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

/// Product details model (matches new API structure)
class ProductDetailsModel {
  final int id;
  final int fkItemId;
  final int fkUnitId;
  final String convertToBase;
  final String unitPrice;
  final String barcode;
  final String cost;
  final int isUploaded;
  final int cid;
  final UnitMasterModel unitMaster;

  const ProductDetailsModel({
    required this.id,
    required this.fkItemId,
    required this.fkUnitId,
    required this.convertToBase,
    required this.unitPrice,
    required this.barcode,
    required this.cost,
    required this.isUploaded,
    required this.cid,
    required this.unitMaster,
  });

  /// Create from JSON
  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailsModel(
      id: json['ID'] ?? 0,
      fkItemId: json['fkItemID'] ?? 0,
      fkUnitId: json['FkUnitID'] ?? 0,
      convertToBase: json['ConvertToBase'] ?? '',
      unitPrice: json['UnitPrice'] ?? '',
      barcode: json['Barcode'] ?? '',
      cost: json['Cost'] ?? '',
      isUploaded: json['isUploaded'] ?? 0,
      cid: json['CID'] ?? 0,
      unitMaster: UnitMasterModel.fromJson(json['unit_master'] ?? {}),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'fkItemID': fkItemId,
      'FkUnitID': fkUnitId,
      'ConvertToBase': convertToBase,
      'UnitPrice': unitPrice,
      'Barcode': barcode,
      'Cost': cost,
      'isUploaded': isUploaded,
      'CID': cid,
      'unit_master': unitMaster.toJson(),
    };
  }
}

/// Unit master model (matches new API structure)
class UnitMasterModel {
  final int id;
  final String unitName;
  final String date;
  final int userid;
  final int isUploaded;
  final int? cid;
  final String otherLang;

  const UnitMasterModel({
    required this.id,
    required this.unitName,
    required this.date,
    required this.userid,
    required this.isUploaded,
    this.cid,
    required this.otherLang,
  });

  /// Create from JSON
  factory UnitMasterModel.fromJson(Map<String, dynamic> json) {
    return UnitMasterModel(
      id: json['ID'] ?? 0,
      unitName: json['UnitName'] ?? '',
      date: json['Date'] ?? '',
      userid: json['Userid'] ?? 0,
      isUploaded: json['isUploaded'] ?? 0,
      cid: json['CID'],
      otherLang: json['other_lang'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'UnitName': unitName,
      'Date': date,
      'Userid': userid,
      'isUploaded': isUploaded,
      'CID': cid,
      'other_lang': otherLang,
    };
  }
}

/// Model representing a menu item (updated for new API)
class ItemModel {
  final int id;
  final String iname;
  final String icode;
  final int categoryId;
  final int disabled;
  final String nameinol;
  final int fkUnit;
  final int multiUnit;
  final double price;
  final double cost;
  final String image; // Base64 string
  final String? imageUrl; // Network image URL
  final int invPrdct;
  final int opqty;
  final String kot;
  final String date;
  final int userid;
  final int modifiedBy;
  final String modifiedDate;
  final String btnColor;
  final String shortName;
  final int isUploaded;
  final int cid;
  final int isVeg;
  final int isAvailableInOnline;
  final String descriptionEn;
  final String descriptionOtherLang;
  final List<UnitPriceListModel> unitPriceList;
  final List<ProductDetailsModel> productdetails;
  final List<int> relatedModifiers;
  final String preparationtime;

  const ItemModel({
    required this.id,
    required this.iname,
    required this.icode,
    required this.categoryId,
    required this.disabled,
    required this.nameinol,
    required this.fkUnit,
    required this.multiUnit,
    required this.price,
    required this.cost,
    required this.image,
    this.imageUrl,
    required this.invPrdct,
    required this.opqty,
    required this.kot,
    required this.date,
    required this.userid,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.btnColor,
    required this.shortName,
    required this.isUploaded,
    required this.cid,
    required this.isVeg,
    required this.isAvailableInOnline,
    required this.descriptionEn,
    required this.descriptionOtherLang,
    required this.unitPriceList,
    required this.productdetails,
    required this.relatedModifiers,
    required this.preparationtime
  });

  /// Create from JSON
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['Id'] ?? 0,
      iname: json['Iname'] ?? '',
      icode: json['Icode'] ?? '',
      categoryId: json['CategoryId'] ?? 0,
      disabled: json['Disabled'] ?? 0,
      nameinol: json['Nameinol'] ?? '',
      fkUnit: json['fk_Unit'] ?? 0,
      multiUnit: json['MultiUnit'] ?? 0,
      price: _safeToDouble(json['Price']),
      cost: _safeToDouble(json['Cost']),
      image: json['image'] ?? '',
      imageUrl: json['img_url'],
      invPrdct: json['InvPrdct'] ?? 0,
      opqty: json['Opqty'] ?? 0,
      kot: json['KOT'] ?? '',
      date: json['Date'] ?? '',
      userid: json['Userid'] ?? 0,
      modifiedBy: json['ModifiedBy'] ?? 0,
      modifiedDate: json['ModifiedDate'] ?? '',
      btnColor: json['btnColor'] ?? '',
      shortName: json['ShortName'] ?? '',
      isUploaded: json['isUploaded'] ?? 0,
      cid: json['cid'] ?? 0,
      isVeg: json['is_veg'] ?? 0,
      isAvailableInOnline: json['is_available_in_online'] ?? 0,
      descriptionEn: json['description_en'] ?? '',
      descriptionOtherLang: json['description_other_lang'] ?? '',
      unitPriceList: (json['UnitPriceList'] as List<dynamic>?)
          ?.map((item) => UnitPriceListModel.fromJson(item))
          .toList() ?? [],
      productdetails: (json['productdetails'] as List<dynamic>?)
          ?.map((item) => ProductDetailsModel.fromJson(item))
          .toList() ?? [],
      relatedModifiers: (json['related_modifiers'] as List<dynamic>?)
          ?.map((item) => item as int)
          .toList() ?? [],
      preparationtime: json['preparationtime'] ?? ''
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Iname': iname,
      'Icode': icode,
      'CategoryId': categoryId,
      'Disabled': disabled,
      'Nameinol': nameinol,
      'fk_Unit': fkUnit,
      'MultiUnit': multiUnit,
      'Price': price,
      'Cost': cost,
      'image': image,
      'image_url': imageUrl,
      'InvPrdct': invPrdct,
      'Opqty': opqty,
      'KOT': kot,
      'Date': date,
      'Userid': userid,
      'ModifiedBy': modifiedBy,
      'ModifiedDate': modifiedDate,
      'btnColor': btnColor,
      'ShortName': shortName,
      'isUploaded': isUploaded,
      'cid': cid,
      'is_veg': isVeg,
      'is_available_in_online': isAvailableInOnline,
      'description_en': descriptionEn,
      'description_other_lang': descriptionOtherLang,
      'UnitPriceList': unitPriceList.map((item) => item.toJson()).toList(),
      'productdetails': productdetails.map((item) => item.toJson()).toList(),
      'related_modifiers': relatedModifiers,
      'preparationtime':preparationtime
    };
  }

  /// Get the lowest price from unit price list
  double get lowestPrice {
    if (unitPriceList.isEmpty) return price;
    return unitPriceList.map((unit) => unit.price).reduce((a, b) => a < b ? a : b);
  }

  /// Get the highest price from unit price list
  double get highestPrice {
    if (unitPriceList.isEmpty) return price;
    return unitPriceList.map((unit) => unit.price).reduce((a, b) => a > b ? a : b);
  }

  /// Get price range string
  String get priceRange {
    if (unitPriceList.isEmpty) return 'QR ${price.toStringAsFixed(2)}';
    if (lowestPrice == highestPrice) {
      return 'QR ${lowestPrice.toStringAsFixed(2)}';
    }
    return 'QR ${lowestPrice.toStringAsFixed(2)} - QR ${highestPrice.toStringAsFixed(2)}';
  }

  /// Get product name based on language
  String getProductName(String language) {
    if (language == 'ar' && nameinol.isNotEmpty) {
      return nameinol;
    }
    return iname.toLowerCase().capitalizeFirst();
  }

  /// Get description based on language
  String getDescription(String language) {
    if (language == 'ar' && descriptionOtherLang.isNotEmpty) {
      return descriptionOtherLang;
    }
    return descriptionEn;
  }

  /// Check if product is available online
  bool get isAvailable => isAvailableInOnline == 1;

  /// Check if product is vegetarian
  bool get isVegetarian => isVeg == 1;

  /// Create a copy with updated properties
  ItemModel copyWith({
    int? id,
    String? iname,
    String? icode,
    int? categoryId,
    int? disabled,
    String? nameinol,
    int? fkUnit,
    int? multiUnit,
    double? price,
    double? cost,
    String? image,
    String? imageUrl,
    int? invPrdct,
    int? opqty,
    String? kot,
    String? date,
    int? userid,
    int? modifiedBy,
    String? modifiedDate,
    String? btnColor,
    String? shortName,
    int? isUploaded,
    int? cid,
    int? isVeg,
    int? isAvailableInOnline,
    String? descriptionEn,
    String? descriptionOtherLang,
    List<UnitPriceListModel>? unitPriceList,
    List<ProductDetailsModel>? productdetails,
    List<int>? relatedModifiers,
  }) {
    return ItemModel(
      id: id ?? this.id,
      iname: iname ?? this.iname,
      icode: icode ?? this.icode,
      categoryId: categoryId ?? this.categoryId,
      disabled: disabled ?? this.disabled,
      nameinol: nameinol ?? this.nameinol,
      fkUnit: fkUnit ?? this.fkUnit,
      multiUnit: multiUnit ?? this.multiUnit,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      invPrdct: invPrdct ?? this.invPrdct,
      opqty: opqty ?? this.opqty,
      kot: kot ?? this.kot,
      date: date ?? this.date,
      userid: userid ?? this.userid,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      btnColor: btnColor ?? this.btnColor,
      shortName: shortName ?? this.shortName,
      isUploaded: isUploaded ?? this.isUploaded,
      cid: cid ?? this.cid,
      isVeg: isVeg ?? this.isVeg,
      isAvailableInOnline: isAvailableInOnline ?? this.isAvailableInOnline,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionOtherLang: descriptionOtherLang ?? this.descriptionOtherLang,
      unitPriceList: unitPriceList ?? this.unitPriceList,
      productdetails: productdetails ?? this.productdetails,
      relatedModifiers: relatedModifiers ?? this.relatedModifiers,
      preparationtime: preparationtime
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ItemModel(id: $id, iname: $iname, categoryId: $categoryId)';
  }
}
