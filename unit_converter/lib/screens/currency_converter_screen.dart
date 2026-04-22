import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/conversion.dart';
import '../models/quick_preset.dart';
import '../services/currency_service.dart';
import '../services/recent_conversions_service.dart';
import '../services/widget_service.dart';
import '../utils/number_formatter.dart';
import '../widgets/currency_input_row.dart';

/// Screen for currency conversion with live rates.
class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({
    super.key,
    this.preset,
    this.demoCurrencies,
    this.demoQuote,
  });

  final QuickPreset? preset;
  final Map<String, String>? demoCurrencies;
  final CurrencyQuote? demoQuote;

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  late final CurrencyService _currencyService;
  final RecentConversionsService _recentConversionsService =
      RecentConversionsService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();

  Map<String, String> _currencies = const {};
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  CurrencyQuote? _quote;
  String? _error;
  bool _isLoading = true;
  bool _isOffline = false;
  String? _offlineWarning;
  Timer? _debounce;
  int _requestVersion = 0;

  List<QuickPreset> get _currencyPresets {
    return kQuickPresets.where((preset) => preset.isCurrency).toList();
  }

  @override
  void initState() {
    super.initState();
    _currencyService = CurrencyService();
    _fromCurrency = widget.preset?.fromSymbol ?? _fromCurrency;
    _toCurrency = widget.preset?.toSymbol ?? _toCurrency;
    _amountController.text = (widget.preset?.sampleValue ?? 1).toString();

    if (widget.demoCurrencies != null) {
      _currencies = Map.fromEntries(
        widget.demoCurrencies!.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      );
      _quote = widget.demoQuote;
      _isLoading = false;
      if (widget.demoQuote != null) {
        _resultController.text = NumberFormatter.formatNumber(
          widget.demoQuote!.convertedAmount,
        );
      }
      return;
    }

    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    try {
      final result = await _currencyService.getCurrenciesWithMetadata();
      if (!mounted) {
        return;
      }

      setState(() {
        _currencies = Map.fromEntries(
          result.currencies.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key)),
        );
        _isLoading = false;
        _isOffline = result.isFromCache || result.isFromDefaults;
        _offlineWarning = result.errorMessage;
        _error = null;
      });

      await _convert();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'Could not load available currencies.';
        _isLoading = false;
        _isOffline = false;
        _offlineWarning = null;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _currencyService.dispose();
    _amountController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _scheduleConvert([String? _]) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _convert);
  }

  Future<void> _convert() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      setState(() {
        _resultController.clear();
        _quote = null;
        _error = null;
      });
      return;
    }

    final requestVersion = ++_requestVersion;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final quote = await _currencyService.convert(
        from: _fromCurrency,
        to: _toCurrency,
        amount: amount,
      );

      if (!mounted || requestVersion != _requestVersion) {
        return;
      }

      final formattedOutput = NumberFormatter.formatNumber(
        quote.convertedAmount,
      );
      setState(() {
        _quote = quote;
        _resultController.text = formattedOutput;
        _isLoading = false;
      });

      await _recentConversionsService.saveConversion(
        RecentConversion(
          category: 'Currency',
          fromUnit: quote.from,
          toUnit: quote.to,
          inputValue: amount,
          outputValue: quote.convertedAmount,
          timestamp: DateTime.now(),
        ),
      );

      await WidgetService.saveLatestConversion(
        title: 'Currency',
        result:
            '${NumberFormatter.formatNumber(amount)} ${quote.from} = $formattedOutput ${quote.to}',
        preset:
            '1 ${quote.from} = ${NumberFormatter.formatNumber(quote.rate)} ${quote.to}',
      );
    } catch (_) {
      if (!mounted || requestVersion != _requestVersion) {
        return;
      }

      setState(() {
        _error =
            'Could not load live rates. Check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  void _applyPreset(QuickPreset preset) {
    setState(() {
      _fromCurrency = preset.fromSymbol;
      _toCurrency = preset.toSymbol;
      _amountController.text = preset.sampleValue.toString();
    });
    _scheduleConvert();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Currency')),
      body: SafeArea(
        child: _isLoading && _currencies.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final contentWidth = width > 1280 ? 1200.0 : width;
                  final compact = width < 480;
                  final wide = contentWidth >= 1000;

                  return ListView(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 14 : 20,
                      8,
                      compact ? 14 : 20,
                      24,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isOffline && _offlineWarning != null)
                                _buildOfflineBanner(),
                              if (_isOffline && _offlineWarning != null)
                                const SizedBox(height: 16),
                              wide
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 8,
                                          child: _buildConverterCard(theme),
                                        ),
                                        const SizedBox(width: 18),
                                        Expanded(
                                          flex: 5,
                                          child: _buildRateDetailsCard(theme),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildConverterCard(theme),
                                        const SizedBox(height: 18),
                                        _buildRateDetailsCard(theme),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.errorContainer,
        border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.onErrorContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onErrorContainer,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _offlineWarning!,
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConverterCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 10),
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live currency conversion',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rates come from the free Frankfurter API backed by institutional ECB data.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () async {
              final url = Uri.parse('https://api.frankfurter.dev');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.link, size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  'api.frankfurter.dev',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _currencyPresets.map((preset) {
              return ActionChip(
                label: Text(preset.label),
                onPressed: () => _applyPreset(preset),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          CurrencyInputRow(
            label: 'From',
            controller: _amountController,
            selectedCode: _fromCurrency,
            items: _currencies,
            onChanged: _scheduleConvert,
            onCurrencyChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _fromCurrency = value;
              });
              _scheduleConvert();
            },
            readOnly: false,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.center,
            child: FilledButton.tonalIcon(
              onPressed: () {
                setState(() {
                  final previous = _fromCurrency;
                  _fromCurrency = _toCurrency;
                  _toCurrency = previous;
                });
                _scheduleConvert();
              },
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('Swap'),
            ),
          ),
          const SizedBox(height: 14),
          CurrencyInputRow(
            label: 'To',
            controller: _resultController,
            selectedCode: _toCurrency,
            items: _currencies,
            onChanged: null,
            onCurrencyChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _toCurrency = value;
              });
              _scheduleConvert();
            },
            readOnly: true,
          ),
          const SizedBox(height: 18),
          // Loading indicator for rate refresh
          if (_isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Fetching latest rate...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              ),
              child: Text(
                _quote == null
                    ? 'Enter an amount to see the latest available rate.'
                    : '${NumberFormatter.formatNumber(_quote!.amount)} ${_quote!.from} (${_currencies[_quote!.from] ?? 'Unknown'}) = ${NumberFormatter.formatNumber(_quote!.convertedAmount)} ${_quote!.to} (${_currencies[_quote!.to] ?? 'Unknown'})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRateDetailsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(
                _error!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              )
            else if (_quote != null) ...[
              Text(
                '1 ${_quote!.from} (${_currencies[_quote!.from] ?? 'Unknown'}) = ${NumberFormatter.formatNumber(_quote!.rate)} ${_quote!.to} (${_currencies[_quote!.to] ?? 'Unknown'})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Latest published day: ${DateFormat('MMM d, yyyy').format(_quote!.effectiveDate)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else
              Text(
                'No quote loaded yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
