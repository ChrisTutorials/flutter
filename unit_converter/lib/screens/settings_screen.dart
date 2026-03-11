import 'package:flutter/material.dart';

import '../services/admob_service.dart';
import '../services/premium_service.dart';
import '../services/theme_service.dart';
import '../services/unit_settings_service.dart';
import '../services/widget_service.dart';

/// Screen for app settings including theme and widget configuration.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.themeController,
    required this.widgetAvailable,
  });

  final ThemeController themeController;
  final bool widgetAvailable;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isPremium = false;
  Set<String> _hiddenUnits = {};
  bool _isLoadingUnits = true;

  @override
  void initState() {
    super.initState();
    _loadPremiumState();
    _loadHiddenUnits();
  }

  Future<void> _loadPremiumState() async {
    final isPremium = await PremiumService.isPremium();
    if (!mounted) {
      return;
    }

    setState(() {
      _isPremium = isPremium;
    });
  }

  Future<void> _loadHiddenUnits() async {
    final hiddenUnits = await UnitSettingsService.getHiddenUnits();
    if (!mounted) {
      return;
    }

    setState(() {
      _hiddenUnits = hiddenUnits;
      _isLoadingUnits = false;
    });
  }

  Future<void> _togglePremium(bool value) async {
    await PremiumService.setPremium(value);
    await AdMobService.setPremiumStatus(value);
    if (!mounted) {
      return;
    }

    setState(() {
      _isPremium = value;
    });
  }

  Future<void> _toggleUnitVisibility(String unitName) async {
    await UnitSettingsService.toggleUnitVisibility(unitName);
    await _loadHiddenUnits();
  }

  Future<void> _resetUnitDefaults() async {
    await UnitSettingsService.resetToDefaults();
    await _loadHiddenUnits();
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
                            child: _buildCloudCard(theme),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildUnitsCard(theme),
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
              'Premium tier',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ad-free mode'),
              subtitle: const Text(
                'This local switch is the app-side gate for a future billing flow. When enabled, banner, interstitial, and app-open ads stay off.',
              ),
              value: _isPremium,
              onChanged: _togglePremium,
            ),
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
              'Hide low-value units that you rarely use to simplify conversion lists.',
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
}
