# Unit Converter Pro - Release Roadmap

> **Versioning Policy:** Patch (1.0.x) for bug fixes and ASO updates. Minor (1.x.0) only when adding significant features.

**Current version:** 1.0.5+14
**Next release:** 1.0.6 (patch) - ASO & bug fixes

---

## Version 1.0.6 - ASO & Store Audit Fixes

### Status: Ready for Release

### Completed Changes

#### Store Listing Updates
- [x] **Title:** "Unit Converter Pro: Custom Units" (was "Unit Converter")
- [x] **Short Description:** Leads with Custom Units + 150+ currencies differentiator
- [x] **Full Description:** Complete rewrite highlighting unique features first
- [x] **Store Assets Guide:** Created at `docs/store-assets-guide.md`

#### Code Fixes
- [x] **CurrencyService memory leak:** Added `dispose()` call in `CurrencyConverterScreen`
- [x] **Custom Units edit mode:** Added `existingUnit` parameter to `AddCustomUnitScreen`

#### UI/Visual Design Fixes (Completed 2026-04-11)
- [x] **ThemeController singleton:** Fixed `ThemeController.instance` pattern for proper DI
- [x] **Offline banner colors:** Replaced hardcoded `Colors.orange.shade50/200` with theme-aware `colorScheme.errorContainer`
- [x] **Purchase button colors:** Replaced hardcoded `Colors.green/red` with theme-aware `colorScheme.secondaryContainer/errorContainer`
- [x] **Content width standardization:** Unified to 1200px across `currency_converter_screen.dart` and `conversion_screen.dart`
- [x] **Card widget standardization:** Changed `Card.outlined` to `Card` with theme's `CardThemeData` (elevation: 0)
- [x] **Button style fix:** Changed `ElevatedButton` to `FilledButton` with `colorScheme.primary`
- [x] **Responsive breakpoint alignment:** Added `ResponsiveLayout.wideBreakpoint` constant (1000px)
- [x] **Deprecated primaryColor removal:** Replaced with `colorScheme.primary`
- [x] **Inner border radius:** Fixed 16px → 12px for consistency
- [x] **Theme-aware shadows:** Made shadow color use `colorScheme.shadow.withValues(alpha: 0.08)`
- [x] **Responsive card widths:** Made `preset_card`, `favorite_conversion_card`, `recent_conversion_card` responsive
- [x] **Dead code removal:** Removed unused `SimpleThemeToggle` class
- [x] **Duplicate import removal:** Removed duplicate `dart:convert` import
- [x] **Icon proportion balance:** Fixed `category_card.dart` container padding

#### Test Coverage Additions
- [x] Temperature conversions: Kelvin variants, absolute zero, same-unit
- [x] FormulaService: All 6 temperature formulas, null handling
- [x] ComparisonService: Data, Pressure, Cooking coverage, null cases
- [x] CurrencyService: API response handling, error cases, cache scenarios

### Pre-Release Checklist

- [ ] Update app icon to be more professional/distinctive
- [ ] Reorder screenshots to put Custom Units first
- [ ] Add text overlays to screenshots highlighting key features
- [ ] Create promo video (30s, "The Only Unit Converter With YOUR Units")
- [ ] Update feature graphic with new branding
- [ ] Test on physical device before release
- [ ] **Regenerate screenshot goldens:** Run `golden_screenshot` tests to update 32 screenshot files in `test/integration/failures/` that reflect the visual design fixes

### Release Steps

```bash
# 0. Regenerate screenshots after UI fixes
# Run golden_screenshot tests to update master images

# 1. Update screenshots in:
#    android/fastlane/metadata/android/en-US/images/

# 2. Build release
flutter build appbundle --release

# 3. Deploy via Fastlane
cd android && fastlane release
```

---

## Version 1.0.7 - Rating Recovery

### Target: 2-4 weeks after 1.0.6

### Goal: Recover from 1-star rating to 4+ stars

### Actions

