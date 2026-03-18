import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';
import '../models/cabin_models.dart';
import '../config/app_config.dart';

class CabinService with ChangeNotifier {
  late String baseUrl;
  late String wsUrl;

  CabinService() {
    baseUrl = AppConfig.apiBaseUrl;
    wsUrl = AppConfig.wsUrl;
  }

  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  WebSocketChannel? _wsChannel;

  String? _selectedAircraftId;
  CabinStatus? _cabinStatus;
  List<CabinAlert> _alerts = [];
  List<DetectedDevice> _devices = [];
  bool _isConnected = false;

  // Getters
  CabinStatus? get cabinStatus => _cabinStatus;
  List<CabinAlert> get alerts => _alerts;
  List<DetectedDevice> get devices => _devices;
  bool get isConnected => _isConnected;
  String? get selectedAircraftId => _selectedAircraftId;

  // Select aircraft and connect
  Future<void> selectAircraft(String aircraftId) async {
    _selectedAircraftId = aircraftId;
    try {
      await connectWebSocket();
      await fetchCabinStatus();
    } catch (e) {
      print('Error selecting aircraft: $e');
    }
  }

  // WebSocket connection
  Future<void> connectWebSocket() async {
    try {
      _wsChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      notifyListeners();
      
      _wsChannel?.stream.listen(
        (message) => _handleWebSocketMessage(message),
        onError: (error) {
          _isConnected = false;
          notifyListeners();
        },
        onDone: () {
          _isConnected = false;
          notifyListeners();
        },
      );
    } catch (e) {
      print('WebSocket connection error: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      // Parse incoming WebSocket messages and update state
      final Map<String, dynamic> data = _parseMessage(message);
      
      if (data.containsKey('devicesByRow')) {
        _cabinStatus = CabinStatus.fromJson(data);
      }
      
      if (data.containsKey('alerts')) {
        final alertList = data['alerts'] as List;
        _alerts = alertList
            .map((a) => CabinAlert.fromJson(a as Map<String, dynamic>))
            .toList();
      }
      
      notifyListeners();
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  Map<String, dynamic> _parseMessage(dynamic message) {
    if (message is String) {
      return _parseJsonString(message);
    }
    return {};
  }

  Map<String, dynamic> _parseJsonString(String jsonString) {
    try {
      return {}; // TODO: Implement JSON parsing
    } catch (e) {
      return {};
    }
  }

  // REST API calls
  Future<void> fetchCabinStatus() async {
    try {
      if (_selectedAircraftId == null) return;
      
      final response = await _dio.get('/aircraft/$_selectedAircraftId/status');
      _cabinStatus = CabinStatus.fromJson(response.data);
      notifyListeners();
    } catch (e) {
      print('Error fetching cabin status: $e');
    }
  }

  Future<void> fetchAlerts() async {
    try {
      if (_selectedAircraftId == null) return;
      
      final response = await _dio.get('/aircraft/$_selectedAircraftId/alerts');
      final alertList = response.data as List;
      _alerts = alertList
          .map((a) => CabinAlert.fromJson(a as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching alerts: $e');
    }
  }

  Future<void> acknowledgeAlert(String alertId) async {
    try {
      await _dio.post('/alerts/$alertId/acknowledge',
          data: {'acknowledgedBy': 'crew_member'});
      await fetchAlerts();
    } catch (e) {
      print('Error acknowledging alert: $e');
    }
  }

  @override
  void dispose() {
    _wsChannel?.sink.close();
    super.dispose();
  }
}
