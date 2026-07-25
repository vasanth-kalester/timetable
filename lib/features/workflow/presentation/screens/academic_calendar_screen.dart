import 'package:flutter/material.dart';

class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  // Mock calendar events
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime(2026, 10, 15): [
      {'title': 'Mid-Term Exams Begin', 'type': 'exam', 'time': 'All Day'},
      {'title': 'Guest Lecture: AI in Healthcare', 'type': 'event', 'time': '2:00 PM - 4:00 PM'},
    ],
    DateTime(2026, 10, 20): [
      {'title': 'Diwali Holiday', 'type': 'holiday', 'time': 'All Day'},
    ],
    DateTime(2026, 10, 25): [
      {'title': 'Department Meeting', 'type': 'meeting', 'time': '10:00 AM - 11:30 AM'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Normalize selected date to match map keys
    final normalizedSelectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final selectedEvents = _events[normalizedSelectedDate] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Calendar'),
        actions: [
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add Event'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Calendar View (Mocked with a simple list for now, in a real app use table_calendar)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'October 2026',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildMockCalendarGrid(theme),
                  
                  const Spacer(),
                  const Text('Legend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildLegendItem('Exam', Colors.red, theme),
                      const SizedBox(width: 16),
                      _buildLegendItem('Holiday', Colors.green, theme),
                      const SizedBox(width: 16),
                      _buildLegendItem('Event', Colors.blue, theme),
                      const SizedBox(width: 16),
                      _buildLegendItem('Meeting', Colors.orange, theme),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Right Side: Events for Selected Day
          Expanded(
            flex: 1,
            child: Container(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Events on ${_selectedDate.day} Oct',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  if (selectedEvents.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No events scheduled for this day.'),
                      ),
                    )
                  else
                    ...selectedEvents.map((event) => _buildEventCard(event, theme)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockCalendarGrid(ThemeData theme) {
    // A very simple mock calendar grid for demonstration
    final daysInMonth = 31;
    final firstDayOffset = 3; // Assuming month starts on Thursday
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.5,
      ),
      itemCount: 42, // 6 rows * 7 days
      itemBuilder: (context, index) {
        if (index < 7) {
          // Day headers
          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          return Center(child: Text(days[index], style: const TextStyle(fontWeight: FontWeight.bold)));
        }
        
        final dayNumber = index - 7 - firstDayOffset + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }
        
        final date = DateTime(2026, 10, dayNumber);
        final hasEvents = _events.containsKey(date);
        final isSelected = date.day == _selectedDate.day;
        
        return InkWell(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : (hasEvents ? theme.colorScheme.primaryContainer.withOpacity(0.3) : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: isSelected ? null : Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                      fontWeight: isSelected || hasEvents ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (hasEvents)
                  Positioned(
                    bottom: 4,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, ThemeData theme) {
    final type = event['type'] as String;
    
    Color color;
    IconData icon;
    switch (type) {
      case 'exam': color = Colors.red; icon = Icons.assignment; break;
      case 'holiday': color = Colors.green; icon = Icons.celebration; break;
      case 'meeting': color = Colors.orange; icon = Icons.groups; break;
      default: color = Colors.blue; icon = Icons.event;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        event['time'] as String,
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
