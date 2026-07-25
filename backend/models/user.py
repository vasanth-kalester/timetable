from sqlalchemy import Column, String, Integer
from core.database import Base


class User(Base):
    __tablename__ = "User"

    id = Column(String, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    passwordHash = Column("passwordHash", String, nullable=False)
    role = Column(String, default="student")
    approvalStatus = Column("approvalStatus", String, default="pending")
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)


class Profile(Base):
    __tablename__ = "Profile"

    id = Column(String, primary_key=True, index=True)
    userId = Column("userId", String, unique=True, index=True, nullable=False)
    firstName = Column("firstName", String)
    lastName = Column("lastName", String)
    avatarUrl = Column("avatarUrl", String)
    collegeId = Column("collegeId", String)
    departmentId = Column("departmentId", String)
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)


class College(Base):
    __tablename__ = "College"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    code = Column(String, unique=True, nullable=False)
    address = Column(String)
    logo = Column(String)
    timeZone = Column("timeZone", String, default="UTC")
    academicYear = Column("academicYear", String)
    workingDays = Column("workingDays", Integer, default=5)
    workingHours = Column("workingHours", Integer, default=8)
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)


class Department(Base):
    __tablename__ = "Department"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    code = Column(String, unique=True, nullable=False)
    collegeId = Column("collegeId", String)
    status = Column(String, default="active")
    readinessStatus = Column("readinessStatus", String, default="draft")
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)
