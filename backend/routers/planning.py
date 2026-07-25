from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any, Optional

from core.database import get_db
from services.planning.capacity_simulator import CapacitySimulator
from services.planning.demand_forecast import DemandForecaster

router = APIRouter(
    prefix="/api/v1/planning",
    tags=["Planning"]
)

@router.get("/simulate-capacity")
def simulate_capacity(newSections: int, studentsPerSection: int, newLabs: int = 0, db: DBSession = Depends(get_db)):
    simulator = CapacitySimulator(db)
    return simulator.simulate_capacity_change(newSections, studentsPerSection, newLabs)

@router.get("/forecast-demand")
def forecast_demand(growthRate: float = 0.1, db: DBSession = Depends(get_db)):
    forecaster = DemandForecaster(db)
    return forecaster.forecast_next_semester(growthRate)
