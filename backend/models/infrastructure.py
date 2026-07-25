from sqlalchemy import Column, String, Integer, Boolean
from core.database import Base

class Building(Base):
    __tablename__ = "Building"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    code = Column(String, unique=True, nullable=False)
    type = Column(String, default="academic")
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)

class Classroom(Base):
    __tablename__ = "Classroom"

    id = Column(String, primary_key=True, index=True)
    roomNumber = Column("roomNumber", String, unique=True, nullable=False)
    capacity = Column(Integer, nullable=False)
    isSmart = Column("isSmart", Boolean, default=False)
    hasProjector = Column("hasProjector", Boolean, default=False)
    hasAC = Column("hasAC", Boolean, default=False)
    buildingId = Column("buildingId", String, nullable=False)
    status = Column(String, default="active")
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)

class Laboratory(Base):
    __tablename__ = "Laboratory"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    code = Column(String, unique=True, nullable=False)
    capacity = Column(Integer, nullable=False)
    equipmentCount = Column("equipmentCount", Integer, default=0)
    labType = Column("labType", String, nullable=False)
    buildingId = Column("buildingId", String, nullable=False)
    departmentId = Column("departmentId", String, nullable=False)
    status = Column(String, default="active")
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)

class WorkingDay(Base):
    __tablename__ = "WorkingDay"

    id = Column(String, primary_key=True, index=True)
    dayOfWeek = Column("dayOfWeek", String, unique=True, nullable=False)
    isEnabled = Column("isEnabled", Boolean, default=True)
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)

class PeriodTemplate(Base):
    __tablename__ = "PeriodTemplate"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)
    isActive = Column("isActive", Boolean, default=False)
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)

class PeriodConfiguration(Base):
    __tablename__ = "PeriodConfiguration"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    startTime = Column("startTime", String, nullable=False)
    endTime = Column("endTime", String, nullable=False)
    isBreak = Column("isBreak", Boolean, default=False)
    templateId = Column("templateId", String, nullable=False)
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)

class InstitutionPolicy(Base):
    __tablename__ = "InstitutionPolicy"

    id = Column(String, primary_key=True, index=True)
    key = Column(String, unique=True, nullable=False)
    value = Column(String, nullable=False)
    description = Column(String)
    createdAt = Column("createdAt", Integer)
    updatedAt = Column("updatedAt", Integer)
