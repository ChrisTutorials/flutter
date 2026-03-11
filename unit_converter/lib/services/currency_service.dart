import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyQuote {
  final String from;
  final String to;
  final double amount;
  final double convertedAmount;
  final double rate;
  final DateTime effectiveDate;

  const CurrencyQuote({
    required this.from,
    required this.to,
    required this.amount,
    required this.convertedAmount,
    required this.rate,
    required this.effectiveDate,
  });
}

class CurrenciesResult {
  final Map<String, String> currencies;
  final bool isFromCache;
  final bool isFromDefaults;
  final String? errorMessage;

  const CurrenciesResult({
    required this.currencies,
    required this.isFromCache,
    required this.isFromDefaults,
    this.errorMessage,
  });
}

class CurrencyService {
  static const String _apiBase = 'https://api.frankfurter.dev/v1';
  static const String _currenciesCacheKey = 'cached_currencies';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  CurrencyService({http.Client? client}) : _client = client ?? http.Client();

  Future<CurrenciesResult> getCurrenciesWithMetadata() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await _client
          .get(Uri.parse('$_apiBase/currencies'))
          .timeout(_timeout);
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch currencies');
      }

      final decoded = Map<String, dynamic>.from(jsonDecode(response.body));
      final currencies = decoded.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      await prefs.setString(_currenciesCacheKey, jsonEncode(currencies));

      return CurrenciesResult(
        currencies: currencies,
        isFromCache: false,
        isFromDefaults: false,
      );
    } catch (_) {
      final cached = prefs.getString(_currenciesCacheKey);
      if (cached != null) {
        try {
          final decoded = Map<String, dynamic>.from(jsonDecode(cached));
          final currencies = decoded.map(
            (key, value) => MapEntry(key, value.toString()),
          );

          return CurrenciesResult(
            currencies: currencies,
            isFromCache: true,
            isFromDefaults: false,
            errorMessage: 'Using cached data - offline mode',
          );
        } catch (_) {
          // Ignore invalid cache and fall back to defaults.
        }
      }

      return const CurrenciesResult(
        currencies: {
          'USD': 'US Dollar',
          'EUR': 'Euro',
          'GBP': 'British Pound',
          'JPY': 'Japanese Yen',
          'CAD': 'Canadian Dollar',
          'AUD': 'Australian Dollar',
        },
        isFromCache: false,
        isFromDefaults: true,
        errorMessage:
            'Using default currencies - offline mode, no cache available',
      );
    }
  }

  Future<Map<String, String>> getCurrencies() async {
    final result = await getCurrenciesWithMetadata();
    return result.currencies;
  }

  Future<CurrencyQuote> convert({
    required String from,
    required String to,
    required double amount,
  }) async {
    if (from == to) {
      return CurrencyQuote(
        from: from,
        to: to,
        amount: amount,
        convertedAmount: amount,
        rate: 1,
        effectiveDate: DateTime.now(),
      );
    }

    final uri = Uri.parse('$_apiBase/latest?base=$from&symbols=$to');
    final response = await _client.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch currency rate');
    }

    final decoded = Map<String, dynamic>.from(jsonDecode(response.body));
    final rates = Map<String, dynamic>.from(decoded['rates'] as Map);
    final rate = (rates[to] as num).toDouble();

    return CurrencyQuote(
      from: from,
      to: to,
      amount: amount,
      convertedAmount: amount * rate,
      rate: rate,
      effectiveDate: DateTime.parse(decoded['date'] as String),
    );
  }
}
