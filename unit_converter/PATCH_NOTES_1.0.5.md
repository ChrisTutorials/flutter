# Version 1.0.5 - Currency Name Helpers

## New Features
- **Currency Name Display**: Added full currency names next to currency codes throughout the app
  - Dropdown items show "USD - US Dollar" format for easy identification
  - Selected values display only the acronym (e.g., "USD") for compact display
  - Conversion results show full names: "100 USD (US Dollar) = 92 EUR (Euro)"
  - Rate details display full names: "1 USD (US Dollar) = 0.92 EUR (Euro)"

## UI Improvements
- **Tooltips for Space-Constrained Areas**: Added helpful tooltips showing currency names on hover/tap
  - Recent conversion cards
  - Favorite conversion cards
  - Preset cards
  - Only shows for currency conversions, not other unit types

## Technical
- Added comprehensive widget test coverage for currency name helpers
- All currency-related widgets now properly handle currency name display
- Graceful fallback for unknown currency codes (shows "Unknown")

