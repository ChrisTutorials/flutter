# Mobile App Proposals: Top 5 Recommendations

**Date:** April 11, 2026  
**Goal:** Identify 5 viable app proposals for indie dev with limited ad budget

---

## Proposal Ranking Criteria

| Criteria | Weight | Description |
|----------|--------|-------------|
| Competition | 30% | Lower = better |
| Development Time | 20% | Faster = better |
| Revenue Potential | 25% | Higher = better |
| Unique Value | 15% | Clear differentiator |
| Scalability | 10% | Can expand beyond MVP |

---

## #1: Honkai: Star Rail Wish Tracker

### The Idea
A beautiful, modern wish tracking companion for Honkai: Star Rail players. Track pulls, pity rates, and spending with a premium UX that existing trackers lack.

### Why #1?

| Factor | Assessment |
|--------|------------|
| Competition | **Low** - Only 3-5 trackers exist |
| Player Base | **20-40M MAU** - Large, passionate |
| Update Cycle | **Every 6 weeks** - Recurring engagement |
| Dev Time | **2-3 weeks** MVP |
| Revenue | **$200-500/mo** realistic Year 1 |

### Problem It Solves

```
Player frustration: "I spent $200 this month and only got 2 five-stars. 
The advertised rate is 0.6% but I got 0.3%. Am I just unlucky?"

Solution: Track every pull. See your actual rate. Know when pity should trigger.
```

### Core Features (MVP)

| Feature | Description | Priority |
|---------|-------------|----------|
| **Pull Entry** | Manual input with timestamp, banner, result | Must Have |
| **Pity Counter** | Auto-calculate based on banner type | Must Have |
| **Statistics Dashboard** | Total pulls, 5-star rate, wish history | Must Have |
| **Banner Management** | Track multiple concurrent banners | Must Have |
| **Local Storage** | Persist data on device | Must Have |
| **Pull History List** | Scrollable list of all pulls | Should Have |

### Premium Features (Post-MVP)

| Feature | Description | Price |
|---------|-------------|-------|
| Cloud Sync | Sync across devices | $1.99/mo |
| No Ads | Remove banner ads | $3.99 one-time |
| Duplicate Tracker | Track constellation level | Included in premium |
| Export/Import | JSON backup | Included in premium |

### Monetization Model

```
Revenue = Ads + Premium Subscriptions

Freemium Tier (Free):
- Basic tracking
- 1 banner type
- Banner ads

Premium Tier ($2.99/month):
- All banner types
- Cloud sync
- No ads
- Advanced stats

Year 1 Projection: $200-500/month average
```

### Development Breakdown

| Week | Deliverable |
|------|--------------|
| 1 | Project setup, database schema, pull entry UI |
| 2 | Pity calculation logic, banner management |
| 3 | Statistics dashboard, local storage |
| 4 | Polish, testing, app store submission |

### Tech Stack

- **Flutter** (leverage existing skills)
- **Hive** (local storage, fast)
- **Google AdMob** (banner ads)
- **RevenueCat** (subscriptions)

### Success Metrics

| Metric | Target (Month 3) | Target (Month 6) |
|--------|------------------|------------------|
| Downloads | 2,000 | 10,000 |
| DAU | 500 | 3,000 |
| Premium Subscribers | 20 | 100 |
| Monthly Revenue | $100 | $400 |

---

## #2: Town of Salem Log Generator

### The Idea
The only dedicated log generator for Town of Salem - a social deduction game with 12+ years of community history but zero companion apps.

### Why #2?

| Factor | Assessment |
|--------|------------|
| Competition | **Zero** - No dedicated apps exist |
| Community | **Active** - Reddit/Discord engaged |
| Dev Time | **2-4 weeks** MVP |
| Revenue | **$50-200/mo** (niche market) |
| Differentiation | **Maximum** - First mover |

### Problem It Solves

```
Town of Salem players manually type logs in notepad or Discord.
Tracking night actions, votes, and wills is tedious and error-prone.

Solution: Structured log entry with auto-generated text for sharing.
```

### Core Features (MVP)

| Feature | Description | Priority |
|---------|-------------|----------|
| **Night Log** | Who visited whom, role abilities | Must Have |
| **Day Tracker** | Votes, lynches, speeches | Must Have |
| **Will Generator** | Auto-format last will/death note | Must Have |
| **Role Templates** | Pre-built role behavior guides | Must Have |
| **Export Log** | Copy/share formatted log text | Must Have |
| **Save Games** | Local storage of game sessions | Should Have |

### Role Templates (MVP)

