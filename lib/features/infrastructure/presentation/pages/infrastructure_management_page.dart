import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/infrastructure_providers.dart';
import '../models/infrastructure_models.dart';

class InfrastructureManagementPage extends ConsumerStatefulWidget {
  const InfrastructureManagementPage({super.key});

  @override
  ConsumerState<InfrastructureManagementPage> createState() => _InfrastructureManagementPageState();
}

class _InfrastructureManagementPageState extends ConsumerState<InfrastructureManagementPage> {
  String? selectedBuildingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infrastructure Management'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buildings Column
          Expanded(
            flex: 1,
            child: _buildBuildingsColumn(),
          ),
          const VerticalDivider(width: 1),

          // Classrooms Column
          Expanded(
            flex: 2,
            child: selectedBuildingId == null
                ? const Center(child: Text('Select a building to view classrooms'))
                : _buildClassroomsColumn(),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingsColumn() {
    final asyncBuildings = ref.watch(buildingsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Buildings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(icon: const Icon(Icons.add), onPressed: () {}),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: asyncBuildings.when(
            data: (buildings) => ListView.builder(
              itemCount: buildings.length,
              itemBuilder: (context, index) {
                final building = buildings[index];
                return ListTile(
                  title: Text(building.name),
                  subtitle: Text(building.code),
                  selected: selectedBuildingId == building.id,
                  onTap: () => setState(() => selectedBuildingId = building.id),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildClassroomsColumn() {
    final asyncClassrooms = ref.watch(classroomsProvider(selectedBuildingId));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Classrooms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Classroom'),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: asyncClassrooms.when(
            data: (classrooms) => classrooms.isEmpty
                ? const Center(child: Text('No classrooms in this building'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: classrooms.length,
                    itemBuilder: (context, index) {
                      final room = classrooms[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(room.roomNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('Capacity: ${room.capacity}'),
                              const Spacer(),
                              Row(
                                children: [
                                  if (room.isSmart) const Icon(Icons.tv, size: 16, color: Colors.blue),
                                  if (room.hasProjector) const Icon(Icons.videocam, size: 16, color: Colors.green),
                                  if (room.hasAC) const Icon(Icons.ac_unit, size: 16, color: Colors.cyan),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}
