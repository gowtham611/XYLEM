import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/market_provider.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    
    return Consumer<MarketProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(icon: const Icon(FontAwesomeIcons.chartLine), text: l10n?.prices ?? 'Prices'),
                  Tab(icon: const Icon(Icons.trending_up), text: l10n?.trending ?? 'Trending'),
                  Tab(icon: const Icon(FontAwesomeIcons.newspaper), text: l10n?.news ?? 'News'),
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
    final l10n = AppLocalizations.of(context);
    
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n?.loadingMarketData ?? 'Loading market data...'),
          ],
        ),
      );
    }

    if (provider.error.isNotEmpty) {
      return _buildErrorCard(provider);
    }

    return StatefulBuilder(
      builder: (context, setSB) {
        final l10n = AppLocalizations.of(context);
        
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
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(_getLocalizedStateName(s, l10n)),
                        ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: l10n?.selectState ?? "Select State",
                  border: const OutlineInputBorder(),
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
                decoration: InputDecoration(
                  labelText: l10n?.searchCropOrMarket ?? "Search crop or market",
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
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
    final l10n = AppLocalizations.of(context);
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
              l10n?.marketSummary ?? 'Market Summary',
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
                _buildSummaryItem('📈', upTrending.toString(), l10n?.rising ?? 'Rising'),
                _buildSummaryItem('📉', downTrending.toString(), l10n?.falling ?? 'Falling'),
                _buildSummaryItem('📊', stable.toString(), l10n?.stable ?? 'Stable'),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.lastUpdated != null)
              Text(
                '${l10n?.lastUpdated ?? 'Last updated'}: ${_formatDateTime(provider.lastUpdated!)}',
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
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.commodityPrices ?? 'Commodity Prices',
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
    final l10n = AppLocalizations.of(context);
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
                    _getLocalizedCropName(price.commodity, l10n),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _getLocalizedMarketName(price.market, l10n),
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
                  '₹${price.price.toStringAsFixed(0)} / ${l10n?.perQuintal ?? 'quintal'}',
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
    final l10n = AppLocalizations.of(context);
    
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final upTrending = provider.getTrendingUp();
    final downTrending = provider.getTrendingDown();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (upTrending.isNotEmpty)
          _buildTrendingSection('📈 ${l10n?.risingPrices ?? 'Rising Prices'}', upTrending, Colors.green),
        const SizedBox(height: 16),
        if (downTrending.isNotEmpty)
          _buildTrendingSection('📉 ${l10n?.fallingPrices ?? 'Falling Prices'}', downTrending, Colors.red),
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
  // NEWS TAB - Dynamic News from API
  // ============================================================
  Widget _buildNewsTab(MarketProvider provider) {
    final l10n = AppLocalizations.of(context);
    
    if (provider.isLoading && provider.news.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.news.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.refreshNews(),
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.newspaper, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(l10n?.noMarketNewsAvailable ?? 'No market news available'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => provider.refreshNews(),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n?.retry ?? 'Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshNews(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.news.length,
        itemBuilder: (context, index) {
          final news = provider.news[index];
          return _buildNewsCard(news);
        },
      ),
    );
  }

  Widget _buildNewsCard(MarketNews news) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: news.url != null && news.url!.isNotEmpty
            ? () => _openNewsUrl(news.url!)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // News Image (if available)
            if (news.imageUrl != null && news.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  news.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Impact indicator and title
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Summary
                  Text(
                    news.summary,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Source and date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.source, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            news.source,
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatDateTime(news.publishedAt),
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  
                  // Read more indicator
                  if (news.url != null && news.url!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Read more',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 14, color: Colors.green[700]),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openNewsUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open article')),
        );
      }
    }
  }

  Widget _buildErrorCard(MarketProvider provider) {
    final l10n = AppLocalizations.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(l10n?.failedToLoadMarketData ?? 'Failed to load market data'),
          const SizedBox(height: 8),
          Text(provider.error, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                provider.fetchMarketData(state: selectedState),
            child: Text(l10n?.retry ?? 'Retry'),
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

  String _getLocalizedStateName(String state, AppLocalizations? l10n) {
    if (l10n == null) return state;
    
    switch (state) {
      case "Andhra Pradesh":
        return l10n.stateAndhraPradesh ?? state;
      case "Arunachal Pradesh":
        return l10n.stateArunachalPradesh ?? state;
      case "Assam":
        return l10n.stateAssam ?? state;
      case "Bihar":
        return l10n.stateBihar ?? state;
      case "Chhattisgarh":
        return l10n.stateChhattisgarh ?? state;
      case "Goa":
        return l10n.stateGoa ?? state;
      case "Gujarat":
        return l10n.stateGujarat ?? state;
      case "Haryana":
        return l10n.stateHaryana ?? state;
      case "Himachal Pradesh":
        return l10n.stateHimachalPradesh ?? state;
      case "Jharkhand":
        return l10n.stateJharkhand ?? state;
      case "Karnataka":
        return l10n.stateKarnataka ?? state;
      case "Kerala":
        return l10n.stateKerala ?? state;
      case "Madhya Pradesh":
        return l10n.stateMadhyaPradesh ?? state;
      case "Maharashtra":
        return l10n.stateMaharashtra ?? state;
      case "Manipur":
        return l10n.stateManipur ?? state;
      case "Meghalaya":
        return l10n.stateMeghalaya ?? state;
      case "Mizoram":
        return l10n.stateMizoram ?? state;
      case "Nagaland":
        return l10n.stateNagaland ?? state;
      case "Odisha":
        return l10n.stateOdisha ?? state;
      case "Punjab":
        return l10n.statePunjab ?? state;
      case "Rajasthan":
        return l10n.stateRajasthan ?? state;
      case "Sikkim":
        return l10n.stateSikkim ?? state;
      case "Tamil Nadu":
        return l10n.stateTamilNadu ?? state;
      case "Telangana":
        return l10n.stateTelangana ?? state;
      case "Tripura":
        return l10n.stateTripura ?? state;
      case "Uttar Pradesh":
        return l10n.stateUttarPradesh ?? state;
      case "Uttarakhand":
        return l10n.stateUttarakhand ?? state;
      case "West Bengal":
        return l10n.stateWestBengal ?? state;
      default:
        return state;
    }
  }

  String _getLocalizedCropName(String commodity, AppLocalizations? l10n) {
    if (l10n == null) return commodity;
    
    // Normalize: lowercase, remove parentheses content, trim
    String normalizedCommodity = commodity
        .toLowerCase()
        .replaceAll(RegExp(r'\(.*?\)'), '')
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .trim();
    
    // Cereals & Grains - check word boundaries
    if (RegExp(r'\b(rice|paddy|chawal)\b').hasMatch(normalizedCommodity)) return l10n.cropRice;
    if (RegExp(r'\b(wheat|gehu|gahu)\b').hasMatch(normalizedCommodity)) return l10n.cropWheat;
    if (RegExp(r'\b(maize|corn|makka)\b').hasMatch(normalizedCommodity)) return l10n.cropMaize;
    if (RegExp(r'\b(barley|jau)\b').hasMatch(normalizedCommodity)) return l10n.cropBarley;
    if (RegExp(r'\b(sorghum|jowar|jola)\b').hasMatch(normalizedCommodity)) return l10n.cropSorghum;
    if (RegExp(r'\b(pearl|bajra|sajje)\b').hasMatch(normalizedCommodity)) return l10n.cropPearl;
    if (RegExp(r'\b(finger|ragi|nachni)\b').hasMatch(normalizedCommodity)) return l10n.cropFinger;
    if (RegExp(r'\b(sorghum|jowar|jola)\b').hasMatch(normalizedCommodity)) return l10n.cropSorghum;
    if (RegExp(r'\b(pearl|bajra|sajje)\b').hasMatch(normalizedCommodity)) return l10n.cropPearl;
    if (RegExp(r'\b(finger|ragi|nachni)\b').hasMatch(normalizedCommodity)) return l10n.cropFinger;
    
    // Vegetables
    if (RegExp(r'\b(onion|pyaz|eerulli)\b').hasMatch(normalizedCommodity)) return l10n.cropOnion;
    if (RegExp(r'\b(tomato|tamatar)\b').hasMatch(normalizedCommodity)) return l10n.cropTomato;
    if (RegExp(r'\b(potato|aloo)\b').hasMatch(normalizedCommodity)) return l10n.cropPotato;
    if (RegExp(r'\b(brinjal|eggplant|baingan)\b').hasMatch(normalizedCommodity)) return l10n.cropBrinjal;
    if (RegExp(r'\b(cauliflower|gobi)\b').hasMatch(normalizedCommodity)) return l10n.cropCauliflower;
    if (RegExp(r'\b(cabbage|patta)\b').hasMatch(normalizedCommodity)) return l10n.cropCabbage;
    if (RegExp(r'\b(carrot|gajar)\b').hasMatch(normalizedCommodity)) return l10n.cropCarrot;
    if (RegExp(r'\b(chilli|chili|mirchi)\b').hasMatch(normalizedCommodity)) return l10n.cropChilli;
    if (RegExp(r'\b(coriander|dhania)\b').hasMatch(normalizedCommodity)) return l10n.cropCoriander;
    if (RegExp(r'\b(garlic|lehsun)\b').hasMatch(normalizedCommodity)) return l10n.cropGarlic;
    if (RegExp(r'\b(ginger|adrak)\b').hasMatch(normalizedCommodity)) return l10n.cropGinger;
    if (RegExp(r'\b(lady.*finger|okra|bhindi)\b').hasMatch(normalizedCommodity)) return l10n.cropLadyFinger;
    if (RegExp(r'\b(turmeric|haldi)\b').hasMatch(normalizedCommodity)) return l10n.cropTurmeric;
    
    // Pulses & Oil Seeds
    if (RegExp(r'\b(groundnut|peanut|moongphali)\b').hasMatch(normalizedCommodity)) return l10n.cropGroundnut;
    if (RegExp(r'\b(soybean|soya)\b').hasMatch(normalizedCommodity)) return l10n.cropSoybean;
    if (RegExp(r'\b(sunflower)\b').hasMatch(normalizedCommodity)) return l10n.cropSunflower;
    if (RegExp(r'\b(mustard|sarson)\b').hasMatch(normalizedCommodity)) return l10n.cropMustard;
    if (RegExp(r'\b(sesame|til)\b').hasMatch(normalizedCommodity)) return l10n.cropSesame;
    if (RegExp(r'\b(castor)\b').hasMatch(normalizedCommodity)) return l10n.cropCastor;
    if (RegExp(r'\b(chickpea|chana|bengal)\b').hasMatch(normalizedCommodity)) return l10n.cropChickpea;
    if (RegExp(r'\b(kidney.*bean|rajma)\b').hasMatch(normalizedCommodity)) return l10n.cropKidneybeans;
    if (RegExp(r'\b(pigeon.*pea|tur|arhar|toor)\b').hasMatch(normalizedCommodity)) return l10n.cropPigeonpeas;
    if (RegExp(r'\b(moth.*bean)\b').hasMatch(normalizedCommodity)) return l10n.cropMothbeans;
    if (RegExp(r'\b(mung.*bean|moong|green.*gram)\b').hasMatch(normalizedCommodity)) return l10n.cropMungbean;
    if (RegExp(r'\b(black.*gram|urad)\b').hasMatch(normalizedCommodity)) return l10n.cropBlackgram;
    if (RegExp(r'\b(lentil|masoor)\b').hasMatch(normalizedCommodity)) return l10n.cropLentil;
    
    // Cash Crops
    if (RegExp(r'\b(sugarcane|sugar.*cane|ganna)\b').hasMatch(normalizedCommodity)) return l10n.cropSugarcane;
    if (RegExp(r'\b(cotton|kapas)\b').hasMatch(normalizedCommodity)) return l10n.cropCotton;
    if (RegExp(r'\b(jute|pat)\b').hasMatch(normalizedCommodity)) return l10n.cropJute;
    if (RegExp(r'\b(tea|chai)\b').hasMatch(normalizedCommodity)) return l10n.cropTea;
    if (RegExp(r'\b(coffee)\b').hasMatch(normalizedCommodity)) return l10n.cropCoffee;
    
    // Fruits
    if (RegExp(r'\b(banana|kela)\b').hasMatch(normalizedCommodity)) return l10n.cropBanana;
    if (RegExp(r'\b(mango|aam)\b').hasMatch(normalizedCommodity)) return l10n.cropMango;
    if (RegExp(r'\b(pomegranate|anar)\b').hasMatch(normalizedCommodity)) return l10n.cropPomegranate;
    if (RegExp(r'\b(grape|angoor)\b').hasMatch(normalizedCommodity)) return l10n.cropGrapes;
    if (RegExp(r'\b(watermelon|tarbooz)\b').hasMatch(normalizedCommodity)) return l10n.cropWatermelon;
    if (RegExp(r'\b(muskmelon|kharbooja)\b').hasMatch(normalizedCommodity)) return l10n.cropMuskmelon;
    if (RegExp(r'\b(apple|seb)\b').hasMatch(normalizedCommodity)) return l10n.cropApple;
    if (RegExp(r'\b(orange|santra)\b').hasMatch(normalizedCommodity)) return l10n.cropOrange;
    if (RegExp(r'\b(papaya)\b').hasMatch(normalizedCommodity)) return l10n.cropPapaya;
    if (RegExp(r'\b(coconut|nariyal)\b').hasMatch(normalizedCommodity)) return l10n.cropCoconut;
    if (RegExp(r'\b(guava|amrud)\b').hasMatch(normalizedCommodity)) return l10n.cropGuava;
    if (RegExp(r'\b(sapota|chiku)\b').hasMatch(normalizedCommodity)) return l10n.cropSapota;
    if (RegExp(r'\b(pineapple|ananas)\b').hasMatch(normalizedCommodity)) return l10n.cropPineapple;
    if (RegExp(r'\b(lemon|nimbu)\b').hasMatch(normalizedCommodity)) return l10n.cropLemon;
    if (RegExp(r'\b(sweet.*lime|mosambi)\b').hasMatch(normalizedCommodity)) return l10n.cropSweet;
    
    // Spices
    if (RegExp(r'\b(cardamom|elaichi)\b').hasMatch(normalizedCommodity)) return l10n.cropCardamom;
    if (RegExp(r'\b(black.*pepper|kali.*mirch)\b').hasMatch(normalizedCommodity)) return l10n.cropBlackPepper;
    if (RegExp(r'\b(betel|beetle|paan)\b').hasMatch(normalizedCommodity)) return l10n.cropBeetleLeaf;
    if (RegExp(r'\b(areca|supari)\b').hasMatch(normalizedCommodity)) return l10n.cropAreca;
    if (RegExp(r'\b(cashew|kaju)\b').hasMatch(normalizedCommodity)) return l10n.cropCashew;
    
    // Gourds & More Vegetables
    if (RegExp(r'\b(cucumber|kheera)\b').hasMatch(normalizedCommodity)) return l10n.cropCucumber;
    if (RegExp(r'\b(bitter.*gourd|karela)\b').hasMatch(normalizedCommodity)) return l10n.cropBitterGourd;
    if (RegExp(r'\b(bottle.*gourd|lauki)\b').hasMatch(normalizedCommodity)) return l10n.cropBottleGourd;
    if (RegExp(r'\b(ridge.*gourd|turai)\b').hasMatch(normalizedCommodity)) return l10n.cropRidgeGourd;
    if (RegExp(r'\b(pumpkin|kaddu)\b').hasMatch(normalizedCommodity)) return l10n.cropPumpkin;
    if (RegExp(r'\b(drumstick|moringa)\b').hasMatch(normalizedCommodity)) return l10n.cropDrumstick;
    if (RegExp(r'\b(bean|sem|french.*bean|field.*bean)\b').hasMatch(normalizedCommodity) && !normalizedCommodity.contains('soy')) return l10n.cropBeans;
    if (RegExp(r'\b(broad.*bean|avare|avarekalu)\b').hasMatch(normalizedCommodity)) return l10n.cropBroadBeans;
    if (RegExp(r'\b(peas|matar)\b').hasMatch(normalizedCommodity)) return l10n.cropPeas;
    if (RegExp(r'\b(radish|mooli|raddish)\b').hasMatch(normalizedCommodity)) return l10n.cropRadish;
    if (RegExp(r'\b(tonde.*kai|tindora|ivy.*gourd|kovakka)\b').hasMatch(normalizedCommodity)) return l10n.cropTondekai;
    if (RegExp(r'\b(arecanut|areca.*nut|betel.*nut|supari|adike)\b').hasMatch(normalizedCommodity)) return l10n.cropAreca;
    if (RegExp(r'\b(horse.*gram|kulthi|kulith|huruli)\b').hasMatch(normalizedCommodity)) return l10n.cropHorseGram;
    if (RegExp(r'\b(soya.*bean|soybean|soya)\b').hasMatch(normalizedCommodity)) return l10n.cropSoybean;
    if (RegExp(r'\b(knol.*khol|knol.*kol|kohlrabi|navil.*kosu)\b').hasMatch(normalizedCommodity)) return l10n.cropKnolKhol;
    if (RegExp(r'\b(green.*avare|hasiru.*avare)\b').hasMatch(normalizedCommodity)) return l10n.cropGreenAvare;
    if (RegExp(r'\b(spinach|palak)\b').hasMatch(normalizedCommodity)) return l10n.cropSpinach;
    if (RegExp(r'\b(fenugreek|methi)\b').hasMatch(normalizedCommodity)) return l10n.cropFenugreek;
    if (RegExp(r'\b(mint|pudina)\b').hasMatch(normalizedCommodity)) return l10n.cropMint;
    if (RegExp(r'\b(curry.*leave|curry.*patta)\b').hasMatch(normalizedCommodity)) return l10n.cropCurryLeaves;
    if (RegExp(r'\b(amaranthus|dantu|green.*leaf|thotakura)\b').hasMatch(normalizedCommodity)) return l10n.cropAmaranthus;
    if (RegExp(r'\b(beetroot|beet|chukandar)\b').hasMatch(normalizedCommodity)) return l10n.cropBeet;
    if (RegExp(r'\b(capsicum|bell.*pepper|simla.*mirch)\b').hasMatch(normalizedCommodity)) return l10n.cropCapsicum;
    if (RegExp(r'\b(chow.*chow|chayote|bangalore.*brinjal|seeme.*badane)\b').hasMatch(normalizedCommodity)) return l10n.cropAshGourd;
    if (RegExp(r'\b(ash.*gourd|petha|white.*gourd|boodu.*gumbal)\b').hasMatch(normalizedCommodity)) return l10n.cropAshGourd;
    if (RegExp(r'\b(snake.*gourd|padaval|pointed.*gourd)\b').hasMatch(normalizedCommodity)) return l10n.cropSnakeGourd;
    if (RegExp(r'\b(cluster.*bean|gavar|gora)\b').hasMatch(normalizedCommodity)) return l10n.cropClusterBeans;
    if (RegExp(r'\b(elephant.*yam|suran|jimikand|senai)\b').hasMatch(normalizedCommodity)) return l10n.cropElephantYam;
    if (RegExp(r'\b(little.*gourd|kundru|ivy.*gourd)\b').hasMatch(normalizedCommodity)) return l10n.cropLittleGourd;
    if (RegExp(r'\b(rat.*tail.*radish|mogari)\b').hasMatch(normalizedCommodity)) return l10n.cropRatTailRadish;
    if (RegExp(r'\b(peas.*cod|peas.*wet|green.*peas)\b').hasMatch(normalizedCommodity)) return l10n.cropPeasCod;
    if (RegExp(r'\b(sweet.*pumpkin)\b').hasMatch(normalizedCommodity)) return l10n.cropSweetPumpkin;
    if (RegExp(r'\b(ridge.*guard|ridge.*gourd|tori|heere)\b').hasMatch(normalizedCommodity)) return l10n.cropRidgeGuard;
    if (RegExp(r'\b(tender.*coconut|coconut.*tender)\b').hasMatch(normalizedCommodity)) return l10n.cropTenderCoconut;
    if (RegExp(r'\b(paddy|dhan|rice.*grain)\b').hasMatch(normalizedCommodity)) return l10n.cropPaddy;
    if (RegExp(r'\b(methi.*leave|fenugreek.*leave)\b').hasMatch(normalizedCommodity)) return l10n.cropMethi;
    if (RegExp(r'\b(turnip|shaljam)\b').hasMatch(normalizedCommodity)) return l10n.cropTurnip;
    if (RegExp(r'\b(papaya.*raw|raw.*papaya)\b').hasMatch(normalizedCommodity)) return l10n.cropPapayaRaw;
    if (RegExp(r'\b(cucumbar|cucumber|kheera)\b').hasMatch(normalizedCommodity)) return l10n.cropCucumber;
    
    // Return original if no match found
    return commodity;
  }

  String _getLocalizedMarketName(String market, AppLocalizations? l10n) {
    if (l10n == null) return market;
    
    // Normalize the market name
    String normalizedMarket = market
        .toLowerCase()
        .replaceAll(RegExp(r'\(.*?\)'), '')
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .trim();
    
    // Common location patterns - translate "Market" suffix
    String result = market;
    
    // Replace common English words
    result = result.replaceAll(RegExp(r'\bMarket\b', caseSensitive: false), 'ಮಾರುಕಟ್ಟೆ');
    result = result.replaceAll(RegExp(r'\bMandi\b', caseSensitive: false), 'ಮಂಡಿ');
    result = result.replaceAll(RegExp(r'\bAPMC\b', caseSensitive: false), 'ಎಪಿಎಂಸಿ');
    result = result.replaceAll(RegExp(r'\bYard\b', caseSensitive: false), 'ಗಜ');
    
    return result;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
