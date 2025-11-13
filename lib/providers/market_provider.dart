import 'package:flutter/foundation.dart';

class MarketPrice {
  final String commodity;
  final double price;
  final double changePercent;
  final String market;
  final String unit;
  final DateTime lastUpdated;
  final String trend;

  MarketPrice({
    required this.commodity,
    required this.price,
    required this.changePercent,
    required this.market,
    required this.unit,
    required this.lastUpdated,
    required this.trend,
  });
}

class MarketNews {
  final String title;
  final String summary;
  final String impact;
  final DateTime publishedAt;

  MarketNews({
    required this.title,
    required this.summary,
    required this.impact,
    required this.publishedAt,
  });
}

class MarketProvider with ChangeNotifier {
  List<MarketPrice> _prices = [];
  List<MarketNews> _news = [];
  bool _isLoading = false;
  String _error = '';
  DateTime? _lastUpdated;

  List<MarketPrice> get prices => _prices;
  List<MarketNews> get news => _news;
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  Future<void> fetchMarketData() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      _prices = [
        MarketPrice(
          commodity: 'Rice',
          price: 2275.0,
          changePercent: 2.1,
          market: 'Karnataka APMC',
          unit: '₹/quintal',
          lastUpdated: DateTime.now(),
          trend: 'up',
        ),
        MarketPrice(
          commodity: 'Wheat',
          price: 2015.0,
          changePercent: 5.8,
          market: 'Punjab APMC',
          unit: '₹/quintal',
          lastUpdated: DateTime.now(),
          trend: 'up',
        ),
        MarketPrice(
          commodity: 'Cotton',
          price: 5850.0,
          changePercent: -3.2,
          market: 'Gujarat APMC',
          unit: '₹/quintal',
          lastUpdated: DateTime.now(),
          trend: 'down',
        ),
        MarketPrice(
          commodity: 'Turmeric',
          price: 8500.0,
          changePercent: 4.3,
          market: 'Erode APMC',
          unit: '₹/quintal',
          lastUpdated: DateTime.now(),
          trend: 'up',
        ),
        MarketPrice(
          commodity: 'Onion',
          price: 2800.0,
          changePercent: -2.1,
          market: 'Nashik APMC',
          unit: '₹/quintal',
          lastUpdated: DateTime.now(),
          trend: 'down',
        ),
        MarketPrice(
          commodity: 'Tomato',
          price: 3500.0,
          changePercent: 7.2,
          market: 'Bangalore APMC',
          unit: '₹/quintal',
          lastUpdated: DateTime.now(),
          trend: 'up',
        ),
      ];

      _news = [
        MarketNews(
          title: 'Rice Prices Show Upward Trend',
          summary: 'Increased international demand pushes rice prices higher across Karnataka markets',
          impact: 'positive',
          publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        MarketNews(
          title: 'Weather Forecast Positive for Wheat',
          summary: 'Favorable conditions expected to boost wheat production this season',
          impact: 'neutral',
          publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        MarketNews(
          title: 'Cotton Market Faces Global Pressure',
          summary: 'International supply chain disruptions affecting cotton price stability',
          impact: 'negative',
          publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ];

      _lastUpdated = DateTime.now();
      _error = '';
    } catch (e) {
      _error = 'Failed to fetch market data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshMarketData() async {
    await fetchMarketData();
  }

  List<MarketPrice> getTrendingUp() {
    return _prices.where((price) => price.trend == 'up').toList();
  }

  List<MarketPrice> getTrendingDown() {
    return _prices.where((price) => price.trend == 'down').toList();
  }
}
