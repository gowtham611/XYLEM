import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/market_provider.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketProvider>(context, listen: false).fetchMarketData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, marketProvider, child) {
        return Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(FontAwesomeIcons.chartLine), text: 'Prices'),
                  Tab(icon: Icon(Icons.trending_up), text: 'Trending'),
                  Tab(icon: Icon(FontAwesomeIcons.newspaper), text: 'News'),
                ],
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPricesTab(marketProvider),
                  _buildTrendingTab(marketProvider),
                  _buildNewsTab(marketProvider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPricesTab(MarketProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading market data...'),
          ],
        ),
      );
    }

    if (provider.error.isNotEmpty) {
      return _buildErrorCard(provider);
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshMarketData(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMarketSummaryCard(provider),
          const SizedBox(height: 16),
          _buildPricesList(provider.prices),
        ],
      ),
    );
  }

  Widget _buildMarketSummaryCard(MarketProvider provider) {
    final upTrending = provider.getTrendingUp().length;
    final downTrending = provider.getTrendingDown().length;
    final stable = provider.prices.length - upTrending - downTrending;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Market Summary',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem('📈', upTrending.toString(), 'Rising'),
                _buildSummaryItem('📉', downTrending.toString(), 'Falling'),
                _buildSummaryItem('📊', stable.toString(), 'Stable'),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.lastUpdated != null)
              Text(
                'Last updated: ${_formatDateTime(provider.lastUpdated!)}',
                style: GoogleFonts.roboto(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String emoji, String count, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildPricesList(List<MarketPrice> prices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Commodity Prices',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...prices.map((price) => _buildPriceCard(price)),
      ],
    );
  }

  Widget _buildPriceCard(MarketPrice price) {
    final trendColor = _getTrendColor(price.trend);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: trendColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                _getCommodityIcon(price.commodity),
                color: trendColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price.commodity,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    price.market,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${price.price.toStringAsFixed(0)}',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTrendIcon(price.trend),
                      size: 14,
                      color: trendColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${price.changePercent > 0 ? '+' : ''}${price.changePercent.toStringAsFixed(1)}%',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: trendColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingTab(MarketProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final upTrending = provider.getTrendingUp();
    final downTrending = provider.getTrendingDown();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (upTrending.isNotEmpty) ...[
          _buildTrendingSection('📈 Rising Prices', upTrending, Colors.green),
          const SizedBox(height: 16),
        ],
        if (downTrending.isNotEmpty) ...[
          _buildTrendingSection('📉 Falling Prices', downTrending, Colors.red),
        ],
        if (upTrending.isEmpty && downTrending.isEmpty) ...[
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_flat, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No significant price movements'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrendingSection(String title, List<MarketPrice> prices, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        ...prices.map((price) => _buildPriceCard(price)),
      ],
    );
  }

  Widget _buildNewsTab(MarketProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.news.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.newspaper, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No market news available'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.news.length,
      itemBuilder: (context, index) {
        final news = provider.news[index];
        return _buildNewsCard(news);
      },
    );
  }

  Widget _buildNewsCard(MarketNews news) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getNewsIcon(news.impact),
                  color: _getNewsColor(news.impact),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    news.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              news.summary,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDateTime(news.publishedAt),
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(MarketProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load market data'),
          const SizedBox(height: 8),
          Text(provider.error, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.fetchMarketData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  IconData _getCommodityIcon(String commodity) {
    switch (commodity.toLowerCase()) {
      case 'rice': return FontAwesomeIcons.seedling;
      case 'wheat': return FontAwesomeIcons.wheatAwn;
      case 'cotton': return FontAwesomeIcons.leaf;
      case 'sugarcane': return FontAwesomeIcons.leaf;
      case 'turmeric': return FontAwesomeIcons.pepperHot;
      case 'onion': return FontAwesomeIcons.circle;
      case 'tomato': return FontAwesomeIcons.apple;
      default: return FontAwesomeIcons.seedling;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'up': return Colors.green;
      case 'down': return Colors.red;
      case 'stable': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'up': return Icons.trending_up;
      case 'down': return Icons.trending_down;
      case 'stable': return Icons.trending_flat;
      default: return Icons.remove;
    }
  }

  IconData _getNewsIcon(String impact) {
    switch (impact) {
      case 'positive': return Icons.trending_up;
      case 'negative': return Icons.trending_down;
      case 'neutral': return Icons.info_outline;
      default: return Icons.info;
    }
  }

  Color _getNewsColor(String impact) {
    switch (impact) {
      case 'positive': return Colors.green;
      case 'negative': return Colors.red;
      case 'neutral': return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
