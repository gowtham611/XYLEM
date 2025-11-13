import 'package:flutter/foundation.dart';

class AppStateProvider with ChangeNotifier {
  bool _isConnected = false;
  String _selectedCrop = 'Rice';
  String _connectionStatus = 'Disconnected';
  bool _isLoading = false;

  bool get isConnected => _isConnected;
  String get selectedCrop => _selectedCrop;
  String get connectionStatus => _connectionStatus;
  bool get isLoading => _isLoading;

  void setConnectionStatus(bool status) {
    _isConnected = status;
    _connectionStatus = status ? 'Connected' : 'Disconnected';
    notifyListeners();
  }

  void setSelectedCrop(String crop) {
    _selectedCrop = crop;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void updateConnectionStatus(String status) {
    _connectionStatus = status;
    notifyListeners();
  }
}
