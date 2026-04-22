# Trading Card Collection App: Comprehensive Proposal

**Date:** April 11, 2026  
**Author:** Strategic Planning  
**Type:** Mobile App Proposal

---

## Executive Summary

| Factor | Assessment |
|--------|------------|
| **Opportunity** | Massive hobby market, poor mobile solutions |
| **Competition** | Low-Medium (existing apps dated) |
| **Development Time** | 2-3 months MVP |
| **Revenue Potential** | $50-300K/year (Year 1: $10-50K realistic) |
| **Best Revenue Model** | Freemium + Marketplace |
| **Platform** | Flutter (cross-platform) |

---

## Part 1: Market Analysis

### The Trading Card Boom (2020-2026)

| Market | Size | Growth |
|--------|------|--------|
| Pokemon TCG | $100B+ total market | Continues strong |
| Magic: The Gathering | $1B+/year | Stable |
| Sports Cards | $10B+/year | Mature |
| Other (Yu-Gi-Oh, One Piece) | $2B+/year | Growing |

### Collector Demographics

| Segment | Age | Spending | Tech Savvy |
|---------|-----|---------|-----------|
| Kids/Teens | 10-18 | $50-200/year | Very high |
| Young Adults | 19-30 | $200-1000/year | Very high |
| Adults | 31-50 | $500-5000/year | High |
| Serious Collectors | All ages | $5000+/year | Medium-High |

### Current Problem

```
Collectors want to:
- Track their collection value
- Know what they have vs want
- Find deals on cards
- Track price changes
- Log when they bought/sold

Current solutions:
- CLZ: Desktop/web-first, dated UI
- PriceCharting: Web-first, cluttered
- EBay: Generic marketplace, not collection-focused
- Excel/Notion: Manual, error-prone
```

### Why Mobile-First Can Win

| Gap | Current Solutions | Opportunity |
|-----|------------------|-------------|
| UI/UX | Cluttered, desktop ported | Modern Flutter app |
| Scanning | Slow, inaccurate | Camera integration |
| Offline | Poor support | Full offline + sync |
| Social | None | Share collection, trades |
| Price Alerts | None/Minimal | Push notifications |

---

## Part 2: Target Audiences

### Primary: Pokemon TCG Collectors (60% of effort)

| Factor | Data |
|--------|------|
| Market Size | 50M+ collectors worldwide |
| Avg Collection Value | $500-2000 |
| Spending/Year | $200-1000 |
| Mobile Usage | Very high |
| Key Need | Price tracking, condition, want lists |

### Secondary: Sports Card Collectors (25% of effort)

| Factor | Data |
|--------|------|
| Market Size | 20M+ collectors |
| Avg Collection Value | $1000-10000 |
| Spending/Year | $500-5000 |
| Mobile Usage | High |
| Key Need | Grading, authentication, value |

### Tertiary: Magic: The Gathering (10% of effort)

| Factor | Data |
|--------|------|
| Market Size | 20M+ players |
| Avg Collection Value | $500-5000 |
| Spending/Year | $300-2000 |
| Mobile Usage | High |
| Key Need | Deck tracking, card pricing |

### Others: Yu-Gi-Oh, One Piece, etc. (5% of effort)

---

## Part 3: MVP Feature Specification

### Must Have (P0)

| Feature | Description | Priority |
|---------|-------------|----------|
| **Card Search** | Search by name, set, rarity | P0 |
| **Add to Collection** | Add cards with quantity, condition | P0 |
| **Collection View** | Grid/list view of all cards | P0 |
| **Total Value** | Calculate collection worth | P0 |
| **Want List** | Cards you're hunting | P0 |
| **Condition Tracking** | NM, EX, VG, G, etc. | P0 |

### Should Have (P1)

| Feature | Description | Priority |
|---------|-------------|----------|
| **Barcode Scanner** | Scan card barcode for fast add | P1 |
| **Price Tracking** | Current market prices | P1 |
| **Set Completion** | % of set you have | P1 |
| **Filter/Sort** | By set, rarity, value, condition | P1 |
| **Export Data** | CSV/JSON backup | P1 |

