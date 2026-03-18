package com.aircraft.compliance.controller;

import com.aircraft.compliance.entity.Aircraft;
import com.aircraft.compliance.entity.DetectedDevice;
import com.aircraft.compliance.entity.Alert;
import com.aircraft.compliance.repository.AircraftRepository;
import com.aircraft.compliance.repository.DetectedDeviceRepository;
import com.aircraft.compliance.service.CabinMonitoringService;
import com.aircraft.compliance.service.AlertService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@Controller
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class WebSocketController {
    private final CabinMonitoringService cabinMonitoringService;
    private final AlertService alertService;
    private final AircraftRepository aircraftRepository;
    private final DetectedDeviceRepository deviceRepository;

    @MessageMapping("/aircraft/{aircraftId}/device-detection")
    @SendTo("/topic/aircraft/{aircraftId}/status")
    public Map<String, Object> handleDeviceDetection(
            @PathVariable String aircraftId,
            DetectedDevice device) {
        try {
            UUID id = UUID.fromString(aircraftId);
            cabinMonitoringService.processDeviceDetection(id, device);
            Aircraft aircraft = aircraftRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Aircraft not found"));
            return cabinMonitoringService.getCabinStatus(id);
        } catch (Exception e) {
            log.error("Error processing device detection", e);
            return Map.of("error", "Failed to process device detection");
        }
    }

    @MessageMapping("/aircraft/{aircraftId}/status-request")
    @SendTo("/topic/aircraft/{aircraftId}/status")
    public Map<String, Object> getCabinStatus(@PathVariable String aircraftId) {
        try {
            UUID id = UUID.fromString(aircraftId);
            return cabinMonitoringService.getCabinStatus(id);
        } catch (Exception e) {
            log.error("Error retrieving cabin status", e);
            return Map.of("error", "Failed to retrieve status");
        }
    }

    @MessageMapping("/aircraft/{aircraftId}/alert-acknowledge")
    @SendTo("/topic/aircraft/{aircraftId}/alerts")
    public Map<String, Object> acknowledgeAlert(
            @PathVariable String aircraftId,
            @RequestParam String alertId,
            @RequestParam String crewId) {
        try {
            alertService.acknowledgeAlert(UUID.fromString(alertId), crewId);
            return Map.of("status", "acknowledged");
        } catch (Exception e) {
            log.error("Error acknowledging alert", e);
            return Map.of("error", "Failed to acknowledge alert");
        }
    }
}
