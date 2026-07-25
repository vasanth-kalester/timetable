from pydantic import BaseModel, EmailStr, Field
from typing import List, Optional
from datetime import datetime

# --- Faculty Schemas ---
class FacultyBase(BaseModel):
    employeeId: str
    name: str
    email: EmailStr
    phone: Optional[str] = None
    departmentId: str
    designation: Optional[str] = None
    qualification: Optional[str] = None
    experience: Optional[int] = None
    joiningDate: Optional[int] = None
    employmentType: str = "Full Time"
    status: str = "Active"
    schedulingReadiness: str = "Draft"
    skills: Optional[str] = None
    profilePicture: Optional[str] = None

class FacultyCreate(FacultyBase):
    pass

class FacultyUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    departmentId: Optional[str] = None
    designation: Optional[str] = None
    qualification: Optional[str] = None
    experience: Optional[int] = None
    employmentType: Optional[str] = None
    status: Optional[str] = None
    schedulingReadiness: Optional[str] = None
    skills: Optional[str] = None
    profilePicture: Optional[str] = None

class FacultyResponse(FacultyBase):
    id: str
    createdAt: int
    updatedAt: int

    class Config:
        from_attributes = True

# --- Scheduling Profile Schemas ---
class SchedulingProfileBase(BaseModel):
    maxPeriodsPerDay: int = 4
    maxPeriodsPerWeek: int = 18
    maxConsecutiveClasses: int = 2
    preferredFreeDay: Optional[str] = None
    avoidFirstHour: bool = False
    avoidLastHour: bool = False
    canHandleTheory: bool = True
    canHandleLabs: bool = True
    canHandleTutorials: bool = True
    preferredBuildings: Optional[str] = None

class SchedulingProfileCreate(SchedulingProfileBase):
    facultyId: str

class SchedulingProfileUpdate(SchedulingProfileBase):
    pass

class SchedulingProfileResponse(SchedulingProfileBase):
    id: str
    facultyId: str
    createdAt: int
    updatedAt: int

    class Config:
        from_attributes = True

# --- Availability Schemas ---
class AvailabilityBase(BaseModel):
    dayOfWeek: int
    period: int
    isAvailable: bool = True
    reason: Optional[str] = None

class AvailabilityCreate(AvailabilityBase):
    facultyId: str

class AvailabilityUpdate(BaseModel):
    isAvailable: Optional[bool] = None
    reason: Optional[str] = None

class AvailabilityResponse(AvailabilityBase):
    id: str
    facultyId: str
    createdAt: int
    updatedAt: int

    class Config:
        from_attributes = True

# --- Leave Schemas ---
class LeaveBase(BaseModel):
    leaveType: str
    startDate: int
    endDate: int
    reason: Optional[str] = None

class LeaveCreate(LeaveBase):
    facultyId: str

class LeaveUpdate(BaseModel):
    status: Optional[str] = None
    reason: Optional[str] = None

class LeaveResponse(LeaveBase):
    id: str
    facultyId: str
    status: str
    createdAt: int
    updatedAt: int

    class Config:
        from_attributes = True
