from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any, Optional
from pydantic import BaseModel

from core.database import get_db
from services.workflow.workflow_engine import WorkflowEngine
from services.workflow.approval_service import ApprovalService

router = APIRouter(
    prefix="/api/v1/workflow",
    tags=["Workflow"]
)

class EventTrigger(BaseModel):
    event_type: str
    context: Dict[str, Any]

class ApprovalAction(BaseModel):
    approver_id: str
    action: str
    comments: Optional[str] = None

@router.post("/trigger-event")
def trigger_event(trigger: EventTrigger, db: DBSession = Depends(get_db)):
    engine = WorkflowEngine(db)
    return engine.trigger_event(trigger.event_type, trigger.context)

@router.post("/approvals/{request_id}/process")
def process_approval(request_id: str, action: ApprovalAction, db: DBSession = Depends(get_db)):
    service = ApprovalService(db)
    return service.process_request(request_id, action.approver_id, action.action, action.comments)
