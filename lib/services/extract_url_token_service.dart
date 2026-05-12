import 'package:digital_menu_order/utils/rul_reader.dart';
import 'package:dio/dio.dart';
import 'package:digital_menu_order/services/api/api_service.dart';
import 'package:digital_menu_order/storage/local_storage.dart';
import 'package:digital_menu_order/utils/qr_init_context.dart';
import 'package:digital_menu_order/utils/qr_gate_messages.dart';

import '../utils/app_debug_log.dart'
    show appInfoLog, appWebDebugLog, appWarnLog, appErrorLog;

String? _lastResolvedToken;

class QrResolveResult {
  final bool shouldBlockUi;
  final String? errorMessage;

  const QrResolveResult._({required this.shouldBlockUi, this.errorMessage});

  const QrResolveResult.success() : this._(shouldBlockUi: false);

  const QrResolveResult.failure(String message)
    : this._(shouldBlockUi: true, errorMessage: message);
}

Future<void> _saveQrContextOrThrow({
  int? branchId,
  int? orderType,
  int? tableId,
}) async {
  await LocalStorage.saveQrContext(
    branchId: branchId,
    orderType: orderType,
    tableId: tableId,
  );
}

Future<QrResolveResult> resolveQrFromInitialToken() async {
  final token = readQrTokenFromEnvironment();
  if (token == _lastResolvedToken && QrInitContext.isResolved) {
    appWebDebugLog('QR resolve skipped (same token): $token');
    return const QrResolveResult.success();
  }
  if (token == null || token.isEmpty) {
    appWarnLog('QR token missing in URL. Blocking UI.');
    QrInitContext.setInitialToken(null);
    try {
      // Clear stale QR session from storage so a blocked launch cannot reuse old branch/table.
      appWebDebugLog('Clearing stored QR context (no token path) started');
      await _saveQrContextOrThrow(
        branchId: null,
        orderType: null,
        tableId: null,
      );
      appWebDebugLog('Clearing stored QR context (no token path) completed');
    } catch (e, st) {
      appErrorLog('QR clear storage failed (no token path): $e\n$st');
      QrInitContext.markFailed(QrGateMessages.saveContextFailedEn);
      return const QrResolveResult.failure(QrGateMessages.saveContextFailedEn);
    }
    QrInitContext.markFailed(QrGateMessages.missingTokenEn);
    return const QrResolveResult.failure(QrGateMessages.missingTokenEn);
  }

  appInfoLog('QR resolve flow started for token: $token');
  QrInitContext.markResolving();

  try {
    // Always clear any stale persisted QR values before applying a new token.
    appWebDebugLog('Clearing stored QR context (before resolve) started');
    await _saveQrContextOrThrow(
      branchId: null,
      orderType: null,
      tableId: null,
    );
    appWebDebugLog('Clearing stored QR context (before resolve) completed');
  } catch (e, st) {
    appErrorLog('QR clear storage failed (before resolve): $e\n$st');
    QrInitContext.markFailed(QrGateMessages.saveContextFailedEn);
    return const QrResolveResult.failure(QrGateMessages.saveContextFailedEn);
  }

  try {
    appWebDebugLog('Resolve API calling started');
    final response = await ApiService().resolveQrToken(token);
    appWebDebugLog('Resolve API calling completed');

    if (response['success'] == false) {
      final message =
          _extractServerMessage(response) ??
          'The menu link could not be validated. Please scan again or contact staff.';
      appWarnLog('Resolve API returned failure: $message');
      QrInitContext.markFailed(message);
      return QrResolveResult.failure(message);
    }

    final rawData = response['data'];
    final data = rawData is Map<String, dynamic> ? rawData : response;

    final branchId = _parsePositiveInt(data['branch_id']);
    final orderType = _parsePositiveInt(data['order_type']);
    final tableId = _parsePositiveInt(data['table_id']);
    final shouldNotAddCustomer = _parseNullableBool(
      data['should_not_add_customer'],
    );

    final hasUsefulPayload =
        branchId != null ||
        orderType != null ||
        tableId != null ||
        shouldNotAddCustomer != null;

    if (!hasUsefulPayload) {
      final message =
          _extractServerMessage(response) ??
          'This menu link did not return a valid session. Please scan again.';
      appWarnLog('Resolve API payload missing required fields: $message');
      QrInitContext.markFailed(message);
      return QrResolveResult.failure(message);
    }

    QrInitContext.applyResolvedContext(
      branchId: branchId,
      orderType: orderType,
      tableId: tableId,
      shouldNotAddCustomer: shouldNotAddCustomer,
    );

    try {
      appWebDebugLog('Saving resolved QR context to storage started');
      await _saveQrContextOrThrow(
        branchId: branchId,
        orderType: orderType,
        tableId: tableId,
      );
      appWebDebugLog('Saving resolved QR context to storage completed');
    } catch (e, st) {
      appErrorLog('QR save context failed after resolve: $e\n$st');
      QrInitContext.markFailed(QrGateMessages.saveContextFailedEn);
      return const QrResolveResult.failure(QrGateMessages.saveContextFailedEn);
    }

    appInfoLog(
      'QR resolved: branch=$branchId orderType=$orderType table=$tableId skipCustomer=$shouldNotAddCustomer',
    );
    _lastResolvedToken = token;
    return const QrResolveResult.success();
  } on DioException catch (e) {
    final message = _dioToUserMessage(e);
    appErrorLog('QR resolve failed (Dio): $message');
    QrInitContext.markFailed(message);
    return QrResolveResult.failure(message);
  } catch (e) {
    const message =
        'Something went wrong while validating this menu link. Please scan again.';
    appErrorLog('QR resolve failed: $e');
    QrInitContext.markFailed(message);
    return const QrResolveResult.failure(message);
  }
}

int? _parsePositiveInt(dynamic value) {
  if (value is num) {
    final intValue = value.toInt();
    return intValue > 0 ? intValue : null;
  }

  if (value is String) {
    final intValue = int.tryParse(value.trim());
    if (intValue != null && intValue > 0) {
      return intValue;
    }
  }

  return null;
}

bool? _parseNullableBool(dynamic value) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }

  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }

  return null;
}

String? _extractServerMessage(Map<String, dynamic> payload) {
  final topLevelMessage = payload['message']?.toString().trim();
  if (topLevelMessage != null && topLevelMessage.isNotEmpty) {
    return topLevelMessage;
  }

  final data = payload['data'];
  if (data is Map<String, dynamic>) {
    final nestedMessage = data['message']?.toString().trim();
    if (nestedMessage != null && nestedMessage.isNotEmpty) {
      return nestedMessage;
    }
  }

  return null;
}

String _dioToUserMessage(DioException error) {
  final responseData = error.response?.data;

  if (responseData is Map<String, dynamic>) {
    final message = _extractServerMessage(responseData);
    if (message != null && message.isNotEmpty) {
      return 'Menu link validation failed: $message';
    }
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Menu link validation timed out. Please check your connection and try again.';
    case DioExceptionType.connectionError:
      return 'Could not reach the server to validate this menu link. Please check your connection and try again.';
    default:
      return 'Menu link validation failed. Please scan again or contact staff.';
  }
}
