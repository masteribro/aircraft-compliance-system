class AppConfig {
  // Backend server URL - Change this to match your backend server
  // For iOS simulator: http://localhost:8080 (connects to host Mac)
  // For Android emulator: http://10.0.2.2:8080 (special alias for host)
  // For real device: http://<your-machine-ip>:8080
  static const String backendUrl = 'http://localhost:8080'; // iOS simulator / real device
  // static const String backendUrl = 'http://10.0.2.2:8080'; // Android emulator
  
  static const String apiBaseUrl = '$backendUrl/api';
  static const String wsBaseUrl = 'ws://localhost:8080'; // iOS simulator / real device
  // static const String wsBaseUrl = 'ws://10.0.2.2:8080'; // Android emulator
  
  static const String wsUrl = '$wsBaseUrl/ws/cabin';
  
  // Connection timeouts (in seconds)
  static const int connectTimeout = 15;
  static const int receiveTimeout = 15;
}
