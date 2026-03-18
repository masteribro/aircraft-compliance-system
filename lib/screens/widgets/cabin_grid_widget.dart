import 'package:flutter/material.dart';
import '../../models/cabin_models.dart';

class CabinGridWidget extends StatelessWidget {
  final CabinStatus cabinStatus;

  const CabinGridWidget({
    super.key,
    required this.cabinStatus,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          cabinStatus.activeRows.length,
          (index) {
            final row = cabinStatus.activeRows[index];
            final deviceCount = cabinStatus.devicesByRow[row] ?? 0;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  // TODO: Navigate to row details
                },
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _getRowColor(deviceCount),
                        border: Border.all(
                          color: _getRowBorderColor(deviceCount),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Row',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$row',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$deviceCount dev',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Row $row',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          },
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

  Color _getRowBorderColor(int deviceCount) {
    if (deviceCount == 0) return Colors.green[700]!;
    if (deviceCount <= 2) return Colors.orange;
    if (deviceCount <= 5) return Colors.deepOrange;
    return Colors.red[900]!;
  }
}
