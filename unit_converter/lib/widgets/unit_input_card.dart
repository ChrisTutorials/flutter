import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/conversion.dart';

class UnitInputCard extends StatelessWidget {
  const UnitInputCard({
    super.key,
    required this.label,
    required this.valueController,
    required this.selectedUnit,
    required this.units,
    required this.onUnitChanged,
    required this.onChanged,
    required this.isReadOnly,
  });

  final String label;
  final TextEditingController valueController;
  final Unit? selectedUnit;
  final List<Unit> units;
  final ValueChanged<Unit?>? onUnitChanged;
  final ValueChanged<String>? onChanged;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                    controller: valueController,
                    readOnly: isReadOnly,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    inputFormatters: isReadOnly
                        ? null
                        : [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'-?\d*\.?\d*'),
                            ),
                          ],
                    decoration: InputDecoration(
                      hintText: isReadOnly ? 'Converted value' : 'Enter value',
                    ),
                    onChanged: onChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<Unit>(
                    initialValue: selectedUnit,
                    items: units
                        .map(
                          (unit) => DropdownMenuItem<Unit>(
                            value: unit,
                            child: Text(unit.symbol),
                          ),
                        )
                        .toList(),
                    onChanged: onUnitChanged != null
                        ? (unit) => onUnitChanged!(unit)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
