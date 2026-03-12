import '../models/conversion.dart';

class HomeSearchInterpretation {
  const HomeSearchInterpretation({
    required this.rawQuery,
    required this.filterTokens,
    this.instantConversion,
  });

  final String rawQuery;
  final List<String> filterTokens;
  final InstantConversionMatch? instantConversion;

  bool get isSearching => rawQuery.trim().isNotEmpty;
}

class InstantConversionMatch {
  const InstantConversionMatch({
    required this.category,
    required this.fromUnit,
    required this.toUnit,
    required this.inputValue,
    required this.outputValue,
  });

  final ConversionCategory category;
  final Unit fromUnit;
  final Unit toUnit;
  final double inputValue;
  final double outputValue;
}

class HomeSearch {
  static const Set<String> _stopWords = {
    'to',
    'into',
    'in',
    'convert',
    'conversion',
    'from',
  };

  static final RegExp _instantPattern = RegExp(
    r'^\s*([-+]?(?:\d+(?:[\.,]\d+)?|[\.,]\d+))\s*(.+?)\s*(?:\bto\b|\binto\b|\bin\b|=|->)\s*(.+?)\s*$',
    caseSensitive: false,
  );

  static final RegExp _valueWithUnitsPattern = RegExp(
    r'^\s*([-+]?(?:\d+(?:[\.,]\d+)?|[\.,]\d+))\s*(.+?)\s*$',
    caseSensitive: false,
  );

