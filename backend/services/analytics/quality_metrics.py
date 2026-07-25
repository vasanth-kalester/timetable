from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any
from collections import defaultdict

from models.timetable import TimetableEntry, Timetable
from models.session import Session

class QualityMetricsEngine:
    def __init__(self, db: DBSession):
        self.db = db
        
    def calculate_quality_score(self, timetable_id: str = None) -> Dict[str, Any]:
        """
        Calculates overall timetable quality metrics.
        """
        if not timetable_id:
            active_timetable = self.db.query(Timetable).filter(Timetable.status == "published").first()
            if not active_timetable:
                active_timetable = self.db.query(Timetable).filter(Timetable.status == "draft").first()
            if not active_timetable:
                return {}
            timetable_id = active_timetable.id
            
        entries = self.db.query(TimetableEntry).filter(TimetableEntry.timetableId == timetable_id).all()
        
        # 1. Calculate average student idle time (gaps between classes for a section)
        section_usage = defaultdict(list)
        for entry in entries:
            section_usage[entry.sectionId].append(entry)
            
        total_student_idle_gaps = 0
        total_sections = len(section_usage)
        
        for section, usage in section_usage.items():
            day_periods = defaultdict(list)
            for entry in usage:
                day_periods[entry.dayOfWeek].append(entry.period)
                
            for day, periods in day_periods.items():
                periods.sort()
                for i in range(1, len(periods)):
                    gap = periods[i] - periods[i-1] - 1
                    if gap > 0:
                        total_student_idle_gaps += gap
                        
        avg_student_idle = total_student_idle_gaps / total_sections if total_sections > 0 else 0
        
        # 2. Calculate average faculty idle time
        faculty_usage = defaultdict(list)
        for entry in entries:
            faculty_usage[entry.facultyId].append(entry)
            
        total_faculty_idle_gaps = 0
        total_faculties = len(faculty_usage)
        
        for fac, usage in faculty_usage.items():
            day_periods = defaultdict(list)
            for entry in usage:
                day_periods[entry.dayOfWeek].append(entry.period)
                
            for day, periods in day_periods.items():
                periods.sort()
                for i in range(1, len(periods)):
                    gap = periods[i] - periods[i-1] - 1
                    if gap > 0:
                        total_faculty_idle_gaps += gap
                        
        avg_faculty_idle = total_faculty_idle_gaps / total_faculties if total_faculties > 0 else 0
        
        # 3. Calculate room occupancy rate
        room_usage = defaultdict(list)
        for entry in entries:
            if entry.roomId:
                room_usage[entry.roomId].append(entry)
                
        total_rooms = len(room_usage)
        TOTAL_PERIODS = 40
        total_used_periods = sum(len(usage) for usage in room_usage.values())
        
        avg_room_occupancy = (total_used_periods / (total_rooms * TOTAL_PERIODS)) * 100 if total_rooms > 0 else 0
        
        # Calculate overall score (higher is better, lower idle times are better)
        # Base score 100, deduct for high idle times, add for good occupancy
        score = 100 - (avg_student_idle * 5) - (avg_faculty_idle * 5)
        score = max(0, min(100, score))
        
        return {
            "timetableId": timetable_id,
            "overallScore": score,
            "avgStudentIdleTime": avg_student_idle,
            "avgFacultyIdleTime": avg_faculty_idle,
            "avgRoomOccupancy": avg_room_occupancy,
            "totalSections": total_sections,
            "totalFaculties": total_faculties,
            "totalRoomsUsed": total_rooms
        }
