from pydantic import BaseModel
from typing import Optional, List

# Academic Year
class AcademicYearBase(BaseModel):
    name: str
    startDate: int
    endDate: int
    status: str = "draft"

class AcademicYearCreate(AcademicYearBase):
    pass

class AcademicYearUpdate(BaseModel):
    name: Optional[str] = None
    startDate: Optional[int] = None
    endDate: Optional[int] = None
    status: Optional[str] = None

class AcademicYearResponse(AcademicYearBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

# Department
class DepartmentBase(BaseModel):
    name: str
    code: str
    collegeId: Optional[str] = None
    status: str = "active"
    readinessStatus: str = "draft"

class DepartmentCreate(DepartmentBase):
    pass

class DepartmentUpdate(BaseModel):
    name: Optional[str] = None
    code: Optional[str] = None
    status: Optional[str] = None
    readinessStatus: Optional[str] = None

class DepartmentResponse(DepartmentBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

# Program
class ProgramBase(BaseModel):
    name: str
    code: str
    degree: str
    durationYears: int
    totalSemesters: int
    intakeCapacity: int
    departmentId: str
    status: str = "active"

class ProgramCreate(ProgramBase):
    pass

class ProgramUpdate(BaseModel):
    name: Optional[str] = None
    code: Optional[str] = None
    degree: Optional[str] = None
    durationYears: Optional[int] = None
    totalSemesters: Optional[int] = None
    intakeCapacity: Optional[int] = None
    status: Optional[str] = None

class ProgramResponse(ProgramBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

# Semester
class SemesterBase(BaseModel):
    name: str
    number: int
    programId: str

class SemesterCreate(SemesterBase):
    pass

class SemesterUpdate(BaseModel):
    name: Optional[str] = None
    number: Optional[int] = None

class SemesterResponse(SemesterBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

# Section
class SectionBase(BaseModel):
    name: str
    intake: int
    semesterId: str
    homeClassroomId: Optional[str] = None
    status: str = "active"

class SectionCreate(SectionBase):
    pass

class SectionUpdate(BaseModel):
    name: Optional[str] = None
    intake: Optional[int] = None
    homeClassroomId: Optional[str] = None
    status: Optional[str] = None

class SectionResponse(SectionBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True

# Subject
class SubjectBase(BaseModel):
    name: str
    code: str
    classId: str
    staffId: Optional[str] = None

class SubjectCreate(SubjectBase):
    pass

class SubjectUpdate(BaseModel):
    name: Optional[str] = None
    code: Optional[str] = None
    staffId: Optional[str] = None

class SubjectResponse(SubjectBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True
