from sqlalchemy import Column, String, Integer, Boolean, ForeignKey
from core.database import Base
import time

class Session(Base):
    __tablename__ = "Session"

    id = Column(String, primary_key=True, index=True)
    sessionCode = Column("sessionCode", String, nullable=False, unique=True)
    subjectId = Column("subjectId", String, nullable=False)
    facultyId = Column("facultyId", String, nullable=False)
    sectionId = Column("sectionId", String, nullable=False)
    programId = Column("programId", String, nullable=False)
    semesterId = Column("semesterId", String, nullable=False)
    departmentId = Column("departmentId", String, nullable=False)
    sessionType = Column("sessionType", String, nullable=False) # theory, lab, tutorial, seminar, project, workshop
    duration = Column(Integer, nullable=False, default=1)
    studentGroupId = Column("studentGroupId", String, nullable=True)
    laboratoryId = Column("laboratoryId", String, nullable=True)
    homeClassroomId = Column("homeClassroomId", String, nullable=True)
    weeklyOccurrence = Column("weeklyOccurrence", Integer, nullable=False, default=1)
    schedulingPriority = Column("schedulingPriority", Integer, nullable=False, default=0)
    status = Column(String, nullable=False, default="pending") # pending, validated, ready, scheduled, published, archived
    createdAt = Column("createdAt", Integer, default=lambda: int(time.time() * 1000))
    updatedAt = Column("updatedAt", Integer, default=lambda: int(time.time() * 1000))
