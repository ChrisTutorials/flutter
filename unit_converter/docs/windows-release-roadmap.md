# Windows Store Release Roadmap

## Overview
Complete roadmap for releasing the Unit Converter app to the Microsoft Store with premium monetization.

## Current Status

### What's Implemented ✅
- Windows-only premium gating via `WindowsStoreAccessPolicy`
- Free categories: Length, Weight, Temperature
- Premium-gated: Currency, advanced categories, Custom Units
- PremiumService integration

### What's Missing ❌
- Real Microsoft Store entitlement/license check
- Real Windows premium add-on purchase flow
- Store-driven trial state handling
- Windows-specific purchase UI copy
- PurchaseService is mobile-only (Android/iOS only)

---

## Phase 1: Partner Center Configuration (Manual)

### 1.1 App Product Setup
**Product ID:** 9P8DMW35JXQ5

**Required Actions:**
- [ ] Set base price to **Free** ($0.00)
- [ ] Set visibility to "Make this product available and discoverable in the Store"
- [ ] Configure target markets (start with primary markets, expand later)
- [ ] Leave organizational licensing at defaults (unless business licensing needed)
- [ ] No sale pricing for launch
- [ ] **Do NOT** configure Store trial yet (will handle in-app)

**Rationale:** Free base app allows freemium model with in-app premium gating.

### 1.2 Store Listing
**Required Actions:**
- [ ] Complete app descriptions (short and long)
- [ ] Upload screenshots (use marketing/screenshots/windows_store_screenshots/)
- [ ] Upload app icon
- [ ] Set support URL
- [ ] Set privacy policy URL
- [ ] Complete classification (category/subcategory)
- [ ] Complete age rating questionnaire
- [ ] Configure release timing and publish behavior

### 1.3 Premium Add-On Setup
**Recommended Model:** Free app + durable premium add-on

**Required Actions:**
- [ ] Create new durable add-on
  - **Add-on ID:** `windows_premium_unlock` (must match code)
  - **Display name:** "Premium Unlock"
  - **Price:** $0.99
  - **Type:** Durable / Non-consumable
  - **Description:** "Unlock all premium features: Currency conversion, advanced categories, and custom units"
- [ ] Configure add-on availability (same markets as app)
- [ ] Add add-on to app submission

**Alternative Model (Not Recommended):** App-level trial/full license
- Would require different implementation approach
- Less flexible for freemium utilities

---

## Phase 2: Code Implementation - Windows Store Integration

### 2.1 Windows Store Entitlement Adapter
**File:** `unit_converter/lib/services/windows_store_entitlement_service.dart`

**Implementation:**
- [ ] Create service that wraps Windows Store SDK license APIs
- [ ] Implement `isPremiumUnlocked()` method checking add-on ownership
- [ ] Implement `purchasePremium()` method to trigger add-on purchase
- [ ] Implement `restorePurchases()` method for license refresh
- [ ] Handle license state changes via Store license events
- [ ] Add error handling for network failures, Store unavailability

### 2.2 Update PurchaseService for Windows
**File:** `unit_converter/lib/services/purchase_service.dart`

**Changes:**
- [ ] Update `_supportsStore` to return true for Windows
- [ ] Add Windows premium product ID: `windows_premium_unlock`
- [ ] Implement Windows purchase flow in `purchasePremium()`
- [ ] Implement Windows restore flow in `restorePurchases()`
- [ ] Update purchase UI copy from "Ad-free upgrade" to "Premium unlock" for Windows

### 2.3 Update WindowsStoreAccessPolicy
**File:** `unit_converter/lib/services/windows_store_access_policy.dart`

**Changes:**
- [ ] Replace mock implementation with real Store entitlement checks
- [ ] Integrate with `WindowsStoreEntitlementService`
- [ ] Add license refresh capability
- [ ] Handle offline scenarios gracefully

### 2.4 Premium Service Integration
**File:** `unit_converter/lib/services/premium_service.dart`

**Changes:**
- [ ] Ensure Windows uses Store-based premium checks
- [ ] Update premium status caching for Windows
- [ ] Handle license state changes from Store events

### 2.5 Windows-Specific UI Updates
**Files:** Various screens with purchase prompts

