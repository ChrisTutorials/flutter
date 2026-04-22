import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Errors that can occur during currency operations
enum CurrencyErrorType {
  network,
  timeout,
  invalidResponse,
  serverError,
  cacheCorrupted,
  unknown,
}

class CurrencyException implements Exception {
  final CurrencyErrorType type;
  final String message;
  final dynamic originalError;

  CurrencyException(this.type, this.message, [this.originalError]);

  @override
  String toString() => 'CurrencyException($type): $message';
}

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
  final CurrencyErrorType? errorType;

  const CurrenciesResult({
    required this.currencies,
    required this.isFromCache,
    required this.isFromDefaults,
    this.errorMessage,
    this.errorType,
  });
}

class CurrencyService {
  static const String _apiBase = 'https://api.frankfurter.dev/v1';
  static const String _currenciesCacheKey = 'cached_currencies';
  static const String _currenciesCacheTimestampKey = 'cached_currencies_timestamp';
  static const Duration _timeout = Duration(seconds: 10);
  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 1);

  final http.Client _client;

  CurrencyService({http.Client? client}) : _client = client ?? http.Client();

  /// Get currencies with metadata and proper error handling
  Future<CurrenciesResult> getCurrenciesWithMetadata() async {
    final prefs = await SharedPreferences.getInstance();

    // Try network fetch with retry
    final networkResult = await _fetchCurrenciesWithRetry(prefs);
    if (networkResult != null) {
      return networkResult;
    }

    // Fallback to cache
    final cacheResult = await _getCachedCurrencies(prefs);
    if (cacheResult != null) {
      return cacheResult;
    }

    // Final fallback to hardcoded defaults
    return const CurrenciesResult(
      currencies: {
        'AUD': 'Australian Dollar',
        'BRL': 'Brazilian Real',
        'CAD': 'Canadian Dollar',
        'CHF': 'Swiss Franc',
        'CNY': 'Chinese Renminbi Yuan',
        'CZK': 'Czech Koruna',
        'DKK': 'Danish Krone',
        'EUR': 'Euro',
        'GBP': 'British Pound',
        'HKD': 'Hong Kong Dollar',
        'HUF': 'Hungarian Forint',
        'IDR': 'Indonesian Rupiah',
        'ILS': 'Israeli New Shekel',
        'INR': 'Indian Rupee',
        'ISK': 'Icelandic Króna',
        'JPY': 'Japanese Yen',
        'KRW': 'South Korean Won',
        'MXN': 'Mexican Peso',
        'MYR': 'Malaysian Ringgit',
        'NOK': 'Norwegian Krone',
        'NZD': 'New Zealand Dollar',
        'PHP': 'Philippine Peso',
        'PLN': 'Polish Złoty',
        'RON': 'Romanian Leu',
        'SEK': 'Swedish Krona',
        'SGD': 'Singapore Dollar',
        'THB': 'Thai Baht',
        'TRY': 'Turkish Lira',
        'USD': 'United States Dollar',
        'ZAR': 'South African Rand',
      },
      isFromCache: false,
      isFromDefaults: true,
      errorMessage: 'Using default currencies - completely offline',
      errorType: CurrencyErrorType.network,
    );
  }

  /// Fetch currencies with exponential backoff retry
  Future<CurrenciesResult?> _fetchCurrenciesWithRetry(
    SharedPreferences prefs, {
    int retryCount = 0,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse('$_apiBase/currencies'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return _processCurrenciesResponse(response.body, prefs);
      }

      // Server error - retry with backoff
      if (response.statusCode >= 500 && retryCount < _maxRetries) {
        return await _retryWithDelay(
          () => _fetchCurrenciesWithRetry(prefs, retryCount: retryCount + 1),
          retryCount,
        );
      }

      throw CurrencyException(
        CurrencyErrorType.serverError,
        'Server returned ${response.statusCode}',
      );
    } on http.ClientException catch (e) {
      if (retryCount < _maxRetries) {
        return await _retryWithDelay(
          () => _fetchCurrenciesWithRetry(prefs, retryCount: retryCount + 1),
          retryCount,
        );
      }
      throw CurrencyException(CurrencyErrorType.network, 'Network error', e);
    } on FormatException catch (e) {
      throw CurrencyException(CurrencyErrorType.invalidResponse, 'Invalid response format', e);
    }
  }

  /// Retry with exponential backoff
  Future<CurrenciesResult?> _retryWithDelay(
    Future<CurrenciesResult?> Function() operation,
    int retryCount,
  ) async {
    final delay = _baseRetryDelay * (retryCount + 1);
    await Future.delayed(delay);
    return operation();
  }

  /// Process currencies response with validation
  CurrenciesResult _processCurrenciesResponse(
    String responseBody,
    SharedPreferences prefs,
  ) {
    try {
      final decoded = jsonDecode(responseBody);
      
      if (decoded is! Map<String, dynamic>) {
        throw CurrencyException(
          CurrencyErrorType.invalidResponse,
          'Expected Map, got ${decoded.runtimeType}',
        );
      }

      final currencies = decoded.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );

      // Validate we got reasonable data
      if (currencies.length < 10) {
        throw CurrencyException(
          CurrencyErrorType.invalidResponse,
          'Too few currencies returned: ${currencies.length}',
        );
      }

      // Cache successful response
      prefs.setString(_currenciesCacheKey, jsonEncode(currencies));
      prefs.setInt(
        _currenciesCacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      return CurrenciesResult(
        currencies: currencies,
        isFromCache: false,
        isFromDefaults: false,
      );
    } on CurrencyException {
      rethrow;
    } catch (e) {
      throw CurrencyException(CurrencyErrorType.invalidResponse, 'Failed to parse response', e);
    }
  }

  /// Get currencies from cache with validation
  Future<CurrenciesResult?> _getCachedCurrencies(
    SharedPreferences prefs,
  ) async {
    try {
      final cached = prefs.getString(_currenciesCacheKey);
      if (cached == null) return null;

      final decoded = Map<String, dynamic>.from(jsonDecode(cached));
      final currencies = decoded.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );

      final timestamp = prefs.getInt(_currenciesCacheTimestampKey);
      final cacheAge = timestamp != null
          ? DateTime.now().millisecondsSinceEpoch - timestamp
          : null;

      String? warning;
      if (cacheAge != null && cacheAge > const Duration(days: 7).inMilliseconds) {
        warning = 'Warning: Cache is over 7 days old';
      }

      return CurrenciesResult(
        currencies: currencies,
        isFromCache: true,
        isFromDefaults: false,
        errorMessage: warning ?? 'Using cached data',
      );
    } catch (e) {
      throw CurrencyException(CurrencyErrorType.cacheCorrupted, 'Cache corrupted', e);
    }
  }

  Future<Map<String, String>> getCurrencies() async {
    final result = await getCurrenciesWithMetadata();
    return result.currencies;
  }

  /// Convert currency with retry logic
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

    return _convertWithRetry(from: from, to: to, amount: amount);
  }

  Future<CurrencyQuote> _convertWithRetry({
    required String from,
    required String to,
    required double amount,
    int retryCount = 0,
  }) async {
    try {
      final uri = Uri.parse('$_apiBase/latest?base=$from&symbols=$to');
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        return _processConvertResponse(response.body, from, to, amount);
      }

      if (response.statusCode >= 500 && retryCount < _maxRetries) {
        final delay = _baseRetryDelay * (retryCount + 1);
        await Future.delayed(delay);
        return _convertWithRetry(
          from: from,
          to: to,
          amount: amount,
          retryCount: retryCount + 1,
        );
      }

      throw CurrencyException(
        CurrencyErrorType.serverError,
        'Server returned ${response.statusCode}',
      );
    } on http.ClientException catch (e) {
      if (retryCount < _maxRetries) {
        final delay = _baseRetryDelay * (retryCount + 1);
        await Future.delayed(delay);
        return _convertWithRetry(
          from: from,
          to: to,
          amount: amount,
          retryCount: retryCount + 1,
        );
      }
      throw CurrencyException(CurrencyErrorType.network, 'Network error', e);
    }
  }

  /// Process convert response with validation
  CurrencyQuote _processConvertResponse(
    String responseBody,
    String from,
    String to,
    double amount,
  ) {
    try {
      final decoded = jsonDecode(responseBody);
      
      if (decoded is! Map<String, dynamic>) {
        throw CurrencyException(
          CurrencyErrorType.invalidResponse,
          'Invalid response format',
        );
      }

      final rates = decoded['rates'];
      if (rates is! Map) {
        throw CurrencyException(
          CurrencyErrorType.invalidResponse,
          'Missing or invalid rates',
        );
      }

      final rateValue = rates[to];
      if (rateValue == null) {
        throw CurrencyException(
          CurrencyErrorType.invalidResponse,
          'Rate not found for $to',
        );
      }

      final rate = (rateValue as num).toDouble();
      
      if (!rate.isFinite || rate <= 0) {
        throw CurrencyException(
          CurrencyErrorType.invalidResponse,
          'Invalid rate value: $rate',
        );
      }

      final dateStr = decoded['date'] as String?;
      final effectiveDate = dateStr != null
          ? DateTime.tryParse(dateStr) ?? DateTime.now()
          : DateTime.now();

      return CurrencyQuote(
        from: from,
        to: to,
        amount: amount,
        convertedAmount: amount * rate,
        rate: rate,
        effectiveDate: effectiveDate,
      );
    } on CurrencyException {
      rethrow;
    } catch (e) {
      throw CurrencyException(
        CurrencyErrorType.invalidResponse,
        'Failed to parse conversion response',
        e,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
