from pydantic import BaseModel
from typing import Optional

# Building
class BuildingBase(BaseModel):
    name: str
    code: str
    type: str = "academic"

class BuildingCreate(BuildingBase):
    pass

class BuildingUpdate(BaseModel):
    name: Optional[str] = None
    code: Optional[str] = None
    type: Optional[str] = None

class BuildingResponse(BuildingBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

# Classroom
class ClassroomBase(BaseModel):
    roomNumber: str
    capacity: int
    isSmart: bool = False
    hasProjector: bool = False
    hasAC: bool = False
    buildingId: str
    status: str = "active"

class ClassroomCreate(ClassroomBase):
    pass

class ClassroomUpdate(BaseModel):
    roomNumber: Optional[str] = None
    capacity: Optional[int] = None
    isSmart: Optional[bool] = None
    hasProjector: Optional[bool] = None
    hasAC: Optional[bool] = None
    status: Optional[str] = None

class ClassroomResponse(ClassroomBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

# Laboratory
class LaboratoryBase(BaseModel):
    name: str
    code: str
    capacity: int
    equipmentCount: int = 0
    labType: str
    buildingId: str
    departmentId: str
    status: str = "active"

class LaboratoryCreate(LaboratoryBase):
    pass

class LaboratoryUpdate(BaseModel):
    name: Optional[str] = None
    code: Optional[str] = None
    capacity: Optional[int] = None
    equipmentCount: Optional[int] = None
    labType: Optional[str] = None
    status: Optional[str] = None

class LaboratoryResponse(LaboratoryBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

# WorkingDay
class WorkingDayBase(BaseModel):
    dayOfWeek: str
    isEnabled: bool = True

class WorkingDayCreate(WorkingDayBase):
    pass

class WorkingDayUpdate(BaseModel):
    isEnabled: Optional[bool] = None

class WorkingDayResponse(WorkingDayBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

# PeriodConfiguration
class PeriodConfigurationBase(BaseModel):
    name: str
    startTime: str
    endTime: str
    isBreak: bool = False
    templateId: str

class PeriodConfigurationCreate(PeriodConfigurationBase):
    pass

class PeriodConfigurationUpdate(BaseModel):
    name: Optional[str] = None
    startTime: Optional[str] = None
    endTime: Optional[str] = None
    isBreak: Optional[bool] = None
    templateId: Optional[str] = None

class PeriodConfigurationResponse(PeriodConfigurationBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

# InstitutionPolicy
class InstitutionPolicyBase(BaseModel):
    key: str
    value: str
    description: Optional[str] = None

class InstitutionPolicyCreate(InstitutionPolicyBase):
    pass

class InstitutionPolicyUpdate(BaseModel):
    value: Optional[str] = None
    description: Optional[str] = None

class InstitutionPolicyResponse(InstitutionPolicyBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True
