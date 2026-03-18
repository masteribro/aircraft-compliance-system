package com.aircraft.compliance.controller;

import com.aircraft.compliance.entity.Aircraft;
import com.aircraft.compliance.entity.Alert;
import com.aircraft.compliance.repository.AircraftRepository;
import com.aircraft.compliance.repository.AlertRepository;
import com.aircraft.compliance.service.CabinMonitoringService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/aircraft")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AircraftController {
    private final AircraftRepository aircraftRepository;
    private final AlertRepository alertRepository;
    private final CabinMonitoringService cabinMonitoringService;

    @GetMapping
    public ResponseEntity<List<Aircraft>> getAllAircraft() {
        return ResponseEntity.ok(aircraftRepository.findAll());
    }

    @GetMapping("/{aircraftId}")
    public ResponseEntity<Aircraft> getAircraft(@PathVariable UUID aircraftId) {
        return aircraftRepository.findById(aircraftId)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Aircraft> createAircraft(@RequestBody Aircraft aircraft) {
        Aircraft saved = aircraftRepository.save(aircraft);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/{aircraftId}/status")
    public ResponseEntity<Map<String, Object>> getAircraftStatus(@PathVariable UUID aircraftId) {
        return ResponseEntity.ok(cabinMonitoringService.getCabinStatus(aircraftId));
    }

    @GetMapping("/{aircraftId}/alerts")
    public ResponseEntity<List<Alert>> getAircraftAlerts(@PathVariable UUID aircraftId) {
        Aircraft aircraft = aircraftRepository.findById(aircraftId)
            .orElseThrow(() -> new IllegalArgumentException("Aircraft not found"));
        return ResponseEntity.ok(alertRepository.findActiveAlerts(aircraft));
    }

    @GetMapping("/{aircraftId}/alerts/unacknowledged")
    public ResponseEntity<List<Alert>> getUnacknowledgedAlerts(@PathVariable UUID aircraftId) {
        Aircraft aircraft = aircraftRepository.findById(aircraftId)
            .orElseThrow(() -> new IllegalArgumentException("Aircraft not found"));
        return ResponseEntity.ok(alertRepository.findUnacknowledgedAlerts(aircraft));
    }
}
