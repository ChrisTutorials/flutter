# Trading Card Collection App: Detailed Spec

**Date:** April 11, 2026  
**Version:** 1.0  
**Type:** Technical Specification

---

## Part 1: Database Schema

### Overview

```
Cloud: Firebase Firestore
Local: Hive (SQLite alternative)
Sync Strategy: Last-write-wins with conflict resolution
```

### Firestore Structure

```
┌─────────────────────────────────────────────────────────┐
│                        USERS                             │
├─────────────────────────────────────────────────────────┤
│ users/{uid}                                           │
│   - email: string                                     │
│   - displayName: string                               │
│   - createdAt: timestamp                              │
│   - subscriptionStatus: 'free' | 'pro' | 'lifetime'  │
│   - subscriptionExpiry: timestamp (nullable)          │
│   - preferences:                                      │
│     - defaultCondition: string                        │
│     - defaultCurrency: string                         │
│     - notifications: boolean                           │
│   - stats:                                            │
│     - totalCards: number                              │
│     - totalValue: number                              │
│     - collectionsCount: number                         │
│     - lastSync: timestamp                             │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    COLLECTIONS                          │
├─────────────────────────────────────────────────────────┤
│ users/{uid}/collections/{collectionId}                 │
│   - name: string                                       │
│   - type: 'pokemon' | 'magic' | 'sports' | 'other'  │
│   - createdAt: timestamp                              │
│   - updatedAt: timestamp                              │
│   - cardCount: number                                 │
│   - totalValue: number                                │
│   - coverImageUrl: string (nullable)                  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                       CARDS                              │
├─────────────────────────────────────────────────────────┤
│ users/{uid}/collections/{collectionId}/cards/{cardId} │
│   - cardDbId: string (from external API)              │
│   - name: string                                      │
│   - setCode: string                                   │
│   - setName: string                                   │
│   - cardNumber: string                                │
│   - rarity: string                                    │
│   - condition: 'M' | 'NM' | 'EX' | 'VG' | 'G' | 'P'│
│   - quantity: number                                   │
│   - buyPrice: number (nullable)                       │
│   - buyDate: timestamp (nullable)                     │
│   - sellPrice: number (nullable)                      │
│   - sellDate: timestamp (nullable)                    │
│   - isGraded: boolean                                 │
│   - gradingCompany: string (nullable)                  │
│   - gradingScore: string (nullable)                   │
│   - notes: string (nullable)                          │
│   - addedAt: timestamp                               │
│   - updatedAt: timestamp                              │
│   - imageUrl: string                                 │
│   - marketPrice: number                              │
│   - priceUpdatedAt: timestamp                         │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                      WANT LISTS                          │
├─────────────────────────────────────────────────────────┤
│ users/{uid}/wantLists/{listId}                        │
│   - name: string                                      │
│   - type: 'pokemon' | 'magic' | 'sports' | 'other'   │
│   - priority: number                                  │
│   - createdAt: timestamp                              │
│   - updatedAt: timestamp                              │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   WANT LIST ITEMS                        │
├─────────────────────────────────────────────────────────┤
│ users/{uid}/wantLists/{listId}/items/{itemId}         │
│   - cardDbId: string                                 │
│   - name: string                                      │
│   - setCode: string                                  │
│   - targetPrice: number (nullable)                   │
│   - maxPrice: number (nullable)                       │
│   - addedAt: timestamp                               │
│   - notes: string (nullable)                         │
└─────────────────────────────────────────────────────────┘
```

### Local Cache Schema (Hive)

