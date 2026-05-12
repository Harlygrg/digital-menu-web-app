import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../routes/routes.dart';
import '../utils/qr_gate_messages.dart';
import '../utils/qr_init_context.dart';

/// Blocks child routes until [QrInitContext.isResolved] (valid `qr/resolve` this session).
class QrMenuAccessGate extends StatelessWidget {
  const QrMenuAccessGate({super.key, required this.child});

  final Widget child;

  static bool get isAllowed => QrInitContext.isResolved;

  @override
  Widget build(BuildContext context) {
    if (isAllowed) {
      return child;
    }

    final isEnglish = context.watch<LanguageProvider>().isEnglish;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.link_off_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    QrGateMessages.startupTitleMissingToken(isEnglish),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    QrGateMessages.missingToken(isEnglish),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.home,
                          (route) => false,
                        );
                      },
                      child: Text(QrGateMessages.openMenuLinkButton(isEnglish)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