**Changes:**
- [ ] Update Settings screen purchase copy for Windows
- [ ] Update premium gate prompts for Windows
- [ ] Add "Restore Purchases" button to Windows Settings
- [ ] Ensure purchase error messages are Windows-appropriate

---

## Phase 3: Testing

### 3.1 Unit Tests
**Files:** `unit_converter/test/services/`

**Required Tests:**
- [x] `windows_admob_behavior_test.dart` - AdMob behavior on Windows
  - Test ads are disabled on Windows
  - Test MobileAds SDK is not initialized
  - Test all ad service methods are safe to call
  - Test premium status does not enable ads
- [x] `windows_iap_integration_test.dart` - IAP integration on Windows
  - Test IAP is not available on Windows (current state)
  - Test purchase attempts fail gracefully
  - Test restore purchases completes without error
  - Test premium status is managed by PremiumService
- [ ] `windows_store_entitlement_service_test.dart` (to be created)
  - Test premium unlock detection
  - Test purchase flow simulation
  - Test restore flow
  - Test error handling
- [ ] Update `windows_store_access_policy_test.dart` for Windows scenarios
  - Test category access with premium unlock
  - Test custom units access with premium unlock
- [ ] Update `premium_service_test.dart` for Windows scenarios

### 3.2 Integration Tests
**Files:** `unit_converter/test/integration/`

**Required Tests:**
- [x] `windows_build_e2e_test.dart` - End-to-end Windows build tests
  - Test app initializes without ads
  - Test free categories accessible to non-premium users
  - Test premium categories locked for non-premium users
  - Test all categories accessible to premium users
  - Test banner ads never show
  - Test interstitial ads never show
  - Test app open ads never show
  - Test IAP is not available (current state)
  - Test purchase attempts fail gracefully
  - Test restore purchases completes without error
  - Test premium status persists across app restarts
  - Test app functions correctly without ads or IAP
  - Test all ad service calls are safe
  - Test all purchase service calls are safe
  - Test premium status changes are maintained
  - Test concurrent service calls don't crash
  - Regression tests ensuring ads never show
  - Regression tests ensuring MobileAds SDK never initializes
  - Regression tests ensuring purchase attempts fail gracefully
- [ ] End-to-end purchase flow on Windows (to be added after IAP implementation)
- [ ] Premium unlock persists across app restarts (to be added after IAP implementation)
- [ ] Restore purchases functionality (to be added after IAP implementation)
- [ ] Offline behavior with cached license (to be added after IAP implementation)
- [ ] License revocation handling (to be added after IAP implementation)

### 3.3 Manual Testing
**Required Tests - Current Windows Behavior:**
- [x] Verify ads are disabled on Windows
- [x] Verify MobileAds SDK is not initialized on Windows
- [x] Verify free categories accessible to all users
- [x] Verify premium categories locked for free users
- [x] Verify premium categories unlock when premium status is set
- [x] Verify app functions correctly without ads or IAP
- [x] Verify premium status persists across app restarts

**Required Tests - After Windows IAP Implementation:**
- [ ] Install from Store (or sideload with Store license)
- [ ] Verify free categories accessible
- [ ] Verify premium categories locked
- [ ] Complete premium purchase via Windows Store
- [ ] Verify premium categories unlocked
- [ ] Close and reopen app - verify premium status persists
- [ ] Test restore purchases from Windows Store
- [ ] Test offline usage with cached premium status
- [ ] Test purchase error handling (network failures, Store unavailability)

---

## Phase 4: Deployment

### 4.1 Build Windows Release
**Commands:**
```powershell
cd c:\dev\flutter\unit_converter
flutter build windows --release
```

**Required Actions:**
- [ ] Verify build succeeds
- [ ] Test the release build locally
- [ ] Package for Store (using Visual Studio or Store submission tools)

### 4.2 Store Submission
**Required Actions:**
- [ ] Upload release package to Partner Center
- [ ] Complete submission questionnaire
- [ ] Set publish date (immediate or scheduled)
- [ ] Monitor submission status
- [ ] Address any certification issues

### 4.3 Post-Launch Monitoring
**Required Actions:**
- [ ] Monitor crash reports
- [ ] Monitor purchase conversion rates
- [ ] Monitor user feedback
- [ ] Track premium adoption
- [ ] Prepare quick fix for any critical issues

