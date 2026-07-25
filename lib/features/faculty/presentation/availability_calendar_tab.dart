import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/faculty_provider.dart';

class AvailabilityCalendarTab extends ConsumerWidget {
  final String facultyId;

  const AvailabilityCalendarTab({super.key, required this.facultyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availabilityAsyncValue = ref.watch(availabilityProvider(facultyId));

    return availabilityAsyncValue.when(
      data: (availabilityList) {
        if (availabilityList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No availability records found.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Implement add availability
                  },
                  child: const Text('Add Availability'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: availabilityList.length,
          itemBuilder: (context, index) {
            final avail = availabilityList[index];
            final dayName = _getDayName(avail.dayOfWeek);
            
            return Card(
              child: ListTile(
                leading: Icon(
                  avail.isAvailable ? Icons.check_circle : Icons.cancel,
                  color: avail.isAvailable ? Colors.green : Colors.red,
                ),
                title: Text('$dayName - Period ${avail.period}'),
                subtitle: Text(avail.reason ?? (avail.isAvailable ? 'Available' : 'Unavailable')),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Implement edit availability
                  },
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }
}
