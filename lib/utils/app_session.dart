import 'package:digital_menu_order/storage/local_storage.dart';
import 'package:digital_menu_order/utils/qr_init_context.dart'
    show QrInitContext;

class AppSession {
  static Future<int?> getBranchId() async {
    return QrInitContext.branchId
        ?? await LocalStorage.getBranchIdAsInt()
        ?? 1; // 🔥 TEMP fallback
  }

  static Future<int?> getOrderType() async {
    return QrInitContext.orderType ?? await LocalStorage.getOrderTypeAsInt();
  }

  static Future<int?> getTableId() async {
    return QrInitContext.tableId ?? await LocalStorage.getTableIdAsInt();
  }
}
