package com.aircraft.compliance.service;

import com.aircraft.compliance.entity.Alert;
import com.aircraft.compliance.entity.Aircraft;
import com.aircraft.compliance.repository.AlertRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AlertService {
    private final AlertRepository alertRepository;

    @Transactional
    public Alert createAlert(Aircraft aircraft, Alert.AlertType type, Alert.Severity severity,
                            Integer rowNumber, Integer deviceCount, String message) {
        Alert alert = Alert.builder()
            .aircraft(aircraft)
            .alertType(type)
            .severity(severity)
            .rowNumber(rowNumber)
            .deviceCount(deviceCount)
            .message(message)
            .isActive(true)
            .crewAcknowledged(false)
            .build();

        return alertRepository.save(alert);
    }

    @Transactional
    public Alert acknowledgeAlert(UUID alertId, String crewMemberId) {
        Alert alert = alertRepository.findById(alertId)
            .orElseThrow(() -> new IllegalArgumentException("Alert not found"));

        alert.setCrewAcknowledged(true);
        alert.setAcknowledgedBy(crewMemberId);
        alert.setAcknowledgedAt(java.time.LocalDateTime.now());

        return alertRepository.save(alert);
    }

    @Transactional
    public Alert resolveAlert(UUID alertId) {
        Alert alert = alertRepository.findById(alertId)
            .orElseThrow(() -> new IllegalArgumentException("Alert not found"));

        alert.setIsActive(false);
        alert.setResolvedAt(java.time.LocalDateTime.now());

        return alertRepository.save(alert);
    }

    @Transactional(readOnly = true)
    public List<Alert> getActiveAlerts(Aircraft aircraft) {
        return alertRepository.findActiveAlerts(aircraft);
    }

    @Transactional(readOnly = true)
    public List<Alert> getUnacknowledgedAlerts(Aircraft aircraft) {
        return alertRepository.findUnacknowledgedAlerts(aircraft);
    }
}
