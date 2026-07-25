from sqlalchemy import Column, String, Integer, DateTime
from sqlalchemy.sql import func
from core.database import Base

class AuditLog(Base):
    __tablename__ = "AuditLog"

    id = Column(String, primary_key=True, index=True)
    userId = Column("userId", String, nullable=False)
    role = Column(String, nullable=False)
    action = Column(String, nullable=False)
    entity = Column(String, nullable=False)
    entityId = Column("entityId", String, nullable=False)
    oldValue = Column("oldValue", String)
    newValue = Column("newValue", String)
    reason = Column(String)
    timestamp = Column(DateTime, server_default=func.now())
