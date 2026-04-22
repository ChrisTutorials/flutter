import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/conversion.dart';
import '../utils/icon_utils.dart';
import '../utils/number_formatter.dart';
import '../utils/responsive_layout.dart';

class RecentConversionCard extends StatelessWidget {
  const RecentConversionCard({
    super.key,
    required this.conversion,
    required this.onDelete,
    this.currencyNames,
  });

  final RecentConversion conversion;
  final VoidCallback onDelete;
  final Map<String, String>? currencyNames;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth < ResponsiveLayout.mobileBreakpoint
        ? 240.0
        : screenWidth < ResponsiveLayout.tabletBreakpoint
            ? 260.0
            : 280.0;

    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  IconUtils.getIconForCategory(conversion.category),
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Tooltip(
                    message: currencyNames != null && conversion.category == 'Currency'
                        ? '${conversion.fromUnit} (${currencyNames![conversion.fromUnit] ?? 'Unknown'}) -> ${conversion.toUnit} (${currencyNames![conversion.toUnit] ?? 'Unknown'})'
                        : '${NumberFormatter.formatCompact(conversion.inputValue)} ${conversion.fromUnit} -> ${NumberFormatter.formatCompact(conversion.outputValue)} ${conversion.toUnit}',
                    child: Text(
                      '${NumberFormatter.formatCompact(conversion.inputValue)} ${conversion.fromUnit} -> ${NumberFormatter.formatCompact(conversion.outputValue)} ${conversion.toUnit}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${conversion.category} • ${DateFormat('MMM d, h:mm a').format(conversion.timestamp)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
