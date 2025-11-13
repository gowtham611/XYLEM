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

class _MarketScreenState extends State<MarketScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // NEW: Search bar + State selector
  final TextEditingController _searchCtrl = TextEditingController();
  String selectedState = "Tamil Nadu";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketProvider>(context, listen: false)
          .fetchMarketData(state: selectedState);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, provider, child) {
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
                  _buildPricesTab(provider),
                  _buildTrendingTab(provider),
                  _buildNewsTab(provider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PRICES TAB (UPDATED)
  // ============================================================
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

    return StatefulBuilder(
      builder: (context, setSB) {
        return RefreshIndicator(
          onRefresh: () =>
              provider.fetchMarketData(state: selectedState),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              //----------------------------------------------------------
              // STATE DROPDOWN
              //----------------------------------------------------------
              DropdownButtonFormField<String>(
                value: selectedState,
                items: provider.indianStates
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: "Select State",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setSB(() => selectedState = value!);
                  provider.fetchMarketData(state: selectedState);
                },
              ),

              const SizedBox(height: 16),

              //----------------------------------------------------------
              // CROP SEARCH BAR
              //----------------------------------------------------------
              TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  labelText: "Search crop or market",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setSB(() {}),
              ),

              const SizedBox(height: 16),

              //----------------------------------------------------------
              // SUMMARY CARD
              //----------------------------------------------------------
              _buildMarketSummaryCard(provider),
              const SizedBox(height: 16),

              //----------------------------------------------------------
              // FILTERED PRICE LIST
              //----------------------------------------------------------
              _buildPricesList(
                provider.filteredPrices(_searchCtrl.text),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================
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

  // ============================================================
  // PRICE LIST (UPDATED TO SHOW ₹/QUINTAL)
  // ============================================================
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
            //------------------------------------------------------
            // ICON SECTION
            //------------------------------------------------------
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

            //------------------------------------------------------
            // CROP & MARKET
            //------------------------------------------------------
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

            //------------------------------------------------------
            // PRICE + TREND
            //------------------------------------------------------
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${price.price.toStringAsFixed(0)} / quintal',    // UPDATED
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getTrendIcon(price.trend),
                        size: 14, color: trendColor),
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

  // ============================================================
  // TRENDING TAB (unchanged)
  // ============================================================
  Widget _buildTrendingTab(MarketProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final upTrending = provider.getTrendingUp();
    final downTrending = provider.getTrendingDown();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (upTrending.isNotEmpty)
          _buildTrendingSection('📈 Rising Prices', upTrending, Colors.green),
        const SizedBox(height: 16),
        if (downTrending.isNotEmpty)
          _buildTrendingSection('📉 Falling Prices', downTrending, Colors.red),
      ],
    );
  }

  Widget _buildTrendingSection(
      String title, List<MarketPrice> prices, Color color) {
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

  // ============================================================
  // NEWS TAB (unchanged)
  // ============================================================
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
                Icon(_getNewsIcon(news.impact),
                    color: _getNewsColor(news.impact), size: 20),
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
            onPressed: () =>
                provider.fetchMarketData(state: selectedState),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ICONS + HELPERS
  IconData _getCommodityIcon(String commodity) {
    switch (commodity.toLowerCase()) {
      case 'rice':
        return FontAwesomeIcons.seedling;
      case 'wheat':
        return FontAwesomeIcons.wheatAwn;
      case 'cotton':
        return FontAwesomeIcons.leaf;
      case 'turmeric':
        return FontAwesomeIcons.pepperHot;
      case 'onion':
        return FontAwesomeIcons.circle;
      case 'tomato':
        return FontAwesomeIcons.apple;
      default:
        return FontAwesomeIcons.seedling;
    }
  }

  Color _getTrendColor(String trend) {
    if (trend == "up") return Colors.green;
    if (trend == "down") return Colors.red;
    return Colors.blue;
  }

  IconData _getTrendIcon(String trend) {
    if (trend == "up") return Icons.trending_up;
    if (trend == "down") return Icons.trending_down;
    return Icons.trending_flat;
  }

  IconData _getNewsIcon(String impact) {
    if (impact == "positive") return Icons.trending_up;
    if (impact == "negative") return Icons.trending_down;
    return Icons.info_outline;
  }

  Color _getNewsColor(String impact) {
    if (impact == "positive") return Colors.green;
    if (impact == "negative") return Colors.red;
    return Colors.blue;
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
