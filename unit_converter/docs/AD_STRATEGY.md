# Ad Strategy for Unit Converter App

## Documentation Navigation
- [Project Overview](README.md)
- [Security Configuration](SECURITY_CONFIG.md)
- [Deployment Roadmap](DEPLOYMENT_ROADMAP.md)

## Overview

This document outlines the comprehensive ad monetization strategy for the Unit Converter app, designed to maximize revenue while maintaining excellent user experience and app store ratings.

## Core Philosophy

**Balance revenue with user experience** - Aggressive ad placement generates short-term revenue but destroys long-term growth through poor reviews and low retention.

---

## 1. Banner Ads (Core Monetization)

### Placement
- **Bottom anchored banner** on all main screens
- Never cover conversion inputs or results
- Show on:
  - Main converter screen
  - Category selection screen
  - Settings screen

### Configuration
- **Refresh rate**: Every 60-90 seconds
- **Ad size**: Adaptive banner (fits screen width)
- **Position**: Fixed at bottom, above safe area

### Why This Works
- Non-interruptive - users can continue using the app
- Ideal for utility apps where users need quick interactions
- High user retention
- Low negative impact on reviews

### Expected Revenue
- **eCPM**: \-4 (typical for utility apps)
- **ARPDAU**: \.002 - \.01
- **Impact**: Low revenue per user but high retention

---

## 2. Interstitial Ads (Controlled Use)

Interstitials generate 5-10x more revenue than banners but are dangerous if misused.

### Critical Rules

#### 1️⃣ Only Show After Task Completion
**Never interrupt the conversion flow**

✅ **Correct Flow:**
`
User converts units
→ Views result
→ Closes result / Navigates to another category
→ THEN show interstitial
`

❌ **Wrong Flow:**
`
Enter number
Choose units
CLICK CONVERT
→ INTERSTITIAL APPEARS
→ Result shown
`

This causes instant 1★ reviews.

#### 2️⃣ Frequency Cap
**Recommended baseline:**
- Every 15-25 conversions (NOT every 5)
- OR minimum 3-5 minutes between interstitials
- Maximum 2-3 interstitials per session

**Current implementation (before fix):** Every 5 conversions
**Status:** ❌ Too aggressive for utility app

#### 3️⃣ First-Time User Protection
Do NOT show interstitials during onboarding.

**Required:**
- No interstitials until:
  - 10 conversions completed OR
  - 2nd app session

This dramatically reduces uninstall spikes from new users.

#### 4️⃣ Session Limit
**Maximum per session:** 2-3 interstitials
Even if conversion count is high, respect session limits.

### Implementation Logic
`dart
bool shouldShowInterstitial() {
  return conversionCount >= 10 &&
         conversionsSinceLastAd >= 20 &&
         timeSinceLastAd >= 180 seconds &&
         sessionInterstitials < 3;
}
`

### Expected Revenue
- **eCPM**: \-18 (much higher than banners)
- **ARPDAU contribution**: \.008 - \.04
- **Impact**: Significant revenue boost when used correctly

---

## 3. App Open Ads (Optional - High Revenue)

### Configuration
- **Frequency**: Once per day maximum
- **Timing**: Show when app launches
- **User flow:**
  `
  User opens app
  ↓
  App open ad appears (skippable after 5 seconds)
  ↓
  User continues to main screen
  `

### Why This Works
- Users expect ads when launching free apps
- High eCPM (\-18)
- Doesn't interrupt active usage
- Once per day is reasonable

### Expected Revenue
- **eCPM**: \-18
- **ARPDAU contribution**: \.01 - \.02
- **Impact**: Significant revenue boost with minimal UX impact

---

## 4. Native Ads (Best UX Option)

### Concept
Native ads match the UI and feel less intrusive than interstitials.

### Example Placement
`
Converter Categories

Length
Mass
Temperature

[Sponsored calculator app] ← Native ad looks like a category

Speed
Area
`

### Why This Works
- Blends with app UI
- Higher engagement than banners
- Better user experience than interstitials
- Higher eCPM than banners

### Implementation Complexity
- More complex than banners/interstitials
- Requires custom ad templates
- Need to ensure ads look good in your UI

### Expected Revenue
- **eCPM**: \-10
- **ARPDAU contribution**: \.004 - \.01
- **Impact**: Good revenue with excellent UX

---

## 5. Paid Version (Highly Recommended)

### Offer
- **Price**: \.99 - \.99
- **Benefits**: Remove all ads (banners + interstitials)

