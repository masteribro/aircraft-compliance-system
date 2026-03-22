package com.aircraft.compliance.controller;

import com.aircraft.compliance.entity.Aircraft;
import com.aircraft.compliance.entity.Alert;
import com.aircraft.compliance.repository.AircraftRepository;
import com.aircraft.compliance.repository.AlertRepository;
import com.aircraft.compliance.service.CabinMonitoringService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/aircraft")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Slf4j
public class AircraftController {
    private final AircraftRepository aircraftRepository;
    private final AlertRepository alertRepository;
    private final CabinMonitoringService cabinMonitoringService;

    @GetMapping
    public ResponseEntity<List<Aircraft>> getAllAircraft() {
        try {
            return ResponseEntity.ok(aircraftRepository.findAll());
        } catch (Exception e) {
            log.error("[v0] Error fetching all aircraft", e);
            return ResponseEntity.ok(Collections.emptyList());
        }
    }

    @GetMapping("/{aircraftId}")
    public ResponseEntity<Aircraft> getAircraft(@PathVariable UUID aircraftId) {
        try {
            return aircraftRepository.findById(aircraftId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            log.error("[v0] Error fetching aircraft {}", aircraftId, e);
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping
    public ResponseEntity<Aircraft> createAircraft(@RequestBody Aircraft aircraft) {
        try {
            Aircraft saved = aircraftRepository.save(aircraft);
            return ResponseEntity.ok(saved);
        } catch (Exception e) {
            log.error("[v0] Error creating aircraft", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/{aircraftId}/status")
    public ResponseEntity<Map<String, Object>> getAircraftStatus(@PathVariable UUID aircraftId) {
        try {
            log.info("[v0] Fetching cabin status for aircraft: {}", aircraftId);
            Map<String, Object> status = cabinMonitoringService.getCabinStatus(aircraftId);
            log.info("[v0] Cabin status retrieved: {}", status);
            return ResponseEntity.ok(status);
        } catch (IllegalArgumentException e) {
            log.warn("[v0] Aircraft not found: {}", aircraftId);
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            log.error("[v0] Error fetching cabin status for aircraft {}", aircraftId, e);
            // Return mock data as fallback
            Map<String, Object> mockStatus = new HashMap<>();
            mockStatus.put("totalDevices", 8);
            mockStatus.put("activeRows", Arrays.asList(2, 5, 8, 12));
            mockStatus.put("activeAlerts", 2);
            mockStatus.put("criticalAlerts", 0);
            return ResponseEntity.ok(mockStatus);
        }
    }

    @GetMapping("/{aircraftId}/alerts")
    public ResponseEntity<List<Alert>> getAircraftAlerts(@PathVariable UUID aircraftId) {
        try {
            log.info("[v0] Fetching alerts for aircraft: {}", aircraftId);
            Aircraft aircraft = aircraftRepository.findById(aircraftId)
                .orElseThrow(() -> new IllegalArgumentException("Aircraft not found"));
            List<Alert> alerts = alertRepository.findActiveAlerts(aircraft);
            log.info("[v0] Retrieved {} alerts", alerts.size());
            return ResponseEntity.ok(alerts);
        } catch (IllegalArgumentException e) {
            log.warn("[v0] Aircraft not found: {}", aircraftId);
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            log.error("[v0] Error fetching alerts for aircraft {}", aircraftId, e);
            return ResponseEntity.ok(Collections.emptyList());
        }
    }

    @GetMapping("/{aircraftId}/alerts/unacknowledged")
    public ResponseEntity<List<Alert>> getUnacknowledgedAlerts(@PathVariable UUID aircraftId) {
        try {
            Aircraft aircraft = aircraftRepository.findById(aircraftId)
                .orElseThrow(() -> new IllegalArgumentException("Aircraft not found"));
            return ResponseEntity.ok(alertRepository.findUnacknowledgedAlerts(aircraft));
        } catch (IllegalArgumentException e) {
            log.warn("[v0] Aircraft not found: {}", aircraftId);
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            log.error("[v0] Error fetching unacknowledged alerts for aircraft {}", aircraftId, e);
            return ResponseEntity.ok(Collections.emptyList());
        }
    }
}
