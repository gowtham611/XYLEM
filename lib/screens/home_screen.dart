import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/sensor_data_provider.dart';
import '../providers/govt_schemes_provider.dart';
import '../providers/language_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/market_provider.dart';
import '../screens/monitoring_screen.dart';
import '../screens/prediction_screen.dart';
import '../widgets/government_schemes_widget.dart';
import '../widgets/language_selector_widget.dart';
import '../screens/weather_screen.dart';
import '../screens/market_screen.dart';

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
                  title: Text(
                    ' ',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
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
                  tabs: const [
                    Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                    Tab(icon: Icon(FontAwesomeIcons.chartLine), text: 'Monitor'),
                    Tab(icon: Icon(FontAwesomeIcons.brain), text: 'Predict'),
                    Tab(icon: Icon(FontAwesomeIcons.cloudSun), text: 'Weather'),
                    Tab(icon: Icon(FontAwesomeIcons.store), text: 'Market'),
                    Tab(icon: Icon(FontAwesomeIcons.landmark), text: 'Schemes'),
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
          _buildQuickStatsRow(context),
          const SizedBox(height: 20),
          _buildFeaturesGrid(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
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
                      'Dashboard',
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
                  'Monitor your sensors and get AI-powered crop predictions',
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
                      _buildQuickStat('🌡️', '${currentData.temperature.toStringAsFixed(1)}°C', 'Temperature'),
                      _buildQuickStat('💧', '${currentData.humidity.toStringAsFixed(1)}%', 'Humidity'),
                      _buildQuickStat('🌱', currentData.ph.toStringAsFixed(1), 'Soil pH'),
                    ],
                  )
                else
                  Center(
                    child: Text(
                      'Connect ESP32 sensors to start monitoring',
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

  Widget _buildQuickStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('📊', 'Monitor', 'Live Sensors', Colors.blue, 1)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('🧠', 'Predict', 'AI Crops', Colors.purple, 2)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('🌤️', 'Weather', 'Forecast', Colors.orange, 3)),
      ],
    );
  }

  Widget _buildStatCard(String icon, String action, String subject, Color color, int tabIndex) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _tabController.animateTo(tabIndex),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.1),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                action,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                subject,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final features = [
      {'icon': FontAwesomeIcons.chartLine, 'title': 'Monitor', 'subtitle': 'Live Sensor Data', 'color': const Color(0xFF2196F3), 'tab': 1},
      {'icon': FontAwesomeIcons.brain, 'title': 'Predict', 'subtitle': 'AI Recommendations', 'color': const Color(0xFF9C27B0), 'tab': 2},
      {'icon': FontAwesomeIcons.cloudSun, 'title': 'Weather', 'subtitle': 'Weather Forecast', 'color': const Color(0xFFFF9800), 'tab': 3},
      {'icon': FontAwesomeIcons.store, 'title': 'Market', 'subtitle': 'Price Tracker', 'color': const Color(0xFF4CAF50), 'tab': 4},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
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
              padding: const EdgeInsets.all(16),
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
                children: [
                  Icon(
                    feature['icon'] as IconData,
                    size: 40,
                    color: feature['color'] as Color,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    feature['title'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature['subtitle'] as String,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
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
