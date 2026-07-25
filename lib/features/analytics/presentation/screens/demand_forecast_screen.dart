import 'package:flutter/material.dart';

class DemandForecastScreen extends StatefulWidget {
  const DemandForecastScreen({super.key});

  @override
  State<DemandForecastScreen> createState() => _DemandForecastScreenState();
}

class _DemandForecastScreenState extends State<DemandForecastScreen> {
  double _growthRate = 10.0; // 10%
  bool _isForecasted = false;

  // Mock forecast results
  final Map<String, dynamic> _forecastResults = {
    'projectedGrowthRate': 0.1,
    'forecastedPeriods': 1562,
    'projectedUtilization': 86.7,
    'roomsShortfall': 1,
    'recommendation': 'Need 1 more room to maintain safe utilization levels.',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demand Forecaster'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forecast Next Semester',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Estimate future resource requirements based on projected student intake growth.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Form
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
                          const Text('Projected Growth Rate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${_growthRate.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              Icon(Icons.trending_up, color: theme.colorScheme.primary),
                            ],
                          ),
                          Slider(
                            value: _growthRate,
                            min: 0,
                            max: 50,
                            divisions: 50,
                            label: '${_growthRate.toStringAsFixed(1)}%',
                            onChanged: (value) {
                              setState(() {
                                _growthRate = value;
                              });
                            },
                          ),
                          
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isForecasted = true;
                                });
                              },
                              icon: const Icon(Icons.analytics),
                              label: const Text('Generate Forecast'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // Results Area
                Expanded(
                  flex: 2,
                  child: _isForecasted ? _buildResultsArea(theme) : _buildEmptyState(theme),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.query_stats, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Adjust the growth rate and generate a forecast.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsArea(ThemeData theme) {
    final res = _forecastResults;
    final shortfall = res['roomsShortfall'] as int;
    
    final statusColor = shortfall > 0 ? Colors.orange : Colors.green;
    final statusIcon = shortfall > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recommendation Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommendation',
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      res['recommendation'] as String,
                      style: TextStyle(color: statusColor.withOpacity(0.8), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Metrics Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2,
          children: [
            _buildResultCard('Forecasted Periods', '${res['forecastedPeriods']}', 'Total periods per week', Icons.schedule, Colors.blue, theme),
            _buildResultCard('Projected Utilization', '${res['projectedUtilization']}%', 'Across all rooms', Icons.trending_up, Colors.purple, theme),
            _buildResultCard('Rooms Shortfall', '$shortfall', 'Additional rooms needed', Icons.meeting_room, Colors.orange, theme),
          ],
        ),
      ],
    );
  }

  Widget _buildResultCard(String title, String value, String subtitle, IconData icon, Color color, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
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
