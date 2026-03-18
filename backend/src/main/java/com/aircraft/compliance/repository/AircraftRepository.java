package com.aircraft.compliance.repository;

import com.aircraft.compliance.entity.Aircraft;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AircraftRepository extends JpaRepository<Aircraft, UUID> {
    Optional<Aircraft> findByTailNumber(String tailNumber);
}
