import 'package:flutter/material.dart';

import '../models/quick_preset.dart';
import '../utils/responsive_layout.dart';

/// A preset card widget for quick conversions.
class PresetCard extends StatelessWidget {
  const PresetCard({
    required this.preset,
    required this.onTap,
    this.currencyNames,
  });

  final QuickPreset preset;
  final VoidCallback onTap;
  final Map<String, String>? currencyNames;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth < ResponsiveLayout.mobileBreakpoint
        ? 160.0
        : screenWidth < ResponsiveLayout.tabletBreakpoint
            ? 174.0
            : 188.0;

    return SizedBox(
      width: cardWidth,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: theme.colorScheme.primaryContainer,
                    ),
                    child: Text(
                      preset.isCurrency ? 'Live' : 'Preset',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Tooltip(
                    message: currencyNames != null && preset.isCurrency
                        ? '${preset.fromSymbol} (${currencyNames![preset.fromSymbol] ?? 'Unknown'}) to ${preset.toSymbol} (${currencyNames![preset.toSymbol] ?? 'Unknown'})'
                        : preset.label,
                    child: Text(
                      preset.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preset.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
