import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/conversion.dart';
import '../services/admob_service.dart';
import '../services/comparison_service.dart';
import '../services/favorite_conversions_service.dart';
import '../services/formula_service.dart';
import '../services/recent_conversions_service.dart';
import '../services/widget_service.dart';
import '../utils/button_styles.dart';
import '../utils/platform_utils.dart';
import '../utils/number_formatter.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/unit_input_card.dart';
import '../widgets/theme_toggle_widget.dart';

class ConversionScreen extends StatefulWidget {
  const ConversionScreen({
    super.key,
    required this.category,
    this.initialFromSymbol,
    this.initialToSymbol,
    this.initialInput,
    this.presetLabel,
  });

  final ConversionCategory category;
  final String? initialFromSymbol;
  final String? initialToSymbol;
  final String? initialInput;
  final String? presetLabel;

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final FavoriteConversionsService _favoritesService =
      FavoriteConversionsService();
  final RecentConversionsService _recentConversionsService =
      RecentConversionsService();

  Unit? _fromUnit;
  Unit? _toUnit;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fromUnit =
        _findUnit(widget.initialFromSymbol) ?? widget.category.units.first;
    _toUnit =
        _findUnit(widget.initialToSymbol) ??
        (widget.category.units.length > 1
            ? widget.category.units[1]
            : widget.category.units.first);