1. **In-App Review Prompt**
   - Implement Google In-App Review API
   - Trigger after 3 successful conversions (non-intrusive)
   - Only prompt on happy path (no errors)

2. **Feedback Mechanism**
   - Add "Rate App" in Settings with link to Play Store
   - Add feedback button that collects issue reports before rating

3. **Address Top Complaints**
   - Audit 1-star reviews (can't read them without Play Console access)
   - Likely issues: ad frequency, crash on specific device, wrong conversion

4. **Push Update with Fixes**
   - Any crash fixes
   - Any conversion accuracy fixes
   - Improved ad experience

---

## Version 1.0.8 - Ad Experience Improvements

### Target: 1-2 months

### Goal: Reduce ad complaints while maintaining revenue

### Changes

1. **Reduce Interstitial Frequency**
   - Current: Every 5 conversions
   - Proposed: Every 10 conversions
   - Test with A/B experiment if possible

2. **Better Ad Placement**
   - Banner only on home screen (not during conversion)
   - Native-looking ad units that feel less intrusive

3. **Rewarded Ads Option** *(minor feature)*
   - Users watch short ad → unlock premium feature for session
   - Opt-in, not forced

4. **Premium Positioning**
   - Make ad-free more prominent
   - Show price in banner area: "Remove ads - $0.99"

---

## Version 1.1.0 - Feature Parity (Minor Release)

### Target: 2-3 months

### Reason for Minor: Adding new unit categories

### Missing Features from Top Apps

1. **Unit Categories Competitors Have**
   - [ ] Fuel economy (mpg, L/100km)
   - [ ] Torque (Nm, ft-lb)
   - [ ] Force (N, lbf)
   - [ ] Energy (J, cal, BTU)

2. **UX Features**
   - [ ] Swap button on main screen (currently only in conversion screen)
   - [ ] Conversion history charts/graphs
   - [ ] Share conversion results as image

3. **Widget Improvements**
   - [ ] Configurable widget (choose preset)
   - [ ] Multiple widget sizes
   - [ ] iOS WidgetKit (if pursuing iOS)

---

## Version 1.2.0 - Differentiation Features (Minor Release)

### Target: 3-4 months

### Reason for Minor: Custom Units v2 is significant

### Unique Features Only This App Has

1. **Custom Units v2**
   - [ ] Import/export custom units as JSON
   - [ ] Share custom units via deep link
   - [ ] Pre-built custom unit packs (engineering, cooking, etc.)

2. **Cloud Sync (Backend Required)**
   - [ ] Sync custom units across devices
   - [ ] Sync favorites/history (optional)
   - Requires: Backend project, authentication

3. **Collaboration**
   - [ ] Share conversion presets with friends
   - [ ] Community unit library

---

## Future: Separate Paid Listing (Unit Converter Pro - No Ads)

### Not a version bump - separate app listing

Consider a **separate paid app** ("Unit Converter Pro - No Ads") to:

1. Compete directly with MissionTools (4.9★, ad-free)
2. Accumulate 5-star reviews separately
3. Not contaminate main app's rating

### Strategy

```
Free App (This one)     → Ad-supported, broad reach
Paid App ($0.99-1.99)   → No ads, pro features, niche market
```

---

## Key Metrics to Track

| Metric | Current | Target | Timeline |
|--------|---------|--------|----------|
| Rating | 1.0★ | 4.0★ | 3 months |
| Reviews | ~5 | 100+ | 6 months |
| Downloads | Low | 10K+ | 6 months |
| DAU | ? | 1K+ | 6 months |
| Ad CTR | ? | 2%+ | Ongoing |

---

## Resources Needed

- **ASO:** Screenshot redesign, promo video creation
- **Backend:** Cloud sync requires server + API
- **Testing:** Physical devices for crash reporting
- **Marketing:** Could benefit from Product Hunt launch, Reddit posts in relevant communities

---

## Notes

- Monitor crash reporting in Play Console
- Check conversion accuracy against authoritative sources
- Consider reducing app size (current?)
- Track keyword rankings for "unit converter" search
