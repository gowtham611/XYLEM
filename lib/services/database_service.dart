class DatabaseService {
  static DatabaseService? _instance;
  
  factory DatabaseService() => _instance ??= DatabaseService._();
  
  DatabaseService._();

  Future<void> initDatabase() async {
    print('Database service initialized (simplified version)');
  }

  Future<void> saveSensorData(Map<String, dynamic> data) async {
    print('Saving sensor data: $data');
  }

  Future<List<Map<String, dynamic>>> getSensorHistory({int limit = 100}) async {
    return [];
  }

  Future<void> clearOldData({int daysToKeep = 30}) async {
    print('Clearing old data older than $daysToKeep days');
  }
}
