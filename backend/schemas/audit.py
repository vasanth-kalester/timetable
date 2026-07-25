from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class AuditLogBase(BaseModel):
    userId: str
    role: str
    action: str
    entity: str
    entityId: str
    oldValue: Optional[str] = None
    newValue: Optional[str] = None
    reason: Optional[str] = None

class AuditLogCreate(AuditLogBase):
    pass

class AuditLogResponse(AuditLogBase):
    id: str
    timestamp: datetime

    class Config:
        from_attributes = True
