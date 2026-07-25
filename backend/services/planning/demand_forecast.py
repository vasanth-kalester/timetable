from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any

from models.infrastructure import Classroom
from models.timetable import TimetableEntry, Timetable

class DemandForecaster:
    def __init__(self, db: DBSession):
        self.db = db
        
    def forecast_next_semester(self, projected_growth_rate: float = 0.1) -> Dict[str, Any]:
        """
        Forecasts resource demand for the next semester based on a projected growth rate.
        """
        # Get current active timetable
        active_timetable = self.db.query(Timetable).filter(Timetable.status == "published").first()
        if not active_timetable:
            active_timetable = self.db.query(Timetable).filter(Timetable.status == "draft").first()
            
        if not active_timetable:
            return {"error": "No active timetable found for baseline."}
            
        rooms = self.db.query(Classroom).all()
        entries = self.db.query(TimetableEntry).filter(TimetableEntry.timetableId == active_timetable.id).all()
        
        TOTAL_PERIODS = 40
        current_used_periods = len(entries)
        
        # Forecast new periods
        forecasted_periods = int(current_used_periods * (1 + projected_growth_rate))
        
        # Check capacity
        total_available_periods = len(rooms) * TOTAL_PERIODS
        projected_utilization = (forecasted_periods / total_available_periods) * 100 if total_available_periods > 0 else 0
        
        shortfall_periods = max(0, forecasted_periods - (total_available_periods * 0.85)) # Assuming 85% is max safe utilization
        rooms_shortfall = max(0, int(shortfall_periods / TOTAL_PERIODS) + 1) if shortfall_periods > 0 else 0
        
        return {
            "projectedGrowthRate": projected_growth_rate,
            "forecastedPeriods": forecasted_periods,
            "projectedUtilization": projected_utilization,
            "roomsShortfall": rooms_shortfall,
            "recommendation": f"Need {rooms_shortfall} more rooms to maintain safe utilization levels." if rooms_shortfall > 0 else "Current infrastructure is sufficient."
        }
