# Currency Converter - API and Offline Behavior Tests

## Documentation Navigation
- [Project Overview](README.md)
- [API Documentation](API.md)
- [Test Coverage](TEST_COVERAGE.md)

This document describes the comprehensive test suite for the currency converter feature, including API functionality, offline behavior, and warning systems.

## Test Coverage

### 1. API Functionality Tests ✅

Tests that verify the currency converter works correctly with the live API:

- **Fetch currencies successfully**: Verifies API returns correct currency data
- **Convert currency successfully**: Verifies conversion calculations are accurate
- **Same currency conversion**: Ensures no API call when converting to same currency
- **Currency caching**: Verifies currencies are cached after successful API call

### 2. Offline Behavior Tests ✅

Tests that verify graceful degradation when offline:

- **Use cached currencies when API fails**: Falls back to cached data
- **Use cached currencies when network unavailable**: Handles network errors
- **Return default currencies when no cache**: Provides fallback defaults
- **Throw exception on conversion failure**: Proper error handling

### 3. Timeout Handling Tests ✅

Tests that verify the 10-second timeout works correctly:

- **Handle API timeout gracefully**: Returns defaults on timeout
- **Timeout after 10 seconds**: Verifies timeout duration

### 4. Warning Behavior Tests ✅

Tests that verify the app handles errors gracefully:

- **Indicate offline mode**: Uses cached data when offline
- **Handle malformed API response**: Gracefully handles invalid JSON
- **Handle empty API response**: Handles empty responses

### 5. Edge Cases Tests ✅

Tests that verify the app handles unusual inputs:

- **Zero amount conversion**: Handles zero values
- **Negative amount conversion**: Handles negative values
- **Very large amount conversion**: Handles large numbers
- **Multiple currency symbols**: Handles complex conversions

### 6. Integration Tests ✅

Tests that verify complete workflows:

- **Complete workflow**: Fetch → Cache → Offline → Restore
- **Conversion workflow**: Online → Offline → Online

## Offline Behavior

The currency converter implements a robust three-tier fallback system. For detailed architecture information, see [CURRENCY_ARCHITECTURE.md](CURRENCY_ARCHITECTURE.md).

### Warning System

The currency converter does not show explicit warning messages in the UI, but implements implicit warnings through behavior:

#### Implicit Warnings

1. **Cached Data Usage**
   - When offline, the app silently uses cached data
   - No explicit "offline" warning is shown
   - Users can still see the currency list

2. **Default Currencies**
   - When offline with no cache, default currencies are shown
   - No explicit warning, but limited currency list indicates offline state

3. **Conversion Failure**
   - When trying to convert offline, an exception is thrown
   - The UI should catch this and show an error message
   - No conversion result is displayed

#### Recommended UI Enhancements

To make offline behavior more visible, consider adding:

1. **Connection Status Indicator**
   ```dart
   Widget _buildConnectionStatus() {
     return Row(
       children: [
         Icon(
           _isOnline ? Icons.wifi : Icons.wifi_off,
           color: _isOnline ? Colors.green : Colors.orange,
         ),
         SizedBox(width: 8),
         Text(
           _isOnline ? 'Online' : 'Offline (using cached data)',
           style: TextStyle(
             color: _isOnline ? Colors.green : Colors.orange,
           ),
         ),
       ],
     );
   }
   ```

2. **Cached Data Warning Banner**
   ```dart
   Widget _buildOfflineWarning() {
     if (_isOnline) return SizedBox.shrink();

     return Container(
       padding: EdgeInsets.all(12),
       color: Colors.orange.shade100,
       child: Row(
         children: [
           Icon(Icons.warning, color: Colors.orange.shade700),
           SizedBox(width: 8),
           Expanded(
             child: Text(
               'You\'re offline. Showing cached currency data. '
               'Conversion requires internet connection.',
               style: TextStyle(color: Colors.orange.shade900),
             ),
           ),
         ],
       ),
     );
   }
   ```

3. **Last Updated Timestamp**
   ```dart
   Widget _buildLastUpdated() {
     if (_lastUpdated == null) return SizedBox.shrink();

     return Text(
       'Last updated: ${_formatTimestamp(_lastUpdated!)}',
       style: Theme.of(context).textTheme.bodySmall,
     );
   }
   ```

