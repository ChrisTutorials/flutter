# Google Play Store Setup - Complete Guide

## ?? Quick Copy-Paste Content

### 1. APP NAME (30 chars max)
Unit Converter Pro

### 2. SHORT DESCRIPTION (80 chars max)
Convert units, create custom measurements, live currency rates

### 3. FULL DESCRIPTION (4000 chars max)

The ultimate unit converter for professionals, students, and everyday users. Convert anything, anywhere, with precision and ease.

KEY FEATURES:

? 8+ Unit Categories
• Length (meters, feet, inches, miles, kilometers, and more)
• Weight (kilograms, pounds, ounces, tons, grams, and more)
• Temperature (Celsius, Fahrenheit, Kelvin)
• Volume (liters, gallons, milliliters, cubic meters, and more)
• Area (square meters, square feet, acres, hectares, and more)
• Speed (km/h, mph, m/s, knots, and more)
• Time (seconds, minutes, hours, days, weeks, months, years)
• Currency (USD, EUR, GBP, and 150+ more)

? Custom Units
• Create your own conversion units for specialized needs
• Perfect for engineers, scientists, and professionals
• Save custom units locally on your device
• Use custom units just like built-in units

? Live Currency Conversion
• Real-time exchange rates via Frankfurter API
• Offline fallback with cached rates
• Support for 150+ currencies
• Automatic rate updates

? Quick Presets
• One-tap common conversions
• °F ? °C (Fahrenheit to Celsius)
• kg ? lb (Kilograms to Pounds)
• in ? cm (Inches to Centimeters)
• gal ? L (Gallons to Liters)
• USD ? EUR (US Dollar to Euro)
• EUR ? GBP (Euro to British Pound)

? Beautiful Themes
• 5 stunning color palettes (Default, Blue, Green, Orange, Purple)
• Dark mode for night use
• Light mode for day use
• System theme to match your device
• Smooth theme transitions

? Offline-First Architecture
• Works without internet for most features
• Cached currency rates for offline use
• All conversions happen locally
• No data usage for basic conversions

? Smart Search
• Search across all categories, units, and presets
• Find converters instantly
• Search by unit name, symbol, or category
• Filter results in real-time

? Recent Conversions
• Quick access to previous conversions
• Timestamp for each conversion
• One-tap to repeat conversions
• Clear history when needed

? Favorites
• Save your most-used conversions
• Quick access from home screen
• Organize your workflow
• Never lose important conversions

PERFECT FOR:

?? Engineers & Scientists
• Custom units for specialized measurements
• Precise calculations
• Offline reliability

?? Travelers
• Live currency conversion
• Offline fallback
• Quick unit conversions on the go

?? Students & Educators
• Easy to understand interface
• Comprehensive unit coverage
• Perfect for homework and teaching

?? Professionals
• Reliable conversions
• Custom workflows
• Multi-platform support

?? Everyday Users
• Simple and intuitive
• Beautiful design
• Works offline

MULTI-PLATFORM SUPPORT:

Works seamlessly on:
• Android (this app)
• iOS (coming soon)
• Windows
• macOS
• Linux
• Web

Consistent experience across all your devices!

WHY CHOOSE US?

Unlike other unit converters, we offer:
? Custom units - Create your own measurements
? Live currency with offline - Best of both worlds
? Beautiful themes - 5 color palettes
? True multi-platform - Works on 6 platforms
? Offline-first - No internet required
? Smart search - Find anything instantly
? No ads in the way - Clean, focused experience
? Privacy-focused - Your data stays on your device

PRIVACY:

• No account required
• No data collection beyond local storage
• No tracking or analytics
• Your custom units and preferences stay on your device
• Open source and transparent

DOWNLOAD NOW:

Start converting with the most powerful unit converter available. Perfect for professionals, students, and anyone who needs reliable conversions.

### 4. RELEASE NOTES (500 chars max)

Initial release:
• 8+ unit categories with custom units
• Live currency conversion with offline fallback
• Quick presets for common conversions
• 5 beautiful themes with dark/light mode
• Offline-first architecture
• Smart search functionality
• Recent conversions and favorites
• Multi-platform support

## ?? How to Take Screenshots

### ?? IMPORTANT: No Emulator Required

**Do not use Android emulator for screenshots.** Use web browser or Playwright for a much faster, more efficient workflow.

### Option 1: Using Web Browser (Recommended - Fastest)

1. Run the app in a browser:
   `ash
   cd C:\dev\flutter\unit_converter
   flutter run -d chrome
   `

2. Use browser developer tools to take screenshots:
   - Press F12 to open DevTools
   - Press Ctrl+Shift+P to open Command Menu
   - Type " screenshot\ and choose:
 - \Capture screenshot\ - captures visible area
 - \Capture full size screenshot\ - captures entire page
 - Save to appropriate location

3. Resize browser for store screenshots:
 - Press F12 to open DevTools
 - Click the device toolbar icon (Ctrl+Shift+M)
 - Set dimensions to 1080x1920 for phone screenshots
 - Take screenshot

### Option 2: Using Playwright (Automated - Fastest for Multiple Screens)

1. Install Playwright:
 `ash
 npm install -D @playwright/test
 npx playwright install
 `

2. Create a screenshot script that navigates through the app and captures screens

3. Run the script to capture all screenshots in one go:
 `ash
 flutter run -d chrome --web-port 8080
 npx playwright test screenshots.spec.ts
 `

4. Much faster than manual emulator screenshots

### Screenshots to Take:

