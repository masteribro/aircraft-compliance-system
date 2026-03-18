package com.aircraft.compliance.repository;

import com.aircraft.compliance.entity.Alert;
import com.aircraft.compliance.entity.Aircraft;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface AlertRepository extends JpaRepository<Alert, UUID> {
    @Query("SELECT a FROM Alert a WHERE a.aircraft = ?1 AND a.isActive = true ORDER BY a.severity DESC, a.createdAt DESC")
    List<Alert> findActiveAlerts(Aircraft aircraft);
    
    List<Alert> findByAircraftAndIsActiveTrue(Aircraft aircraft);
    
    @Query("SELECT a FROM Alert a WHERE a.aircraft = ?1 AND a.crewAcknowledged = false ORDER BY a.createdAt DESC")
    List<Alert> findUnacknowledgedAlerts(Aircraft aircraft);
}