| Faction | Roles Include |
|---------|---------------|
| Town | Sheriff, Investigator, Lookout, Doctor, Escort, Mayor, etc. |
| Mafia | Godfather, Mafioso, Consort, Disguiser, etc. |
| Neutral Benign | Survivor, Amnesiac, Guardian Angel |
| Neutral Evil | Witch, Jester, Executioner |
| Neutral Killing | Serial Killer, Werewolf, Arsonist |

### Monetization Model

```
Revenue = Paid App + Future Expansion

Option A: Paid App ($1.99-2.99)
- No ads, premium feel
- 5K downloads = ~$7K revenue (after store cut)

Option B: Freemium
- Free: Core features
- Premium ($0.99): All roles, cloud sync
```

### Why Not #1?

- Smaller total market than HSR/Genshin
- Game is older, less growth potential
- No update cycle = no recurring engagement
- BUT: Zero competition = easier to dominate

### Development Breakdown

| Week | Deliverable |
|------|--------------|
| 1 | Night log UI, role templates |
| 2 | Day tracker, voting system |
| 3 | Will generator, export |
| 4 | Polish, testing, community building |

### Success Metrics

| Metric | Target (Month 3) | Target (Month 6) |
|--------|------------------|------------------|
| Downloads | 500 | 2,000 |
| Reviews | 20 | 100 |
| Rating | 4.5+ | 4.7+ |
| Monthly Revenue | $50 | $150 |

---

## #3: Epic Seven Companion (Character Planner)

### The Idea
A comprehensive character planner and team builder for Epic Seven players - track gear, builds, and team compositions.

### Why #3?

| Factor | Assessment |
|--------|------------|
| Competition | **Low** - Only 2-3 apps |
| Player Base | **5-10M MAU** - Hardcore players |
| Community | **Very Active** - Reddit, Discord, dedicated |
| Dev Time | **3-4 weeks** MVP |
| Revenue | **$150-400/mo** realistic |

### Problem It Solves

```
Epic Seven has 300+ characters, complex gear system, and team synergy requirements.
Players spend hours planning builds and compositions.

Solution: Character planner with gear optimization suggestions.
```

### Core Features (MVP)

| Feature | Description | Priority |
|---------|-------------|----------|
| **Character Database** | All 300+ heroes with stats | Must Have |
| **Build Planner** | Plan gear sets, stats, priorities | Must Have |
| **Team Builder** | Create team compositions | Must Have |
| **Bookmark/Favorites** | Save favorite builds | Should Have |
| **Search/Filter** | Find characters and builds | Should Have |

### Monetization Model

```
Revenue = Freemium + Affiliate

Free Tier:
- Character database
- Basic build planner
- Banner ads

Premium Tier ($4.99):
- Unlimited bookmarks
- Team builder
- No ads
- Priority updates
```

### Differentiation from Existing

| Competitor | Gap | Our Advantage |
|------------|-----|--------------|
| Epic Seven Wiki | No planner | Build planner + team builder |
| E7 Helper apps | Ugly UI | Modern Flutter UI |
| General tools | Not game-specific | Deep E7 integration |

### Development Breakdown

| Week | Deliverable |
|------|--------------|
| 1 | Character database (scraped/crowdsourced) |
| 2 | Build planner UI, stat calculator |
| 3 | Team builder, bookmarks |
| 4 | Polish, gear database expansion |

---

## #4: Multi-Gacha Tracker (Genshin + HSR + E7)

### The Idea
A unified wish tracker for players who play multiple gacha games - one app to track them all.

### Why #4?

| Factor | Assessment |
|--------|------------|
| Competition | **Low-Medium** - No unified tracker exists |
| Audience | **Cross-game players** - Common demographic |
| Dev Time | **4-6 weeks** (more games = more work) |
| Revenue | **$300-700/mo** realistic |
| Scalability | **High** - Easy to add games |

### Problem It Solves

```
Players who play multiple gacha games (Genshin + HSR is common) 
use separate apps for each. One app to rule them all.

Solution: One tracker, multiple games, unified experience.
```

### Core Features (MVP)

| Feature | Description | Priority |
|---------|-------------|----------|
| **Game Selection** | Add/remove tracked games | Must Have |
| **Per-Game Tracking** | Isolated data per game | Must Have |
| **Unified Stats** | Combined spending across games | Should Have |
| **Cross-Game Pity** | (For Hoyoverse games) | Should Have |

### Games to Support (MVP +1)