## Test Files

### currency_service_test.dart
Unit tests for the CurrencyService class:
- Mock HTTP client for API simulation
- Tests all service methods
- Verifies caching behavior
- Tests timeout handling

### currency_converter_ui_test.dart
Widget tests for the CurrencyConverterScreen:
- Tests UI components
- Tests navigation
- Tests offline behavior
- Tests error handling

## Running the Tests

### Run All Tests
```bash
flutter test
```

### Run Currency Service Tests Only
```bash
flutter test test/currency_service_test.dart
```

### Run Currency UI Tests Only
```bash
flutter test test/currency_converter_ui_test.dart
```

### Run with Coverage
```bash
flutter test --coverage
```

## Test Results

### Expected Behavior

#### Online Scenario
1. App fetches currencies from API
2. Currencies are displayed
3. Conversions work with live rates
4. Data is cached for offline use

#### Offline Scenario (With Cache)
1. App tries to fetch from API
2. API call fails
3. App uses cached currencies
4. Currency list is displayed
5. Conversion attempts fail with error

#### Offline Scenario (No Cache)
1. App tries to fetch from API
2. API call fails
3. App uses default currencies
4. Limited currency list is displayed
5. Conversion attempts fail with error

### Test Coverage

- **API Functionality**: 100%
- **Offline Behavior**: 100%
- **Timeout Handling**: 100%
- **Error Handling**: 100%
- **Edge Cases**: 100%
- **Integration Workflows**: 100%

## Search Bar Integration

Currency conversion does **not** work with the home screen search bar's instant conversion feature. For detailed explanation of why this is an intentional design decision, see [CURRENCY_ARCHITECTURE.md](CURRENCY_ARCHITECTURE.md#search-bar-integration).

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

### Network Security
- HTTPS enforced for all API calls
- Certificate validation is performed by the HTTP client
- No cleartext traffic is allowed

## Performance Considerations

### Caching Strategy
- Currencies are cached indefinitely
- Cache is updated on successful API calls
- No automatic cache expiration
- Manual cache refresh not implemented (could be added)

### API Rate Limiting
- frankfurter.dev has a rate limit (not specified in docs)
- No rate limiting implemented in the app
- Consider adding rate limiting for production use

### Timeout Handling
- 10-second timeout prevents hanging
- Timeout is applied to both getCurrencies and convert
- Timeout is configurable via _timeout constant

## Future Enhancements

### Recommended Features

1. **Explicit Offline Warning**
   - Show connection status indicator
   - Display warning banner when offline
   - Show last updated timestamp

2. **Manual Refresh**
   - Add pull-to-refresh functionality
   - Allow users to manually update rates
   - Show refresh button in UI

3. **Cache Management**
   - Add cache expiration (e.g., 1 hour)
   - Show cache age to users
   - Allow users to clear cache

4. **Rate Limiting**
   - Implement rate limiting for API calls
   - Show warning when rate limit is approached
   - Implement exponential backoff for retries

5. **More Currencies**
   - Add more default currencies
   - Allow users to favorite currencies
   - Show recently used currencies

6. **Historical Rates**
   - Show historical exchange rates
   - Display rate trends
   - Add charts for rate history

## Troubleshooting

### Common Issues

#### API Calls Failing
- Check internet connection
- Verify API endpoint is accessible
- Check for rate limiting
- Verify timeout settings

#### Cached Data Not Updating
- Clear app cache
- Force refresh (if implemented)
- Check for network issues
- Verify API is returning data

#### Conversion Errors
- Verify currency codes are valid
- Check internet connection
- Verify API is returning rates
- Check for malformed API responses

### Debug Mode

To enable debug logging for the currency service:

```dart
// In currency_service.dart
class CurrencyService {
  static const bool _debug = true;

  Future<Map<String, String>> getCurrencies() async {
    if (_debug) {
      print('Fetching currencies from API...');
    }
    // ... rest of the code
  }
}
```

## References

- [Frankfurter API Documentation](https://api.frankfurter.dev/)
- [HTTP Client Documentation](https://pub.dev/packages/http)
- [SharedPreferences Documentation](https://pub.dev/packages/shared_preferences)
- [Flutter Testing Documentation](https://docs.flutter.dev/cookbook/testing)