```dart
// Hive Box: 'cardDatabase'
// Stores cached card data from APIs
@HiveType(typeId: 0)
class CachedCard {
  @HiveField(0)
  String id;                    // Pokemon TCG API ID
  
  @HiveField(1)
  String name;                  // "Charizard"
  
  @HiveField(2)
  String setCode;              // "base2"
  
  @HiveField(3)
  String setName;              // "Jungle"
  
  @HiveField(4)
  String cardNumber;           // "4/64"
  
  @HiveField(5)
  String rarity;               // "Rare Holo"
  
  @HiveField(6)
  String imageUrl;             // High-res image URL
  
  @HiveField(7)
  String smallImageUrl;        // Thumbnail URL
  
  @HiveField(8)
  double marketPrice;          // Latest market price
  
  @HiveField(9)
  double reverseHoloPrice;     // Reverse holo variant
  
  @HiveField(10)
  DateTime lastUpdated;        // When we fetched this
}

// Hive Box: 'userCollection'
// Local copy of user's collection (for offline)
@HiveType(typeId: 1)
class LocalCard {
  @HiveField(0)
  String localId;              // UUID for this entry
  
  @HiveField(1)
  String cardDbId;             // Link to CachedCard
  
  @HiveField(2)
  String collectionId;         // Which collection
  
  @HiveField(3)
  int quantity;
  
  @HiveField(4)
  String condition;
  
  @HiveField(5)
  double? buyPrice;
  
  @HiveField(6)
  DateTime? buyDate;
  
  @HiveField(7)
  String? notes;
  
  @HiveField(8)
  DateTime addedAt;
  
  @HiveField(9)
  DateTime updatedAt;
}

// Hive Box: 'prices'
// Cached prices (refreshed daily)
@HiveType(typeId: 2)
class CachedPrice {
  @HiveField(0)
  String cardDbId;
  
  @HiveField(1)
  double marketPrice;
  
  @HiveField(2)
  double? gradedPrice;          // For PSA/BGS
  
  @HiveField(3)
  DateTime fetchedAt;
  
  @HiveField(4)
  DateTime validUntil;         // Price expires
}
```

### Enum Definitions

```dart
enum CardCondition {
  M,    // Mint
  NM,   // Near Mint
  EX,   // Excellent
  VG,   // Very Good
  G,    // Good
  P,    // Poor
}

enum CollectionType {
  pokemon,
  magic,
  sports,
  other,
}

enum SubscriptionTier {
  free,
  pro,
  lifetime,
}
```

---

## Part 2: UI Wireframes

### Screen Flow

```
┌─────────────────────────────────────────────────────────┐
│                    APP ENTRY                             │
├─────────────────────────────────────────────────────────┤
│                                                             │
│    ┌─────────┐    ┌─────────┐    ┌─────────┐           │
│    │ Splash  │───▶│  Auth   │───▶│  Home   │           │
│    │ Screen  │    │ (Login) │    │         │           │
│    └─────────┘    └─────────┘    └────┬────┘           │
│                                      │                  │
│                                      ▼                  │
│    ┌──────────────────────────────────────────────────┐ │
│    │                    HOME TABS                      │ │
│    ├──────────────────────────────────────────────────┤ │
│    │  [Collection]  [Want List]  [Search]  [Profile] │ │
│    └──────────────────────────────────────────────────┘ │
│                          │                              │
│                          ▼                              │
└──────────────────────────┼──────────────────────────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
    ┌──────────┐     ┌──────────┐     ┌──────────┐
    │ Collection│     │Want List │     │  Search  │
    │  Detail  │     │  Detail  │     │ Results  │
    └────┬─────┘     └────┬─────┘     └────┬─────┘
         │                │                │
         ▼                ▼                ▼
    ┌──────────┐     ┌──────────┐     ┌──────────┐
    │  Card    │     │  Card    │     │  Card    │
    │  Detail  │     │  Detail  │     │  Detail  │
    └──────────┘     └──────────┘     └──────────┘
```

### Screen 1: Splash Screen

```
┌─────────────────────────────────────┐
│                                      │
│                                      │
│                                      │
│           ┌─────────────┐            │
│           │             │            │
│           │   🃏        │            │
│           │  CollectR   │            │
│           │             │            │
│           └─────────────┘            │
│                                      │
│         Your Card Collection          │
│                                      │
│                                      │
│          ◐◐◐◐◐◐◐◐◐◐◐◐  loading      │
│                                      │
└─────────────────────────────────────┘
```

### Screen 2: Home (Collection Tab)

