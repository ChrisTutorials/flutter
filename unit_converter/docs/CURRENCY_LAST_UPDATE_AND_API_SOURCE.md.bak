# Currency Converter - Last Update Time & API Source Link Implementation

## Documentation Navigation
- [Project Overview](README.md)
- [API Documentation](API.md)
- [Currency Converter Tests](CURRENCY_CONVERTER_TESTS.md)

## Overview

Enhanced the currency converter to show the last update date/time when offline and added a clickable API source link that's always visible.

## Implementation Summary

### 1. Last Update Timestamp Tracking ✅

#### Service Enhancements
- Added `_lastUpdateKey` constant for storing timestamp
- Added `getLastUpdate()` method to retrieve the last update timestamp
- Modified `getCurrenciesWithMetadata()` to save timestamp on successful API fetch
- Added `lastUpdate` field to `CurrenciesResult` class
- Implemented `_formatDateTime()` method for user-friendly time display

#### Time Formatting
The `_formatDateTime()` method provides human-readable time formats:
- **Just now**: Less than 1 minute ago
- **X min ago**: Less than 1 hour ago
- **X hr ago**: Less than 24 hours ago
- **X day(s) ago**: Less than 7 days ago
- **DD MMM YYYY**: For older updates

### 2. API Source Link ✅

#### UI Enhancement
- Added clickable link to `https://api.frankfurter.dev`
- Link appears below the Frankfurter API description
- Opens in external browser
- Styled with primary color and underline
- Includes link icon for visual clarity

#### Dependencies
- Added `url_launcher: ^6.3.0` to pubspec.yaml
- Imported `package:url_launcher/url_launcher.dart` in main.dart

### 3. Enhanced Warning Messages ✅

#### Offline Warning with Last Update
When using cached data, the warning message now includes:
- "Using cached data - offline mode (Last updated: X min ago)"

#### Example Messages
- **With Cache**: "Using cached data - offline mode (Last updated: 5 min ago)"
- **No Cache**: "Using default currencies - offline mode, no cache available"
- **Online**: No warning (live data)

### 4. Comprehensive Test Coverage ✅

#### New Test Groups Added

1. **Last Update Timestamp Tests** (4 tests)
   - Return null when no last update exists
   - Save timestamp when fetching from API
   - Update timestamp on subsequent API fetches
   - Preserve timestamp when using cached data

2. **API Source URL Tests** (3 tests)
   - Verify API source URL constant
   - Verify correct API base URL for requests
   - Verify correct API base URL for conversion requests

3. **DateTime Formatting Tests** (5 tests)
   - Format "Just now" for recent updates
   - Format minutes ago for updates within an hour
   - Format hours ago for updates within a day
   - Format days ago for updates within a week
   - Format actual date for updates older than a week

4. **Updated Warning Behavior Tests** (2 new tests)
   - Include last update in warning message when offline
   - Save and retrieve last update timestamp

5. **Updated Integration Tests** (1 new test)
   - Track last update timestamp across complete workflow

**Total New Tests: 15**
**Updated Tests: 2**
**Total Test Count: 38 tests**

## User Experience

### Online Mode
- Live currency conversion with real-time rates
- No warning banner displayed
- API source link visible and clickable
- Timestamp saved in background

### Offline Mode (With Cache)
- Orange warning banner displayed at top
- Message: "Using cached data - offline mode (Last updated: 5 min ago)"
- Cached currency list available
- Conversions fail with error message
- API source link still visible and clickable

### Offline Mode (No Cache)
- Orange warning banner displayed at top
- Message: "Using default currencies - offline mode, no cache available"
- Limited currency list (6 default currencies)
- Conversions fail with error message
- API source link still visible and clickable

## Technical Details

### Data Storage
- Last update timestamp stored in SharedPreferences
- Key: `last_currency_update`
- Format: ISO 8601 string (UTC)
- Persistence: Until app is uninstalled

### API Source
- URL: `https://api.frankfurter.dev`
- Opens in external browser
- Uses `LaunchMode.externalApplication`
- Fallback handling if browser not available

### Time Display Logic
```dart
String _formatDateTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hr ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else {
    return '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}';
  }
}
```

## Files Modified/Created

### Modified Files

1. **lib/services/currency_service.dart**
   - Added `_apiSourceUrl` constant
   - Added `_lastUpdateKey` constant
   - Added `lastUpdate` field to `CurrenciesResult`
   - Added `getLastUpdate()` method
   - Updated `getCurrenciesWithMetadata()` to save and return timestamp
   - Added `_formatDateTime()` method
   - Added `_getMonthName()` method

