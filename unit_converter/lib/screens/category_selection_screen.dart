import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/conversion.dart';
import '../models/favorite_conversion.dart';
import '../models/quick_preset.dart';
import '../services/admob_service.dart';
import '../services/favorite_conversions_service.dart';
import '../services/recent_conversions_service.dart';
import '../services/theme_service.dart';
import '../services/widget_service.dart';
import '../utils/navigation_utils.dart';
import '../utils/platform_utils.dart';
import '../utils/responsive_layout.dart';
import '../widgets/category_card.dart';
import '../widgets/favorite_conversion_card.dart';
import '../widgets/preset_card.dart';
import '../widgets/recent_conversion_card.dart';
import '../widgets/theme_toggle_widget.dart';
import 'conversion_screen.dart';
import 'custom_units_screen.dart';
import 'currency_converter_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  final ThemeController themeController;

  const CategorySelectionScreen({super.key, required this.themeController});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  BannerAd? _bannerAd;
  final FavoriteConversionsService _favoritesService =
      FavoriteConversionsService();
  final RecentConversionsService _recentConversionsService =
      RecentConversionsService();
  final TextEditingController _searchController = TextEditingController();
  List<FavoriteConversion> _favorites = [];
  List<RecentConversion> _recentConversions = [];
  List<ConversionCategory> _categories = ConversionData.categories;
  bool _widgetAvailable = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _refreshHomeData();

    // Show app open ad if available (once per day)
    AdMobService.showAppOpenAdIfAvailable();
  }

  void _loadBannerAd() {
    // Only load banner ads on mobile platforms
    if (PlatformUtils.isMobile && AdMobService.adsEnabled) {
      _bannerAd = AdMobService.createBannerAd();
      _bannerAd?.load();
    }
  }

  Future<void> _refreshHomeData() async {
    final results = await Future.wait<dynamic>([
      ConversionData.getCategoriesWithCustomUnits(),
      _favoritesService.getFavorites(),
      _recentConversionsService.getRecentConversions(),
      WidgetService.isAvailable(),
    ]);

    if (!mounted) {
      return;
    }

    setState(() {
      _categories = results[0] as List<ConversionCategory>;
      _favorites = results[1] as List<FavoriteConversion>;
      _recentConversions = results[2] as List<RecentConversion>;
      _widgetAvailable = results[3] as bool;
    });

    _syncBannerState();
  }

  void _syncBannerState() {
    if (!PlatformUtils.isMobile || !AdMobService.adsEnabled) {
      _bannerAd?.dispose();
      _bannerAd = null;
      return;
    }

    _bannerAd ??= AdMobService.createBannerAd()..load();
  }

  Future<void> _openCategory(
    String categoryName, {
    String? fromSymbol,
    String? toSymbol,
    String? presetLabel,
    double? sampleValue,
  }) async {
    final category = await ConversionData.getCategoryWithCustomUnits(
      categoryName,
    );
    if (!mounted || category == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversionScreen(
          category: category,
          initialFromSymbol: fromSymbol,
          initialToSymbol: toSymbol,
          initialInput: sampleValue?.toString(),
          presetLabel: presetLabel,
        ),
      ),
    );

    _refreshHomeData();
  }

  Future<void> _openCurrency({QuickPreset? preset}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrencyConverterScreen(preset: preset),
      ),
    );

    _refreshHomeData();
  }

  Future<void> _handlePresetTap(QuickPreset preset) async {
    if (preset.isCurrency) {
      await _openCurrency(preset: preset);
      return;
    }

    await _openCategory(
      preset.categoryName!,
      fromSymbol: preset.fromSymbol,
      toSymbol: preset.toSymbol,
      presetLabel: preset.label,
      sampleValue: preset.sampleValue,
    );
  }

  Future<void> _removeFavorite(FavoriteConversion favorite) async {
    await _favoritesService.removeFavorite(favorite);
    await _refreshHomeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  bool get _isSearching => _searchQuery.trim().isNotEmpty;

  List<ConversionCategory> get _filteredCategories {
    if (!_isSearching) {
      return _categories;
    }

    return _categories.where((category) {
      return _matchesSearch(category.name) ||
          category.units.any(
            (unit) => _matchesSearch('${unit.name} ${unit.symbol}'),
          );
    }).toList();
  }

  List<FavoriteConversion> get _filteredFavorites {
    if (!_isSearching) {
      return _favorites;
    }

    return _favorites.where((favorite) {
      return _matchesSearch(
        '${favorite.title} ${favorite.categoryName} ${favorite.fromSymbol} ${favorite.toSymbol}',
      );
    }).toList();
  }

  List<QuickPreset> get _filteredPresets {
    if (!_isSearching) {
      return kQuickPresets;
    }

    return kQuickPresets.where((preset) {
      return _matchesSearch(
        '${preset.label} ${preset.subtitle} ${preset.categoryName ?? 'Currency'} ${preset.fromSymbol} ${preset.toSymbol}',
      );
    }).toList();
  }

  List<RecentConversion> get _filteredRecentConversions {
    if (!_isSearching) {
      return _recentConversions;
    }

    return _recentConversions.where((conversion) {
      return _matchesSearch(
        '${conversion.category} ${conversion.fromUnit} ${conversion.toUnit}',
      );
    }).toList();
  }

  bool _matchesSearch(String value) {
    return value.toLowerCase().contains(_searchQuery.trim().toLowerCase());
  }

  /// Get responsive spacing for sections
  double _getSectionSpacing(BuildContext context) {
    return ResponsiveLayout.getSectionSpacing(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'About',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Custom units',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomUnitsScreen(),
                ),
              );
              _refreshHomeData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Themes and settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    themeController: widget.themeController,
                    widgetAvailable: _widgetAvailable,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshHomeData,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewportWidth = constraints.maxWidth;
                  final contentWidth = viewportWidth > 1280
                      ? 1200.0
                      : viewportWidth;
                  final compact = viewportWidth < 480;
                  final wide = contentWidth >= 980;

                  return ListView(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 12 : 20,
                      8,
                      compact ? 12 : 20,
                      24,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSearchCard(theme),
                              SizedBox(height: _getSectionSpacing(context)),
                              if (wide && _filteredFavorites.isNotEmpty)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildFavoritesSection(theme),
                                    ),
                                    SizedBox(width: _getSectionSpacing(context)),
                                    Expanded(
                                      child: _buildPresetsSection(theme),
                                    ),
                                  ],
                                )
                              else ...[
                                if (_filteredFavorites.isNotEmpty)
                                  _buildFavoritesSection(theme),
                                if (_filteredFavorites.isNotEmpty)
                                  SizedBox(height: _getSectionSpacing(context)),
                                _buildPresetsSection(theme),
                              ],
                              SizedBox(height: _getSectionSpacing(context) * 1.2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Converters',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${_filteredCategories.length + 1} tools',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              LayoutBuilder(
                                builder: (context, innerConstraints) {
                                  final width = innerConstraints.maxWidth;
                                  final crossAxisCount = ResponsiveLayout.getCategoryGridColumns(context);
                                  final childAspectRatio = ResponsiveLayout.getCardAspectRatio(
                                    context,
                                    availableWidth: width,
                                  );
                                  final spacing = ResponsiveLayout.getCardSpacing(context);

                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          childAspectRatio: childAspectRatio,
                                          crossAxisSpacing: spacing,
                                          mainAxisSpacing: spacing,
                                        ),
                                    itemCount: _filteredCategories.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == 0) {
                                        return _buildCurrencyCard();
                                      }

                                      final category =
                                          _filteredCategories[index - 1];
                                      return _buildCategoryCard(category);
                                    },
                                  );
                                },
                              ),
                              if (_isSearching &&
                                  _filteredCategories.isEmpty &&
                                  _filteredFavorites.isEmpty &&
                                  _filteredPresets.isEmpty &&
                                  _filteredRecentConversions.isEmpty) ...[
                                SizedBox(height: _getSectionSpacing(context)),
                                _buildNoResultsCard(theme),
                              ],
                              if (_filteredRecentConversions.isNotEmpty) ...[
                                SizedBox(height: _getSectionSpacing(context) * 1.5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Recent conversions',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await _recentConversionsService
                                            .clearRecentConversions();
                                        _refreshHomeData();
                                      },
                                      child: const Text('Clear all'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _filteredRecentConversions.length,
                                  itemBuilder: (context, index) {
                                    return _buildRecentConversionCard(
                                      _filteredRecentConversions[index],
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (_bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              margin: const EdgeInsets.only(bottom: 8),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard() {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight < 160 || constraints.maxWidth < 180;
        return Card(
          child: InkWell(
            key: const Key('currency_tool_card'),
            borderRadius: BorderRadius.circular(24),
            onTap: _openCurrency,
            child: Padding(
              padding: EdgeInsets.all(compact ? 8 : 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(compact ? 6 : 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.currency_exchange_rounded,
                      size: compact ? 20 : 28,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: compact ? 6 : 10),
                  Text(
                    'Currency',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (compact
                                ? theme.textTheme.titleSmall
                                : theme.textTheme.titleMedium)
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: compact ? 13 : null,
                            ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: compact ? 1 : 4),
                  Text(
                    'Live rates via Frankfurter',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: compact ? 11 : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(ConversionCategory category) {
    return CategoryCard(
      category: category,
      onTap: () => _openCategory(category.name),
    );
  }

  Widget _buildSearchCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('home_search_field'),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search converters, presets, or custom units',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _isSearching
                    ? IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 10),
            Text(
              _isSearching
                  ? 'Results update across presets, favorites, recent conversions, and categories that contain matching units.'
                  : 'Search by category, unit name, symbol, or a custom unit you created.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No matches found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a category name, a unit like meter or psi, or one of your custom unit symbols.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesSection(ThemeData theme) {
    if (_filteredFavorites.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Favorites',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${_filteredFavorites.length} saved',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 122,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filteredFavorites.length > ResponsiveLayout.getMaxHorizontalItems(context)
                ? ResponsiveLayout.getMaxHorizontalItems(context)
                : _filteredFavorites.length,
            separatorBuilder: (context, index) => SizedBox(
              width: ResponsiveLayout.getCardSpacing(context),
            ),
            itemBuilder: (context, index) {
              final favorite = _filteredFavorites[index];
              return FavoriteConversionCard(
                favorite: favorite,
                onTap: () => _openCategory(
                  favorite.categoryName,
                  fromSymbol: favorite.fromSymbol,
                  toSymbol: favorite.toSymbol,
                  presetLabel: favorite.title,
                ),
                onRemove: () => _removeFavorite(favorite),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPresetsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick presets',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filteredPresets.length > ResponsiveLayout.getMaxHorizontalItems(context)
                ? ResponsiveLayout.getMaxHorizontalItems(context)
                : _filteredPresets.length,
            separatorBuilder: (context, index) => SizedBox(
              width: ResponsiveLayout.getCardSpacing(context),
            ),
            itemBuilder: (context, index) {
              final preset = _filteredPresets[index];
              return PresetCard(
                preset: preset,
                onTap: () => _handlePresetTap(preset),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentConversionCard(RecentConversion conversion) {
    return RecentConversionCard(
      conversion: conversion,
      onDelete: () => _deleteConversion(conversion),
    );
  }

  Future<void> _deleteConversion(RecentConversion conversion) async {
    await _recentConversionsService.deleteConversion(conversion);
    _refreshHomeData();
  }
}
