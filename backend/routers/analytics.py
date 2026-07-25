from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any, Optional

from core.database import get_db
from services.analytics.utilization_engine import ResourceUtilizationEngine
from services.analytics.faculty_analytics import FacultyUtilizationEngine
from services.analytics.quality_metrics import QualityMetricsEngine
from services.analytics.conflict_analyzer import InfrastructureConflictAnalyzer

router = APIRouter(
    prefix="/api/v1/analytics",
    tags=["Analytics"]
)

@router.get("/rooms/utilization")
def get_room_utilization(timetableId: Optional[str] = None, db: DBSession = Depends(get_db)):
    engine = ResourceUtilizationEngine(db)
    return engine.calculate_room_utilization(timetableId)

@router.get("/faculty/utilization")
def get_faculty_utilization(timetableId: Optional[str] = None, db: DBSession = Depends(get_db)):
    engine = FacultyUtilizationEngine(db)
    return engine.calculate_faculty_utilization(timetableId)

@router.get("/quality-score")
def get_quality_score(timetableId: Optional[str] = None, db: DBSession = Depends(get_db)):
    engine = QualityMetricsEngine(db)
    return engine.calculate_quality_score(timetableId)

@router.get("/infrastructure-conflicts")
def get_infrastructure_conflicts(timetableId: Optional[str] = None, db: DBSession = Depends(get_db)):
    engine = InfrastructureConflictAnalyzer(db)
    return engine.detect_infrastructure_issues(timetableId)