| Game | Priority | Data Available |
|------|----------|----------------|
| Honkai: Star Rail | MVP | Pull history, banners |
| Genshin Impact | MVP | Pull history, banners |
| Epic Seven | Post-MVP | Character database |

### Monetization Model

```
Revenue = Freemium + Premium

Free Tier:
- 1 game support
- Basic tracking
- Banner ads

Premium Tier ($4.99/month):
- Unlimited games
- Cloud sync
- No ads
- Advanced statistics

Year 1 Projection: $300-700/month average
```

### Why #4 Over #1?

| Factor | #1 (HSR Only) | #4 (Multi-Game) |
|--------|----------------|-----------------|
| Dev Time | 2-3 weeks | 4-6 weeks |
| Competition | Low | Low-Medium |
| User Value | Single game | Multiple games |
| Revenue | $200-500 | $300-700 |
| Maintenance | Per-game updates | Higher effort |

### Development Breakdown

| Week | Deliverable |
|------|--------------|
| 1 | App structure, HSR tracking |
| 2 | Genshin support, shared UI |
| 3 | Statistics dashboard |
| 4-6 | Polish, testing, E7 expansion |

---

## #5: Idle Game Calculator Suite

### The Idea
A calculator/planner for idle and incremental games - help players optimize progression in games like AFK Arena, Idle Heroes, and Merge Mansion.

### Why #5?

| Factor | Assessment |
|--------|------------|
| Competition | **Low** - Fragmented market |
| Genre Popularity | **Large** - Idle games are huge |
| Dev Time | **2-3 weeks** MVP |
| Revenue | **$100-300/mo** realistic |
| Expandability | **High** - Many games to support |

### Problem It Solves

```
Idle games have complex progression math: when to prestige, 
optimal resource allocation, time-to-completion calculations.

Solution: Calculators that crunch the numbers for optimal play.
```

### Games to Support (MVP Focus)

| Game | Popularity | Calculator Type |
|------|------------|----------------|
| **AFK Arena** | Very High | Idle rewards, prestige calculator |
| **Idle Heroes** | High | Hero tier, team planner |
| **Merge Mansion** | Medium | Merge optimization |

### Core Features (MVP)

| Feature | Description | Priority |
|---------|-------------|----------|
| **Game Selector** | Choose which idle game | Must Have |
| **Progression Calculator** | Time-to-level calculations | Must Have |
| **Prestige Planner** | When to reset for max gains | Must Have |
| **Resource Optimizer** | Best use of resources | Should Have |
| **Save Profiles** | Multiple accounts | Should Have |

### Monetization Model

```
Revenue = Ad-Supported + Paid Games

Free Tier:
- 1 game support
- Basic calculators
- Banner ads

Game Packs ($0.99-1.99 each):
- Unlock additional games
- No ads in that game section
- Premium calculators

Year 1 Projection: $100-300/month average
```

### Why Lower Priority?

- More fragmented than gacha
- Calculator apps have lower perceived value
- Users bounce faster than tracker apps
- BUT: Low effort, steady income

### Development Breakdown

| Week | Deliverable |
|------|--------------|
| 1 | App structure, AFK Arena calculator |
| 2 | Idle Heroes support |
| 3 | Polish, additional games |

---

## Summary Comparison

| Proposal | Dev Time | Competition | Revenue (Y1) | Scalability |
|---------|----------|-------------|--------------|-------------|
| **#1 HSR Tracker** | 2-3 weeks | Low | $200-500/mo | Medium |
| **#2 ToS Log** | 2-4 weeks | Zero | $50-200/mo | Low |
| **#3 E7 Planner** | 3-4 weeks | Low | $150-400/mo | Medium |
| **#4 Multi-Gacha** | 4-6 weeks | Low-Medium | $300-700/mo | High |
| **#5 Idle Calc** | 2-3 weeks | Low | $100-300/mo | Medium |

## Recommendation

### If Wanting Fastest First Revenue:
**Proposal #1 (HSR Tracker)** - Low competition, large audience, proven model

### If Wanting Lowest Effort:
**Proposal #5 (Idle Calculator)** - Simple calculators, quick build

### If Wanting Most Unique:
**Proposal #2 (Town of Salem)** - Zero competition, first-mover

### If Wanting Highest Scalability:
**Proposal #4 (Multi-Gacha)** - Can expand to all gacha games

---

## Next Steps

1. **Pick proposal** - Which resonates most?
2. **Detailed spec** - Figma wireframes, database schema
3. **Development plan** - Sprint breakdown
4. **Launch strategy** - Community building before launch

Which proposal should I spec out in detail?
