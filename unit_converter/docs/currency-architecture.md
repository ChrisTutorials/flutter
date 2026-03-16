# Currency Converter - Architecture and Design

## Documentation Navigation
- [Project Overview](readme.md)
- [Currency Converter Tests](currency-converter-tests.md)
- [Currency Offline Warning System](currency-offline-warning-system.md)
- [Currency Last Update & API Source](currency-last-update-and-api-source.md)

## Overview

The currency converter is a separate feature from the main unit converter that uses the Frankfurter API to provide live currency exchange rates. This document explains the architecture, design decisions, and integration patterns.

## API Integration

### Frankfurter API

- **Base URL**: `https://api.frankfurter.dev/v1`
- **Source**: Free API backed by institutional ECB data
- **Authentication**: None required
- **Rate Limits**: Unspecified (no rate limiting implemented in app)
- **Documentation**: https://api.frankfurter.dev/

### API Endpoints Used

1. **Get Currencies**: `GET /currencies`
   - Returns list of available currencies
   - Cached locally for offline access

2. **Get Exchange Rate**: `GET /latest?base={from}&symbols={to}`
   - Returns current exchange rate
   - Used for live conversions
   - Not cached (requires internet)

## Three-Tier Fallback System

The currency converter implements a robust three-tier fallback system for handling offline scenarios:

### Tier 1: Live API (Online)
- Fetches live exchange rates from `https://api.frankfurter.dev/v1`
- Returns real-time data
- Caches results for offline use
- No warning displayed to users

### Tier 2: Cached Data (Offline)
- If API fails, uses previously cached currencies
- Allows users to see currency list without internet
- Conversion still requires internet (no cached rates)
- Shows orange warning banner: "Using cached data - offline mode (Last updated: X min ago)"

### Tier 3: Default Currencies (Offline, No Cache)
- If no cache available, returns default currencies
- Provides basic functionality even on first run offline
- Defaults: USD, EUR, GBP, JPY, CAD, AUD
- Shows orange warning banner: "Using default currencies - offline mode, no cache available"

## Architecture Separation

### Why Currency is Separate

Currency conversion is architecturally separate from other unit conversions for several reasons:

1. **API Dependency**: Currency requires live API calls, other conversions use local math
2. **Rate Limiting Concerns**: Frankfurter API has unspecified rate limits
3. **Offline Behavior**: Currency has complex offline fallback system
4. **UI Requirements**: Currency needs additional context (rates, dates, warnings)

### Conversion Flow Comparison

#### Regular Unit Conversions
- Uses `ConversionData.convert()` method
- Pure mathematical calculations
- No network calls required
- Works offline
- Supported in search bar instant conversion

#### Currency Conversions
- Uses `CurrencyService.convert()` method
- Requires API call to Frankfurter
- 350ms debouncing to reduce API calls
- Offline mode with fallback system
- Not supported in search bar instant conversion

## Search Bar Integration

### Instant Conversion Exclusion

Currency conversion does **not** work with the home screen search bar's instant conversion feature. This is an intentional design decision.

### Why Currency is Excluded from Instant Search

1. **API Rate Limiting**
   - Frankfurter API has unspecified rate limits
   - No rate limiting is currently implemented in the app
   - Instant search would trigger API calls on every keystroke (even with debouncing)
   - Risk of hitting rate limits and getting banned

2. **Architecture Design**
   - Currency conversion requires live API calls to Frankfurter API
   - Other unit conversions use local math without API calls
   - Currency is handled separately in `CurrencyConverterScreen` with 350ms debouncing
   - Search instant conversion uses `ConversionData.convert()` which only supports local conversions

3. **User Experience Considerations**
   - Currency conversions need to show live rates with effective dates
   - Currency has offline mode with cached data and warnings
   - Currency conversion requires more UI context (rate details, last update, API source link)

### How Users Access Currency Conversion

Users must access currency conversion through the dedicated currency card on the home screen, not through the search bar. This ensures:

- API calls are only made when user explicitly uses the currency converter
- Proper debouncing (350ms) reduces API call frequency
- Users see full context (rates, last update, offline warnings)
- API rate limits are respected

### Future Enhancement Considerations

If you want to enable instant currency conversion in search, you must implement:

1. Proper rate limiting with exponential backoff
2. Aggressive caching of currency rates
3. Clear warnings when approaching rate limits
4. Fallback to cached/offline rates
5. Consider API costs and reliability implications

## Debouncing Strategy

### Currency Converter Screen
- **Debounce Delay**: 350ms
- **Purpose**: Reduce API calls while typing
- **Implementation**: Timer-based cancellation on new input

### Why 350ms?
- Fast enough for responsive UI
- Slow enough to reduce API calls significantly
- Balances user experience with API rate limit concerns

## Data Persistence

### SharedPreferences Keys
- `cached_currencies`: Stores currency list JSON
- `last_currency_update`: Stores ISO 8601 timestamp of last successful API fetch

### Cache Strategy
- Currencies cached indefinitely
- No automatic cache expiration
- Manual cache refresh not implemented
- Cache persists until app is uninstalled

## Error Handling

### API Errors
- Network errors: Fall back to cache or defaults
- Timeout errors: 10-second timeout, fall back to cache or defaults
- Malformed responses: Fall back to cache or defaults
- Rate limit errors: Not currently handled (would require implementation)

### Conversion Errors
- Same currency: No API call, returns original amount
- Invalid currency codes: Exception thrown, caught by UI
- Offline conversion: Exception thrown, UI shows error message

## Security Considerations

### API Security
- All API calls use HTTPS
- 10-second timeout prevents hanging
- No sensitive data is transmitted
- API is free and doesn't require authentication

### Data Privacy
- No personal data is collected
- Currency data is cached locally
- Cache is cleared when app is uninstalled
- No user tracking

## Performance Considerations

### API Rate Limiting
- frankfurter.dev has a rate limit (not specified in docs)
- No rate limiting implemented in the app
- Consider adding rate limiting for production use
- Debouncing reduces but doesn't eliminate rate limit risk

### Timeout Handling
- 10-second timeout prevents hanging
- Timeout is applied to both getCurrencies and convert
- Timeout is configurable via _timeout constant

## Future Enhancements

### Recommended Features

1. **Rate Limiting**
   - Implement rate limiting for API calls
   - Show warning when rate limit is approached
   - Implement exponential backoff for retries

2. **Cache Management**
   - Add cache expiration (e.g., 1 hour)
   - Show cache age to users
   - Allow users to clear cache
   - Manual refresh button

3. **Offline Conversion**
   - Cache exchange rates for offline use
   - Show last update timestamp prominently
   - Allow manual refresh when online

4. **More Currencies**
   - Add more default currencies
   - Allow users to favorite currencies
   - Show recently used currencies

5. **Historical Rates**
   - Show historical exchange rates
   - Display rate trends
   - Add charts for rate history

## References

- [Frankfurter API Documentation](https://api.frankfurter.dev/)
- [Currency Converter Tests](currency-converter-tests.md)
- [Currency Offline Warning System](currency-offline-warning-system.md)
- [Currency Last Update & API Source](currency-last-update-and-api-source.md)

