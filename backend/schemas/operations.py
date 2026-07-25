from pydantic import BaseModel
from typing import Optional, List

class TimetableVersionBase(BaseModel):
    timetableId: str
    versionNumber: int
    publishedBy: str
    reason: Optional[str] = None
    isActive: bool = True

class TimetableVersionCreate(TimetableVersionBase):
    pass

class TimetableVersionResponse(TimetableVersionBase):
    id: str
    publishedAt: Optional[int] = None
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

class TimetableChangeBase(BaseModel):
    versionId: str
    sessionId: str
    changedBy: str
    changeType: str
    reason: str
    oldDay: Optional[int] = None
    oldPeriod: Optional[int] = None
    oldRoomId: Optional[str] = None
    oldFacultyId: Optional[str] = None
    newDay: Optional[int] = None
    newPeriod: Optional[int] = None
    newRoomId: Optional[str] = None
    newFacultyId: Optional[str] = None

class TimetableChangeCreate(TimetableChangeBase):
    pass

class TimetableChangeResponse(TimetableChangeBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

class SubstitutionRequestBase(BaseModel):
    sessionId: str
    originalFacultyId: str
    substituteFacultyId: Optional[str] = None
    date: int
    status: str = "pending"
    reason: str

class SubstitutionRequestCreate(SubstitutionRequestBase):
    pass

class SubstitutionRequestResponse(SubstitutionRequestBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

class EventBase(BaseModel):
    title: str
    description: Optional[str] = None
    eventType: str
    date: int
    startPeriod: int
    endPeriod: int
    roomId: Optional[str] = None
    departmentId: Optional[str] = None
    status: str = "scheduled"

class EventCreate(EventBase):
    pass

class EventResponse(EventBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

class RoomMaintenanceBase(BaseModel):
    roomId: str
    reason: str
    startDate: int
    endDate: int
    status: str = "active"

class RoomMaintenanceCreate(RoomMaintenanceBase):
    pass

class RoomMaintenanceResponse(RoomMaintenanceBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

class NotificationBase(BaseModel):
    userId: str
    title: str
    message: str
    type: str
    isRead: bool = False

class NotificationCreate(NotificationBase):
    pass

class NotificationResponse(NotificationBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True
