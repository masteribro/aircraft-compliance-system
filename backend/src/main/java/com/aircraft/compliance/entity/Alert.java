package com.aircraft.compliance.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "alerts")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Alert {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "aircraft_id", nullable = false)
    private Aircraft aircraft;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private AlertType alertType;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private Severity severity;

    private Integer rowNumber;

    @Column(nullable = false)
    private Integer deviceCount;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String message;

    @Column(nullable = false)
    private Boolean isActive;

    @Column(nullable = false)
    private Boolean crewAcknowledged;

    private String acknowledgedBy;

    private LocalDateTime acknowledgedAt;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime resolvedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        isActive = true;
        crewAcknowledged = false;
    }

    public enum AlertType {
        DEVICE_DETECTED, MULTIPLE_DEVICES, AIRPLANE_MODE_WARNING, SENSOR_ERROR
    }

    public enum Severity {
        INFO, LOW, MEDIUM, HIGH, CRITICAL
    }
}
