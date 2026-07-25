from sqlalchemy import Column, String, Integer, ForeignKey
from core.database import Base
import time

class CandidateSlot(Base):
    __tablename__ = "CandidateSlot"

    id = Column(String, primary_key=True, index=True)
    sessionId = Column("sessionId", String, ForeignKey("Session.id", ondelete="CASCADE"), nullable=False)
    dayOfWeek = Column("dayOfWeek", Integer, nullable=False)
    period = Column(Integer, nullable=False)
    roomId = Column("roomId", String, nullable=True)
    facultyId = Column("facultyId", String, nullable=False)
    sectionId = Column("sectionId", String, nullable=False)
    penaltyScore = Column("penaltyScore", Integer, default=0)
    satisfiedConstraints = Column("satisfiedConstraints", String, nullable=True) # JSON string
    violatedConstraints = Column("violatedConstraints", String, nullable=True) # JSON string
    priority = Column(Integer, default=0)
    status = Column(String, default="valid") # valid, invalid, selected
    createdAt = Column("createdAt", Integer, default=lambda: int(time.time() * 1000))
    updatedAt = Column("updatedAt", Integer, default=lambda: int(time.time() * 1000))
