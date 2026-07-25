from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from core.database import get_db
from core.dependencies import require_role
from models.audit import AuditLog
from schemas.audit import AuditLogResponse

router = APIRouter(prefix="/audit", tags=["Audit Logs"])

@router.get("/", response_model=List[AuditLogResponse])
def get_audit_logs(
    entity: str = None, 
    entityId: str = None, 
    limit: int = 50, 
    db: Session = Depends(get_db), 
    _ = Depends(require_role("principal", "admin"))
):
    query = db.query(AuditLog)
    if entity:
        query = query.filter(AuditLog.entity == entity)
    if entityId:
        query = query.filter(AuditLog.entityId == entityId)
        
    return query.order_by(AuditLog.timestamp.desc()).limit(limit).all()
