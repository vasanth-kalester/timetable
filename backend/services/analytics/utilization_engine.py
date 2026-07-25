from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any
from collections import defaultdict

from models.infrastructure import Classroom
from models.timetable import TimetableEntry, Timetable

class ResourceUtilizationEngine:
    def __init__(self, db: DBSession):
        self.db = db
        
    def calculate_room_utilization(self, timetable_id: str = None) -> List[Dict[str, Any]]:
        """
        Calculates utilization metrics for all classrooms and labs.
        """
        if not timetable_id:
            active_timetable = self.db.query(Timetable).filter(Timetable.status == "published").first()
            if not active_timetable:
                active_timetable = self.db.query(Timetable).filter(Timetable.status == "draft").first()
            if not active_timetable:
                return []
            timetable_id = active_timetable.id
            
        rooms = self.db.query(Classroom).all()
        entries = self.db.query(TimetableEntry).filter(TimetableEntry.timetableId == timetable_id).all()
        
        # Group entries by room
        room_usage = defaultdict(list)
        for entry in entries:
            if entry.roomId:
                room_usage[entry.roomId].append(entry)
                
        # Assuming a standard 5-day week, 8 periods a day = 40 periods total
        TOTAL_PERIODS = 40
        
        utilization_data = []
        for room in rooms:
            usage = room_usage.get(room.id, [])
            used_periods = len(usage)
            
            # Calculate peak day
            day_counts = defaultdict(int)
            for entry in usage:
                day_counts[entry.dayOfWeek] += 1
                
            peak_day = max(day_counts.items(), key=lambda x: x[1])[0] if day_counts else None
            
            utilization_data.append({
                "roomId": room.id,
                "roomName": room.name,
                "buildingId": room.buildingId,
                "capacity": room.capacity,
                "weeklyUtilization": (used_periods / TOTAL_PERIODS) * 100 if TOTAL_PERIODS > 0 else 0,
                "idleHours": TOTAL_PERIODS - used_periods,
                "peakUsageDay": peak_day,
                "totalUsedPeriods": used_periods
            })
            
        return utilization_data
