# Version 1.0.5 - Currency Name Helpers & History Controls

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

- **Currency Visibility Settings**: Separate card in Appearance and extras for toggling currencies
  - All currencies can be shown/hidden from currency converter dropdown
  - VND (Vietnamese Dong) hidden by default
  - Settings persist across app restarts

- **History Toggle**: New setting to disable conversion history entirely
  - When disabled, no conversions are saved
  - Disabling clears existing history
  - When re-enabling, dialog asks whether to clear existing history
  - Useful for privacy-conscious users
  - Recent conversions section hidden from home page when disabled

## Technical
- Added comprehensive widget test coverage for currency name helpers
- All currency-related widgets now properly handle currency name display
- Graceful fallback for unknown currency codes (shows "Unknown")
- History toggle implemented with proper state management
- Currency visibility stored separately from unit visibility
- 14 new tests for history toggle functionality