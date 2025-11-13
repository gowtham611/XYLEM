class NotificationService {
  static NotificationService? _instance;
  
  factory NotificationService() => _instance ??= NotificationService._();
  
  NotificationService._();

  Future<void> initialize() async {
    print('✅ Notification service initialized (console-based)');
  }

  Future<void> showNotification({
    required String title,
    required String message,
    String? payload,
  }) async {
    final timestamp = DateTime.now().toLocal().toString().split('.')[0];
    print('🔔 [$timestamp] $title: $message');
    
    // You can add Firebase push notifications here later
  }

  Future<void> showWeatherAlert(String alertType, String message) async {
    await showNotification(
      title: '🌦️ Weather Alert: $alertType',
      message: message,
      payload: 'weather_alert',
    );
  }

  Future<void> showMarketAlert(String crop, double price) async {
    await showNotification(
      title: '💰 Market Alert: $crop',
      message: 'Current price: ₹$price per quintal',
      payload: 'market_alert',
    );
  }
}
