import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/services/currency_service.dart';

class FakeClient extends http.BaseClient {
  FakeClient(this._handler);

  final Future<http.Response> Function(http.BaseRequest request) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('getCurrencies returns API data when available', () async {
    final client = FakeClient((request) async {
      return http.Response(
        jsonEncode({'USD': 'US Dollar', 'EUR': 'Euro'}),
        200,
      );
    });
    final service = CurrencyService(client: client);

    final result = await service.getCurrenciesWithMetadata();

    expect(result.currencies['USD'], 'US Dollar');
    expect(result.isFromCache, isFalse);
    expect(result.isFromDefaults, isFalse);
  });

  test('getCurrencies falls back to cache on request failure', () async {
    SharedPreferences.setMockInitialValues({
      'cached_currencies': jsonEncode({'GBP': 'British Pound'}),
    });

    final client = FakeClient((request) async {
      throw Exception('offline');
    });
    final service = CurrencyService(client: client);

    final result = await service.getCurrenciesWithMetadata();

    expect(result.currencies['GBP'], 'British Pound');
    expect(result.isFromCache, isTrue);
    expect(result.isFromDefaults, isFalse);
  });

  test('getCurrencies falls back to defaults when cache is missing', () async {
    final client = FakeClient((request) async {
      throw Exception('offline');
    });
    final service = CurrencyService(client: client);

    final result = await service.getCurrenciesWithMetadata();

    expect(result.currencies.keys, containsAll(<String>['USD', 'EUR', 'GBP']));
    expect(result.isFromDefaults, isTrue);
  });

  test('convert parses latest quote response', () async {
    final client = FakeClient((request) async {
      return http.Response(
        jsonEncode({
          'amount': 10,
          'base': 'USD',
          'date': '2026-03-11',
          'rates': {'EUR': 0.92},
        }),
        200,
      );
    });
    final service = CurrencyService(client: client);

    final quote = await service.convert(from: 'USD', to: 'EUR', amount: 10);

    expect(quote.rate, 0.92);
    expect(quote.convertedAmount, closeTo(9.2, 0.000001));
    expect(quote.effectiveDate, DateTime(2026, 3, 11));
  });

  test('convert short-circuits identical currencies', () async {
    final service = CurrencyService(
      client: FakeClient((request) async {
        fail('network should not be called for identical currencies');
      }),
    );

    final quote = await service.convert(from: 'USD', to: 'USD', amount: 5);

    expect(quote.rate, 1);
    expect(quote.convertedAmount, 5);
  });
}