### Why This Works
- Users who value convenience will pay to remove ads
- High conversion rate in utility apps (1-3%)
- Long-term revenue exceeds ads
- Improves user satisfaction

### Implementation
- Add \"Remove Ads\" button in settings
- Link to in-app purchase
- Simple toggle to disable all ads
- Persistent across app restarts

### Expected Revenue
- **Conversion rate**: 1-3% of users
- **Long-term value**: Often exceeds ad revenue
- **Impact**: Best long-term monetization strategy

---

## 6. Revenue-Optimized Configuration (Recommended)

### Ad Types Enabled
- ✅ Banner: YES
- ✅ Interstitial: YES (limited)
- ✅ App Open: YES (optional)
- ⚪ Native: Optional (future enhancement)
- ❌ Rewarded: NO (doesn't fit utilities)

### Final Frequency Rules

#### Banner Ads
- Always visible on main screens
- Refresh every 60-90 seconds
- No frequency limits

#### Interstitial Ads
- Show only after completed conversions
- Every 20 conversions (not 5)
- Minimum 3 minutes between ads
- Maximum 3 per session
- No ads for first 10 conversions

#### App Open Ads
- Once per day maximum
- Show on app launch
- Skippable after 5 seconds

#### First-Time User Protection
- No interstitials until:
  - 10 conversions completed OR
  - 2nd app session

---

## 7. Implementation Details

### AdMob Service Configuration

The AdMobService class implements the following logic:

`dart
class AdMobService {
  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static AppOpenAd? _appOpenAd;
  
  // Tracking
  static int _conversionCount = 0;
  static int _conversionsSinceLastAd = 0;
  static int _sessionInterstitials = 0;
  static DateTime? _lastAdTime;
  static DateTime? _lastAppOpenAdTime;
  
  // Configuration
  static const int minConversionsBeforeFirstAd = 10;
  static const int conversionsBetweenAds = 20;
  static const int minSecondsBetweenAds = 180; // 3 minutes
  static const int maxInterstitialsPerSession = 3;
  
  // Check if interstitial should be shown
  static bool shouldShowInterstitial() {
    if (_conversionCount < minConversionsBeforeFirstAd) {
      return false; // First-time user protection
    }
    
    if (_conversionsSinceLastAd < conversionsBetweenAds) {
      return false; // Not enough conversions
    }
    
    if (_lastAdTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdTime!).inSeconds;
      if (timeSinceLastAd < minSecondsBetweenAds) {
        return false; // Too soon since last ad
      }
    }
    
    if (_sessionInterstitials >= maxInterstitialsPerSession) {
      return false; // Session limit reached
    }
    
    return true;
  }
  
  // Track a conversion
  static void trackConversion() {
    _conversionCount++;
    _conversionsSinceLastAd++;
    
    if (shouldShowInterstitial()) {
      showInterstitialAd();
    }
  }
  
  // Show interstitial ad
  static Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) {
      return;
    }
    
    // Update tracking
    _conversionsSinceLastAd = 0;
    _sessionInterstitials++;
    _lastAdTime = DateTime.now();
    
    // Show the ad
    await _interstitialAd!.show();
    _interstitialAd = null;
    
    // Preload next ad
    loadInterstitialAd();
  }
  
  // App open ad logic
  static Future<void> showAppOpenAdIfAvailable() async {
    if (_appOpenAd == null) {
      return;
    }
    
    // Check if shown today
    if (_lastAppOpenAdTime != null) {
      final now = DateTime.now();
      final lastShown = _lastAppOpenAdTime!;
      if (now.day == lastShown.day &&
          now.month == lastShown.month &&
          now.year == lastShown.year) {
        return; // Already shown today
      }
    }
    
    // Show the ad
    await _appOpenAd!.show();
    _lastAppOpenAdTime = DateTime.now();
    _appOpenAd = null;
    
    // Preload next ad
    loadAppOpenAd();
  }
}
`

---

## 8. Biggest Monetization Mistake (Avoid This)

### ❌ NEVER Show Ads During the Conversion Flow

**Example of what NOT to do:**
`
User enters number: 100
User selects units: meters to feet
User taps \"Convert\"
→ INTERSTITIAL AD APPEARS
→ User must close ad
→ Result shown: 328.08 feet
`

**Why this is disastrous:**
- Instant 1★ reviews
- High uninstall rate
- Users feel cheated
- Destroys app reputation

### ✅ Correct Placement

**Show interstitial AFTER the task is complete:**
`
User converts units
→ Sees result
→ Copies result or navigates away
→ THEN show interstitial
`

---

## 9. Estimated Revenue (Utility App)

### Revenue per Daily Active User (ARPDAU)

| Ad Strategy | ARPDAU | Monthly (10k DAU) |
|-------------|--------|-------------------|
| Banners only | \.002 - \.01 | \ - \,000 |
| Banner + Interstitial | \.01 - \.05 | \,000 - \,000 |
| With App Open Ads | \.02 - \.07 | \,000 - \,000 |
| With Paid Version (1% conversion) | +\.005 - \.015 | +\ - \,500 |

### Example Calculation

**Assumptions:**
- 10,000 daily active users
- 30-day month
- Banner + Interstitial + App Open strategy

**Revenue:**
- Banners: 10,000 × \.005 × 30 = \,500
- Interstitials: 10,000 × \.03 × 30 = \,000
- App Open: 10,000 × \.015 × 30 = \,500
- Paid version (1%): 100 × \.99 × 30 = \,970

**Total: ~\,000/month**

---

## 10. Advanced Optimization: AdMob Mediation

### Concept
Use multiple ad networks to maximize fill rate and eCPM.

### Recommended Networks
1. **AdMob** (Google) - Primary network
2. **Unity Ads** - Good for gaming, decent for utilities
3. **AppLovin** - High fill rate
4. **IronSource** - Strong performance

### Benefits
- Higher fill rate (more ads show)
- Higher eCPM (more revenue per ad)
- Competition between networks drives prices up
- Better user experience (ads always available)

### Implementation
Requires setting up mediation in AdMob Console and adding SDKs for each network.

### Expected Impact
- **Fill rate**: 95%+ (vs 80-90% without mediation)
- **eCPM increase**: 20-40%
- **Revenue increase**: 30-50%

---

## 11. Testing and Optimization

### A/B Testing
Test different ad frequencies:
- Every 15 conversions vs every 20 conversions
- 2 interstitials per session vs 3
- App open ads vs no app open ads

### Metrics to Track
- **Retention rate** (day 1, 7, 30)
- **Session length**
- **Conversions per session**
- **Ad revenue per user**
- **App store rating**
- **Review sentiment**

### Optimization Loop
1. Start conservative (protect reviews)
2. Gradually increase frequency
3. Monitor impact on retention and reviews
4. Adjust based on data
5. Never sacrifice user experience for short-term revenue

---

## 12. Implementation Checklist

### Phase 1: Core Implementation (Current)
- [x] Banner ads configured
- [x] Interstitial ads configured
- [x] Implement frequency capping (20 conversions)
- [x] Implement time-based capping (3 minutes)
- [x] Implement session limit (3 per session)
- [x] Implement first-time user protection (10 conversions)
- [x] Fix ad placement (after task completion, not during)

### Phase 2: App Open Ads
- [x] Add AppOpenAd to AdMobService
- [x] Implement once-per-day logic
- [x] Load on app startup
- [x] Show after app initialization

### Phase 3: Native Ads (Optional)
- [ ] Design native ad template
- [ ] Implement native ad loading
- [ ] Integrate into category list
- [ ] Test ad rendering

### Phase 4: Paid Version
- [ ] Implement in-app purchase
- [ ] Add \"Remove Ads\" button
- [ ] Implement ad-free mode
- [ ] Test purchase flow

### Phase 5: AdMob Mediation (Advanced)
- [ ] Set up mediation in AdMob Console
- [ ] Add Unity Ads SDK
- [ ] Add AppLovin SDK
- [ ] Configure mediation groups
- [ ] Test fill rates

---

## 13. Key Takeaways

1. **User experience first** - Protect reviews and retention
2. **Start conservative** - You can always increase frequency later
3. **Never interrupt core functionality** - Ads should appear at natural pauses
4. **Respect new users** - Give them time to experience value before showing ads
5. **Consider paid version** - Often more profitable long-term than ads
6. **Monitor metrics** - Track retention, reviews, and revenue
7. **A/B test** - Find the optimal balance for your users
8. **Use mediation** - Maximize revenue with multiple ad networks

---

## Resources

- [AdMob Best Practices](https://developers.google.com/admob/android/best-practices)
- [AdMob Mediation](https://developers.google.com/admob/android/mediation)
- [AdMob Policy](https://support.google.com/admob/answer/9054530)
- [Flutter AdMob Plugin](https://pub.dev/packages/google_mobile_ads)