```
┌─────────────────────────────────────┐
│  CollectR              [Profile] 👤│
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│
│  │ 🔍 Search cards...              ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌──────┐ ┌──────┐ ┌──────┐       │
│  │      │ │      │ │      │       │
│  │ 🃏   │ │ 🃏   │ │ 🃏   │       │
│  │      │ │      │ │      │       │
│  ├──────┤ ├──────┤ ├──────┤       │
│  │ Base │ │Jungle│ │ Fossil│      │
│  │ 45   │ │ 12   │ │ 8     │      │
│  └──────┘ └──────┘ └──────┘       │
│                                      │
│  ┌─────────────────────────────────┐│
│  │ 📊 Collection Value              ││
│  │ $4,521.35                      ││
│  │ ↑ 2.3% this month              ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │ 🃏 Pokemon TCG          See All ││
│  ├─────────────────────────────────┤│
│  │ ┌────┐ ┌────┐ ┌────┐ ┌────┐    ││
│  │ │Char│ │Blas│ │Venu│ │Pi │    ││
│  │ │izard│ │toise│ │saur│ │kachu│    ││
│  │ └────┘ └────┘ └────┘ └────┘    ││
│  │ ┌────┐ ┌────┐ ┌────┐ ┌────┐    ││
│  │ │Mew │ │Eeve│ │Snor│ │Gengar│    ││
│  │ │two │ │lution│ │lax │ │    │    ││
│  │ └────┘ └────┘ └────┘ └────┘    ││
│  └─────────────────────────────────┘│
│                                      │
│  [Collection] [Want List] [Search] [Profile]│
└─────────────────────────────────────┘
```

### Screen 3: Collection Detail (Grid View)

```
┌─────────────────────────────────────┐
│ ← Pokemon TCG              [⋮ More]│
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│
│  │ Total: 347 cards  │  Value: $2,134 ││
│  └─────────────────────────────────┘│
│                                      │
│  [Grid] [List] [Set Progress]  Sort ▼│
│                                      │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐│
│  │NM  │ │EX  │ │NM  │ │VG  │ │NM  ││
│  │    │ │    │ │    │ │    │ │    ││
│  │ 🃏  │ │ 🃏  │ │ 🃏  │ │ 🃏  │ │ 🃏  ││
│  │    │ │    │ │    │ │    │ │    ││
│  │Char│ │Blas│ │Venu│ │Mew │ │Gyar││
│  │$45 │ │$12 │ │$28 │ │$89 │ │$15 ││
│  └────┘ └────┘ └────┘ └────┘ └────┘│
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐│
│  │NM  │ │NM  │ │EX  │ │NM  │ │NM  ││
│  │    │ │    │ │    │ │    │ │    ││
│  │Pika│ │Mew │ │Zard│ │Aqua│ │Vulp││
│  │$34 │ │$67 │ │$12 │ │$8  │ │$5  ││
│  └────┘ └────┘ └────┘ └────┘ └────┘│
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐│
│  │NM  │ │EX  │ │NM  │ │NM  │ │NM  ││
│  │Lug │ │ arti│ │Mol│ │Tau │ │Arti││
│  │$23 │ │$45 │ │$9  │ │$11 │ │$34 ││
│  └────┘ └────┘ └────┘ └────┘ └────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │        [+ Add Card]              ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

### Screen 4: Add Card (Search)

```
┌─────────────────────────────────────┐
│ ← Add Card                          │
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│
│  │ 🔍 Search by name or scan...    ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │ 📷 Scan Barcode                  ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │      📷                          ││
│  │   Point camera at               ││
│  │   card barcode                  ││
│  │   (Back of card)                ││
│  └─────────────────────────────────┘│
│                                      │
│  ─── OR Choose Set ───              │
│                                      │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐│
│  │  Base   │ │ Jungle  │ │ Fossil  ││
│  │  Set    │ │  Set    │ │  Set    ││
│  └─────────┘ └─────────┘ └─────────┘│
│  ┌─────────┐ ┌─────────┐ ┌─────────┐│
│  │  Neo    │ │  Gym    │ │  Promo  ││
│  │ Genesis │ │  Sets   │ │  Cards  ││
│  └─────────┘ └─────────┘ └─────────┘│
│                                      │
│  ─── Recent Cards ───               │
│                                      │
│  ┌─────────────────────────────────┐│
│  │ Charizard      │  $45.00   NM  ││
│  │ Jungle/4       │  [ADD]         ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ Blastoise     │  $12.00   EX   ││
│  │ Jungle/2      │  [ADD]         ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

### Screen 5: Card Detail (Edit)

