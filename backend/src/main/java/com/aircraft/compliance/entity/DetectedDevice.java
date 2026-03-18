package com.aircraft.compliance.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "detected_devices")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DetectedDevice {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "aircraft_id", nullable = false)
    private Aircraft aircraft;

    @ManyToOne
    @JoinColumn(name = "sensor_id", nullable = false)
    private Sensor sensor;

    @Column(nullable = false)
    private String macAddress;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private DeviceType deviceType;

    @Column(nullable = false)
    private Integer signalStrength; // dBm value

    private Integer estimatedRow;

    @Column(columnDefinition = "numeric(3,2)")
    private Double confidenceScore;

    @Column(nullable = false)
    private Boolean isInAirplaneMode;

    @Column(nullable = false, updatable = false)
    private LocalDateTime detectedAt;

    @Column(nullable = false)
    private LocalDateTime lastSeen;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private Status status;

    @PrePersist
    protected void onCreate() {
        detectedAt = LocalDateTime.now();
        lastSeen = LocalDateTime.now();
        status = Status.ACTIVE;
        isInAirplaneMode = false;
        confidenceScore = 0.0;
    }

    public enum DeviceType {
        WIFI_PROBE, BLUETOOTH_BEACON, CELLULAR, UNKNOWN
    }

    public enum Status {
        ACTIVE, IDLE, INACTIVE
    }
}
