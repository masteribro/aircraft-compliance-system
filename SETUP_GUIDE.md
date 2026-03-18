## Running the Aircraft Compliance System

### Backend Setup (Java Spring Boot)

#### Prerequisites
- Java 17 or higher
- Maven 3.8+
- PostgreSQL 12 or higher

#### Steps

1. **Setup Database**
   ```bash
   # Create PostgreSQL database
   createdb aircraft_compliance
   
   # Or using psql
   psql -U postgres -c "CREATE DATABASE aircraft_compliance;"
   ```

2. **Configure Backend**
   ```bash
   cd backend
   
   # Edit src/main/resources/application.yml to match your database credentials
   # Default configuration:
   # spring.datasource.url=jdbc:postgresql://localhost:5432/aircraft_compliance
   # spring.datasource.username=postgres
   # spring.datasource.password=your_password
   ```

3. **Build and Run Backend**
   ```bash
   # Build with Maven
   mvn clean package
   
   # Run the application
   mvn spring-boot:run
   
   # Or run the JAR directly
   java -jar target/aircraft-compliance-system-1.0.0.jar
   ```

   Backend will be available at: `http://localhost:8080`

### Flutter Frontend Setup

#### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- iOS: Xcode 14+
- Android: Android Studio + Android SDK

#### Configuration

1. **Update Backend URL** (if using a different backend address)
   - Edit `lib/config/app_config.dart`
   - Change `backendUrl` to your backend server address

   For different platforms:
   - **Android Emulator**: `http://10.0.2.2:8080`
   - **iOS Simulator**: `http://localhost:8080`
   - **Physical Device**: Use your machine's local IP (e.g., `http://192.168.1.100:8080`)
   - **Production**: Use your production server URL

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run on iOS Simulator**
   ```bash
   flutter run -d "iPhone 16 Pro"
   ```

4. **Run on Android Emulator**
   ```bash
   flutter run -d emulator-5554
   ```

5. **Run on Physical Device**
   ```bash
   flutter run
   ```

### Testing

1. **Start Backend** (Terminal 1)
   ```bash
   cd backend
   mvn spring-boot:run
   ```

2. **Start Flutter App** (Terminal 2)
   ```bash
   flutter run
   ```

3. **Login with test credentials**
   - Username: `crew@example.com`
   - Password: `password123`

### Common Issues

#### Connection Refused Error
- Ensure the backend is running on port 8080
- Check firewall settings
- Verify the backend URL in `lib/config/app_config.dart` matches your setup
- For emulators, use `10.0.2.2` (Android) or `localhost` (iOS)

#### Database Connection Error
- Verify PostgreSQL is running
- Check database credentials in `application.yml`
- Ensure the database `aircraft_compliance` exists
- Run migrations: Liquibase will auto-run on startup

#### WebSocket Connection Issues
- WebSocket requires the same base URL as REST API
- Check that the backend supports WebSocket on `/ws/cabin`
- Verify network connectivity between client and server

### Docker Deployment

Build and run with Docker:

```bash
# Backend
cd backend
docker build -t aircraft-compliance-backend .
docker run -e DATABASE_URL=postgresql://postgres:password@db:5432/aircraft_compliance -p 8080:8080 aircraft-compliance-backend

# Database
docker run -e POSTGRES_DB=aircraft_compliance -e POSTGRES_PASSWORD=password -p 5432:5432 postgres:15
```

### Production Deployment

1. **Build Flutter Release**
   ```bash
   flutter build ios --release
   flutter build apk --release
   ```

2. **Deploy Backend to Cloud** (AWS, GCP, Azure, Heroku, etc.)
   - Use environment variables for database credentials
   - Enable HTTPS/WSS for WebSocket
   - Configure CORS if frontend is on different domain

3. **Update Frontend Config**
   - Change backend URL to production server in `lib/config/app_config.dart`
   - Build and deploy to app stores
