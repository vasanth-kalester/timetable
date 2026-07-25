from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any

from services.analytics.utilization_engine import ResourceUtilizationEngine
from services.analytics.faculty_analytics import FacultyUtilizationEngine

class ReportGeneratorService:
    def __init__(self, db: DBSession):
        self.db = db
        
    def generate_utilization_report(self) -> Dict[str, Any]:
        """
        Generates a comprehensive utilization report.
        In a real system, this might generate a PDF or Excel file.
        For now, we return structured data that the frontend can format.
        """
        resource_engine = ResourceUtilizationEngine(self.db)
        faculty_engine = FacultyUtilizationEngine(self.db)
        
        room_utilization = resource_engine.calculate_room_utilization()
        faculty_utilization = faculty_engine.calculate_faculty_utilization()
        
        # Aggregate data
        total_rooms = len(room_utilization)
        avg_room_utilization = sum(r['weeklyUtilization'] for r in room_utilization) / total_rooms if total_rooms > 0 else 0
        
        total_faculty = len(faculty_utilization)
        avg_teaching_hours = sum(f['teachingHours'] for f in faculty_utilization) / total_faculty if total_faculty > 0 else 0
        
        return {
            "reportType": "Comprehensive Utilization",
            "generatedAt": "2026-10-15T10:00:00Z",
            "summary": {
                "totalRooms": total_rooms,
                "averageRoomUtilization": round(avg_room_utilization, 2),
                "totalFaculty": total_faculty,
                "averageTeachingHours": round(avg_teaching_hours, 2)
            },
            "roomDetails": room_utilization,
            "facultyDetails": faculty_utilization
        }
