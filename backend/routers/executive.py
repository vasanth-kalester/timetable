from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any, Optional
from pydantic import BaseModel

from core.database import get_db
from services.executive.kpi_service import KPIService
from services.executive.benchmarking_service import BenchmarkingService
from services.executive.quality_analytics import QualityAnalytics
from services.executive.historical_service import HistoricalService
from services.executive.forecast_service import ForecastService
from services.executive.semester_replay import SemesterReplayEngine
from services.executive.accreditation_service import AccreditationService
from services.executive.report_builder import ReportBuilder
from services.executive.alert_engine import AlertEngine

router = APIRouter(
    prefix="/api/v1/executive",
    tags=["Executive Analytics"]
)

@router.get("/kpis")
def get_institutional_kpis(db: DBSession = Depends(get_db)):
    service = KPIService(db)
    return service.get_institutional_kpis()

@router.get("/benchmarks")
def get_department_benchmarks(db: DBSession = Depends(get_db)):
    service = BenchmarkingService(db)
    return service.get_department_benchmarks()

@router.get("/quality/{timetable_id}")
def get_timetable_quality(timetable_id: str, db: DBSession = Depends(get_db)):
    service = QualityAnalytics(db)
    return service.evaluate_timetable_quality(timetable_id)

@router.get("/historical/trends")
def get_historical_trends(metric: str, db: DBSession = Depends(get_db)):
    service = HistoricalService(db)
    return service.get_historical_trends(metric)

@router.get("/forecast")
def get_resource_forecast(target_year: str, growth_rate: float, db: DBSession = Depends(get_db)):
    service = ForecastService(db)
    return service.generate_resource_forecast(target_year, growth_rate)

@router.get("/replay")
def replay_semester(academic_year_id: str, semester: str, db: DBSession = Depends(get_db)):
    engine = SemesterReplayEngine(db)
    return engine.reconstruct_semester(academic_year_id, semester)

@router.get("/accreditation/{body_name}")
def get_accreditation_metrics(body_name: str, db: DBSession = Depends(get_db)):
    service = AccreditationService(db)
    return service.get_accreditation_metrics(body_name)

@router.post("/reports/custom")
def generate_custom_report(filters: Dict[str, Any], format: str = "pdf", db: DBSession = Depends(get_db)):
    builder = ReportBuilder(db)
    return builder.generate_custom_report(filters, format)

@router.get("/alerts")
def get_active_alerts(db: DBSession = Depends(get_db)):
    engine = AlertEngine(db)
    return engine.get_active_alerts()
