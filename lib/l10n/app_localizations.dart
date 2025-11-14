import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kn')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Agriculture Pro'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @sensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get sensors;

  /// No description provided for @assistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistant;

  /// No description provided for @weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @schemes.
  ///
  /// In en, this message translates to:
  /// **'Schemes'**
  String get schemes;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning, Farmer!'**
  String get goodMorning;

  /// No description provided for @farmStatus.
  ///
  /// In en, this message translates to:
  /// **'Your farm is looking great today. Check your sensors and get AI-powered recommendations.'**
  String get farmStatus;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @soilHealth.
  ///
  /// In en, this message translates to:
  /// **'Soil Health'**
  String get soilHealth;

  /// No description provided for @predictedCrop.
  ///
  /// In en, this message translates to:
  /// **'Predicted Crop'**
  String get predictedCrop;

  /// No description provided for @marketPrice.
  ///
  /// In en, this message translates to:
  /// **'Market Price'**
  String get marketPrice;

  /// No description provided for @activeAlerts.
  ///
  /// In en, this message translates to:
  /// **'Active Alerts'**
  String get activeAlerts;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @voiceChatSupport.
  ///
  /// In en, this message translates to:
  /// **'Voice & Chat Support'**
  String get voiceChatSupport;

  /// No description provided for @weatherAlerts.
  ///
  /// In en, this message translates to:
  /// **'Weather Alerts'**
  String get weatherAlerts;

  /// No description provided for @smartForecasting.
  ///
  /// In en, this message translates to:
  /// **'Smart Forecasting'**
  String get smartForecasting;

  /// No description provided for @marketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// No description provided for @connectBuyers.
  ///
  /// In en, this message translates to:
  /// **'Connect with Buyers'**
  String get connectBuyers;

  /// No description provided for @govSchemes.
  ///
  /// In en, this message translates to:
  /// **'Gov. Schemes'**
  String get govSchemes;

  /// No description provided for @subsidyInfo.
  ///
  /// In en, this message translates to:
  /// **'Subsidy Information'**
  String get subsidyInfo;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noSensorData.
  ///
  /// In en, this message translates to:
  /// **'No Sensor Data'**
  String get noSensorData;

  /// No description provided for @connectESP32.
  ///
  /// In en, this message translates to:
  /// **'Connect to ESP32 to start monitoring'**
  String get connectESP32;

  /// No description provided for @startMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Start Monitoring'**
  String get startMonitoring;

  /// No description provided for @stopMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Stop Monitoring'**
  String get stopMonitoring;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @govSchemesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Government Schemes Available'**
  String get govSchemesAvailable;

  /// No description provided for @searchingSchemes.
  ///
  /// In en, this message translates to:
  /// **'Searching schemes for your region...'**
  String get searchingSchemes;

  /// No description provided for @noSchemesFound.
  ///
  /// In en, this message translates to:
  /// **'No schemes found for your region'**
  String get noSchemesFound;

  /// No description provided for @eligibility.
  ///
  /// In en, this message translates to:
  /// **'Eligibility'**
  String get eligibility;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNow;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @kannada.
  ///
  /// In en, this message translates to:
  /// **'ಕನ್ನಡ'**
  String get kannada;

  /// No description provided for @monitor.
  ///
  /// In en, this message translates to:
  /// **'Monitor'**
  String get monitor;

  /// No description provided for @liveSensorData.
  ///
  /// In en, this message translates to:
  /// **'Live Sensor Data'**
  String get liveSensorData;

  /// No description provided for @predict.
  ///
  /// In en, this message translates to:
  /// **'Predict'**
  String get predict;

  /// No description provided for @aiRecommendations.
  ///
  /// In en, this message translates to:
  /// **'AI Recommendations'**
  String get aiRecommendations;

  /// No description provided for @weatherForecast.
  ///
  /// In en, this message translates to:
  /// **'Weather Forecast'**
  String get weatherForecast;

  /// No description provided for @priceTracker.
  ///
  /// In en, this message translates to:
  /// **'Price Tracker'**
  String get priceTracker;

  /// No description provided for @realTimeMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Real-Time Monitoring'**
  String get realTimeMonitoring;

  /// No description provided for @liveSensorDataFromESP32.
  ///
  /// In en, this message translates to:
  /// **'Live sensor data from your ESP32 devices'**
  String get liveSensorDataFromESP32;

  /// No description provided for @noSensorDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Sensor Data'**
  String get noSensorDataAvailable;

  /// No description provided for @connectESP32ToStart.
  ///
  /// In en, this message translates to:
  /// **'Connect your ESP32 sensors to start monitoring'**
  String get connectESP32ToStart;

  /// No description provided for @liveSensorReadings.
  ///
  /// In en, this message translates to:
  /// **'Live Sensor Readings'**
  String get liveSensorReadings;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @soilPH.
  ///
  /// In en, this message translates to:
  /// **'Soil pH'**
  String get soilPH;

  /// No description provided for @moisture.
  ///
  /// In en, this message translates to:
  /// **'Moisture'**
  String get moisture;

  /// No description provided for @nitrogen.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen'**
  String get nitrogen;

  /// No description provided for @phosphorus.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus'**
  String get phosphorus;

  /// No description provided for @potassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium'**
  String get potassium;

  /// No description provided for @sensorStatus.
  ///
  /// In en, this message translates to:
  /// **'Sensor Status'**
  String get sensorStatus;

  /// No description provided for @dataHistory.
  ///
  /// In en, this message translates to:
  /// **'Data History'**
  String get dataHistory;

  /// No description provided for @last24Hours.
  ///
  /// In en, this message translates to:
  /// **'Last 24 Hours'**
  String get last24Hours;

  /// No description provided for @noHistoryData.
  ///
  /// In en, this message translates to:
  /// **'No history data available'**
  String get noHistoryData;

  /// No description provided for @sensorStatusAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Sensor Status Analysis'**
  String get sensorStatusAnalysis;

  /// No description provided for @optimal.
  ///
  /// In en, this message translates to:
  /// **'OPTIMAL'**
  String get optimal;

  /// No description provided for @optimalRange.
  ///
  /// In en, this message translates to:
  /// **'Optimal Range'**
  String get optimalRange;

  /// No description provided for @recentDataLog.
  ///
  /// In en, this message translates to:
  /// **'Recent Data Log'**
  String get recentDataLog;

  /// No description provided for @readings.
  ///
  /// In en, this message translates to:
  /// **'readings'**
  String get readings;

  /// No description provided for @secondsAgo.
  ///
  /// In en, this message translates to:
  /// **'s ago'**
  String get secondsAgo;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'m ago'**
  String get minutesAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get hoursAgo;

  /// No description provided for @prices.
  ///
  /// In en, this message translates to:
  /// **'Prices'**
  String get prices;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @loadingMarketData.
  ///
  /// In en, this message translates to:
  /// **'Loading market data...'**
  String get loadingMarketData;

  /// No description provided for @marketSummary.
  ///
  /// In en, this message translates to:
  /// **'Market Summary'**
  String get marketSummary;

  /// No description provided for @rising.
  ///
  /// In en, this message translates to:
  /// **'Rising'**
  String get rising;

  /// No description provided for @falling.
  ///
  /// In en, this message translates to:
  /// **'Falling'**
  String get falling;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @currentPrices.
  ///
  /// In en, this message translates to:
  /// **'Current Prices'**
  String get currentPrices;

  /// No description provided for @perKg.
  ///
  /// In en, this message translates to:
  /// **'per kg'**
  String get perKg;

  /// No description provided for @priceChange.
  ///
  /// In en, this message translates to:
  /// **'Price Change'**
  String get priceChange;

  /// No description provided for @trendingCrops.
  ///
  /// In en, this message translates to:
  /// **'Trending Crops'**
  String get trendingCrops;

  /// No description provided for @highDemand.
  ///
  /// In en, this message translates to:
  /// **'High Demand'**
  String get highDemand;

  /// No description provided for @priceIncreasing.
  ///
  /// In en, this message translates to:
  /// **'Price Increasing'**
  String get priceIncreasing;

  /// No description provided for @seasonalCrop.
  ///
  /// In en, this message translates to:
  /// **'Seasonal Crop'**
  String get seasonalCrop;

  /// No description provided for @marketNews.
  ///
  /// In en, this message translates to:
  /// **'Market News'**
  String get marketNews;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @marketError.
  ///
  /// In en, this message translates to:
  /// **'Market Error'**
  String get marketError;

  /// No description provided for @selectState.
  ///
  /// In en, this message translates to:
  /// **'Select State'**
  String get selectState;

  /// No description provided for @searchCropOrMarket.
  ///
  /// In en, this message translates to:
  /// **'Search crop or market'**
  String get searchCropOrMarket;

  /// No description provided for @commodityPrices.
  ///
  /// In en, this message translates to:
  /// **'Commodity Prices'**
  String get commodityPrices;

  /// No description provided for @perQuintal.
  ///
  /// In en, this message translates to:
  /// **'quintal'**
  String get perQuintal;

  /// No description provided for @risingPrices.
  ///
  /// In en, this message translates to:
  /// **'Rising Prices'**
  String get risingPrices;

  /// No description provided for @fallingPrices.
  ///
  /// In en, this message translates to:
  /// **'Falling Prices'**
  String get fallingPrices;

  /// No description provided for @noMarketNewsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No market news available'**
  String get noMarketNewsAvailable;

  /// No description provided for @failedToLoadMarketData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load market data'**
  String get failedToLoadMarketData;

  /// No description provided for @stateAndhraPradesh.
  ///
  /// In en, this message translates to:
  /// **'Andhra Pradesh'**
  String get stateAndhraPradesh;

  /// No description provided for @stateArunachalPradesh.
  ///
  /// In en, this message translates to:
  /// **'Arunachal Pradesh'**
  String get stateArunachalPradesh;

  /// No description provided for @stateAssam.
  ///
  /// In en, this message translates to:
  /// **'Assam'**
  String get stateAssam;

  /// No description provided for @stateBihar.
  ///
  /// In en, this message translates to:
  /// **'Bihar'**
  String get stateBihar;

  /// No description provided for @stateChhattisgarh.
  ///
  /// In en, this message translates to:
  /// **'Chhattisgarh'**
  String get stateChhattisgarh;

  /// No description provided for @stateGoa.
  ///
  /// In en, this message translates to:
  /// **'Goa'**
  String get stateGoa;

  /// No description provided for @stateGujarat.
  ///
  /// In en, this message translates to:
  /// **'Gujarat'**
  String get stateGujarat;

  /// No description provided for @stateHaryana.
  ///
  /// In en, this message translates to:
  /// **'Haryana'**
  String get stateHaryana;

  /// No description provided for @stateHimachalPradesh.
  ///
  /// In en, this message translates to:
  /// **'Himachal Pradesh'**
  String get stateHimachalPradesh;

  /// No description provided for @stateJharkhand.
  ///
  /// In en, this message translates to:
  /// **'Jharkhand'**
  String get stateJharkhand;

  /// No description provided for @stateKarnataka.
  ///
  /// In en, this message translates to:
  /// **'Karnataka'**
  String get stateKarnataka;

  /// No description provided for @stateKerala.
  ///
  /// In en, this message translates to:
  /// **'Kerala'**
  String get stateKerala;

  /// No description provided for @stateMadhyaPradesh.
  ///
  /// In en, this message translates to:
  /// **'Madhya Pradesh'**
  String get stateMadhyaPradesh;

  /// No description provided for @stateMaharashtra.
  ///
  /// In en, this message translates to:
  /// **'Maharashtra'**
  String get stateMaharashtra;

  /// No description provided for @stateManipur.
  ///
  /// In en, this message translates to:
  /// **'Manipur'**
  String get stateManipur;

  /// No description provided for @stateMeghalaya.
  ///
  /// In en, this message translates to:
  /// **'Meghalaya'**
  String get stateMeghalaya;

  /// No description provided for @stateMizoram.
  ///
  /// In en, this message translates to:
  /// **'Mizoram'**
  String get stateMizoram;

  /// No description provided for @stateNagaland.
  ///
  /// In en, this message translates to:
  /// **'Nagaland'**
  String get stateNagaland;

  /// No description provided for @stateOdisha.
  ///
  /// In en, this message translates to:
  /// **'Odisha'**
  String get stateOdisha;

  /// No description provided for @statePunjab.
  ///
  /// In en, this message translates to:
  /// **'Punjab'**
  String get statePunjab;

  /// No description provided for @stateRajasthan.
  ///
  /// In en, this message translates to:
  /// **'Rajasthan'**
  String get stateRajasthan;

  /// No description provided for @stateSikkim.
  ///
  /// In en, this message translates to:
  /// **'Sikkim'**
  String get stateSikkim;

  /// No description provided for @stateTamilNadu.
  ///
  /// In en, this message translates to:
  /// **'Tamil Nadu'**
  String get stateTamilNadu;

  /// No description provided for @stateTelangana.
  ///
  /// In en, this message translates to:
  /// **'Telangana'**
  String get stateTelangana;

  /// No description provided for @stateTripura.
  ///
  /// In en, this message translates to:
  /// **'Tripura'**
  String get stateTripura;

  /// No description provided for @stateUttarPradesh.
  ///
  /// In en, this message translates to:
  /// **'Uttar Pradesh'**
  String get stateUttarPradesh;

  /// No description provided for @stateUttarakhand.
  ///
  /// In en, this message translates to:
  /// **'Uttarakhand'**
  String get stateUttarakhand;

  /// No description provided for @stateWestBengal.
  ///
  /// In en, this message translates to:
  /// **'West Bengal'**
  String get stateWestBengal;

  /// No description provided for @loadingWeatherData.
  ///
  /// In en, this message translates to:
  /// **'Loading weather data...'**
  String get loadingWeatherData;

  /// No description provided for @weatherError.
  ///
  /// In en, this message translates to:
  /// **'Weather Error'**
  String get weatherError;

  /// No description provided for @noWeatherData.
  ///
  /// In en, this message translates to:
  /// **'No Weather Data'**
  String get noWeatherData;

  /// No description provided for @weatherDetails.
  ///
  /// In en, this message translates to:
  /// **'Weather Details'**
  String get weatherDetails;

  /// No description provided for @windSpeed.
  ///
  /// In en, this message translates to:
  /// **'Wind Speed'**
  String get windSpeed;

  /// No description provided for @visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibility;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels Like'**
  String get feelsLike;

  /// No description provided for @farmingRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Farming Recommendations'**
  String get farmingRecommendations;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updatedAt;

  /// No description provided for @aiCropAdvisor.
  ///
  /// In en, this message translates to:
  /// **'AI Crop Advisor'**
  String get aiCropAdvisor;

  /// No description provided for @intelligentCropPrediction.
  ///
  /// In en, this message translates to:
  /// **'Intelligent crop prediction & recommendations'**
  String get intelligentCropPrediction;

  /// No description provided for @checkOnnxRuntime.
  ///
  /// In en, this message translates to:
  /// **'Check ONNX Runtime'**
  String get checkOnnxRuntime;

  /// No description provided for @runAIPrediction.
  ///
  /// In en, this message translates to:
  /// **'Run AI Prediction'**
  String get runAIPrediction;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running...'**
  String get running;

  /// No description provided for @simulate.
  ///
  /// In en, this message translates to:
  /// **'Simulate'**
  String get simulate;

  /// No description provided for @noPredictionsYet.
  ///
  /// In en, this message translates to:
  /// **'No predictions yet'**
  String get noPredictionsYet;

  /// No description provided for @noPredictionData.
  ///
  /// In en, this message translates to:
  /// **'No Prediction Data'**
  String get noPredictionData;

  /// No description provided for @connectSensorsOrSimulate.
  ///
  /// In en, this message translates to:
  /// **'Connect sensors or start simulation to get predictions'**
  String get connectSensorsOrSimulate;

  /// No description provided for @suitability.
  ///
  /// In en, this message translates to:
  /// **'Suitability'**
  String get suitability;

  /// No description provided for @soilQuality.
  ///
  /// In en, this message translates to:
  /// **'Soil Quality'**
  String get soilQuality;

  /// No description provided for @growthPotential.
  ///
  /// In en, this message translates to:
  /// **'Growth Potential'**
  String get growthPotential;

  /// No description provided for @riskLevel.
  ///
  /// In en, this message translates to:
  /// **'Risk Level'**
  String get riskLevel;

  /// No description provided for @seasonMatch.
  ///
  /// In en, this message translates to:
  /// **'Season Match'**
  String get seasonMatch;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @veryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very High'**
  String get veryHigh;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @tomatoes.
  ///
  /// In en, this message translates to:
  /// **'Tomatoes'**
  String get tomatoes;

  /// No description provided for @potatoes.
  ///
  /// In en, this message translates to:
  /// **'Potatoes'**
  String get potatoes;

  /// No description provided for @leafyGreens.
  ///
  /// In en, this message translates to:
  /// **'Leafy Greens'**
  String get leafyGreens;

  /// No description provided for @peppers.
  ///
  /// In en, this message translates to:
  /// **'Peppers'**
  String get peppers;

  /// No description provided for @legumes.
  ///
  /// In en, this message translates to:
  /// **'Legumes'**
  String get legumes;

  /// No description provided for @herbs.
  ///
  /// In en, this message translates to:
  /// **'Herbs'**
  String get herbs;

  /// No description provided for @optimalPHHighNitrogen.
  ///
  /// In en, this message translates to:
  /// **'Optimal pH and high nitrogen levels'**
  String get optimalPHHighNitrogen;

  /// No description provided for @goodPHPhosphorus.
  ///
  /// In en, this message translates to:
  /// **'Good pH and phosphorus levels'**
  String get goodPHPhosphorus;

  /// No description provided for @highNitrogenMoisture.
  ///
  /// In en, this message translates to:
  /// **'High nitrogen and moisture content'**
  String get highNitrogenMoisture;

  /// No description provided for @goodPHPotassium.
  ///
  /// In en, this message translates to:
  /// **'Good pH and potassium levels'**
  String get goodPHPotassium;

  /// No description provided for @nitrogenFixers.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen fixers, improve soil quality'**
  String get nitrogenFixers;

  /// No description provided for @adaptableToSoil.
  ///
  /// In en, this message translates to:
  /// **'Adaptable to various soil conditions'**
  String get adaptableToSoil;

  /// No description provided for @governmentSchemesScreen.
  ///
  /// In en, this message translates to:
  /// **'Government Schemes Screen'**
  String get governmentSchemesScreen;

  /// No description provided for @sensorConnection.
  ///
  /// In en, this message translates to:
  /// **'Sensor Connection'**
  String get sensorConnection;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @dataPoints.
  ///
  /// In en, this message translates to:
  /// **'Data Points'**
  String get dataPoints;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @connectToESP32ForRealData.
  ///
  /// In en, this message translates to:
  /// **'Connect to ESP32 for real sensor data:'**
  String get connectToESP32ForRealData;

  /// No description provided for @esp32IPAddress.
  ///
  /// In en, this message translates to:
  /// **'ESP32 IP Address'**
  String get esp32IPAddress;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @connectToESP32Button.
  ///
  /// In en, this message translates to:
  /// **'Connect to ESP32'**
  String get connectToESP32Button;

  /// No description provided for @useTestData.
  ///
  /// In en, this message translates to:
  /// **'Use Test Data'**
  String get useTestData;

  /// No description provided for @testDataModeActive.
  ///
  /// In en, this message translates to:
  /// **'Test Data Mode Active'**
  String get testDataModeActive;

  /// No description provided for @stopTest.
  ///
  /// In en, this message translates to:
  /// **'Stop Test'**
  String get stopTest;

  /// No description provided for @usingSimulatedData.
  ///
  /// In en, this message translates to:
  /// **'Using simulated sensor data for testing purposes.'**
  String get usingSimulatedData;

  /// No description provided for @esp32Connected.
  ///
  /// In en, this message translates to:
  /// **'ESP32 Connected'**
  String get esp32Connected;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @receivingLiveData.
  ///
  /// In en, this message translates to:
  /// **'Receiving live data from ESP32 every 3 seconds.'**
  String get receivingLiveData;

  /// No description provided for @connectingToESP32.
  ///
  /// In en, this message translates to:
  /// **'Connecting to ESP32...'**
  String get connectingToESP32;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection Error:'**
  String get connectionError;

  /// No description provided for @latestSensorReading.
  ///
  /// In en, this message translates to:
  /// **'Latest Sensor Reading:'**
  String get latestSensorReading;

  /// No description provided for @simulationModeActive.
  ///
  /// In en, this message translates to:
  /// **'Simulation Mode Active'**
  String get simulationModeActive;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @aiCropAdvisorTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Crop Advisor'**
  String get aiCropAdvisorTitle;

  /// No description provided for @smartCropPredictions.
  ///
  /// In en, this message translates to:
  /// **'Smart crop predictions · Soil insights · Farming tips'**
  String get smartCropPredictions;

  /// No description provided for @runningDots.
  ///
  /// In en, this message translates to:
  /// **'Running...'**
  String get runningDots;

  /// No description provided for @runAIPredictionButton.
  ///
  /// In en, this message translates to:
  /// **'Run AI Prediction'**
  String get runAIPredictionButton;

  /// No description provided for @simulateButton.
  ///
  /// In en, this message translates to:
  /// **'Simulate'**
  String get simulateButton;

  /// No description provided for @noPredictionsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No predictions yet'**
  String get noPredictionsYetTitle;

  /// No description provided for @runAIPredictionToSeeResults.
  ///
  /// In en, this message translates to:
  /// **'Run the AI prediction to see results'**
  String get runAIPredictionToSeeResults;

  /// No description provided for @predictionError.
  ///
  /// In en, this message translates to:
  /// **'Prediction error:'**
  String get predictionError;

  /// No description provided for @noPredictionDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Prediction Data'**
  String get noPredictionDataTitle;

  /// No description provided for @connectSensorsOrStartSimulation.
  ///
  /// In en, this message translates to:
  /// **'Connect sensors or start simulation to get predictions'**
  String get connectSensorsOrStartSimulation;

  /// No description provided for @startingDots.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get startingDots;

  /// No description provided for @simulateAndRun.
  ///
  /// In en, this message translates to:
  /// **'Simulate & Run'**
  String get simulateAndRun;

  /// No description provided for @recommendedCropsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended Crops'**
  String get recommendedCropsTitle;

  /// No description provided for @modelRecommendationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Model recommendation'**
  String get modelRecommendationSubtitle;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidenceLabel;

  /// No description provided for @topAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Top alternatives'**
  String get topAlternatives;

  /// No description provided for @soilLabel.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get soilLabel;

  /// No description provided for @issuesLabel.
  ///
  /// In en, this message translates to:
  /// **'issues'**
  String get issuesLabel;

  /// No description provided for @tipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tipsLabel;

  /// No description provided for @primaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primaryLabel;

  /// No description provided for @advisoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Advisory'**
  String get advisoryLabel;

  /// No description provided for @viewSoilRecommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'View soil recommendations'**
  String get viewSoilRecommendationsTitle;

  /// No description provided for @noMajorSoilIssues.
  ///
  /// In en, this message translates to:
  /// **'No major soil issues detected.'**
  String get noMajorSoilIssues;

  /// No description provided for @optimalPHHighNitrogenReason.
  ///
  /// In en, this message translates to:
  /// **'Optimal pH and high nitrogen levels'**
  String get optimalPHHighNitrogenReason;

  /// No description provided for @goodPHPhosphorusReason.
  ///
  /// In en, this message translates to:
  /// **'Good pH and phosphorus levels'**
  String get goodPHPhosphorusReason;

  /// No description provided for @highNitrogenMoistureReason.
  ///
  /// In en, this message translates to:
  /// **'High nitrogen and moisture content'**
  String get highNitrogenMoistureReason;

  /// No description provided for @goodPHPotassiumReason.
  ///
  /// In en, this message translates to:
  /// **'Good pH and potassium levels'**
  String get goodPHPotassiumReason;

  /// No description provided for @nitrogenFixersReason.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen fixers, improve soil quality'**
  String get nitrogenFixersReason;

  /// No description provided for @adaptableToSoilReason.
  ///
  /// In en, this message translates to:
  /// **'Adaptable to various soil conditions'**
  String get adaptableToSoilReason;

  /// No description provided for @cropTomatoes.
  ///
  /// In en, this message translates to:
  /// **'Tomatoes'**
  String get cropTomatoes;

  /// No description provided for @cropPotatoes.
  ///
  /// In en, this message translates to:
  /// **'Potatoes'**
  String get cropPotatoes;

  /// No description provided for @cropLeafyGreens.
  ///
  /// In en, this message translates to:
  /// **'Leafy Greens'**
  String get cropLeafyGreens;

  /// No description provided for @cropPeppers.
  ///
  /// In en, this message translates to:
  /// **'Peppers'**
  String get cropPeppers;

  /// No description provided for @cropLegumes.
  ///
  /// In en, this message translates to:
  /// **'Legumes'**
  String get cropLegumes;

  /// No description provided for @cropHerbs.
  ///
  /// In en, this message translates to:
  /// **'Herbs'**
  String get cropHerbs;

  /// No description provided for @cropRice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get cropRice;

  /// No description provided for @cropMaize.
  ///
  /// In en, this message translates to:
  /// **'Maize'**
  String get cropMaize;

  /// No description provided for @cropChickpea.
  ///
  /// In en, this message translates to:
  /// **'Chickpea'**
  String get cropChickpea;

  /// No description provided for @cropKidneybeans.
  ///
  /// In en, this message translates to:
  /// **'Kidney Beans'**
  String get cropKidneybeans;

  /// No description provided for @cropPigeonpeas.
  ///
  /// In en, this message translates to:
  /// **'Pigeon Peas'**
  String get cropPigeonpeas;

  /// No description provided for @cropMothbeans.
  ///
  /// In en, this message translates to:
  /// **'Moth Beans'**
  String get cropMothbeans;

  /// No description provided for @cropMungbean.
  ///
  /// In en, this message translates to:
  /// **'Mung Bean'**
  String get cropMungbean;

  /// No description provided for @cropBlackgram.
  ///
  /// In en, this message translates to:
  /// **'Black Gram'**
  String get cropBlackgram;

  /// No description provided for @cropLentil.
  ///
  /// In en, this message translates to:
  /// **'Lentil'**
  String get cropLentil;

  /// No description provided for @cropPomegranate.
  ///
  /// In en, this message translates to:
  /// **'Pomegranate'**
  String get cropPomegranate;

  /// No description provided for @cropBanana.
  ///
  /// In en, this message translates to:
  /// **'Banana'**
  String get cropBanana;

  /// No description provided for @cropMango.
  ///
  /// In en, this message translates to:
  /// **'Mango'**
  String get cropMango;

  /// No description provided for @cropGrapes.
  ///
  /// In en, this message translates to:
  /// **'Grapes'**
  String get cropGrapes;

  /// No description provided for @cropWatermelon.
  ///
  /// In en, this message translates to:
  /// **'Watermelon'**
  String get cropWatermelon;

  /// No description provided for @cropMuskmelon.
  ///
  /// In en, this message translates to:
  /// **'Muskmelon'**
  String get cropMuskmelon;

  /// No description provided for @cropApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get cropApple;

  /// No description provided for @cropOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get cropOrange;

  /// No description provided for @cropPapaya.
  ///
  /// In en, this message translates to:
  /// **'Papaya'**
  String get cropPapaya;

  /// No description provided for @cropCoconut.
  ///
  /// In en, this message translates to:
  /// **'Coconut'**
  String get cropCoconut;

  /// No description provided for @cropCotton.
  ///
  /// In en, this message translates to:
  /// **'Cotton'**
  String get cropCotton;

  /// No description provided for @cropJute.
  ///
  /// In en, this message translates to:
  /// **'Jute'**
  String get cropJute;

  /// No description provided for @cropCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get cropCoffee;

  /// No description provided for @cropWheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get cropWheat;

  /// No description provided for @cropBarley.
  ///
  /// In en, this message translates to:
  /// **'Barley'**
  String get cropBarley;

  /// No description provided for @cropSorghum.
  ///
  /// In en, this message translates to:
  /// **'Sorghum'**
  String get cropSorghum;

  /// No description provided for @cropPearl.
  ///
  /// In en, this message translates to:
  /// **'Pearl Millet'**
  String get cropPearl;

  /// No description provided for @cropFinger.
  ///
  /// In en, this message translates to:
  /// **'Finger Millet'**
  String get cropFinger;

  /// No description provided for @cropOnion.
  ///
  /// In en, this message translates to:
  /// **'Onion'**
  String get cropOnion;

  /// No description provided for @cropTomato.
  ///
  /// In en, this message translates to:
  /// **'Tomato'**
  String get cropTomato;

  /// No description provided for @cropPotato.
  ///
  /// In en, this message translates to:
  /// **'Potato'**
  String get cropPotato;

  /// No description provided for @cropBrinjal.
  ///
  /// In en, this message translates to:
  /// **'Brinjal'**
  String get cropBrinjal;

  /// No description provided for @cropCauliflower.
  ///
  /// In en, this message translates to:
  /// **'Cauliflower'**
  String get cropCauliflower;

  /// No description provided for @cropCabbage.
  ///
  /// In en, this message translates to:
  /// **'Cabbage'**
  String get cropCabbage;

  /// No description provided for @cropCarrot.
  ///
  /// In en, this message translates to:
  /// **'Carrot'**
  String get cropCarrot;

  /// No description provided for @cropChilli.
  ///
  /// In en, this message translates to:
  /// **'Chilli'**
  String get cropChilli;

  /// No description provided for @cropCoriander.
  ///
  /// In en, this message translates to:
  /// **'Coriander'**
  String get cropCoriander;

  /// No description provided for @cropGarlic.
  ///
  /// In en, this message translates to:
  /// **'Garlic'**
  String get cropGarlic;

  /// No description provided for @cropGinger.
  ///
  /// In en, this message translates to:
  /// **'Ginger'**
  String get cropGinger;

  /// No description provided for @cropLadyFinger.
  ///
  /// In en, this message translates to:
  /// **'Lady Finger'**
  String get cropLadyFinger;

  /// No description provided for @cropTurmeric.
  ///
  /// In en, this message translates to:
  /// **'Turmeric'**
  String get cropTurmeric;

  /// No description provided for @cropGroundnut.
  ///
  /// In en, this message translates to:
  /// **'Groundnut'**
  String get cropGroundnut;

  /// No description provided for @cropSoybean.
  ///
  /// In en, this message translates to:
  /// **'Soybean'**
  String get cropSoybean;

  /// No description provided for @cropSunflower.
  ///
  /// In en, this message translates to:
  /// **'Sunflower'**
  String get cropSunflower;

  /// No description provided for @cropMustard.
  ///
  /// In en, this message translates to:
  /// **'Mustard'**
  String get cropMustard;

  /// No description provided for @cropSesame.
  ///
  /// In en, this message translates to:
  /// **'Sesame'**
  String get cropSesame;

  /// No description provided for @cropCastor.
  ///
  /// In en, this message translates to:
  /// **'Castor'**
  String get cropCastor;

  /// No description provided for @cropSugarcane.
  ///
  /// In en, this message translates to:
  /// **'Sugarcane'**
  String get cropSugarcane;

  /// No description provided for @cropTea.
  ///
  /// In en, this message translates to:
  /// **'Tea'**
  String get cropTea;

  /// No description provided for @cropCardamom.
  ///
  /// In en, this message translates to:
  /// **'Cardamom'**
  String get cropCardamom;

  /// No description provided for @cropBlackPepper.
  ///
  /// In en, this message translates to:
  /// **'Black Pepper'**
  String get cropBlackPepper;

  /// No description provided for @cropBeetleLeaf.
  ///
  /// In en, this message translates to:
  /// **'Beetle Leaf'**
  String get cropBeetleLeaf;

  /// No description provided for @cropAreca.
  ///
  /// In en, this message translates to:
  /// **'Areca Nut'**
  String get cropAreca;

  /// No description provided for @cropCashew.
  ///
  /// In en, this message translates to:
  /// **'Cashew'**
  String get cropCashew;

  /// No description provided for @cropGuava.
  ///
  /// In en, this message translates to:
  /// **'Guava'**
  String get cropGuava;

  /// No description provided for @cropSapota.
  ///
  /// In en, this message translates to:
  /// **'Sapota'**
  String get cropSapota;

  /// No description provided for @cropPineapple.
  ///
  /// In en, this message translates to:
  /// **'Pineapple'**
  String get cropPineapple;

  /// No description provided for @cropLemon.
  ///
  /// In en, this message translates to:
  /// **'Lemon'**
  String get cropLemon;

  /// No description provided for @cropSweet.
  ///
  /// In en, this message translates to:
  /// **'Sweet Lime'**
  String get cropSweet;

  /// No description provided for @cropCucumber.
  ///
  /// In en, this message translates to:
  /// **'Cucumber'**
  String get cropCucumber;

  /// No description provided for @cropBitterGourd.
  ///
  /// In en, this message translates to:
  /// **'Bitter Gourd'**
  String get cropBitterGourd;

  /// No description provided for @cropBottleGourd.
  ///
  /// In en, this message translates to:
  /// **'Bottle Gourd'**
  String get cropBottleGourd;

  /// No description provided for @cropRidgeGourd.
  ///
  /// In en, this message translates to:
  /// **'Ridge Gourd'**
  String get cropRidgeGourd;

  /// No description provided for @cropPumpkin.
  ///
  /// In en, this message translates to:
  /// **'Pumpkin'**
  String get cropPumpkin;

  /// No description provided for @cropDrumstick.
  ///
  /// In en, this message translates to:
  /// **'Drumstick'**
  String get cropDrumstick;

  /// No description provided for @cropBeans.
  ///
  /// In en, this message translates to:
  /// **'Beans'**
  String get cropBeans;

  /// No description provided for @cropPeas.
  ///
  /// In en, this message translates to:
  /// **'Peas'**
  String get cropPeas;

  /// No description provided for @cropRadish.
  ///
  /// In en, this message translates to:
  /// **'Radish'**
  String get cropRadish;

  /// No description provided for @cropSpinach.
  ///
  /// In en, this message translates to:
  /// **'Spinach'**
  String get cropSpinach;

  /// No description provided for @cropFenugreek.
  ///
  /// In en, this message translates to:
  /// **'Fenugreek'**
  String get cropFenugreek;

  /// No description provided for @cropMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get cropMint;

  /// No description provided for @cropCurryLeaves.
  ///
  /// In en, this message translates to:
  /// **'Curry Leaves'**
  String get cropCurryLeaves;

  /// No description provided for @cropAshGourd.
  ///
  /// In en, this message translates to:
  /// **'Ashgourd'**
  String get cropAshGourd;

  /// No description provided for @cropAmaranthus.
  ///
  /// In en, this message translates to:
  /// **'Amaranthus'**
  String get cropAmaranthus;

  /// No description provided for @cropCapsicum.
  ///
  /// In en, this message translates to:
  /// **'Capsicum'**
  String get cropCapsicum;

  /// No description provided for @cropBeet.
  ///
  /// In en, this message translates to:
  /// **'Beetroot'**
  String get cropBeet;

  /// No description provided for @cropSnakeGourd.
  ///
  /// In en, this message translates to:
  /// **'Snake Gourd'**
  String get cropSnakeGourd;

  /// No description provided for @cropClusterBeans.
  ///
  /// In en, this message translates to:
  /// **'Cluster Beans'**
  String get cropClusterBeans;

  /// No description provided for @cropElephantYam.
  ///
  /// In en, this message translates to:
  /// **'Elephant Yam'**
  String get cropElephantYam;

  /// No description provided for @cropLittleGourd.
  ///
  /// In en, this message translates to:
  /// **'Little Gourd'**
  String get cropLittleGourd;

  /// No description provided for @cropRatTailRadish.
  ///
  /// In en, this message translates to:
  /// **'Rat Tail Radish'**
  String get cropRatTailRadish;

  /// No description provided for @cropPeasCod.
  ///
  /// In en, this message translates to:
  /// **'Peas'**
  String get cropPeasCod;

  /// No description provided for @cropSweetPumpkin.
  ///
  /// In en, this message translates to:
  /// **'Sweet Pumpkin'**
  String get cropSweetPumpkin;

  /// No description provided for @cropRidgeGuard.
  ///
  /// In en, this message translates to:
  /// **'Ridge Gourd'**
  String get cropRidgeGuard;

  /// No description provided for @cropTenderCoconut.
  ///
  /// In en, this message translates to:
  /// **'Tender Coconut'**
  String get cropTenderCoconut;

  /// No description provided for @cropPaddy.
  ///
  /// In en, this message translates to:
  /// **'Paddy'**
  String get cropPaddy;

  /// No description provided for @cropMethi.
  ///
  /// In en, this message translates to:
  /// **'Fenugreek Leaves'**
  String get cropMethi;

  /// No description provided for @cropTurnip.
  ///
  /// In en, this message translates to:
  /// **'Turnip'**
  String get cropTurnip;

  /// No description provided for @cropPapayaRaw.
  ///
  /// In en, this message translates to:
  /// **'Raw Papaya'**
  String get cropPapayaRaw;

  /// No description provided for @cropBroadBeans.
  ///
  /// In en, this message translates to:
  /// **'Broad Beans'**
  String get cropBroadBeans;

  /// No description provided for @cropTondekai.
  ///
  /// In en, this message translates to:
  /// **'Ivy Gourd'**
  String get cropTondekai;

  /// No description provided for @cropHorseGram.
  ///
  /// In en, this message translates to:
  /// **'Horse Gram'**
  String get cropHorseGram;

  /// No description provided for @cropKnolKhol.
  ///
  /// In en, this message translates to:
  /// **'Knol Khol'**
  String get cropKnolKhol;

  /// No description provided for @cropGreenAvare.
  ///
  /// In en, this message translates to:
  /// **'Green Avare'**
  String get cropGreenAvare;

  /// No description provided for @soil.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get soil;

  /// No description provided for @overall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get overall;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
