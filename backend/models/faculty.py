from sqlalchemy import Column, String, Integer, Boolean, ForeignKey
from core.database import Base

class Faculty(Base):
    __tablename__ = "Faculty"

    id = Column(String, primary_key=True, index=True)
    employeeId = Column("employeeId", String, unique=True, index=True, nullable=False)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    phone = Column(String)
    departmentId = Column("departmentId", String, ForeignKey("Department.id"), nullable=False)
    designation = Column(String)
    qualification = Column(String)
    experience = Column(Integer)  # in years
    joiningDate = Column("joiningDate", Integer)
    employmentType = Column("employmentType", String, default="Full Time")
    status = Column(String, default="Active")
    schedulingReadiness = Column("schedulingReadiness", String, default="Draft")
    skills = Column(String)
    profilePicture = Column("profilePicture", String)
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)

class CrossDepartmentTeaching(Base):
    __tablename__ = "CrossDepartmentTeaching"

    id = Column(String, primary_key=True, index=True)
    facultyId = Column("facultyId", String, ForeignKey("Faculty.id"), nullable=False)
    departmentId = Column("departmentId", String, ForeignKey("Department.id"), nullable=False)
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)

class SchedulingProfile(Base):
    __tablename__ = "SchedulingProfile"

    id = Column(String, primary_key=True, index=True)
    facultyId = Column("facultyId", String, ForeignKey("Faculty.id"), unique=True, nullable=False)
    maxPeriodsPerDay = Column("maxPeriodsPerDay", Integer, default=4)
    maxPeriodsPerWeek = Column("maxPeriodsPerWeek", Integer, default=18)
    maxConsecutiveClasses = Column("maxConsecutiveClasses", Integer, default=2)
    preferredFreeDay = Column("preferredFreeDay", String)
    avoidFirstHour = Column("avoidFirstHour", Boolean, default=False)
    avoidLastHour = Column("avoidLastHour", Boolean, default=False)
    canHandleTheory = Column("canHandleTheory", Boolean, default=True)
    canHandleLabs = Column("canHandleLabs", Boolean, default=True)
    canHandleTutorials = Column("canHandleTutorials", Boolean, default=True)
    preferredBuildings = Column("preferredBuildings", String)
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)

class Availability(Base):
    __tablename__ = "Availability"

    id = Column(String, primary_key=True, index=True)
    facultyId = Column("facultyId", String, ForeignKey("Faculty.id"), nullable=False)
    dayOfWeek = Column("dayOfWeek", Integer, nullable=False)  # 1-7 for Monday-Sunday
    period = Column(Integer, nullable=False)
    isAvailable = Column("isAvailable", Boolean, default=True)
    reason = Column(String)
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)

class Leave(Base):
    __tablename__ = "Leave"

    id = Column(String, primary_key=True, index=True)
    facultyId = Column("facultyId", String, ForeignKey("Faculty.id"), nullable=False)
    leaveType = Column("leaveType", String, nullable=False)
    startDate = Column("startDate", Integer, nullable=False)
    endDate = Column("endDate", Integer, nullable=False)
    status = Column(String, default="Pending")
    reason = Column(String)
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)
