from sqlalchemy import Column, String, Integer, Boolean
from core.database import Base
import time

class ConstraintConfiguration(Base):
    __tablename__ = "ConstraintConfiguration"

    id = Column(String, primary_key=True, index=True)
    code = Column(String, unique=True, nullable=False)
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)
    type = Column(String, default="hard") # hard, soft
    isActive = Column("isActive", Boolean, default=True)
    weight = Column(Integer, default=1) # For soft constraints penalty
    parameters = Column(String, nullable=True) # JSON string for configurable parameters
    createdAt = Column("createdAt", Integer, default=lambda: int(time.time() * 1000))
    updatedAt = Column("updatedAt", Integer, default=lambda: int(time.time() * 1000))
