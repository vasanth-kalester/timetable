from pydantic import BaseModel
from typing import Optional, List

class CandidateSlotBase(BaseModel):
    sessionId: str
    dayOfWeek: int
    period: int
    roomId: Optional[str] = None
    facultyId: str
    sectionId: str
    penaltyScore: int = 0
    satisfiedConstraints: Optional[str] = None
    violatedConstraints: Optional[str] = None
    priority: int = 0
    status: str = "valid"

class CandidateSlotCreate(CandidateSlotBase):
    pass

class CandidateSlotResponse(CandidateSlotBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True
