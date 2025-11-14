# News API Setup Guide

## Overview
The XYLEM app now fetches dynamic agricultural news from NewsAPI.org. This guide will help you set up the API key.

## Steps to Get Your Free API Key

### Option 1: NewsAPI.org (Recommended)
1. Visit https://newsapi.org/
2. Click "Get API Key" or "Register"
3. Sign up with your email
4. Verify your email address
5. Copy your API key from the dashboard
6. Free tier includes:
   - 100 requests per day
   - Access to news from 80,000+ sources
   - 1-month historical data

### Option 2: GNews API (Alternative)
1. Visit https://gnews.io/
2. Click "Get API Key"
3. Sign up for free account
4. Copy your API key
5. Free tier includes:
   - 100 requests per day
   - Access to 60,000+ news sources

## Configuration

### Update the API Key
Open `lib/services/news_api_service.dart` and replace the placeholder:

```dart
static const String _apiKey = 'YOUR_NEWS_API_KEY'; // Replace with your actual key
```

**Example:**
```dart
static const String _apiKey = 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6'; // Your real key
```

### For NewsAPI.org
The current implementation is already set up for NewsAPI.org. Just add your key.

### For GNews API
If you prefer GNews, update the following in `lib/services/news_api_service.dart`:

```dart
// Change the base URL
static const String _baseUrl = 'https://gnews.io/api/v4';

// Update the fetchAgricultureNews method
final url = Uri.parse(
  '$_baseUrl/search?q=agriculture+farming+crop&lang=en&country=in&max=20&apikey=$_apiKey',
);
```

## Features

### What the News Section Shows:
- ✅ **Dynamic Agricultural News** - Real-time news about farming, crops, markets
- ✅ **News Images** - Thumbnail images for each article (when available)
- ✅ **Impact Analysis** - Automatically categorizes news as positive/negative/neutral
- ✅ **Source Attribution** - Shows which publication the news is from
- ✅ **Read More Links** - Tap any article to open in browser
- ✅ **Pull to Refresh** - Swipe down to fetch latest news
- ✅ **Fallback Content** - Shows local updates if API is unavailable

### News Impact Indicators:
- 🟢 **Green (Positive)** - Good news for farmers (price increase, subsidies, etc.)
- 🔴 **Red (Negative)** - Concerning news (droughts, pests, price drops)
- ⚪ **Gray (Neutral)** - General information

## Testing

### Test Without API Key
The app works without an API key! It will show fallback news:
- Market data updates
- Weather advisories
- Government scheme information

### Test With API Key
1. Add your API key as described above
2. Run the app: `flutter run`
3. Navigate to Market → News tab
4. Pull down to refresh
5. You should see real agricultural news with images

## Troubleshooting

### Issue: No news showing
**Solution:** Check internet connection and verify API key is correct

### Issue: "API limit exceeded"
**Solution:** Free tier limits to 100 requests/day. Wait 24 hours or upgrade plan.

### Issue: Only fallback news showing
**Solution:** 
1. Verify API key is correctly added (no extra spaces)
2. Check console logs for error messages
3. Ensure you're using the correct API service (NewsAPI vs GNews)

### Issue: News articles not in English
**Solution:** The API is configured for English (`language=en`). Modify the query parameters if needed.

## API Request Examples

### Current News Query:
Searches for: agriculture, farming, crop, mandi, farmer, agricultural, kisan

### Customize Search Terms:
Edit the `searchTerms` in `news_api_service.dart`:
```dart
final searchTerms = [
  'agriculture',
  'farming',
  'crop prices',
  'monsoon',
  // Add your custom terms
].join(' OR ');
```

## Best Practices

1. **Don't commit API keys to git** - Add `.env` file for production
2. **Monitor usage** - Check NewsAPI dashboard for request counts
3. **Cache results** - Consider implementing local caching to reduce API calls
4. **Handle errors gracefully** - App falls back to local content if API fails

## Production Deployment

For production apps, use environment variables instead of hardcoding:

```dart
// Use flutter_dotenv package
import 'package:flutter_dotenv/flutter_dotenv.dart';

static final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
```

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

Create `.env` file:
```
NEWS_API_KEY=your_actual_api_key_here
```

## Additional Resources

- [NewsAPI Documentation](https://newsapi.org/docs)
- [GNews Documentation](https://gnews.io/docs/v4)
- [Flutter URL Launcher Docs](https://pub.dev/packages/url_launcher)

## Support

If you encounter issues:
1. Check the Flutter console for error messages
2. Verify API key is valid at the provider's website
3. Test API directly using Postman or browser
4. Check if free tier limits have been exceeded

---

**Last Updated:** November 14, 2025
**XYLEM Version:** 1.0
