package com.aircraft.compliance.repository;

import com.aircraft.compliance.entity.DetectedDevice;
import com.aircraft.compliance.entity.Aircraft;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface DetectedDeviceRepository extends JpaRepository<DetectedDevice, UUID> {
    List<DetectedDevice> findByAircraftAndStatus(Aircraft aircraft, DetectedDevice.Status status);
    
    @Query("SELECT d FROM DetectedDevice d WHERE d.aircraft = ?1 AND d.lastSeen > ?2 AND d.status = ?3")
    List<DetectedDevice> findRecentDevices(Aircraft aircraft, LocalDateTime sinceTime, DetectedDevice.Status status);
    
    @Query("SELECT COUNT(d) FROM DetectedDevice d WHERE d.aircraft = ?1 AND d.estimatedRow = ?2 AND d.status = ?3")
    Long countDevicesByRow(Aircraft aircraft, Integer row, DetectedDevice.Status status);
    
    @Query("SELECT DISTINCT d.estimatedRow FROM DetectedDevice d WHERE d.aircraft = ?1 AND d.estimatedRow IS NOT NULL AND d.status = ?2")
    List<Integer> findActiveRows(Aircraft aircraft, DetectedDevice.Status status);
}
