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
    return Text(fullText, style: style);
  }
}
