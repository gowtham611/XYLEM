# XYLEM 🌱

**Edge-Powered XAI-Based Crop Recommendation System**

XYLEM is an innovative mobile application designed to empower farmers with intelligent crop management solutions. Built with Flutter and powered by on-device machine learning, XYLEM provides real-time crop recommendations, monitoring, and agricultural insights—all running directly on your mobile device without requiring constant internet connectivity.

---

## 🎯 Overview

XYLEM combines cutting-edge technology with agricultural expertise to help farmers make data-driven decisions. The application integrates with a 7-in-1 sensor system to collect real-world data from your fields and processes it using an on-device AI model to provide actionable insights.

### Why XYLEM?

- **Edge Computing**: Machine learning models run directly on your mobile device for faster, more private predictions
- **Real-Time Monitoring**: Live sensor data from your fields
- **Comprehensive Insights**: From crop recommendations to market prices and weather updates
- **Farmer-Friendly**: Designed specifically for farmers with an intuitive interface
- **Offline Capable**: Core AI features work without internet connectivity

---

## ✨ Key Features

### 📊 **Dashboard**
Central hub for all your farming data and quick access to all features

### 🔗 **Connection Screen**
Seamlessly connect your mobile app to the 7-in-1 sensor system deployed in your field

### 🌾 **Crop Recommendation**
- AI-powered crop suggestions based on real-world soil and environmental data
- Detailed descriptions of recommended crops
- Explainable AI (XAI) insights into why certain crops are recommended

### 💰 **Market Price Monitoring**
Live market prices for various crops to help you make informed selling decisions

### 🌤️ **Weather Monitoring**
Real-time weather data and forecasts to plan your farming activities

### 📰 **Farming News**
Stay updated with the latest news and trends in agriculture

### 🤖 **On-Device Machine Learning**
ML model runs directly on your mobile device for:
- Privacy-first approach
- Faster predictions
- Reduced dependency on internet connectivity

---

## 🛠️ Technology Stack

- **Frontend**: Flutter (Dart)
- **Machine Learning**: On-device ML models
- **Hardware Integration**: 7-in-1 Sensor System
- **Platform Support**: Android & iOS (via Flutter)

### Language Composition
- Dart: 70.5%
- HTML: 20.8%
- C++: 3.6%
- CMake: 2.7%
- Jupyter Notebook: 0.9%
- Kotlin: 0.9%
- Other: 0.6%

---

## 📱 Application Screens

1. **Dashboard** - Overview of all farming metrics
2. **Connection Screen** - Sensor pairing and connectivity
3. **Recommendation Screen** - AI-powered crop suggestions
4. **Market Price Monitoring** - Live crop pricing data
5. **Weather Monitoring** - Real-time weather information

---

## 🔧 Hardware Requirements

### 7-in-1 Sensor System
The XYLEM system includes a multi-parameter sensor that measures:

1. **Temperature** - Soil and ambient temperature
2. **pH Level** - Soil acidity/alkalinity
3. **Humidity** - Soil and air humidity
4. **Rainfall** - Precipitation measurement
5. **Nitrogen (N)** - Soil nitrogen content
6. **Phosphorus (P)** - Soil phosphorus content
7. **Potassium (K)** - Soil potassium content

---

## 🚀 Getting Started

### For Farmers (End Users)

#### Step 1: Install the Application
Download and install the XYLEM mobile app on your Android or iOS device.

#### Step 2: Deploy Sensors
Place the 7-in-1 sensor system in your field according to the provided guidelines.

#### Step 3: Connect to Sensors
1. Open the XYLEM app
2. Navigate to the Connection Screen
3. Follow the on-screen instructions to pair your device with the sensors
4. Wait for the confirmation message

#### Step 4: Start Monitoring
Once connected, you're all set! The app will automatically:
- Collect real-time data from your field
- Provide crop recommendations
- Display market prices and weather information
- Keep you updated with farming news

### For Developers

#### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Git

#### Installation

```bash
# Clone the repository
git clone https://github.com/gowtham611/XYLEM.git

# Navigate to project directory
cd XYLEM

# Install dependencies
flutter pub get

# Run the application
flutter run
```

