import 'package:flutter/material.dart';

import '../services/currency_service.dart';
import '../services/recent_conversions_service.dart';
import '../services/theme_service.dart';
import '../services/unit_settings_service.dart';
import '../services/widget_service.dart';
import '../widgets/purchase_button.dart';

/// Screen for app settings including theme and widget configuration.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.themeController,
    required this.widgetAvailable,
    this.isWindowsPlatform,
  });

  final ThemeController themeController;
  final bool widgetAvailable;
  final bool? isWindowsPlatform;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Set<String> _hiddenUnits = {};
  Set<String> _hiddenCurrencies = {};
  bool _isLoadingUnits = true;
  bool _historyEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadHiddenUnits();
    _loadHiddenCurrencies();
    _loadHistoryEnabled();
  }

  Future<void> _loadHiddenUnits() async {
    final hiddenUnits = await UnitSettingsService.getHiddenUnits();
    if (!mounted) {
      return;
    }

    setState(() {
      _hiddenUnits = hiddenUnits;
    });
  }

  Future<void> _loadHiddenCurrencies() async {
    final hiddenCurrencies = await UnitSettingsService.getHiddenCurrencies();
    if (!mounted) {
      return;
    }

    setState(() {
      _hiddenCurrencies = hiddenCurrencies;
      _isLoadingUnits = false;
    });
  }

  Future<void> _loadHistoryEnabled() async {
    final enabled = await RecentConversionsService.isHistoryEnabled();
    if (!mounted) {
      return;
    }

    setState(() {
      _historyEnabled = enabled;
    });
  }

  Future<void> _toggleUnitVisibility(String unitName) async {
    await UnitSettingsService.toggleUnitVisibility(unitName);
    await _loadHiddenUnits();
  }

  Future<void> _toggleCurrencyVisibility(String currencyCode) async {
    await UnitSettingsService.toggleCurrencyVisibility(currencyCode);
    await _loadHiddenCurrencies();
  }

  Future<void> _toggleHistory(bool enabled) async {
    if (enabled) {
      final shouldClear = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable history?'),
          content: const Text('Would you like to clear existing history?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep history'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear history'),
            ),
          ],
        ),
      );

      if (shouldClear == null) {
        return;
      }

      if (shouldClear == true) {
        await RecentConversionsService().clearRecentConversions();
      }
    } else {
      await RecentConversionsService().clearRecentConversions();
    }

    await RecentConversionsService.setHistoryEnabled(enabled);
    if (!mounted) {
      return;
    }
    setState(() {
      _historyEnabled = enabled;
    });
  }

  Future<void> _resetUnitDefaults() async {
    await UnitSettingsService.resetToDefaults();
    await _loadHiddenUnits();
  }

  Future<void> _resetCurrencyDefaults() async {
    await UnitSettingsService.resetCurrencyDefaults();
    await _loadHiddenCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance and extras')),
      body: AnimatedBuilder(
        animation: widget.themeController,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final contentWidth = width > 1200 ? 1100.0 : width;
              final compact = width < 480;
              final cardWidth = contentWidth >= 900
                  ? (contentWidth - 18) / 2
                  : contentWidth;

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
                      child: Wrap(
                        spacing: 18,
                        runSpacing: 18,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _buildThemeCard(theme),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildPremiumCard(theme),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildWidgetCard(theme),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildHistoryCard(theme),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildCloudCard(theme),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildUnitsCard(theme),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildCurrenciesCard(theme),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildThemeCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme mode',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            SegmentedButton<AppThemeMode>(
              segments: AppThemeMode.values
                  .map(
                    (mode) => ButtonSegment<AppThemeMode>(
                      value: mode,
                      label: Text(themeModeLabel(mode)),
                    ),
                  )
                  .toList(),
              selected: {widget.themeController.themeModeSetting},
              onSelectionChanged: (selection) {
                widget.themeController.updateThemeMode(selection.first);
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Palette',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppPalette.values.map((palette) {
                return ChoiceChip(
                  label: Text(paletteLabel(palette)),
                  selected: palette == widget.themeController.palette,
                  onSelected: (_) =>
                      widget.themeController.updatePalette(palette),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upgrades',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            PurchaseButton(isWindowsPlatform: widget.isWindowsPlatform),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Home-screen widget',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.widgetAvailable
                  ? 'Pin the Android widget to keep your last conversion and a quick preset on the home screen.'
                  : 'Android widget support depends on launcher support. iOS WidgetKit requires a dedicated extension target that is not part of this Flutter-only change set.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: widget.widgetAvailable
                  ? () async {
                      await WidgetService.requestPin();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Pin widget request sent to the launcher',
                            ),
                          ),
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.widgets_outlined),
              label: const Text('Add Android widget'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conversion history',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable history'),
              subtitle: Text(
                _historyEnabled
                    ? 'Recent conversions are saved'
                    : 'History is disabled - no conversions saved',
              ),
              value: _historyEnabled,
              onChanged: _toggleHistory,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cloud history sync',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'History remains local for now. Real device-to-device sync needs a backend project and credentials, so this build surfaces the constraint instead of shipping a fake cloud toggle.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unit visibility',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Show or hide units from conversion lists. Hidden units are hidden everywhere in the app.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoadingUnits)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  Text(
                    'Hidden by default',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...UnitSettingsService.getLowValueUnits().map((unitName) {
                    final isHidden = _hiddenUnits.contains(unitName);
                    return SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(unitName),
                      subtitle: isHidden ? const Text('Hidden') : const Text('Visible'),
                      value: !isHidden,
                      onChanged: (_) => _toggleUnitVisibility(unitName),
                    );
                  }).toList(),
                  const Divider(height: 24),
                  Text(
                    'All units',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<Set<String>>(
                    future: UnitSettingsService.getAllToggleableUnits(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      final allUnits = snapshot.data!.toList()..sort();
                      return Column(
                        children: allUnits.map((unitName) {
                            final isHidden = _hiddenUnits.contains(unitName);
                            return SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: Text(unitName),
                              subtitle: isHidden ? const Text('Hidden') : const Text('Visible'),
                              value: !isHidden,
                              onChanged: (_) => _toggleUnitVisibility(unitName),
                            );
                          }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _resetUnitDefaults,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset to defaults'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrenciesCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Currency visibility',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Show or hide currencies from the currency converter dropdown. Hidden currencies will not appear in any currency selection lists.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoadingUnits)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  FutureBuilder<Map<String, String>>(
                    future: CurrencyService().getCurrencies(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      final currencies = snapshot.data!.entries.toList()
                        ..sort((a, b) => a.key.compareTo(b.key));
                      return Column(
                        children: currencies.map((entry) {
                          final code = entry.key;
                          final name = entry.value;
                          final isHidden = _hiddenCurrencies.contains(code);
                          return SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text('$code - $name'),
                            subtitle: isHidden ? const Text('Hidden') : const Text('Visible'),
                            value: !isHidden,
                            onChanged: (_) => _toggleCurrencyVisibility(code),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _resetCurrencyDefaults,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset to defaults'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