### Nice to Have (P2)

| Feature | Description | Priority |
|---------|-------------|----------|
| **Price Alerts** | Notify on value changes | P2 |
| **Multiple Collections** | Track different groups | P2 |
| **Trade Calculator** | Fair trade values | P2 |
| **Selling List** | Cards you want to sell | P2 |

### Future (Post-MVP)

| Feature | Description |
|---------|-------------|
| **Marketplace** | Buy/sell within app |
| **Social Sharing** | Show off collection |
| **Collection Comparison** | vs friends |
| **AI Grading** | Estimate card condition |

---

## Part 4: Pokemon TCG Data Specification

### Card Data Structure

```dart
class TcgCard {
  String id;           // Unique Pokemon API ID
  String name;         // "Charizard"
  String setCode;      // "base2"
  String setName;      // "Jungle"
  String cardNumber;    // "4/64"
  String rarity;       // "Rare Holo"
  String condition;     // "NM", "EX", etc.
  int quantity;        // How many owned
  double buyPrice;     // What you paid
  DateTime dateAdded;
  
  // From API
  String imageUrl;
  double marketPrice;
  double reverseHoloPrice;
}
```

### Set Completion Structure

```dart
class SetProgress {
  String setCode;
  String setName;
  int totalCards;
  int ownedCards;
  double percentComplete;
  double valueOwned;
  double totalSetValue;
}
```

### Condition Grades

| Grade | Name | Description |
|-------|------|-------------|
| M | Mint | Perfect, never played |
| NM | Near Mint | Lightly played, perfect corners |
| EX | Excellent | Light wear, great shape |
| VG | Very Good | Moderate wear, noticeable |
| G | Good | Heavy wear, fully playable |
| P | Poor | Damaged, for parts only |

---

## Part 5: Data Sources

### Pokemon TCG

| Source | Pros | Cons |
|--------|------|------|
| **Pokemon TCG API** | Free, comprehensive | Updates may lag |
| **TCGPlayer** | Accurate prices | Requires account |
| **PriceCharting** | Historical data | Web-first |

