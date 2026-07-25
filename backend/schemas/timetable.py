from pydantic import BaseModel
from typing import Optional, List

class TimetableEntryBase(BaseModel):
    sessionId: str
    dayOfWeek: int
    period: int
    roomId: Optional[str] = None
    facultyId: str
    sectionId: str
    isManualEdit: bool = False

class TimetableEntryCreate(TimetableEntryBase):
    timetableId: str

class TimetableEntryResponse(TimetableEntryBase):
    id: str
    timetableId: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

class TimetableBase(BaseModel):
    academicYearId: str
    name: str
    status: str = "draft"
    optimizationScore: float = 0.0
    conflicts: int = 0
    roomUtilization: float = 0.0
    facultySatisfaction: float = 0.0
    studentSatisfaction: float = 0.0

class TimetableCreate(TimetableBase):
    pass

class TimetableUpdate(BaseModel):
    name: Optional[str] = None
    status: Optional[str] = None
    optimizationScore: Optional[float] = None
    conflicts: Optional[int] = None
    roomUtilization: Optional[float] = None
    facultySatisfaction: Optional[float] = None
    studentSatisfaction: Optional[float] = None

class TimetableResponse(TimetableBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None
    entries: Optional[List[TimetableEntryResponse]] = []

    class Config:
        from_attributes = True
