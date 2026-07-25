import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/faculty_provider.dart';

class SchedulingPreferencesTab extends ConsumerWidget {
  final String facultyId;

  const SchedulingPreferencesTab({super.key, required this.facultyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(schedulingProfileProvider(facultyId));

    return profileAsyncValue.when(
      data: (profile) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Workload Configuration', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Max Periods Per Day'),
                      trailing: Text('${profile.maxPeriodsPerDay}'),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Max Periods Per Week'),
                      trailing: Text('${profile.maxPeriodsPerWeek}'),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Max Consecutive Classes'),
                      trailing: Text('${profile.maxConsecutiveClasses}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Avoid First Hour'),
                      value: profile.avoidFirstHour,
                      onChanged: null, // Disabled for view mode
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Avoid Last Hour'),
                      value: profile.avoidLastHour,
                      onChanged: null,
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Preferred Free Day'),
                      trailing: Text(profile.preferredFreeDay ?? 'None'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Capabilities', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('Can Handle Theory'),
                      value: profile.canHandleTheory,
                      onChanged: null,
                    ),
                    const Divider(),
                    CheckboxListTile(
                      title: const Text('Can Handle Labs'),
                      value: profile.canHandleLabs,
                      onChanged: null,
                    ),
                    const Divider(),
                    CheckboxListTile(
                      title: const Text('Can Handle Tutorials'),
                      value: profile.canHandleTutorials,
                      onChanged: null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No scheduling profile found.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement create profile
              },
              child: const Text('Create Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
