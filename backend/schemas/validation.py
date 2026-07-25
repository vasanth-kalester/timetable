from pydantic import BaseModel
from typing import Optional, List

class ValidationResultBase(BaseModel):
    category: str
    entityId: Optional[str] = None
    entityName: Optional[str] = None
    status: str
    message: str
    suggestion: Optional[str] = None
    severity: str

class ValidationResultResponse(ValidationResultBase):
    id: str
    reportId: str
    createdAt: Optional[int] = None

    class Config:
        from_attributes = True

class ValidationReportBase(BaseModel):
    academicYearId: str
    institutionReadiness: float = 0.0
    departmentReadiness: float = 0.0
    sectionReadiness: float = 0.0
    sessionReadiness: float = 0.0
    overallReadiness: float = 0.0
    status: str = "failed"

class ValidationReportResponse(ValidationReportBase):
    id: str
    createdAt: Optional[int] = None
    results: List[ValidationResultResponse] = []

    class Config:
        from_attributes = True