```
┌─────────────────────────────────────┐
│ ← Card Details          [💾 Save]  │
├─────────────────────────────────────┤
│                                      │
│         ┌─────────────────┐          │
│         │                 │          │
│         │                 │          │
│         │   [Card Image]   │          │
│         │                 │          │
│         │                 │          │
│         └─────────────────┘          │
│                                      │
│         Charizard                    │
│         Jungle Set • #4/64           │
│         Rare Holo                     │
│                                      │
│  ┌─────────────────────────────────┐│
│  │ Market Price                    ││
│  │ $45.00         ↑ $2.30 (5.4%)  ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │ Condition              [NM ▼]   ││
│  ├─────────────────────────────────┤│
│  │ Quantity                  [1]  ││
│  ├─────────────────────────────────┤│
│  │ Buy Price               [$45]  ││
│  ├─────────────────────────────────┤│
│  │ Buy Date              [Today] ││
│  ├─────────────────────────────────┤│
│  │ Graded?                   [No] ││
│  ├─────────────────────────────────┤│
│  │ Notes                           ││
│  │ [Pulled at locals...         ] ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │ Collection: [Pokemon TCG ▼]     ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │        [Add to Collection]      ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

### Screen 6: Want List

```
┌─────────────────────────────────────┐
│  Want Lists                   [+]  │
├─────────────────────────────────────┤
│                                      │
│  ┌─────────────────────────────────┐│
│  │ ⭐ High Priority                  ││
│  │   12 cards  │  ~$450 needed      ││
│  │   3 alerts active                 ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │ 🔥 Chase Cards                   ││
│  │   24 cards  │  ~$890 needed     ││
│  │   5 alerts active               ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │ 📋 General                       ││
│  │   56 cards  │  ~$1,200 needed   ││
│  │   0 alerts active                ││
│  └─────────────────────────────────┘│
│                                      │
│  ─── All Want List Items ───       │
│                                      │
│  ┌─────────────────────────────────┐│
│  │ 🔔 PSA 10 Charizard              ││
│  │    Target: $500 | Market: $523  ││
│  │    [Remove]                      ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ 🔔 1st Edition Blastoise         ││
│  │    Target: $300 | Market: $345  ││
│  │    [Remove]                      ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │    Base Set Complete Set         ││
│  │    12/102 cards | 88 to go     ││
│  │    ████████░░░░░░░░░ 12%      ││
│  └─────────────────────────────────┘│
│                                      │
│  [Collection] [Want List] [Search] [Profile]│
└─────────────────────────────────────┘
```

### Screen 7: Card Detail (Want List)

```
┌─────────────────────────────────────┐
│ ← Add to Want List                 │
├─────────────────────────────────────┤
│                                      │
│         ┌─────────────────┐          │
│         │                 │          │
│         │   [Card Image]   │          │
│         │                 │          │
│         └─────────────────┘          │
│                                      │
│         Charizard                    │
│         Jungle Set • #4/64           │
│         Rare Holo                     │
│         Current: $45.00              │
│                                      │
│  ┌─────────────────────────────────┐│
│  │ Target Price          [$50.00] ││
│  ├─────────────────────────────────┤│
│  │ Alert when below:     [✓]       ││
│  │   $45.00 (current price)        ││
│  ├─────────────────────────────────┤│
│  │ Priority               [High ▼]││
│  ├─────────────────────────────────┤│
│  │ Notes                           ││
│  │ [Will buy when PSA 10 drops...] ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │ Add to:                          ││
│  │ ○ High Priority                  ││
│  │ ○ Chase Cards                    ││
│  │ ○ Create New List...             ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │      [Add to Want List]          ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

### Screen 8: Set Progress

