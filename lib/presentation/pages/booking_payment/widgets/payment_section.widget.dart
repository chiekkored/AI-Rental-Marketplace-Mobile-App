import 'package:flutter/material.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BookingPaymentSection extends StatelessWidget {
  final Widget child;

  const BookingPaymentSection({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: child,
    );
  }
}
