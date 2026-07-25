from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any
from collections import defaultdict

from models.faculty import Faculty
from models.timetable import TimetableEntry, Timetable
from models.session import Session

class FacultyUtilizationEngine:
    def __init__(self, db: DBSession):
        self.db = db
        
    def calculate_faculty_utilization(self, timetable_id: str = None) -> List[Dict[str, Any]]:
        """
        Calculates utilization metrics for all faculty members.
        """
        if not timetable_id:
            active_timetable = self.db.query(Timetable).filter(Timetable.status == "published").first()
            if not active_timetable:
                active_timetable = self.db.query(Timetable).filter(Timetable.status == "draft").first()
            if not active_timetable:
                return []
            timetable_id = active_timetable.id
            
        faculties = self.db.query(Faculty).all()
        entries = self.db.query(TimetableEntry).filter(TimetableEntry.timetableId == timetable_id).all()
        
        # Group entries by faculty
        faculty_usage = defaultdict(list)
        for entry in entries:
            faculty_usage[entry.facultyId].append(entry)
            
        # Assuming a standard 5-day week, 8 periods a day = 40 periods total
        TOTAL_PERIODS = 40
        
        utilization_data = []
        for fac in faculties:
            usage = faculty_usage.get(fac.id, [])
            teaching_hours = len(usage)
            
            # Calculate idle gaps (free periods between classes on the same day)
            idle_gaps = 0
            day_periods = defaultdict(list)
            for entry in usage:
                day_periods[entry.dayOfWeek].append(entry.period)
                
            for day, periods in day_periods.items():
                periods.sort()
                for i in range(1, len(periods)):
                    gap = periods[i] - periods[i-1] - 1
                    if gap > 0:
                        idle_gaps += gap
                        
            # Calculate cross-department workload
            departments = set()
            for entry in usage:
                session = self.db.query(Session).filter(Session.id == entry.sessionId).first()
                if session and session.departmentId:
                    departments.add(session.departmentId)
                    
            utilization_data.append({
                "facultyId": fac.id,
                "name": f"{fac.firstName} {fac.lastName}",
                "departmentId": fac.departmentId,
                "teachingHours": teaching_hours,
                "freeHours": TOTAL_PERIODS - teaching_hours,
                "idleGaps": idle_gaps,
                "departmentsCount": len(departments)
            })
            
        return utilization_data
