package com.aircraft.compliance.config;

import com.aircraft.compliance.entity.Aircraft;
import com.aircraft.compliance.repository.AircraftRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import java.util.UUID;

@Configuration
@RequiredArgsConstructor
public class DataInitializer {
    
    @Bean
    CommandLineRunner initDatabase(AircraftRepository aircraftRepository) {
        return args -> {
            // Create a sample aircraft if it doesn't exist
            if (aircraftRepository.findAll().isEmpty()) {
                Aircraft aircraft = new Aircraft();
                aircraft.setId(UUID.fromString("550e8400-e29b-41d4-a716-446655440000"));
                aircraft.setTailNumber("N12345");
                aircraft.setAircraftType("Boeing 737");
                aircraft.setTotalRows(30);
                aircraft.setSeatsPerRow(6);
                
                aircraftRepository.save(aircraft);
                System.out.println("[v0] Sample aircraft created with ID: " + aircraft.getId());
            }
        };
    }
}
