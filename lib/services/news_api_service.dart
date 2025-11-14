import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsApiService {
  // Using NewsAPI.org - Get a free API key from https://newsapi.org/
  // For production, store this in environment variables or secure storage
  static const String _apiKey = '4516bdbc38c34e968c76bec44448932f';
  static const String _baseUrl = 'https://newsapi.org/v2';
  
  // Flag to check if API key is configured
  static bool get isConfigured => _apiKey.isNotEmpty && _apiKey.length > 20;
  
  // Alternative: Using GNews API (also free)
  // static const String _apiKey = 'YOUR_GNEWS_API_KEY';
  // static const String _baseUrl = 'https://gnews.io/api/v4';

  /// Fetches agricultural news from NewsAPI
  static Future<List<Map<String, dynamic>>> fetchAgricultureNews({
    String country = 'in', // India
    int pageSize = 20,
  }) async {
    // If API key is not configured, return fallback news immediately
    if (!isConfigured) {
      print('ℹ️ News API key not configured. Using fallback news.');
      print('📝 To get live news, add your API key in lib/services/news_api_service.dart');
      print('🔗 Get free API key: https://newsapi.org/');
      return _getFallbackNews();
    }

    try {
      // Search for agriculture-related news
      final searchTerms = [
        'agriculture',
        'farming',
        'crop',
        'mandi',
        'farmer',
        'agricultural',
        'kisan',
      ].join(' OR ');

      final url = Uri.parse(
        '$_baseUrl/everything?q=$searchTerms&language=en&sortBy=publishedAt&pageSize=$pageSize&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List;
        
        return articles.map((article) => {
          'title': article['title'] ?? 'No Title',
          'description': article['description'] ?? 'No description available',
          'url': article['url'] ?? '',
          'urlToImage': article['urlToImage'],
          'publishedAt': article['publishedAt'] ?? DateTime.now().toIso8601String(),
          'source': article['source']?['name'] ?? 'Unknown',
          'content': article['content'] ?? '',
        }).toList();
      } else if (response.statusCode == 401) {
        print('❌ Invalid API key. Please check your NewsAPI key.');
        print('🔗 Get free API key: https://newsapi.org/');
        return _getFallbackNews();
      } else {
        print('⚠️ News API error: ${response.statusCode}');
        return _getFallbackNews();
      }
    } catch (e) {
      print('⚠️ Error fetching agriculture news: $e');
      return _getFallbackNews();
    }
  }

  /// Alternative: Fetch news specifically for Indian agriculture
  static Future<List<Map<String, dynamic>>> fetchIndianAgriNews() async {
    if (!isConfigured) {
      print('ℹ️ News API key not configured. Using fallback news.');
      return _getFallbackNews();
    }

    try {
      // Search for India-specific agricultural news
      final url = Uri.parse(
        '$_baseUrl/everything?q=india+agriculture+OR+farming+OR+mandi+OR+kisan&language=en&sortBy=publishedAt&pageSize=20&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List;
        
        return articles.map((article) => {
          'title': article['title'] ?? 'No Title',
          'description': article['description'] ?? 'No description available',
          'url': article['url'] ?? '',
          'urlToImage': article['urlToImage'],
          'publishedAt': article['publishedAt'] ?? DateTime.now().toIso8601String(),
          'source': article['source']?['name'] ?? 'Unknown',
          'content': article['content'] ?? '',
        }).toList();
      } else if (response.statusCode == 401) {
        print('❌ Invalid API key. Please check your NewsAPI key.');
        return _getFallbackNews();
      } else {
        print('⚠️ News API error: ${response.statusCode}');
        return _getFallbackNews();
      }
    } catch (e) {
      print('⚠️ Error fetching Indian agriculture news: $e');
      return _getFallbackNews();
    }
  }

  /// Analyzes news impact based on keywords
  static String analyzeNewsImpact(String title, String description) {
    final content = '${title.toLowerCase()} ${description.toLowerCase()}';
    
    // Positive impact keywords
    final positiveKeywords = [
      'increase', 'rise', 'growth', 'profit', 'benefit', 'good',
      'improvement', 'success', 'gain', 'bonus', 'subsidy', 'scheme',
      'higher', 'boost', 'support', 'help', 'better',
    ];
    
    // Negative impact keywords
    final negativeKeywords = [
      'decrease', 'fall', 'drop', 'loss', 'damage', 'drought',
      'flood', 'pest', 'disease', 'crisis', 'problem', 'decline',
      'lower', 'worst', 'concern', 'warning', 'threat',
    ];
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (var keyword in positiveKeywords) {
      if (content.contains(keyword)) positiveCount++;
    }
    
    for (var keyword in negativeKeywords) {
      if (content.contains(keyword)) negativeCount++;
    }
    
    if (positiveCount > negativeCount) {
      return 'positive';
    } else if (negativeCount > positiveCount) {
      return 'negative';
    } else {
      return 'neutral';
    }
  }

  /// Fallback news when API is unavailable or no key is provided
  static List<Map<String, dynamic>> _getFallbackNews() {
    return [
      {
        'title': '📰 News API Setup Required',
        'description': 'To see live agricultural news, please configure your NewsAPI key. Visit newsapi.org to get a free API key (100 requests/day). See NEWS_API_SETUP.md for detailed instructions.',
        'url': 'https://newsapi.org/',
        'urlToImage': null,
        'publishedAt': DateTime.now().toIso8601String(),
        'source': 'XYLEM Setup',
        'content': 'Free API key setup takes only 2 minutes and gives you access to 80,000+ news sources.',
      },
      {
        'title': 'Market Price Update',
        'description': 'Latest commodity prices have been updated from government sources. Check the Prices tab for current market rates across Indian states.',
        'url': '',
        'urlToImage': null,
        'publishedAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'source': 'XYLEM App',
        'content': 'Latest market data synchronized from data.gov.in agricultural database.',
      },
      {
        'title': 'Weather Advisory Available',
        'description': 'Check current weather conditions and farming recommendations based on local weather patterns. Get real-time updates for better crop planning.',
        'url': '',
        'urlToImage': null,
        'publishedAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'source': 'XYLEM App',
        'content': 'Stay updated with real-time weather information and personalized farming recommendations.',
      },
      {
        'title': 'Government Agricultural Schemes',
        'description': 'Various agricultural schemes and subsidies are available for farmers. Explore programs offering financial aid, equipment support, and training opportunities.',
        'url': '',
        'urlToImage': null,
        'publishedAt': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        'source': 'XYLEM App',
        'content': 'Government initiatives to support farmers with resources and financial assistance.',
      },
      {
        'title': 'Smart Farming Tips',
        'description': 'Learn about modern farming techniques, soil health management, and crop rotation strategies to improve your yield and sustainability.',
        'url': '',
        'urlToImage': null,
        'publishedAt': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
        'source': 'XYLEM App',
        'content': 'Access expert farming advice and best practices for modern agriculture.',
      },
    ];
  }
}
