import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/csv_parser_service.dart';
import '../../application/providers/academic_provider.dart';
import '../../../../core/widgets/app_button.dart';

class CsvImportDialog extends ConsumerStatefulWidget {
  const CsvImportDialog({super.key});

  @override
  ConsumerState<CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends ConsumerState<CsvImportDialog> {
  final _csvController = TextEditingController(
    text: 'roll_number,register_number,name,email,department_id,semester_id\n'
        '21CS050,REG21CS050,Diana Prince,diana@student.campus,dept_cs,Sem 5\n'
        '21CS051,REG21CS051,Evan Wright,evan@student.campus,dept_cs,Sem 5\n'
        '21CS052,REG21CS052,Fiona Gallagher,fiona@student.campus,dept_cs,Sem 5',
  );

  CsvParseResult? _parseResult;
  bool _isImporting = false;

  void _analyzeCsv() {
    setState(() {
      _parseResult = CsvParserService.parseStudentsCsv(_csvController.text);
    });
  }

  @override
  void initState() {
    super.initState();
    _analyzeCsv();
  }

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bulk Student Import (CSV)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Paste or upload raw CSV content. Format: roll_number, register_number, name, email, department_id, semester_id',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _csvController,
                maxLines: 5,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (_) => _analyzeCsv(),
              ),
              const SizedBox(height: 16),
              if (_parseResult != null) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_parseResult!.validRecords.length} Valid Records Ready',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_parseResult!.parseErrors.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_parseResult!.parseErrors.length} Diagnostic Warnings',
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                if (_parseResult!.parseErrors.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 80),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _parseResult!.parseErrors
                            .map((e) => Text('• $e', style: const TextStyle(fontSize: 11, color: Colors.redAccent)))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    label: 'Confirm Import',
                    isLoading: _isImporting,
                    onPressed: _parseResult == null || _parseResult!.validRecords.isEmpty
                        ? null
                        : () async {
                            setState(() {
                              _isImporting = true;
                            });
                            final (count, errors) = await ref
                                .read(academicProvider.notifier)
                                .importStudents(_parseResult!.validRecords);

                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Successfully imported $count student records! ${errors.isNotEmpty ? "(${errors.length} skipped)" : ""}'),
                                ),
                              );
                            }
                          },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
