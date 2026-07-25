import 'package:flutter/material.dart';

class TimetableGrid extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> entries;
  final Function(String entryId, int newDay, int newPeriod)? onEntryMoved;

  const TimetableGrid({
    super.key,
    required this.title,
    required this.entries,
    this.onEntryMoved,
  });

  @override
  State<TimetableGrid> createState() => _TimetableGridState();
}

class _TimetableGridState extends State<TimetableGrid> {
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final int _periods = 8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                dataRowMaxHeight: 80,
                dataRowMinHeight: 80,
                columns: [
                  const DataColumn(label: Text('Day / Period', style: TextStyle(fontWeight: FontWeight.bold))),
                  for (int i = 1; i <= _periods; i++)
                    DataColumn(label: Text('Period $i\n(00:00 - 00:00)', textAlign: TextAlign.center)),
                ],
                rows: _days.asMap().entries.map((dayEntry) {
                  final dayIndex = dayEntry.key + 1; // 1-indexed for backend
                  final dayName = dayEntry.value;

                  return DataRow(
                    cells: [
                      DataCell(Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold))),
                      for (int period = 1; period <= _periods; period++)
                        DataCell(_buildCell(dayIndex, period, theme)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCell(int day, int period, ThemeData theme) {
    // Find entry for this cell
    final entry = widget.entries.firstWhere(
      (e) => e['dayOfWeek'] == day && e['period'] == period,
      orElse: () => {},
    );

    final hasEntry = entry.isNotEmpty;

    return DragTarget<String>(
      onWillAccept: (data) => data != null,
      onAccept: (entryId) {
        if (widget.onEntryMoved != null) {
          widget.onEntryMoved!(entryId, day, period);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Container(
          width: 120,
          height: 70,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isHovered 
                ? theme.colorScheme.primaryContainer.withOpacity(0.5) 
                : hasEntry 
                    ? theme.colorScheme.primaryContainer 
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovered 
                  ? theme.colorScheme.primary 
                  : hasEntry 
                      ? theme.colorScheme.primary.withOpacity(0.3) 
                      : theme.colorScheme.outlineVariant.withOpacity(0.5),
              style: hasEntry ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: hasEntry
              ? Draggable<String>(
                  data: entry['id'],
                  feedback: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 120,
                      height: 70,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          entry['sessionCode'] ?? '',
                          style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _buildEntryContent(entry, theme),
                  ),
                  child: _buildEntryContent(entry, theme),
                )
              : const Center(
                  child: Text('-', style: TextStyle(color: Colors.grey)),
                ),
        );
      },
    );
  }

  Widget _buildEntryContent(Map<String, dynamic> entry, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            entry['sessionCode'] ?? '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            entry['faculty'] ?? '',
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            entry['room'] ?? '',
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
