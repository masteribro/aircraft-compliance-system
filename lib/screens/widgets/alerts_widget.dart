import 'package:flutter/material.dart';
import '../../services/cabin_service.dart';

class AlertsWidget extends StatelessWidget {
  final CabinService cabinService;

  const AlertsWidget({super.key, required this.cabinService});

  @override
  Widget build(BuildContext context) {
    final activeAlerts = cabinService.alerts.where((a) => a.isActive).toList();

    if (activeAlerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Active Alerts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Cabin is clear',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeAlerts.length,
      itemBuilder: (context, index) {
        final alert = activeAlerts[index];
        return _buildAlertCard(context, alert);
      },
    );
  }

  Widget _buildAlertCard(BuildContext context, CabinAlert alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: alert.getSeverityColor(),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert.alertType.replaceAll('_', ' '),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: alert.getSeverityColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              alert.severity,
                              style: TextStyle(
                                fontSize: 12,
                                color: alert.getSeverityColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (alert.rowNumber != null)
                        Text(
                          'Row ${alert.rowNumber} • ${alert.deviceCount} device(s)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.message,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            if (!alert.crewAcknowledged)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    cabinService.acknowledgeAlert(alert.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alert acknowledged'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alert.getSeverityColor(),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Acknowledge'),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Acknowledged',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