```
┌─────────────────────────────────────┐
│ ← Jungle Set Progress               │
├─────────────────────────────────────┤
│                                      │
│  ┌─────────────────────────────────┐│
│  │ ████████████████░░░░░░░░░░░░░  ││
│  │                                  ││
│  │        12 / 64 Cards             ││
│  │        $156 / $890 Value         ││
│  │                                  ││
│  │   Missing: 52 cards ($734)       ││
│  └─────────────────────────────────┘│
│                                      │
│  [All] [Missing] [Owned] [Affordable]│
│                                      │
│  ┌─────────────────────────────────┐│
│  │ ✅ Charizard         NM   $45  ││
│  │    4/64 • Rare Holo            ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ ✅ Blastoise        EX   $12   ││
│  │    2/64 • Rare Holo            ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ ⬜ Nidoqueen       NM   $8     ││
│  │    29/64 • Rare Holo           ││
│  │    ▼ $6.50 avg                 ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ ⬜ Nidoking         NM   $7     ││
│  │    34/64 • Rare Holo           ││
│  │    ▼ $5.00 avg                 ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ ⬜ Pidgeotto        NM   $1.50 ││
│  │    18/64 • Common              ││
│  │    ▼ $0.75 avg                 ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │      [Add Missing Cards]        ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

### Screen 9: Search Results

```
┌─────────────────────────────────────┐
│ ← Search: "Charizard"         [✕]  │
├─────────────────────────────────────┤
│                                      │
│  Found 847 results • 2.3s           │
│                                      │
│  ─── Pokemon TCG (124) ───         │
│                                      │
│  ┌─────────────────────────────────┐│
│  │ 🃏 Charizard                     ││
│  │ Base Set • #4/64 • Rare Holo   ││
│  │ Market: $45.00 | NM             ││
│  │                        [+] [♥] ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ 🃏 Charizard                     ││
│  │ Base Set 2 • #4/95 • Rare Holo││
│  │ Market: $12.00 | NM             ││
│  │                        [+] [♥] ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ 🃏 Charizard                     ││
│  │ EX Box Topper • #TB4            ││
│  │ Market: $8.00 | NM              ││
│  │                        [+] [♥] ││
│  └─────────────────────────────────┘│
│                                      │
│  ─── Magic: The Gathering (423) ───│
│  ┌─────────────────────────────────┐│
│  │ ⚡ Charizard (MTG)              ││
│  │ Universes Beyond • #1/20       ││
│  │ Market: $15.00 | NM             ││
│  │                    [Switch ▼] ││
│  └─────────────────────────────────┘│
│                                      │
│  ─── Sports Cards (300) ───        │
│  (Upgrade to Pro to search sports)  │
│                                      │
│  [Collection] [Want List] [Search] [Profile]│
└─────────────────────────────────────┘
```

### Screen 10: Profile / Settings

```
┌─────────────────────────────────────┐
│  Profile                            │
├─────────────────────────────────────┤
│                                      │
│         ┌───────────┐               │
│         │    👤     │               │
│         └───────────┘               │
│         collector123                 │
│         collector@email.com          │
│                                      │
│  ┌─────────────────────────────────┐│
│  │ 🎴 Pro Member                    ││
│  │    4.99/month • Renews Apr 15   ││
│  │    [Manage Subscription]         ││
│  └─────────────────────────────────┘│
│                                      │
│  ─── Stats ───                      │
│                                      │
│  ┌─────────────────────────────────┐│
│  │ Total Cards          1,247      ││
│  ├─────────────────────────────────┤│
│  │ Collection Value     $12,456    ││
│  ├─────────────────────────────────┤│
│  │ Monthly Change       +$234 (2%) ││
│  ├─────────────────────────────────┤│
│  │ Want List Cards      92         ││
│  ├─────────────────────────────────┤│
│  │ Member Since         Jan 2026   ││
│  └─────────────────────────────────┘│
│                                      │
│  ─── Settings ───                   │
│                                      │
│  ┌─────────────────────────────────┐│
│  │ 📱 Notifications            [ON] ││
│  ├─────────────────────────────────┤│
│  │ 🔔 Price Alerts             [ON] ││
│  ├─────────────────────────────────┤│
│  │ ☁️ Cloud Sync                [ON]││
│  ├─────────────────────────────────┤│
│  │ 🌙 Dark Mode               [AUTO]││
│  ├─────────────────────────────────┤│
│  │ 💱 Default Currency     [USD ▼] ││
│  ├─────────────────────────────────┤│
│  │ 🏷️ Default Condition     [NM ▼] ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │ 📊 Manage Collections            ││
│  ├─────────────────────────────────┤│
│  │ 💾 Export Data (CSV)            ││
│  ├─────────────────────────────────┤│
│  │ 💳 Upgrade to Pro                ││
│  ├─────────────────────────────────┤│
│  │ ❓ Help & Support                ││
│  ├─────────────────────────────────┤│
│  │ 📜 Privacy Policy                 ││
│  ├─────────────────────────────────┤│
│  │ 🚪 Sign Out                       ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

### Screen 11: Upgrade to Pro

