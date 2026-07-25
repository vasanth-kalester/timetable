from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any, Optional

from core.database import get_db
from services.digital_twin.campus_map_service import CampusMapService
from services.reports.report_service import ReportGeneratorService

router = APIRouter(
    prefix="/api/v1/digital-twin",
    tags=["Digital Twin"]
)

@router.get("/campus-map")
def get_campus_map(dayOfWeek: int, period: int, db: DBSession = Depends(get_db)):
    service = CampusMapService(db)
    return service.get_realtime_status(dayOfWeek, period)

@router.get("/reports/utilization")
def generate_utilization_report(db: DBSession = Depends(get_db)):
    service = ReportGeneratorService(db)
    return service.generate_utilization_report()
