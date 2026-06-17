# PSX Dividend Machine - Mobile App Setup

Your personal investment tool for PSX (Pakistan Stock Exchange) dividend analysis, now available on mobile!

## Features

✅ **Search Any Stock** - Find and add any PSX-listed stock to your portfolio
✅ **Live Prices** - Real-time stock prices via backend proxy (no CORS errors)
✅ **Portfolio Management** - Track dividend yields, market cap, and financial ratios
✅ **Buy Decision Tool** - S-Tier system for monthly SIP decisions
✅ **Financial Metrics** - BR scores, D/E ratios, and other financial indicators
✅ **PIN Protection** - Secure your portfolio with a 4-digit PIN

## Quick Start

### Prerequisites

- Flutter 3.0+ installed
- Android SDK (for Android devices) or Xcode (for iOS)
- Node.js 14+ installed
- A connected Android/iOS device or emulator

### Step 1: Start the Backend Server

Open a terminal and navigate to the port directory:

```bash
cd c:\Users\aar25\Desktop\port
cd backend
npm start
```

The server will start on `http://localhost:3001`.

**Expected output:**

```
PSX Proxy Server running on http://localhost:3001
Health check: http://localhost:3001/api/health
```

### Step 2: Prepare Your Mobile Device

#### For Android:

1. Enable **Developer Mode**: Go to Settings > About Phone > Tap Build Number 7 times
2. Enable **USB Debugging**: Go to Settings > Developer options > Enable USB Debugging
3. Connect your phone via USB
4. Run `flutter devices` to verify connection

#### For iOS:

1. Connect via USB cable
2. Run `flutter devices` to verify connection
3. May need to open Xcode and trust the certificate

### Step 3: Run the App on Mobile

In a new terminal:

```bash
cd c:\Users\aar25\Desktop\port\psx_app
flutter clean
flutter pub get
flutter run
```

When prompted, select your device:

```
Connected devices:
[1]: Android device
[2]: iOS device
[3]: Chrome (web)
...
Please choose one: [1 or 2 for mobile]
```

### Step 4: Add Stocks

1. Open the app - you'll see a PIN lock screen (leave empty if no PIN is set)
2. Tap the floating **+** button (green button at bottom right)
3. Search for any stock by symbol (e.g., "FFC", "BIPL", "HUBC")
4. Tap **Add** to add to your portfolio
5. View your portfolio in the "Portfolio" tab

## Building for Production (APK/IPA)

### Android APK (for sharing with friends)

```bash
cd c:\Users\aar25\Desktop\port\psx_app

# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

Transfer the APK to your phone and install:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### iOS IPA

```bash
flutter build ios --release
```

Requires Apple Developer account and Xcode for signing and distribution.

## Troubleshooting

### "Backend not reachable"

**Error:** `Failed to fetch live prices from backend: Connection refused`

**Solution:**

1. Make sure backend is running: `npm start` in the backend folder
2. Check if port 3001 is available
3. On Android emulator, use `http://10.0.2.2:3001` instead of `localhost:3001`

### Update the Backend URL for Android Emulator

If using Android emulator, edit the backend URL in `psx_service.dart`:

```dart
// For physical device (same network):
const String BACKEND_URL = 'http://localhost:3001';

// For Android emulator:
const String BACKEND_URL = 'http://10.0.2.2:3001';

// For iOS simulator:
const String BACKEND_URL = 'http://localhost:3001';
```

### Device Not Detected

```bash
# List connected devices
flutter devices

# If nothing shows up:
# Android: Run "adb devices" and check drivers
# iOS: Run "sudo killall -9 usbmuxd"
```

### "Device offline" / Connection errors

Android:

```bash
adb kill-server
adb start-server
adb devices
```

## How It Works

### Architecture

```
┌─────────────────────────────────────────────────┐
│          Flutter Mobile App                      │
│  (Portfolio, Search, Decision Tool)              │
└────────────────────┬────────────────────────────┘
                     │ HTTP Requests
                     ↓
┌─────────────────────────────────────────────────┐
│      Node.js Backend (localhost:3001)           │
│  (CORS Proxy, Price Fetching, Parsing)          │
└────────────────────┬────────────────────────────┘
                     │ HTML Scraping
                     ↓
┌─────────────────────────────────────────────────┐
│       PSX Website (dps.psx.com.pk)              │
│  (Live Stock Data)                              │
└─────────────────────────────────────────────────┘
```

### Stock Search Flow

1. User types stock symbol in search box
2. Flutter app sends query to backend: `/api/stocks/search?query=FFC`
3. Backend scrapes PSX website for matching stocks
4. Backend fetches detailed info: price, yield, sector
5. User sees results and taps "Add"
6. Stock added to local portfolio (SharedPreferences)

### Price Updates

- When app launches, it fetches live prices for all stocks in portfolio
- Prices are cached for 5 minutes to reduce load
- Manual refresh available via pull-to-refresh on Overview tab

## Features Explained

### Buy Tool (Monthly Decision)

- S-Tier SIP system: Invest Rs 10,000/month
- Filter recommendations by financial ratios
- Check BR (Business Ratios) score before buying

### Portfolio Tab

- View all your stocks
- See dividend yield, market cap, volume
- Remove stocks you no longer track

### Roadmap Tab

- View planned phases and improvements
- Track upcoming features

### Settings Tab

- Set/change PIN lock
- Clear cached data
- View about information

## API Endpoints (Backend)

### Health Check

```
GET /api/health
```

### Search Stocks

```
GET /api/stocks/search?query=FFC
```

### Get Single Stock Price

```
GET /api/stock/FFC/price
```

### Get Multiple Stock Prices

```
POST /api/stocks/prices
Body: { "symbols": ["FFC", "BIPL", "HUBC"] }
```

### Get Stock Details

```
GET /api/stock/FFC/details
```

## Data Privacy

✅ All data stored locally on your device
✅ No account required
✅ PIN protection for sensitive portfolio
✅ Backend only fetches public PSX data
✅ No tracking or analytics

## Free for Personal Use

This app is completely free for personal use. You can:

- Run it on as many of your devices as you want
- Modify the code for your needs
- Share APK with friends

## Next Steps

1. Set up backend (see Step 1)
2. Connect your mobile device
3. Run the app (see Step 3)
4. Search for stocks (see Step 4)
5. Start making better investment decisions! 🚀

## Support

For issues or questions:

1. Check the Troubleshooting section above
2. Verify backend is running (`npm start`)
3. Check Flutter version: `flutter --version`
4. Check connected devices: `flutter devices`

## License

Free for personal use. Modify as needed for your investment research.

---

**Happy investing! 📈**