```
┌─────────────────────────────────────┐
│ ←                                  │
├─────────────────────────────────────┤
│                                      │
│         ┌───────────┐               │
│         │  ⭐ PRO    │               │
│         │  CollectR  │               │
│         └───────────┘               │
│                                      │
│      Unlock your collection          │
│                                      │
│  ┌─────────────────────────────────┐│
│  │ ✅ UNLIMITED Cards               ││
│  │    No 500 card limit            ││
│  ├─────────────────────────────────┤│
│  │ ✅ NO ADS                        ││
│  │    Enjoy without interruption    ││
│  ├─────────────────────────────────┤│
│  │ ✅ CLOUD SYNC                    ││
│  │    Access from any device        ││
│  ├─────────────────────────────────┤│
│  │ ✅ REAL-TIME PRICES              ││
│  │    Always up-to-date            ││
│  ├─────────────────────────────────┤│
│  │ ✅ PRICE ALERTS                  ││
│  │    Get notified on price drops   ││
│  ├─────────────────────────────────┤│
│  │ ✅ UNLIMITED WANT LISTS          ││
│  ├─────────────────────────────────┤│
│  │ ✅ EXPORT DATA                   ││
│  │    CSV, JSON backup              ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │  Pro Monthly                    ││
│  │  $4.99/month                     ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │  Pro Yearly              SAVE 33%││
│  │  $39.99/year                     ││
│  │  (Just $3.33/month!)            ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │  Pro Lifetime                   ││
│  │  $79.99 one-time                ││
│  │  (Never pay again!)            ││
│  └─────────────────────────────────┘│
│                                      │
│     Already subscribed? [Restore]    │
│                                      │
└─────────────────────────────────────┘
```

---

## Part 3: Component Library

### Card Grid Item

```
┌─────────────────┐
│ ┌─────────────┐ │
│ │             │ │
│ │  [Card Img] │ │
│ │             │ │
│ └─────────────┘ │
│  NM             │  ← Condition badge
│  Charizard      │  ← Name
│  $45.00         │  ← Price
│       ×2        │  ← Quantity (if > 1)
└─────────────────┘
```

States:
- Default: Normal display
- Selected: Blue border (for bulk actions)
- Long-press: Context menu
- Loading: Shimmer placeholder

### Card List Item

```
┌─────────────────────────────────────┐
│ ┌────┐                             │
│ │    │  Charizard                   │
│ │ 🃏  │  Jungle Set • #4/64         │
│ │    │  NM • ×1                      │
│ └────┘              $45.00          │
└─────────────────────────────────────┘
```

### Collection Summary Card

```
┌─────────────────────────────────────┐
│  🃏  Pokemon TCG           See All │
├─────────────────────────────────────┤
│ ┌────┐ ┌────┐ ┌────┐ ┌────┐       │
│ │ 🃏  │ │ 🃏  │ │ 🃏  │ │ 🃏  │ ... │
│ └────┘ └────┘ └────┘ └────┘       │
│ 45 cards        $2,134 total       │
└─────────────────────────────────────┘
```

### Price Change Indicator

```
↑ $2.30 (5.4%)  ← Green, price up
↓ $1.50 (3.2%)  ← Red, price down
→ $0.00 (0.0%)  ← Gray, no change
```

### Condition Badge

```
┌────┐
│ NM │  ← Green for M, NM, EX
│ VG │  ← Yellow for VG
│ G  │  ← Orange for G
│ P  │  ← Red for P
└────┘
```

### Set Progress Bar

```
┌─────────────────────────────────────┐
│ ██████████████░░░░░░░░░░░░░░░░░░░░  │
│ 12/64 cards (19%)           $156    │
└─────────────────────────────────────┘
```

### Empty States

```
Collection Empty:
┌─────────────────────────────────────┐
│                                      │
│              📦                      │
│                                      │
│      Your collection is empty        │
│                                      │
│    Start by adding your first card    │
│                                      │
│      [+ Add Your First Card]         │
│                                      │
└─────────────────────────────────────┘

Search No Results:
┌─────────────────────────────────────┐
│                                      │
│              🔍                      │
│                                      │
│      No cards found                  │
│                                      │
│    Try a different search term       │
│                                      │
└─────────────────────────────────────┘
```

---

