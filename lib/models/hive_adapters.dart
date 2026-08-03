import 'package:hive/hive.dart';
import 'cart_item_model.dart';
import 'item_model.dart';
import 'option_models.dart';

/// Hive TypeAdapter for CartModifier
/// TypeId: 0
class CartModifierAdapter extends TypeAdapter<CartModifier> {
  @override
  final int typeId = 0;

  @override
  CartModifier read(BinaryReader reader) {
    final id = reader.readInt();
    final name = reader.readString();
    final price = reader.readDouble();
    final quantity = reader.readInt();

    // Backward compatibility: older persisted data won't have these fields.
    bool isAvailable = true;
    String? unavailableReason;
    int? taxId;
    try {
      isAvailable = reader.readBool();
      unavailableReason = reader.read() as String?;
    } catch (_) {
      // Defaults already set.
    }
    try {
      taxId = reader.read() as int?;
    } catch (_) {
      // Older carts without taxId.
    }

    return CartModifier(
      id: id,
      name: name,
      price: price,
      quantity: quantity,
      isAvailable: isAvailable,
      unavailableReason: unavailableReason,
      taxId: taxId,
    );
  }

  @override
  void write(BinaryWriter writer, CartModifier obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
    writer.writeDouble(obj.price);
    writer.writeInt(obj.quantity);
    writer.writeBool(obj.isAvailable);
    writer.write(obj.unavailableReason);
    writer.write(obj.taxId);
  }
}

/// Hive TypeAdapter for UnitPriceListModel
/// TypeId: 1
class UnitPriceListModelAdapter extends TypeAdapter<UnitPriceListModel> {
  @override
  final int typeId = 1;

  @override
  UnitPriceListModel read(BinaryReader reader) {
    return UnitPriceListModel(
      unitFkId: reader.readInt(),
      price: reader.readDouble(),
      unitName: reader.readString(),
      otherLang: reader.readString(),
      isMainUnit: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, UnitPriceListModel obj) {
    writer.writeInt(obj.unitFkId);
    writer.writeDouble(obj.price);
    writer.writeString(obj.unitName);
    writer.writeString(obj.otherLang);
    writer.writeBool(obj.isMainUnit);
  }
}

/// Hive TypeAdapter for UnitMasterModel
/// TypeId: 2
class UnitMasterModelAdapter extends TypeAdapter<UnitMasterModel> {
  @override
  final int typeId = 2;

  @override
  UnitMasterModel read(BinaryReader reader) {
    return UnitMasterModel(
      id: reader.readInt(),
      unitName: reader.readString(),
      date: reader.readString(),
      userid: reader.readInt(),
      isUploaded: reader.readInt(),
      cid: reader.read(),
      otherLang: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, UnitMasterModel obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.unitName);
    writer.writeString(obj.date);
    writer.writeInt(obj.userid);
    writer.writeInt(obj.isUploaded);
    writer.write(obj.cid);
    writer.writeString(obj.otherLang);
  }
}

/// Hive TypeAdapter for ProductDetailsModel
/// TypeId: 3
class ProductDetailsModelAdapter extends TypeAdapter<ProductDetailsModel> {
  @override
  final int typeId = 3;

  @override
  ProductDetailsModel read(BinaryReader reader) {
    return ProductDetailsModel(
      id: reader.readInt(),
      fkItemId: reader.readInt(),
      fkUnitId: reader.readInt(),
      convertToBase: reader.readString(),
      unitPrice: reader.readString(),
      barcode: reader.readString(),
      cost: reader.readString(),
      isUploaded: reader.readInt(),
      cid: reader.readInt(),
      unitMaster: reader.read() as UnitMasterModel,
    );
  }

  @override
  void write(BinaryWriter writer, ProductDetailsModel obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.fkItemId);
    writer.writeInt(obj.fkUnitId);
    writer.writeString(obj.convertToBase);
    writer.writeString(obj.unitPrice);
    writer.writeString(obj.barcode);
    writer.writeString(obj.cost);
    writer.writeInt(obj.isUploaded);
    writer.writeInt(obj.cid);
    writer.write(obj.unitMaster);
  }
}

/// Hive TypeAdapter for ItemModel
/// TypeId: 4
class ItemModelAdapter extends TypeAdapter<ItemModel> {
  @override
  final int typeId = 4;

