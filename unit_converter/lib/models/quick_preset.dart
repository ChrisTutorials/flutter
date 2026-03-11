/// Represents a quick preset for common conversions.
class QuickPreset {
  final String label;
  final String subtitle;
  final String? categoryName;
  final String fromSymbol;
  final String toSymbol;
  final double sampleValue;
  final bool isCurrency;

  const QuickPreset.standard({
    required this.label,
    required this.subtitle,
    required this.categoryName,
    required this.fromSymbol,
    required this.toSymbol,
    this.sampleValue = 1,
  }) : isCurrency = false;

  const QuickPreset.currency({
    required this.label,
    required this.subtitle,
    required this.fromSymbol,
    required this.toSymbol,
    this.sampleValue = 1,
  }) : isCurrency = true,
       categoryName = null;
}

/// Pre-defined quick presets for common conversions.
const List<QuickPreset> kQuickPresets = [
  QuickPreset.standard(
    label: '°F to °C',
    subtitle: 'Weather checks',
    categoryName: 'Temperature',
    fromSymbol: '°F',
    toSymbol: '°C',
    sampleValue: 72,
  ),
  QuickPreset.standard(
    label: 'kg to lb',
    subtitle: 'Fitness tracking',
    categoryName: 'Weight',
    fromSymbol: 'kg',
    toSymbol: 'lb',
    sampleValue: 1,
  ),
  QuickPreset.standard(
    label: 'in to cm',
    subtitle: 'DIY and sizing',
    categoryName: 'Length',
    fromSymbol: 'in',
    toSymbol: 'cm',
    sampleValue: 1,
  ),
  QuickPreset.standard(
    label: 'gal to L',
    subtitle: 'Kitchen and fuel',
    categoryName: 'Volume',
    fromSymbol: 'gal',
    toSymbol: 'L',
    sampleValue: 1,
  ),
  QuickPreset.currency(
    label: 'USD to EUR',
    subtitle: 'Travel money',
    fromSymbol: 'USD',
    toSymbol: 'EUR',
    sampleValue: 1,
  ),
  QuickPreset.currency(
    label: 'EUR to GBP',
    subtitle: 'Cross-border spend',
    fromSymbol: 'EUR',
    toSymbol: 'GBP',
    sampleValue: 1,
  ),
];
