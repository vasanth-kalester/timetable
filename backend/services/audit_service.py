from sqlalchemy.orm import Session
import uuid
import json
from models.audit import AuditLog
from models.user import User

class AuditService:
    @staticmethod
    def log_action(
        db: Session, 
        user: User, 
        action: str, 
        entity: str, 
        entity_id: str, 
        old_value: dict = None, 
        new_value: dict = None, 
        reason: str = None
    ):
        log = AuditLog(
            id=str(uuid.uuid4()),
            userId=user.id,
            role=user.role,
            action=action,
            entity=entity,
            entityId=entity_id,
            oldValue=json.dumps(old_value) if old_value else None,
            newValue=json.dumps(new_value) if new_value else None,
            reason=reason
        )
        db.add(log)
        db.commit()
        return log