**Recommendation:** Pokemon TCG API (https://api.pokemontcg.io) for card data, supplement with TCGPlayer prices.

### Magic: The Gathering

| Source | Pros | Cons |
|--------|------|------|
| **Scryfall** | Free, comprehensive, fast | None really |
| **MTGGoldfish** | Deck tracking | Price focus |
| **TCGPlayer** | Marketplace | Commercial |

**Recommendation:** Scryfall API (https://api.scryfall.com) - best free API.

### Sports Cards

| Source | Pros | Cons |
|--------|------|------|
| **PriceCharting** | Sports card focus | Web-first |
| **eBay API** | Real sales data | Complex |
| **130point.com** | Grading database | Limited API |

**Recommendation:** PriceCharting for prices, manual data entry initially.

---

## Part 6: Revenue Model

### Freemium + Subscription (Recommended)

```
┌─────────────────────────────────────────┐
│              FREE TIER                   │
├─────────────────────────────────────────┤
│ • Add up to 500 cards                   │
│ • Basic search                          │
│ • Collection value (delayed prices)     │
│ • 1 want list                          │
│ • Banner ads                           │
└─────────────────────────────────────────┘
              ↓ Upgrade prompt
┌─────────────────────────────────────────┐
│          PRO TIER ($4.99/month)          │
├─────────────────────────────────────────┤
│ • Unlimited cards                      │
│ • Real-time prices                     │
│ • Unlimited want lists                 │
│ • Multiple collections                  │
│ • No ads                              │
│ • Cloud sync                          │
│ • Export data                         │
│ • Price alerts                        │
└─────────────────────────────────────────┘
```

### Alternative: One-Time Purchase

```
Pro Version: $19.99 one-time
• All features forever
• No subscription
• But: less recurring revenue
• Good for collectors who hate subscriptions
```

### Hybrid Model (Best of Both)

```
Free Tier: Basic features, ads
Pro Subscription: $4.99/month or $39.99/year
Lifetime Pro: $79.99 (one-time)

Gives users choice:
- Casual: Free with ads
- Regular: $39.99/year (~$3.33/month)
- Committed: $79.99 lifetime
```

---

## Part 7: Revenue Projections

### Conservative Scenario

| Month | Downloads | DAU | Free Users | Pro Users | Revenue |
|-------|-----------|-----|-----------|----------|---------|
| 1 | 500 | 100 | 95 | 5 | $10 |
| 3 | 2,000 | 500 | 470 | 30 | $75 |
| 6 | 5,000 | 1,500 | 1,350 | 150 | $375 |
| 12 | 15,000 | 5,000 | 4,250 | 750 | $1,875 |

**Year 1 Total: ~$15,000**

### Moderate Scenario

| Month | Downloads | DAU | Free Users | Pro Users | Revenue |
|-------|-----------|-----|-----------|----------|---------|
| 1 | 1,000 | 300 | 270 | 30 | $60 |
| 3 | 5,000 | 1,500 | 1,275 | 225 | $450 |
| 6 | 15,000 | 5,000 | 4,000 | 1,000 | $2,000 |
| 12 | 50,000 | 20,000 | 15,000 | 5,000 | $10,000 |

**Year 1 Total: ~$50,000**

### Optimistic Scenario

| Month | Downloads | DAU | Free Users | Pro Users | Revenue |
|-------|-----------|-----|-----------|----------|---------|
| 1 | 2,000 | 600 | 510 | 90 | $180 |
| 3 | 10,000 | 4,000 | 3,200 | 800 | $1,600 |
| 6 | 30,000 | 12,000 | 9,000 | 3,000 | $6,000 |
| 12 | 100,000 | 40,000 | 28,000 | 12,000 | $24,000 |

**Year 1 Total: ~$100,000**

### Long-Term (Year 3)

| Scenario | MAU | Pro Users | Monthly Revenue | Annual |
|----------|-----|-----------|---------------|--------|
| Conservative | 50K | 5K | $12,500 | $150K |
| Moderate | 150K | 20K | $50,000 | $600K |
| Optimistic | 500K | 75K | $187,500 | $2.25M |

---

## Part 8: Development Roadmap

### Phase 1: Foundation (Weeks 1-4)

```
Week 1-2: Project Setup
• Flutter project structure
• Firebase setup (auth, firestore)
• Card data models
• Pokemon TCG API integration

Week 3-4: Core Features
• Card search UI
• Add card to collection
• Collection list view
• Local persistence
```

### Phase 2: Polish (Weeks 5-8)

```
Week 5-6: Value & Organization
• Price API integration
• Collection value calculation
• Filter/sort functionality
• Condition tracking

Week 7-8: Want Lists & UX
• Want list feature
• Set completion tracking
• UI polish
• Bug fixes
```

### Phase 3: Monetization (Weeks 9-12)

```
Week 9-10: Premium Features
• Pro subscription UI
• Cloud sync (Firebase)
• Remove ads logic
• Paywall implementation

Week 11-12: Launch Prep
• App store optimization
• Screenshots, descriptions
• Test flight review
• Release build
```

### Phase 4: Post-Launch (Ongoing)

```
Month 3-4:
• Monitor reviews
• Fix bugs
• Add sports card support

Month 5-6:
• Magic: The Gathering support
• Marketplace MVP (future)
```

---

## Part 9: Technical Architecture

### Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter |
| Backend | Firebase (Auth, Firestore, Cloud Functions) |
| Database | Firestore (user collections) + Card Data API |
| Storage | Firebase Storage (images, exports) |
| Analytics | Firebase Analytics |
| Payments | RevenueCat (subscriptions) |
| Ads | AdMob (banner, interstitial) |
| API | Pokemon TCG API, Scryfall |

### Data Model

```
Users/
  {userId}/
    profile/
      displayName
      email
      createdAt
      subscriptionStatus (free/pro/lifetime)
    
    collections/
      {collectionId}/
        name
        type (pokemon/magic/sports)
        createdAt
        
        cards/
          {cardId}/
            cardDbId       // From API
            name
            quantity
            condition
            buyPrice
            dateAdded
            notes
    
    wantLists/
      {listId}/
        name
        cards/
          {cardId}/
            cardDbId
            targetPrice
            addedAt
```

### Offline Strategy

```
1. Card database: Cached locally (SQLite/Hive)
2. User collection: Firestore + local cache
3. Prices: Fetch on open, cache for 24h
4. Sync: Conflict resolution (last-write-wins)
```

---

## Part 10: App Store Optimization

### Title Options

```
1. "CardVault - Collection Tracker"
2. "CollectR - Pokemon & MTG Tracker"  
3. "CardWise - Trading Card Collection"
```

**Recommendation:** "CollectR - Pokemon & MTG Tracker"

### Short Description (80 chars)

```
Track your Pokemon & Magic collection. Prices, want lists, and more!
```

### Full Description (4000 chars)

```
YOUR COMPLETE TRADING CARD COMPANION

Track, value, and manage your Pokemon TCG, Magic: The Gathering, and sports card collections all in one beautiful app.

FEATURES:

📦 UNLIMITED COLLECTION TRACKING
Add your cards in seconds. Search by name, scan a barcode, or browse by set. Track condition, quantity, purchase price, and more.

💰 KNOW YOUR COLLECTION'S WORTH
See real-time market prices and track how your collection value changes over time. Know exactly what your collection is worth.

📋 SET COMPLETION TRACKING
See exactly which cards you need to complete a set. Track your progress and find missing cards.

❤️ WANT LISTS
Create want lists for cards you're hunting. Set target prices and get alerts when cards are in your range.

🔔 PRICE ALERTS (Pro)
Get notified when cards in your collection or want list change price.

☁️ SYNC ACROSS DEVICES (Pro)
Your collection syncs to the cloud. Access from phone, tablet, anywhere.

🚫 NO ADS (Pro)
Enjoy your collection without interruptions.

SUPPORTED:
• Pokemon Trading Card Game
• Magic: The Gathering (Coming Soon)
• Sports Cards (Coming Soon)

Join thousands of collectors who trust CollectR to manage their collections.

SUBSCRIPTION:
• Pro: $4.99/month or $39.99/year
• Lifetime: $79.99 (one-time)

Prices in USD. Cancel anytime.
```

### Keywords

```
pokemon, trading cards, mtg, magic, collection, collector, cards, tcg, yugioh, baseball cards, basketball, football, price guide, card value, deck
```

### Screenshots (5 required)

| # | Content | Text Overlay |
|---|---------|--------------|
| 1 | Collection grid | "Beautiful Collection View" |
| 2 | Card detail | "Track Condition & Price" |
| 3 | Want list | "Hunt for Cards" |
| 4 | Set completion | "Complete Your Sets" |
| 5 | Value dashboard | "Know Your Worth" |

---

## Part 11: Competitive Analysis

### Existing Players

| App | Platform | Strengths | Weaknesses | Price |
|------|----------|-----------|------------|-------|
| **CLZ** | Both | Comprehensive | Dated UI, expensive | $25/year |
| **PriceCharting** | Web + Mobile | Price data | Web-first, cluttered | Free + paid |
| **Delisc** | iOS | Modern UI | Pokemon only | $5/month |
| **Cardkeeper** | Android | Basic tracking | Limited features | Free + ads |

### Our Advantages

| Competitor Weakness | Our Advantage |
|--------------------|--------------|
| CLZ: Expensive | Our pricing: $4.99/month or free tier |
| CLZ: Dated UI | Modern Flutter UI |
| PriceCharting: Web-first | True mobile-first |
| Others: Limited | Multi-game support (future) |

### Differentiation Strategy

1. **Modern UI** - Clean, fast, beautiful
2. **Aggressive Freemium** - Generous free tier
3. **Pokemon First** - Dominant market, then expand
4. **Speed** - Faster scanning, smoother UX

---

## Part 12: Go-To-Market Strategy

### Pre-Launch (Weeks 1-12)

```
1. Build in public
   - Reddit: r/pkmncollector, r/PokemonTCG
   - Twitter: Share progress, get feedback
   
2. Beta Testing
   - TestFlight (iOS)
   - Internal testing (Android)
   - Gather feedback, fix bugs
   
3. Community Building
   - Discord server for collectors
   - Monthly polls, card discussions
```

### Launch Week

```
1. App Store Submission
   - Prepare screenshots, descriptions
   - Submit 2 weeks before wanted date
   
2. Launch Post
   - Reddit posts in Pokemon communities
   - Twitter announcement
   - Discord celebration
   
3. Outreach
   - Contact Pokemon YouTubers (small, engaged)
   - Contact card shopping discords
```

### Post-Launch (Month 1-3)

```
1. Monitor & Respond
   - Reply to every review
   - Fix critical bugs within 24h
   
2. Feature Releases
   - Weekly updates with bug fixes
   - Bi-weekly with small features
   
3. Expansion
   - Sports card support (month 2-3)
   - Magic: The Gathering (month 4-6)
```

---

## Part 13: Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Card API goes down** | Low | High | Cache locally, multiple sources |
| **Competition intensifies** | Medium | Medium | First-mover advantage, community |
| **Pokemon prices crash** | Medium | Low | Diversify to MTG, sports |
| **App store rejection** | Low | Medium | Follow guidelines carefully |
| **Low user retention** | Medium | High | Push notifications, community |
| **Subscription churn** | Medium | Medium | Add value, don't gouge |

---

## Part 14: Financial Summary

### Development Costs

| Item | Cost |
|------|------|
| Your time (500 hours × $0) | $0 |
| Firebase (tier 1) | $0 |
| Card APIs | $0 |
| RevenueCat | $0 (free tier) |
| Total | $0 |

### Ongoing Costs (Year 1)

| Item | Monthly Cost |
|------|-------------|
| Firebase (Spark → Blaze if needed) | $0-50 |
| Card API subscriptions | $0-100 |
| RevenueCat (3% fee) | 3% of subscription revenue |
| Total | $0-150 |

### Break-Even Analysis

| Scenario | Monthly Cost | Revenue to Break Even |
|----------|-------------|---------------------|
| Conservative | $50 | 17 Pro subscribers |
| Moderate | $100 | 34 Pro subscribers |
| Optimistic | $150 | 51 Pro subscribers |

**With 5,000 DAU at 3% conversion = 150 Pro subscribers = $750/month**

---

## Part 15: Final Recommendation

### MVP Scope (2-3 months)

```
✅ Card search
✅ Add to collection
✅ Collection view
✅ Total value
✅ Want list
✅ Condition tracking
✅ Set completion
✅ Basic filter/sort
✅ Local storage
```

### Post-MVP (Months 4-6)

```
• Cloud sync
• Subscription implementation
• Sports cards
• Price alerts
• Export/import
```

### Year 2 Vision

```
• Magic: The Gathering
• Marketplace
• Social features
• Collection comparison
```

---

## Summary

| Factor | Commitment |
|--------|------------|
| Development Time | 2-3 months MVP |
| Ongoing Costs | ~$50-100/month |
| Year 1 Revenue (Realistic) | $15,000-50,000 |
| Year 1 Revenue (Stretch) | $100,000+ |
| Competition | Low-Medium |
| Passion Factor | Very High |
| Recurring Revenue | Yes (subscriptions) |

---

## Next Steps

1. **Validate** - Reddit/Twitter interest check
2. **Spec** - Detailed UI wireframes (Figma)
3. **Build** - Flutter app, Pokemon API integration
4. **Beta** - TestFlight, gather feedback
5. **Launch** - App store submission, community push

---

**Document Version:** 1.0  
**Ready for Development:** Pending your decision
