package com.aircraft.compliance;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class AircraftComplianceApplication {

    public static void main(String[] args) {
        SpringApplication.run(AircraftComplianceApplication.class, args);
    }
}
