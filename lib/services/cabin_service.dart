import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/cabin_models.dart';
import '../config/app_config.dart';

class CabinService with ChangeNotifier {
  late String baseUrl;
  late String wsUrl;
  late Dio _dio;

  CabinService() {
    baseUrl = AppConfig.apiBaseUrl;
    wsUrl = AppConfig.wsUrl;
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: AppConfig.connectTimeout),
      receiveTimeout: Duration(seconds: AppConfig.receiveTimeout),
    ));
    
    print('[v0] CabinService initialized with baseUrl: $baseUrl, wsUrl: $wsUrl');
  }

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
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('[v0] JSON parse error: $e for string: $jsonString');
      return {};
    }
  }

  // REST API calls
  Future<void> fetchCabinStatus() async {
    try {
      if (_selectedAircraftId == null) {
        print('[v0] No aircraft selected');
        return;
      }

      print('[v0] Fetching cabin status for: $_selectedAircraftId');
      final response = await _dio.get('/aircraft/$_selectedAircraftId/status');
      print('[v0] Cabin status response: ${response.data}');
      _cabinStatus = CabinStatus.fromJson(response.data);
      notifyListeners();
    } catch (e) {
      print('[v0] Error fetching cabin status: $e');
    }
  }

  Future<void> fetchAlerts() async {
    try {
      if (_selectedAircraftId == null) return;

      print('[v0] Fetching alerts for: $_selectedAircraftId');
      final response = await _dio.get('/aircraft/$_selectedAircraftId/alerts');
      print('[v0] Alerts response: ${response.data}');
      final alertList = response.data as List;
      _alerts = alertList
          .map((a) => CabinAlert.fromJson(a as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      print('[v0] Error fetching alerts: $e');
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
