package com.aircraft.compliance.service;

import com.aircraft.compliance.entity.*;
import com.aircraft.compliance.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class SensorSimulationService {
    private final DetectedDeviceRepository deviceRepository;
    private final SensorRepository sensorRepository;
    private final AircraftRepository aircraftRepository;
    private final CabinMonitoringService cabinMonitoringService;

    @Transactional
    public void simulateDeviceDetection(UUID aircraftId) {
        Aircraft aircraft = aircraftRepository.findById(aircraftId)
            .orElseThrow(() -> new IllegalArgumentException("Aircraft not found"));

        List<Sensor> sensors = sensorRepository.findByAircraft(aircraft);
        if (sensors.isEmpty()) {
            log.warn("No sensors found for aircraft {}", aircraftId);
            return;
        }

        // Simulate random device detections
        Random random = new Random();
        int numberOfDevices = random.nextInt(10);

        for (int i = 0; i < numberOfDevices; i++) {
            Sensor sensor = sensors.get(random.nextInt(sensors.size()));
            
            DetectedDevice device = DetectedDevice.builder()
                .aircraft(aircraft)
                .sensor(sensor)
                .macAddress(generateRandomMac())
                .deviceType(DetectedDevice.DeviceType.values()[
                    random.nextInt(DetectedDevice.DeviceType.values().length)])
                .signalStrength(-50 - random.nextInt(50))
                .estimatedRow(sensor.getLocationRow())
                .confidenceScore(0.7 + random.nextDouble() * 0.3)
                .isInAirplaneMode(random.nextDouble() > 0.3)
                .status(DetectedDevice.Status.ACTIVE)
                .build();

            deviceRepository.save(device);
            cabinMonitoringService.processDeviceDetection(aircraftId, device);
        }

        log.info("Simulated {} device detections for aircraft {}", numberOfDevices, aircraftId);
    }

    private String generateRandomMac() {
        Random random = new Random();
        byte[] macBytes = new byte[6];
        random.nextBytes(macBytes);
        
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < macBytes.length; i++) {
            sb.append(String.format("%02X", macBytes[i]));
            if (i < macBytes.length - 1) sb.append(":");
        }
        return sb.toString();
    }
}
