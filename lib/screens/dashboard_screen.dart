import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cabin_models.dart';
import '../services/cabin_service.dart';
import 'widgets/cabin_grid_widget.dart';
import 'widgets/alerts_widget.dart';
import 'widgets/row_details_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTabIndex = 0;
  String? _selectedAircraftId;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    // Delay the initialization to after the first frame to avoid setState during build
    if (!mounted) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      final cabinService = context.read<CabinService>();
      // TODO: Replace with actual aircraft ID from backend
      _selectedAircraftId = 'demo-aircraft-001';
      await cabinService.selectAircraft(_selectedAircraftId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aircraft Cabin Monitor'),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<CabinService>(
              builder: (context, cabinService, _) {
                return Center(
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: cabinService.isConnected
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cabinService.isConnected ? 'Connected' : 'Disconnected',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<CabinService>(
        builder: (context, cabinService, _) {
          if (cabinService.cabinStatus == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // Tab navigation
              Material(
                color: Colors.white,
                child: TabBar(
                  onTap: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    const Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
                    const Tab(icon: Icon(Icons.grid_3x3), text: 'Rows'),
                    Tab(
                      icon: const Icon(Icons.warning),
                      text:
                          'Alerts (${cabinService.alerts.where((a) => a.isActive).length})',
                    ),
                    const Tab(icon: Icon(Icons.settings), text: 'Settings'),
                  ],
                ),
              ),
              // Tab content
              Expanded(
                child: IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    _buildOverviewTab(cabinService),
                    _buildRowsTab(cabinService),
                    _buildAlertsTab(cabinService),
                    _buildSettingsTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(CabinService cabinService) {
    final status = cabinService.cabinStatus!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Devices',
                  status.totalDevices.toString(),
                  Colors.blue,
                  Icons.phone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Active Rows',
                  status.activeRows.length.toString(),
                  Colors.orange,
                  Icons.grid_on,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active Alerts',
                  status.activeAlerts.toString(),
                  Colors.yellow[700]!,
                  Icons.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Critical',
                  status.criticalAlerts.toString(),
                  Colors.red,
                  Icons.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Cabin grid
          const Text(
            'Cabin Layout',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          CabinGridWidget(cabinStatus: status),
        ],
      ),
    );
  }

  Widget _buildRowsTab(CabinService cabinService) {
    return RowDetailsWidget(cabinService: cabinService);
  }

  Widget _buildAlertsTab(CabinService cabinService) {
    return AlertsWidget(cabinService: cabinService);
  }

  Widget _buildSettingsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Settings'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
