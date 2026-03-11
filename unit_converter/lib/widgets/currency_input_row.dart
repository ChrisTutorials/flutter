import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A currency input row widget for the currency converter.
class CurrencyInputRow extends StatelessWidget {
  const CurrencyInputRow({
    required this.label,
    required this.controller,
    required this.selectedCode,
    required this.items,
    required this.onChanged,
    required this.onCurrencyChanged,
    required this.readOnly,
  });

  final String label;
  final TextEditingController controller;
  final String selectedCode;
  final Map<String, String> items;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String?> onCurrencyChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: readOnly
                    ? null
                    : [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'-?\d*\.?\d*'),
                        ),
                      ],
                decoration: InputDecoration(
                  hintText: readOnly ? 'Converted amount' : 'Enter amount',
                ),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                initialValue: selectedCode,
                isExpanded: true,
                items: items.entries
                    .map(
                      (entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.key),
                      ),
                    )
                    .toList(),
                onChanged: onCurrencyChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