2. **lib/main.dart**
   - Added `url_launcher` import
   - Added `_isOffline` state variable
   - Added `_offlineWarning` state variable
   - Updated `_loadCurrencies()` to use metadata API
   - Added offline warning banner to UI
   - Added API source link to UI

3. **pubspec.yaml**
   - Added `url_launcher: ^6.3.0` dependency

4. **test/currency_service_test.dart**
   - Added 15 new tests
   - Updated 2 existing tests
   - Total: 38 comprehensive tests

### Created Files

1. **docs/CURRENCY_LAST_UPDATE_AND_API_SOURCE.md** (this file)
   - Complete implementation documentation
   - Test coverage details
   - User experience guide

## Running the Tests

### Run All Tests
```bash
flutter test
```

### Run Currency Service Tests Only
```bash
flutter test test/currency_service_test.dart
```

### Run Specific Test Groups
```bash
# Last update timestamp tests
flutter test --name "Last Update Timestamp"

# API source URL tests
flutter test --name "API Source URL"

# DateTime formatting tests
flutter test --name "DateTime Formatting"
```

### Run with Coverage
```bash
flutter test --coverage
```

## Test Coverage Summary

### Complete Test Coverage (38 Tests)

1. **API Functionality** (5 tests)
   - Fetch currencies successfully
   - Convert currency successfully
   - Same currency conversion
   - Currency caching
   - Cache verification

2. **Offline Behavior** (3 tests)
   - Use cached currencies when API fails
   - Use cached currencies when network unavailable
   - Return default currencies when no cache and API fails

3. **Timeout Handling** (2 tests)
   - Handle API timeout gracefully
   - Timeout after 10 seconds on slow API

4. **Warning Behavior** (7 tests)
   - Indicate offline mode when using cached data
   - Indicate offline mode when using default currencies
   - Indicate online mode when using live API
   - Save and retrieve last update timestamp
   - Include last update in warning message when offline
   - Handle malformed API response gracefully
   - Handle empty API response

5. **Last Update Timestamp** (4 tests)
   - Return null when no last update exists
   - Save timestamp when fetching from API
   - Update timestamp on subsequent API fetches
   - Preserve timestamp when using cached data

6. **API Source URL** (3 tests)
   - Verify API source URL constant
   - Verify correct API base URL for requests
   - Verify correct API base URL for conversion requests

7. **DateTime Formatting** (5 tests)
   - Format "Just now" for recent updates
   - Format minutes ago for updates within an hour
   - Format hours ago for updates within a day
   - Format days ago for updates within a week
   - Format actual date for updates older than a week

8. **Edge Cases** (4 tests)
   - Zero amount conversion
   - Negative amount conversion
   - Very large amount conversion
   - Multiple currency symbols

9. **Integration Tests** (5 tests)
   - Complete workflow: fetch → cache → offline → restore
   - Conversion workflow: online → offline → online
   - Track offline status across complete workflow with metadata
   - First run offline scenario with defaults and warning
   - Track last update timestamp across complete workflow

## Search Bar Integration

Currency conversion does **not** work with the home screen search bar's instant conversion feature. For detailed explanation of why this is an intentional design decision, see [CURRENCY_ARCHITECTURE.md](CURRENCY_ARCHITECTURE.md#search-bar-integration).

## Benefits

### For Users
- Clear visibility into when data was last updated
- Easy access to API documentation via clickable link
- Better understanding of data freshness
- Improved trust in the application

### For Developers
- Comprehensive test coverage for new features
- Easy to debug timestamp issues
- Clear API source attribution
- Well-documented behavior

### For Production
- Transparent data source attribution
- User-friendly time display
- Robust timestamp tracking
- No breaking changes to existing functionality

## Future Enhancements

### Recommended Features
1. **Manual Refresh Button**
   - Allow users to manually refresh rates
   - Show "Last updated: Just now" after refresh
   - Pull-to-refresh functionality

2. **Cache Expiration**
   - Add cache expiration (e.g., 1 hour)
   - Show warning when cache is stale
   - Auto-refresh when cache expires

3. **Enhanced Time Display**
   - Show exact time on long press
   - Show timezone information
   - Support different time formats

4. **API Status Indicator**
   - Show API health status
   - Display rate limit information
   - Show last successful request time

## Conclusion

The currency converter now provides:
- ✅ Last update date/time display when offline
- ✅ Clickable API source link (always visible)
- ✅ Comprehensive test coverage (38 tests)
- ✅ User-friendly time formatting
- ✅ Robust timestamp tracking
- ✅ Transparent data source attribution

The implementation is production-ready and provides users with excellent visibility into data freshness and source! 🎉
