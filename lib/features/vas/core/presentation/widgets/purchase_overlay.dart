import 'package:flutter/material.dart';

class PurchaseProcessingOverlay extends StatelessWidget {
  final bool visible;
  final String? message;
  final Widget child;

  const PurchaseProcessingOverlay({
    super.key,
    required this.visible,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,

        if (visible)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 34,
                          width: 34,
                          child: CircularProgressIndicator(),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          message ?? 'Completing purchase...',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}