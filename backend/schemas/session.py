from pydantic import BaseModel
from typing import Optional, List

class TeachingAssignment(BaseModel):
    subjectId: str
    facultyId: str
    sectionId: str
    programId: str
    semesterId: str
    departmentId: str
    theoryHours: int = 0
    labHours: int = 0
    tutorialHours: int = 0
    studentGroupId: Optional[str] = None
    laboratoryId: Optional[str] = None
    homeClassroomId: Optional[str] = None
class SessionBase(BaseModel):
    sessionCode: str
    subjectId: str
    facultyId: str
    sectionId: str
    programId: str
    semesterId: str
    departmentId: str
    sessionType: str
    duration: int = 1
    studentGroupId: Optional[str] = None
    laboratoryId: Optional[str] = None
    homeClassroomId: Optional[str] = None
    weeklyOccurrence: int = 1
    schedulingPriority: int = 0
    status: str = "pending"

class SessionCreate(SessionBase):
    pass

class SessionUpdate(BaseModel):
    sessionCode: Optional[str] = None
    subjectId: Optional[str] = None
    facultyId: Optional[str] = None
    sectionId: Optional[str] = None
    programId: Optional[str] = None
    semesterId: Optional[str] = None
    departmentId: Optional[str] = None
    sessionType: Optional[str] = None
    duration: Optional[int] = None
    studentGroupId: Optional[str] = None
    laboratoryId: Optional[str] = None
    homeClassroomId: Optional[str] = None
    weeklyOccurrence: Optional[int] = None
    schedulingPriority: Optional[int] = None
    status: Optional[str] = None

class SessionResponse(SessionBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True
