package com.aircraft.compliance.controller;

import com.aircraft.compliance.entity.Alert;
import com.aircraft.compliance.repository.AlertRepository;
import com.aircraft.compliance.service.AlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController
@RequestMapping("/alerts")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AlertController {
    private final AlertService alertService;
    private final AlertRepository alertRepository;

    @PostMapping("/{alertId}/acknowledge")
    public ResponseEntity<Alert> acknowledgeAlert(
            @PathVariable UUID alertId,
            @RequestParam String acknowledgedBy) {
        Alert alert = alertService.acknowledgeAlert(alertId, acknowledgedBy);
        return ResponseEntity.ok(alert);
    }

    @PostMapping("/{alertId}/resolve")
    public ResponseEntity<Alert> resolveAlert(@PathVariable UUID alertId) {
        Alert alert = alertService.resolveAlert(alertId);
        return ResponseEntity.ok(alert);
    }

    @GetMapping("/{alertId}")
    public ResponseEntity<Alert> getAlert(@PathVariable UUID alertId) {
        return alertRepository.findById(alertId)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
}
