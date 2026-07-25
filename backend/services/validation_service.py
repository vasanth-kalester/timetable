from sqlalchemy.orm import Session
from models.academic import AcademicYear, Program, Semester, Section
from models.user import Department
from models.infrastructure import Classroom, Building
from fastapi import HTTPException

class ValidationService:
    @staticmethod
    def validate_academic_year_transition(db: Session, year_id: str, new_status: str):
        year = db.query(AcademicYear).filter(AcademicYear.id == year_id).first()
        if not year:
            raise HTTPException(status_code=404, detail="Academic Year not found")
        
        if year.status == "archived":
            raise HTTPException(status_code=400, detail="Cannot change status of an archived academic year")
            
        if new_status == "ready":
            # Check if all active departments are ready
            departments = db.query(Department).filter(Department.status == "active").all()
            for dept in departments:
                if dept.readinessStatus not in ["ready", "frozen"]:
                    raise HTTPException(
                        status_code=400, 
                        detail=f"Cannot mark Academic Year as ready. Department {dept.name} is not ready."
                    )
                    
        return True

    @staticmethod
    def validate_department_readiness(db: Session, dept_id: str):
        dept = db.query(Department).filter(Department.id == dept_id).first()
        if not dept:
            raise HTTPException(status_code=404, detail="Department not found")
            
        programs = db.query(Program).filter(Program.departmentId == dept_id, Program.status == "active").all()
        if not programs:
            return "draft"
            
        for prog in programs:
            semesters = db.query(Semester).filter(Semester.programId == prog.id).all()
            if not semesters:
                return "draft"
                
            for sem in semesters:
                sections = db.query(Section).filter(Section.semesterId == sem.id, Section.status == "active").all()
                if not sections:
                    return "draft"
                
                for sec in sections:
                    if not sec.homeClassroomId:
                        return "configured" # Programs, semesters, sections exist, but home classrooms missing
                        
        return "ready"

    @staticmethod
    def validate_section_capacity(db: Session, intake: int, room_id: str):
        if not room_id:
            return True
            
        room = db.query(Classroom).filter(Classroom.id == room_id).first()
        if not room:
            raise HTTPException(status_code=404, detail="Classroom not found")
            
        if intake > room.capacity:
            raise HTTPException(
                status_code=400, 
                detail=f"Classroom capacity ({room.capacity}) is smaller than section intake ({intake})"
            )
        return True

    @staticmethod
    def validate_home_classroom_uniqueness(db: Session, room_id: str, current_section_id: str = None):
        if not room_id:
            return True
            
        query = db.query(Section).filter(Section.homeClassroomId == room_id, Section.status == "active")
        if current_section_id:
            query = query.filter(Section.id != current_section_id)
            
        existing = query.first()
        if existing:
            raise HTTPException(
                status_code=400, 
                detail=f"Classroom is already assigned as Home Classroom to Section {existing.name}"
            )
        return True
