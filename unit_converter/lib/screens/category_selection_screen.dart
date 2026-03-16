import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/conversion.dart';
import '../models/favorite_conversion.dart';
import '../models/quick_preset.dart';
import '../services/admob_service.dart';
import '../services/currency_service.dart';
import '../services/favorite_conversions_service.dart';
import '../services/recent_conversions_service.dart';
import '../services/theme_service.dart';
import '../services/windows_store_access_policy.dart';
import '../services/widget_service.dart';
import '../utils/home_search.dart';
import '../utils/navigation_utils.dart';
import '../utils/number_formatter.dart';
import '../utils/platform_utils.dart';
import '../utils/responsive_layout.dart';
import '../utils/screenshot_scenario.dart';
import '../widgets/category_card.dart';
import '../widgets/bottom_banner_slot.dart';
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
  final ScreenshotScrollTarget initialScrollTarget;
  final WindowsStoreAccessPolicy? windowsStoreAccessPolicy;

  const CategorySelectionScreen({
    super.key,
    required this.themeController,
    this.initialScrollTarget = ScreenshotScrollTarget.none,
    this.windowsStoreAccessPolicy,
  });

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  BannerAd? _bannerAd;
  late final WindowsStoreAccessPolicy _windowsStoreAccessPolicy;
  final FavoriteConversionsService _favoritesService =
      FavoriteConversionsService();
  final RecentConversionsService _recentConversionsService =
      RecentConversionsService();
  final CurrencyService _currencyService = CurrencyService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _historySectionGlobalKey = GlobalKey();
  List<FavoriteConversion> _favorites = [];
  List<RecentConversion> _recentConversions = [];
  List<ConversionCategory> _categories = ConversionData.categories;
  bool _widgetAvailable = false;
  String _searchQuery = '';
  bool _didAttemptInitialScroll = false;
  Map<String, String> _currencyNames = {};
  bool _isPremiumUnlocked = false;

  @override
  void initState() {
    super.initState();
    _windowsStoreAccessPolicy =
        widget.windowsStoreAccessPolicy ?? WindowsStoreAccessPolicy();
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
      _currencyService.getCurrencies(),
    ]);

    if (!mounted) {
      return;
    }

    setState(() {
      _categories = results[0] as List<ConversionCategory>;
      _favorites = results[1] as List<FavoriteConversion>;
      _recentConversions = results[2] as List<RecentConversion>;
      _widgetAvailable = results[3] as bool;
      _currencyNames = results[4] as Map<String, String>;
    });

    final isPremiumUnlocked =
        await _windowsStoreAccessPolicy.isPremiumUnlocked();
    if (!mounted) {
      return;
    }

    setState(() {
      _isPremiumUnlocked = isPremiumUnlocked;
    });

    _scheduleInitialScrollIfNeeded();

    _syncBannerState();
  }

  void _scheduleInitialScrollIfNeeded() {
    if (_didAttemptInitialScroll ||
        widget.initialScrollTarget != ScreenshotScrollTarget.history ||
        _recentConversions.isEmpty) {
      return;
    }

    _didAttemptInitialScroll = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = _historySectionGlobalKey.currentContext;
      if (!mounted || targetContext == null) {
        return;
      }

      final viewportHeight = MediaQuery.sizeOf(context).height;
      final alignment = viewportHeight >= 2400
          ? 0.68
          : viewportHeight >= 1800
          ? 0.58
          : 0.46;

      Scrollable.ensureVisible(
        targetContext,
        alignment: alignment,
        duration: const Duration(milliseconds: 1),
      );
    });
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
    final canAccess = await _windowsStoreAccessPolicy.canAccessCategory(
      categoryName,
    );
    if (!canAccess) {
      _showPremiumDialog(
        title: '$categoryName is part of Premium',
        message:
            'Unlock advanced converters on Windows, including $categoryName, Currency, and Custom Units.',
      );
      return;
    }

    final category = await ConversionData.getCategoryWithCustomUnits(
      categoryName,
    );
    if (!mounted || category == null) {
      return;
    }

    await NavigationUtils.pushAndAwait<dynamic>(
      context,
      ConversionScreen(
        category: category,
        initialFromSymbol: fromSymbol,
        initialToSymbol: toSymbol,
        initialInput: sampleValue?.toString(),
        presetLabel: presetLabel,
      ),
    );

    _refreshHomeData();
  }

  Future<void> _openCurrency({QuickPreset? preset}) async {
    final canAccess = await _windowsStoreAccessPolicy.canAccessCurrency();
    if (!canAccess) {
      _showPremiumDialog(
        title: 'Currency is part of Premium',
        message:
            'Unlock live currency conversion and the rest of the advanced Windows toolset.',
      );
      return;
    }

    await NavigationUtils.pushAndAwait<dynamic>(
      context,
      CurrencyConverterScreen(preset: preset),
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

  Future<void> _openCustomUnits() async {
    final canAccess = await _windowsStoreAccessPolicy.canAccessCustomUnits();
    if (!canAccess) {
      _showPremiumDialog(
        title: 'Custom Units is part of Premium',
        message:
            'Unlock Custom Units on Windows to create and save your own conversions.',
      );
      return;
    }

    await NavigationUtils.pushAndAwait<dynamic>(
      context,
      const CustomUnitsScreen(),
    );
    _refreshHomeData();
  }

  void _showPremiumDialog({
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Maybe later'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await NavigationUtils.pushAndAwait<dynamic>(
                  context,
                  SettingsScreen(
                    themeController: widget.themeController,
                    widgetAvailable: _widgetAvailable,
                    isWindowsPlatform:
                        _windowsStoreAccessPolicy.isWindowsStorePolicyActive,
                  ),
                );
                _refreshHomeData();
              },
              child: Text(
                _isPremiumUnlocked
                    ? 'Premium Active'
                    : (_windowsStoreAccessPolicy.isWindowsStorePolicyActive
                          ? 'Unlock Premium'
                          : 'Upgrade'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeFavorite(FavoriteConversion favorite) async {
    await _favoritesService.removeFavorite(favorite);
    await _refreshHomeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  bool get _isSearching => _searchQuery.trim().isNotEmpty;

  HomeSearchInterpretation get _searchInterpretation =>
      HomeSearch.analyze(_searchQuery, _categories);

  List<ConversionCategory> get _filteredCategories {
    final search = _searchInterpretation;
    if (!search.isSearching) {
      return _categories;
    }

    if (search.instantConversion != null) {
      return _categories
          .where(
            (category) =>
                category.name == search.instantConversion!.category.name,
          )
          .toList();
    }

    return _categories.where((category) {
      return HomeSearch.matchesTokens(
        HomeSearch.buildCategorySearchText(category),
        search.filterTokens,
      );
    }).toList();
  }

  List<FavoriteConversion> get _filteredFavorites {
    final search = _searchInterpretation;
    if (!search.isSearching) {
      return _favorites;
    }

    return _favorites.where((favorite) {
      return HomeSearch.matchesTokens(
        '${favorite.title} ${favorite.categoryName} ${favorite.fromSymbol} ${favorite.toSymbol}',
        search.filterTokens,
      );
    }).toList();
  }

  List<QuickPreset> get _filteredPresets {
    final search = _searchInterpretation;
    if (!search.isSearching) {
      return kQuickPresets;
    }

    return kQuickPresets.where((preset) {
      return HomeSearch.matchesTokens(
        '${preset.label} ${preset.subtitle} ${preset.categoryName ?? 'Currency'} ${preset.fromSymbol} ${preset.toSymbol}',
        search.filterTokens,
      );
    }).toList();
  }

  List<RecentConversion> get _filteredRecentConversions {
    final search = _searchInterpretation;
    if (!search.isSearching) {
      return _recentConversions;
    }

    return _recentConversions.where((conversion) {
      return HomeSearch.matchesTokens(
        '${conversion.category} ${conversion.fromUnit} ${conversion.toUnit} ${conversion.inputValue} ${conversion.outputValue}',
        search.filterTokens,
      );
    }).toList();
  }

  Future<void> _openInstantConversion(InstantConversionMatch match) async {
    await _openCategory(
      match.category.name,
      fromSymbol: match.fromUnit.symbol,
      toSymbol: match.toUnit.symbol,
      sampleValue: match.inputValue,
      presetLabel:
          '${NumberFormatter.formatPrecise(match.inputValue)} ${match.fromUnit.symbol} to ${match.toUnit.symbol}',
    );
  }

  Future<void> _handleSearchSubmitted() async {
    final instantConversion = _searchInterpretation.instantConversion;
    if (instantConversion != null) {
      await _openInstantConversion(instantConversion);
      return;
    }

    if (_filteredCategories.length == 1 &&
        _filteredFavorites.isEmpty &&
        _filteredPresets.isEmpty &&
        _filteredRecentConversions.isEmpty) {
      await _openCategory(_filteredCategories.single.name);
    }
  }

  /// Get responsive spacing for sections
  double _getSectionSpacing(BuildContext context) {
    return ResponsiveLayout.getSectionSpacing(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchInterpretation = _searchInterpretation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All-in-One Unit Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'About',
             onPressed: () async {
               await NavigationUtils.pushAndAwait(
                 context,
                 const AboutScreen(),
               );
             },
          ),
          IconButton(
            icon: const Icon(Icons.extension_outlined),
            tooltip: 'Custom units',
            onPressed: () async {
              await _openCustomUnits();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Themes and settings',
             onPressed: () async {
               await NavigationUtils.pushAndAwait(
                 context,
                 SettingsScreen(
                   themeController: widget.themeController,
                   widgetAvailable: _widgetAvailable,
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
                    controller: _scrollController,
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
                              _buildSearchCard(theme, searchInterpretation),
                              SizedBox(height: _getSectionSpacing(context)),
                              if (wide && _filteredFavorites.isNotEmpty && _filteredPresets.isNotEmpty)
                                Column(
                                  children: [
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
                                    ),
                                    SizedBox(height: _getSectionSpacing(context) * 1.2),
                                  ],
                                )
                              else ...[
                                if (_filteredFavorites.isNotEmpty)
                                  _buildFavoritesSection(theme),
                                if (_filteredFavorites.isNotEmpty &&
                                    _filteredPresets.isNotEmpty)
                                  SizedBox(height: _getSectionSpacing(context)),
                                if (_filteredPresets.isNotEmpty)
                                  _buildPresetsSection(theme),
                                if (_filteredFavorites.isNotEmpty ||
                                    _filteredPresets.isNotEmpty)
                                  SizedBox(height: _getSectionSpacing(context) * 1.2),
                              ],
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
                                KeyedSubtree(
                                  key: const Key('home_history_section'),
                                  child: Container(
                                    key: _historySectionGlobalKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'History',
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
                                  ),
                                ),
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
          BottomBannerSlot(
            bannerSize: _bannerAd?.size,
            bannerChild: _bannerAd != null ? AdWidget(ad: _bannerAd!) : null,
            showDebugPlaceholder: kDebugMode && PlatformUtils.isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard() {
    final theme = Theme.of(context);
    final isLocked =
        _windowsStoreAccessPolicy.isCurrencyPremium() && !_isPremiumUnlocked;

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
                    isLocked
                        ? 'Live rates with Premium'
                        : 'Live rates via Frankfurter',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: compact ? 11 : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isLocked) ...[
                    SizedBox(height: compact ? 4 : 8),
                    Icon(
                      Icons.workspace_premium,
                      size: compact ? 16 : 18,
                      color: theme.colorScheme.secondary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(ConversionCategory category) {
    final isLocked =
        _windowsStoreAccessPolicy.isPremiumCategory(category.name) &&
        !_isPremiumUnlocked;

    return CategoryCard(
      category: category,
      onTap: () => _openCategory(category.name),
      isLocked: isLocked,
      lockedSubtitle: '${category.units.length} units',
    );
  }

  Widget _buildSearchCard(
    ThemeData theme,
    HomeSearchInterpretation searchInterpretation,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('home_search_field'),
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search converters or type 60 g to lb',
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
              onSubmitted: (_) => _handleSearchSubmitted(),
            ),
            const SizedBox(height: 10),
            Text(
              searchInterpretation.instantConversion != null
                  ? 'Instant conversion is ready. You can keep browsing matching tools or open the converter directly.'
                  : _isSearching
                  ? 'Search across converters, presets, favorites, and history, or type a conversion like 32 F to C.'
                  : 'Search by category, unit name, symbol, or type a full conversion like 60 g to lb.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            if (searchInterpretation.instantConversion != null) ...[
              const SizedBox(height: 14),
              _buildInstantConversionCard(
                theme,
                searchInterpretation.instantConversion!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstantConversionCard(
    ThemeData theme,
    InstantConversionMatch match,
  ) {
    final formattedInput = NumberFormatter.formatPrecise(match.inputValue);
    final formattedOutput = NumberFormatter.formatPrecise(match.outputValue);

    return Container(
      key: const Key('instant_conversion_card'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instant conversion',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$formattedInput ${match.fromUnit.symbol} = $formattedOutput ${match.toUnit.symbol}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            match.category.name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('open_instant_conversion_button'),
            onPressed: () => _openInstantConversion(match),
            child: const Text('Open converter'),
          ),
        ],
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
              'Try a category name, a unit like meter or psi, or a direct conversion like 5 km to mi.',
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
                currencyNames: _currencyNames,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPresetsSection(ThemeData theme) {
    if (_filteredPresets.isEmpty) {
      return const SizedBox.shrink();
    }

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
                currencyNames: _currencyNames,
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
      currencyNames: _currencyNames,
    );
  }

  Future<void> _deleteConversion(RecentConversion conversion) async {
    await _recentConversionsService.deleteConversion(conversion);
    _refreshHomeData();
  }
}
