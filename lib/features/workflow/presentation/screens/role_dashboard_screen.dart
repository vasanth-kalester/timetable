import 'package:flutter/material.dart';

class RoleDashboardScreen extends StatelessWidget {
  final String role; // 'principal', 'hod', 'faculty', 'student'

  const RoleDashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${role[0].toUpperCase()}${role.substring(1)} Dashboard'),
        actions: [
          IconButton(
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            if (role == 'principal') _buildPrincipalWidgets(theme),
            if (role == 'hod') _buildHODWidgets(theme),
            if (role == 'faculty') _buildFacultyWidgets(theme),
            if (role == 'student') _buildStudentWidgets(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPrincipalWidgets(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildWidgetCard('Pending Approvals', '12', Icons.fact_check, Colors.orange, theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildWidgetCard('Critical Alerts', '2', Icons.warning, Colors.red, theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildWidgetCard('Active Events', '1', Icons.event, Colors.blue, theme)),
          ],
        ),
        const SizedBox(height: 24),
        _buildListWidget('Recent Approvals', [
          'Faculty Leave: Dr. Sharma (CS) - Pending',
          'Room Change: ME201 to ME205 - Approved',
        ], theme),
      ],
    );
  }

  Widget _buildHODWidgets(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildWidgetCard('Dept Faculty on Leave', '3', Icons.person_off, Colors.orange, theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildWidgetCard('Pending Tasks', '5', Icons.task, Colors.blue, theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildWidgetCard('Substitutions Needed', '2', Icons.swap_horiz, Colors.red, theme)),
          ],
        ),
        const SizedBox(height: 24),
        _buildListWidget('Department Alerts', [
          'CS301 Lab needs a substitute for Period 3.',
          'Reminder: Upload internal marks by Friday.',
        ], theme),
      ],
    );
  }

  Widget _buildFacultyWidgets(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildWidgetCard('Today\'s Classes', '4', Icons.class_, Colors.blue, theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildWidgetCard('Pending Tasks', '2', Icons.task, Colors.orange, theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildWidgetCard('Leave Balance', '12', Icons.event_available, Colors.green, theme)),
          ],
        ),
        const SizedBox(height: 24),
        _buildListWidget('Today\'s Agenda', [
          'Period 1: CS301 - Room 101',
          'Period 3: CS305 Lab - Main Lab',
          'Period 5: Department Meeting',
        ], theme),
      ],
    );
  }

  Widget _buildStudentWidgets(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildWidgetCard('Today\'s Classes', '5', Icons.class_, Colors.blue, theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildWidgetCard('Upcoming Exams', '1', Icons.assignment, Colors.orange, theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildWidgetCard('Announcements', '3', Icons.campaign, Colors.purple, theme)),
          ],
        ),
        const SizedBox(height: 24),
        _buildListWidget('Today\'s Timetable', [
          'Period 1: CS301 (Dr. Ravi) - Room 101',
          'Period 2: MA201 (Dr. Gupta) - Room 102',
          'Period 3: Cancelled (Faculty on Leave)',
        ], theme),
      ],
    );
  }

  Widget _buildWidgetCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                Text(
                  value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListWidget(String title, List<String> items, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
