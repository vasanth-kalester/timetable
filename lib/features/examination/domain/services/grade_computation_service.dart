import '../models/examination_models.dart';

class GradeComputationService {
  /// Converts raw marks into a Grade Point (0.0 to 10.0 scale) and Letter Grade.
  static GradeRecord computeGrade({
    required String id,
    required String studentId,
    required String subjectId,
    required double internalMarks,
    required double externalMarks,
  }) {
    double total = internalMarks + externalMarks;
    double gradePoint;
    String letterGrade;

    if (total >= 90) {
      gradePoint = 10.0; letterGrade = 'S';
    } else if (total >= 80) {
      gradePoint = 9.0; letterGrade = 'A';
    } else if (total >= 70) {
      gradePoint = 8.0; letterGrade = 'B';
    } else if (total >= 60) {
      gradePoint = 7.0; letterGrade = 'C';
    } else if (total >= 50) {
      gradePoint = 6.0; letterGrade = 'D';
    } else if (total >= 40) {
      gradePoint = 5.0; letterGrade = 'E';
    } else {
      gradePoint = 0.0; letterGrade = 'F'; // Fail
    }

    return GradeRecord(
      id: id,
      studentId: studentId,
      subjectId: subjectId,
      internalMarks: internalMarks,
      externalMarks: externalMarks,
      // Note: In real scenarios, these would be saved in DB. 
      // We are just returning them computed for the model.
      // We can augment GradeRecord to store these or just calculate on the fly.
    );
  }

  /// Calculates SGPA for a semester.
  /// SGPA = Sum(GradePoint * Credits) / Sum(Credits)
  static double calculateSGPA(List<GradeRecord> records, Map<String, int> subjectCredits) {
    if (records.isEmpty) return 0.0;

    double totalPoints = 0;
    int totalCredits = 0;

    for (var record in records) {
      int credits = subjectCredits[record.subjectId] ?? 3; // Default 3 credits
      double gradePoint = _getGradePoint(record.totalMarks);
      
      totalPoints += (gradePoint * credits);
      totalCredits += credits;
    }

    if (totalCredits == 0) return 0.0;
    return (totalPoints / totalCredits);
  }

  /// Calculates CGPA across multiple semesters.
  static double calculateCGPA(List<SemesterRecord> semesters) {
    if (semesters.isEmpty) return 0.0;

    double totalPoints = 0;
    int totalCredits = 0;

    for (var sem in semesters) {
      totalPoints += (sem.sgpa * sem.creditsCompleted);
      totalCredits += sem.creditsCompleted;
    }

    if (totalCredits == 0) return 0.0;
    return (totalPoints / totalCredits);
  }

  static double _getGradePoint(double totalMarks) {
    if (totalMarks >= 90) return 10.0;
    if (totalMarks >= 80) return 9.0;
    if (totalMarks >= 70) return 8.0;
    if (totalMarks >= 60) return 7.0;
    if (totalMarks >= 50) return 6.0;
    if (totalMarks >= 40) return 5.0;
    return 0.0;
  }
}
