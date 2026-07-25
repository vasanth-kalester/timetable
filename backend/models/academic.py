from sqlalchemy import Column, String, Integer, Boolean
from core.database import Base

class AcademicYear(Base):
    __tablename__ = "AcademicYear"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)
    startDate = Column("startDate", Integer) # Prisma stores DateTime as Integer in SQLite
    endDate = Column("endDate", Integer)
    status = Column(String, default="draft")
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)

class Program(Base):
    __tablename__ = "Program"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    code = Column(String, unique=True, nullable=False)
    degree = Column(String, nullable=False)
    durationYears = Column("durationYears", Integer, nullable=False)
    totalSemesters = Column("totalSemesters", Integer, nullable=False)
    intakeCapacity = Column("intakeCapacity", Integer, nullable=False)
    departmentId = Column("departmentId", String, nullable=False)
    status = Column(String, default="active")
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)

class Semester(Base):
    __tablename__ = "Semester"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    number = Column(Integer, nullable=False)
    programId = Column("programId", String, nullable=False)
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)

class Section(Base):
    __tablename__ = "Section"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    intake = Column(Integer, nullable=False)
    semesterId = Column("semesterId", String, nullable=False)
    homeClassroomId = Column("homeClassroomId", String)
    status = Column(String, default="active")
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)

class Subject(Base):
    __tablename__ = "Subject"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    code = Column(String, unique=True, nullable=False)
    credits = Column(Integer, nullable=False, default=3)
    weeklyHours = Column("weeklyHours", Integer, nullable=False, default=3)
    category = Column(String, nullable=False, default="core") # core, elective, open_elective
    subjectType = Column("subjectType", String, nullable=False, default="theory") # theory, lab, tutorial, project
    departmentId = Column("departmentId", String, nullable=False)
    status = Column(String, default="active")
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)
