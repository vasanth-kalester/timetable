from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any

from models.infrastructure import Classroom
from models.timetable import TimetableEntry, Timetable

class CapacitySimulator:
    def __init__(self, db: DBSession):
        self.db = db
        
    def simulate_capacity_change(self, new_sections: int, students_per_section: int, new_labs: int = 0) -> Dict[str, Any]:
        """
        Simulates the impact of adding new sections and students.
        """
        # Get current active timetable
        active_timetable = self.db.query(Timetable).filter(Timetable.status == "published").first()
        if not active_timetable:
            active_timetable = self.db.query(Timetable).filter(Timetable.status == "draft").first()
            
        if not active_timetable:
            return {"error": "No active timetable found for baseline."}
            
        # Get current room utilization
        rooms = self.db.query(Classroom).all()
        entries = self.db.query(TimetableEntry).filter(TimetableEntry.timetableId == active_timetable.id).all()
        
        TOTAL_PERIODS = 40
        total_capacity = sum(r.capacity for r in rooms)
        
        # Calculate current usage
        used_periods = len(entries)
        current_utilization = (used_periods / (len(rooms) * TOTAL_PERIODS)) * 100 if rooms else 0
        
        # Estimate new requirements
        # Assuming each new section needs roughly 30 periods of theory and 10 periods of lab per week
        estimated_new_theory_periods = new_sections * 30
        estimated_new_lab_periods = new_sections * 10
        
        total_new_periods = estimated_new_theory_periods + estimated_new_lab_periods
        
        # Calculate new utilization
        new_utilization = ((used_periods + total_new_periods) / (len(rooms) * TOTAL_PERIODS)) * 100 if rooms else 0
        
        # Check if we need more rooms
        additional_rooms_needed = 0
        if new_utilization > 85: # 85% is a safe upper bound
            # Calculate how many rooms we need to bring utilization back to 85%
            target_total_periods = (used_periods + total_new_periods) / 0.85
            target_rooms = target_total_periods / TOTAL_PERIODS
            additional_rooms_needed = max(0, int(target_rooms - len(rooms)) + 1)
            
        # Estimate faculty needed
        # Assuming a faculty member teaches 15 periods a week
        additional_faculty_needed = total_new_periods / 15
        
        return {
            "baseline": {
                "totalRooms": len(rooms),
                "currentUtilization": current_utilization,
            },
            "simulation": {
                "newSections": new_sections,
                "studentsPerSection": students_per_section,
                "estimatedNewPeriods": total_new_periods,
                "projectedUtilization": new_utilization,
                "additionalRoomsNeeded": additional_rooms_needed,
                "additionalFacultyNeeded": round(additional_faculty_needed, 1),
                "status": "Warning" if additional_rooms_needed > 0 else "Feasible"
            }
        }
