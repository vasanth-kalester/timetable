import 'package:flutter/material.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  String _selectedBuilding = 'Engineering Block';
  int _selectedFloor = 1;

  // Mock data for the campus map
  final Map<String, Map<int, List<Map<String, dynamic>>>> _campusData = {
    'Engineering Block': {
      1: [
        {'id': 'B101', 'name': 'Room B101', 'status': 'occupied', 'utilization': 85, 'currentClass': 'CS301 - OS', 'faculty': 'Dr. Ravi', 'capacity': 60},
        {'id': 'B102', 'name': 'Room B102', 'status': 'available', 'utilization': 40, 'currentClass': null, 'faculty': null, 'capacity': 60},
        {'id': 'L103', 'name': 'Lab L103', 'status': 'occupied', 'utilization': 95, 'currentClass': 'CS305 - OS Lab', 'faculty': 'Dr. Priya', 'capacity': 30},
        {'id': 'B104', 'name': 'Room B104', 'status': 'maintenance', 'utilization': 0, 'currentClass': null, 'faculty': null, 'capacity': 60},
      ],
      2: [
        {'id': 'B201', 'name': 'Room B201', 'status': 'occupied', 'utilization': 75, 'currentClass': 'ME201 - Thermo', 'faculty': 'Dr. Arjun', 'capacity': 60},
        {'id': 'B202', 'name': 'Room B202', 'status': 'available', 'utilization': 50, 'currentClass': null, 'faculty': null, 'capacity': 60},
      ],
    },
    'Science Block': {
      1: [
        {'id': 'S101', 'name': 'Room S101', 'status': 'occupied', 'utilization': 90, 'currentClass': 'PH101 - Physics', 'faculty': 'Dr. Sharma', 'capacity': 80},
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final floors = _campusData[_selectedBuilding]!;
    final rooms = floors[_selectedFloor] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Twin Campus Map'),
        actions: [
          // Building Selector
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedBuilding,
              items: _campusData.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedBuilding = newValue!;
                  _selectedFloor = _campusData[newValue]!.keys.first;
                });
              },
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Row(
        children: [
          // Left Sidebar: Floor Selector & Legend
          Container(
            width: 200,
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Floors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...floors.keys.map((floor) {
                  final isSelected = floor == _selectedFloor;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedFloor = floor),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Floor $floor',
                          style: TextStyle(
                            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                
                const Spacer(),
                
                const Text('Legend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildLegendItem('Occupied', Colors.red, theme),
                const SizedBox(height: 8),
                _buildLegendItem('Available', Colors.green, theme),
                const SizedBox(height: 8),
                _buildLegendItem('Maintenance', Colors.orange, theme),
              ],
            ),
          ),
          
          // Main Area: Interactive Map
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_selectedBuilding - Floor $_selectedFloor',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap on any room to view real-time status and schedule.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 40),
                  
                  // Map Grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return _buildRoomNode(room, theme);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildRoomNode(Map<String, dynamic> room, ThemeData theme) {
    final status = room['status'] as String;
    
    Color statusColor;
    switch (status) {
      case 'occupied':
        statusColor = Colors.red;
        break;
      case 'available':
        statusColor = Colors.green;
        break;
      case 'maintenance':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return InkWell(
      onTap: () => _showRoomDetails(room, theme),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  room['name'] as String,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(
                  status == 'occupied' ? Icons.people : (status == 'maintenance' ? Icons.build : Icons.check_circle),
                  color: statusColor,
                ),
              ],
            ),
            const Spacer(),
            if (status == 'occupied') ...[
              Text(
                room['currentClass'] as String,
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                room['faculty'] as String,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
              ),
            ] else if (status == 'available') ...[
              Text(
                'Available',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ] else ...[
              Text(
                'Under Maintenance',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ],
            const Spacer(),
            LinearProgressIndicator(
              value: (room['utilization'] as int) / 100,
              backgroundColor: statusColor.withOpacity(0.2),
              color: statusColor,
              minHeight: 4,
            ),
            const SizedBox(height: 4),
            Text(
              'Weekly Utilization: ${room['utilization']}%',
              style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoomDetails(Map<String, dynamic> room, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.meeting_room, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(room['name'] as String),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Status', room['status'].toString().toUpperCase(), theme),
            _buildDetailRow('Capacity', '${room['capacity']} students', theme),
            _buildDetailRow('Weekly Utilization', '${room['utilization']}%', theme),
            const Divider(height: 32),
            if (room['status'] == 'occupied') ...[
              const Text('Current Session', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDetailRow('Class', room['currentClass'] as String, theme),
              _buildDetailRow('Faculty', room['faculty'] as String, theme),
            ] else ...[
              const Text('Next Session', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDetailRow('Class', 'CS302 - DB', theme),
              _buildDetailRow('Time', 'Period 4', theme),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {},
            child: const Text('View Full Schedule'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
