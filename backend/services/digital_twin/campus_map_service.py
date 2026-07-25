from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any
from datetime import datetime

from models.infrastructure import Classroom, Building
from models.timetable import TimetableEntry, Timetable
from models.session import Session
from models.faculty import Faculty

class CampusMapService:
    def __init__(self, db: DBSession):
        self.db = db
        
    def get_realtime_status(self, day_of_week: int, period: int) -> Dict[str, Any]:
        """
        Aggregates real-time data for the interactive campus map.
        """
        # Get active timetable
        active_timetable = self.db.query(Timetable).filter(Timetable.status == "published").first()
        if not active_timetable:
            active_timetable = self.db.query(Timetable).filter(Timetable.status == "draft").first()
            
        if not active_timetable:
            return {"buildings": []}
            
        buildings = self.db.query(Building).all()
        rooms = self.db.query(Classroom).all()
        
        # Get all entries for the current day
        day_entries = self.db.query(TimetableEntry).filter(
            TimetableEntry.timetableId == active_timetable.id,
            TimetableEntry.dayOfWeek == day_of_week
        ).all()
        
        # Build a map of room_id -> list of entries
        room_schedule = {}
        for entry in day_entries:
            if entry.roomId:
                if entry.roomId not in room_schedule:
                    room_schedule[entry.roomId] = []
                room_schedule[entry.roomId].append(entry)
                
        campus_data = []
        
        for building in buildings:
            building_rooms = [r for r in rooms if r.buildingId == building.id]
            
            # Group rooms by floor
            floors = {}
            for room in building_rooms:
                floor = room.floor
                if floor not in floors:
                    floors[floor] = []
                    
                # Find current and next class
                schedule = room_schedule.get(room.id, [])
                schedule.sort(key=lambda x: x.period)
                
                current_class = None
                next_class = None
                
                for entry in schedule:
                    if entry.period == period:
                        session = self.db.query(Session).filter(Session.id == entry.sessionId).first()
                        faculty = self.db.query(Faculty).filter(Faculty.id == entry.facultyId).first()
                        current_class = {
                            "sessionCode": session.code if session else "Unknown",
                            "facultyName": f"{faculty.firstName} {faculty.lastName}" if faculty else "Unknown",
                            "sectionId": entry.sectionId
                        }
                    elif entry.period > period and next_class is None:
                        session = self.db.query(Session).filter(Session.id == entry.sessionId).first()
                        next_class = {
                            "sessionCode": session.code if session else "Unknown",
                            "period": entry.period
                        }
                        
                # Determine status
                status = "occupied" if current_class else "available"
                # TODO: Check RoomMaintenance for "maintenance" status
                
                floors[floor].append({
                    "roomId": room.id,
                    "roomName": room.name,
                    "capacity": room.capacity,
                    "status": status,
                    "currentClass": current_class,
                    "nextClass": next_class,
                    "dailyUtilization": len(schedule)
                })
                
            campus_data.append({
                "buildingId": building.id,
                "buildingName": building.name,
                "floors": [{"floor": f, "rooms": r} for f, r in floors.items()]
            })
            
        return {"buildings": campus_data}
