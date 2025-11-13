import 'package:flutter/foundation.dart';
import '../services/market_api_service.dart';

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

  // 🔹 List of all Indian states
  final List<String> indianStates = [
    "Andhra Pradesh","Arunachal Pradesh","Assam","Bihar","Chhattisgarh",
    "Goa","Gujarat","Haryana","Himachal Pradesh","Jharkhand","Karnataka",
    "Kerala","Madhya Pradesh","Maharashtra","Manipur","Meghalaya","Mizoram",
    "Nagaland","Odisha","Punjab","Rajasthan","Sikkim","Tamil Nadu",
    "Telangana","Tripura","Uttar Pradesh","Uttarakhand","West Bengal"
  ];

  Future<void> fetchMarketData({String state = "Tamil Nadu"}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final rawData = await MarketApiService.fetchAllCrops(state);

      List<MarketPrice> parsed = [];

      for (var item in rawData.take(50)) {
        double minPrice = double.tryParse(item["min_price"] ?? "0") ?? 0;
        double maxPrice = double.tryParse(item["max_price"] ?? "0") ?? 0;

        double avgPrice = (minPrice + maxPrice) / 2;

        // Trend Estimation
        String trend = "stable";
        double changePercent = 0;
        if (avgPrice > 3000) {
          trend = "up";
          changePercent = 5.1;
        } else if (avgPrice < 1500) {
          trend = "down";
          changePercent = -4.3;
        }

        parsed.add(
          MarketPrice(
            commodity: item["commodity"] ?? "Unknown",
            price: avgPrice,
            changePercent: changePercent,
            market: item["market"] ?? "Unknown Market",
            unit: "₹/quintal",
            lastUpdated: DateTime.now(),
            trend: trend,
          ),
        );
      }

      _prices = parsed;
      _lastUpdated = DateTime.now();

      _news = [
        MarketNews(
          title: "Market Updated",
          summary: "Latest mandi data fetched from data.gov.in",
          impact: "neutral",
          publishedAt: DateTime.now(),
        )
      ];
    } catch (e) {
      _error = "Error: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  List<MarketPrice> filteredPrices(String query) {
    if (query.isEmpty) return _prices;

    return _prices.where((p) =>
        p.commodity.toLowerCase().contains(query.toLowerCase()) ||
        p.market.toLowerCase().contains(query.toLowerCase())).toList();
  }

  List<MarketPrice> getTrendingUp() =>
      _prices.where((p) => p.trend == "up").toList();

  List<MarketPrice> getTrendingDown() =>
      _prices.where((p) => p.trend == "down").toList();

  Future<void> refreshMarketData({String state = "Tamil Nadu"}) async {
    await fetchMarketData(state: state);
  }
}
