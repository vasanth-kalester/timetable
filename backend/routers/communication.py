from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any, Optional
from pydantic import BaseModel

from core.database import get_db
from services.communication.notification_engine import NotificationEngine
from services.communication.announcement_service import AnnouncementService

router = APIRouter(
    prefix="/api/v1/communication",
    tags=["Communication"]
)

class AnnouncementCreate(BaseModel):
    title: str
    content: str
    author_id: str
    target_audience: str
    target_department_id: Optional[str] = None

@router.post("/announcements")
def publish_announcement(announcement: AnnouncementCreate, db: DBSession = Depends(get_db)):
    service = AnnouncementService(db)
    return service.publish_announcement(
        announcement.title,
        announcement.content,
        announcement.author_id,
        announcement.target_audience,
        announcement.target_department_id
    )

@router.get("/notifications/{user_id}")
def get_notifications(user_id: str, unread_only: bool = False, db: DBSession = Depends(get_db)):
    engine = NotificationEngine(db)
    return engine.get_user_notifications(user_id, unread_only)
