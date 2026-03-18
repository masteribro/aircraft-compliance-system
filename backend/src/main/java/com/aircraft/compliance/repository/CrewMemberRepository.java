package com.aircraft.compliance.repository;

import com.aircraft.compliance.entity.CrewMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CrewMemberRepository extends JpaRepository<CrewMember, UUID> {
    Optional<CrewMember> findByUsername(String username);
}
