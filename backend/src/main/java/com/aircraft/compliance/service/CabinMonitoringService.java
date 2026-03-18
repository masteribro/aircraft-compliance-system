package com.aircraft.compliance.service;

import com.aircraft.compliance.entity.*;
import com.aircraft.compliance.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class CabinMonitoringService {
    private final DetectedDeviceRepository deviceRepository;
    private final AlertRepository alertRepository;
    private final AircraftRepository aircraftRepository;
    private final AlertService alertService;

    @Transactional
    public void processDeviceDetection(UUID aircraftId, DetectedDevice device) {
        Aircraft aircraft = aircraftRepository.findById(aircraftId)
            .orElseThrow(() -> new IllegalArgumentException("Aircraft not found"));

        device.setAircraft(aircraft);
        deviceRepository.save(device);

        checkAndGenerateAlerts(aircraft, device);
    }

    private void checkAndGenerateAlerts(Aircraft aircraft, DetectedDevice device) {
        // Check for device not in airplane mode
        if (!device.getIsInAirplaneMode()) {
            alertService.createAlert(aircraft, Alert.AlertType.DEVICE_DETECTED,
                Alert.Severity.MEDIUM,
                device.getEstimatedRow(),
                1,
                "Device detected not in airplane mode: " + device.getMacAddress());
        }

        // Check for multiple devices in same row
        Long deviceCountInRow = deviceRepository.countDevicesByRow(
            aircraft, device.getEstimatedRow(), DetectedDevice.Status.ACTIVE);

        if (deviceCountInRow > 3) {
            alertService.createAlert(aircraft, Alert.AlertType.MULTIPLE_DEVICES,
                Alert.Severity.HIGH,
                device.getEstimatedRow(),
                deviceCountInRow.intValue(),
                "Multiple devices detected in row " + device.getEstimatedRow());
        }
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getCabinStatus(UUID aircraftId) {
        Aircraft aircraft = aircraftRepository.findById(aircraftId)
            .orElseThrow(() -> new IllegalArgumentException("Aircraft not found"));

        List<DetectedDevice> activeDevices = deviceRepository
            .findByAircraftAndStatus(aircraft, DetectedDevice.Status.ACTIVE);

        List<Integer> activeRows = deviceRepository
            .findActiveRows(aircraft, DetectedDevice.Status.ACTIVE);

        List<Alert> activeAlerts = alertRepository.findActiveAlerts(aircraft);

        Map<String, Object> status = new HashMap<>();
        status.put("totalDevices", activeDevices.size());
        status.put("activeRows", activeRows);
        status.put("devicesByRow", groupDevicesByRow(activeDevices));
        status.put("activeAlerts", activeAlerts.size());
        status.put("criticalAlerts", activeAlerts.stream()
            .filter(a -> a.getSeverity() == Alert.Severity.CRITICAL)
            .count());

        return status;
    }

    private Map<Integer, Long> groupDevicesByRow(List<DetectedDevice> devices) {
        return devices.stream()
            .filter(d -> d.getEstimatedRow() != null)
            .collect(Collectors.groupingByConcurrent(
                DetectedDevice::getEstimatedRow,
                Collectors.counting()
            ));
    }

    @Transactional
    public void cleanupInactiveDevices(UUID aircraftId, int inactivityMinutes) {
        Aircraft aircraft = aircraftRepository.findById(aircraftId)
            .orElseThrow(() -> new IllegalArgumentException("Aircraft not found"));

        LocalDateTime cutoffTime = LocalDateTime.now().minusMinutes(inactivityMinutes);
        List<DetectedDevice> inactiveDevices = deviceRepository
            .findRecentDevices(aircraft, cutoffTime, DetectedDevice.Status.ACTIVE);

        inactiveDevices.forEach(device -> {
            device.setStatus(DetectedDevice.Status.INACTIVE);
            deviceRepository.save(device);
        });

        log.info("Cleaned up {} inactive devices for aircraft {}", inactiveDevices.size(), aircraftId);
    }
}