  static HomeSearchInterpretation analyze(
    String query,
    List<ConversionCategory> categories,
  ) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const HomeSearchInterpretation(rawQuery: '', filterTokens: []);
    }

    final instantConversion = _tryParseInstantConversion(
      trimmedQuery,
      categories,
    );

    return HomeSearchInterpretation(
      rawQuery: trimmedQuery,
      filterTokens: instantConversion == null
          ? buildFilterTokens(trimmedQuery)
          : <String>[
              _normalize(instantConversion.category.name),
              ..._aliasesForUnit(instantConversion.fromUnit).map(_normalize),
              ..._aliasesForUnit(instantConversion.toUnit).map(_normalize),
            ].where((token) => token.isNotEmpty).toSet().toList(),
      instantConversion: instantConversion,
    );
  }

  static List<String> buildFilterTokens(String query) {
    return _tokenize(
      query,
    ).where((token) => !_stopWords.contains(token)).toSet().toList();
  }

  static bool matchesTokens(String value, List<String> tokens) {
    if (tokens.isEmpty) {
      return true;
    }

    final normalizedValue = _normalize(value);
    return tokens.every(normalizedValue.contains);
  }

  static String buildCategorySearchText(ConversionCategory category) {
    final buffer = StringBuffer(category.name);
    for (final unit in category.units) {
      buffer.write(' ');
      buffer.writeAll(_aliasesForUnit(unit), ' ');
    }
    return buffer.toString();
  }

  static InstantConversionMatch? _tryParseInstantConversion(
    String query,
    List<ConversionCategory> categories,
  ) {
    final explicitMatch = _instantPattern.firstMatch(query);
    if (explicitMatch != null) {
      return _buildInstantConversionMatch(
        valueText: explicitMatch.group(1)!,
        fromUnitText: explicitMatch.group(2)!,
        toUnitText: explicitMatch.group(3)!,
        categories: categories,
      );
    }

    final impliedMatch = _valueWithUnitsPattern.firstMatch(query);
    if (impliedMatch == null) {
      return null;
    }

    final remainder = impliedMatch.group(2)!.trim();
    if (remainder.isEmpty) {
      return null;
    }

    final resolvedMatches = <InstantConversionMatch>[];
    for (final separator in RegExp(r'\s+').allMatches(remainder)) {
      final fromUnitText = remainder.substring(0, separator.start).trim();
      final toUnitText = remainder.substring(separator.end).trim();

      if (fromUnitText.isEmpty || toUnitText.isEmpty) {
        continue;
      }

      final resolvedMatch = _buildInstantConversionMatch(
        valueText: impliedMatch.group(1)!,
        fromUnitText: fromUnitText,
        toUnitText: toUnitText,
        categories: categories,
      );
      if (resolvedMatch != null) {
        resolvedMatches.add(resolvedMatch);
      }
    }

    final uniqueMatches = <String, InstantConversionMatch>{};
    for (final resolvedMatch in resolvedMatches) {
      uniqueMatches[_instantConversionKey(resolvedMatch)] = resolvedMatch;
    }

    if (uniqueMatches.length != 1) {
      return null;
    }

    return uniqueMatches.values.single;
  }

  static InstantConversionMatch? _buildInstantConversionMatch({
    required String valueText,
    required String fromUnitText,
    required String toUnitText,
    required List<ConversionCategory> categories,
  }) {
    final value = double.tryParse(valueText.replaceAll(',', '.'));
    if (value == null) {
      return null;
    }

    final fromCandidates = _resolveUnitCandidates(fromUnitText, categories);
    final toCandidates = _resolveUnitCandidates(toUnitText, categories);

    final resolvedMatches = <InstantConversionMatch>[];
    for (final fromCandidate in fromCandidates) {
      for (final toCandidate in toCandidates) {
        if (fromCandidate.category.name != toCandidate.category.name) {
          continue;
        }

        resolvedMatches.add(
          InstantConversionMatch(
            category: fromCandidate.category,
            fromUnit: fromCandidate.unit,
            toUnit: toCandidate.unit,
            inputValue: value,
            outputValue: ConversionData.convert(
              value,
              fromCandidate.unit,
              toCandidate.unit,
              fromCandidate.category.name,
            ),
          ),
        );
      }
    }

    if (resolvedMatches.length != 1) {
      return null;
    }

    return resolvedMatches.single;
  }

  static String _instantConversionKey(InstantConversionMatch match) {
    return '${match.category.name}|${match.fromUnit.symbol}|${match.toUnit.symbol}|${match.inputValue}';
  }

  static List<_ResolvedUnitCandidate> _resolveUnitCandidates(
    String rawUnit,
    List<ConversionCategory> categories,
  ) {
    final trimmedUnit = rawUnit.trim();
    if (trimmedUnit.isEmpty) {
      return const [];
    }

    final candidates = <_ResolvedUnitCandidate>[];
    for (final category in categories) {
      for (final unit in category.units) {
        candidates.add(_ResolvedUnitCandidate(category: category, unit: unit));
      }
    }

    final exactSymbolMatches = candidates
        .where((candidate) => candidate.unit.symbol == trimmedUnit)
        .toList();
    if (exactSymbolMatches.isNotEmpty) {
      return exactSymbolMatches;
    }

    final normalizedUnit = _normalize(trimmedUnit);
    final symbolMatches = candidates
        .where(
          (candidate) => _normalize(candidate.unit.symbol) == normalizedUnit,
        )
        .toList();
    if (symbolMatches.length == 1) {
      return symbolMatches;
    }

    return candidates
        .where(
          (candidate) => _aliasesForUnit(
            candidate.unit,
          ).map(_normalize).contains(normalizedUnit),
        )
        .toList();
  }

  static List<String> _aliasesForUnit(Unit unit) {
    final baseName = unit.name.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
    final normalizedName = baseName.toLowerCase();

    final aliases = <String>{
      unit.symbol,
      unit.name,
      baseName,
      normalizedName,
      _pluralize(normalizedName),
      _alternateSpelling(normalizedName),
      _pluralize(_alternateSpelling(normalizedName)),
    };

    if (unit.symbol == '°C') {
      aliases.addAll({'c', 'deg c', 'degree c', 'degrees c', 'centigrade'});
    }
    if (unit.symbol == '°F') {
      aliases.addAll({'f', 'deg f', 'degree f', 'degrees f'});
    }
    if (unit.symbol == 'K') {
      aliases.addAll({'kelvin', 'degrees kelvin'});
    }
    if (unit.symbol == 'lb') {
      aliases.add('lbs');
    }
    if (unit.symbol == 'ft') {
      aliases.addAll({'foot', 'feet'});
    }
    if (unit.symbol == 'in') {
      aliases.addAll({'inch', 'inches'});
    }
    if (unit.symbol == 'L') {
      aliases.addAll({'l', 'liter', 'liters', 'litre', 'litres'});
    }
    if (unit.symbol == 'mL') {
      aliases.addAll({
        'ml',
        'milliliter',
        'milliliters',
        'millilitre',
        'millilitres',
      });
    }
    if (unit.symbol == 'gal') {
      aliases.addAll({'gallon', 'gallons'});
    }

    return aliases.where((alias) => alias.trim().isNotEmpty).toList();
  }

  static String _alternateSpelling(String value) {
    return value
        .replaceAll('meter', 'metre')
        .replaceAll('liter', 'litre')
        .replaceAll('kilometer', 'kilometre')
        .replaceAll('millimeter', 'millimetre')
        .replaceAll('centimeter', 'centimetre')
        .replaceAll('micrometer', 'micrometre');
  }

  static String _pluralize(String value) {
    if (value.isEmpty) {
      return value;
    }
    if (value == 'foot') {
      return 'feet';
    }
    if (value.endsWith('ch') ||
        value.endsWith('sh') ||
        value.endsWith('s') ||
        value.endsWith('x') ||
        value.endsWith('z')) {
      return '${value}es';
    }
    if (value.endsWith('y') && value.length > 1) {
      final beforeY = value[value.length - 2];
      if (!'aeiou'.contains(beforeY)) {
        return '${value.substring(0, value.length - 1)}ies';
      }
    }
    return '${value}s';
  }

  static List<String> _tokenize(String value) {
    return RegExp(r'[a-z/]+|\d+(?:\.\d+)?')
        .allMatches(_normalize(value))
        .map((match) => match.group(0)!)
        .where((token) => double.tryParse(token) == null)
        .toList();
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('°', '')
        .replaceAll('²', '2')
        .replaceAll('³', '3')
        .replaceAll('µ', 'u')
        .replaceAll('μ', 'u')
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[^a-z0-9/+.-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _ResolvedUnitCandidate {
  const _ResolvedUnitCandidate({required this.category, required this.unit});

  final ConversionCategory category;
  final Unit unit;
}
