/// Session-only QR deep-link initialization flags (not persisted).
///
/// Values are set after a successful `qr/resolve` response in [HomeController]
/// and read by [CustomerProvider] without URL parsing.
class QrInitContext {
  QrInitContext._();

  /// When `true`, customer collection UI must be skipped; `null` means unspecified.
  static bool? shouldNotAddCustomer;

  /// Sets [shouldNotAddCustomer] from the resolve payload (may be `null` to clear).
  static void setShouldNotAddCustomer(bool? value) {
    shouldNotAddCustomer = value;
  }

  /// Clears in-memory state (e.g. for tests or a fresh non-QR launch).
  static void clear() {
    shouldNotAddCustomer = null;
  }
}
