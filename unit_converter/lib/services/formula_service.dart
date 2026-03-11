import '../models/conversion.dart';
import '../utils/number_formatter.dart';

class FormulaService {
  static String buildFormula({
    required String categoryName,
    required Unit? fromUnit,
    required Unit? toUnit,
  }) {
    if (fromUnit == null || toUnit == null) {
      return 'Select two units to view the formula.';
    }

    if (categoryName == 'Temperature') {
      return _temperatureFormula(fromUnit.symbol, toUnit.symbol);
    }

    return 'value × ${_formatFactor(fromUnit.conversionFactor)} ÷ ${_formatFactor(toUnit.conversionFactor)}';
  }

  static String? buildCalculation({
    required String categoryName,
    required Unit? fromUnit,
    required Unit? toUnit,
    required double? inputValue,
  }) {
    if (fromUnit == null || toUnit == null || inputValue == null) {
      return null;
    }

    final outputValue = ConversionData.convert(
      inputValue,
      fromUnit,
      toUnit,
      categoryName,
    );

    if (categoryName == 'Temperature') {
      return _temperatureCalculation(
        inputValue,
        outputValue,
        fromUnit.symbol,
        toUnit.symbol,
      );
    }

    return '${NumberFormatter.formatNumber(inputValue)} × ${_formatFactor(fromUnit.conversionFactor)} ÷ ${_formatFactor(toUnit.conversionFactor)} = ${NumberFormatter.formatNumber(outputValue)}';
  }

  static String _temperatureFormula(String fromSymbol, String toSymbol) {
    if (fromSymbol == toSymbol) {
      return 'value';
    }

    switch ('$fromSymbol:$toSymbol') {
      case '°C:°F':
        return '(value × 9 / 5) + 32';
      case '°F:°C':
        return '(value - 32) × 5 / 9';
      case '°C:K':
        return 'value + 273.15';
      case 'K:°C':
        return 'value - 273.15';
      case '°F:K':
        return '((value - 32) × 5 / 9) + 273.15';
      case 'K:°F':
        return '((value - 273.15) × 9 / 5) + 32';
      default:
        return 'value';
    }
  }

  static String _temperatureCalculation(
    double inputValue,
    double outputValue,
    String fromSymbol,
    String toSymbol,
  ) {
    switch ('$fromSymbol:$toSymbol') {
      case '°C:°F':
        return '(${NumberFormatter.formatNumber(inputValue)} × 9 / 5) + 32 = ${NumberFormatter.formatNumber(outputValue)}';
      case '°F:°C':
        return '(${NumberFormatter.formatNumber(inputValue)} - 32) × 5 / 9 = ${NumberFormatter.formatNumber(outputValue)}';
      case '°C:K':
        return '${NumberFormatter.formatNumber(inputValue)} + 273.15 = ${NumberFormatter.formatNumber(outputValue)}';
      case 'K:°C':
        return '${NumberFormatter.formatNumber(inputValue)} - 273.15 = ${NumberFormatter.formatNumber(outputValue)}';
      case '°F:K':
        return '((${NumberFormatter.formatNumber(inputValue)} - 32) × 5 / 9) + 273.15 = ${NumberFormatter.formatNumber(outputValue)}';
      case 'K:°F':
        return '((${NumberFormatter.formatNumber(inputValue)} - 273.15) × 9 / 5) + 32 = ${NumberFormatter.formatNumber(outputValue)}';
      default:
        return NumberFormatter.formatNumber(outputValue);
    }
  }

  static String _formatFactor(double value) {
    return NumberFormatter.formatNumber(value);
  }
}