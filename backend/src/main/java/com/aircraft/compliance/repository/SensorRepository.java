package com.aircraft.compliance.repository;

import com.aircraft.compliance.entity.Sensor;
import com.aircraft.compliance.entity.Aircraft;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface SensorRepository extends JpaRepository<Sensor, UUID> {
    List<Sensor> findByAircraft(Aircraft aircraft);
    List<Sensor> findByAircraftAndStatus(Aircraft aircraft, Sensor.Status status);
}
