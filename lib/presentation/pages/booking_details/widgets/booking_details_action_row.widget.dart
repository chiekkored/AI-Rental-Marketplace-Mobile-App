import 'package:flutter/material.dart';
import 'package:lend/presentation/common/texts.common.dart';

class BookingDetailsActionRow extends StatelessWidget {
  const BookingDetailsActionRow({
    required this.icon,
    required this.text,
    required this.color,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22.0),
            const SizedBox(width: 12.0),
            Expanded(child: LNDText.medium(text: text, color: color)),
            Icon(Icons.chevron_right_rounded, color: color, size: 22.0),
          ],
        ),
      ),
    );
  }
}
