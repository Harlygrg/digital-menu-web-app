import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/theme.dart';

/// Encoding mode for the QR payload
/// Set to `true` for Base64 encoding, `false` for raw JSON
const bool kEncodeAsBase64 = true;

/// Widget that displays an Order QR code for scanning
/// 
/// This widget generates a QR code containing order information that can be
/// scanned by the OrderTaking app. It includes:
/// - A scannable QR code
/// - The order ID displayed near the QR
/// - A fallback PIN text with copy functionality
class OrderQrWidget extends StatelessWidget {
  /// The unique order identifier
  final String orderId;
  
  /// The PIN number for the order
  final String pin;
  
  /// Optional label for localization (defaults to English)
  final bool isEnglish;

  const OrderQrWidget({
    super.key,
    required this.orderId,
    required this.pin,
    this.isEnglish = true,
  });

  /// Generate the QR payload data
  String _generateQrPayload() {
    final payload = {
      'orderId': orderId,
      'pin': pin,
      'app': 'digital_menu',
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };

    final jsonString = jsonEncode(payload);
    
    if (kEncodeAsBase64) {
      return base64Encode(utf8.encode(jsonString));
    }
    return jsonString;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive QR size: constrain to available width with max size
        final maxQrSize = 200.0;
        final availableWidth = constraints.maxWidth;
        final qrSize = availableWidth < maxQrSize + 48 
            ? availableWidth - 48 // Account for padding
            : maxQrSize;
        
        return _buildQrContainer(context, theme, qrSize);
      },
    );
  }

  Widget _buildQrContainer(BuildContext context, ThemeData theme, double qrSize) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Order ID label
          Text(
            isEnglish ? 'Order ID' : 'رقم الطلب',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: Responsive.fontSize(context, 12),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: Responsive.padding(context, 4)),
          
          // Order ID value
          SelectableText(
            orderId,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: Responsive.fontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          
          SizedBox(height: Responsive.padding(context, 16)),
          
          // QR Code with Semantics
          _buildQrCode(context, theme, qrSize),
          
          SizedBox(height: Responsive.padding(context, 16)),
          
          // Fallback PIN with copy button
          _buildFallbackPin(context, theme),
        ],
      ),
    );
  }

  Widget _buildQrCode(BuildContext context, ThemeData theme, double qrSize) {
    try {
      final qrData = _generateQrPayload();
      
      return Semantics(
        label: isEnglish 
            ? 'Order QR code for order $orderId' 
            : 'رمز QR للطلب $orderId',
        child: Tooltip(
          message: isEnglish 
              ? 'Scan this QR code to confirm order' 
              : 'امسح رمز QR لتأكيد الطلب',
          child: Container(
            padding: EdgeInsets.all(Responsive.padding(context, 12)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: qrSize,
              backgroundColor: AppColors.white,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: theme.colorScheme.onSurface,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: theme.colorScheme.onSurface,
              ),
              errorCorrectionLevel: QrErrorCorrectLevel.M,
              errorStateBuilder: (context, error) {
                return _buildQrError(context, theme, qrSize);
              },
            ),
          ),
        ),
      );
    } catch (e) {
      // Log error using existing project pattern
      debugPrint('OrderQrWidget: Failed to generate QR code - $e');
      
      // Show error snackbar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEnglish 
                    ? 'QR unavailable — use PIN to confirm'
                    : 'رمز QR غير متاح — استخدم رقم التعريف للتأكيد',
              ),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      });
      
      return _buildQrError(context, theme, qrSize);
    }
  }

  Widget _buildQrError(BuildContext context, ThemeData theme, double qrSize) {
    return Container(
      width: qrSize,
      height: qrSize,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_2,
            size: Responsive.fontSize(context, 48),
            color: theme.colorScheme.error.withValues(alpha: 0.5),
          ),
          SizedBox(height: Responsive.padding(context, 8)),
          Text(
            isEnglish ? 'QR unavailable' : 'رمز QR غير متاح',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontSize: Responsive.fontSize(context, 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackPin(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Text(
          isEnglish ? 'PIN' : 'رقم التعريف',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: Responsive.fontSize(context, 11),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        SizedBox(height: Responsive.padding(context, 4)),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Selectable PIN text
            SelectableText(
              pin,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: Responsive.fontSize(context, 20),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(width: Responsive.padding(context, 8)),
            
            // Copy button
            Tooltip(
              message: isEnglish ? 'Copy PIN' : 'نسخ رقم التعريف',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _copyPinToClipboard(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.padding(context, 6)),
                    child: Icon(
                      Icons.copy_rounded,
                      size: Responsive.fontSize(context, 18),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _copyPinToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: pin));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEnglish ? 'PIN copied to clipboard' : 'تم نسخ رقم التعريف',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

