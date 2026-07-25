from sqlalchemy.orm import Session as DBSession
from typing import List
import uuid

from models.session import Session
from models.academic import Subject
from models.faculty import CrossDepartmentTeaching
from schemas.session import TeachingAssignment

class SessionBuilder:
    def __init__(self, db: DBSession):
        self.db = db
        
    def _calculate_priority(self, session_type: str, faculty_id: str, department_id: str, hours: int) -> int:
        """
        Calculate scheduling priority based on rules:
        1. Laboratory Sessions (Highest)
        2. Shared Faculty Sessions
        3. High Hour Theory Subjects
        4. Tutorials
        5. Electives (Lowest)
        """
        priority = 0
        
        if session_type == "lab":
            priority += 100
            
        # Check if faculty is shared
        is_shared = self.db.query(CrossDepartmentTeaching).filter(
            CrossDepartmentTeaching.facultyId == faculty_id,
            CrossDepartmentTeaching.departmentId != department_id
        ).first()
        
        if is_shared:
            priority += 80
            
        if session_type == "theory" and hours >= 4:
            priority += 60
            
        if session_type == "tutorial":
            priority += 40
            
        # Electives would be checked here if we had the subject category
        # For now, we'll just use the base priority
        
        return priority

    def build_sessions(self, assignment: TeachingAssignment) -> List[Session]:
        sessions = []
        
        subject = self.db.query(Subject).filter(Subject.id == assignment.subjectId).first()
        subject_code = subject.code if subject else "SUB"
        
        # Build Theory Sessions
        for i in range(assignment.theoryHours):
            session = Session(
                id=str(uuid.uuid4()),
                sessionCode=f"{subject_code}-T{i+1}",
                subjectId=assignment.subjectId,
                facultyId=assignment.facultyId,
                sectionId=assignment.sectionId,
                programId=assignment.programId,
                semesterId=assignment.semesterId,
                departmentId=assignment.departmentId,
                sessionType="theory",
                duration=1,
                studentGroupId=assignment.studentGroupId,
                homeClassroomId=assignment.homeClassroomId,
                weeklyOccurrence=1,
                schedulingPriority=self._calculate_priority("theory", assignment.facultyId, assignment.departmentId, assignment.theoryHours),
                status="ready"
            )
            sessions.append(session)
            
        # Build Lab Sessions
        # Business Rule: Labs requiring 6 hours/week become 2 sessions of 3 hours
        # We'll assume a standard lab session is 2 or 3 hours based on total hours
        lab_duration = 3 if assignment.labHours >= 3 else 2
        num_lab_sessions = assignment.labHours // lab_duration
        remaining_lab_hours = assignment.labHours % lab_duration
        
        for i in range(num_lab_sessions):
            session = Session(
                id=str(uuid.uuid4()),
                sessionCode=f"{subject_code}-L{i+1}",
                subjectId=assignment.subjectId,
                facultyId=assignment.facultyId,
                sectionId=assignment.sectionId,
                programId=assignment.programId,
                semesterId=assignment.semesterId,
                departmentId=assignment.departmentId,
                sessionType="lab",
                duration=lab_duration,
                studentGroupId=assignment.studentGroupId,
                laboratoryId=assignment.laboratoryId,
                weeklyOccurrence=1,
                schedulingPriority=self._calculate_priority("lab", assignment.facultyId, assignment.departmentId, assignment.labHours),
                status="ready"
            )
            sessions.append(session)
            
        if remaining_lab_hours > 0:
            session = Session(
                id=str(uuid.uuid4()),
                sessionCode=f"{subject_code}-L{num_lab_sessions+1}",
                subjectId=assignment.subjectId,
                facultyId=assignment.facultyId,
                sectionId=assignment.sectionId,
                programId=assignment.programId,
                semesterId=assignment.semesterId,
                departmentId=assignment.departmentId,
                sessionType="lab",
                duration=remaining_lab_hours,
                studentGroupId=assignment.studentGroupId,
                laboratoryId=assignment.laboratoryId,
                weeklyOccurrence=1,
                schedulingPriority=self._calculate_priority("lab", assignment.facultyId, assignment.departmentId, assignment.labHours),
                status="ready"
            )
            sessions.append(session)
            
        # Build Tutorial Sessions
        for i in range(assignment.tutorialHours):
            session = Session(
                id=str(uuid.uuid4()),
                sessionCode=f"{subject_code}-TUT{i+1}",
                subjectId=assignment.subjectId,
                facultyId=assignment.facultyId,
                sectionId=assignment.sectionId,
                programId=assignment.programId,
                semesterId=assignment.semesterId,
                departmentId=assignment.departmentId,
                sessionType="tutorial",
                duration=1,
                studentGroupId=assignment.studentGroupId,
                homeClassroomId=assignment.homeClassroomId,
                weeklyOccurrence=1,
                schedulingPriority=self._calculate_priority("tutorial", assignment.facultyId, assignment.departmentId, assignment.tutorialHours),
                status="ready"
            )
            sessions.append(session)
            
        # Save to DB
        for session in sessions:
            self.db.add(session)
            
        self.db.commit()
        
        return sessions