    if (widget.initialInput != null) {
      _inputController.text = widget.initialInput!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _convert());
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _refreshFavoriteState(),
    );
  }

  Unit? _findUnit(String? symbol) {
    if (symbol == null) {
      return null;
    }

    try {
      return widget.category.units.firstWhere((unit) => unit.symbol == symbol);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  Future<void> _refreshFavoriteState() async {
    if (_fromUnit == null || _toUnit == null) {
      return;
    }

    final isFavorite = await _favoritesService.isFavorite(
      categoryName: widget.category.name,
      fromSymbol: _fromUnit!.symbol,
      toSymbol: _toUnit!.symbol,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = isFavorite;
    });
  }

  void _convert([String? _]) {
    final inputValue = double.tryParse(_inputController.text);
    if (inputValue == null || _fromUnit == null || _toUnit == null) {
      setState(() {
        _outputController.clear();
      });
      return;
    }

    final outputValue = ConversionData.convert(
      inputValue,
      _fromUnit!,
      _toUnit!,
      widget.category.name,
    );

    final formattedOutput = NumberFormatter.formatPrecise(outputValue);
    setState(() {
      _outputController.text = formattedOutput;
    });

    final conversion = RecentConversion(
      category: widget.category.name,
      fromUnit: _fromUnit!.symbol,
      toUnit: _toUnit!.symbol,
      inputValue: inputValue,
      outputValue: outputValue,
      timestamp: DateTime.now(),
    );
    _recentConversionsService.saveConversion(conversion);

    // Save to widget service
    WidgetService.saveLatestConversion(
      title: widget.category.name,
      result:
          '${NumberFormatter.formatPrecise(inputValue)} ${_fromUnit!.symbol} = $formattedOutput ${_toUnit!.symbol}',
      preset: _buildWidgetPresetText(),
    );

    // Only track conversions for ads on mobile platforms
    if (PlatformUtils.isMobile) {
      AdMobService.trackConversion();
    }
  }

  Future<void> _toggleFavorite() async {
    if (_fromUnit == null || _toUnit == null) {
      return;
    }

    final saved = await _favoritesService.toggleFavorite(
      categoryName: widget.category.name,
      fromSymbol: _fromUnit!.symbol,
      toSymbol: _toUnit!.symbol,
      title:
          '${widget.category.name}: ${_fromUnit!.symbol} to ${_toUnit!.symbol}',
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = saved;
    });
    SnackbarUtils.show(
      context,
      saved ? 'Saved to favorites' : 'Removed from favorites',
    );
  }

  String _buildWidgetPresetText() {
    if (_fromUnit == null || _toUnit == null) {
      return '1 in = 2.54 cm';
    }

    final converted = ConversionData.convert(
      1,
      _fromUnit!,
      _toUnit!,
      widget.category.name,
    );
    return '1 ${_fromUnit!.symbol} = ${NumberFormatter.formatPrecise(converted)} ${_toUnit!.symbol}';
  }

  void _swapUnits() {
    setState(() {
      final previousFrom = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = previousFrom;
    });
    _convert();
    _refreshFavoriteState();
  }

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: _outputController.text));
    SnackbarUtils.show(context, 'Result copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.presetLabel ?? widget.category.name),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            tooltip: _isFavorite ? 'Remove favorite' : 'Save favorite',
            icon: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            ),
          ),
          const ThemeToggleWidget(),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
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
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 8,
                                child: _buildConversionCard(theme),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    _buildFormulaCard(theme),
                                    const SizedBox(height: 18),
                                    _buildComparisonCard(theme),
                                    const SizedBox(height: 18),
                                    _buildAvailableUnitsCard(theme),
                                    const SizedBox(height: 18),
                                    _buildCopyButton(),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _buildConversionCard(theme),
                              const SizedBox(height: 18),
                              _buildFormulaCard(theme),
                              const SizedBox(height: 18),
                              _buildComparisonCard(theme),
                              const SizedBox(height: 18),
                              _buildAvailableUnitsCard(theme),
                              const SizedBox(height: 18),
                              _buildCopyButton(),
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

  Widget _buildConversionCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            blurRadius: 24,
            offset: Offset(0, 10),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live conversion',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Switch between metric and imperial units instantly. Negative values are supported for temperature and signed measurements.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          UnitInputCard(
            label: 'From',
            valueController: _inputController,
            selectedUnit: _fromUnit,
            units: widget.category.units,
            onUnitChanged: (value) {
              setState(() {
                _fromUnit = value;
              });
              _convert();
              _refreshFavoriteState();
            },
            onChanged: _convert,
            isReadOnly: false,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.center,
            child: FilledButton.tonalIcon(
              onPressed: _swapUnits,
              icon: const Icon(Icons.swap_vert_rounded),
              label: const Text('Swap'),
            ),
          ),
          const SizedBox(height: 14),
          UnitInputCard(
            label: 'To',
            valueController: _outputController,
            selectedUnit: _toUnit,
            units: widget.category.units,
            onUnitChanged: (value) {
              setState(() {
                _toUnit = value;
              });
              _convert();
              _refreshFavoriteState();
            },
            onChanged: null,
            isReadOnly: true,
          ),
          const SizedBox(height: 18),
          _buildSummaryCard(theme),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
      ),
      child: Text(
        _buildSummaryText(),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAvailableUnitsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available units',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.category.units.map((unit) {
                return Chip(
                  label: Text('${unit.name} (${unit.symbol})'),
                  side: BorderSide.none,
                  backgroundColor: theme.colorScheme.secondaryContainer
                      .withValues(alpha: 0.55),
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaCard(ThemeData theme) {
    final inputValue = double.tryParse(_inputController.text);
    final calculation = FormulaService.buildCalculation(
      categoryName: widget.category.name,
      fromUnit: _fromUnit,
      toUnit: _toUnit,
      inputValue: inputValue,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Formula',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              FormulaService.buildFormula(
                categoryName: widget.category.name,
                fromUnit: _fromUnit,
                toUnit: _toUnit,
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (calculation != null) ...[
              const SizedBox(height: 10),
              Text(
                calculation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(ThemeData theme) {
    final comparison = ComparisonService.describe(
      categoryName: widget.category.name,
      fromUnit: _fromUnit,
      toUnit: _toUnit,
    );

    if (comparison == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-world comparison',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              comparison,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyButton() {
    return FilledButton.icon(
      onPressed: _outputController.text.isEmpty ? null : _copyResult,
      icon: const Icon(Icons.copy_rounded),
      label: const Text('Copy result'),
      style: ButtonStyles.fullWidthButton,
    );
  }

  String _buildSummaryText() {
    if (_inputController.text.isEmpty ||
        _outputController.text.isEmpty ||
        _fromUnit == null ||
        _toUnit == null) {
      return 'Enter a value to see the converted result.';
    }

    return '${_inputController.text} ${_fromUnit!.symbol} = ${_outputController.text} ${_toUnit!.symbol}';
  }
}
