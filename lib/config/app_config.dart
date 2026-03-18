class AppConfig {
  // Backend server URL - Change this to match your backend server
  // For local development: http://localhost:8080
  // For production: Update with your actual backend URL
  static const String backendUrl = 'http://10.0.2.2:8080'; // Android emulator
  // static const String backendUrl = 'http://localhost:8080'; // iOS simulator or real device
  
  static const String apiBaseUrl = '$backendUrl/api';
  static const String wsBaseUrl = 'ws://10.0.2.2:8080'; // Android emulator
  // static const String wsBaseUrl = 'ws://localhost:8080'; // iOS simulator or real device
  
  static const String wsUrl = '$wsBaseUrl/ws/cabin';
}
