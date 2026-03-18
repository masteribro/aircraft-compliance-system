# Aircraft Compliance System - Real-Time Passenger Intelligence Platform

## Overview

A real-time cabin monitoring system that provides airlines with visibility into passenger activity, device usage, and compliance with airplane mode requirements. The system consists of:

1. **Java Spring Boot Backend** - REST API with WebSocket support for real-time updates
2. **Flutter Frontend** - Crew tablet dashboard for monitoring cabin activity
3. **PostgreSQL Database** - Stores aircraft, sensor, device, and alert data

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Cabin Sensors (IoT)                    │
│        (ESP32/Raspberry Pi detecting signals)           │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│          Java Spring Boot Backend (Port 8080)           │
│  ├─ REST API: /api/aircraft/*                          │
│  ├─ WebSocket: /ws/cabin                               │
│  ├─ Device Detection Processing                        │
│  └─ Alert Generation Engine                            │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│        PostgreSQL Database (Port 5432)                  │
│  ├─ aircraft table                                      │
│  ├─ sensors table                                       │
│  ├─ detected_devices table                              │
│  ├─ alerts table                                        │
│  └─ crew_members table                                  │
└─────────────────────────────────────────────────────────┘

                     ▲
                     │
┌────────────────────┴────────────────────────────────────┐
│           Flutter Mobile/Tablet Client                  │
│       (Crew Dashboard with Real-Time Updates)           │
└─────────────────────────────────────────────────────────┘
```

## Backend Setup

### Prerequisites
- Java 17+
- Maven 3.8+
- PostgreSQL 12+

### Step 1: Database Setup

```bash
# Create PostgreSQL database
psql -U postgres -c "CREATE DATABASE aircraft_db;"
psql -U postgres -d aircraft_db -c "CREATE USER aircraft_user WITH PASSWORD 'secure_password';"
psql -U postgres -d aircraft_db -c "GRANT ALL PRIVILEGES ON DATABASE aircraft_db TO aircraft_user;"
```

### Step 2: Build Backend

```bash
cd backend
mvn clean install
```

### Step 3: Update Configuration

Edit `src/main/resources/application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/aircraft_db
    username: aircraft_user
    password: secure_password
```

### Step 4: Run Backend

```bash
mvn spring-boot:run
```

The backend will run on `http://localhost:8080/api`

### Database Schema

The application uses Liquibase for schema management. Tables created:

- **aircraft** - Aircraft information (tail number, type, capacity)
- **sensors** - Cabin sensor devices and their locations
- **detected_devices** - Wireless devices detected in cabin
- **cabin_activity** - Activity logs and events
- **alerts** - Generated alerts for crew attention
- **crew_members** - Crew authentication and roles

## Frontend Setup

### Prerequisites
- Flutter 3.10+
- Android SDK (for Android) or Xcode (for iOS)

### Step 1: Install Dependencies

```bash
flutter pub get
```

### Step 2: Update API Configuration

Edit `lib/services/cabin_service.dart`:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_URL/api';
static const String wsUrl = 'ws://YOUR_BACKEND_URL/ws/cabin';
```

### Step 3: Run on Device

```bash
# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Run on Web (development)
flutter run -d chrome
```

## Key Features

### 1. Cabin Overview Dashboard
- Real-time device count by row
- Status indicators for each row (green/yellow/orange/red)
- Quick alert summary
- Total connected devices

### 2. Row-Level Monitoring
- Detailed view of each row's activity
- Seat-by-seat device detection
- Signal strength metrics
- Device-to-seat mapping

### 3. Alert Management
- Automatic alert generation for non-compliant devices
- Alert acknowledgment by crew
- Priority-based alert display
- Alert history and resolution tracking

### 4. Real-Time Communication
- WebSocket connection for <500ms latency
- Automatic reconnection on disconnect
- Bi-directional messaging
- Device status updates

## API Endpoints

### REST Endpoints

```
GET  /aircraft                           - List all aircraft
GET  /aircraft/{aircraftId}             - Get aircraft details
POST /aircraft                          - Create aircraft
GET  /aircraft/{aircraftId}/status      - Get cabin status
GET  /aircraft/{aircraftId}/alerts      - Get active alerts
GET  /aircraft/{aircraftId}/alerts/unacknowledged - Get unacknowledged alerts
```

### WebSocket Endpoints

```
STOMP Endpoint: /ws/cabin

Subscriptions:
  /topic/aircraft/{aircraftId}/status   - Cabin status updates
  /topic/aircraft/{aircraftId}/alerts   - Alert updates

Send Messages:
  /app/aircraft/{aircraftId}/device-detection     - Report device
  /app/aircraft/{aircraftId}/status-request       - Request status
  /app/aircraft/{aircraftId}/alert-acknowledge    - Acknowledge alert
```

## Device Detection Logic

### Detection Flow
1. Cabin sensors detect Wi-Fi probes, Bluetooth beacons, or cellular signals
2. Edge processor aggregates and sends to backend
3. Backend processes device data and calculates seat location
4. System estimates if device is in airplane mode (no cellular/Wi-Fi activity)
5. Alerts generated if device not in airplane mode
6. Real-time updates pushed to crew dashboard

### Signal Strength (dBm)
- **< -50 dBm**: Weak signal
- **-50 to -70 dBm**: Medium signal
- **> -70 dBm**: Strong signal

### Device Classification
- **WIFI_PROBE**: Wi-Fi network discovery requests
- **BLUETOOTH_BEACON**: Bluetooth advertising packets
- **CELLULAR**: Cellular radio transmissions
- **UNKNOWN**: Unclassified signals

## Alert Types

| Alert Type | Severity | Trigger |
|-----------|----------|---------|
| DEVICE_DETECTED | MEDIUM | Single device not in airplane mode |
| MULTIPLE_DEVICES | HIGH | 3+ devices in same row |
| AIRPLANE_MODE_WARNING | MEDIUM | Device transmitting before takeoff |
| SENSOR_ERROR | LOW | Sensor not responding |

## Crew Dashboard Tabs

### 1. Overview
- Cabin statistics
- Row grid visualization
- Active alert count
- Critical issues highlighted

### 2. Rows
- Expandable row details
- Per-seat device information
- Signal strength per row
- Avg signal metrics

### 3. Alerts
- Real-time alert list
- Severity color coding
- Alert acknowledgment
- Message details

### 4. Settings
- Logout functionality
- Crew preferences (future)
- System diagnostics (future)

## Data Models

### CabinStatus
```dart
{
  "totalDevices": 5,
  "activeRows": [12, 15, 18],
  "devicesByRow": {
    "12": 2,
    "15": 1,
    "18": 2
  },
  "activeAlerts": 3,
  "criticalAlerts": 0
}
```

### DetectedDevice
```dart
{
  "id": "uuid",
  "macAddress": "AA:BB:CC:DD:EE:FF",
  "deviceType": "WIFI_PROBE",
  "signalStrength": -65,
  "estimatedRow": 12,
  "isInAirplaneMode": false
}
```

### Alert
```dart
{
  "id": "uuid",
  "alertType": "DEVICE_DETECTED",
  "severity": "MEDIUM",
  "rowNumber": 12,
  "deviceCount": 1,
  "message": "Device detected not in airplane mode",
  "isActive": true,
  "crewAcknowledged": false
}
```

## Deployment

### Backend Deployment (Docker)

```dockerfile
FROM openjdk:17-slim
COPY target/aircraft-compliance-backend-1.0.0.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

```bash
docker build -t aircraft-compliance-backend .
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/aircraft_db \
  -e SPRING_DATASOURCE_USERNAME=aircraft_user \
  -e SPRING_DATASOURCE_PASSWORD=secure_password \
  aircraft-compliance-backend
```

### Frontend Deployment

```bash
# Web build
flutter build web --release

# Android APK
flutter build apk --release

# iOS app
flutter build ios --release
```

## Performance Targets

- **WebSocket Latency**: < 500ms from sensor to dashboard
- **Device Detection Sensitivity**: > 90%
- **Alert Accuracy**: > 95% precision
- **Dashboard Responsiveness**: 60fps on crew tablets
- **System Uptime**: > 99% during flight operations

## Troubleshooting

### Backend Issues

**WebSocket Connection Fails**
- Check if backend is running on port 8080
- Verify firewall rules allow WebSocket (upgrade header)
- Check CORS configuration in WebSocketConfig.java

**Database Connection Error**
- Verify PostgreSQL is running
- Check database credentials in application.yml
- Run migration: `mvn liquibase:update`

### Frontend Issues

**Can't Connect to Backend**
- Verify backend URL in cabin_service.dart
- Check if backend server is reachable
- Test with `curl http://YOUR_BACKEND_URL/api/aircraft`

**No Real-Time Updates**
- WebSocket not connected - check browser console
- Verify /ws/cabin endpoint is accessible
- Check network for WebSocket support

## Security Considerations

1. **Authentication**: Implement JWT-based crew authentication
2. **Authorization**: Role-based access control (Crew, Captain, Admin)
3. **Encryption**: Use TLS/SSL for all communications
4. **Input Validation**: All user inputs validated server-side
5. **Rate Limiting**: Implement rate limits on API endpoints
6. **Data Privacy**: Encrypt sensitive data at rest

## Future Enhancements

1. **Machine Learning**: Device location triangulation using signal fingerprinting
2. **Passenger Notifications**: In-seat display messages for non-compliant passengers
3. **Analytics Dashboard**: Historical trends and reporting
4. **Mobile Notifications**: Push alerts to crew devices
5. **AI Behavior Detection**: Anomaly detection for safety incidents
6. **Integration APIs**: Connect with airline systems (crew scheduling, passenger manifests)

## Support

For issues or questions, please contact the development team or create an issue in the GitHub repository.

## License

Proprietary - Aircraft Compliance System
