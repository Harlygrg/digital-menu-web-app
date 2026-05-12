/// Session-only QR deep-link initialization flags (not persisted).
///
/// Values are set after a successful `qr/resolve` response and read by
/// downstream flows without reparsing the URL.
enum QrLaunchStatus { none, resolving, resolved, failed }

class QrInitContext {
  QrInitContext._();

  static String? initialToken;

  /// When `true`, customer collection UI must be skipped; `null` means unspecified.
  static bool? shouldNotAddCustomer;
  static int? tableId;
  static int? orderType;
  static int? branchId;
  static QrLaunchStatus status = QrLaunchStatus.none;
  static String? failureMessage;

  static bool get hasInitialToken => (initialToken?.trim().isNotEmpty ?? false);
  static bool get isResolved => status == QrLaunchStatus.resolved;
  static bool get isFailed => status == QrLaunchStatus.failed;

  /// Resets the in-memory QR state for the current launch URL.
  static void setInitialToken(String? token) {
    initialToken = token?.trim();
    _clearResolvedValues();
    failureMessage = null;
    status = hasInitialToken ? QrLaunchStatus.resolving : QrLaunchStatus.none;
  }

  /// Marks the launch as actively resolving the QR token.
  static void markResolving() {
    _clearResolvedValues();
    failureMessage = null;
    status = hasInitialToken ? QrLaunchStatus.resolving : QrLaunchStatus.none;
  }

  /// Applies a successfully resolved QR payload.
  static void applyResolvedContext({
    required int? branchId,
    required int? orderType,
    required int? tableId,
    required bool? shouldNotAddCustomer,
  }) {
    QrInitContext.branchId = branchId;
    QrInitContext.orderType = orderType;
    QrInitContext.tableId = tableId;
    QrInitContext.shouldNotAddCustomer = shouldNotAddCustomer;
    failureMessage = null;
    status = QrLaunchStatus.resolved;
  }

  /// Marks the QR launch as failed and clears any partially applied data.
  static void markFailed(String message) {
    _clearResolvedValues();
    failureMessage = message;
    status = QrLaunchStatus.failed;
  }

  /// Sets [shouldNotAddCustomer] from the resolve payload (may be `null` to clear).
  static void setShouldNotAddCustomer(bool? value) {
    shouldNotAddCustomer = value;
  }

  /// Clears in-memory state (e.g. for tests or a fresh non-QR launch).
  static void clear() {
    initialToken = null;
    _clearResolvedValues();
    failureMessage = null;
    status = QrLaunchStatus.none;
  }

  static void _clearResolvedValues() {
    shouldNotAddCustomer = null;
    tableId = null;
    orderType = null;
    branchId = null;
  }
}