## Part 4: Navigation Structure

### Bottom Tab Navigation

```dart
enum HomeTab {
  collection,
  wantList,
  search,
  profile,
}
```

### Stack Navigation

```
Root
├── AuthStack
│   ├── SplashScreen
│   ├── LoginScreen
│   └── SignUpScreen
│
├── HomeStack (with BottomNav)
│   ├── CollectionTab
│   │   ├── CollectionListScreen
│   │   ├── CollectionDetailScreen
│   │   ├── CardDetailScreen
│   │   ├── AddCardScreen
│   │   └── SetProgressScreen
│   │
│   ├── WantListTab
│   │   ├── WantListScreen
│   │   ├── WantListDetailScreen
│   │   ├── AddToWantListScreen
│   │   └── SetProgressScreen (shared)
│   │
│   ├── SearchTab
│   │   ├── SearchScreen
│   │   ├── SearchResultsScreen
│   │   └── CardDetailScreen (shared)
│   │
│   └── ProfileTab
│       ├── ProfileScreen
│       ├── SettingsScreen
│       ├── ManageCollectionsScreen
│       └── UpgradeScreen
│
└── ModalStack
    ├── AddCardModal
    ├── FilterModal
    ├── SortModal
    └── SubscriptionModal
```

---

## Part 5: State Management

### Riverpod Providers

```dart
// Auth
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>

// User
final userProvider = StreamProvider<User>

// Collections
final collectionsProvider = StreamProvider<List<Collection>>
final currentCollectionProvider = StateProvider<Collection?>
final collectionCardsProvider = StreamProvider.family<List<Card>, String>

// Want Lists
final wantListsProvider = StreamProvider<List<WantList>>
final wantListItemsProvider = StreamProvider.family<List<WantItem>, String>

// Search
final searchQueryProvider = StateProvider<String>
final searchResultsProvider = FutureProvider<List<Card>>

// Prices
final priceCacheProvider = FutureProvider.family<CardPrice, String>

// UI State
final selectedTabProvider = StateProvider<HomeTab>
final selectedCardsProvider = StateProvider<Set<String>>
final isSelectionModeProvider = StateProvider<bool>

// Subscription
final subscriptionProvider = StreamProvider<Subscription>
final isProProvider = Provider<bool>
```

---

## Part 6: API Contracts

### Pokemon TCG API

```dart
// GET /v1/cards?name=Charizard
class PokemonApiResponse {
  List<PokemonCard> data;
  int page;
  int pageSize;
  int totalCount;
  bool success;
}

class PokemonCard {
  String id;
  String name;
  String? imageUrl;
  String? imageUrlHiRes;
  String setCode;
  String setName;
  String number;
  String rarity;
  List<String> types;
  String? hp;
  List<String> attacks;
  // ... other fields
}

// Price endpoint (separate)
class PriceResponse {
  String cardId;
  double marketPrice;
  double reverseHoloPrice;
  DateTime lastUpdated;
}
```

### Internal API (Cloud Functions)

```dart
// POST /getCardPrice
// Request: { cardDbId: string }
// Response: { price: number, updatedAt: timestamp }

// POST /checkWantListAlerts
// Request: { userId: string }
// Response: { alerts: [{ cardId, currentPrice, targetPrice }] }

// POST /createCheckoutSession
// Request: { tier: 'monthly' | 'yearly' | 'lifetime' }
// Response: { sessionUrl: string } // Stripe URL
```

---

## Part 7: Error Handling

### Error States

| Error | User Message | Action |
|-------|--------------|--------|
| Network Error | "Can't connect. Check your internet." | Retry button |
| API Rate Limit | "Too many requests. Try again in a minute." | Auto-retry |
| Card Not Found | "Card not found. Try a different search." | Suggest alternatives |
| Price Unavailable | "Price data unavailable" | Show "—" |
| Sync Failed | "Couldn't save. Changes saved locally." | Manual sync button |
| Auth Expired | "Please sign in again." | Redirect to login |

### Offline Handling

```
1. Show cached data immediately
2. Display "Offline" indicator in app bar
3. Queue mutations for sync when online
4. Conflict resolution: Last-write-wins with timestamp
5. Show toast: "You're offline. Changes will sync when connected."
```

---

**Document Version:** 1.0  
**Status:** Ready for Development
