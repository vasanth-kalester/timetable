import '../../domain/entities/academic_entities.dart';

class CsvParseResult {
  final List<StudentRecordEntity> validRecords;
  final List<String> parseErrors;

  const CsvParseResult({
    required this.validRecords,
    required this.parseErrors,
  });
}

class CsvParserService {
  /// Parses raw CSV string data into StudentRecordEntity list with diagnostics.
  static CsvParseResult parseStudentsCsv(String rawCsv) {
    final List<StudentRecordEntity> records = [];
    final List<String> errors = [];

    final lines = rawCsv.split('\n').where((l) => l.trim().isNotEmpty).toList();

    if (lines.isEmpty) {
      return const CsvParseResult(validRecords: [], parseErrors: ['CSV content is empty.']);
    }

    // Header check
    final header = lines.first.toLowerCase().split(',');
    if (!header.contains('roll_number') || !header.contains('name')) {
      return const CsvParseResult(
        validRecords: [],
        parseErrors: ['Invalid CSV header. Expected columns: roll_number, register_number, name, email, department_id, semester_id'],
      );
    }

    for (int i = 1; i < lines.length; i++) {
      final cols = lines[i].split(',').map((c) => c.trim()).toList();
      if (cols.length < 3) {
        errors.add('Line ${i + 1}: Insufficient columns (found ${cols.length}, expected at least 3).');
        continue;
      }

      final roll = cols[0];
      final reg = cols.length > 1 && cols[1].isNotEmpty ? cols[1] : 'REG_$roll';
      final name = cols.length > 2 ? cols[2] : '';
      final email = cols.length > 3 && cols[3].isNotEmpty ? cols[3] : '$roll@student.campus';
      final dept = cols.length > 4 ? cols[4] : 'dept_cs';
      final sem = cols.length > 5 ? cols[5] : 'Sem 5';

      if (roll.isEmpty || name.isEmpty) {
        errors.add('Line ${i + 1}: Missing mandatory roll_number or name field.');
        continue;
      }

      records.add(StudentRecordEntity(
        id: 'std_csv_$i',
        rollNumber: roll,
        registerNumber: reg,
        fullName: name,
        email: email,
        departmentId: dept,
        programId: 'prog_btech_cs',
        semesterId: sem,
        sectionId: 'sec_a',
      ));
    }

    return CsvParseResult(validRecords: records, parseErrors: errors);
  }
}
