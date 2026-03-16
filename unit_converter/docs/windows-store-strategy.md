# Windows Store Strategy for Unit Converter

## Objective

Ship a Windows Store version of Unit Converter with a monetization model that fits desktop utility expectations, preserves a strong free experience, and grows toward a sustainable premium conversion funnel.

## Evidence Base

### Microsoft trial guidance
Microsoft recommends that utility apps use Store-supported trial behavior and either:
- limit features in the trial/free experience,
- show upgrade prompts,
- or combine full functionality with trial-only prompts.

For utility apps specifically, Microsoft guidance notes that feature limitation is a valid and common strategy for trial versions.

### Microsoft Store pricing and availability model
Partner Center supports:
- free pricing,
- paid pricing tiers,
- unlimited trials,
- time-limited trials,
- scheduled pricing changes.

This supports a staged rollout where we can start with a free core and premium unlock, then adjust pricing later based on conversion data.

### App-specific competitive evidence
Our existing competitive analysis shows that our strongest differentiators are:
- Custom Units
- Live Currency Conversion
- Offline-first reliability
- Polished responsive UX
- Quick Presets and advanced workflows

These are stronger premium candidates than basic unit conversion, because basic conversion categories face heavy free competition on desktop.

## Recommended Monetization Strategy

## Recommendation

Use a **Windows-specific freemium / unlimited-trial model**:
- **Free core** for essential utility use
- **One-time premium unlock** for advanced/pro features
- **No ads on Windows** as the primary monetization mechanism

## Why this strategy is the best fit

### Why not ad-supported Windows?
- Desktop utility users are less tolerant of ads than mobile users.
- Desktop ad support is weaker and less aligned with this codebase.
- Windows Store users are more accepting of utility software that has a clean free tier and a paid upgrade.

### Why not fully paid from day one?
- Desktop converter utilities compete with free alternatives.
- A paid-only paywall suppresses installs, search ranking, and reviews.
- A free tier lets the app prove value before asking for money.

### Why freemium works here
- It aligns with Microsoft trial guidance.
- It preserves discoverability and acquisition.
- It monetizes the features users perceive as advanced and differentiated.
- It gives us measurable conversion points inside the app.

## Product Packaging Recommendation

### Free Windows tier
Users should get a useful standalone utility without paying:
- Length
- Weight
- Temperature
- Search
- Recent history
- Favorites
- Quick presets for free categories
- Theme support

This is enough for basic value and strong reviews.

### Premium Windows tier
Premium should unlock features that clearly exceed the baseline:
- Currency conversion
- Volume
- Cooking
- Area
- Speed
- Data
- Pressure
- Time
- Custom Units
- Future offline currency enhancements
- Future power-user desktop workflows

## Pricing Recommendation

### Launch recommendation
- **Primary recommendation:** $0.99 one-time premium unlock

### Why $0.99 first
- Low-friction impulse purchase
- Easier to validate conversion rate early
- Competitive against free alternatives
- Strong match for a utility with clear premium differentiation but no established Windows brand yet

### Price testing roadmap
After launch, evaluate:
- $0.99 baseline
- $1.99 if conversion remains strong and reviews validate premium value

Do not launch above $1.99 until Windows-specific demand is proven.

## Rollout Plan

## Phase 1: Ship a strong Windows free core

### Goal
Get installs, reviews, and real-world usage data.

### Product decisions
- Keep 3 core categories free.
- Gate advanced categories and Custom Units.
- Show premium labels on locked tools.
- Show an upgrade dialog when locked tools are tapped.
- Route upgrade traffic to the existing Settings purchase surface.

### Success metrics
- Store acquisition
- Category open rate
- Locked-tool tap rate
- Upgrade conversion rate
- Review quality

## Phase 2: Validate premium demand

### Goal
Measure whether the gated feature set converts on Windows.

### Instrumentation to add
- Locked category tap events
- Currency lock tap events
- Custom Units lock tap events
- Upgrade CTA impressions
- Upgrade CTA taps
- Purchase completion rate

### Decision thresholds
- If upgrade taps are high but purchases are low, improve value messaging.
- If purchases are healthy, test $1.99.
- If conversion is weak, reduce gating severity before lowering price.

## Phase 3: Improve premium value proposition

### Add premium features that fit desktop utility users
- Saved workspaces / favorite bundles
- Offline currency snapshots
- Export/share conversion sets
- Multi-panel desktop layout
- Keyboard-first workflows
- More professional categories

This gives us a stronger reason to increase price later.

## Gating Strategy Details

## What should stay free
These categories are basic, universal, and expected in free tools:
- Length
- Weight
- Temperature

## What should be premium
These are more differentiated or power-user oriented:
- Currency
- Volume
- Cooking
- Area
- Speed
- Data
- Pressure
- Time
- Custom Units

## Why category-based gating first
This is the clearest first implementation because:
- users immediately understand what is locked,
- the value proposition is visible on the home screen,
- it is easy to test,
- it minimizes risky platform-specific code.

## Engineering Plan

## Implemented in first slice
The first slice now introduces:
- a Windows Store access policy service,
- Windows-only premium gating logic,
- locked-card UI for premium categories,
- premium messaging for Currency and other advanced tools,
- Custom Units access gating,
- test coverage for policy behavior and widget behavior.

## Next implementation slices

### Slice 2: Windows purchase product model
- Add Windows-specific premium product naming and copy.
- Separate Windows premium messaging from mobile ad-removal messaging.
- Ensure Settings communicates premium as an unlock, not just ad removal.

### Slice 3: Real Microsoft Store license integration
- Replace local premium-only fallback with Store-backed Windows entitlement checks.
- Listen for license changes while app is running.
- Support restore/refresh for Windows entitlement state.

### Slice 4: Analytics and experiment support
- Add internal events for lock impressions and upgrade taps.
- Track upgrade funnel per category.
- Support price/message experiments.

## Testing Strategy

## Implemented tests
- Policy tests for Windows free tier vs premium tier
- Widget tests for locked Windows UI states
- Widget tests for upgrade dialog presentation
- Widget tests confirming non-Windows flow remains unlocked

## Additional tests to add next
- Integration tests for upgrade flow from locked tool to Settings purchase UI
- Tests for Custom Units lock flow
- Tests ensuring search results respect locked access messaging
- Windows-specific integration coverage once Store entitlement integration exists

## Risks and Mitigations

### Risk: Too much locked too early
Mitigation:
- Keep the free core genuinely useful
- Watch store reviews and upgrade conversion
- Be ready to move one additional category into free if needed

### Risk: Premium messaging is unclear
Mitigation:
- Use explicit premium labels
- Explain exactly what premium unlocks
- Improve copy in Settings and dialogs

### Risk: Windows purchase UX differs from mobile
Mitigation:
- Keep the access policy isolated
- Introduce platform-specific entitlement adapters
- Avoid coupling Windows monetization to Android/iOS assumptions

## Final Recommendation

For Windows Store, the recommended path is:
- **Free app with unlimited trial-style feature gating**
- **$0.99 one-time premium unlock at launch**
- **Free core = Length, Weight, Temperature**
- **Premium = advanced categories + Custom Units**

This is the strongest balance of:
- acquisition,
- desktop user expectations,
- Microsoft guidance,
- and our app's actual differentiators.

