from sqlalchemy.orm import Session
from typing import List, Dict, Any
import uuid

from models.validation import ValidationReport, ValidationResult
from models.academic import AcademicYear, Department, Program, Semester, Section, Subject
from models.faculty import Faculty, SchedulingProfile, Availability
from models.infrastructure import Building, Classroom, Laboratory
from schemas.validation import ValidationReportResponse, ValidationResultResponse

class ValidationEngine:
    def __init__(self, db: Session):
        self.db = db
        self.report_id = str(uuid.uuid4())
        self.results = []
        self.academic_year_id = None
        
    def add_result(self, category: str, status: str, message: str, severity: str, entity_id: str = None, entity_name: str = None, suggestion: str = None):
        result = ValidationResult(
            id=str(uuid.uuid4()),
            reportId=self.report_id,
            category=category,
            entityId=entity_id,
            entityName=entity_name,
            status=status,
            message=message,
            suggestion=suggestion,
            severity=severity
        )
        self.results.append(result)
        
    def validate_institution(self):
        # Check active academic year
        academic_year = self.db.query(AcademicYear).filter(AcademicYear.status == "frozen").first()
        if not academic_year:
            self.add_result(
                category="Institution",
                status="error",
                message="No frozen academic year found",
                severity="critical",
                suggestion="Freeze an academic year before scheduling"
            )
            return False
            
        self.academic_year_id = academic_year.id
        
        # Check buildings
        buildings = self.db.query(Building).all()
        if not buildings:
            self.add_result(
                category="Institution",
                status="error",
                message="No buildings configured",
                severity="critical",
                suggestion="Add at least one building"
            )
            return False
            
        self.add_result(
            category="Institution",
            status="passed",
            message="Institution is ready for scheduling",
            severity="info"
        )
        return True

    def validate_departments(self):
        departments = self.db.query(Department).filter(Department.status == "active").all()
        if not departments:
            self.add_result(
                category="Department",
                status="error",
                message="No active departments found",
                severity="critical",
                suggestion="Create and activate departments"
            )
            return False
            
        all_passed = True
        for dept in departments:
            if dept.readinessStatus != "ready" and dept.readinessStatus != "frozen":
                self.add_result(
                    category="Department",
                    status="error",
                    message=f"Department {dept.name} is not ready",
                    severity="error",
                    entity_id=dept.id,
                    entity_name=dept.name,
                    suggestion="Ensure department configuration is complete"
                )
                all_passed = False
                
        if all_passed:
            self.add_result(
                category="Department",
                status="passed",
                message="All active departments are ready",
                severity="info"
            )
        return all_passed

    def validate_sections(self):
        sections = self.db.query(Section).filter(Section.status == "active").all()
        if not sections:
            self.add_result(
                category="Section",
                status="warning",
                message="No active sections found",
                severity="warning",
                suggestion="Create sections if scheduling is required"
            )
            return True
            
        all_passed = True
        for section in sections:
            if not section.homeClassroomId:
                self.add_result(
                    category="Section",
                    status="warning",
                    message=f"Section {section.name} has no home classroom assigned",
                    severity="warning",
                    entity_id=section.id,
                    entity_name=section.name,
                    suggestion="Assign a home classroom to the section"
                )
                all_passed = False
                
        if all_passed:
            self.add_result(
                category="Section",
                status="passed",
                message="All sections have home classrooms",
                severity="info"
            )
        return all_passed

    def validate_subjects(self):
        subjects = self.db.query(Subject).filter(Subject.status == "active").all()
        if not subjects:
            self.add_result(
                category="Subject",
                status="error",
                message="No active subjects found",
                severity="critical",
                suggestion="Create subjects for the curriculum"
            )
            return False
            
        all_passed = True
        for subject in subjects:
            if subject.weeklyHours <= 0:
                self.add_result(
                    category="Subject",
                    status="error",
                    message=f"Subject {subject.name} has invalid weekly hours",
                    severity="error",
                    entity_id=subject.id,
                    entity_name=subject.name,
                    suggestion="Set weekly hours greater than 0"
                )
                all_passed = False
                
        if all_passed:
            self.add_result(
                category="Subject",
                status="passed",
                message="All subjects are valid",
                severity="info"
            )
        return all_passed

    def validate_faculty(self):
        faculties = self.db.query(Faculty).filter(Faculty.status == "Active").all()
        if not faculties:
            self.add_result(
                category="Faculty",
                status="error",
                message="No active faculty found",
                severity="critical",
                suggestion="Add faculty members"
            )
            return False
            
        all_passed = True
        for faculty in faculties:
            profile = self.db.query(SchedulingProfile).filter(SchedulingProfile.facultyId == faculty.id).first()
            if not profile:
                self.add_result(
                    category="Faculty",
                    status="warning",
                    message=f"Faculty {faculty.name} has no scheduling profile",
                    severity="warning",
                    entity_id=faculty.id,
                    entity_name=faculty.name,
                    suggestion="Create a scheduling profile for the faculty"
                )
                all_passed = False
                
        if all_passed:
            self.add_result(
                category="Faculty",
                status="passed",
                message="Faculty scheduling profiles are configured",
                severity="info"
            )
        return all_passed

    def validate_laboratories(self):
        labs = self.db.query(Laboratory).filter(Laboratory.status == "active").all()
        if not labs:
            self.add_result(
                category="Laboratory",
                status="warning",
                message="No active laboratories found",
                severity="warning",
                suggestion="Add laboratories if practical sessions are required"
            )
            return True
            
        self.add_result(
            category="Laboratory",
            status="passed",
            message="Laboratories are configured",
            severity="info"
        )
        return True

    def run_validation(self) -> ValidationReport:
        # Run all validations
        inst_passed = self.validate_institution()
        dept_passed = self.validate_departments()
        sec_passed = self.validate_sections()
        sub_passed = self.validate_subjects()
        fac_passed = self.validate_faculty()
        lab_passed = self.validate_laboratories()
        
        # Calculate readiness scores
        total_checks = len(self.results)
        if total_checks == 0:
            overall_readiness = 0.0
        else:
            passed_checks = sum(1 for r in self.results if r.status == "passed")
            overall_readiness = (passed_checks / total_checks) * 100.0
            
        # Determine overall status
        critical_errors = any(r.severity == "critical" for r in self.results)
        errors = any(r.severity == "error" for r in self.results)
        
        if critical_errors or errors:
            status = "failed"
        elif any(r.severity == "warning" for r in self.results):
            status = "warnings"
        else:
            status = "passed"
            
        # Create report
        report = ValidationReport(
            id=self.report_id,
            academicYearId=self.academic_year_id or "unknown",
            institutionReadiness=100.0 if inst_passed else 0.0,
            departmentReadiness=100.0 if dept_passed else 0.0,
            sectionReadiness=100.0 if sec_passed else 0.0,
            sessionReadiness=0.0, # Will be updated by Session Builder
            overallReadiness=overall_readiness,
            status=status
        )
        
        # Save to DB
        self.db.add(report)
        for result in self.results:
            self.db.add(result)
            
        self.db.commit()
        self.db.refresh(report)
        
        return report
