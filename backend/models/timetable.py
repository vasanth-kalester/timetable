from sqlalchemy import Column, String, Integer, Float, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from core.database import Base
import time

class Timetable(Base):
    __tablename__ = "Timetable"

    id = Column(String, primary_key=True, index=True)
    academicYearId = Column("academicYearId", String, ForeignKey("AcademicYear.id"), nullable=False)
    name = Column(String, nullable=False)
    status = Column(String, default="draft") # draft, approved, published, archived
    optimizationScore = Column("optimizationScore", Float, default=0.0)
    conflicts = Column(Integer, default=0)
    roomUtilization = Column("roomUtilization", Float, default=0.0)
    facultySatisfaction = Column("facultySatisfaction", Float, default=0.0)
    studentSatisfaction = Column("studentSatisfaction", Float, default=0.0)
    createdAt = Column("createdAt", Integer, default=lambda: int(time.time() * 1000))
    updatedAt = Column("updatedAt", Integer, default=lambda: int(time.time() * 1000))

    entries = relationship("TimetableEntry", back_populates="timetable", cascade="all, delete-orphan")

class TimetableEntry(Base):
    __tablename__ = "TimetableEntry"

    id = Column(String, primary_key=True, index=True)
    timetableId = Column("timetableId", String, ForeignKey("Timetable.id", ondelete="CASCADE"), nullable=False)
    sessionId = Column("sessionId", String, ForeignKey("Session.id", ondelete="CASCADE"), nullable=False)
    dayOfWeek = Column("dayOfWeek", Integer, nullable=False)
    period = Column(Integer, nullable=False)
    roomId = Column("roomId", String, nullable=True)
    facultyId = Column("facultyId", String, nullable=False)
    sectionId = Column("sectionId", String, nullable=False)
    isManualEdit = Column("isManualEdit", Boolean, default=False)
    createdAt = Column("createdAt", Integer, default=lambda: int(time.time() * 1000))
    updatedAt = Column("updatedAt", Integer, default=lambda: int(time.time() * 1000))

    timetable = relationship("Timetable", back_populates="entries")