#### Building for Production

```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

---

## 📊 How It Works

```
┌─────────────────┐
│  7-in-1 Sensor  │
│   (In Field)    │
└────────┬────────┘
         │
         │ Bluetooth/IoT
         ▼
┌─────────────────┐
│   Mobile App    │
│   (Flutter)     │
└────────┬────────┘
         │
         │ On-Device Processing
         ▼
┌─────────────────┐
│   ML Model      │
│  (Edge AI)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Recommendations │
│   & Insights    │
└─────────────────┘
```

1. **Data Collection**: Sensors continuously monitor soil and environmental parameters
2. **Data Transmission**: Real-time data is sent to the mobile app
3. **AI Processing**: On-device ML model analyzes the data
4. **Recommendations**: Farmers receive crop suggestions and detailed insights
5. **Additional Info**: Market prices, weather, and news supplement the recommendations

---

## 🌾 Supported Crops

XYLEM's AI model can recommend a wide variety of crops based on your soil conditions and environmental factors. The system provides detailed information about:
- Ideal growing conditions
- Expected yield
- Market demand
- Seasonal considerations
- Best practices for cultivation

---

## 📖 User Guide

### Connecting Your Sensors
1. Ensure sensors are properly installed in your field
2. Turn on Bluetooth on your mobile device
3. Open XYLEM app and go to Connection Screen
4. Tap "Connect Sensors"
5. Select your sensor device from the list
6. Wait for successful pairing confirmation

### Understanding Recommendations
- **Crop Score**: Higher scores indicate better suitability for current conditions
- **Confidence Level**: Shows how certain the AI is about the recommendation
- **Key Factors**: Displays which parameters influenced the recommendation
- **Detailed Info**: Tap any crop for comprehensive growing guidelines

### Troubleshooting
- **Sensors not connecting?** Check Bluetooth is enabled and sensors are powered
- **No data showing?** Ensure sensors are properly deployed and within range
- **App crashes?** Update to the latest version or contact support

---

## 🤝 Contributing

We welcome feedback and suggestions from our farming community!

### How to Contribute
- **Feedback**: Share your experience using XYLEM
- **Feature Requests**: Suggest new features that would help you
- **Bug Reports**: Report any issues you encounter
- **Insights**: Share your farming knowledge to improve our recommendations

### Contact Us
For support, feedback, or collaboration:
- GitHub Issues: [Report a problem](https://github.com/gowtham611/XYLEM/issues)
- Email: [Your Contact Email]

---

## 🔒 Privacy & Data

- All ML processing happens **on your device**
- Your farming data stays **private and secure**
- No data is sent to external servers without your permission
- Sensor data is encrypted during transmission

---

## 🗺️ Roadmap

### Current Features
- ✅ Real-time crop monitoring
- ✅ AI-powered crop recommendations
- ✅ Market price tracking
- ✅ Weather monitoring
- ✅ Farming news feed
- ✅ On-device ML processing

### Upcoming Features
- 🔄 Multi-field management
- 🔄 Historical data analytics
- 🔄 Crop disease detection
- 🔄 Irrigation scheduling
- 🔄 Community features for farmers
- 🔄 Multi-language support

---

## 📄 License

This project currently does not have a formal license. All rights reserved.

---

## 👥 Team

Developed with ❤️ for farmers by [@gowtham611](https://github.com/gowtham611)

---

## 🙏 Acknowledgments

- Thanks to all farmers who provided valuable feedback during development
- Agricultural experts who contributed to crop knowledge base
- Open-source community for amazing tools and libraries

---

## 📞 Support

Having trouble with XYLEM? We're here to help!

- 📧 Email: [Your Support Email]
- 🐛 Bug Reports: [GitHub Issues](https://github.com/gowtham611/XYLEM/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/gowtham611/XYLEM/discussions)

---

## 🌟 Show Your Support

If XYLEM is helping you with your farming decisions, please ⭐ star this repository!

---

<div align="center">

**XYLEM** - *Empowering Farmers with AI*

Made with 🌱 for the farming community

</div>
