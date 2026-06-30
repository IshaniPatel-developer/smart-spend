import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';

class RupeeAmountText extends StatelessWidget {
  final double amount;
  final TextStyle style;
  final bool forceAbbreviate;

  const RupeeAmountText({
    super.key,
    required this.amount,
    required this.style,
    this.forceAbbreviate = true,
  });

  @override
  Widget build(BuildContext context) {
    final fullText = Formatters.formatRupee(amount);
    if (fullText.length > 9) {
      final truncatedText = '${fullText.substring(0, 6)}...';
      return Tooltip(
        message: fullText,
        triggerMode: TooltipTriggerMode.tap,
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Text(truncatedText, style: style),
      );
    }
    return Text(fullText, style: style);
  }
}