---

## Phase 5: Post-Launch Enhancements (Future)

### 5.1 Advanced Features
- [ ] Store-managed trial integration (if desired)
- [ ] Multiple premium tiers
- [ ] Subscription options
- [ ] Promo codes for premium unlock
- [ ] Sales and discounts

### 5.2 Analytics
- [ ] Track premium conversion funnel
- [ ] Track category usage patterns
- [ ] Track purchase abandonment points
- [ ] A/B test pricing

---

## Dependencies & Critical Path

### Critical Path (Must Complete in Order)
1. Phase 1.1 (App Product Setup) - Can start immediately
2. Phase 1.2 (Store Listing) - Can start in parallel with 1.1
3. Phase 2.1 (Windows Store Entitlement Adapter) - Depends on 1.1 completion (for add-on ID)
4. Phase 2.2 (Update PurchaseService) - Depends on 2.1
5. Phase 2.3 (Update WindowsStoreAccessPolicy) - Depends on 2.1
6. Phase 2.4 (Premium Service Integration) - Depends on 2.1
7. Phase 2.5 (UI Updates) - Can start in parallel with 2.1-2.4
8. Phase 3 (Testing) - Depends on Phase 2 completion
9. Phase 1.3 (Premium Add-On Setup) - Can start after 2.1 (needs add-on ID from code)
10. Phase 4.1 (Build Release) - Depends on Phase 3 completion
11. Phase 4.2 (Store Submission) - Depends on 4.1 and Phase 1 completion

### Parallel Work Opportunities
- Phase 1.1 and 1.2 can be done simultaneously
- Phase 2.5 can be done alongside 2.1-2.4
- Phase 1.3 can be done while coding Phase 2 (once add-on ID is decided)

---

## Estimated Timeline

### Minimum Viable Release (MVR)
- **Phase 1 (Partner Center):** 1-2 days
- **Phase 2 (Code Implementation):** 2-3 days
- **Phase 3 (Testing):** 1-2 days
- **Phase 4 (Deployment):** 1 day
- **Total:** 5-8 days

### Full Release with Testing
- **Phases 1-4 as above**
- **Phase 5 (Post-Launch):** Ongoing
- **Total to launch:** 1-2 weeks

---

## Risk Mitigation

### Technical Risks
**Risk:** Windows Store SDK integration issues
**Mitigation:** Implement fallback to current mock behavior if Store APIs fail

**Risk:** License state synchronization issues
**Mitigation:** Implement robust caching and refresh logic

**Risk:** Purchase flow failures
**Mitigation:** Comprehensive error handling and user-friendly error messages

### Business Risks
**Risk:** Low premium conversion rate
**Mitigation:** A/B test pricing, optimize premium gate UX

**Risk:** Store certification rejection
**Mitigation:** Follow Store guidelines closely, test thoroughly before submission

---

## Success Criteria

### Launch Criteria
- [ ] App successfully published to Microsoft Store
- [ ] Free categories accessible to all users
- [ ] Premium categories properly gated
- [ ] Premium purchase flow functional
- [ ] Premium status persists across app sessions
- [ ] No critical bugs or crashes

### Post-Launch Success Metrics
- [ ] Conversion rate > 2% (free to premium)
- [ ] App store rating > 4.0 stars
- [ ] Crash rate < 1%
- [ ] User retention > 30% after 7 days

---

## Next Immediate Actions

1. **Decision:** Confirm add-on ID `windows_premium_unlock` and price $0.99
2. **Partner Center:** Start Phase 1.1 and 1.2 (app setup and listing)
3. **Code:** Begin Phase 2.1 (Windows Store Entitlement Adapter)
4. **Coordination:** Share add-on ID with developer once decided

---

## Resources

- **Unified Deployment:** `.windsurf/workflows/unified-deployment.md`
- **Deployment Script:** `scripts/deploy.ps1`
- **Windows Deployment Skill:** `.windsurf/skills/unified-deployment/SKILL.md`
- **AdMob Setup:** `docs/ADMOB_PRODUCTION_SETUP.md`
- **Deployment Guide:** `docs/DEPLOYMENT.md`

