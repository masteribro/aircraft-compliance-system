class Aircraft {
  final String id;
  final String tailNumber;
  final String aircraftType;
  final int totalRows;
  final int seatsPerRow;

  Aircraft({
    required this.id,
    required this.tailNumber,
    required this.aircraftType,
    required this.totalRows,
    required this.seatsPerRow,
  });

  factory Aircraft.fromJson(Map<String, dynamic> json) {
    return Aircraft(
      id: json['id'] as String,
      tailNumber: json['tailNumber'] as String,
      aircraftType: json['aircraftType'] as String,
      totalRows: json['totalRows'] as int,
      seatsPerRow: json['seatsPerRow'] as int,
    );
  }
}

class DetectedDevice {
  final String id;
  final String macAddress;
  final String deviceType;
  final int signalStrength;
  final int? estimatedRow;
  final bool isInAirplaneMode;

  DetectedDevice({
    required this.id,
    required this.macAddress,
    required this.deviceType,
    required this.signalStrength,
    this.estimatedRow,
    required this.isInAirplaneMode,
  });

  factory DetectedDevice.fromJson(Map<String, dynamic> json) {
    return DetectedDevice(
      id: json['id'] as String,
      macAddress: json['macAddress'] as String,
      deviceType: json['deviceType'] as String,
      signalStrength: json['signalStrength'] as int,
      estimatedRow: json['estimatedRow'] as int?,
      isInAirplaneMode: json['isInAirplaneMode'] as bool? ?? false,
    );
  }
}

class CabinAlert {
  final String id;
  final String alertType;
  final String severity;
  final int? rowNumber;
  final int deviceCount;
  final String message;
  final bool isActive;
  final bool crewAcknowledged;

  CabinAlert({
    required this.id,
    required this.alertType,
    required this.severity,
    this.rowNumber,
    required this.deviceCount,
    required this.message,
    required this.isActive,
    required this.crewAcknowledged,
  });

  factory CabinAlert.fromJson(Map<String, dynamic> json) {
    return CabinAlert(
      id: json['id'] as String,
      alertType: json['alertType'] as String,
      severity: json['severity'] as String,
      rowNumber: json['rowNumber'] as int?,
      deviceCount: json['deviceCount'] as int,
      message: json['message'] as String,
      isActive: json['isActive'] as bool? ?? true,
      crewAcknowledged: json['crewAcknowledged'] as bool? ?? false,
    );
  }

  Color getSeverityColor() {
    switch (severity) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.yellow;
      case 'LOW':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class CabinStatus {
  final int totalDevices;
  final List<int> activeRows;
  final Map<int, int> devicesByRow;
  final int activeAlerts;
  final int criticalAlerts;

  CabinStatus({
    required this.totalDevices,
    required this.activeRows,
    required this.devicesByRow,
    required this.activeAlerts,
    required this.criticalAlerts,
  });

  factory CabinStatus.fromJson(Map<String, dynamic> json) {
    final devicesByRowJson = json['devicesByRow'] as Map<String, dynamic>? ?? {};
    final devicesByRow = devicesByRowJson.cast<int, int>();

    return CabinStatus(
      totalDevices: json['totalDevices'] as int? ?? 0,
      activeRows: List<int>.from(json['activeRows'] as List? ?? []),
      devicesByRow: devicesByRow,
      activeAlerts: json['activeAlerts'] as int? ?? 0,
      criticalAlerts: json['criticalAlerts'] as int? ?? 0,
    );
  }
}

import 'package:flutter/material.dart';