  @override
  ItemModel read(BinaryReader reader) {
    final model = ItemModel(
      id: reader.readInt(),
      iname: reader.readString(),
      icode: reader.readString(),
      categoryId: reader.readInt(),
      disabled: reader.readInt(),
      nameinol: reader.readString(),
      fkUnit: reader.readInt(),
      multiUnit: reader.readInt(),
      price: reader.readDouble(),
      cost: reader.readDouble(),
      image: reader.readString(),
      imageUrl: reader.read() as String?,
      invPrdct: reader.readInt(),
      opqty: reader.readInt(),
      kot: reader.readString(),
      date: reader.readString(),
      userid: reader.readInt(),
      modifiedBy: reader.readInt(),
      modifiedDate: reader.readString(),
      btnColor: reader.readString(),
      shortName: reader.readString(),
      isUploaded: reader.readInt(),
      cid: reader.readInt(),
      isVeg: reader.readInt(),
      isAvailableInOnline: reader.readInt(),
      descriptionEn: reader.readString(),
      descriptionOtherLang: reader.readString(),
      unitPriceList: (reader.read() as List).cast<UnitPriceListModel>(),
      productdetails: (reader.read() as List).cast<ProductDetailsModel>(),
      relatedModifiers: (reader.read() as List).cast<int>(),
      preparationtime: reader.readString(),
    );
    int? taxId;
    try {
      taxId = reader.read() as int?;
    } catch (_) {
      // Older carts without TaxId on items.
    }
    return model.copyWith(taxId: taxId);
  }

  @override
  void write(BinaryWriter writer, ItemModel obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.iname);
    writer.writeString(obj.icode);
    writer.writeInt(obj.categoryId);
    writer.writeInt(obj.disabled);
    writer.writeString(obj.nameinol);
    writer.writeInt(obj.fkUnit);
    writer.writeInt(obj.multiUnit);
    writer.writeDouble(obj.price);
    writer.writeDouble(obj.cost);
    writer.writeString(obj.image);
    writer.write(obj.imageUrl);
    writer.writeInt(obj.invPrdct);
    writer.writeInt(obj.opqty);
    writer.writeString(obj.kot);
    writer.writeString(obj.date);
    writer.writeInt(obj.userid);
    writer.writeInt(obj.modifiedBy);
    writer.writeString(obj.modifiedDate);
    writer.writeString(obj.btnColor);
    writer.writeString(obj.shortName);
    writer.writeInt(obj.isUploaded);
    writer.writeInt(obj.cid);
    writer.writeInt(obj.isVeg);
    writer.writeInt(obj.isAvailableInOnline);
    writer.writeString(obj.descriptionEn);
    writer.writeString(obj.descriptionOtherLang);
    writer.write(obj.unitPriceList);
    writer.write(obj.productdetails);
    writer.write(obj.relatedModifiers);
    writer.writeString(obj.preparationtime);
    writer.write(obj.taxId);
  }
}

/// Hive TypeAdapter for CartItemModel
/// TypeId: 5
class CartItemModelAdapter extends TypeAdapter<CartItemModel> {
  @override
  final int typeId = 5;

  @override
  CartItemModel read(BinaryReader reader) {
    final id = reader.readString();
    final item = reader.read() as ItemModel;
    final selectedUnit = reader.read() as UnitPriceListModel?;
    final modifiers = (reader.read() as List).cast<CartModifier>();
    final quantity = reader.readInt();
    final specialInstructions = reader.read() as String?;
    final unitPrice = reader.readDouble();
    final itemTotal = reader.readDouble();

    // Backward compatibility: older persisted data won't have these fields.
    bool isAvailable = true;
    String? unavailableReason;
    try {
      isAvailable = reader.readBool();
      unavailableReason = reader.read() as String?;
    } catch (_) {
      // Defaults already set.
    }

    return CartItemModel(
      id: id,
      item: item,
      selectedUnit: selectedUnit,
      modifiers: modifiers,
      quantity: quantity,
      specialInstructions: specialInstructions,
      unitPrice: unitPrice,
      itemTotal: itemTotal,
      isAvailable: isAvailable,
      unavailableReason: unavailableReason,
    );
  }

  @override
  void write(BinaryWriter writer, CartItemModel obj) {
    writer.writeString(obj.id);
    writer.write(obj.item);
    writer.write(obj.selectedUnit);
    writer.write(obj.modifiers);
    writer.writeInt(obj.quantity);
    writer.write(obj.specialInstructions);
    writer.writeDouble(obj.unitPrice);
    writer.writeDouble(obj.itemTotal);
    writer.writeBool(obj.isAvailable);
    writer.write(obj.unavailableReason);
  }
}