1. **Home Screen** (01_home_screen.png)
 - Navigate to the app home
 - Show category grid
 - Show quick presets horizontal list
 - Show hero banner

2. **Conversion Screen** (02_conversion_screen.png)
 - Tap on Length category
 - Show conversion from meters to feet
 - Type 10 to show live conversion
 - Show the swap button

3. **Currency Converter** (03_currency_converter.png)
 - Tap on Currency card
 - Show USD to EUR conversion
 - Show live rate display
 - Show preset chips at top

4. **Theme Settings** (04_theme_settings.png)
 - Go to Settings (gear icon)
 - Show theme selection
 - Show the 5 color palette options
 - Show dark/light/system toggle

5. **Custom Units Screen** (05_custom_units.png)
 - Go to Settings ? Custom Units
 - Show list of custom units
 - Show Add Custom Unit button

6. **Search Functionality** (06_search_functionality.png)
 - On home screen, tap search field
 - Type currency to show filtered results
 - Show search results

### Screenshot Requirements:
- Minimum 2, maximum 8 screenshots
- Size: 320px to 3840px
- Recommended: 1080x1920 or 1080x2400 pixels
- Format: JPG or PNG
- No status bar (optional but looks cleaner)
- Show key features clearly

**Note**: Web browser screenshots are much faster and easier than emulator screenshots. No emulator setup required!
## ?? App Icon Creation

### Create a 512x512 PNG icon:

1. Use a design tool (Figma, Canva, Photoshop, etc.)
2. Create a 512x512 canvas
3. Design your icon:
   - Unit converter symbol (arrows, equals sign, or conversion icon)
   - Your brand colors (teal gradient: #0F766E to #6B8E23)
   - Clean, modern design
   - No text (except your brand name if subtle)
4. Save as PNG
5. IMPORTANT: No transparency/alpha channel
6. Save to: C:\dev\flutter\unit_converter\screenshots\app_icon.png

### Icon Design Tips:
- Simple and recognizable at small sizes
- High contrast
- Avoid too much detail
- Use your brand colors
- Test at different sizes (32px, 48px, 72px, 96px, 144px, 192px)

## ?? Privacy Policy Setup

### Create a Free Privacy Policy:

1. Go to: https://privacypolicygenerator.info
2. Fill in the form:
   - App name: Unit Converter Pro
   - Company name: MoonBark Studio
   - Contact email: your-email@moonbarkstudio.com
   - Website: your-website.com (optional)
3. Select data collected:
   - Custom units (stored locally)
   - Recent conversions (stored locally)
   - Theme preferences (stored locally)
4. Select third-party services:
   - AdMob (for displaying ads)
   - Frankfurter API (for currency rates)
5. Generate the policy
6. Copy the HTML code
7. Upload to a website:
   - GitHub Pages (free)
   - Netlify (free)
   - Vercel (free)
   - Or your own website
8. Copy the URL and add to Google Play Console

### Privacy Policy URL Examples:
- https://yourname.github.io/unit-converter-privacy-policy/
- https://unit-converter-privacy-policy.netlify.app/
- https://yourwebsite.com/privacy-policy

## ?? Content Rating Questionnaire

### Answer these questions in Google Play Console:

1. **User-generated content?**
   - No

2. **Violence?**
   - No

3. **Sexual content?**
   - No

4. **Strong language?**
   - No

5. **Gambling?**
   - No

6. **Drugs?**
   - No

7. **Display ads?**
   - Yes (AdMob)

8. **Require user account?**
   - No

9. **Collect user data?**
   - Yes (optional, for custom units and recent conversions stored locally)

### Expected Result: Everyone rating

## ?? Pricing and Distribution

### Settings in Google Play Console:

1. **Free or Paid:**
   - Select: Free

2. **Countries:**
   - Select: All countries (or specific ones you want)

3. **Content Guidelines:**
   - Check all boxes to confirm compliance

4. **US Export Laws:**
   - Check the box to confirm compliance

## ?? App Bundle Location

Your release AAB is ready at:
C:\dev\flutter\unit_converter\build\app\outputs\bundle\release\app-release.aab

Size: 46.8MB

## ?? Complete Setup Checklist

### Store Listing
- [ ] App name: Unit Converter Pro
- [ ] Short description copied
- [ ] Full description copied
- [ ] Screenshots taken (2-8)
- [ ] App icon created (512x512 PNG)
- [ ] Screenshots uploaded
- [ ] App icon uploaded

### Content Rating
- [ ] Questionnaire completed
- [ ] Rating received (likely \Everyone\)

### Privacy Policy
- [ ] Privacy policy created
- [ ] Privacy policy hosted online
- [ ] Privacy policy URL added to Console

### Pricing and Distribution
- [ ] Set as Free
- [ ] Countries selected
- [ ] Content guidelines checked
- [ ] US Export laws checked

### Upload and Release
- [ ] AAB file uploaded
- [ ] Release notes added
- [ ] Submitted for review

## ?? Contact Information

Add to Google Play Console:
- Support email: your-email@moonbarkstudio.com
- Website: your-website.com (optional)

## ?? Next Steps After Setup

1. Upload AAB to Internal Testing
2. Test the app yourself
3. Invite a few friends to test
4. Fix any bugs
5. Upload to Production
6. Wait for Google review (1-3 days)
7. App goes live!

## ?? Additional Resources

- Google Play Console: https://play.google.com/console
- Flutter Deployment: https://flutter.dev/docs/deployment/android
- AdMob Setup: https://developers.google.com/admob/android/quick-start



