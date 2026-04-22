import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/services/currency_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CurrencyService', () {
    test('convert handles same currency gracefully', () async {
      final service = CurrencyService();
      
      final quote = await service.convert(
        from: 'USD',
        to: 'USD',
        amount: 100.0,
      );
      
      expect(quote.from, equals('USD'));
      expect(quote.to, equals('USD'));
      expect(quote.amount, equals(100.0));
      expect(quote.convertedAmount, equals(100.0));
      expect(quote.rate, equals(1.0));
    });

    test('convert handles same currency with zero amount', () async {
      final service = CurrencyService();
      
      final quote = await service.convert(
        from: 'EUR',
        to: 'EUR',
        amount: 0.0,
      );
      
      expect(quote.from, equals('EUR'));
      expect(quote.to, equals('EUR'));
      expect(quote.amount, equals(0.0));
      expect(quote.convertedAmount, equals(0.0));
      expect(quote.rate, equals(1.0));
    });

    test('CurrencyQuote stores all fields correctly', () {
      final quote = CurrencyQuote(
        from: 'USD',
        to: 'EUR',
        amount: 100.0,
        convertedAmount: 91.8,
        rate: 0.918,
        effectiveDate: DateTime(2024, 3, 15),
      );

      expect(quote.from, equals('USD'));
      expect(quote.to, equals('EUR'));
      expect(quote.amount, equals(100.0));
      expect(quote.convertedAmount, equals(91.8));
      expect(quote.rate, equals(0.918));
      expect(quote.effectiveDate, equals(DateTime(2024, 3, 15)));
    });

    test('CurrenciesResult stores metadata correctly', () {
      final result = CurrenciesResult(
        currencies: {'USD': 'US Dollar', 'EUR': 'Euro'},
        isFromCache: true,
        isFromDefaults: false,
        errorMessage: 'Using cache',
        errorType: CurrencyErrorType.network,
      );

      expect(result.currencies.length, equals(2));
      expect(result.isFromCache, true);
      expect(result.isFromDefaults, false);
      expect(result.errorMessage, equals('Using cache'));
      expect(result.errorType, equals(CurrencyErrorType.network));
    });

    test('CurrenciesResult can be created with null error fields', () {
      final result = CurrenciesResult(
        currencies: {'USD': 'US Dollar'},
        isFromCache: false,
        isFromDefaults: false,
      );

      expect(result.errorMessage, isNull);
      expect(result.errorType, isNull);
    });

    test('CurrencyException contains error details', () {
      final exception = CurrencyException(
        CurrencyErrorType.network,
        'Connection failed',
        TimeoutException('test'),
      );

      expect(exception.type, equals(CurrencyErrorType.network));
      expect(exception.message, equals('Connection failed'));
      expect(exception.originalError, isA<TimeoutException>());
      expect(exception.toString(), contains('CurrencyException'));
      expect(exception.toString(), contains('network'));
    });

    test('CurrencyException toString includes message', () {
      final exception = CurrencyException(
        CurrencyErrorType.invalidResponse,
        'Invalid JSON received',
      );

      expect(exception.toString(), equals('CurrencyException(invalidResponse): Invalid JSON received'));
    });

    test('getCurrenciesWithMetadata returns default currencies when offline', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      final mockClient = MockClient((request) async {
        throw Exception('Network error');
      });
      
      final service = CurrencyService(client: mockClient);
      final result = await service.getCurrenciesWithMetadata();

      expect(result.isFromDefaults, true);
      expect(result.currencies.containsKey('USD'), true);
      expect(result.currencies.containsKey('EUR'), true);
      expect(result.currencies.containsKey('GBP'), true);
    });

    test('getCurrenciesWithMetadata uses cache when available', () async {
      final cachedCurrencies = {'USD': 'US Dollar', 'JPY': 'Japanese Yen'};
      SharedPreferences.setMockInitialValues({
        'cached_currencies': '{"USD": "US Dollar", "JPY": "Japanese Yen"}',
        'cached_currencies_timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      
      final mockClient = MockClient((request) async {
        throw Exception('Should not make network request');
      });
      
      final service = CurrencyService(client: mockClient);
      final result = await service.getCurrenciesWithMetadata();

      expect(result.isFromCache, true);
      expect(result.isFromDefaults, false);
      expect(result.currencies['USD'], equals('US Dollar'));
      expect(result.currencies['JPY'], equals('Japanese Yen'));
    });

    test('convert processes valid API response correctly', () async {
      SharedPreferences.setMockInitialValues({});
      
      final mockClient = MockClient((request) async {
        expect(request.url.path, equals('/v1/latest'));
        expect(request.url.queryParameters['base'], equals('USD'));
        expect(request.url.queryParameters['symbols'], equals('EUR'));
        return http.Response(
          '{"base":"USD","rates":{"EUR":0.918},"date":"2024-03-15"}',
          200,
        );
      });
      
      final service = CurrencyService(client: mockClient);
      final quote = await service.convert(from: 'USD', to: 'EUR', amount: 100);
      
      expect(quote.from, equals('USD'));
      expect(quote.to, equals('EUR'));
      expect(quote.amount, equals(100));
      expect(quote.convertedAmount, closeTo(91.8, 0.001));
      expect(quote.rate, closeTo(0.918, 0.001));
    });

    test('convert throws on API error after retries', () async {
      SharedPreferences.setMockInitialValues({});
      
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });
      
      final service = CurrencyService(client: mockClient);
      
      expect(
        () => service.convert(from: 'USD', to: 'EUR', amount: 100),
        throwsA(isA<CurrencyException>()),
      );
    });

    test('convert throws on network error after retries', () async {
      SharedPreferences.setMockInitialValues({});
      
      final mockClient = MockClient((request) async {
        throw http.ClientException('Network error');
      });
      
      final service = CurrencyService(client: mockClient);
      
      expect(
        () => service.convert(from: 'USD', to: 'EUR', amount: 100),
        throwsA(isA<CurrencyException>()),
      );
    });

    test('convert throws CurrencyException with invalidResponse on malformed JSON', () async {
      SharedPreferences.setMockInitialValues({});
      
      final mockClient = MockClient((request) async {
        return http.Response('not valid json', 200);
      });
      
      final service = CurrencyService(client: mockClient);
      
      expect(
        () => service.convert(from: 'USD', to: 'EUR', amount: 100),
        throwsA(isA<CurrencyException>()),
      );
    });

    test('convert throws CurrencyException when rate not found in response', () async {
      SharedPreferences.setMockInitialValues({});
      
      final mockClient = MockClient((request) async {
        return http.Response('{"base":"USD","rates":{}}', 200);
      });
      
      final service = CurrencyService(client: mockClient);
      
      expect(
        () => service.convert(from: 'USD', to: 'EUR', amount: 100),
        throwsA(isA<CurrencyException>()),
      );
    });

    test('convert throws CurrencyException on invalid rate value', () async {
      SharedPreferences.setMockInitialValues({});
      
      final mockClient = MockClient((request) async {
        return http.Response('{"base":"USD","rates":{"EUR":"invalid"},"date":"2024-03-15"}', 200);
      });
      
      final service = CurrencyService(client: mockClient);
      
      expect(
        () => service.convert(from: 'USD', to: 'EUR', amount: 100),
        throwsA(isA<CurrencyException>()),
      );
    });

    test('convert handles decimal amount correctly', () async {
      SharedPreferences.setMockInitialValues({});
      
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"base":"USD","rates":{"EUR":0.918},"date":"2024-03-15"}',
          200,
        );
      });
      
      final service = CurrencyService(client: mockClient);
      final quote = await service.convert(from: 'USD', to: 'EUR', amount: 1.5);
      
      expect(quote.amount, equals(1.5));
      expect(quote.convertedAmount, closeTo(1.377, 0.001));
    });

    test('dispose closes the HTTP client', () async {
      bool clientClosed = false;
      final mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });
      
      final service = CurrencyService(client: mockClient);
      service.dispose();
    });
  });

  group('CurrencyErrorType', () {
    test('all error types are defined', () {
      expect(CurrencyErrorType.values.length, equals(6));
      expect(CurrencyErrorType.values, contains(CurrencyErrorType.network));
      expect(CurrencyErrorType.values, contains(CurrencyErrorType.timeout));
      expect(CurrencyErrorType.values, contains(CurrencyErrorType.invalidResponse));
      expect(CurrencyErrorType.values, contains(CurrencyErrorType.serverError));
      expect(CurrencyErrorType.values, contains(CurrencyErrorType.cacheCorrupted));
      expect(CurrencyErrorType.values, contains(CurrencyErrorType.unknown));
    });
  });
}
