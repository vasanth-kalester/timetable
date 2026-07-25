from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any, Optional
from pydantic import BaseModel

from core.database import get_db
from services.academic.calendar_service import CalendarService
from services.academic.task_manager import TaskManager

router = APIRouter(
    prefix="/api/v1/calendar",
    tags=["Calendar"]
)

class TaskCreate(BaseModel):
    title: str
    description: str
    assignee_id: str
    due_date: str
    priority: str = "medium"

@router.get("/unified")
def get_unified_calendar(user_id: str, role: str, start_date: str, end_date: str, db: DBSession = Depends(get_db)):
    service = CalendarService(db)
    return service.get_unified_calendar(user_id, role, start_date, end_date)

@router.post("/tasks")
def create_task(task: TaskCreate, db: DBSession = Depends(get_db)):
    manager = TaskManager(db)
    return manager.create_task(
        task.title,
        task.description,
        task.assignee_id,
        task.due_date,
        task.priority
    )

@router.get("/tasks/{user_id}")
def get_tasks(user_id: str, status: Optional[str] = None, db: DBSession = Depends(get_db)):
    manager = TaskManager(db)
    return manager.get_user_tasks(user_id, status)
