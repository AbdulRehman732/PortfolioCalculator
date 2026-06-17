# PSX Proxy Backend Server

A Node.js/Express backend server that acts as a CORS proxy for fetching live stock prices from PSX (Pakistan Stock Exchange).

## Problem Solved

The Flutter web app was getting CORS errors when trying to fetch stock prices directly from `https://dps.psx.com.pk`. Browsers block cross-origin requests from `localhost:xxxx` to external domains for security reasons.

## Solution

This backend server:

1. Runs on `localhost:3001`
2. Fetches live stock prices from PSX on behalf of the Flutter app
3. Returns prices as JSON (no CORS restrictions between localhost services)
4. Caches prices for 5 minutes to reduce API calls

## Setup

### Prerequisites

- Node.js 14+ installed
- npm or yarn

### Installation

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install
```

### Running the Server

**Development mode (with auto-reload):**

```bash
npm run dev
```

**Production mode:**

```bash
npm start
```

The server will start on `http://localhost:3001`

## API Endpoints

### Health Check

```
GET /api/health
```

Response:

```json
{
  "status": "ok",
  "timestamp": 1622000000000,
  "cacheSize": 3
}
```

### Get Single Stock Price

```
GET /api/stock/:symbol/price
```

Example: `GET /api/stock/FFC/price`

Response:

```json
{
  "symbol": "FFC",
  "price": 504.27,
  "cached": false,
  "timestamp": 1622000000000
}
```

### Get Multiple Stock Prices

```
POST /api/stocks/prices
Content-Type: application/json

{
  "symbols": ["FFC", "BIPL", "HUBC"]
}
```

Response:

```json
{
  "prices": {
    "FFC": 504.27,
    "BIPL": 24.98,
    "HUBC": 220.49
  },
  "timestamp": 1622000000000,
  "fetched": 3,
  "requested": 3
}
```

### Clear Cache

```
GET /api/cache/clear
```

## Running Both Services

### Terminal 1: Start the Backend Server

```bash
cd backend
npm install
npm start
```

### Terminal 2: Start the Flutter Web App

```bash
cd psx_app
flutter run
# Choose: [2]: Chrome (chrome)
```

## How It Works

1. Flutter app starts and calls `PsxService._fetchLivePrices()`
2. Instead of hitting PSX directly, it calls `http://localhost:3001/api/stocks/prices`
3. Backend server fetches HTML from PSX, parses it with cheerio
4. Extracts stock prices and returns JSON to Flutter app
5. Flutter updates the UI with live prices

## Troubleshooting

### Backend not reachable

```
Failed to fetch live prices from backend: Connection refused
```

**Solution:** Make sure the backend server is running on port 3001:

```bash
npm start
```

### Port 3001 already in use

```bash
# Kill the process using port 3001
lsof -ti:3001 | xargs kill -9  # macOS/Linux
netstat -ano | findstr :3001   # Windows (find PID)
taskkill /PID <PID> /F         # Windows (kill process)
```

### Dependencies missing

```bash
cd backend
rm -rf node_modules package-lock.json
npm install
npm start
```

## Dependencies

- **express**: Web framework
- **cors**: Enable CORS for all requests
- **axios**: HTTP client for fetching PSX pages
- **cheerio**: HTML parsing (jQuery-like syntax)

## Notes

- Prices are cached for 5 minutes to avoid hammering PSX servers
- The backend gracefully handles errors - if PSX is down, the app uses default prices
- CORS headers are set to allow requests from any origin (suitable for localhost development)

## Future Improvements

- Add rate limiting
- Add authentication
- Store historical prices in database
- Add more financial metrics
- Deploy to cloud (Heroku, AWS, etc.)
