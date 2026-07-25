import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/infrastructure_providers.dart';

class InstitutionSettingsPage extends ConsumerWidget {
  const InstitutionSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institution Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Working Days'),
          _buildWorkingDays(ref),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Period Configuration'),
          _buildPeriods(ref),
          const SizedBox(height: 24),

          _buildSectionHeader('Institution Policies'),
          _buildPolicies(ref),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWorkingDays(WidgetRef ref) {
    final asyncDays = ref.watch(workingDaysProvider);

    return asyncDays.when(
      data: (days) => Card(
        child: Column(
          children: days.map((day) => SwitchListTile(
            title: Text(day.dayOfWeek),
            value: day.isEnabled,
            onChanged: (val) {
              // TODO: Update working day
            },
          )).toList(),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }

  Widget _buildPeriods(WidgetRef ref) {
    final asyncPeriods = ref.watch(periodsProvider);

    return asyncPeriods.when(
      data: (periods) => Card(
        child: Column(
          children: [
            ...periods.map((period) => ListTile(
              title: Text(period.name),
              subtitle: Text('${period.startTime} - ${period.endTime}'),
              trailing: period.isBreak ? const Chip(label: Text('Break')) : null,
              onTap: () {
                // TODO: Edit period
              },
            )),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Period'),
              onTap: () {
                // TODO: Add period
              },
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }

  Widget _buildPolicies(WidgetRef ref) {
    final asyncPolicies = ref.watch(policiesProvider);

    return asyncPolicies.when(
      data: (policies) => Card(
        child: Column(
          children: policies.map((policy) => ListTile(
            title: Text(policy.key),
            subtitle: Text(policy.description ?? ''),
            trailing: Text(policy.value, style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              // TODO: Edit policy
            },
          )).toList(),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }
}
