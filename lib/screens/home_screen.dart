import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/sensor_data_provider.dart';
import '../providers/govt_schemes_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/market_provider.dart';
import '../screens/monitoring_screen.dart';
import '../screens/prediction_screen.dart';
import '../widgets/government_schemes_widget.dart';
import '../widgets/language_selector_widget.dart';
import '../screens/weather_screen.dart';
import '../screens/market_screen.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // Updated to 6 tabs
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GovtSchemesProvider>(context, listen: false).fetchSchemes();
      Provider.of<WeatherProvider>(context, listen: false).fetchWeather();
      Provider.of<MarketProvider>(context, listen: false).fetchMarketData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: DefaultTabController(
        length: 6,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.language, color: Colors.white),
                    onPressed: () {
                      _showLanguageSelector(context);
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                          
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        FontAwesomeIcons.seedling,
                        size: 60,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(icon: const Icon(Icons.dashboard), text: l10n?.dashboard ?? 'Dashboard'),
                    Tab(icon: const Icon(FontAwesomeIcons.chartLine), text: l10n?.sensors ?? 'Monitor'),
                    Tab(icon: const Icon(FontAwesomeIcons.brain), text: l10n?.predictedCrop ?? 'Predict'),
                    Tab(icon: const Icon(FontAwesomeIcons.cloudSun), text: l10n?.weather ?? 'Weather'),
                    Tab(icon: const Icon(FontAwesomeIcons.store), text: l10n?.market ?? 'Market'),
                    Tab(icon: const Icon(FontAwesomeIcons.landmark), text: l10n?.schemes ?? 'Schemes'),
                  ],
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3.0,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardTab(context),
              const MonitoringScreen(),        // New dedicated monitoring screen
              const PredictionScreen(),        // New dedicated prediction screen
              const WeatherScreen(),
              const MarketScreen(),
              const GovernmentSchemesWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(context),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          _buildFeaturesGrid(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<SensorDataProvider>(
      builder: (context, sensorProvider, child) {
        final currentData = sensorProvider.currentData;
        
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2),
                          Color(0xFF42A5F5),],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.seedling, color: Colors.white, size: 30),
                    const SizedBox(width: 10),
                    Text(
                      l10n?.goodMorning ?? 'Good Morning, Farmer!',
                      style: GoogleFonts.roboto(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  l10n?.farmStatus ?? 'Your farm is looking great today. Check your sensors and get AI-powered recommendations.',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 15),
                if (currentData != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat('🌡️', '${currentData.temperature.toStringAsFixed(1)}°C', l10n?.temperature ?? 'Temperature'),
                      _buildQuickStat('💧', '${currentData.humidity.toStringAsFixed(1)}%', l10n?.humidity ?? 'Humidity'),
                      _buildQuickStat('🌱', currentData.ph.toStringAsFixed(1), 'Soil pH'),
                    ],
                  )
                else
                  Center(
                    child: Text(
                      l10n?.connectESP32 ?? 'Connect ESP32 sensors to start monitoring',
                      style: GoogleFonts.roboto(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final features = [
      {'icon': FontAwesomeIcons.chartLine, 'title': l10n?.monitor ?? 'Monitor', 'subtitle': l10n?.liveSensorData ?? 'Live Sensor Data', 'color': const Color(0xFF2196F3), 'tab': 1},
      {'icon': FontAwesomeIcons.brain, 'title': l10n?.predict ?? 'Predict', 'subtitle': l10n?.aiRecommendations ?? 'AI Recommendations', 'color': const Color(0xFF9C27B0), 'tab': 2},
      {'icon': FontAwesomeIcons.cloudSun, 'title': l10n?.weather ?? 'Weather', 'subtitle': l10n?.weatherForecast ?? 'Weather Forecast', 'color': const Color(0xFFFF9800), 'tab': 3},
      {'icon': FontAwesomeIcons.store, 'title': l10n?.market ?? 'Market', 'subtitle': l10n?.priceTracker ?? 'Price Tracker', 'color': const Color(0xFF4CAF50), 'tab': 4},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
              _tabController.animateTo(feature['tab'] as int);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    (feature['color'] as Color).withOpacity(0.1),
                    (feature['color'] as Color).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    feature['icon'] as IconData,
                    size: 36,
                    color: feature['color'] as Color,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    feature['title'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    feature['subtitle'] as String,
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  
  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const LanguageSelectorWidget(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
