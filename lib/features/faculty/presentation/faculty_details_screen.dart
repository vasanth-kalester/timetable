import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/faculty_provider.dart';
import 'scheduling_preferences_tab.dart';
import 'availability_calendar_tab.dart';
import 'leave_management_tab.dart';

class FacultyDetailsScreen extends ConsumerStatefulWidget {
  final String facultyId;

  const FacultyDetailsScreen({super.key, required this.facultyId});

  @override
  ConsumerState<FacultyDetailsScreen> createState() => _FacultyDetailsScreenState();
}

class _FacultyDetailsScreenState extends ConsumerState<FacultyDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facultyAsyncValue = ref.watch(facultyDetailProvider(widget.facultyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Details'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Scheduling'),
            Tab(text: 'Availability'),
            Tab(text: 'Leaves'),
          ],
        ),
      ),
      body: facultyAsyncValue.when(
        data: (faculty) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Profile Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        child: Text(faculty.name[0], style: const TextStyle(fontSize: 40)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        faculty.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ListTile(
                      title: const Text('Employee ID'),
                      subtitle: Text(faculty.employeeId),
                      leading: const Icon(Icons.badge),
                    ),
                    ListTile(
                      title: const Text('Email'),
                      subtitle: Text(faculty.email),
                      leading: const Icon(Icons.email),
                    ),
                    ListTile(
                      title: const Text('Department'),
                      subtitle: Text(faculty.departmentId),
                      leading: const Icon(Icons.business),
                    ),
                    ListTile(
                      title: const Text('Designation'),
                      subtitle: Text(faculty.designation ?? 'N/A'),
                      leading: const Icon(Icons.work),
                    ),
                    ListTile(
                      title: const Text('Employment Type'),
                      subtitle: Text(faculty.employmentType),
                      leading: const Icon(Icons.category),
                    ),
                    ListTile(
                      title: const Text('Status'),
                      subtitle: Text(faculty.status),
                      leading: const Icon(Icons.info),
                    ),
                  ],
                ),
              ),
              // Scheduling Preferences Tab
              SchedulingPreferencesTab(facultyId: widget.facultyId),
              // Availability Calendar Tab
              AvailabilityCalendarTab(facultyId: widget.facultyId),
              // Leave Management Tab
              LeaveManagementTab(facultyId: widget.facultyId),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
