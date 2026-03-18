import 'package:flutter/material.dart';
import '../../services/cabin_service.dart';

class RowDetailsWidget extends StatelessWidget {
  final CabinService cabinService;

  const RowDetailsWidget({super.key, required this.cabinService});

  @override
  Widget build(BuildContext context) {
    final status = cabinService.cabinStatus;
    if (status == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: status.activeRows.length,
      itemBuilder: (context, index) {
        final row = status.activeRows[index];
        final deviceCount = status.devicesByRow[row] ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getRowColor(deviceCount),
                  ),
                  child: Center(
                    child: Text(
                      '$row',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Row $row',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$deviceCount device${deviceCount != 1 ? 's' : ''}',
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
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seats: A B C D E F',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: ['A', 'B', 'C', 'D', 'E', 'F']
                          .map((seat) => _buildSeatWidget(deviceCount > 0))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Signal Strength Average: -45 dBm',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.7,
                      backgroundColor: Colors.grey[300],
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeatWidget(bool hasDevice) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasDevice ? Colors.orange[100] : Colors.green[100],
        border: Border.all(
          color: hasDevice ? Colors.orange : Colors.green,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          hasDevice ? Icons.phone : Icons.person,
          size: 16,
          color: hasDevice ? Colors.orange : Colors.green,
        ),
      ),
    );
  }

  Color _getRowColor(int deviceCount) {
    if (deviceCount == 0) return Colors.green;
    if (deviceCount <= 2) return Colors.yellow[700]!;
    if (deviceCount <= 5) return Colors.orange;
    return Colors.red;
  }
}
