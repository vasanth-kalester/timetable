import 'package:flutter/material.dart';

class ReportBuilderScreen extends StatefulWidget {
  const ReportBuilderScreen({super.key});

  @override
  State<ReportBuilderScreen> createState() => _ReportBuilderScreenState();
}

class _ReportBuilderScreenState extends State<ReportBuilderScreen> {
  String _selectedReportType = 'Faculty Workload';
  String _selectedFormat = 'PDF';
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Report Builder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Build Custom Reports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Select filters and export formats to generate detailed operational reports.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Configuration Panel
                Expanded(
                  flex: 1,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Report Type', border: OutlineInputBorder()),
                            value: _selectedReportType,
                            items: ['Faculty Workload', 'Room Utilization', 'Timetable Quality'].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) setState(() => _selectedReportType = newValue);
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Academic Year', border: OutlineInputBorder()),
                            value: '2025-2026',
                            items: ['2024-2025', '2025-2026'].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (String? newValue) {},
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Department (Optional)', border: OutlineInputBorder()),
                            value: 'All Departments',
                            items: ['All Departments', 'Computer Science', 'Mechanical'].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (String? newValue) {},
                          ),
                          const SizedBox(height: 16),
                          
                          const Text('Export Format', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'PDF', label: Text('PDF'), icon: Icon(Icons.picture_as_pdf)),
                              ButtonSegment(value: 'Excel', label: Text('Excel'), icon: Icon(Icons.table_chart)),
                            ],
                            selected: {_selectedFormat},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() {
                                _selectedFormat = newSelection.first;
                              });
                            },
                          ),
                          
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isGenerating = true;
                                });
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (mounted) {
                                    setState(() {
                                      _isGenerating = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Report generated successfully!')),
                                    );
                                  }
                                });
                              },
                              icon: _isGenerating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.build),
                              label: Text(_isGenerating ? 'Generating...' : 'Generate Report'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // Preview Area
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 500,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outlineVariant, style: BorderStyle.solid),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.preview, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'Report Preview',
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Configure and generate a report to see the preview here.',
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
