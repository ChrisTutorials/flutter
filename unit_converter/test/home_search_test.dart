import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/models/conversion.dart';
import 'package:unit_converter/utils/home_search.dart';

void main() {
  group('HomeSearch instant conversions', () {
    final scenarios =
        <
          ({
            String query,
            String category,
            String fromSymbol,
            String toSymbol,
            double output,
          })
        >[
          (
            query: '60g to lb',
            category: 'Weight',
            fromSymbol: 'g',
            toSymbol: 'lb',
            output: 0.1322773573,
          ),
          (
            query: '5 km to mi',
            category: 'Length',
            fromSymbol: 'km',
            toSymbol: 'mi',
            output: 3.1068559612,
          ),
          (
            query: '32 F to C',
            category: 'Temperature',
            fromSymbol: '°F',
            toSymbol: '°C',
            output: 0,
          ),
          (
            query: '1 gal to L',
            category: 'Volume',
            fromSymbol: 'gal',
            toSymbol: 'L',
            output: 3.785411784,
          ),
          (
            query: '120 psi to bar',
            category: 'Pressure',
            fromSymbol: 'psi',
            toSymbol: 'bar',
            output: 8.2737087518,
          ),
          (
            query: '90 min to h',
            category: 'Time',
            fromSymbol: 'min',
            toSymbol: 'h',
            output: 1.5,
          ),
          (
            query: '10 metres to feet',
            category: 'Length',
            fromSymbol: 'm',
            toSymbol: 'ft',
            output: 32.8083989501,
          ),
          (
            query: '2 liters to mL',
            category: 'Volume',
            fromSymbol: 'L',
            toSymbol: 'mL',
            output: 2000,
          ),
          (
            query: '20 gal l',
            category: 'Volume',
            fromSymbol: 'gal',
            toSymbol: 'L',
            output: 75.70823568,
          ),
          (
            query: '10 meters feet',
            category: 'Length',
            fromSymbol: 'm',
            toSymbol: 'ft',
            output: 32.8083989501,
          ),
          (
            query: '32 f c',
            category: 'Temperature',
            fromSymbol: '°F',
            toSymbol: '°C',
            output: 0,
          ),
          (
            query: '1 imp gal l',
            category: 'Volume',
            fromSymbol: 'imp gal',
            toSymbol: 'L',
            output: 4.54609,
          ),
          (
            query: '3.5 mph km/h',
            category: 'Speed',
            fromSymbol: 'mph',
            toSymbol: 'km/h',
            output: 5.632704,
          ),
        ];

    for (final scenario in scenarios) {
      test('parses ${scenario.query}', () {
        final interpretation = HomeSearch.analyze(
          scenario.query,
          ConversionData.categories,
        );

        expect(interpretation.instantConversion, isNotNull);

        final match = interpretation.instantConversion!;
        expect(match.category.name, scenario.category);
        expect(match.fromUnit.symbol, scenario.fromSymbol);
        expect(match.toUnit.symbol, scenario.toSymbol);
        expect(match.outputValue, closeTo(scenario.output, 0.000001));
      });
    }

    final invalidQueries = <String>[
      'usd to eur',
      'convert weight',
      '60 to lb',
      '20 gal',
      '20 gal volume',
      '12 apples to oranges',
    ];

    for (final query in invalidQueries) {
      test('does not parse $query as an instant conversion', () {
        final interpretation = HomeSearch.analyze(
          query,
          ConversionData.categories,
        );

        expect(interpretation.instantConversion, isNull);
      });
    }
  });

  group('HomeSearch filter tokens', () {
    final scenarios = <({String query, List<String> tokens})>[
      (query: 'travel', tokens: ['travel']),
      (query: 'ft to m', tokens: ['ft', 'm']),
      (query: 'convert pressure psi', tokens: ['pressure', 'psi']),
      (query: 'custom unit symbol', tokens: ['custom', 'unit', 'symbol']),
    ];

    for (final scenario in scenarios) {
      test('builds tokens for ${scenario.query}', () {
        expect(HomeSearch.buildFilterTokens(scenario.query), scenario.tokens);
      });
    }
  });
}
