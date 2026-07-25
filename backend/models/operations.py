from sqlalchemy import Column, String, Integer, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from core.database import Base
import time

class TimetableVersion(Base):
    __tablename__ = "TimetableVersion"

    id = Column(String, primary_key=True, index=True)
    timetableId = Column("timetableId", String, ForeignKey("Timetable.id", ondelete="CASCADE"), nullable=False)
    versionNumber = Column("versionNumber", Integer, nullable=False)
    publishedAt = Column("publishedAt", Integer, default=lambda: int(time.time() * 1000))
    publishedBy = Column("publishedBy", String, nullable=False)
    reason = Column(String, nullable=True)
    isActive = Column("isActive", Boolean, default=True)
    createdAt = Column("createdAt", Integer, default=lambda: int(time.time() * 1000))
    updatedAt = Column("updatedAt", Integer, default=lambda: int(time.time() * 1000))

    timetable = relationship("Timetable", back_populates="versions")
    changes = relationship("TimetableChange", back_populates="version", cascade="all, delete-orphan")

class TimetableChange(Base):
    __tablename__ = "TimetableChange"

    id = Column(String, primary_key=True, index=True)
    versionId = Column("versionId", String, ForeignKey("TimetableVersion.id", ondelete="CASCADE"), nullable=False)
    sessionId = Column("sessionId", String, ForeignKey("Session.id"), nullable=False)
    changedBy = Column("changedBy", String, nullable=False)
    changeType = Column("changeType", String, nullable=False)
    reason = Column(String, nullable=False)
    oldDay = Column("oldDay", Integer, nullable=True)
    oldPeriod = Column("oldPeriod", Integer, nullable=True)
    oldRoomId = Column("oldRoomId", String, nullable=True)
    oldFacultyId = Column("oldFacultyId", String, nullable=True)
    newDay = Column("newDay", Integer, nullable=True)
    newPeriod = Column("newPeriod", Integer, nullable=True)
    newRoomId = Column("newRoomId", String, nullable=True)
    newFacultyId = Column("newFacultyId", String, nullable=True)
    createdAt = Column("createdAt", Integer, default=lambda: int(time.time() * 1000))
    updatedAt = Column("updatedAt", Integer, default=lambda: int(time.time() * 1000))

    version = relationship("TimetableVersion", back_populates="changes")
    session = relationship("Session")

class SubstitutionRequest(Base):
    __tablename__ = "SubstitutionRequest"

    id = Column(String, primary_key=True, index=True)
    sessionId = Column("sessionId", String, ForeignKey("Session.id"), nullable=False)
    originalFacultyId = Column("originalFacultyId", String, nullable=False)
    substituteFacultyId = Column("substituteFacultyId", String, nullable=True)
    date = Column(Integer, nullable=False)
    status = Column(String, default="pending")
    reason = Column(String, nullable=False)
    createdAt = Column("createdAt", Integer, default=lambda: int(time.time() * 1000))
    updatedAt = Column("updatedAt", Integer, default=lambda: int(time.time() * 1000))

    session = relationship("Session")

class Event(Base):
    __tablename__ = "Event"

    id = Column(String, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=True)
    eventType = Column("eventType", String, nullable=False)
    date = Column(Integer, nullable=False)
    startPeriod = Column("startPeriod", Integer, nullable=False)
    endPeriod = Column("endPeriod", Integer, nullable=False)
    roomId = Column("roomId", String, nullable=True)
    departmentId = Column("departmentId", String, nullable=True)
    status = Column(String, default="scheduled")
    createdAt = Column("createdAt", Integer, default=lambda: int(time.time() * 1000))
    updatedAt = Column("updatedAt", Integer, default=lambda: int(time.time() * 1000))

class RoomMaintenance(Base):
    __tablename__ = "RoomMaintenance"

    id = Column(String, primary_key=True, index=True)
    roomId = Column("roomId", String, nullable=False)
    reason = Column(String, nullable=False)
    startDate = Column("startDate", Integer, nullable=False)
    endDate = Column("endDate", Integer, nullable=False)
    status = Column(String, default="active")
    createdAt = Column("createdAt", Integer, default=lambda: int(time.time() * 1000))
    updatedAt = Column("updatedAt", Integer, default=lambda: int(time.time() * 1000))

class Notification(Base):
    __tablename__ = "Notification"

    id = Column(String, primary_key=True, index=True)
    userId = Column("userId", String, nullable=False)
    title = Column(String, nullable=False)
    message = Column(String, nullable=False)
    type = Column(String, nullable=False)
    isRead = Column("isRead", Boolean, default=False)
    createdAt = Column("createdAt", Integer, default=lambda: int(time.time() * 1000))
    updatedAt = Column("updatedAt", Integer, default=lambda: int(time.time() * 1000))
